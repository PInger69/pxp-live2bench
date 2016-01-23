//
//  RicoDualViewTabViewController.m
//  Live2BenchNative
//
//  Created by dev on 2016-01-15.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "RicoDualViewTabViewController.h"

#import "DualViewPeriodTableViewController.h"
#import "NCRecordButton.h"
#import "UserCenter.h"
#import "EncoderProtocol.h"
#import "EncoderManager.h"
#import "RJLVideoPlayer.h"
#import "PipViewController.h"
#import "FeedSelectionController.h"
#import "LiveButton.h"
#import "SeekButton.h"

#import "NCPlayerView.h"

#import "RicoPlayer.h"
#import "RicoPlayerControlBar.h"
#import "RicoPlayerViewController.h"
#import "RicoZoomContainer.h"

#import "DebugOutput.h"

#define BOTTOM_BAR_HEIGHT 70
#define PLAYHEAD_HEIGHT 44
#define PINCH_VELOCITY 1
#define ANIMATION_DURATION 0.25




@interface RicoDualViewTabViewController () <NCRecordButtonDelegate, FeedSelectionControllerDelegate, DualViewTagControllerDelegate>{
    Event                           * _currentEvent;
    id <EncoderProtocol>                _observedEncoder;
}



@property (nonatomic,strong) RicoPlayer                 * topPlayer;
@property (nonatomic,strong) RicoPlayer                 * bottomPlayer;
@property (nonatomic,strong) RicoPlayer                 * ricoMain;
@property (nonatomic,strong) RicoPlayerControlBar       * playerControls;
@property (nonatomic,strong) RicoPlayerViewController   * playerViewController;

@property (nonatomic,strong) RicoZoomContainer          * topZoomContainer;
@property (nonatomic,strong) RicoZoomContainer          * bottomZoomContainer;

@property (weak, nonatomic) UIView                      * fullscreenView;




@property (strong, nonatomic, nonnull) DualViewPeriodTableViewController *periodTableViewController;

@property (strong, nonatomic, nonnull) UITapGestureRecognizer *topPlayerFullscreenRecognizer;
@property (strong, nonatomic, nonnull) UITapGestureRecognizer *bottomPlayerFullscreenRecognizer;

//@property (strong, nonatomic, nonnull) UIPinchGestureRecognizer *topPlayerFullscreenRecognizer;
//@property (strong, nonatomic, nonnull) UIPinchGestureRecognizer *bottomPlayerFullscreenRecognizer;

@property (strong, nonatomic, nonnull) UIView *bottomBarView;
@property (strong, nonatomic, nonnull) NCRecordButton *recordButton;
@property (strong, nonatomic, nonnull) UILabel *timeLabel;
@property (strong, nonatomic, nonnull) UILabel *activeTagLabel;

@property (strong, nonatomic, nonnull) LiveButton *liveButton;
@property (strong, nonatomic, nonnull) Slomo *slomoButton;
@property (strong, nonatomic, nonnull) SeekButton *backSeekButton;
@property (strong, nonatomic, nonnull) SeekButton *forwardSeekButton;

@property (strong, nonatomic, nonnull) NSArray *feeds;
@property (strong, nonatomic, nonnull) FeedSelectionController *topViewFeedSelectionController;
@property (strong, nonatomic, nonnull) FeedSelectionController *bottomViewFeedSelectionController;

@property (strong, nonatomic, nullable) NSString *activeTagName;
@property (assign, nonatomic) NSTimeInterval startTime;

@property (assign, nonatomic) CGRect fullscreenInitialRect;
//@property (weak, nonatomic, nullable) NCPlayerView *fullscreenView;

@property (assign, nonatomic) BOOL recording;
@property (copy, nonatomic, nullable) NSString *durationTagID;

@property (assign, nonatomic) CMTime resumeTime;
@property (assign, nonatomic) float resumeRate;

@end

@implementation RicoDualViewTabViewController

