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
#define ANIMATION_DURATION 0.25

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

@property (strong, nonatomic, nonnull) UIPinchGestureRecognizer *topPlayerFullscreenRecognizer;
@property (strong, nonatomic, nonnull) UIPinchGestureRecognizer *bottomPlayerFullscreenRecognizer;

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
@property (weak, nonatomic, nullable) NCPlayerView *fullscreenView;

@property (assign, nonatomic) BOOL recording;

@end

@implementation FBTrainingTabViewController

- (instancetype)initWithAppDelegate:(AppDelegate *)appDel {
    self = [super initWithAppDelegate:appDel];
    if (self) {
        [self setMainSectionTab:NSLocalizedString(@"FBTraining", nil) imageName:@"live2BenchTab"];
        
        self.periodTableViewController = [[FBTrainingPeriodTableViewController alloc] init];
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
        
        self.topPlayerFullscreenRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(topFullscreen:)];
        self.bottomPlayerFullscreenRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(bottomFullscreen:)];
        
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
        self.mainPlayer.syncInterval = CMTimeMakeWithSeconds(1.0, NSEC_PER_SEC);
        
        self.topPlayerView = [[NCPlayerView alloc] initWithFrame:CGRectMake(1024 - playerWidth, 55, playerWidth, playerHeight)];
        self.bottomPlayerView = [[NCPlayerView alloc] initWithFrame:CGRectMake(1024 - playerWidth, 55 + playerHeight, playerWidth, playerHeight)];
        
        self.topPlayerView.showsControlBar = NO;
        
        self.topPlayerView.player = self.playerB;
        self.bottomPlayerView.player = self.playerA;
        
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
    self.bottomViewFeedSelectionController.view.frame = CGRectMake(self.bottomPlayerView.frame.size.width - 128, 0, 128, self.bottomPlayerView.frame.size.height - PLAYHEAD_HEIGHT);
    
    [self.topPlayerView addSubview:self.topViewFeedSelectionController.view];
    [self.bottomPlayerView addSubview:self.bottomViewFeedSelectionController.view];
    
    [self.topPlayerView addGestureRecognizer:self.topPlayerFullscreenRecognizer];
    [self.bottomPlayerView addGestureRecognizer:self.bottomPlayerFullscreenRecognizer];
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
    
    if (event.live) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.mainPlayer.status == AVPlayerStatusReadyToPlay) [self.mainPlayer play];
        });
    }
    
    // tell other players to STFU and hope they will
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_COMMAND_VIDEO_PLAYER object:nil userInfo:@{ @"command":[NSNumber numberWithInt:VideoPlayerCommandMute]}];
    
    self.mainPlayer.muted = NO;
    
    [self.periodTableViewController setHidden:NO animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    
    // pause the player
    [self.playerA pause];
    
    // we're nice and mute when no one is listening
    self.mainPlayer.muted = YES;
    
    // terminate the recording
    [self.recordButton terminate];
    
    self.recording = NO;
    
    self.backSeekButton.enabled = YES;
    self.forwardSeekButton.enabled = YES;
    self.slomoButton.enabled = YES;
    self.liveButton.hidden = NO;
    self.topPlayerView.enabled = YES;
    self.bottomPlayerView.enabled = YES;
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

#pragma mark - Fullscreen Methods

- (void)setTopFullscreen:(BOOL)fullscreen animated:(BOOL)animated {
    if (fullscreen && !self.fullscreenView) {
        self.fullscreenView = self.topPlayerView;
        self.fullscreenInitialRect = self.topPlayerView.frame;
        
        if (animated) {
            [UIView animateWithDuration:ANIMATION_DURATION
                             animations:^() {
                                 self.topPlayerView.frame = CGRectMake(0, 55, 1024, 768 - 55 - BOTTOM_BAR_HEIGHT);
                                 self.bottomPlayerView.alpha = 0.0;
                                 self.view.backgroundColor = [UIColor blackColor];
                             }
                             completion:^(BOOL finished) {
                                 self.topPlayerView.showsControlBar = YES;
                                 self.bottomPlayerView.hidden = YES;
                             }];
        } else {
            self.topPlayerView.frame = CGRectMake(0, 55, 1024, 768 - 55 - BOTTOM_BAR_HEIGHT);
            self.topPlayerView.showsControlBar = YES;
            self.bottomPlayerView.alpha = 0.0;
            self.bottomPlayerView.hidden = YES;
            self.view.backgroundColor = [UIColor blackColor];
        }
    } else if (!fullscreen && self.fullscreenView == self.topPlayerView) {
        
        self.fullscreenView = nil;
        
        self.topPlayerView.showsControlBar = NO;
        self.bottomPlayerView.hidden = NO;
        
        if (animated) {
            
            [UIView animateWithDuration:ANIMATION_DURATION
                             animations:^() {
                                 self.topPlayerView.frame = self.fullscreenInitialRect;
                                 self.bottomPlayerView.alpha = 1.0;
                                 self.view.backgroundColor = [UIColor whiteColor];
                             }
                             completion:^(BOOL finished) {
                                 
                             }];
        } else {
            self.bottomPlayerView.alpha = 1.0;
            self.topPlayerView.frame = self.fullscreenInitialRect;
            self.view.backgroundColor = [UIColor whiteColor];
        }
    }
}

- (void)setBottomFullscreen:(BOOL)fullscreen animated:(BOOL)animated {
    if (fullscreen && !self.fullscreenView) {
        self.fullscreenView = self.bottomPlayerView;
        self.fullscreenInitialRect = self.bottomPlayerView.frame;
        
        if (animated) {
            [UIView animateWithDuration:ANIMATION_DURATION
                             animations:^() {
                                 self.bottomPlayerView.frame = CGRectMake(0, 55, 1024, 768 - 55 - BOTTOM_BAR_HEIGHT);
                                 self.topPlayerView.alpha = 0.0;
                                 self.view.backgroundColor = [UIColor blackColor];
                             }
                             completion:^(BOOL finished) {
                                 self.topPlayerView.hidden = YES;
                             }];
        } else {
            self.bottomPlayerView.frame = CGRectMake(0, 55, 1024, 768 - 55 - BOTTOM_BAR_HEIGHT);
            self.bottomPlayerView.showsControlBar = YES;
            self.topPlayerView.alpha = 0.0;
            self.topPlayerView.hidden = YES;
            self.view.backgroundColor = [UIColor blackColor];
        }
    } else if (!fullscreen && self.fullscreenView == self.bottomPlayerView) {
        
        self.fullscreenView = nil;
        
        self.topPlayerView.hidden = NO;
        
        if (animated) {
            
            [UIView animateWithDuration:ANIMATION_DURATION
                             animations:^() {
                                 self.bottomPlayerView.frame = self.fullscreenInitialRect;
                                 self.topPlayerView.alpha = 1.0;
                                 self.view.backgroundColor = [UIColor whiteColor];
                             }
                             completion:^(BOOL finished) {
                                 
                             }];
        } else {
            self.bottomPlayerView.frame = self.fullscreenInitialRect;
            self.topPlayerView.alpha = 1.0;
            self.view.backgroundColor = [UIColor whiteColor];
        }
    }
}

#pragma mark - Gesture Recognizers

- (void)topFullscreen:(UIPinchGestureRecognizer *)recognizer {
    if (recognizer.velocity > PINCH_VELOCITY) {
        [self setTopFullscreen:YES animated:YES];
    } else if (recognizer.velocity < -PINCH_VELOCITY) {
        [self setTopFullscreen:NO animated:YES];
    }
}

- (void)bottomFullscreen:(UIPinchGestureRecognizer *)recognizer {
    if (recognizer.velocity > PINCH_VELOCITY) {
        [self setBottomFullscreen:YES animated:YES];
    } else if (recognizer.velocity < -PINCH_VELOCITY) {
        [self setBottomFullscreen:NO animated:YES];
    }
}

#pragma mark - Actions

- (void)liveButtonPressed:(LiveButton *)sender {
    
    // invalidate the loop range
    self.mainPlayer.loopRange = kCMTimeRangeInvalid;
    
    // seek a bit before
    CMTime time = CMTimeSubtract(self.mainPlayer.duration, CMTimeMake(1, 1));
    
    if (CMTIME_IS_NUMERIC(time)) {
        [self.mainPlayer pause];
        [self.mainPlayer seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL complete) {
            [self.mainPlayer prerollAndPlayAtRate:1.0];
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
    
    self.backSeekButton.enabled = NO;
    self.forwardSeekButton.enabled = NO;
    self.slomoButton.enabled = NO;
    self.liveButton.hidden = YES;
    self.topPlayerView.enabled = NO;
    self.bottomPlayerView.enabled = NO;
    [self.periodTableViewController setHidden:YES animated:YES];
}

- (void)recordingDidFinishInRecordButton:(nonnull NCRecordButton *)recordButton withDuration:(NSTimeInterval)duration {
    self.recording = NO;
    
    self.backSeekButton.enabled = YES;
    self.forwardSeekButton.enabled = YES;
    self.slomoButton.enabled = YES;
    self.liveButton.hidden = NO;
    self.topPlayerView.enabled = YES;
    self.bottomPlayerView.enabled = YES;
    [self.periodTableViewController setHidden:NO animated:YES];
    
    NSTimeInterval clipDuration = CMTimeGetSeconds(self.mainPlayer.currentTime) - self.startTime;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_TAG_POSTED
                                                        object:nil
                                                      userInfo:@{ @"name": self.activeTagName,
                                                                  @"time": [NSString stringWithFormat:@"%f", self.startTime],
                                                                  @"duration": [NSString stringWithFormat:@"%d", (int) ceil(clipDuration)]
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
