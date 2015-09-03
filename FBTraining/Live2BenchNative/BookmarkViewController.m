 ////
//  BookmarkViewController.m
//  Live2BenchNative
//
//  Created by dev on 13-03-26.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "RatingAndCommentingField.h"
#import "BookmarkViewController.h"
#import "AppDelegate.h"
#import "ClipSharePopoverViewController.h"
#import "HeaderBar.h"
#import "CommentingRatingField.h"
#import "RatingInput.h"
#import "MyClipFilterViewController.h"
#import "CustomAlertView.h"
#import "VideoBarMyClipViewController.h"
#import "FullVideoBarMyClipViewController.h"
#import "TagPopOverContent.h"
#import "RJLVideoPlayer.h"
#import "FullScreenViewController.h"
#import "ScreenController.h"
#import "CustomLabel.h"
#import "BookmarkTableViewController.h"
#import "TestFilterViewController.h"
#import "Pip.h"
#import "PipViewController.h"
#import "FeedSwitchView.h"
#import "Clip.h"
#import "ClipDataContentDisplay.h"
#import "PxpFilterMyClipTabViewController.h"
#import "LocalMediaManager.h"
#import "PxpPlayerViewController.h"
#import "PxpFullscreenViewController.h"
#import "PxpClipContext.h"
#import "PxpVideoBar.h"

#define SMALL_MEDIA_PLAYER_HEIGHT   340
#define TOTAL_WIDTH                1024
#define LABEL_HEIGHT                 40
#define TABLE_WIDTH                 390
#define TABLE_WIDTH2                 390
#define COMMENTBOX_HEIGHT           200
#define COMMENTBOX_WIDTH            530//560

@interface BookmarkViewController ()

@property (strong, nonatomic) Clip                          * currentClip;
@property (strong, nonatomic) BookmarkTableViewController   * tableViewController;
@property (strong, nonatomic) NSDictionary                  * feeds;
@property (strong, nonatomic) UIButton                      * filterButton;
@property (strong, nonatomic) UIButton                      * userSortButton;
@property (strong, nonatomic) NSDictionary                  * selectedData;
@property (strong, nonatomic, nonnull) PxpPlayerViewController *playerViewController;
@property (strong, nonatomic, nonnull) PxpMyClipViewFullscreenViewController *fullscreenViewController;
@property (strong, nonatomic, nonnull) PxpClipContext *clipContext;
@property (strong, nonatomic, nonnull) PxpVideoBar *videoBar;

@end

@implementation BookmarkViewController{
    NSMutableArray                      * tagsWillUploadToDB;
    UIImageView                         * playbackRateBackGuide;
    UIImageView                         * playbackRateForwardGuide;
    UILabel                             * playbackRateBackLabel;
    UILabel                             * playbackRateForwardLabel;
    int                                 totalDBTagNumber;
    int                                 successDBTagNumber;
    BOOL                                isModifyingPlaybackRate;
    BOOL                                isFrameByFrame;
    float                               playbackRateRadius;
    float                               frameByFrameInterval;
    UIImageView                         * teleImage; //for telestration playback
    
    // Richards's new UI Elements
    MyClipFilterViewController          * _filterToolBoxView;
    TestFilterViewController            * componentFilter;
    HeaderBar                           * headerBar;
    CustomLabel                         * numTagsLabel;
    VideoBarMyClipViewController        * newVideoControlBar;
    FullVideoBarMyClipViewController    * newFullScreenVideoControlBar;
    FullScreenViewController            * testFullScreen;
    ScreenController                    * externalControlScreen;
    PipViewController                   * _pipController;
    Pip                                 * _pip;
    FeedSwitchView                      * _feedSwitch;
    ClipDataContentDisplay              * clipContentDisplay;
    NSMutableArray                      * _tagsToDisplay;
    BOOL                                _userSort;
}


@synthesize selectedTag;
@synthesize popoverController;
@synthesize progressBarIndex;
@synthesize allEvents;
@synthesize videoPlayer;
@synthesize teleViewController;
@synthesize playbackRateBackButton;
@synthesize playbackRateForwardButton;
@synthesize playNextClipButton;
@synthesize playPreviousClipButton;
@synthesize fullScreenMode;

//back from fullscreen, the viewwillappear function will be called twice.will change the value of fullscreenmode when the viewwillappear function was called the second time(viewWillAppearCalled = 2)
int viewWillAppearCalled;

#pragma mark - General Methods

- (id)init
{
    self = [super init];
    if (self) {
        [self setMainSectionTab:NSLocalizedString(@"My Clip", nil) imageName:@"myClipTab"];
    }
    return self;
}

