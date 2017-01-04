 ////
//  BookmarkViewController.m
//  Live2BenchNative
//
//  Created by dev on 13-03-26.
//  Copyright (c) 2013 DEV. All rights reserved.
//


#import "BookmarkViewController.h"
#import "HeaderBar.h"
#import "ScreenController.h"
#import "CustomLabel.h"
#import "BookmarkTableViewController.h"

#import "Clip.h"
#import "ClipDataContentDisplay.h"
#import "PxpFilterMyClipTabViewController.h"
#import "LocalMediaManager.h"
#import "PxpPlayerViewController.h"
#import "PxpFullscreenViewController.h"
#import "PxpClipContext.h"
#import "PxpVideoBar.h"


#import "RicoPlayer.h"
#import "RicoPlayerControlBar.h"
#import "RicoPlayerViewController.h"
#import "RicoZoomContainer.h"

#import "RicoBaseFullScreenViewController.h"
#import "RicoFullScreenControlBar.h"
#import "RicoPlayerGroupContainer.h"

#import "RicoBookmarkPlayerController.h"


#define SMALL_MEDIA_PLAYER_HEIGHT   340
#define TOTAL_WIDTH                1024
#define LABEL_HEIGHT                 40
#define TABLE_WIDTH                 390
#define TABLE_WIDTH2                 390
#define COMMENTBOX_HEIGHT           200
#define COMMENTBOX_WIDTH            530//560

@interface BookmarkViewController () <RicoBaseFullScreenDelegate,PxpTelestrationViewControllerDelegate,PxpTimeProvider>

@property (strong, nonatomic) Clip                          * currentClip;
@property (strong, nonatomic) BookmarkTableViewController   * tableViewController;
@property (strong, nonatomic) NSDictionary                  * feeds;
@property (strong, nonatomic) UIButton                      * filterButton;
@property (strong, nonatomic) UIButton                      * userSortButton;
@property (strong, nonatomic) NSDictionary                  * selectedData;




@property (strong, nonatomic, nonnull) PxpClipContext *clipContext;



@property (strong, nonatomic, nonnull) PxpVideoBar *videoBar;


@property (strong, nonatomic, nonnull) PxpTelestrationViewController    * telestrationViewController;
@property (strong, nonatomic) RicoPlayer                  * ricoPlayer;


@property (strong, nonatomic) RicoPlayerControlBar        * ricoPlayerControlBar;
@property (strong, nonatomic) RicoPlayerViewController    * ricoPlayerController;
@property (strong, nonatomic) RicoZoomContainer           * ricoZoomer;
@property (strong, nonatomic) RicoFullScreenControlBar    * ricoFullScreenControlBar;


@property (strong, nonatomic, nonnull) RicoPlayerGroupContainer         * ricoZoomGroup;

@property (strong, nonatomic, nonnull) RicoBaseFullScreenViewController *fullscreenViewController;


@property (strong, nonatomic, nonnull) RicoBookmarkPlayerController *ricoBookmarkPlayerController;



@end

@implementation BookmarkViewController{
   
    // Richards's new UI Elements
    HeaderBar                           * headerBar;
    CustomLabel                         * numTagsLabel;
    ScreenController                    * externalControlScreen;
    ClipDataContentDisplay              * clipContentDisplay;
    NSMutableArray                      * _tagsToDisplay;
    BOOL                                _wasPausedBeforeTele;
}

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
        externalControlScreen                   = _appDel.screenController;
        _pxpFilter                              = [[PxpFilter alloc]init];
        _pxpFilter.delegate                     = self;
        _pxpFilterTab                           = [[TabView alloc]init];
        _pxpFilterTab.pxpFilter                 = _pxpFilter;
        _pxpFilterTab.modalPresentationStyle    = UIModalPresentationPopover; // Might have to make it custom if we want the fade darker

        [_pxpFilterTab addTab:        [[PxpFilterMyClipTabViewController alloc]init]];
        _tagsToDisplay                          = [NSMutableArray new];
        
