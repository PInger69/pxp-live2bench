//
//  AlertsSettingViewController.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-05-07.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "AlertsSettingViewController.h"

@interface AlertsSettingViewController () <ToggleSettingViewControllerDelegate>

@end

@implementation AlertsSettingViewController

- (nonnull instancetype)initWithAppDelegate:(nonnull AppDelegate *)appDel {
    self = [super initWithAppDelegate:appDel
                                 name:NSLocalizedString(@"Alerts", nil)
                           identifier:@"Alerts"
                              toggles:@[
                                        @{
                                            @"Name": NSLocalizedString(@"Notification Alerts", nil),
                                            @"Identifier": ALERT_NOTIFICATION
                                            },
                                        @{
                                            @"Name": NSLocalizedString(@"Encoder Alerts", nil),
                                            @"Identifier": ALERT_ENCODER
                                            },
                                        @{
                                            @"Name": NSLocalizedString(@"Device Alerts", nil),
                                            @"Identifier": ALERT_DEVICE
                                            },
                                        @{
                                            @"Name": NSLocalizedString(@"Indecisive Alerts", nil),
                                            @"Identifier": ALERT_INDECISIVE
                                            }
                                        ]];
    
    if (self) {
        // default settings
        self.settingData[ALERT_NOTIFICATION] = @YES;
        self.settingData[ALERT_ENCODER] = @YES;
        self.settingData[ALERT_DEVICE] = @YES;
        self.settingData[ALERT_INDECISIVE] = @YES;
        
        self.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestSettings:) name:NOTIF_REQUEST_SETTINGS object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_REQUEST_SETTINGS object:nil];
}
         
- (void)requestSettings:(NSNotification *)note {
    if ([self isKindOfClass:note.userInfo[@"Class"]]) {
        void(^block)(NSDictionary *) = note.userInfo[@"Block"];
        
        block(self.settingData);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)toggleStateDidChangeWithIdentifier:(nonnull NSString *)identifier state:(BOOL)on {
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_ALERTS_SETTING_CHANGED object:nil userInfo:self.settingData];
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