-(id)initWithAppDelegate:(AppDelegate *)mainappDelegate
{
    self = [super initWithAppDelegate:mainappDelegate];
    if (self) {
        [self setMainSectionTab:NSLocalizedString(@"My Clip", nil) imageName:@"myClipTab"];
        externalControlScreen = _appDel.screenController;
        _pxpFilter              = [[PxpFilter alloc]init];
        _pxpFilter.delegate     = self;
        
        _pxpFilterTab                           = [[TabView alloc]init];
        _pxpFilterTab.pxpFilter                 = _pxpFilter;
        _pxpFilterTab.modalPresentationStyle    = UIModalPresentationPopover; // Might have to make it custom if we want the fade darker

        [_pxpFilterTab addTab:        [[PxpFilterMyClipTabViewController alloc]init]];
        

        _tagsToDisplay = [NSMutableArray new];
        
        _playerViewController = [[PxpPlayerViewController alloc] init];
        _fullscreenViewController = [[PxpMyClipViewFullscreenViewController alloc] initWithPlayerViewController:_playerViewController];
        
        [_fullscreenViewController.nextTagButton addTarget:self action:@selector(playNextClipButtonUp:) forControlEvents:UIControlEventTouchUpInside];
        [_fullscreenViewController.previousTagButton addTarget:self action:@selector(playPreviousClipButtonUp:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addChildViewController:_playerViewController];
        [self addChildViewController:_fullscreenViewController];
        
        _clipContext    = [PxpClipContext context];
        _videoBar       = [[PxpVideoBar alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NOTIF_CLIP_SELECTED object:nil queue:nil usingBlock:^(NSNotification *note) {
        
        Clip *clipToPlay = note.userInfo[@"clip"];
        NSString *source = note.userInfo[@"source"];
        __block BookmarkViewController *weakSelf = self;
        
        [clipContentDisplay displayClip:clipToPlay];
        clipContentDisplay.enable = YES;
        clipContentDisplay.ratingAndCommentingView.tagUpdate = ^(NSDictionary *tagData){
            clipToPlay.rating = [[tagData objectForKey:@"rating"] intValue];
            clipToPlay.comment = [tagData objectForKey:@"comment"];
            [weakSelf.tableViewController reloadData];
        };
        _clipContext = [PxpClipContext contextWithClip:clipToPlay];
        _playerViewController.playerView.player = source ? [_clipContext playerForName:source] : _clipContext.mainPlayer;
        [_videoBar setSelectedTag:clipToPlay];
        [_fullscreenViewController setSelectedTag:clipToPlay];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NOTIF_REMOVE_INFORMATION object:nil queue:nil usingBlock:^(NSNotification *note){
        [clipContentDisplay displayClip:nil];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:NOTIF_DELETE_CLIPS object:nil queue:nil usingBlock:^(NSNotification *note){
        
        [self.allClips removeObjectIdenticalTo:note.userInfo];
        componentFilter.rawTagArray = self.allClips;

    }];
    self.videoPlayer.playerContext = STRING_MYCLIP_CONTEXT;

    _pip            = [[Pip alloc]initWithFrame:CGRectMake(50, 50, 200, 150)];
    _pip.isDragAble  = YES;
    _pip.hidden      = YES;
    _pip.muted       = YES;
    _pip.dragBounds  = self.videoPlayer.view.frame;
    [self.videoPlayer.view addSubview:_pip];
    
    _feedSwitch     = [[FeedSwitchView alloc]initWithFrame:CGRectMake(1, 768 - SMALL_MEDIA_PLAYER_HEIGHT - 73, COMMENTBOX_WIDTH, 40)];
   
    _pipController  = [[PipViewController alloc]initWithVideoPlayer:self.videoPlayer f:_feedSwitch];
    _pipController.context = STRING_MYCLIP_CONTEXT;
    [_pipController addPip:_pip];
    [_pipController viewDidLoad];
    
    [self.view addSubview:_feedSwitch];
    //[_feedSwitch setHidden:!([_encoderManager.feeds count]>1)];
    
    //array of file paths
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];

    
    [self setupView];
    

    
    fullScreenMode = FALSE;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkFullScreen) name:@"Entering FullScreen" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkFullScreen) name:@"Exiting FullScreen" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clipSaved:) name:NOTIF_CLIP_SAVED object:nil];
  

    // This is for the tag count
    numTagsLabel = [[CustomLabel alloc] init];
    [numTagsLabel setMargin:CGRectMake(0, 5, 0, 5)];
    [numTagsLabel setTextAlignment:NSTextAlignmentRight];
    [numTagsLabel setText:NSLocalizedString(@"Tags",nil)];
    [numTagsLabel setTextColor:[UIColor whiteColor]];
    [numTagsLabel setBackgroundColor:[UIColor lightGrayColor]];
    [numTagsLabel setFont:[UIFont systemFontOfSize:14.0f]];
    
    [self.view addSubview:numTagsLabel];
    
    /*newVideoControlBar = [[VideoBarMyClipViewController alloc]initWithVideoPlayer:videoPlayer];
    [self.view addSubview:newVideoControlBar.view];
    [newVideoControlBar.playNextButton addTarget: self action:@selector(playNextClipButtonUp:) forControlEvents:UIControlEventTouchUpInside];
    [newVideoControlBar.playPreButton addTarget: self action:@selector(playPreviousClipButtonUp:) forControlEvents:UIControlEventTouchUpInside];*/
    
    
    //testFullScreen = [[FullScreenViewController alloc]initWithVideoPlayer:self.videoPlayer];
    _tableViewController.delegate = self;
    
    const CGFloat width = COMMENTBOX_WIDTH, height = width / (16.0 / 9.0);
    
    _playerViewController.view.frame = CGRectMake(0, 768 - height - 44.0, width, height);
    _playerViewController.telestrationViewController.stillMode = YES;
    _videoBar.playerViewController = _playerViewController;
    
    [self.view addSubview:_playerViewController.view];
    [self.view addSubview:_videoBar];
    [self.view addSubview:_fullscreenViewController.view];
    
    
    _videoBar.frame = CGRectMake(0.0, 768 - 44.0, width, 44.0);
    [_videoBar.fullscreenButton addTarget:_fullscreenViewController action:@selector(fullscreenResponseHandler:) forControlEvents:UIControlEventTouchUpInside];
    
    
    //show the buttons and setup the selector
    /*[self.videoBar showPlayNextPreButton];
    [_videoBar.playNextButton addTarget:self action:@selector(playNextClipButtonUp:) forControlEvents:UIControlEventTouchUpInside];
    [_videoBar.playPreButton addTarget:self action:@selector(playPreviousClipButtonUp:) forControlEvents:UIControlEventTouchUpInside];*/
}

