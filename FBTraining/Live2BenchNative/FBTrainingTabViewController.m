//
//  FBTrainingTabViewController.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-05-19.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "FBTrainingTabViewController.h"

#import "FBTrainingPeriodTableViewController.h"
#import "NCRecordButton.h"
#import "UserCenter.h"
#import "EncoderClasses/EncoderProtocol.h"
#import "EncoderClasses/EncoderManager.h"
#import "RJLVideoPlayer.h"
#import "PipViewController.h"
#import "FeedSelectionController.h"
#import "LiveButton.h"
#import "SeekButton.h"

#import "NCPlayerView.h"

#define BOTTOM_BAR_HEIGHT 70
#define PLAYHEAD_HEIGHT 44
#define PINCH_VELOCITY 1

@interface FBTrainingTabViewController () <NCRecordButtonDelegate, FeedSelectionControllerDelegate, FBTrainingTagControllerDelegate>

// BEGIN NC PLAYER

@property (strong, nonatomic, nonnull) NCPlayerContext *playerContext;

@property (strong, nonatomic, nonnull) NCPlayer *playerA;
@property (strong, nonatomic, nonnull) NCPlayer *playerB;

@property (weak, nonatomic, nonnull) NCPlayer *mainPlayer;

@property (strong, nonatomic, nonnull) NCPlayerView *topPlayerView;
@property (strong, nonatomic, nonnull) NCPlayerView *bottomPlayerView;
@property (strong, nonatomic, nonnull) NCPlayerView *fullscreenPlayerView;

// END NC PLAYER

@property (strong, nonatomic, nonnull) FBTrainingPeriodTableViewController *periodTableViewController;

@property (strong, nonatomic, nonnull) UIViewController<PxpVideoPlayerProtocol> *currentPlayer;

@property (strong, nonatomic, nonnull) UIViewController<PxpVideoPlayerProtocol> *splitPlayer;
@property (strong, nonatomic, nonnull) PipViewController *pipViewController;

@property (strong, nonatomic, nonnull) UIViewController<PxpVideoPlayerProtocol> *fullscreenPlayer;

@property (strong, nonatomic, nonnull) UIPinchGestureRecognizer *pipToFullscreenRecognizer;
@property (strong, nonatomic, nonnull) UIPinchGestureRecognizer *playerToFullscreenRecognizer;
@property (strong, nonatomic, nonnull) UIPinchGestureRecognizer *exitFullscreenRecognizer;

@property (strong, nonatomic, nonnull) UIView *bottomBarView;
@property (strong, nonatomic, nonnull) Pip *pipView;
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
@property (assign, nonatomic) BOOL isFullscreen;
@property (assign, nonatomic) BOOL recording;

@end

@implementation FBTrainingTabViewController

