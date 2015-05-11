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
#import "NSObject+LBCloudConvenience.h"
#import "CustomAlertView.h"
#import "VideoBarMyClipViewController.h"
#import "FullVideoBarMyClipViewController.h"
#import "TagPopOverContent.h"
#import "RJLVideoPlayer.h"
#import "FullScreenViewController.h"
#import "ScreenController.h"
#import "CustomLabel.h"
#import "BookmarkTableViewController.h"
#import "ShareOptionsViewController.h"
#import "SocialSharingManager.h"
#import "TestFilterViewController.h"
#import "Pip.h"
#import "PipViewController.h"
#import "FeedSwitchView.h"
#import "Clip.h"

#define SMALL_MEDIA_PLAYER_HEIGHT   340
#define TOTAL_WIDTH                1024
#define LABEL_HEIGHT                 40
#define TABLE_WIDTH                 390
#define TABLE_WIDTH2                 390
#define COMMENTBOX_HEIGHT           200
#define COMMENTBOX_WIDTH            530//560

@interface BookmarkViewController ()

@property (strong, nonatomic) Clip *currentClip;
@property (strong, nonatomic) UIDocumentInteractionController *shareController;

@property (strong, nonatomic) BookmarkTableViewController *tableViewController;
@property (strong, nonatomic) NSDictionary                *feeds;
@property (strong, nonatomic) UIButton                    * filterButton;

@property (strong, nonatomic) UIButton                    *shareButton;
@property (strong, nonatomic) UIPopoverController         *sharePop;

@property (strong, nonatomic) UIView                      *informationarea;

@property (strong, nonatomic) RatingAndCommentingField    *ratingAndCommentingView;
@property (strong, nonatomic) NSDictionary                *selectedData;


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
    CommentingRatingField               * commentingField;
    CustomLabel                         * numTagsLabel;
    VideoBarMyClipViewController        * newVideoControlBar;
    FullVideoBarMyClipViewController    * newFullScreenVideoControlBar;
    FullScreenViewController            * testFullScreen;
    ScreenController                    * externalControlScreen;
    PipViewController                   * _pipController;
    Pip                                 * _pip;
    FeedSwitchView                      * _feedSwitch;
    TagPopOverContent                   *tagPopoverContent;

}

@synthesize startTime;
//@synthesize allTags;
//@synthesize typesOfTags;
@synthesize selectedTag;
@synthesize popoverController;
@synthesize progressLabel;
@synthesize progressBar;
@synthesize progressBarIndex;
@synthesize allEvents;
//@synthesize tagsToDisplay=_tagsToDisplay;
@synthesize videoPlayer;
@synthesize teleButton;
@synthesize teleViewController;
@synthesize playbackRateBackButton;
@synthesize playbackRateForwardButton;
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
    }
    externalControlScreen = _appDel.screenController;
    return self;
}

