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

#define BOTTOM_BAR_HEIGHT 70
#define PLAYHEAD_HEIGHT 44
#define PINCH_VELOCITY 1

@interface FBTrainingTabViewController () <NCRecordButtonDelegate, FeedSelectionControllerDelegate, FBTrainingTagControllerDelegate>

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
@property (strong, nonatomic, nonnull) FeedSelectionController *pipFeedSelectionController;
@property (strong, nonatomic, nonnull) FeedSelectionController *playerFeedSelectionController;

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
        self.pipFeedSelectionController = [[FeedSelectionController alloc] initWithFeeds:self.feeds];
        self.playerFeedSelectionController = [[FeedSelectionController alloc] initWithFeeds:self.feeds];
        
        self.pipFeedSelectionController.delegate = self;
        self.playerFeedSelectionController.delegate = self;
        
        [self addChildViewController:self.pipFeedSelectionController];
        [self addChildViewController:self.playerFeedSelectionController];
        
        self.pipToFullscreenRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pipToFullscreen:)];
        self.playerToFullscreenRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(playerToFullscreen:)];
        self.exitFullscreenRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(exitFullscreen:)];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sideTagsReady:) name:NOTIF_SIDE_TAGS_READY_FOR_L2B object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tagsReady:) name:NOTIF_TAGS_ARE_READY object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tagReceived:) name:NOTIF_TAG_RECEIVED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(feedsReady:) name:NOTIF_EVENT_FEEDS_READY object:nil];
        
        
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
    [self.view addSubview:pipContainer];
    [self.view addSubview:playerContainer];
    
    [self.view addSubview:self.fullscreenPlayer.view];
    
    [self.view addSubview:self.periodTableViewController.view];
    
    [self.view addSubview:self.forwardSeekButton];
    [self.view addSubview:self.backSeekButton];
    
    self.pipFeedSelectionController.view.frame = CGRectMake(pipContainer.frame.size.width - 128, 0, 128, pipContainer.frame.size.height);
    self.playerFeedSelectionController.view.frame = CGRectMake(playerContainer.frame.size.width - 128, 0, 128, playerContainer.frame.size.height - PLAYHEAD_HEIGHT);
    
    [pipContainer addSubview:self.pipFeedSelectionController.view];
    [playerContainer addSubview:self.playerFeedSelectionController.view];
    
    [self.pipView addGestureRecognizer:self.pipToFullscreenRecognizer];
    [self.splitPlayer.view addGestureRecognizer:self.playerToFullscreenRecognizer];
    [self.fullscreenPlayer.view addGestureRecognizer:self.exitFullscreenRecognizer];
    
    self.pipView.muted = YES;
    self.fullscreenPlayer.mute = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    Event *event = [_appDel.encoderManager.primaryEncoder event];
    
    self.feeds = [[NSMutableArray arrayWithArray:[event.feeds allValues]] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sourceName" ascending:YES]]];
    self.pipFeedSelectionController.feeds = self.feeds;
    self.playerFeedSelectionController.feeds = self.feeds;
    
    [self setFullscreen:NO animated:NO rect:CGRectZero];
    
    [self.splitPlayer playFeed:self.feeds.count > 0 ? self.feeds[0] : nil];
    [self.pipView playWithFeed:self.feeds.count > 1 ? self.feeds[1] : self.splitPlayer.feed];
    [self.pipViewController syncToPlayer];
    
    self.splitPlayer.mute = NO;
    
    [self.liveButton isActive:event.live];
    [self.splitPlayer gotolive];
    
    // tell other players to STFU and hope they will
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_COMMAND_VIDEO_PLAYER object:nil userInfo:@{ @"command":[NSNumber numberWithInt:VideoPlayerCommandMute]}];
}

- (void)viewWillDisappear:(BOOL)animated {
    // we're nice and mute when no one is listening
    self.currentPlayer.mute = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sideTagsReady:(NSNotification *)note {
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
        
        self.fullscreenPlayer.view.frame = rect;
        self.fullscreenPlayer.view.hidden = NO;
        self.splitPlayer.mute = YES;
        self.fullscreenPlayer.mute = NO;
        
        if (animated) {
            
            [UIView animateWithDuration:1.0
                             animations:^() {
                                 self.fullscreenPlayer.view.frame = CGRectMake(0, 55, 1024, 768 - 55 - BOTTOM_BAR_HEIGHT);
                             }
                             completion:^(BOOL finished) {
                                 self.pipView.hidden = YES;
                                 self.splitPlayer.view.hidden = YES;
                             }];
        } else {
            self.fullscreenPlayer.view.frame = CGRectMake(0, 55, 1024, 768 - 55 - BOTTOM_BAR_HEIGHT);
            self.pipView.hidden = YES;
            self.splitPlayer.view.hidden = YES;
        }
        
        self.currentPlayer = self.fullscreenPlayer;
        self.isFullscreen = YES;
        
    } else if (!fullscreen && self.isFullscreen) {
        
        self.pipView.hidden = NO;
        self.splitPlayer.view.hidden = NO;
        self.splitPlayer.mute = NO;
        self.fullscreenPlayer.mute = YES;
        
        if (animated) {
            
            [UIView animateWithDuration:1.0
                             animations:^() {
                                 self.fullscreenPlayer.view.frame = rect;
                             }
                             completion:^(BOOL finished) {
                                 self.fullscreenPlayer.view.hidden = YES;
                             }];
        } else {
            self.fullscreenPlayer.view.frame = rect;
            self.fullscreenPlayer.view.hidden = YES;
        }
        
        self.currentPlayer = self.splitPlayer;
        self.isFullscreen = NO;
    }
    
    
}

