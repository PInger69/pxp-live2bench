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

#define BOTTOM_BAR_HEIGHT 75
#define PLAYHEAD_HEIGHT 44

@interface FBTrainingTabViewController () <NCRecordButtonDelegate, FeedSelectionControllerDelegate>

@property (strong, nonatomic, nonnull) FBTrainingPeriodTableViewController *periodTableViewController;
@property (strong, nonatomic, nonnull) RJLVideoPlayer *mainPlayer;
@property (strong, nonatomic, nonnull) PipViewController *pipViewController;

@property (strong, nonatomic, nonnull) UIView *bottomBarView;
@property (strong, nonatomic, nonnull) Pip *pipView;
@property (strong, nonatomic, nonnull) NCRecordButton *recordButton;
@property (strong, nonatomic, nonnull) UILabel *timeLabel;

@property (strong, nonatomic, nonnull) NSArray *feeds;
@property (strong, nonatomic, nonnull) FeedSelectionController *pipFeedSelectionController;
@property (strong, nonatomic, nonnull) FeedSelectionController *playerFeedSelectionController;

@end

@implementation FBTrainingTabViewController

- (instancetype)initWithAppDelegate:(AppDelegate *)appDel {
    self = [super initWithAppDelegate:appDel];
    if (self) {
        [self setMainSectionTab:NSLocalizedString(@"FBTraining", nil) imageName:@"FBTraining"];
        
        self.periodTableViewController = [[FBTrainingPeriodTableViewController alloc] init];
        
        self.bottomBarView = [[UIView alloc] init];
        
        self.recordButton = [[NCRecordButton alloc] init];
        self.timeLabel = [[UILabel alloc] init];
        
        CGFloat playerHeight = (768 - 55 - BOTTOM_BAR_HEIGHT) / 2.0;
        GLfloat playerWidth = playerHeight * (16.0 / 9.0);
        
        self.mainPlayer = [[RJLVideoPlayer alloc] initWithFrame:CGRectMake(0, 0, playerWidth, playerHeight)];
        self.mainPlayer.zoomManager = nil;
        
        self.pipView = [[Pip alloc] initWithFrame:CGRectMake(0, 0, playerWidth, playerHeight)];
        self.pipView.layer.borderWidth = 0.0;
        
        self.pipViewController = [[PipViewController alloc] initWithVideoPlayer:self.mainPlayer f:nil encoderManager:_appDel.encoderManager];
        self.pipViewController.swapsOnSingleTap = NO;
        
        [self addChildViewController:self.periodTableViewController];
        [self addChildViewController:self.mainPlayer];
        [self addChildViewController:self.pipViewController];
        
        self.feeds = @[];
        self.pipFeedSelectionController = [[FeedSelectionController alloc] initWithFeeds:self.feeds];
        self.playerFeedSelectionController = [[FeedSelectionController alloc] initWithFeeds:self.feeds];
        
        self.pipFeedSelectionController.delegate = self;
        self.playerFeedSelectionController.delegate = self;
        
        [self addChildViewController:self.pipFeedSelectionController];
        [self addChildViewController:self.playerFeedSelectionController];
        
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
    UIView *playerContainer = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - self.mainPlayer.view.frame.size.width, 55 + pipContainer.frame.size.height, self.mainPlayer.view.frame.size.width, self.mainPlayer.view.frame.size.height)];
    
    self.periodTableViewController.view.frame = CGRectMake(0, 55, self.view.bounds.size.width, self.view.bounds.size.height - 55 - BOTTOM_BAR_HEIGHT);
    [self.view addSubview:self.periodTableViewController.view];
    
    self.bottomBarView.frame = CGRectMake(0, self.view.bounds.size.height - BOTTOM_BAR_HEIGHT, self.view.bounds.size.width, BOTTOM_BAR_HEIGHT);
    self.bottomBarView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.bottomBarView];
    
    self.recordButton.frame = CGRectMake(self.bottomBarView.bounds.size.width - self.bottomBarView.bounds.size.height, 0, self.bottomBarView.bounds.size.height, self.bottomBarView.bounds.size.height);
    self.recordButton.displaysTime = NO;
    self.recordButton.delegate = self;
    [self.bottomBarView addSubview:self.recordButton];
    
    self.timeLabel.frame = CGRectMake(self.bottomBarView.center.x - 150, 0, 300, self.bottomBarView.bounds.size.height);
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.font = [UIFont systemFontOfSize:64];
    self.timeLabel.text = @"00:00:00";
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    [self.bottomBarView addSubview:self.timeLabel];
    
    [self.pipViewController addPip:self.pipView];
    
    [pipContainer addSubview:self.pipView];
    [playerContainer addSubview:self.mainPlayer.view];
    
    [self.view addSubview:pipContainer];
    [self.view addSubview:playerContainer];
    
    self.pipFeedSelectionController.view.frame = CGRectMake(pipContainer.frame.size.width - 128, 0, 128, pipContainer.frame.size.height);
    self.playerFeedSelectionController.view.frame = CGRectMake(playerContainer.frame.size.width - 128, 0, 128, playerContainer.frame.size.height - PLAYHEAD_HEIGHT);
    
    [pipContainer addSubview:self.pipFeedSelectionController.view];
    [playerContainer addSubview:self.playerFeedSelectionController.view];
}

- (void)viewDidAppear:(BOOL)animated {
    self.feeds = [[NSMutableArray arrayWithArray:[[_appDel.encoderManager.primaryEncoder event].feeds allValues]] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sourceName" ascending:YES]]];
    self.pipFeedSelectionController.feeds = self.feeds;
    self.playerFeedSelectionController.feeds = self.feeds;
    
    [self.mainPlayer playFeed:self.feeds.count > 0 ? self.feeds[0] : nil];
    [self.pipView playWithFeed:self.feeds.count > 1 ? self.feeds[1] : nil];
    [self.pipViewController syncToPlayer];
    
    self.mainPlayer.mute = YES;
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
    
    for (NSUInteger i = 0; i < 64; i++) {
        NSString *name = tagNames[(NSUInteger)(drand48() * (tagNames.count))];
        if (![name isEqualToString:@"--"]) {
            Tag *tag = [[Tag alloc] init];
            tag.time = drand48();
            tag.name = name;
            
            [self.periodTableViewController addTag:tag];
        }
    }
    
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

#pragma mark - FeedSelectionControllerDelegate

- (void)feedSelectionController:(nonnull FeedSelectionController *)feedSelectionController didSelectFeed:(nonnull Feed *)feed {
    if (feedSelectionController == self.pipFeedSelectionController) {
        [self.pipView playWithFeed:feed];
    } else if (feedSelectionController == self.playerFeedSelectionController) {
        [self.mainPlayer playFeed:feed];
    }
    
    [feedSelectionController dismiss:YES];
}

#pragma mark - NCRecordButtonDelegate

- (void)recordingDidStartInRecordButton:(nonnull NCRecordButton *)recordButton {
    
}

- (void)recordingDidFinishInRecordButton:(nonnull NCRecordButton *)recordButton withDuration:(NSTimeInterval)duration {
    
}

- (void)recordingTimeDidUpdateInRecordButton:(nonnull NCRecordButton *)recordButton {
    self.timeLabel.text = recordButton.recordingTimeString;
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