//-(void) feedSelected: (NSNotification *) notification
//{
//    
//    NSDictionary *userInfo = [notification.userInfo objectForKey:@"forFeed"];
//    
//    float time              = [[[notification.userInfo objectForKey:@"forFeed"] objectForKey:@"time"] floatValue];
//    float dur               = [[[notification.userInfo objectForKey:@"forFeed"] objectForKey:@"duration"] floatValue];
//    CMTime cmtime           = CMTimeMake(time, 1);
//    CMTime cmDur            = CMTimeMake(dur, 1);
//    
//    CMTimeRange timeRange   = CMTimeRangeMake(cmtime, cmDur);
//    
//    NSString *pick = [userInfo objectForKey:@"feed"];
//    
//    
//    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SET_PLAYER_FEED object:nil userInfo:@{@"context":STRING_MYCLIP_CONTEXT,
//                                                                                                          @"feed":pick,
//                                                                                                          @"time":[userInfo objectForKey:@"time"],
//                                                                                                          @"duration":[userInfo objectForKey:@"duration"],
//                                                                                                          @"state":[NSNumber numberWithInteger:PS_Play]}];
//    
//    self.videoPlayer.looping = YES;
//    [self.videoPlayer playFeed:self.feeds[pick] withRange:timeRange];
//    
//    [_feedSwitch buildButtonsWithData: self.feeds];
//    
//    selectedTag = [self.allClips[[self.allClips indexOfObjectIdenticalTo:notification.userInfo[@"forWhole"]]] mutableCopy];
//    [self.videoPlayer play];
//    
//    [commentingField clear];
//    commentingField.enabled             = YES;
//    commentingField.text                = [selectedTag objectForKey:@"comment"];
//    commentingField.ratingScale.rating  = [[selectedTag objectForKey:@"rating"]integerValue];
//    
//    [newVideoControlBar setTagName:[selectedTag objectForKey:@"name"]];
//}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(feedSelected:) name:NOTIF_SET_PLAYER_FEED_IN_MYCLIP object:nil];
//    [[NSNotificationCenter defaultCenter] addObserverForName:@"tagSelected" object:nil queue:nil usingBlock:^(NSNotification *note) {
//        for (TagPopOverContent *info in self.informationarea.subviews) {
//            [info removeFromSuperview];
//        }
//        [self.ratingAndCommentingView removeFromSuperview];
//        
//        self.selectedData = note.userInfo;
//        self.ratingAndCommentingView = [[RatingAndCommentingField alloc] initWithFrame:CGRectMake(0, 100, COMMENTBOX_WIDTH, (COMMENTBOX_HEIGHT+20)) andData:[note.userInfo mutableCopy]].view;
//        [self.informationarea addSubview:[[TagPopOverContent alloc] initWithData:note.userInfo frame:CGRectMake(0, 0, COMMENTBOX_WIDTH, (COMMENTBOX_HEIGHT+20))]];
//        [self.informationarea addSubview:self.ratingAndCommentingView];
//    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"NOTIF_CLIP_SELECTED" object:nil queue:nil usingBlock:^(NSNotification *note) {
        
        Clip *clipToPlay = note.object;
        [tagPopoverContent removeFromSuperview];
        tagPopoverContent = nil;
        tagPopoverContent = [[TagPopOverContent alloc] initWithData: clipToPlay.rawData frame:CGRectMake(0, 0, COMMENTBOX_WIDTH, (COMMENTBOX_HEIGHT+20))];
        
        [self.ratingAndCommentingView.view removeFromSuperview];
        self.ratingAndCommentingView = nil;
        self.ratingAndCommentingView = [[RatingAndCommentingField alloc] initWithFrame:CGRectMake(0, 100, COMMENTBOX_WIDTH, (COMMENTBOX_HEIGHT+20)) andData: [clipToPlay.rawData mutableCopy]];
        
        __block BookmarkViewController *weakSelf = self;
        self.ratingAndCommentingView.tagUpdate = ^(NSDictionary *tagData){
            clipToPlay.rating = [[tagData objectForKey:@"rating"] intValue];
            clipToPlay.comment = [tagData objectForKey:@"comment"];
            [weakSelf.tableViewController reloadData];
        };
        
        [self.informationarea addSubview: tagPopoverContent];
        [self.informationarea addSubview: self.ratingAndCommentingView.view];
        
        [self.videoPlayer playFeed: [[clipToPlay.feeds allValues] firstObject]];
        
        // Setup shareController
        
        // take first feed
        
        Feed *feed = clipToPlay.feeds[@"source0"];
        
        self.shareController = [UIDocumentInteractionController interactionControllerWithURL:feed.path];
        self.shareController.name = clipToPlay.name;
        self.shareButton.hidden = NO;
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"removeInformation" object:nil queue:nil usingBlock:^(NSNotification *note){
        for (TagPopOverContent *info in self.informationarea.subviews) {
            [info removeFromSuperview];
        }
        [self.ratingAndCommentingView.view removeFromSuperview];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"NOTIF_DELETE_CLIPS" object:nil queue:nil usingBlock:^(NSNotification *note){
        [self.allClips removeObjectIdenticalTo:note.userInfo];
        componentFilter.rawTagArray = self.allClips;
        //[componentFilter refresh];
    }];
//    
//    //facebook = [[Facebook alloc] initWithAppId:@"144069185765148"];
//    
//    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//    if (!appDelegate.session.isOpen) {
//        // create a fresh session object
//        appDelegate.session = [[FBSession alloc] init];
//        // if we don't have a cached token, a call to open here would cause UX for login to
//        // occur; we don't want that to happen unless the user clicks the login button, and so
//        // we check here to make sure we have a token before calling open
//        if (appDelegate.session.state == FBSessionStateCreatedTokenLoaded) {
//            // even though we had a cached token, we need to login to make the session usable
//            [appDelegate.session openWithCompletionHandler:^(FBSession *session,
//                                                             FBSessionState status,
//                                                             NSError *error) {
//                //// we recurse here, in order to update buttons and labels
//                //[self updateView];
//            }];
//        }
//    }
    
    self.videoPlayer = [[RJLVideoPlayer alloc]initWithFrame:CGRectMake(1, 768 - SMALL_MEDIA_PLAYER_HEIGHT , COMMENTBOX_WIDTH, SMALL_MEDIA_PLAYER_HEIGHT)];
    self.videoPlayer.playerContext = STRING_MYCLIP_CONTEXT;
    
    //allTags = [[NSMutableArray alloc]init];
    
    _pip            = [[Pip alloc]initWithFrame:CGRectMake(50, 50, 200, 150)];
    _pip.isDragAble  = YES;
    _pip.hidden      = YES;
    _pip.muted       = YES;
    _pip.dragBounds  = self.videoPlayer.view.frame;
    [self.videoPlayer.view addSubview:_pip];
    
    _feedSwitch     = [[FeedSwitchView alloc]initWithFrame:CGRectMake(1, 768 - SMALL_MEDIA_PLAYER_HEIGHT - 73, COMMENTBOX_WIDTH, 40)];