- (instancetype)initWithAppDelegate:(AppDelegate *)appDel {
    self = [super initWithAppDelegate:appDel];
    if (self) {
        [self setMainSectionTab:NSLocalizedString(@"Rico View", nil) imageName:@"live2BenchTab"];
        
        self.periodTableViewController = [[DualViewPeriodTableViewController alloc] init];
        self.periodTableViewController.delegate = self;
        
        self.bottomBarView = [[UIView alloc] init];
        
        self.recordButton = [[NCRecordButton alloc] init];
        self.recordButton.enabled = NO;
        self.timeLabel = [[UILabel alloc] init];
        self.activeTagLabel = [[UILabel alloc] init];
        
        CGFloat playerHeight = (768 - 55 - BOTTOM_BAR_HEIGHT) / 2.0;
        GLfloat playerWidth = playerHeight * (16.0 / 9.0);
        
        [self addChildViewController:self.periodTableViewController];
        
        self.feeds = @[];
        self.topViewFeedSelectionController = [[FeedSelectionController alloc] initWithFeeds:self.feeds];
        self.bottomViewFeedSelectionController = [[FeedSelectionController alloc] initWithFeeds:self.feeds];
        
        self.topViewFeedSelectionController.delegate = self;
        self.bottomViewFeedSelectionController.delegate = self;
        
        [self addChildViewController:self.topViewFeedSelectionController];
        [self addChildViewController:self.bottomViewFeedSelectionController];
        
//        self.topPlayerFullscreenRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(topFullscreen:)];
//        self.bottomPlayerFullscreenRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(bottomFullscreen:)];

        self.topPlayerFullscreenRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(topFullscreen:)];
        self.topPlayerFullscreenRecognizer.numberOfTapsRequired = 2;
        self.bottomPlayerFullscreenRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bottomFullscreen:)];
        self.bottomPlayerFullscreenRecognizer.numberOfTapsRequired = 2;
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sideTagsReady:) name:NOTIF_SIDE_TAGS_READY_FOR_L2B object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(addEventObserver:) name:NOTIF_PRIMARY_ENCODER_CHANGE object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(feedsReady:) name:NOTIF_EVENT_FEEDS_READY object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tabJustBeingAdded:) name:NOTIF_TAB_CREATED object:nil];
        
        
        // BEGIN RICO PLAYER
        self.topPlayer              = [[RicoPlayer alloc]initWithFrame:CGRectMake(0, 0, playerWidth, playerHeight)];
        self.topPlayer.name         = @"topPlayer";
        self.topPlayer.isPlaying    = YES;
        
        self.bottomPlayer           = [[RicoPlayer alloc]initWithFrame:CGRectMake(0, 0, playerWidth, playerHeight)];
        self.bottomPlayer.name      = @"bottomPlayer";
        self.bottomPlayer.isPlaying = YES;
        self.playerControls         = [[RicoPlayerControlBar alloc]initWithFrame:CGRectMake(200,200,400,40)];
     
        
        self.playerViewController                   = [RicoPlayerViewController new];
        self.playerViewController.playerControlBar  = self.playerControls;
        [self.playerViewController addPlayers:self.topPlayer];
        [self.playerViewController addPlayers:self.bottomPlayer];
        
        self.topZoomContainer = [[RicoZoomContainer alloc]initWithFrame:CGRectMake(1024 - playerWidth, 55, playerWidth, playerHeight)];
        self.topZoomContainer.zoomEnabled = YES;
        self.bottomZoomContainer = [[RicoZoomContainer alloc]initWithFrame:CGRectMake(1024 - playerWidth, 55 + playerHeight, playerWidth, playerHeight)];
        self.bottomZoomContainer.zoomEnabled = YES;
        
           self.playerControls.frame   = CGRectMake(0, CGRectGetMaxY(self.bottomZoomContainer.frame)-44,1024,44);
        // END RICO PLAYER
        
        
        _resumeTime = kCMTimeInvalid;
        _resumeRate = 1.0;
    }
    return self;
}

-(void)tabJustBeingAdded:(NSNotification*)note{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_TAB_CREATED object:nil];
    _observedEncoder = _appDel.encoderManager.masterEncoder;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(eventChanged:) name:NOTIF_EVENT_CHANGE object:_observedEncoder];
    _currentEvent = [_appDel.encoderManager.primaryEncoder event];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onTagChanged:) name:NOTIF_TAG_RECEIVED object:_currentEvent];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onTagChanged:) name:NOTIF_TAG_MODIFIED object:_currentEvent];
}

// encoderOberver
-(void)addEventObserver:(NSNotification *)note
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_TAB_CREATED object:nil];
    if (_observedEncoder != nil) {
        [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_EVENT_CHANGE object:_observedEncoder];
    }
    
    if (note.object == nil) {
        _observedEncoder = nil;
    }else{
        _observedEncoder = (id <EncoderProtocol>) note.object;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(eventChanged:) name:NOTIF_EVENT_CHANGE object:_observedEncoder];
    }
}

