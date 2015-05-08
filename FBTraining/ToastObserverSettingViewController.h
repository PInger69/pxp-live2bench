//
//  ToastObserverSettingViewController.h
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-05-06.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "ToggleSettingViewController.h"

#define NOTIF_TOAST_SETTING_CHANGED @"ToastSettingChanged"

// Toast Observer identifiers
#define TOAST_DOWNLOAD_COMPLETE @"DownloadComplete"
#define TOAST_TAG_SYNCHRONIZED @"TagSynchronized"
#define TOAST_TAG_RECEIVED @"TagReceived"

@interface ToastObserverSettingViewController : ToggleSettingViewController

- (nonnull instancetype)initWithAppDelegate:(nonnull AppDelegate *)appDel;

@end