//        _playerViewController                   = [[PxpPlayerViewController alloc] init];
//        self.ricoPlayerController               = [RicoPlayerViewController new];

        _videoBar       = [[PxpVideoBar alloc] init];
        
        [_videoBar.forwardSeekButton    addTarget:self action:@selector(onSeekButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        [_videoBar.backwardSeekButton   addTarget:self action:@selector(onSeekButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        [_videoBar.slomoButton addTarget:self action:@selector(slomoPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clipSelectedToPlay:) name:NOTIF_CLIP_SELECTED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clipsSelectedToBedeleted:) name:NOTIF_DELETE_CLIPS object:nil];
    [[NSNotificationCenter defaultCenter] addObserverForName:NOTIF_REMOVE_INFORMATION object:nil queue:nil usingBlock:^(NSNotification *note){
        [clipContentDisplay displayClip:nil];
    }];
//    [[NSNotificationCenter defaultCenter] addObserverForName:NOTIF_DELETE_CLIPS object:nil queue:nil usingBlock:^(NSNotification *note){
//        [self.allClips removeObjectIdenticalTo:note.userInfo];
//    }];
    
    [self setupView];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clipSaved:) name:NOTIF_CLIP_SAVED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clipAutoSaved:) name:NOTIF_AUTO_DOWNLOAD_COMPLETE object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self.tableViewController selector:@selector(reloadData) name:NOTIF_AUTO_DOWNLOAD_COMPLETE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBookmarkPlayerControlerChange:) name:BOOKMARK_PLAYER_CONTROLLER_CHANGE object:nil];
  
    // This is for the tag count
    numTagsLabel = [[CustomLabel alloc] init];
    [numTagsLabel setMargin:CGRectMake(0, 5, 0, 5)];
    [numTagsLabel setTextAlignment:NSTextAlignmentRight];
    [numTagsLabel setText:NSLocalizedString(@"Tags",nil)];
    [numTagsLabel setTextColor:[UIColor whiteColor]];
    [numTagsLabel setBackgroundColor:[UIColor lightGrayColor]];
    [numTagsLabel setFont:[UIFont systemFontOfSize:14.0f]];
    
    [self.view addSubview:numTagsLabel];

    _tableViewController.delegate = self;
    
    const CGFloat width = COMMENTBOX_WIDTH, height = width / (16.0 / 9.0);
    

    
    
    // Rico Player
    
    CGRect theFrame = CGRectMake(0.0,  768 - height - 88.0, width, height);
    
    self.ricoPlayerControlBar = [[RicoPlayerControlBar alloc]initWithFrame:CGRectMake(0.0,  768 - 88.0, width, 44)];
   
    self.ricoPlayerControlBar.enabled = NO;
    

    
    
    [self.ricoPlayerControlBar.playPauseButton addTarget:self action:@selector(onPlayPause:) forControlEvents:UIControlEventTouchUpInside];
    
    self.ricoBookmarkPlayerController = [[RicoBookmarkPlayerController alloc]initWithFrame:theFrame];
    self.ricoPlayerController = self.ricoBookmarkPlayerController.ricoPlayerController;
    [self.view addSubview:self.ricoBookmarkPlayerController.view];
    [self.view addSubview:self.ricoPlayerControlBar];
    
    self.ricoPlayerController.playerControlBar = self.ricoPlayerControlBar;
    self.ricoPlayerControlBar.delegate                                      = self.ricoPlayerController;
    self.ricoPlayerControlBar.state                                         = RicoPlayerStateNormal;
    
       _fullscreenViewController               = [[RicoBaseFullScreenViewController alloc] initWithView:self.ricoBookmarkPlayerController.view];
    _fullscreenViewController.delegate      = self;

    _ricoFullScreenControlBar               = [[RicoFullScreenControlBar alloc]init];
    [_fullscreenViewController.bottomBar addSubview:_ricoFullScreenControlBar];
    
    [self.ricoFullScreenControlBar.backwardSeekButton           addTarget: self action:@selector(onSeekButtonPress:)        forControlEvents:UIControlEventTouchUpInside];
    [self.ricoFullScreenControlBar.forwardSeekButton            addTarget: self action:@selector(onSeekButtonPress:)        forControlEvents:UIControlEventTouchUpInside];
    [self.ricoFullScreenControlBar.slomoButton                  addTarget: self action:@selector(slomoPressed:)       forControlEvents:UIControlEventTouchUpInside];
    [self.ricoFullScreenControlBar.controlBar.playPauseButton   addTarget: self action:@selector(onPlayPause:) forControlEvents:UIControlEventTouchUpInside];
    [self.ricoFullScreenControlBar.fullscreenButton             addTarget: _fullscreenViewController action:@selector(fullscreenResponseHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.ricoFullScreenControlBar.nextTagButton                addTarget: self.tableViewController  action:@selector(playNext) forControlEvents:UIControlEventTouchUpInside];
    [self.ricoFullScreenControlBar.previousTagButton            addTarget: self.tableViewController  action:@selector(playPrevious) forControlEvents:UIControlEventTouchUpInside];
    [self.ricoFullScreenControlBar.frameBackward                addTarget: self action:@selector(frameByFrame:)       forControlEvents:UIControlEventTouchUpInside];
    [self.ricoFullScreenControlBar.frameForward                 addTarget: self action:@selector(frameByFrame:)       forControlEvents:UIControlEventTouchUpInside];
    
    self.ricoFullScreenControlBar.mode = RicoFullScreenModeBookmark;
    [self.view addSubview:_videoBar];
    [self.view addSubview:_fullscreenViewController.view];
    
    _videoBar.frame = CGRectMake(0.0, 768 - 44.0, width, 44.0);
    [_videoBar.fullscreenButton addTarget:_fullscreenViewController action:@selector(fullscreenResponseHandler:) forControlEvents:UIControlEventTouchUpInside];

    self.allClips = [NSMutableArray arrayWithArray:[[LocalMediaManager getInstance].clips allValues]];

    

// Telestartion

    
    self.telestrationViewController = [PxpTelestrationViewController new];
    self.telestrationViewController.stillMode    = YES;
    self.telestrationViewController.delegate     = self;
    self.telestrationViewController.view.frame   = self.ricoBookmarkPlayerController.view.frame;
    self.telestrationViewController.timeProvider = self;
    self.telestrationViewController.view.hidden  = YES;
    [self.view addSubview:self.telestrationViewController.view];
}