- (void)clipSaved:(NSNotification *)note {
    [self.allClips addObject:note.object];
//    self.tableViewController.tableData = [self filterAndSortClips:self.allClips];
    
    self.tableViewController.tableData = _tagsToDisplay;
    [self.tableViewController reloadData];
    
    [numTagsLabel setText:[NSString stringWithFormat:@"Clip Total: %lu",(unsigned long)[_tagsToDisplay count]]];
}


-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];

    
    self.allClips = [NSMutableArray arrayWithArray:[[LocalMediaManager getInstance].clips allValues]];
    
    [_pxpFilter filterTags:self.allClips];
    
    self.tableViewController.tableData = _tagsToDisplay;

    CGRect tableRect = self.tableViewController.view.frame;
    numTagsLabel.frame = CGRectMake(tableRect.origin.x, CGRectGetMaxY(tableRect), tableRect.size.width, 18);
    


    
    //get all the events information which will be used to display home team, visit team
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];
    NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"EventsHid.plist"];
    NSMutableArray *eventsData = [[NSMutableArray alloc] initWithContentsOfFile: plistPath];
    for (NSDictionary *event in eventsData) {
        
        if (!allEvents) {
            allEvents = [[NSMutableDictionary alloc]initWithObjects:[[NSArray alloc]initWithObjects:event, nil] forKeys:[[NSArray alloc]initWithObjects:[event objectForKey:@"name"], nil]];
        }else{
            [allEvents setObject:event forKey:[NSString stringWithFormat:@"%@",[event objectForKey:@"name"]]];
        }
        
    }
    
    
    if(![self.view.subviews containsObject:self.videoPlayer.view])
    {
        [self.videoPlayer.view setFrame:CGRectMake(1, 768 - SMALL_MEDIA_PLAYER_HEIGHT - 32, COMMENTBOX_WIDTH, SMALL_MEDIA_PLAYER_HEIGHT)];
        [self.view addSubview:self.videoPlayer.view];
        
        UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(detectSwipe:)];
        [swipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
        [self.videoPlayer.view addGestureRecognizer:swipeGestureRecognizer];
        
        swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(detectSwipe:)];
        [swipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
        [self.videoPlayer.view addGestureRecognizer:swipeGestureRecognizer];
        
    }
    cellSelectedNumber = 0;
    
    fullScreenMode = FALSE;

    [self.videoPlayer pause];
    
    [newVideoControlBar viewDidAppear:NO];
    [numTagsLabel setText:[NSString stringWithFormat:@"Clip Total: %lu",(unsigned long)[_tagsToDisplay count]]];
}




-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    UIEdgeInsets insets = {10, 50, 0, 50};
    [numTagsLabel drawTextInRect:UIEdgeInsetsInsetRect(numTagsLabel.frame, insets)];

}


//initialize comment box and if one tag is selected, the tag details will show in the box too
-(void)setupView{
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    headerBar = [[HeaderBar alloc]initWithFrame:CGRectMake(0,55,TOTAL_WIDTH, LABEL_HEIGHT) defaultSort:DATE_FIELD | DESCEND];
    [headerBar onTapPerformSelector:@selector(sortFromHeaderBar:) addTarget:self];
    [self.view addSubview:headerBar];
    

    clipContentDisplay = [[ClipDataContentDisplay alloc]initWithFrame:CGRectMake(1,94, COMMENTBOX_WIDTH, COMMENTBOX_HEIGHT+60)];
    clipContentDisplay.enable = NO;

    
    [self.view addSubview:clipContentDisplay];
    
    self.tableViewController = [[BookmarkTableViewController alloc] init];
    self.tableViewController.contextString = @"CLIP";
    
    float divider = 535;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        [self.tableViewController.view setFrame:CGRectMake(divider + 5.0f,
                                                           CGRectGetMaxY(headerBar.frame),
                                                           self.view.bounds.size.width - COMMENTBOX_WIDTH - 30.0f,
                                                           self.view.bounds.size.height - CGRectGetMaxY(headerBar.frame) - 50.0f-18.0f)];
    } else {
        [self.tableViewController.view setFrame:CGRectMake(divider + 5.0f,
                                                           CGRectGetMaxY(headerBar.frame),
                                                           self.view.bounds.size.height - COMMENTBOX_WIDTH - 30.0f,
                                                           self.view.bounds.size.width - CGRectGetMaxY(headerBar.frame) - 50.0f-18.0f)];
    }
    
    
    self.tableViewController.view.autoresizingMask = UIViewAutoresizingNone;
    [self addChildViewController: self.tableViewController];
    [self.view addSubview: self.tableViewController.view];
    
    self.filterButton = [[UIButton alloc] initWithFrame:CGRectMake(950, 710, 74, 58)];
    [self.filterButton setTitle:NSLocalizedString(@"Filter",nil) forState:UIControlStateNormal];
    [self.filterButton setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
    [self.filterButton addTarget:self action:@selector(slideFilterBox) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: self.filterButton];
    
    self.userSortButton = [[UIButton alloc] initWithFrame:CGRectMake(800, 710,100, 58)];
    [self.userSortButton setTitle:@"User Sort" forState:UIControlStateNormal];
    [self.userSortButton setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
    [self.userSortButton addTarget:self action:@selector(useCustomSort:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: self.userSortButton];

}




//return the tag dictionary of each cell
- (NSMutableDictionary*)tagAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.allClips objectAtIndex:indexPath.row];
}