-(void)eventChanged:(NSNotification *)note
{
    if (_currentEvent != nil) {
        [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_TAG_RECEIVED object:_currentEvent];
        [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_TAG_MODIFIED object:_currentEvent];
        //[self.periodTableViewController ];
    }
    
    if (_currentEvent.live && _appDel.encoderManager.liveEvent == nil) {
        _currentEvent = nil;
    }else{
        _currentEvent = [((id <EncoderProtocol>) note.object) event];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onTagChanged:) name:NOTIF_TAG_RECEIVED object:_currentEvent];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onTagChanged:) name:NOTIF_TAG_MODIFIED object:_currentEvent];
        self.feeds = [[NSMutableArray arrayWithArray:[_currentEvent.feeds allValues]] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sourceName" ascending:YES]]];
        
        self.topViewFeedSelectionController.feeds = self.feeds;
        self.bottomViewFeedSelectionController.feeds = self.feeds;
        
        Feed *feedA = self.feeds.count > 0 ? self.feeds[0] : nil;
        Feed *feedB = self.feeds.count > 1 ? self.feeds[1]: feedA;
            [feedA setQuality:1];
            [feedB setQuality:1];
        self.liveButton.enabled = YES;
        

        if (_currentEvent.live) {

            NSBlockOperation * syncer = [NSBlockOperation blockOperationWithBlock:^{
                            [self.playerViewController live];
            }];

            [syncer addDependency:[self.topPlayer loadFeed:feedA]];
            [syncer addDependency: [self.bottomPlayer loadFeed:feedB]];
            [self.playerViewController.operationQueue addOperation:syncer];

        } else {
            [self.playerViewController play];
            [self.topPlayer loadFeed:feedA];
            [self.bottomPlayer loadFeed:feedB];
        }

    }
}