//    
    _pipController  = [[PipViewController alloc]initWithVideoPlayer:self.videoPlayer f:_feedSwitch];
    _pipController.context = STRING_MYCLIP_CONTEXT;
    [_pipController addPip:_pip];
    [_pipController viewDidLoad];
    
    [self.view addSubview:_feedSwitch];
    //[_feedSwitch setHidden:!([_encoderManager.feeds count]>1)];
    
    //array of file paths
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];
    
    
    //Find path to accountInformation plist
    //    NSString *accountInformationPath = [documentsDirectory stringByAppendingPathComponent:@"accountInformation.plist"];
    //    NSMutableDictionary *accountInfo = [[NSMutableDictionary alloc] initWithContentsOfFile: accountInformationPath];
    //    userIdd = [accountInfo objectForKey:@"hid"];
    
    
    [self setupView];
    
    
    //typesOfTags = [[NSMutableArray alloc]init];
    //tagsDidViewed = [[NSMutableArray alloc]init];
    
    fullScreenMode = FALSE;
    //progressLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.tableView.frame.origin.x + 12,self.tableView.frame.size.height + 110,200 ,25)];
    [progressLabel setText:NSLocalizedString(@"Processing",nil)];
    [progressLabel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:progressLabel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkFullScreen) name:@"Entering FullScreen" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkFullScreen) name:@"Exiting FullScreen" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showDropboxUpload) name:@"Show DB Upload" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopDropboxUpload) name:@"Stop DB Upload" object:nil];
    
    
    progressBar = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
    //[progressBar setFrame:CGRectMake(self.tableView.frame.origin.x + 12,self.tableView.frame.size.height + 155,200 ,25)];
    [self.view addSubview:progressBar];
    
    
    //uploadFileResponseLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.tableView.frame.origin.x + 12,self.tableView.frame.size.height + 180,120 , 25)];
    //    [uploadFileResponseLabel setText:@"sharing:"];
    //    [uploadFileResponseLabel setBackgroundColor:[UIColor clearColor]];
    //    [uploadFileResponseLabel setHidden:TRUE];
    //    [self.view addSubview:uploadFileResponseLabel];
    //
    //    uploadFileResponse = [[UITextView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(uploadFileResponseLabel.frame)+10, uploadFileResponseLabel.frame.origin.y-5, TABLE_WIDTH+200, 30)];
    //    [uploadFileResponse setFont:[UIFont systemFontOfSize:15.0f]];
    //    [uploadFileResponse setBackgroundColor:[UIColor clearColor]];
    //    [uploadFileResponse setUserInteractionEnabled:FALSE];
    //    [uploadFileResponse setHidden:TRUE];
    //    [self.view addSubview:uploadFileResponse];
    
    
    
    // This is for the tag count
    numTagsLabel = [[CustomLabel alloc] init];
    [numTagsLabel setMargin:CGRectMake(0, 5, 0, 5)];
    [numTagsLabel setTextAlignment:NSTextAlignmentRight];
    [numTagsLabel setText:NSLocalizedString(@"Tags",nil)];
    [numTagsLabel setTextColor:[UIColor whiteColor]];
    [numTagsLabel setBackgroundColor:[UIColor lightGrayColor]];
    [numTagsLabel setFont:[UIFont systemFontOfSize:14.0f]];
    
    [self.view addSubview:numTagsLabel];
    
    newVideoControlBar = [[VideoBarMyClipViewController alloc]initWithVideoPlayer:videoPlayer];
    [self.view addSubview:newVideoControlBar.view];
    
    
    testFullScreen = [[FullScreenViewController alloc]initWithVideoPlayer:self.videoPlayer];
    //    [self.view addSubview:testFullScreen.view];
}