#pragma mark - Filter Button Pressed


- (void)slideFilterBox
{
    
    if (_pxpFilterTab.isViewLoaded)
    {
        _pxpFilterTab.view.frame =  CGRectMake(0, 0, _pxpFilterTab.preferredContentSize.width,_pxpFilterTab.preferredContentSize.height);
    }
 
    UIPopoverPresentationController *presentationController = [_pxpFilterTab popoverPresentationController];
    presentationController.sourceRect               = [[UIScreen mainScreen] bounds];
    presentationController.sourceView               = self.view;
    presentationController.permittedArrowDirections = 0;
    
    [self presentViewController:_pxpFilterTab animated:YES completion:nil];
    
    
   [_pxpFilter filterTags:[self.allClips copy]];
    

    
}

- (void)dismissFilterToolbox
{
    [_filterToolBoxView close:YES]; // Slide filter close
    blurView.hidden = YES;
    [componentFilter close:YES];
}


/**
 *  This is for detecteing swipes on the video player
 *  maybe this should be on the player it self??
 *  @param gestureRecognizer
 */
-(void)detectSwipe:(UISwipeGestureRecognizer *)gestureRecognizer
{
    //    switch (gestureRecognizer.direction) {
    //        case UISwipeGestureRecognizerDirectionLeft:
    //            if (!fullScreenMode) {
    //                [currentSeekBackButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    //            }else{
    //                [currentSeekBackButtoninFullScreen sendActionsForControlEvents:UIControlEventTouchUpInside];
    //            }
    //            break;
    //        case UISwipeGestureRecognizerDirectionRight:
    //            if (!fullScreenMode) {
    //                [currentSeekForwardButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    //            }else{
    //                [currentSeekForwardButtoninFullScreen sendActionsForControlEvents:UIControlEventTouchUpInside];
    //            }
    //            break;
    //        default:
    //            break;
    //    }
}

#pragma mark - Richard Sort from headder
-(void)sortFromHeaderBar:(id)sender
{
    
    self.tableViewController.tableData = [self filterAndSortClips:_tagsToDisplay];
    [self.tableViewController.tableView reloadData];
    

}

-(NSMutableArray*)sortArrayFromHeaderBar:(NSMutableArray*)toSort headerBarState:(HBSortType) sortType
{
    
    NSSortDescriptor *sorter;
    //Fields are from HeaderBar.h
    if(sortType & TIME_FIELD){
        sorter = [NSSortDescriptor
                  sortDescriptorWithKey:@"displayTime"
                  ascending:(sortType & ASCEND)?YES:NO
                  selector:@selector(compare:)];
        
    } else if (sortType & DATE_FIELD) {
        sorter = [NSSortDescriptor
                  sortDescriptorWithKey:@"eventName"
                  ascending:(sortType & ASCEND)?YES:NO
                  selector:@selector(caseInsensitiveCompare:)];
    }  else if (sortType & NAME_FIELD) {
        sorter = [NSSortDescriptor
                  sortDescriptorWithKey:@"name"
                  ascending:(sortType & ASCEND)?YES:NO
                  selector:@selector(caseInsensitiveCompare:)];
    }  else if (sortType & RATING_FIELD) {
        
        sorter = [NSSortDescriptor sortDescriptorWithKey:@"rating" ascending:(sortType & ASCEND)? YES:NO selector:@selector(compare:)];
    } else {
        return toSort;
    }
    
    return [NSMutableArray arrayWithArray:[toSort sortedArrayUsingDescriptors:@[sorter]]];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //pause video and remove the time observer
    [videoPlayer pause];
    
    //we will remove the filtertoolbox to deallocate mem -- makes sure app does not freeze up
    [_filterToolBoxView.view removeFromSuperview];
    _filterToolBoxView=nil;
    currentPlayingTag = nil;
}



-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.videoPlayer pause];
}




