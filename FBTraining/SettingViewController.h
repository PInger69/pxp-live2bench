//
//  SettingViewController.h
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-05-06.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "UserCenter.h"
#import "EncoderManager.h"
#import "SwipeableTableViewCell.h"

@interface SettingViewController: UITableViewController<UITableViewDelegate, UITableViewDataSource>

// the display name under settings
@property (readonly, nonatomic, nonnull) NSString *name;
// the plist settings identifier
@property (readonly, nonatomic, nonnull) NSString *identifier;
// the data loaded fromt the plist
@property (readonly, nonatomic, nonnull) NSMutableDictionary *settingData;

@property (strong, nonatomic, nonnull) UserCenter *userCenter;
@property (strong, nonatomic, nonnull) EncoderManager *encoderManager;

- (nonnull instancetype)initWithAppDelegate:(nonnull AppDelegate *)appDel name:(nonnull NSString *)name identifier:(nonnull NSString *)identifier;
- (void)refresh;

@end