-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
//    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_LIST_VIEW_CONTROLLER_FEED object:nil userInfo:@{@"block" : ^(NSDictionary *feeds, NSArray *eventTags){
//        if(feeds){
//            self.feeds = feeds;
//            //            Feed *theFeed = [[feeds allValues] firstObject];
//            //            [self.videoPlayer playFeed:theFeed];
//        }
//        
//        if(eventTags){
//            if (self.allClips.count == 0) {
//                self.allClips = [NSMutableArray arrayWithArray:[eventTags copy]];
//                _tableViewController.tableData = self.allClips;
//                [_tableViewController.tableView reloadData];
//            }
//        }
//    }}];
    if (self.allClips.count == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REQUEST_CLIPS object:^(NSArray *clips){
            self.allClips = [NSMutableArray arrayWithArray: clips];
            _tableViewController.tableData = self.allClips;
            [_tableViewController.tableView reloadData];
        }];
    }
    
    
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
        
    }else{
        //when just enter bookmark view, no video is selected,leave the player screen black
        //        NSURL *videoURL = [NSURL URLWithString:@""];
        //        [self.videoPlayer setVideoURL:videoURL];
        //        [self.videoPlayer setPlayerWithURL:videoURL];
    }
    
    
    //get all data for bookmark
    [self fetchedData];
    //number of cells which have been viewed
    cellSelectedNumber = 0;
    //if no cell has been viewed (or selected),disable the comment and rating box
    
    commentingField.enabled = NO;
    commentingField.ratingScale.rating = 0;
    [commentingField clear];
    
    fullScreenMode = FALSE;
    //firstTimeStartMoviePlayer = TRUE;
    //set the right play back rate in the case: pause viedo,then switch between full screen and normal screen, then resume to play with proper play back rate
    //    [updatePlayRateTimer invalidate];
    //    updatePlayRateTimer = nil;
    //    updatePlayRateTimer=[NSTimer scheduledTimerWithTimeInterval:1.0
    //                                                         target:self
    //                                                       selector:@selector(updatePlayRate:)
    //                                                       userInfo:nil
    //                                                        repeats:YES];
    
    
    //when new bookmark tag is created, reload the table view
    //    [updateTableViewTimer invalidate];
    //    updateTableViewTimer = nil;
    //    updateTableViewTimer=[NSTimer scheduledTimerWithTimeInterval:1.0
    //                                                          target:self
    //                                                        selector:@selector(updateTableView:)
    //                                                        userInfo:nil
    //                                                         repeats:YES];
    
    
    //if all the new bookmark tags are received from the server or no new bookmark tag is processed, hide the progress bar;Otherwise display the progress bar to indicate the process of loading new bookmark tags
    //    if (globals.DID_FINISH_RECEIVE_BOOKMARK_VIDEO || globals.NUMBER_OF_BOOKMARK_TAG_TO_PROCESS <1) {
    //        [progressLabel setHidden:TRUE];
    //        [progressBar setHidden:TRUE];
    //    }else{
    //        [progressLabel setHidden:FALSE];
    //        [progressBar setHidden:FALSE];
    //    }
    
    [self.videoPlayer pause];
    
    //[self.tableView reloadData];
    
    [newVideoControlBar viewDidAppear:NO];
    
    
    
}




-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    //[numTagsLabel setFrame:CGRectMake(self.tableView.frame.origin.x,
    //                                      CGRectGetMaxY(self.tableView.frame),
    //                                      self.tableView.frame.size.width,
    //                                      21.0f)];
    UIEdgeInsets insets = {10, 50, 0, 50};
    [numTagsLabel drawTextInRect:UIEdgeInsetsInsetRect(numTagsLabel.frame, insets)];
    
    // This was just a test
    //    //playing tag from book mark video folder
    //    NSString *tagVideoPath = @"http://192.168.3.100/pub/test/list.m3u8";
    //    //when play back from ios device storage set "nsurl" by using "fileurlwithpath" instead of "urlwithstring"
    //    NSURL *videoURL = [NSURL URLWithString:[tagVideoPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    //
    //    [self.videoPlayer setVideoURL:videoURL];
    //
    //    [self.videoPlayer setPlayerWithURL:videoURL];
    //
    //    [self.videoPlayer play];
    
    //      [testFullScreen viewDidAppear:NO];
}