#pragma mark - Play Rate Controlls
-(void)showPlaybackRateControls
{
    if (playbackRateBackButton){
        [playbackRateBackButton removeFromSuperview];
        playbackRateBackButton = nil;
        [playbackRateBackGuide removeFromSuperview];
        playbackRateBackGuide = nil;
        [playbackRateBackLabel removeFromSuperview];
        playbackRateBackLabel = nil;
    }
    if (playbackRateForwardButton){
        [playbackRateForwardButton removeFromSuperview];
        playbackRateForwardButton = nil;
        [playbackRateForwardGuide removeFromSuperview];
        playbackRateForwardGuide = nil;
        [playbackRateForwardLabel removeFromSuperview];
        playbackRateForwardLabel = nil;
    }
    
    if (playNextClipButton){
        [playNextClipButton removeFromSuperview];
        playNextClipButton = nil;
    }
    
    if (playPreviousClipButton){
        [playPreviousClipButton removeFromSuperview];
        playPreviousClipButton = nil;
    }
    
    //play next/previous clip controlls
    playNextClipButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    [playNextClipButton setFrame:CGRectMake(80, 585, 70.0f, 70.0f)];
    [playNextClipButton setContentMode:UIViewContentModeScaleAspectFit];
    [playNextClipButton setTag:0];
    [playNextClipButton setImage:[UIImage imageNamed:@"playbackRateButtonBack"] forState:UIControlStateNormal];
    [playNextClipButton setImage:[UIImage imageNamed:@"playbackRateButtonBackSelected"] forState:UIControlStateHighlighted];
    [playNextClipButton setImage:[UIImage imageNamed:@"playbackRateButtonBackSelected"] forState:UIControlStateSelected];
    [playNextClipButton addTarget:self action:@selector(playNextClipButtonUp:) forControlEvents:UIControlEventTouchUpInside];
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:playNextClipButton];
    
    playPreviousClipButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    [playPreviousClipButton setFrame:CGRectMake(80, 585, 70.0f, 70.0f)];
    [playPreviousClipButton setContentMode:UIViewContentModeScaleAspectFit];
    [playPreviousClipButton setTag:0];
    [playPreviousClipButton setImage:[UIImage imageNamed:@"playbackRateButtonBack"] forState:UIControlStateNormal];
    [playPreviousClipButton setImage:[UIImage imageNamed:@"playbackRateButtonBackSelected"] forState:UIControlStateHighlighted];
    [playPreviousClipButton setImage:[UIImage imageNamed:@"playbackRateButtonBackSelected"] forState:UIControlStateSelected];
    [playPreviousClipButton addTarget:self action:@selector(playPreviousClipButtonUp:) forControlEvents:UIControlEventTouchUpInside];
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:playPreviousClipButton];
    
    //Playback rate controls
    playbackRateBackButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    [playbackRateBackButton setFrame:CGRectMake(165, 585, 70.0f, 70.0f)];
    [playbackRateBackButton setContentMode:UIViewContentModeScaleAspectFit];
    [playbackRateBackButton setTag:0];
    [playbackRateBackButton setImage:[UIImage imageNamed:@"playbackRateButtonBack"] forState:UIControlStateNormal];
    [playbackRateBackButton setImage:[UIImage imageNamed:@"playbackRateButtonBackSelected"] forState:UIControlStateHighlighted];
    [playbackRateBackButton setImage:[UIImage imageNamed:@"playbackRateButtonBackSelected"] forState:UIControlStateSelected];
    [playbackRateBackButton addTarget:self action:@selector(playbackRateButtonDown:) forControlEvents:UIControlEventTouchDown];
    [playbackRateBackButton addTarget:self action:@selector(playbackRateButtonUp:) forControlEvents:UIControlEventTouchUpInside];
    [playbackRateBackButton addTarget:self action:@selector(playbackRateButtonUp:) forControlEvents:UIControlEventTouchUpOutside];
    [playbackRateBackButton addTarget:self action:@selector(playbackRateButtonDrag:forEvent:) forControlEvents:UIControlEventTouchDragInside];
    [playbackRateBackButton addTarget:self action:@selector(playbackRateButtonDrag:forEvent:) forControlEvents:UIControlEventTouchDragOutside];
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:playbackRateBackButton];
    
    playbackRateBackGuide = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"playbackRateTrackBack"]];
    [playbackRateBackGuide setFrame:CGRectMake(playbackRateBackButton.frame.origin.x - 148, playbackRateBackButton.frame.origin.y - 146, playbackRateBackGuide.bounds.size.width, playbackRateBackGuide.bounds.size.height)];
    [playbackRateBackGuide setContentMode:UIViewContentModeScaleAspectFit];
    [playbackRateBackGuide setAlpha:0.0f];
    [[UIApplication sharedApplication].keyWindow.rootViewController.view insertSubview:playbackRateBackGuide belowSubview:playbackRateBackButton];
    
    playbackRateBackLabel = [CustomLabel labelWithStyle:CLStyleWhite];
    [playbackRateBackLabel setFrame:CGRectMake(CGRectGetMaxX(playbackRateBackButton.frame), playbackRateBackButton.frame.origin.y, 60.0f, 30.0f)];
    [playbackRateBackLabel setText:@"-2fps"];
    [playbackRateBackLabel setTextAlignment:NSTextAlignmentCenter];
    [playbackRateBackLabel.layer setCornerRadius:4.0f];
    [playbackRateBackLabel setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.2f]];
    [playbackRateBackLabel setAlpha:0.0f];
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:playbackRateBackLabel];
    
    playbackRateForwardButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    [playbackRateForwardButton setFrame:CGRectMake(playbackRateBackButton.superview.bounds.size.width - playbackRateBackButton.frame.origin.x - playbackRateBackButton.bounds.size.width, playbackRateBackButton.frame.origin.y, playbackRateBackButton.bounds.size.width, playbackRateBackButton.bounds.size.height)];
    [playbackRateForwardButton setContentMode:UIViewContentModeScaleAspectFit];
    [playbackRateForwardButton setTag:1];
    [playbackRateForwardButton setImage:[UIImage imageNamed:@"playbackRateButtonForward"] forState:UIControlStateNormal];
    [playbackRateForwardButton setImage:[UIImage imageNamed:@"playbackRateButtonForwardSelected"] forState:UIControlStateHighlighted];
    [playbackRateForwardButton setImage:[UIImage imageNamed:@"playbackRateButtonForwardSelected"] forState:UIControlStateSelected];
    [playbackRateForwardButton addTarget:self action:@selector(playbackRateButtonDown:) forControlEvents:UIControlEventTouchDown];
    [playbackRateForwardButton addTarget:self action:@selector(playbackRateButtonUp:) forControlEvents:UIControlEventTouchUpInside];
    [playbackRateForwardButton addTarget:self action:@selector(playbackRateButtonUp:) forControlEvents:UIControlEventTouchUpOutside];
    [playbackRateForwardButton addTarget:self action:@selector(playbackRateButtonDrag:forEvent:) forControlEvents:UIControlEventTouchDragInside];
    [playbackRateForwardButton addTarget:self action:@selector(playbackRateButtonDrag:forEvent:) forControlEvents:UIControlEventTouchDragOutside];
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:playbackRateForwardButton];
    
    playbackRateForwardGuide = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"playbackRateTrackForward"]];
    [playbackRateForwardGuide setFrame:CGRectMake(playbackRateForwardButton.superview.bounds.size.width - playbackRateBackGuide.bounds.size.width - (playbackRateBackButton.frame.origin.x - 148), playbackRateBackGuide.frame.origin.y, playbackRateBackGuide.bounds.size.width, playbackRateBackGuide.bounds.size.height)];
    [playbackRateForwardGuide setContentMode:UIViewContentModeScaleAspectFit];
    [playbackRateForwardGuide setAlpha:0.0f];
    [[UIApplication sharedApplication].keyWindow.rootViewController.view insertSubview:playbackRateForwardGuide belowSubview:playbackRateForwardButton];
    
    playbackRateForwardLabel = [CustomLabel labelWithStyle:CLStyleWhite];
    [playbackRateForwardLabel setFrame:CGRectMake(playbackRateForwardButton.frame.origin.x - playbackRateBackLabel.bounds.size.width, playbackRateForwardButton.frame.origin.y, playbackRateBackLabel.bounds.size.width, playbackRateBackLabel.bounds.size.height)];
    [playbackRateForwardLabel setText:@"2fps"];
    [playbackRateForwardLabel setTextAlignment:NSTextAlignmentCenter];
    [playbackRateForwardLabel.layer setCornerRadius:4.0f];
    [playbackRateForwardLabel setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.2f]];
    [playbackRateForwardLabel setAlpha:0.0f];
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:playbackRateForwardLabel];
}