#pragma mark - playing a clip when selected
// Selected clip to play
-(void)clipSelectedToPlay:(NSNotification*)note
{
    
    self.telestrationViewController.telestration = nil;
    Clip *clipToPlay = note.userInfo[@"clip"];
    self.currentClip = clipToPlay;
//    NSString *source = note.userInfo[@"source"];
    __block BookmarkViewController *weakSelf = self;
    
    self.ricoFullScreenControlBar.currentTagLabel.text = clipToPlay.name;
    
    [clipContentDisplay displayClip:clipToPlay];
    clipContentDisplay.enable = YES;
    clipContentDisplay.ratingAndCommentingView.tagUpdate = ^(NSDictionary *tagData){
        clipToPlay.rating = [[tagData objectForKey:@"rating"] intValue];
        clipToPlay.comment = [tagData objectForKey:@"comment"];
        [weakSelf.tableViewController reloadData];
    };

    [_videoBar setSelectedTag:clipToPlay];
    [_videoBar.tagExtendEndButton setHidden:YES];
    [_videoBar.tagExtendStartButton setHidden:YES];
    self.ricoPlayerControlBar.enabled = YES;
    
    [self.ricoBookmarkPlayerController playClip:clipToPlay];
}

-(void)clipsSelectedToBedeleted:(NSNotification*)note
{
    Clip * deletedClip = note.object;
    
    if (deletedClip == self.currentClip) {
    
        self.telestrationViewController.telestration = nil;
        self.ricoFullScreenControlBar.currentTagLabel.text = @"";
        
        [clipContentDisplay displayClip:nil];
        
        clipContentDisplay.enable = NO;
        clipContentDisplay.ratingAndCommentingView.tagUpdate = nil;
        
        [_videoBar setSelectedTag:nil];
        [_videoBar.tagExtendEndButton setHidden:YES];
        [_videoBar.tagExtendStartButton setHidden:YES];
        self.ricoPlayerControlBar.enabled = NO;
        [self.ricoPlayerControlBar clear];
        [self.ricoBookmarkPlayerController clear];

        self.currentClip = nil;
    }
}