//initialize comment box and if one tag is selected, the tag details will show in the box too
-(void)setupView{
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    headerBar = [[HeaderBar alloc]initWithFrame:CGRectMake(0,55,TOTAL_WIDTH, LABEL_HEIGHT)];
    [headerBar onTapPerformSelector:@selector(sortFromHeaderBar:) addTarget:self];
    [self.view addSubview:headerBar];
    
    
    
    commentingField = [[CommentingRatingField alloc]initWithFrame:CGRectMake(1,74, COMMENTBOX_WIDTH, COMMENTBOX_HEIGHT+60) title:NSLocalizedString(@"Comment",nil)];
    commentingField.enabled = NO;
    [commentingField onPressRatePerformSelector:@selector(sendRatingNew:) addTarget:self ];
    [commentingField onPressSavePerformSelector:@selector(sendComment2) addTarget:self];
    [commentingField.fieldTitle setHidden:YES];
    
    self.informationarea = [[UIView alloc] initWithFrame:CGRectMake(1,94, COMMENTBOX_WIDTH, COMMENTBOX_HEIGHT+60)];
    self.informationarea.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.informationarea.layer.borderWidth = 1.0f;
    [self.view addSubview:self.informationarea];
    
    
    //[self.view addSubview:commentingField];
    
    
    self.tableViewController = [[BookmarkTableViewController alloc] init];
    self.tableViewController.contextString = @"CLIP";
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        [self.tableViewController.view setFrame:CGRectMake(CGRectGetMaxX(commentingField.frame) + 5.0f, CGRectGetMaxY(headerBar.frame), self.view.bounds.size.width - CGRectGetMaxX(commentingField.frame) - 30.0f, self.view.bounds.size.height - CGRectGetMaxY(headerBar.frame) - 50.0f)];
    } else {
        [self.tableViewController.view setFrame:CGRectMake(CGRectGetMaxX(commentingField.frame) + 5.0f, CGRectGetMaxY(headerBar.frame), self.view.bounds.size.height - CGRectGetMaxX(commentingField.frame) - 30.0f, self.view.bounds.size.width - CGRectGetMaxY(headerBar.frame) - 50.0f)];
    }
    self.tableViewController.view.autoresizingMask = UIViewAutoresizingNone;
    [self addChildViewController: self.tableViewController];
    [self.view addSubview: self.tableViewController.view];
    
    
    self.tableActionButton = [BorderButton buttonWithType:UIButtonTypeCustom];
    //    [self.tableActionButton setFrame:CGRectMake(kiPadWidthLandscape - 100, 60, 80, 30)];
    self.tableActionButton.titleLabel.font = [UIFont defaultFontOfSize:18];
    [self.tableActionButton setTitle:@"" forState:UIControlStateNormal];
    [self.tableActionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.tableActionButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.tableActionButton setBackgroundImage:[UIImage imageNamed:@"tab-bar.png"] forState:UIControlStateHighlighted];
    [self.tableActionButton setHidden:YES];
    [self.tableActionButton addTarget:self action:@selector(actionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview: self.tableActionButton];
    
    self.filterButton = [[UIButton alloc] initWithFrame:CGRectMake(950, 710, 74, 58)];
    [self.filterButton setTitle:NSLocalizedString(@"Filter",nil) forState:UIControlStateNormal];
    [self.filterButton setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
    [self.filterButton addTarget:self action:@selector(slideFilterBox) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: self.filterButton];
    
    self.shareButton = [[UIButton alloc] initWithFrame:CGRectMake(850, 710, 74, 58)];
    [self.shareButton setTitle:@"Share" forState:UIControlStateNormal];
    [self.shareButton setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
    [self.shareButton addTarget:self action:@selector(popShareOptions:) forControlEvents:UIControlEventTouchUpInside];
    self.shareButton.hidden = YES;
    [self.view addSubview:self.shareButton];
    
    /////////////////////////////////////////////////////////////////
}

- (void)popShareOptions:(id)sender {
    /*
    //ShareOptionsViewController *shareOptions = [[ShareOptionsViewController alloc] initWithArray:[[SocialSharingManager CommonManager] arrayOfSharingOptions]];
    ShareOptionsViewController *shareOptions = [[ShareOptionsViewController alloc] initWithArray: [[SocialSharingManager commonManager] arrayOfSocialOptions] andIcons:[[SocialSharingManager commonManager] arrayOfIcons] andSelectedIcons: [[SocialSharingManager commonManager] arrayOfSelectedIcons]];
    self.sharePop = [[UIPopoverController alloc] initWithContentViewController:shareOptions];
    self.sharePop.popoverContentSize = CGSizeMake(280, 180);
    [self.sharePop presentPopoverFromRect:self.shareButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
     */
    [self.shareController presentOptionsMenuFromRect:CGRectZero inView:self.shareButton animated:YES];
}


//get all the bookmark tags from the global bookmark dictionary
- (void)fetchedData
{
    //    for(int i=0;i<4;i++)
    //    {
    //        NSMutableArray *sectionArray = [[NSMutableArray alloc]init];
    //        [typesOfTags addObject:sectionArray];
    //    }
    //
    //    //NSMutableArray *allBookmarkTags; // contains the bookmarks that will be displayed after iterating through the global bookmarks
    //
    //
    //    hasBeenOrdered=FALSE;
    //
    //    //url for the plist where the ordered array of bookmarks will be stored -- ordered by user
    //    NSString *orderedBookmarkPlist=[globals.BOOKMARK_PATH stringByAppendingPathComponent:@"orderedBookmarks.plist"];
    //    int orderedTagCount = [[NSArray arrayWithContentsOfFile:orderedBookmarkPlist] count];
    //
    //    if(!fileManager)
    //    {
    //        fileManager = [NSFileManager defaultManager]; //make sure we have a filemanager
    //    }
    //
    //    //now grab the bookmark tags from the global dictionary, we need to iterate through and add all of them to an array so we can get the total number of bookmarks in the end
    //    NSMutableArray *allBMTags = [[NSMutableArray alloc] init]; //temporary array to add the thumb items to
    //    for(NSDictionary *d in [globals.BOOKMARK_TAGS allValues])
    //    {
    //        [allBMTags addObjectsFromArray:[d allValues]];
    //    }
    //    //if there is no downloaded tags or the total bookmark tags'count and ordered bookmark tags' count are not equal, and the ordered bookmark plist file exists, we need to delete this file
    //    if((allBMTags.count == 0 || allBMTags.count != orderedTagCount )&& [fileManager fileExistsAtPath:orderedBookmarkPlist]){
    //        [fileManager removeItemAtPath:orderedBookmarkPlist error:nil];
    //    }
    //    //if ordered bookmark plist file not exist or the total number of bookmark tags are greater than the number of ordered bookmark tags, we need to
    //    //use the array of all bookmark tags for this view to display
    //    if(![fileManager fileExistsAtPath:orderedBookmarkPlist])
    //    {
    //        allTags = allBMTags;
    //
    //    }else{
    //        //if the user has ordered and they aren't filtering then grab the ordered list from the plist
    //        hasBeenOrdered=TRUE;
    //        allTags =[[NSMutableArray alloc] initWithContentsOfFile:orderedBookmarkPlist];
    //    }
    //
    //
    //    //allTags = [allBookmarkTags mutableCopy];
    //
    //    //after adding all of the old bookmarks and the new bookmarks to the array we need to make sure we write the new array of bookmarks in whichever order they are in to the plist
    //    [allTags writeToFile:orderedBookmarkPlist atomically:TRUE];
    //
    //    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    //    for(NSDictionary *tag in allTags){
    //        if ([tag isKindOfClass:[NSDictionary class]]) {
    //            if ([tag objectForKey:@"colour"] != nil && [[tag objectForKey:@"type"]integerValue]!=3) {
    //                //type == 2, line tag,type == 0 normal tag, type == 10, strength tag;if the tag was deleted, type value will be 3 and "deleted" value will be 1
    //                if([[tag objectForKey:@"type"] intValue]==0||[[tag objectForKey:@"type"] intValue]==100)
    //                {
    //                    [tempArray addObject:tag];
    //                    if(![[typesOfTags objectAtIndex:0] containsObject:[tag  objectForKey:@"name"]])
    //                    {
    //                        [[typesOfTags objectAtIndex:0] addObject:[tag  objectForKey:@"name"]];
    //                    }
    //
    //                }else if([[tag objectForKey:@"type"] intValue]==10){
    //                    [tempArray addObject:tag];
    //                    if(![[typesOfTags objectAtIndex:2] containsObject:[tag  objectForKey:@"name"]])
    //                    {
    //                        [[typesOfTags objectAtIndex:2] addObject:[tag  objectForKey:@"name"]];
    //                    }
    //
    //                }else{
    //                    [tempArray addObject:tag];
    //                    if(![[typesOfTags objectAtIndex:1] containsObject:[tag  objectForKey:@"name"]])
    //                    {
    //                        [[typesOfTags objectAtIndex:1] addObject:[tag  objectForKey:@"name"]];
    //                    }
    //                }
    //
    //            }
    //        }
    //    }
    //
    //    self.tagsToDisplay=[tempArray mutableCopy];
    //
    //    if (self.tagsToDisplay.count > 0) {
    //
    //        [self.tableView reloadData];
    //    }
    //
    //
    //    if ([globals.TAGGED_ATTS_BOOKMARK count] >0){
    //        if(![self.view.subviews containsObject:_filterToolBoxView.view])
    //        {
    //            [_filterToolBoxView.view setAlpha:0.95f];
    //            [self.view addSubview:_filterToolBoxView.view];
    //
    //        }
    //        //  [self.view insertSubview:filterToolBoxListViewController.view atIndex:self.view.subviews.count-1];
    ////        [_filterToolBoxView viewDidAppear:TRUE];
    //    }
    //
}


//return the tag dictionary of each cell
- (NSMutableDictionary*)tagAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.allClips objectAtIndex:indexPath.row];
}