-(void)updateSelectedTagToVideoBar{
    _videoBar.selectedTag = self.tableViewController.tableData[self.tableViewController.selectedPath.row];
}

-(void)playNextClipButtonUp:(id)sender{
    [self.tableViewController playNext];
}

-(void)playPreviousClipButtonUp:(id)sender{
    [self.tableViewController playPrevious];
}

-(void)playbackRateButtonDown:(id)sender
{
    isModifyingPlaybackRate = YES;
    
    if ([sender tag] == 0) {
        [UIView animateWithDuration:0.3f animations:^{
            [playbackRateBackGuide setAlpha:1.0f];
            //            [self.overlayLeftViewController.view setAlpha:0.0f];
            [playbackRateBackLabel setAlpha:1.0f];
        }];
    } else if ([sender tag] == 1){
        [UIView animateWithDuration:0.3f animations:^{
            [playbackRateForwardGuide setAlpha:1.0f];
            //            [self.overlayRightViewController.view setAlpha:0.0f];
            [playbackRateForwardLabel setAlpha:1.0f];
        }];
    }

}

-(void)playbackRateButtonUp:(id)sender
{
    isModifyingPlaybackRate = NO;
    if ([sender tag] == 0) {
        [UIView animateWithDuration:0.3f animations:^{
            [playbackRateBackGuide setAlpha:0.0f];
            //            [self.overlayLeftViewController.view setAlpha:1.0f];
            [playbackRateBackButton setFrame:CGRectMake(165, 535, 70.0f, 70.0f)];
            [playbackRateBackLabel setFrame:CGRectMake(CGRectGetMaxX(playbackRateBackButton.frame), playbackRateBackButton.frame.origin.y, playbackRateBackLabel.bounds.size.width, playbackRateBackLabel.bounds.size.height)];
            [playbackRateBackLabel setAlpha:0.0f];
        }];
    } else if ([sender tag] == 1){
        [UIView animateWithDuration:0.3f animations:^{
            [playbackRateForwardGuide setAlpha:0.0f];
            //            [self.overlayRightViewController.view setAlpha:1.0f];
            [playbackRateForwardButton setFrame:CGRectMake(playbackRateBackButton.superview.bounds.size.width - playbackRateBackButton.frame.origin.x - playbackRateBackButton.bounds.size.width, playbackRateBackButton.frame.origin.y, playbackRateBackButton.bounds.size.width, playbackRateBackButton.bounds.size.height)];
            [playbackRateForwardLabel setFrame:CGRectMake(playbackRateForwardButton.frame.origin.x - playbackRateForwardLabel.bounds.size.width, playbackRateForwardButton.frame.origin.y, playbackRateForwardLabel.bounds.size.width, playbackRateForwardLabel.bounds.size.height)];
            [playbackRateForwardLabel setAlpha:0.0f];
            
        }];
    }
    //    globals.PLAYBACK_SPEED = 0.0;
    //    [videoPlayer.avPlayer setRate:globals.PLAYBACK_SPEED];
}