#pragma mark - Gesture Recognizers

- (void)pipToFullscreen:(UIPinchGestureRecognizer *)recognizer {
    if (recognizer.velocity > PINCH_VELOCITY) {
        [self.fullscreenPlayer playFeed:self.pipView.feed];
        [self.fullscreenPlayer seekToInSec:self.splitPlayer.currentTimeInSeconds];
        
        self.fullscreenInitialRect = [self.view convertRect:self.pipView.bounds fromView:self.pipView];
        [self setFullscreen:YES animated:YES rect:self.fullscreenInitialRect];

    }
}

- (void)playerToFullscreen:(UIPinchGestureRecognizer *)recognizer {
    if (recognizer.velocity > PINCH_VELOCITY) {
        [self.fullscreenPlayer playFeed:self.splitPlayer.feed];
        [self.fullscreenPlayer seekToInSec:self.splitPlayer.currentTimeInSeconds];
        
        self.fullscreenInitialRect = [self.view convertRect:self.splitPlayer.view.bounds fromView:self.splitPlayer.view];
        [self setFullscreen:YES animated:YES rect:self.fullscreenInitialRect];
    }
}

- (void)exitFullscreen:(UIPinchGestureRecognizer *)recognizer {
    if (recognizer.velocity < -PINCH_VELOCITY) {
        [self.splitPlayer seekToInSec:self.fullscreenPlayer.currentTimeInSeconds];
        [self setFullscreen:NO animated:YES rect:self.fullscreenInitialRect];
    }
}

#pragma mark - Actions

- (void)liveButtonPressed:(LiveButton *)sender {
    [self.currentPlayer gotolive];
}

- (void)seekPressed:(SeekButton *)sender {
    [self.currentPlayer seekBy:sender.speed];
}

- (void)slomoPressed:(Slomo *)slomo {
    slomo.slomoOn = !slomo.slomoOn;
    self.currentPlayer.slowmo = slomo.slomoOn;
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
    [self.currentPlayer playClipWithFeed:self.currentPlayer.feed andTimeRange:range];
}

#pragma mark - FeedSelectionControllerDelegate

- (void)feedSelectionController:(nonnull FeedSelectionController *)feedSelectionController didSelectFeed:(nonnull Feed *)feed {
    if (feedSelectionController == self.pipFeedSelectionController) {
        [self.pipView playWithFeed:feed];
    } else if (feedSelectionController == self.playerFeedSelectionController) {
        [self.splitPlayer playFeed:feed];
    }
    
    [feedSelectionController dismiss:YES];
}

#pragma mark - NCRecordButtonDelegate

- (void)recordingDidStartInRecordButton:(nonnull NCRecordButton *)recordButton {
    self.recording = YES;
    self.startTime = self.currentPlayer.currentTimeInSeconds;
}

- (void)recordingDidFinishInRecordButton:(nonnull NCRecordButton *)recordButton withDuration:(NSTimeInterval)duration {
    self.recording = NO;
    
    NSTimeInterval clipDuration = self.currentPlayer.currentTimeInSeconds - self.startTime;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_TAG_POSTED
                                                        object:nil
                                                      userInfo:@{ @"name": self.activeTagName,
                                                                  @"time": [NSString stringWithFormat:@"%f", self.startTime],
                                                                  @"duration": [NSString stringWithFormat:@"%d", (int) ceil(clipDuration) + 10]
                                                                  }];
}

- (void)recordingTimeDidUpdateInRecordButton:(nonnull NCRecordButton *)recordButton {
    
    if (self.recording) {
        NSTimeInterval clipDuration = self.currentPlayer.currentTimeInSeconds - self.startTime;
        
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
    if (second >= 60 && second < 3600) {
        minute = second / 60;
        second = second % 60;
    } else if (second >= 3600){
        hour = second / 3600;
        minute = second % 3600 / 60;
        second = minute % 60;
    }
    
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
