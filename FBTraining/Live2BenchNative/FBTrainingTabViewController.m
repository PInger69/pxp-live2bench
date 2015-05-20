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

@interface FBTrainingTabViewController () <NCRecordButtonDelegate>

@property (strong, nonatomic, nonnull) FBTrainingPeriodTableViewController *periodTableViewController;
@property (strong, nonatomic, nonnull) UIView *bottomBarView;
@property (strong, nonatomic, nonnull) NCRecordButton *recordButton;
@property (strong, nonatomic, nonnull) UILabel *timeLabel;

@end

@implementation FBTrainingTabViewController

- (id)initWithAppDelegate:(AppDelegate *)appDel {
    self = [super initWithAppDelegate:appDel];
    if (self) {
        [self setMainSectionTab:NSLocalizedString(@"FBTraining", nil) imageName:@"FBTraining"];
        
        self.periodTableViewController = [[FBTrainingPeriodTableViewController alloc] init];
        [self addChildViewController:self.periodTableViewController];
        
        self.bottomBarView = [[UIView alloc] init];
        
        self.recordButton = [[NCRecordButton alloc] init];
        self.timeLabel = [[UILabel alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = PRIMARY_APP_COLOR;
    
    self.periodTableViewController.view.frame = CGRectMake(0, 55, self.view.bounds.size.width, self.view.bounds.size.height - 55 - 75);
    [self.view addSubview:self.periodTableViewController.view];
    
    self.bottomBarView.frame = CGRectMake(0, self.view.bounds.size.height - 75, self.view.bounds.size.width, 75);
    self.bottomBarView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.bottomBarView];
    
    self.recordButton.frame = CGRectMake(0, 0, self.bottomBarView.bounds.size.height, self.bottomBarView.bounds.size.height);
    self.recordButton.displaysTime = NO;
    self.recordButton.delegate = self;
    [self.bottomBarView addSubview:self.recordButton];
    
    self.timeLabel.frame = CGRectMake(self.recordButton.frame.size.width + 25, 0, 400, self.bottomBarView.bounds.size.height);
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.font = [UIFont systemFontOfSize:64];
    self.timeLabel.text = @"00:00:00";
    [self.bottomBarView addSubview:self.timeLabel];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
