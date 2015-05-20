//
//  FBTrainingTabViewController.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-05-19.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "FBTrainingTabViewController.h"

#import "FBTrainingPeriodTableViewController.h"

@interface FBTrainingTabViewController ()

@property (strong, nonatomic, nonnull) FBTrainingPeriodTableViewController *periodTableViewController;

@end

@implementation FBTrainingTabViewController

- (id)initWithAppDelegate:(AppDelegate *)appDel {
    self = [super initWithAppDelegate:appDel];
    if (self) {
        [self setMainSectionTab:NSLocalizedString(@"FBTraining", nil) imageName:@"FBTraining"];
        
        self.periodTableViewController = [[FBTrainingPeriodTableViewController alloc] init];
        [self addChildViewController:self.periodTableViewController];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = PRIMARY_APP_COLOR;
    [self.view addSubview:self.periodTableViewController.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
