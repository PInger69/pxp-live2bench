//
//  AlertsSettingViewController.h
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-05-07.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "ToggleSettingViewController.h"

#define NOTIF_ALERTS_SETTING_CHANGED @"AlertsSettingChanged"

// Alert Identifiers
#define ALERT_NOTIFICATION @"Notification"
#define ALERT_ENCODER @"Encoder"
#define ALERT_DEVICE @"Device"
#define ALERT_INDECISIVE @"Indecisive"

@interface AlertsSettingViewController : ToggleSettingViewController

- (nonnull instancetype)initWithAppDelegate:(nonnull AppDelegate *)appDel;

@end
