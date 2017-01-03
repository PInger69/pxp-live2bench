//
//  TabsSettingViewController.h
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-05-07.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "ToggleSettingViewController.h"

#define NOTIF_TABS_SETTING_CHANGED @"TabsSettingChanged"

@interface TabsSettingViewController : ToggleSettingViewController

- (nonnull instancetype)initWithAppDelegate:(nonnull AppDelegate *)appDel;

@end