- (void)clipSaved:(NSNotification *)note {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.allClips addObject:note.object];
        self.tableViewController.tableData = _tagsToDisplay;
        [self.tableViewController reloadData];
        [numTagsLabel setText:[NSString stringWithFormat:@"Clip Total: %lu",(unsigned long)[_tagsToDisplay count]]];
    });
}

- (void)clipAutoSaved:(NSNotification *)note {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.allClips = [NSMutableArray arrayWithArray:[[LocalMediaManager getInstance].clips allValues]];
        [_pxpFilter filterTags:self.allClips];
        _tagsToDisplay = [self filterAndSortClips:_tagsToDisplay];
        self.tableViewController.tableData = _tagsToDisplay;
        [self.tableViewController reloadData];
        [numTagsLabel setText:[NSString stringWithFormat:@"Clip Total: %lu",(unsigned long)[_tagsToDisplay count]]];
    });
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_pxpFilter filterTags:self.allClips];
    _tagsToDisplay = [self filterAndSortClips:_tagsToDisplay];
    self.tableViewController.tableData = _tagsToDisplay;
    CGRect tableRect = self.tableViewController.view.frame;
    numTagsLabel.frame = CGRectMake(tableRect.origin.x, CGRectGetMaxY(tableRect), tableRect.size.width, 18);
    [numTagsLabel setText:[NSString stringWithFormat:@"Clip Total: %lu",(unsigned long)[_tagsToDisplay count]]];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    UIEdgeInsets insets = {10, 50, 0, 50};
    [numTagsLabel drawTextInRect:UIEdgeInsetsInsetRect(numTagsLabel.frame, insets)];
      [_pxpFilter filterTags:self.allClips];
   _tagsToDisplay = [self filterAndSortClips:_tagsToDisplay];
    self.tableViewController.tableData = _tagsToDisplay;
    [self.tableViewController.tableView reloadData];

}