-(void)playbackRateButtonDrag:(id)sender forEvent:(UIEvent*)event
{
    //    UIButton* button = sender;
    //    UITouch *touch = [[event touchesForView:button] anyObject];
    //    CGPoint touchPoint = [touch locationInView:button.superview];
    //    CGPoint buttonPosition = [self coordForPosition:touchPoint onGuide:[button tag]];
    //    [button setCenter:buttonPosition];
    //    if ([button tag] == 0) {
    //        [playbackRateBackLabel setFrame:CGRectMake(CGRectGetMaxX(button.frame), button.frame.origin.y, playbackRateBackLabel.bounds.size.width, playbackRateBackLabel.bounds.size.height)];
    //        if (isFrameByFrame) {
    //            [playbackRateBackLabel setText:[NSString stringWithFormat:@"-%.0fps",1/frameByFrameInterval]];
    //        } else {
    //            [playbackRateBackLabel setText:[NSString stringWithFormat:@"%.2fx",globals.PLAYBACK_SPEED]];
    //        }
    //    } else if ([button tag] == 1){
    //        [playbackRateForwardLabel setFrame:CGRectMake(button.frame.origin.x - playbackRateForwardLabel.bounds.size.width, button.frame.origin.y, playbackRateForwardLabel.bounds.size.width, playbackRateForwardLabel.bounds.size.height)];
    //        if (isFrameByFrame) {
    //            [playbackRateForwardLabel setText:[NSString stringWithFormat:@"%.0ffps",1/frameByFrameInterval]];
    //        } else {
    //            [playbackRateForwardLabel setText:[NSString stringWithFormat:@"%.2fx",globals.PLAYBACK_SPEED]];
    //        }
    //    }
    //    if (videoPlayer.avPlayer.rate != globals.PLAYBACK_SPEED) {
    //        videoPlayer.avPlayer.rate = globals.PLAYBACK_SPEED;
    //    }
}

-(CGPoint)coordForPosition:(CGPoint)point onGuide:(int)tag
{
    float yPos = 0.0f;
    float xPos = 0.0f;
    CGPoint guidePivot;
    float theta = 0.0f;
    float degrees = 0.0f;
    playbackRateRadius = 118.0f + playbackRateBackButton.bounds.size.width/2;
    if (tag == 0){
        guidePivot = CGPointMake(playbackRateBackGuide.frame.origin.x + 30.0f, CGRectGetMaxY(playbackRateBackGuide.frame) - 25.0f);
        theta = atan2f(point.y - guidePivot.y, point.x - guidePivot.x);
        if (theta*180/M_PI < -87){
            theta = -87*M_PI/180;
        } else if (theta*180/M_PI > -3){
            theta = -3*M_PI/180;
        }
        
        degrees = -(theta*180.0f/M_PI);
        float degRange = 84.0f;
        float increment = degRange/6;
        
        if (degrees <= 3){
            [self startFrameByFrameScrollingAtInterval:0.5f goingForward:FALSE];
        } else if (degrees > 3 && degrees < increment*2){
            [self startFrameByFrameScrollingAtInterval:0.2f goingForward:FALSE];
        } else {
            isFrameByFrame = NO;
            //            if (degrees >= increment*2 && degrees < increment*3){
            //                globals.PLAYBACK_SPEED = 0.25f;
            //            } else if (degrees >= increment*3 && degrees < increment*4){
            //                globals.PLAYBACK_SPEED = 0.5f;
            //            } else if (degrees >= increment*4 && degrees < increment*5){
            //                globals.PLAYBACK_SPEED = 1.0f;
            //            } else if (degrees >= increment*5 && degrees < (increment*6 - 1)){
            //                globals.PLAYBACK_SPEED = 2.0f;
            //            } else if (degrees >= (increment*6 - 3)){
            //                globals.PLAYBACK_SPEED = 4.0f;
            //            }
        }
        //        globals.PLAYBACK_SPEED = -globals.PLAYBACK_SPEED;
        
        yPos = sinf(theta)*playbackRateRadius;
        xPos = cosf(theta)*playbackRateRadius;
        yPos += guidePivot.y;
        xPos += guidePivot.x;
    } else if (tag == 1){
        guidePivot = CGPointMake(CGRectGetMaxX(playbackRateForwardGuide.frame) - 30.0f, CGRectGetMaxY(playbackRateForwardGuide.frame) - 25.0f);
        theta = atan2f(point.y - guidePivot.y, guidePivot.x - point.x);
        if (theta*180/M_PI < -87){
            theta = -87*M_PI/180;
        } else if (theta*180/M_PI > -3){
            theta = -3*M_PI/180;
        }
        degrees = -(theta*180.0f/M_PI);
        float degRange = 84.0f;
        float increment = degRange/6;
        
        if (degrees <= 3){
            [self startFrameByFrameScrollingAtInterval:0.5f goingForward:TRUE];
        } else if (degrees > 3 && degrees < increment*2){
            [self startFrameByFrameScrollingAtInterval:0.2f goingForward:TRUE];
        } else {
            isFrameByFrame = NO;
            //            if (degrees >= increment*2 && degrees < increment*3){
            //                globals.PLAYBACK_SPEED = 0.25f;
            //            } else if (degrees >= increment*3 && degrees < increment*4){
            //                globals.PLAYBACK_SPEED = 0.5f;
            //            } else if (degrees >= increment*4 && degrees < increment*5){
            //                globals.PLAYBACK_SPEED = 1.0f;
            //            } else if (degrees >= increment*5 && degrees < (increment*6 - 1)){
            //                globals.PLAYBACK_SPEED = 2.0f;
            //            } else if (degrees >= (increment*6 - 3)){
            //                globals.PLAYBACK_SPEED = 4.0f;
            //            }
        }
        
        
        yPos = sinf(theta)*playbackRateRadius;
        xPos = cosf(theta)*playbackRateRadius;
        yPos += guidePivot.y;
        xPos -= guidePivot.x;
        xPos = -xPos;
    }
    return CGPointMake(xPos, yPos);
}