#pragma mark - Triple Swipe Table Methods

- (void)actionButtonPressed: (UIButton*)button
{
    //    if(self.tableView.selectionType == JPTripleSwipeCellSelectionLeft)
    //    {
    //        [self shareTagsReorderTable:button];
    //    }
    //    else if(self.tableView.selectionType == JPTripleSwipeCellSelectionRight)
    //    {
    //        [self deleteCells];
    //    }
}

//after viewing a tag, save it into the tagsDidViewed.plist file
-(void)saveTagsDidViewed:(id)tag
{
    //    NSString *tagsDidViewedPath = [globals.THUMBNAILS_PATH stringByAppendingPathComponent:@"tagsDidViewed.plist"];
    //    fileManager = [NSFileManager defaultManager];
    //    if (![fileManager fileExistsAtPath: tagsDidViewedPath])
    //    {
    //        tagsDidViewedPath = [globals.THUMBNAILS_PATH stringByAppendingPathComponent: [NSString stringWithFormat: @"tagsDidViewed.plist"] ];
    //    }
    //    [tag writeToFile:tagsDidViewedPath atomically:YES];
}

#pragma mark - Swipe Buttons Methods
- (void)slideFilterBox
{
    
    if(!blurView)
    {
        blurView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,0.0f,self.view.frame.size.width,self.view.frame.size.height)];
        blurView.backgroundColor = [UIColor colorWithRed:0.f
                                                   green:0.f
                                                    blue:0.f
                                                   alpha:0.7f];
        UITapGestureRecognizer* tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissFilterToolbox)];
        [blurView addGestureRecognizer:tapRec];
        
        blurView.hidden = YES;
        componentFilter = [[TestFilterViewController alloc]initWithTagArray: self.allClips];
    }
    [self.view insertSubview:blurView aboveSubview:newVideoControlBar.view];
    [self.view insertSubview:_filterToolBoxView.view aboveSubview:blurView];
    
    blurView.hidden = NO;
    [_filterToolBoxView open:YES]; // Slide filter open
    
    componentFilter.rawTagArray = self.allClips;
    componentFilter.rangeSlider.highestValue = [((UIViewController <PxpVideoPlayerProtocol> *)self.videoPlayer) durationInSeconds];
    
    [componentFilter onSelectPerformSelector:@selector(receiveFilteredArrayFromFilter:) addTarget:self];
    //[componentFilter onSwipePerformSelector:@selector(slideFilterBox) addTarget:self];
    componentFilter.finishedSwipe = TRUE;
    
    [self.view addSubview:componentFilter.view];
    componentFilter.rangeSlider.highestValue = [((UIViewController <PxpVideoPlayerProtocol> *)self.videoPlayer) durationInSeconds];
    [componentFilter setOrigin:CGPointMake(60, 190)];
    [componentFilter close:NO];
    [componentFilter viewDidAppear:TRUE];
    
    
    [componentFilter open:YES];
    
}

