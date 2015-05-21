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
#import "EncoderClasses/EncoderManager.h"
#import "RJLVideoPlayer.h"

#define BOTTOM_BAR_HEIGHT 75

@interface FBTrainingTabViewController () <NCRecordButtonDelegate>

@property (strong, nonatomic, nonnull) FBTrainingPeriodTableViewController *periodTableViewController;
@property (strong, nonatomic, nonnull) RJLVideoPlayer *player1;
@property (strong, nonatomic, nonnull) RJLVideoPlayer *player2;

@property (strong, nonatomic, nonnull) UIView *bottomBarView;
@property (strong, nonatomic, nonnull) NCRecordButton *recordButton;
@property (strong, nonatomic, nonnull) UILabel *timeLabel;

@end

@implementation FBTrainingTabViewController

- (instancetype)initWithAppDelegate:(AppDelegate *)appDel {
    self = [super initWithAppDelegate:appDel];
    if (self) {
        [self setMainSectionTab:NSLocalizedString(@"FBTraining", nil) imageName:@"FBTraining"];
        
        self.periodTableViewController = [[FBTrainingPeriodTableViewController alloc] init];
        [self addChildViewController:self.periodTableViewController];
        
        self.bottomBarView = [[UIView alloc] init];
        
        self.recordButton = [[NCRecordButton alloc] init];
        self.timeLabel = [[UILabel alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sideTagsReady:) name:NOTIF_SIDE_TAGS_READY_FOR_L2B object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tagsReady:) name:NOTIF_TAGS_ARE_READY object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(tagReceived:) name:NOTIF_TAG_RECEIVED object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_SIDE_TAGS_READY_FOR_L2B object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_TAGS_ARE_READY object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_TAG_RECEIVED object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.periodTableViewController.view.frame = CGRectMake(0, 55, self.view.bounds.size.width, self.view.bounds.size.height - 55 - BOTTOM_BAR_HEIGHT);
    [self.view addSubview:self.periodTableViewController.view];
    
    self.bottomBarView.frame = CGRectMake(0, self.view.bounds.size.height - BOTTOM_BAR_HEIGHT, self.view.bounds.size.width, BOTTOM_BAR_HEIGHT);
    self.bottomBarView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.bottomBarView];
    
    self.recordButton.frame = CGRectMake(self.bottomBarView.bounds.size.width - self.bottomBarView.bounds.size.height, 0, self.bottomBarView.bounds.size.height, self.bottomBarView.bounds.size.height);
    self.recordButton.displaysTime = NO;
    self.recordButton.delegate = self;
    [self.bottomBarView addSubview:self.recordButton];
    
    self.timeLabel.frame = CGRectMake(self.recordButton.frame.origin.x - 325, 0, 300, self.bottomBarView.bounds.size.height);
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.font = [UIFont systemFontOfSize:64];
    self.timeLabel.text = @"00:00:00";
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    [self.bottomBarView addSubview:self.timeLabel];
    
    CGFloat playerHeight = (self.view.frame.size.height - 55 - BOTTOM_BAR_HEIGHT) / 2.0;
    GLfloat playerWidth = playerHeight * (16.0 / 9.0);
    
    self.player1 = [[RJLVideoPlayer alloc] initWithFrame:CGRectMake(self.view.frame.size.width - playerWidth, 55, playerWidth, playerHeight)];
    self.player2 = [[RJLVideoPlayer alloc] initWithFrame:CGRectMake(self.view.frame.size.width - playerWidth, 55 + playerHeight, playerWidth, playerHeight)];
    
    [self addChildViewController:self.player1];
    [self addChildViewController:self.player2];
    
    [self.view addSubview:self.player1.view];
    [self.view addSubview:self.player2.view];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sideTagsReady:(NSNotification *)note {
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
        Tag *tag = [[Tag alloc] init];
        tag.time = drand48();
        tag.name = name;
        
        [self.periodTableViewController addTag:tag];
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