- (void)startFrameByFrameScrollingAtInterval:(float)interval goingForward:(BOOL)forward
{
    frameByFrameInterval = interval;
    if (isFrameByFrame) {
        return;
    } else {
        isFrameByFrame = YES;
    }
    if (forward){
        [self frameByFrameForward];
    } else {
        [self frameByFrameBackward];
    }
    
}

- (void)frameByFrameForward
{
    if (isFrameByFrame) {
        [videoPlayer.avPlayer.currentItem stepByCount:1];
        [NSTimer scheduledTimerWithTimeInterval:frameByFrameInterval target:self selector:@selector(frameByFrameForward) userInfo:nil repeats:NO];
    }
}

- (void)frameByFrameBackward
{
    if (isFrameByFrame) {
        [videoPlayer.avPlayer.currentItem stepByCount:-1];
        [NSTimer scheduledTimerWithTimeInterval:frameByFrameInterval target:self selector:@selector(frameByFrameBackward) userInfo:nil repeats:NO];
    }
}

-(void)createAllFullScreenSubviews
{
    
    
    // Richard
    newFullScreenVideoControlBar = [[FullVideoBarMyClipViewController alloc]initWithVideoPlayer:videoPlayer];
    [newFullScreenVideoControlBar viewDidAppear:NO];
    [newFullScreenVideoControlBar onPressNextPrevPerformSelector:@selector(playNextOrPreTag:) addTarget:self];
    [newFullScreenVideoControlBar setTagName:[currentPlayingTag objectForKey:@"name"]];
    
    if ([[currentPlayingTag objectForKey:@"type"]intValue] != 4) {
        //show telestration button
        [self showPlaybackRateControls];
    }
    
    // Richard
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:newFullScreenVideoControlBar.view];
}


/**
 *  This will play the next tag in the tableview based of the button's tag value
 *
 *  @param sender button
 */
-(void)playNextOrPreTag:(id)sender
{
    NSInteger buttonTagValue  = ((UIButton*)sender).tag;
    NSInteger nextIndex = wasPlayingIndexPath.row + buttonTagValue;
    if(nextIndex > self.allClips.count -1 || nextIndex <0){
        return;
    }
    

}


-(void)removeAllFullScreenSubviews
{
    
    [playNextClipButton removeFromSuperview];
    [playPreviousClipButton removeFromSuperview];
    //
    [playbackRateBackButton removeFromSuperview];
    [playbackRateBackLabel removeFromSuperview];
    [playbackRateBackGuide removeFromSuperview];
    [playbackRateForwardButton removeFromSuperview];
    [playbackRateForwardLabel removeFromSuperview];
    [playbackRateForwardGuide removeFromSuperview];
    // Richard
    [newFullScreenVideoControlBar.view removeFromSuperview];
}

// This will dismiss the filter View Controller
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
}


#pragma mark - Richard Filtering
-(void)receiveFilteredArrayFromFilter:(id)filter
{
    self.tableViewController.tableData = [self filterAndSortClips:self.allClips];
    [self.tableViewController reloadData];
}

- (NSString*)cloudFileNameWithTag: (NSDictionary*)tag
{
    NSString* type = @"mp4";
    NSString* eventName = [NSString stringWithFormat:@"[%@ vs %@](%@)", [tag objectForKey:@"homeTeam"], [tag objectForKey:@"visitTeam"], [[tag objectForKey:@"event"] substringToIndex:10]];
    NSString* fileName = [NSString stringWithFormat:@"My Clip Video: %@.%@", eventName, type];
    return fileName;
}

-(void)useCustomSort:(id)sender
{
    if(self.tableViewController.editing == NO)
        [self.tableViewController setEditing:YES];
    else
        [self.tableViewController setEditing:NO];

}





-(NSMutableArray *)filterAndSortClips:(NSArray *)clips {
    NSMutableArray *clipsToSort = [NSMutableArray arrayWithArray:clips];
    if (componentFilter) {
        componentFilter.rawTagArray = clipsToSort;
        clipsToSort = [NSMutableArray arrayWithArray:componentFilter.processedList];
    }
    return [self sortArrayFromHeaderBar:clipsToSort headerBarState:headerBar.headerBarSortType];
}

#pragma mark - PxpFilterDelegate Methods
-(void)onFilterComplete:(PxpFilter*)filter
{
    [_tagsToDisplay removeAllObjects];
    [_tagsToDisplay addObjectsFromArray:filter.filteredTags];
    [_tableViewController reloadData];
    [numTagsLabel setText:[NSString stringWithFormat:@"Clip Total: %lu",(unsigned long)[_tagsToDisplay count]]];
}

-(void)onFilterChange:(PxpFilter *)filter
{
    [filter filterTags:self.allClips];
    [_tagsToDisplay removeAllObjects];
    [_tagsToDisplay addObjectsFromArray:filter.filteredTags];
    [_tableViewController reloadData];
    [numTagsLabel setText:[NSString stringWithFormat:@"Clip Total: %lu",(unsigned long)[_tagsToDisplay count]]];
    
}


#pragma mark - DeletableTableViewControllerDelegate Methods

-(void)tableView:(DeletableTableViewController *)tableView indexesToBeDeleted:(NSArray *)toBeDeleted
{
    for (NSIndexPath *cellIndexPath in toBeDeleted) {
        Clip * aClip = [_tagsToDisplay objectAtIndex:cellIndexPath.row];
        if ([self.allClips containsObject:aClip]) {
            [self.allClips removeObject:aClip];
        }
        
    }
}

#pragma mark -
-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

@end