- (void)dismissFilterToolbox
{
    [_filterToolBoxView close:YES]; // Slide filter close
    blurView.hidden = YES;
    //blurView = nil;
   
    [componentFilter close:YES];
    
}



#pragma mark Richard Methods for commenting and rating
-(void)sendRatingNew:(id)sender
{
    int recievedRating = [(RatingInput *)sender rating];
    [selectedTag    setValue:   [NSString stringWithFormat:@"%i",recievedRating]   forKey:@"rating"];
    
    
    //handle offline mode, save comment information in local storage
    //    BOOL addToCurrentEventThumbnails = FALSE;
    
    
}

-(void)sendComment2
{
    [commentingField.textField resignFirstResponder];
    NSString *comment = commentingField.textField.text;
    [selectedTag setValue:comment forKey:@"comment"];
}

-(void)tagModCallback:(id)newTagInfo
{
    //the updated tag
    //    NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithDictionary:newTagInfo];
    
    //update it in the dictionary
    //note: cannot use newtaginfo objectforkey"id" directly - the value is either integer or string (id) and needs to be converted to nsstring
    
    //    if ([[dict objectForKey:@"bookmark"]integerValue]==1 && [[dict objectForKey:@"type"]integerValue] != 3) {
    //        [[globals.BOOKMARK_TAGS objectForKey:[newTagInfo objectForKey:@"event"]] setObject:dict forKey:[NSString stringWithFormat:@"%@",[newTagInfo objectForKey:@"id"]]];
    //    }
    //    //save it to file
    //    // [globals.CURRENT_EVENT_THUMBNAILS writeToFile:[[globals.EVENTS_PATH stringByAppendingPathComponent:globals.EVENT_NAME] stringByAppendingPathComponent:@"Thumbnails.plist"] atomically:YES];
    //    [globals.BOOKMARK_TAGS writeToFile:globals.BOOKMARK_TAGS_PATH atomically:YES];
    //
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
    HeaderBar * hBar = (HeaderBar *)sender;
    
    self.allClips = [self sortArrayFromHeaderBar:self.allClips headerBarState:hBar.headerBarSortType];
    self.tableViewController.tableData = self.allClips;
    [self.tableViewController.tableView reloadData];
    //[self.tableView reloadData];
    
    
    
}

-(NSMutableArray*)sortArrayFromHeaderBar:(NSMutableArray*)toSort headerBarState:(HBSortType) sortType
{
    
    NSSortDescriptor *sorter;
    //Fields are from HeaderBar.h
    if(sortType & TIME_FIELD){
        sorter = [NSSortDescriptor
                  sortDescriptorWithKey:@"displaytime"
                  ascending:(sortType & ASCEND)?YES:NO
                  selector:@selector(compare:)];
        
    } else if (sortType & DATE_FIELD) {
        sorter = [NSSortDescriptor
                  sortDescriptorWithKey:@"event"
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
    
    
    [blurView removeFromSuperview];
    //blurView=nil;
    [self dismissFilterToolbox];
   
 
    currentPlayingTag = nil;
    
    

    
}



-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    //make sure the movieplayer is stoped before going to otherviews, otherwise the app will crash
    [self.videoPlayer pause];
    
    //[allTags removeAllObjects];
    //    globals.IS_IN_BOOKMARK_VIEW = FALSE;
    
}


-(void)willExitFullscreen
{
    [self removeAllFullScreenSubviews];
}

-(void)didExitFullscreen
{
    [self.view bringSubviewToFront: blurView];
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
    //    globals.PLAYBACK_SPEED = 0.0;
    //    [videoPlayer.avPlayer setRate:globals.PLAYBACK_SPEED];
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
        [self showTeleButton];
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
    NSInteger * buttonTagValue  = ((UIButton*)sender).tag;
    int         nextIndex       = wasPlayingIndexPath.row + (int)buttonTagValue;
    if(nextIndex > self.allClips.count -1 || nextIndex <0){
        return;
    }
    
//    NSIndexPath *nextPath = [NSIndexPath indexPathForRow:nextIndex inSection:wasPlayingIndexPath.section];
    //[self reorderTableView:self.tableView didSelectRowAtIndexPath:nextPath];
}

-(void)showTeleButton
{
    if (teleButton) {
        [teleButton removeFromSuperview];
        teleButton = nil;
    }
    teleButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    [teleButton setFrame:CGRectMake(939.0f, 585.0f, 64.0f, 64.0f)];
    [teleButton setContentMode:UIViewContentModeScaleAspectFill];
    [teleButton setImage:[UIImage imageNamed:@"teleButton"] forState:UIControlStateNormal];
    [teleButton setImage:[UIImage imageNamed:@"teleButtonSelect"] forState:UIControlStateHighlighted];
    //teleButton.transform=CGAffineTransformMakeRotation(M_PI/2);
    [teleButton addTarget:self action:@selector(initTele:) forControlEvents:UIControlEventTouchUpInside];
    //need to be modified later
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:teleButton];
}



