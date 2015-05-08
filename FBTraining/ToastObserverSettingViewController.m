//
//  ToastObserverSettingViewController.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-05-06.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "ToastObserverSettingViewController.h"

@interface ToastObserverSettingViewController () <ToggleSettingViewControllerDelegate>

@end

@implementation ToastObserverSettingViewController

- (nonnull instancetype)initWithAppDelegate:(nonnull AppDelegate *)appDel {
    self = [super initWithAppDelegate:appDel
                                 name:NSLocalizedString(@"Toast Observer", nil)
                           identifier:@"ToastObserver"
                              toggles:@[
                                        @{
                                            @"Name": NSLocalizedString(@"Download Complete", nil),
                                            @"Identifier": TOAST_DOWNLOAD_COMPLETE
                                            },
                                        @{
                                            @"Name": NSLocalizedString(@"Tag Synchronized", nil),
                                            @"Identifier": TOAST_TAG_SYNCHRONIZED
                                            },
                                        @{
                                            @"Name": NSLocalizedString(@"Tag Received", nil),
                                            @"Identifier": TOAST_TAG_RECEIVED
                                            }
                                        ]];
    
    if (self) {
        // Default Settings with corresponding toggle identifiers
        self.settingData[TOAST_DOWNLOAD_COMPLETE] = @YES;
        self.settingData[TOAST_TAG_SYNCHRONIZED] = @YES;
        self.settingData[TOAST_TAG_RECEIVED] = @YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestSettings:) name:NOTIF_REQUEST_SETTINGS object:nil];
        self.delegate = self;
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

- (void)toggleStateDidChangeWithIdentifier:(NSString *)identifier state:(BOOL)on {
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_TOAST_SETTING_CHANGED object:nil userInfo:self.settingData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