-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_CLIP_SELECTED object:nil userInfo:@{}];
    [self.ricoBookmarkPlayerController clear];
    self.fullscreenViewController.fullscreen = NO;
    
    [self.ricoFullScreenControlBar.controlBar clear];
    [self.ricoPlayerControlBar clear];
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
    [self.filterButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    [self.filterButton addTarget:self action:@selector(onPressFilter) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: self.filterButton];
    
    self.userSortButton = [[UIButton alloc] initWithFrame:CGRectMake(800, 710,100, 58)];
    [self.userSortButton setTitle:@"User Sort" forState:UIControlStateNormal];
    [self.userSortButton setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
    [self.userSortButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    [self.userSortButton addTarget:self action:@selector(useCustomSort:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: self.userSortButton];
    
    
    self.progress = [[UILabel alloc]initWithFrame:CGRectMake(550, 710,230, 58)];
    self.tableViewController.progress = self.progress;
    [self.progress setTextColor:[UIColor blackColor]];
    [self.progress setText:@""];
    [self.progress setFont:[UIFont systemFontOfSize:10.0f]];
    [self.progress setHidden:YES];
    [self.view addSubview: self.progress];
}

#pragma mark - Filter Button Pressed

- (void)onPressFilter
{
    if (_pxpFilterTab.isViewLoaded)
    {
        _pxpFilterTab.view.frame =  CGRectMake(0, 0, _pxpFilterTab.preferredContentSize.width,_pxpFilterTab.preferredContentSize.height);
    }
 
    UIPopoverPresentationController *presentationController = [_pxpFilterTab popoverPresentationController];
    presentationController.sourceRect               = [[UIScreen mainScreen] bounds];
    presentationController.sourceView               = self.view;
    presentationController.permittedArrowDirections = 0;
//    [_pxpFilter filterTags:[self.allClips copy]];
    [self presentViewController:_pxpFilterTab animated:YES completion:nil];

}

#pragma mark - Extra VideoControls Pressed

-(void)onSeekButtonPress:(SeekButton *)sender
{
    CMTime  sTime = CMTimeMakeWithSeconds(sender.speed, NSEC_PER_SEC);
    CMTime  cTime = self.ricoPlayerController.primaryPlayer.currentTime;
    
    
    if (sender.speed < 0.2 && sender.speed > -0.2) {
        [self.ricoPlayerController stepByCount:(sender.speed>0)?1:-1];
    } else {
        [self.ricoPlayerController seekToTime:CMTimeAdd(cTime, sTime) toleranceBefore:kCMTimePositiveInfinity toleranceAfter:kCMTimePositiveInfinity completionHandler:nil];
    }
}

- (void)slomoPressed:(Slomo *)slomo {
    slomo.slomoOn = !slomo.slomoOn;
    self.ricoPlayerController.slomo = slomo.slomoOn;
}


-(void)onPlayPause:(id)sender
{

    self.telestrationViewController.telestration = nil;
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
        
        NSSortDescriptor *sorter1 = [NSSortDescriptor
                                     sortDescriptorWithKey:@"displayTime"
                                     ascending:(sortType & ASCEND)?YES:NO
                                     selector:@selector(compare:)];
        NSSortDescriptor *sorter2 =[NSSortDescriptor
                  sortDescriptorWithKey:@"eventName"
                  ascending:(sortType & ASCEND)?YES:NO
                  selector:@selector(caseInsensitiveCompare:)];
        return [NSMutableArray arrayWithArray:[toSort sortedArrayUsingDescriptors:@[sorter2,sorter1]]];
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



#pragma mark - Richard Filtering
-(void)receiveFilteredArrayFromFilter:(id)filter
{
    self.tableViewController.tableData = [self filterAndSortClips:self.allClips];
    [self.tableViewController reloadData];
}

-(void)useCustomSort:(id)sender
{
    if(self.tableViewController.editing == NO)         [self.tableViewController setEditing:YES];
    else
        [self.tableViewController setEditing:NO];
}

-(NSMutableArray *)filterAndSortClips:(NSArray *)clips {
    NSMutableArray *clipsToSort = [NSMutableArray arrayWithArray:clips];
    return [self sortArrayFromHeaderBar:clipsToSort headerBarState:headerBar.headerBarSortType];
}

#pragma mark - PxpFilterDelegate Methods
-(void)onFilterComplete:(PxpFilter*)filter
{
    [_tagsToDisplay removeAllObjects];
    [_tagsToDisplay addObjectsFromArray:filter.filteredTags];
    _tagsToDisplay = [self filterAndSortClips:_tagsToDisplay];
    [_tableViewController reloadData];
    [numTagsLabel setText:[NSString stringWithFormat:@"Clip Total: %lu",(unsigned long)[_tagsToDisplay count]]];
}

-(void)onFilterChange:(PxpFilter *)filter
{
    [filter filterTags:self.allClips];
    [_tagsToDisplay removeAllObjects];
    [_tagsToDisplay addObjectsFromArray:filter.filteredTags];
    _tagsToDisplay = [self filterAndSortClips:_tagsToDisplay];
    self.tableViewController.tableData = _tagsToDisplay;
    [_tableViewController reloadData];
    [numTagsLabel setText:[NSString stringWithFormat:@"Clip Total: %lu",(unsigned long)[_tagsToDisplay count]]];
}

#pragma mark - DeletableTableViewControllerDelegate Methods

-(void)tableView:(DeletableTableViewController *)tableView indexesToBeDeleted:(NSArray *)toBeDeleted
{
    for (NSIndexPath *cellIndexPath in toBeDeleted) {
        Clip * aClip = [_tagsToDisplay objectAtIndex:cellIndexPath.row];
        if (aClip ==_clipContext.clip){ /// if selected and deleted clear UI
            [_clipContext.mainPlayer pause];
            [_clipContext.mainPlayer replaceCurrentItemWithPlayerItem:nil];
            [clipContentDisplay displayClip:nil];
//            [_playerViewController zeroControlBarTimes];
            [_videoBar clear];
        }

        if ([self.allClips containsObject:aClip]) {
            [self.allClips removeObject:aClip];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_DELETE_CLIPS  object:aClip userInfo:nil];
    }

   [numTagsLabel setText:[NSString stringWithFormat:@"Clip Total: %lu",(unsigned long)[self.allClips count]]];
}

#pragma mark - RicoFullScreenDelegate Methods

-(void)onFullScreenLeave:(RicoBaseFullScreenViewController *)fullscreenController
{
    self.ricoPlayerController.playerControlBar          = self.ricoPlayerControlBar;
    self.ricoPlayerControlBar.delegate                  = self.ricoPlayerController;
    self.telestrationViewController.view.hidden         = YES;
    self.videoBar.slomoButton.slomoOn                   = self.ricoPlayerController.slomo;
    
    [self.telestrationViewController.view setFrame:self.ricoBookmarkPlayerController.view.frame];
}

-(void)onFullScreenShow:(RicoBaseFullScreenViewController *)fullscreenController
{
    self.ricoPlayerController.playerControlBar          = self.ricoFullScreenControlBar.controlBar;
    self.ricoFullScreenControlBar.controlBar.delegate   = self.ricoPlayerController;
    self.ricoFullScreenControlBar.slomoButton.slomoOn   = self.videoBar.slomoButton.slomoOn;
    CGRect aRect = self.ricoBookmarkPlayerController.view.frame;
    self.telestrationViewController.view.hidden  = NO;
    CGRect tempRect = CGRectMake(
                                 aRect.origin.x,
                                 aRect.origin.y+130,
                                 aRect.size.width,
                                 aRect.size.height -10
                                 );
    [self.telestrationViewController.view setFrame:tempRect];
}

#pragma mark -
#pragma mark PxpTimeProvider Protocol Methods

- (NSTimeInterval)currentTimeInSeconds
{
    return CMTimeGetSeconds(self.ricoPlayerController.primaryPlayer.currentTime);
}

#pragma mark -
#pragma mark PxpTelestrationViewControllerDelegate Protocol Methods

- (void)telestration:(nonnull PxpTelestration *)telestration didStartInViewController:(nonnull PxpTelestrationViewController *)viewController
{
    
    
    _wasPausedBeforeTele = !self.ricoPlayerController.isPlaying;
    
    [self.ricoPlayerController pause];
    self.ricoFullScreenControlBar.controlBar.playPauseButton.paused = YES;
    self.ricoPlayerControlBar.playPauseButton.paused =YES;
}

- (void)telestration:(nonnull PxpTelestration *)tele didFinishInViewController:(nonnull PxpTelestrationViewController *)viewController
{
    if (!_wasPausedBeforeTele){
        [self.ricoPlayerController play];
        self.ricoFullScreenControlBar.controlBar.playPauseButton.paused = NO;
        self.ricoPlayerControlBar.playPauseButton.paused = NO;
    }
}

#pragma mark -
-(void)onBookmarkPlayerControlerChange:(NSNotification*)note
{
//    RicoBookmarkPlayerController * controller = (RicoBookmarkPlayerController *)note.object;
    
    // if its more then one feed then hide the telestaration
}

-(void)frameByFrame:(id)sender{
    
    if (self.telestrationViewController.telestration) {
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_PLAYER_BAR_CANCEL object:nil];
    }
    
    [self.ricoPlayerController pause];
    self.ricoPlayerController.playerControlBar.playPauseButton.paused = YES;
    float speed = ([((UIButton*)sender).titleLabel.text isEqualToString:@"FB"] )?-0.10:0.10;
    
    self.ricoFullScreenControlBar.controlBar.state = self.ricoPlayerControlBar.state = RicoPlayerStateNormal;
    [self.ricoPlayerController pause];
    [self.ricoPlayerController stepByCount:(speed>0)?1:-1];
}



#pragma mark -
-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

@end