-(void)removeAllFullScreenSubviews
{
    
    [teleButton removeFromSuperview];
    [playbackRateBackButton removeFromSuperview];
    [playbackRateBackLabel removeFromSuperview];
    [playbackRateBackGuide removeFromSuperview];
    [playbackRateForwardButton removeFromSuperview];
    [playbackRateForwardLabel removeFromSuperview];
    [playbackRateForwardGuide removeFromSuperview];
    // Richard
    [newFullScreenVideoControlBar.view removeFromSuperview];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    //    UITouch *touch = [[event allTouches] anyObject];
    //    if ([commentTextView isFirstResponder] && [touch view] != commentTextView) {
    //        [commentTextView resignFirstResponder];
    //    }
    [super touchesBegan:touches withEvent:event];
}

-(void)updatePlayRate:(NSTimer*)timer
{
    //if(self.moviePlayer.playbackState != MPMoviePlaybackStatePaused)
    
    
}


#pragma mark - Richard Filtering
-(void)receiveFilteredArrayFromFilter:(id)filter
{
    AbstractFilterViewController * checkFilter = (AbstractFilterViewController *)filter;
    NSMutableArray *filteredArray = (NSMutableArray *)[checkFilter processedList]; //checkFilter.displayArray;
    //self.tableData = [filteredArray mutableCopy];
    
    _tableViewController.tableData = [filteredArray mutableCopy];
    [self.tableViewController reloadData];
    //[breadCrumbVC inputList: [checkFilter.tabManager invokedComponentNames]];
    
    //    MyClipFilterViewController * checkFilter = (MyClipFilterViewController *)filter;
    //
    //    NSMutableArray *filteredArray = (NSMutableArray *)[checkFilter processedList]; //checkFilter.displayArray;
    //    NSMutableArray *tempArr;
    //
    //
    //    ///we have to check to see if the list has been reordered
    //
    //    //check to make sure filemanager exists
    //    if(!fileManager)
    //    {
    //        fileManager = [NSFileManager defaultManager];
    //    }
    //
    //    //create teh path to the reordered bookmarks plist
    //    NSString *orderedBookmarkPlist=[globals.BOOKMARK_PATH stringByAppendingPathComponent:@"orderedBookmarks.plist"];
    //
    //    //now grab the bookmark tags from the global dictionary, we need to iterate through and add all of them to an array so we can get the total number of bookmarks in the end
    //    NSMutableArray *a = [[NSMutableArray alloc] init]; //temporary array to add the thumb items to
    //    for(NSDictionary *d in [globals.BOOKMARK_TAGS allValues])
    //    {
    //        [a addObjectsFromArray:[d allValues]];
    //    }
    //
    //    int orderedTagCount = [[NSArray arrayWithContentsOfFile:orderedBookmarkPlist] count];
    //    //if the user is filtering or or there is no ordered bookmarks then just display the filtered array. If however there is an ordered list and the user is not filtering, then use the
    //    //ordered list
    //    if(filteredArray.count < a.count || ![fileManager fileExistsAtPath:orderedBookmarkPlist] || a.count > orderedTagCount)
    //    {
    //        tempArr = [filteredArray mutableCopy];
    //    }else{
    //        //if all bookmark tags count is smaller than the odered bookmark tags, replace the ordered bookmark tags
    //        if (a.count < orderedTagCount && [fileManager fileExistsAtPath:orderedBookmarkPlist]) {
    //            [a writeToFile:orderedBookmarkPlist atomically:YES];
    //            tempArr = a;
    //        }else{
    //            tempArr =[[NSMutableArray alloc] initWithContentsOfFile:orderedBookmarkPlist];
    //        }
    //
    //
    //    }
    //
    //    // Added the ability to sor the array from headerbar
    //    self.tagsToDisplay = [self sortArrayFromHeaderBar:[tempArr mutableCopy] headerBarState:headerBar.headerBarSortType];
    //
    //    [self.tableView reloadData];
    //
    
}




#pragma mark - Popover

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    //[self.tableView selectAllCellsWithSelectionType:JPTripleSwipeCellSelectionNone];
}




- (NSString*)cloudFileNameWithTag: (NSDictionary*)tag
{
    NSString* type = @"mp4";
    
    NSString* eventName = [NSString stringWithFormat:@"[%@ vs %@](%@)", [tag objectForKey:@"homeTeam"], [tag objectForKey:@"visitTeam"], [[tag objectForKey:@"event"] substringToIndex:10]];
    NSString* fileName = [NSString stringWithFormat:@"My Clip Video: %@.%@", eventName, type];
    return fileName;
}

//// Check these methods, they should be implimented as per protocal, but are not used
//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return nil;
//}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}


@end