-(void)onTagChanged:(NSNotification *)note{
    
    for (Tag *tag in _currentEvent.tags ) {
        if (![self.periodTableViewController.tags containsObject:tag]) {
            if (tag.type == TagTypeNormal || tag.type == TagTypeTele || tag.type == TagTypeCloseDuration) {
                [self.periodTableViewController addTag:tag];
            }
        }
        if(tag.modified && [self.periodTableViewController.tags containsObject:tag]){
            if (tag.type == TagTypeNormal || tag.type == TagTypeTele) {
                [self.periodTableViewController removeTag:tag];
                [self.periodTableViewController addTag:tag];
            }
            if (tag.type == TagTypeCloseDuration) {
                [self.periodTableViewController addTag:tag];
            }
        }
    }
    
    Tag *toBeRemoved;
    for (Tag *tag in self.periodTableViewController.tags ){
        
        if (![_currentEvent.tags containsObject:tag]) {
            toBeRemoved = tag;
        }
    }
    if (toBeRemoved) {
        [self.periodTableViewController removeTag:toBeRemoved];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_SIDE_TAGS_READY_FOR_L2B object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_TAG_RECEIVED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_EVENT_FEEDS_READY object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_PRIMARY_ENCODER_CHANGE object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.periodTableViewController.view.frame = CGRectMake(0, 55, 320, 768 - 55 - BOTTOM_BAR_HEIGHT - PLAYHEAD_HEIGHT);
    
    self.bottomBarView.frame = CGRectMake(0, self.view.bounds.size.height - BOTTOM_BAR_HEIGHT - PLAYHEAD_HEIGHT, self.view.bounds.size.width, BOTTOM_BAR_HEIGHT + PLAYHEAD_HEIGHT);
    self.bottomBarView.backgroundColor = [UIColor blackColor];
    
    self.recordButton.frame = CGRectMake(self.bottomBarView.bounds.size.width - BOTTOM_BAR_HEIGHT, PLAYHEAD_HEIGHT, BOTTOM_BAR_HEIGHT, BOTTOM_BAR_HEIGHT);
    self.recordButton.displaysTime = NO;
    self.recordButton.delegate = self;
    [self.bottomBarView addSubview:self.recordButton];
    
    self.timeLabel.frame = CGRectMake(self.bottomBarView.center.x - 150, PLAYHEAD_HEIGHT, 300, BOTTOM_BAR_HEIGHT);
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.font = [UIFont systemFontOfSize:64];
    self.timeLabel.text = @"00:00:00";
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    [self.bottomBarView addSubview:self.timeLabel];
    
    self.activeTagLabel.frame = CGRectMake(15, PLAYHEAD_HEIGHT, 135, BOTTOM_BAR_HEIGHT);
    self.activeTagLabel.textColor = PRIMARY_APP_COLOR;
    self.activeTagLabel.font = [UIFont systemFontOfSize:20];
    self.activeTagLabel.text = @"";
    self.activeTagLabel.textAlignment = NSTextAlignmentLeft;
    [self.bottomBarView addSubview:self.activeTagLabel];
    
    self.liveButton = [[LiveButton alloc] initWithFrame:CGRectMake(self.bottomBarView.bounds.size.width - 370, BOTTOM_BAR_HEIGHT * 0.5 - 15 + PLAYHEAD_HEIGHT, 130, 35)];
    [self.liveButton addTarget:self action:@selector(liveButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBarView addSubview:self.liveButton];
    
    self.slomoButton = [[Slomo alloc] initWithFrame:CGRectMake(230, PLAYHEAD_HEIGHT, BOTTOM_BAR_HEIGHT, BOTTOM_BAR_HEIGHT)];
    [self.slomoButton addTarget:self action:@selector(slomoPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBarView addSubview:self.slomoButton];
    
    CGPoint forwardSeekPoint = [self.view convertPoint:CGPointMake(self.bottomBarView.bounds.size.width - 160 - 70, PLAYHEAD_HEIGHT) fromView:self.bottomBarView];
    CGPoint backSeekPoint = [self.view convertPoint:CGPointMake(160, PLAYHEAD_HEIGHT) fromView:self.bottomBarView];
    
    
    self.forwardSeekButton = [SeekButton makeFullScreenForwardAt:forwardSeekPoint];
    [self.forwardSeekButton onPressSeekPerformSelector:@selector(seekPressed:) addTarget:self];
    self.backSeekButton = [SeekButton makeFullScreenBackwardAt:backSeekPoint];
    [self.backSeekButton onPressSeekPerformSelector:@selector(seekPressed:) addTarget:self];
    
    [self.view addSubview:self.bottomBarView];

    // BEGIN NC PLAYER
        // END NC PLAYER
    
    
    // RICO PLAYER
    
    [self.view addSubview:self.topZoomContainer];
    [self.view addSubview:self.bottomZoomContainer];
    [self.topZoomContainer addToContainer:self.topPlayer];
    [self.bottomZoomContainer addToContainer:self.bottomPlayer];
    

    self.topPlayer.syncronized = YES;

    self.bottomPlayer.syncronized = YES;
    self.playerControls.delegate = self.playerViewController;

    [self.topZoomContainer addGestureRecognizer:self.topPlayerFullscreenRecognizer];
    [self.bottomZoomContainer addGestureRecognizer:self.bottomPlayerFullscreenRecognizer];
    // RICO PLAYER
    
    
    
    [self.view addSubview:self.periodTableViewController.view];
    
    [self.view addSubview:self.forwardSeekButton];
    [self.view addSubview:self.backSeekButton];
    
    UIView * tempView1 = self.topZoomContainer;
    UIView * tempView2 = self.bottomZoomContainer;
    
    self.topViewFeedSelectionController.view.frame = CGRectMake(tempView1.frame.origin.x - 128, CGRectGetMinY(tempView1.frame), 128, tempView1.frame.size.height);
    self.bottomViewFeedSelectionController.view.frame = CGRectMake(tempView2.frame.origin.x - 128, CGRectGetMinY(tempView2.frame), 128, tempView2.frame.size.height - PLAYHEAD_HEIGHT);
    [self.view addSubview:self.topViewFeedSelectionController.view];
    [self.view addSubview:self.bottomViewFeedSelectionController.view];
    
//    [self.topPlayer addGestureRecognizer:self.topPlayerFullscreenRecognizer];
//    [self.bottomPlayer addGestureRecognizer:self.bottomPlayerFullscreenRecognizer];
    
    
    [self.topViewFeedSelectionController    present:YES];
    [self.bottomViewFeedSelectionController present:YES];
    

//    [self.view addSubview:[DebugOutput getInstance]];
//    [DebugOutput getInstance].frame = CGRectMake(10, 60, 400, 200);

    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateSideTags];

    self.timeLabel.text = @"00:00:00";
    
    Event *event = [_appDel.encoderManager.primaryEncoder event];
    
    self.feeds = [[NSMutableArray arrayWithArray:[event.feeds allValues]] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sourceName" ascending:YES]]];
    self.periodTableViewController.tags = [NSMutableArray arrayWithArray:_appDel.encoderManager.primaryEncoder.event.tags];
    
    self.topViewFeedSelectionController.feeds = self.feeds;
    self.bottomViewFeedSelectionController.feeds = self.feeds;

    [self.periodTableViewController setHidden:NO animated:YES];
    [self.view addSubview: self.playerControls];
 
}

//-(void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//   [self.playerControls setNeedsDisplay]; // sometimes the bar does not refresh when it appears
//}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
//    self.resumeRate = self.mainPlayer.rate;
//    self.resumeTime = self.mainPlayer.currentTime;
//    
     // terminate the recording
    [self.recordButton terminate];
    
    self.recording = NO;
    
    self.backSeekButton.enabled = YES;
    self.forwardSeekButton.enabled = YES;
    self.slomoButton.enabled = YES;
    self.liveButton.hidden = NO;
    
    [self.periodTableViewController setHidden:YES animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}



- (void)updateSideTags {
    // sort them the way the user wanted them

    NSArray *sortedTagDescriptors = [_appDel.userCenter.tagNames sortedArrayUsingDescriptors:@[
                                                                                               [NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES],
                                                                                               [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES]]];
    
    NSMutableArray *tagNames = [NSMutableArray array];
    for (NSDictionary *tagDescriptor in sortedTagDescriptors) {
        [tagNames addObject:tagDescriptor[@"name"]];
    }
    
    self.periodTableViewController.tagNames = tagNames;

}

- (void)sideTagsReady:(NSNotification *)note {
    [self updateSideTags];
}

- (void)tagsReady:(NSNotification *)note {
    self.periodTableViewController.tags = [[_appDel.encoderManager.eventTags allValues] copy];
}

- (void)tagReceived:(NSNotification *)note {
    Tag *tag = note.object;
    if (tag) {
        [self.periodTableViewController addTag:tag];
    }
}

- (void)feedsReady:(NSNotification *)note {
    
}

- (void)setActiveTagName:(nullable NSString *)activeTagName {
    _activeTagName = activeTagName;
    self.recordButton.enabled = activeTagName != nil;
    self.activeTagLabel.text = activeTagName != nil ? activeTagName : @"";
}

#pragma mark - Fullscreen Methods

- (void)setFullscreen:(BOOL)fullscreen toFullScreen:(UIView *)toFullScreen toHide:(UIView *)toHide animated:(BOOL)animated {

   
    
    if (fullscreen && !self.fullscreenView) {
        self.fullscreenView = toFullScreen;
        self.fullscreenInitialRect = toFullScreen.frame;
        
        
        if (animated) {
            [UIView animateWithDuration:ANIMATION_DURATION
                             animations:^() {
                                 toFullScreen.frame  = CGRectMake(0, 55, 1024, 768 - 55 - BOTTOM_BAR_HEIGHT);
                                 toHide.alpha          = 0.0;
                                 self.view.backgroundColor  = [UIColor blackColor];
                             }
                             completion:^(BOOL finished) {
                                 //                                 self.topPlayerView.showsControlBar = YES;
                                 toHide.hidden       = YES;
                                 [self.bottomViewFeedSelectionController dismiss:YES];
                                 [self.topViewFeedSelectionController dismiss:YES];
                             }];
        } else {
            toFullScreen.frame = CGRectMake(0, 55, 1024, 768 - 55 - BOTTOM_BAR_HEIGHT);
            //            self.topPlayerView.showsControlBar = YES;
            toHide.alpha = 0.0;
            toHide.hidden = YES;
            self.view.backgroundColor = [UIColor blackColor];
        }
    } else if (!fullscreen && self.fullscreenView) {
        
        self.fullscreenView = nil;
//        otherPlayer = self.bottomPlayer;
        //        self.bottomPlayer.showsControlBar = NO;
        toHide.hidden = NO;
        
        if (animated) {
            
            [UIView animateWithDuration:ANIMATION_DURATION
                             animations:^() {
                                 toFullScreen.frame = self.fullscreenInitialRect;
                                 toHide.alpha = 1.0;
                                 self.view.backgroundColor = [UIColor whiteColor];
                             }
                             completion:^(BOOL finished) {
                                 //                                 self.topPlayerView.showsControlBar = NO;
                                 toHide.hidden = NO;
                                 [self.bottomViewFeedSelectionController present:YES];
                                 [self.topViewFeedSelectionController present:YES];
                             }];
        } else {
            toHide.alpha = 1.0;
            toFullScreen.frame = self.fullscreenInitialRect;
            self.view.backgroundColor = [UIColor whiteColor];
        }
    }


}


- (void)setTopFullscreen:(BOOL)fullscreen animated:(BOOL)animated {
    RicoPlayer * otherPlayer;
    if (fullscreen && !self.fullscreenView) {
        self.fullscreenView = self.topPlayer;
        otherPlayer = self.bottomPlayer;
        self.fullscreenInitialRect = self.topPlayer.frame;
        
        if (animated) {
            [UIView animateWithDuration:ANIMATION_DURATION
                             animations:^() {
                                 self.fullscreenView.frame  = CGRectMake(0, 55, 1024, 768 - 55 - BOTTOM_BAR_HEIGHT);
                                 otherPlayer.alpha          = 0.0;
                                 self.view.backgroundColor  = [UIColor blackColor];
                             }
                             completion:^(BOOL finished) {
//                                 self.topPlayerView.showsControlBar = YES;
                                 otherPlayer.hidden       = YES;
                             }];
        } else {
            self.fullscreenView.frame = CGRectMake(0, 55, 1024, 768 - 55 - BOTTOM_BAR_HEIGHT);
//            self.topPlayerView.showsControlBar = YES;
            otherPlayer.alpha = 0.0;
            otherPlayer.hidden = YES;
            self.view.backgroundColor = [UIColor blackColor];
        }
    } else if (!fullscreen && self.fullscreenView == self.topPlayer) {
        
        self.fullscreenView = nil;
        otherPlayer = self.bottomPlayer;
//        self.bottomPlayer.showsControlBar = NO;
        otherPlayer.hidden = NO;
        
        if (animated) {
            
            [UIView animateWithDuration:ANIMATION_DURATION
                             animations:^() {
                                 self.topPlayer.frame = self.fullscreenInitialRect;
                                 otherPlayer.alpha = 1.0;
                                 self.view.backgroundColor = [UIColor whiteColor];
                             }
                             completion:^(BOOL finished) {
//                                 self.topPlayerView.showsControlBar = NO;
                                 otherPlayer.hidden = NO;
                             }];
        } else {
            otherPlayer.alpha = 1.0;
            self.topPlayer.frame = self.fullscreenInitialRect;
            self.view.backgroundColor = [UIColor whiteColor];
        }
    }
}

- (void)setBottomFullscreen:(BOOL)fullscreen animated:(BOOL)animated {
//    if (fullscreen && !self.fullscreenView) {
//        self.fullscreenView = self.bottomPlayerView;
//        self.fullscreenInitialRect = self.bottomPlayerView.frame;
//        
//        if (animated) {
//            [UIView animateWithDuration:ANIMATION_DURATION
//                             animations:^() {
//                                 self.bottomPlayerView.frame = CGRectMake(0, 55, 1024, 768 - 55 - BOTTOM_BAR_HEIGHT);
//                                 self.topPlayerView.alpha = 0.0;
//                                 self.view.backgroundColor = [UIColor blackColor];
//                             }
//                             completion:^(BOOL finished) {
//                                 self.topPlayerView.hidden = YES;
//                             }];
//        } else {
//            self.bottomPlayerView.frame = CGRectMake(0, 55, 1024, 768 - 55 - BOTTOM_BAR_HEIGHT);
//            self.bottomPlayerView.showsControlBar = YES;
//            self.topPlayerView.alpha = 0.0;
//            self.topPlayerView.hidden = YES;
//            self.view.backgroundColor = [UIColor blackColor];
//        }
//    } else if (!fullscreen && self.fullscreenView == self.bottomPlayerView) {
//        
//        self.fullscreenView = nil;
//        
//        self.topPlayerView.hidden = NO;
//        
//        if (animated) {
//            
//            [UIView animateWithDuration:ANIMATION_DURATION
//                             animations:^() {
//                                 self.bottomPlayerView.frame = self.fullscreenInitialRect;
//                                 self.topPlayerView.alpha = 1.0;
//                                 self.view.backgroundColor = [UIColor whiteColor];
//                             }
//                             completion:^(BOOL finished) {
//                                 self.topPlayerView.hidden = NO;
//                             }];
//        } else {
//            self.bottomPlayerView.frame = self.fullscreenInitialRect;
//            self.topPlayerView.alpha = 1.0;
//            self.view.backgroundColor = [UIColor whiteColor];
//        }
//    }
}

#pragma mark - Gesture Recognizers

//- (void)topFullscreen:(UIPinchGestureRecognizer *)recognizer {
//    if (recognizer.velocity > PINCH_VELOCITY) {
//        [self setFullscreen:YES toFullScreen:self.topPlayer toHide:self.bottomPlayer animated:YES];
//    } else if (recognizer.velocity < -PINCH_VELOCITY) {
//        [self setFullscreen:NO toFullScreen:self.topPlayer toHide:self.bottomPlayer animated:YES];
//    }
//}
//
//- (void)bottomFullscreen:(UIPinchGestureRecognizer *)recognizer {
//    if (recognizer.velocity > PINCH_VELOCITY) {
//        [self setFullscreen:YES toFullScreen:self.bottomPlayer toHide:self.topPlayer animated:YES];
//    } else if (recognizer.velocity < -PINCH_VELOCITY) {
//        [self setFullscreen:NO toFullScreen:self.bottomPlayer toHide:self.topPlayer animated:YES];
//    }
//}

- (void)topFullscreen:(UITapGestureRecognizer *)recognizer {
    self.topZoomContainer.zoomEnabled = false;
    self.topZoomContainer.zoomEnabled = true;
    if (!self.fullscreenView) {
        [self setFullscreen:YES toFullScreen:self.topZoomContainer toHide:self.bottomZoomContainer animated:YES];
    } else {
        [self setFullscreen:NO toFullScreen:self.topZoomContainer toHide:self.bottomZoomContainer animated:YES];

    }

}

- (void)bottomFullscreen:(UITapGestureRecognizer *)recognizer {
    self.bottomZoomContainer.zoomEnabled = false;
    self.bottomZoomContainer.zoomEnabled = true;

    if (!self.fullscreenView) {
        [self setFullscreen:YES toFullScreen:self.bottomZoomContainer toHide:self.topZoomContainer animated:YES];
    }else {
        [self setFullscreen:NO toFullScreen:self.bottomZoomContainer toHide:self.topZoomContainer animated:YES];
    }
    
}


#pragma mark - Actions

- (void)liveButtonPressed:(LiveButton *)sender {
        [self.playerViewController cancelPressed:self.playerControls];    
    self.slomoButton.slomoOn = NO;
    if (_currentEvent.live){
        self.playerViewController.slomo = NO;
        self.playerControls.state = RicoPlayerStateLive;
        [self.playerViewController seekToTime: kCMTimePositiveInfinity //self.playerControls.range.duration
                              toleranceBefore:kCMTimeZero
                               toleranceAfter:kCMTimePositiveInfinity
                            completionHandler:nil];
        
        [self.playerViewController play];
       
    } else {
        [_appDel.encoderManager declareCurrentEvent:_appDel.encoderManager.liveEvent];
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_TAG_RECEIVED object:_appDel.encoderManager.liveEvent];
    }
    
    self.timeLabel.text = @"00:00:00";

}

- (void)seekPressed:(SeekButton *)sender {
//    [self.mainPlayer seekBy:CMTimeMakeWithSeconds(sender.speed, NSEC_PER_SEC)];
    
    CMTime  sTime = CMTimeMakeWithSeconds(sender.speed, NSEC_PER_SEC);
    CMTime  cTime = self.playerViewController.primaryPlayers.currentTime;
    self.playerControls.state = RicoPlayerStateNormal;
    [self.playerViewController seekToTime:CMTimeAdd(cTime, sTime) toleranceBefore:kCMTimePositiveInfinity toleranceAfter:kCMTimePositiveInfinity completionHandler:nil];
}

- (void)slomoPressed:(Slomo *)slomo {
    slomo.slomoOn = !slomo.slomoOn;
    self.playerControls.state = RicoPlayerStateNormal;
    self.playerViewController.slomo = slomo.slomoOn;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - DualViewTagControllerDelegate

- (void)tagController:(nonnull DualViewPeriodTableViewController *)tagController didSelectTagNamed:(nonnull NSString *)tagName {
    
    self.activeTagName = tagName;
}

- (void)clipController:(nonnull DualViewClipTableViewController *)clipController didSelectTagClip:(nonnull Tag *)tag {

    
//    self.mainPlayer.loopRange = range;
    [self.playerViewController playTag:tag];
    
}

#pragma mark - FeedSelectionControllerDelegate

- (void)feedSelectionController:(nonnull FeedSelectionController *)feedSelectionController didSelectFeed:(nonnull Feed *)feed {
//    self.playerViewController
    
    
    // cancel if your playing a tag
    [self.playerViewController cancelPressed:self.playerControls];
    
    RicoPlayer * aplayer;
    
    if (feedSelectionController == self.topViewFeedSelectionController) {
        aplayer = self.topPlayer;
    } else if (feedSelectionController == self.bottomViewFeedSelectionController) {
        aplayer = self.bottomPlayer;
    }
    
    CMTime time = aplayer.currentTime;

//    aplayer.feed = feed;
//    [aplayer loadFeed:feed];
//    [[aplayer loadFeed:feed] setCompletionBlock:^{
//        NSLog(@"PRessessssssssssss");
//    }];
    [aplayer loadFeed:feed];

    [aplayer seekToTime:time toleranceBefore:kCMTimePositiveInfinity toleranceAfter:kCMTimePositiveInfinity completionHandler:nil] ;
    
    
    if (aplayer.isPlaying) {
        [aplayer play];
    }
    

}

#pragma mark - NCRecordButtonDelegate

- (void)recordingDidStartInRecordButton:(nonnull NCRecordButton *)recordButton {
    self.recording                      = YES;
    self.startTime                      = CMTimeGetSeconds(self.playerViewController.primaryPlayers.currentTime);
    self.backSeekButton.enabled         = NO;
    self.forwardSeekButton.enabled      = NO;
    self.slomoButton.enabled            = NO;
    self.liveButton.hidden              = YES;
    self.playerControls.enabled         = NO;
    [self.periodTableViewController setHidden:YES animated:YES];

    [self.bottomViewFeedSelectionController dismiss:YES];
    [self.topViewFeedSelectionController dismiss:YES];
    
    self.timeLabel.textColor = [UIColor whiteColor];

    self.durationTagID = [Tag makeDurationID];
//
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_TAG_POSTED object:self userInfo:@{
                                                                                                      @"name":self.activeTagName,
                                                                                                      @"time":[NSString stringWithFormat:@"%f", self.startTime],
                                                                                                      @"type":[NSNumber numberWithInteger:TagTypeOpenDuration],
                                                                                                      @"dtagid": self.durationTagID
                                                                                                      }];
    
}

- (void)recordingDidFinishInRecordButton:(nonnull NCRecordButton *)recordButton withDuration:(NSTimeInterval)duration {
    self.recording = NO;
    self.backSeekButton.enabled = YES;
    self.forwardSeekButton.enabled = YES;
    self.slomoButton.enabled = YES;
    self.liveButton.hidden = NO;
    self.playerControls.enabled         = YES;
    [self.periodTableViewController setHidden:NO animated:YES];
    
    if (!self.fullscreenView){
        [self.bottomViewFeedSelectionController present:YES];
        [self.topViewFeedSelectionController present:YES];
    }
    
    NSTimeInterval endTime = CMTimeGetSeconds(self.playerViewController.primaryPlayers.currentTime);

    Tag *tag = [Tag getOpenTagByDurationId:self.durationTagID];

    NSMutableDictionary * tagData   = [NSMutableDictionary dictionaryWithDictionary:[tag makeTagData]];

    [tagData setValue:[NSString stringWithFormat:@"%f", endTime] forKey:@"closetime"];
    [tagData setValue:[NSNumber numberWithInteger:TagTypeCloseDuration] forKey:@"type"];
    [tagData setValue:self.durationTagID forKey:@"dtagid"];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MODIFY_TAG object:nil userInfo:tagData];
    self.durationTagID = nil;
    
    self.timeLabel.textColor = [UIColor lightGrayColor];
}

- (void)recordingDidTerminateInRecordButton:(nonnull NCRecordButton *)recordButton {
    self.recording = NO;
    
    self.backSeekButton.enabled = YES;
    self.forwardSeekButton.enabled = YES;
    self.slomoButton.enabled = YES;
    self.liveButton.hidden = NO;
    self.playerControls.enabled         = YES;
    [self.periodTableViewController setHidden:NO animated:YES];
    if (!self.fullscreenView){
        [self.bottomViewFeedSelectionController present:YES];
        [self.topViewFeedSelectionController present:YES];
    }
    Tag *tag = [Tag getOpenTagByDurationId:self.durationTagID];
    if (tag) {
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_DELETE_TAG object:tag];
    }
    
    self.durationTagID = nil;
    
    self.timeLabel.textColor = [UIColor lightGrayColor];
}

- (void)recordingTimeDidUpdateInRecordButton:(nonnull NCRecordButton *)recordButton {
//    
    if (self.recording) {
        
        NSTimeInterval clipDuration = CMTimeGetSeconds(self.playerViewController.primaryPlayers.currentTime) - self.startTime;
        
        self.timeLabel.text = [self recordingTimeStringForSeconds:clipDuration];
    } else {
        self.timeLabel.text = @"00:00:00";
    }
}

- (NSString *)recordingTimeStringForSeconds:(NSTimeInterval)seconds {
    NSUInteger second = 00;
    NSUInteger minute = 00;
    NSUInteger hour = 00;
    
    second = (NSUInteger) seconds;
    hour = second / 3600;
    minute = second % 3600 / 60;
    second = second % 60;
    
    return [NSString stringWithFormat:@"%02lu:%02lu:%02lu",(unsigned long) hour, (unsigned long) minute, (unsigned long)second];
}



@end

