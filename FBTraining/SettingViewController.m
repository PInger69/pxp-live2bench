//
//  SettingViewController.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-05-06.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

@synthesize name = _name;
@synthesize identifier = _identifier;
@synthesize settingData = _settingData;

- (instancetype)initWithAppDelegate:(nonnull AppDelegate *)appDel name:(nonnull NSString *)name identifier:(nonnull NSString *)identifier {
    self = [super init];
    if (self) {
        self.view.frame = CGRectMake(0, 0, 705, 715);
        self.userCenter = appDel.userCenter;
        self.encoderManager = appDel.encoderManager;
        
        _name = name;
        _identifier = identifier;
        _settingData = [NSMutableDictionary dictionary];
        
        
        
    }
    return self;
}

- (void)refresh {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    PXPLog(@"*** didReceiveMemoryWarning ***");
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