- (instancetype)initWithAppDelegate:(AppDelegate *)appDel {
    self = [super initWithAppDelegate:appDel];
    if (self) {
        [self setMainSectionTab:NSLocalizedString(@"FBTraining", nil) imageName:@"FBTraining"];
        
        self.periodTableViewController = [[FBTrainingPeriodTableViewController alloc] init];
        self.periodTableViewController.delegate = self;
        
        self.bottomBarView = [[UIView alloc] init];
        
        self.recordButton = [[NCRecordButton alloc] init];
        self.recordButton.enabled = NO;
        self.timeLabel = [[UILabel alloc] init];
        self.activeTagLabel = [[UILabel alloc] init];
        
        CGFloat playerHeight = (768 - 55 - BOTTOM_BAR_HEIGHT) / 2.0;
        GLfloat playerWidth = playerHeight * (16.0 / 9.0);
        
        self.splitPlayer = [[RJLVideoPlayer alloc] initWithFrame:CGRectMake(0, 0, playerWidth, playerHeight)];
        self.fullscreenPlayer = [[RJLVideoPlayer alloc] initWithFrame:CGRectMake(0, 55, 1024, 768 - 55 - BOTTOM_BAR_HEIGHT)];
        self.fullscreenPlayer.view.frame = CGRectZero;
        self.fullscreenPlayer.view.hidden = YES;
        
        self.currentPlayer = self.splitPlayer;
        
        self.pipView = [[Pip alloc] initWithFrame:CGRectMake(0, 0, playerWidth, playerHeight)];
        self.pipView.layer.borderWidth = 0.0;
        
        self.pipViewController = [[PipViewController alloc] initWithVideoPlayer:self.splitPlayer f:nil encoderManager:_appDel.encoderManager];
        self.pipViewController.swapsOnSingleTap = NO;
        
        [self addChildViewController:self.periodTableViewController];
        [self addChildViewController:self.splitPlayer];
        [self addChildViewController:self.pipViewController];
        [self addChildViewController:self.fullscreenPlayer];
        
        self.feeds = @[];
        self.topViewFeedSelectionController = [[FeedSelectionController alloc] initWithFeeds:self.feeds];
        self.bottomViewFeedSelectionController = [[FeedSelectionController alloc] initWithFeeds:self.feeds];
        
        self.topViewFeedSelectionController.delegate = self;
        self.bottomViewFeedSelectionController.delegate = self;
        
        [self addChildViewController:self.topViewFeedSelectionController];
        [self addChildViewController:self.bottomViewFeedSelectionController];
        
        self.pipToFullscreenRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pipToFullscreen:)];
        self.playerToFullscreenRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(playerToFullscreen:)];
        self.exitFullscreenRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(exitFullscreen:)];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sideTagsReady:) name:NOTIF_SIDE_TAGS_READY_FOR_L2B object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tagsReady:) name:NOTIF_TAGS_ARE_READY object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tagReceived:) name:NOTIF_TAG_RECEIVED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(feedsReady:) name:NOTIF_EVENT_FEEDS_READY object:nil];
        
        // BEGIN NC PLAYER
        
        self.playerContext = [[NCPlayerContext alloc] init];
        
        self.playerA = [[NCPlayer alloc] initWithPlayerItem:nil];
        self.playerB = [[NCPlayer alloc] initWithPlayerItem:nil];
        
        self.playerA.context = self.playerContext;
        self.playerB.context = self.playerContext;
        
        self.playerA.muted = YES;
        self.playerB.muted = YES;
        
        self.mainPlayer = self.playerA;
        self.mainPlayer.syncInterval = CMTimeMakeWithSeconds(5.0, NSEC_PER_SEC);
        
        self.topPlayerView = [[NCPlayerView alloc] initWithFrame:CGRectMake(1024 - playerWidth, 55, playerWidth, playerHeight)];
        self.bottomPlayerView = [[NCPlayerView alloc] initWithFrame:CGRectMake(1024 - playerWidth, 55 + playerHeight, playerWidth, playerHeight)];
        
        self.topPlayerView.showsControlBar = NO;
        
        self.topPlayerView.player = self.playerB;
        self.bottomPlayerView.player = self.playerA;
        
        self.fullscreenPlayerView = [[NCPlayerView alloc] initWithFrame:CGRectMake(0, 55, 1024, 768 - 55 - BOTTOM_BAR_HEIGHT)];
        self.fullscreenPlayerView.player = self.playerB;
        self.fullscreenPlayerView.frame = CGRectZero;
        
        // END NC PLAYER
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_SIDE_TAGS_READY_FOR_L2B object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_TAGS_ARE_READY object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_TAG_RECEIVED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_EVENT_FEEDS_READY object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIView *pipContainer = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - self.pipView.frame.size.width, 55, self.pipView.frame.size.width, self.pipView.frame.size.height)];
    UIView *playerContainer = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - self.splitPlayer.view.frame.size.width, 55 + pipContainer.frame.size.height, self.splitPlayer.view.frame.size.width, self.splitPlayer.view.frame.size.height)];
    
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
    
    [self.pipViewController addPip:self.pipView];
    
    [pipContainer addSubview:self.pipView];
    [playerContainer addSubview:self.splitPlayer.view];
    
    [self.view addSubview:self.bottomBarView];
    //[self.view addSubview:pipContainer];
    //[self.view addSubview:playerContainer];
    
    //[self.view addSubview:self.fullscreenPlayer.view];
    
    // BEGIN NC PLAYER
    
    [self.view addSubview:self.topPlayerView];
    [self.view addSubview:self.bottomPlayerView];
    [self.view addSubview:self.fullscreenPlayerView];
    
    // END NC PLAYER
    
    [self.view addSubview:self.periodTableViewController.view];
    
    [self.view addSubview:self.forwardSeekButton];
    [self.view addSubview:self.backSeekButton];
    
    self.topViewFeedSelectionController.view.frame = CGRectMake(self.topPlayerView.frame.size.width - 128, 0, 128, self.bottomPlayerView.frame.size.height);
    self.bottomViewFeedSelectionController.view.frame = CGRectMake(playerContainer.frame.size.width - 128, 0, 128, playerContainer.frame.size.height - PLAYHEAD_HEIGHT);
    
    [self.topPlayerView addSubview:self.topViewFeedSelectionController.view];
    [self.bottomPlayerView addSubview:self.bottomViewFeedSelectionController.view];
    
    [self.topPlayerView addGestureRecognizer:self.pipToFullscreenRecognizer];
    [self.bottomPlayerView addGestureRecognizer:self.playerToFullscreenRecognizer];
    [self.fullscreenPlayerView addGestureRecognizer:self.exitFullscreenRecognizer];
    
    self.pipView.muted = YES;
    self.fullscreenPlayer.mute = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [self updateSideTags];
    
    self.timeLabel.text = @"00:00:00";
    
    Event *event = [_appDel.encoderManager.primaryEncoder event];
    
    self.feeds = [[NSMutableArray arrayWithArray:[event.feeds allValues]] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sourceName" ascending:YES]]];
    self.periodTableViewController.tags = [[_appDel.encoderManager.eventTags allValues] copy];
    
    NSLog(@"%@", self.feeds);
    self.topViewFeedSelectionController.feeds = self.feeds;
    self.bottomViewFeedSelectionController.feeds = self.feeds;
    
    [self setFullscreen:NO animated:NO rect:CGRectZero];
    
    //[self.splitPlayer playFeed:self.feeds.count > 0 ? self.feeds[0] : nil];
    //[self.pipView playWithFeed:self.feeds.count > 1 ? self.feeds[1] : self.splitPlayer.feed];
    //[self.pipViewController syncToPlayer];
    
    //self.splitPlayer.mute = NO;
    
    Feed *feedA = self.feeds.count > 0 ? self.feeds[0] : nil;
    Feed *feedB = self.feeds.count > 1 ? self.feeds[1]: feedA;
    
    NSLog(@"\t%@\n\t%@", feedA.path, feedB.path);
    
    self.playerA.URL = feedA.path;
    self.playerB.URL = feedB.path;
    
    [self.liveButton isActive:event.live];
    
    // tell other players to STFU and hope they will
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_COMMAND_VIDEO_PLAYER object:nil userInfo:@{ @"command":[NSNumber numberWithInt:VideoPlayerCommandMute]}];
    
    self.mainPlayer.muted = NO;
    
    [self.periodTableViewController setHidden:NO animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    
    // pause the player
    [self.playerA pause];
    
    // we're nice and mute when no one is listening
    self.currentPlayer.mute = YES;
    self.mainPlayer.muted = YES;
    
    // terminate the recording
    [self.recordButton terminate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setMainPlayer:(nonnull NCPlayer *)mainPlayer {
    _mainPlayer.muted = YES;
    _mainPlayer = mainPlayer;
    _mainPlayer.muted = NO;
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
    
    // random tags
    /*
     for (NSUInteger i = 0; i < 64; i++) {
     NSString *name = tagNames[(NSUInteger)(drand48() * (tagNames.count))];
     if (![name isEqualToString:@"--"]) {
     Tag *tag = [[Tag alloc] init];
     tag.time = drand48();
     tag.name = name;
     
     [self.periodTableViewController addTag:tag];
     }
     }
     */
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

- (void)setFullscreen:(BOOL)fullscreen animated:(BOOL)animated rect:(CGRect)rect {
    
    if (fullscreen && !self.isFullscreen) {
        
        self.fullscreenPlayerView.frame = rect;
        self.fullscreenPlayerView.hidden = NO;
        
        if (animated) {
            
            [UIView animateWithDuration:1.0
                             animations:^() {
                                 self.fullscreenPlayerView.frame = CGRectMake(0, 55, 1024, 768 - 55 - BOTTOM_BAR_HEIGHT);
                             }
                             completion:^(BOOL finished) {
                                 self.topPlayerView.hidden = YES;
                                 self.bottomPlayerView.hidden = YES;
                             }];
        } else {
            self.fullscreenPlayerView.frame = CGRectMake(0, 55, 1024, 768 - 55 - BOTTOM_BAR_HEIGHT);
            self.topPlayerView.hidden = YES;
            self.bottomPlayerView.hidden = YES;
        }
        
        self.isFullscreen = YES;
        
    } else if (!fullscreen && self.isFullscreen) {
        
        self.topPlayerView.hidden = NO;
        self.bottomPlayerView.hidden = NO;
        
        if (animated) {
            
            [UIView animateWithDuration:1.0
                             animations:^() {
                                 self.fullscreenPlayerView.frame = rect;
                             }
                             completion:^(BOOL finished) {
                                 self.fullscreenPlayerView.hidden = YES;
                             }];
        } else {
            self.fullscreenPlayerView.frame = rect;
            self.fullscreenPlayerView.hidden = YES;
        }
        
        self.isFullscreen = NO;
    }
    
    
}

#pragma mark - Gesture Recognizers

- (void)pipToFullscreen:(UIPinchGestureRecognizer *)recognizer {
    if (recognizer.velocity > PINCH_VELOCITY) {
        
        self.fullscreenPlayerView.player = self.topPlayerView.player;
        
        /*
        [self.fullscreenPlayer playFeed:self.pipView.feed];
        
        [self.fullscreenPlayer.avPlayer seekToTime:self.splitPlayer.avPlayer.currentTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL complete) {
            [self.fullscreenPlayer.avPlayer prerollAtRate:self.splitPlayer.avPlayer.rate completionHandler:^(BOOL complete) {
                [self.fullscreenPlayer.avPlayer setRate:self.splitPlayer.avPlayer.rate];
            }];
        }];
         */
        
        //[self.fullscreenPlayer seekToInSec:self.splitPlayer.currentTimeInSeconds];
        
        self.fullscreenInitialRect = [self.view convertRect:self.topPlayerView.bounds fromView:self.topPlayerView];
        [self setFullscreen:YES animated:YES rect:self.fullscreenInitialRect];

    }
}

- (void)playerToFullscreen:(UIPinchGestureRecognizer *)recognizer {
    if (recognizer.velocity > PINCH_VELOCITY) {
        
        self.fullscreenPlayerView.player = self.bottomPlayerView.player;
        
        /*
        [self.fullscreenPlayer playFeed:self.splitPlayer.feed];
        
        [self.fullscreenPlayer.avPlayer seekToTime:self.splitPlayer.avPlayer.currentTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL complete) {
            [self.fullscreenPlayer.avPlayer prerollAtRate:self.splitPlayer.avPlayer.rate completionHandler:^(BOOL complete) {
                [self.fullscreenPlayer.avPlayer setRate:self.splitPlayer.avPlayer.rate];
            }];
        }];
        */
        // [self.fullscreenPlayer seekToInSec:self.splitPlayer.currentTimeInSeconds];
        
        self.fullscreenInitialRect = [self.view convertRect:self.bottomPlayerView.bounds fromView:self.bottomPlayerView];
        [self setFullscreen:YES animated:YES rect:self.fullscreenInitialRect];
    }
}

- (void)exitFullscreen:(UIPinchGestureRecognizer *)recognizer {
    if (recognizer.velocity < -PINCH_VELOCITY) {
        
        /*
        [self.splitPlayer.avPlayer seekToTime:self.fullscreenPlayer.avPlayer.currentTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL complete) {
            [self.splitPlayer.avPlayer prerollAtRate:self.fullscreenPlayer.avPlayer.rate completionHandler:^(BOOL complete) {
                [self.splitPlayer.avPlayer setRate:self.fullscreenPlayer.avPlayer.rate];
            }];
        }];
         */
        
        //[self.splitPlayer seekToInSec:self.fullscreenPlayer.currentTimeInSeconds];
        [self setFullscreen:NO animated:YES rect:self.fullscreenInitialRect];
    }
}

#pragma mark - Actions

- (void)liveButtonPressed:(LiveButton *)sender {
    
    // invalidate the loop range
    self.mainPlayer.loopRange = kCMTimeRangeInvalid;
    
    float rate = self.mainPlayer.rate;
    
    // seek a bit before
    CMTime time = CMTimeSubtract(self.mainPlayer.duration, CMTimeMake(2, 1));
    
    NSLog(@"%@", self.mainPlayer);
    
    if (CMTIME_IS_NUMERIC(time)) {
        [self.mainPlayer pause];
        [self.mainPlayer seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL complete) {
            [self.mainPlayer prerollAndPlayAtRate:rate];
        }];
    }
}

- (void)seekPressed:(SeekButton *)sender {
    [self.mainPlayer seekBy:CMTimeMakeWithSeconds(sender.speed, NSEC_PER_SEC)];
}

- (void)slomoPressed:(Slomo *)slomo {
    slomo.slomoOn = !slomo.slomoOn;
    self.mainPlayer.slomo = slomo.slomoOn;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - FBTrainingTagControllerDelegate

- (void)tagController:(nonnull FBTrainingPeriodTableViewController *)tagController didSelectTagNamed:(nonnull NSString *)tagName {
    // invalidate the loop range
    self.mainPlayer.loopRange = kCMTimeRangeInvalid;
    
    self.activeTagName = tagName;
}

- (void)clipController:(nonnull FBTrainingClipTableViewController *)clipController didSelectTagClip:(nonnull Tag *)tag {
    CMTimeRange range = CMTimeRangeMake(CMTimeMakeWithSeconds(tag.time, 1), CMTimeMakeWithSeconds(tag.duration, 1));
    
    self.mainPlayer.loopRange = range;
    //[self.currentPlayer playClipWithFeed:self.currentPlayer.feed andTimeRange:range];
}

#pragma mark - FeedSelectionControllerDelegate

- (void)feedSelectionController:(nonnull FeedSelectionController *)feedSelectionController didSelectFeed:(nonnull Feed *)feed {
    if (feedSelectionController == self.topViewFeedSelectionController) {
        //[self.pipView playWithFeed:feed];
        
        __weak NCPlayer *player = self.topPlayerView.player;
        
        float rate = player.rate;
        CMTime time = player.currentTime;
        
        [player setURL:feed.path];
        [player addReadyToPlayObserver:^(BOOL ready) {
            NSLog(@"READY");
            [player setRate:rate atTime:time];
        }];
        
    } else if (feedSelectionController == self.bottomViewFeedSelectionController) {
        //[self.splitPlayer playFeed:feed];
        
        __weak NCPlayer *player = self.bottomPlayerView.player;
        
        float rate = player.rate;
        CMTime time = player.currentTime;
        
        [player setURL:feed.path];
        [player addReadyToPlayObserver:^(BOOL ready) {
            [player setRate:rate atTime:time];
        }];
    }
    
    [feedSelectionController dismiss:YES];
}

#pragma mark - NCRecordButtonDelegate

- (void)recordingDidStartInRecordButton:(nonnull NCRecordButton *)recordButton {
    // invalidate the loop range
    self.mainPlayer.loopRange = kCMTimeRangeInvalid;
    
    self.recording = YES;
    self.startTime = CMTimeGetSeconds(self.mainPlayer.currentTime);
    
    self.currentPlayer.videoControlBar.enable = NO;
    self.currentPlayer.liveIndicatorLight.tintColor = [UIColor redColor];
    self.currentPlayer.liveIndicatorLight.hidden = NO;
    
    self.backSeekButton.enabled = NO;
    self.forwardSeekButton.enabled = NO;
    self.slomoButton.enabled = NO;
    self.liveButton.hidden = YES;
    [self.periodTableViewController setHidden:YES animated:YES];
}

- (void)recordingDidFinishInRecordButton:(nonnull NCRecordButton *)recordButton withDuration:(NSTimeInterval)duration {
    self.recording = NO;
    self.currentPlayer.videoControlBar.enable = YES;
    self.currentPlayer.liveIndicatorLight.hidden = !self.currentPlayer.live;
    self.currentPlayer.liveIndicatorLight.tintColor = [UIColor greenColor];
    
    self.backSeekButton.enabled = YES;
    self.forwardSeekButton.enabled = YES;
    self.slomoButton.enabled = YES;
    self.liveButton.hidden = NO;
    [self.periodTableViewController setHidden:NO animated:YES];
    
    NSTimeInterval clipDuration = CMTimeGetSeconds(self.mainPlayer.currentTime) - self.startTime;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_TAG_POSTED
                                                        object:nil
                                                      userInfo:@{ @"name": self.activeTagName,
                                                                  @"time": [NSString stringWithFormat:@"%f", self.startTime],
                                                                  @"duration": [NSString stringWithFormat:@"%d", (int) ceil(clipDuration) + 10]
                                                                  }];
}

- (void)recordingTimeDidUpdateInRecordButton:(nonnull NCRecordButton *)recordButton {
    
    if (self.recording) {
        NSTimeInterval clipDuration = CMTimeGetSeconds(self.mainPlayer.currentTime) - self.startTime;
        
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
