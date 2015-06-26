//
//  TabsSettingViewController.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-05-07.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "TabsSettingViewController.h"

#import "CalendarViewController.h"
#import "InjuryViewController.h"
#import "Live2BenchViewController.h"
#import "ClipViewController.h"
#import "ListViewController.h"
#import "BookmarkViewController.h"
#import "DebuggingTabViewController.h"
#import "FBTrainingTabViewController.h"

// Tab setting identifiers
#define TAB_CALENDAR @"Calendar"
#define TAB_INJURY @"Injury"
#define TAB_LIVE2BENCH @"Live2Bench"
#define TAB_CLIPVIEW @"ClipView"
#define TAB_LISTVIEW @"ListView"
#define TAB_MYCLIP @"MyClip"
#define TAB_FOOTBALL_TRAINING @"FBTraining"
#define TAB_DEBUG @"Debug"

@interface TabsSettingViewController () <ToggleSettingViewControllerDelegate>

@property (strong, nonatomic, nonnull) NSDictionary *tabClassForIdentifier;

@end

@implementation TabsSettingViewController

- (nonnull instancetype)initWithAppDelegate:(nonnull AppDelegate *)appDel {
    self = [super initWithAppDelegate:appDel
                                 name:NSLocalizedString(@"Tabs", nil)
                           identifier:@"Tabs"
                              toggles:@[
                                        @{
                                            @"Name": NSLocalizedString(@"Calendar", nil),
                                            @"Identifier": TAB_CALENDAR
                                            },
                                        @{
                                            @"Name": NSLocalizedString(@"Injury", nil),
                                            @"Identifier": TAB_INJURY
                                            },
                                        @{
                                            @"Name": NSLocalizedString(@"Dual View", nil),
                                            @"Identifier": TAB_FOOTBALL_TRAINING
                                            },
                                        @{
                                            @"Name": NSLocalizedString(@"Live2Bench", nil),
                                            @"Identifier": TAB_LIVE2BENCH
                                            },
                                        @{
                                            @"Name": NSLocalizedString(@"Clip View", nil),
                                            @"Identifier": TAB_CLIPVIEW
                                            },
                                        @{
                                            @"Name": NSLocalizedString(@"List View", nil),
                                            @"Identifier": TAB_LISTVIEW
                                            },
                                        @{
                                            @"Name": NSLocalizedString(@"My Clip", nil),
                                            @"Identifier": TAB_MYCLIP
                                            },
#if DEBUG_MODE == 1
                                        @{
                                            @"Name": NSLocalizedString(@"Debug", nil),
                                            @"Identifier": TAB_DEBUG
                                            }
#endif
                                        ]];
    if (self) {
        self.settingData[TAB_CALENDAR] = @YES;
        self.settingData[TAB_INJURY] = @NO;
        self.settingData[TAB_LIVE2BENCH] = @YES;
        self.settingData[TAB_CLIPVIEW] = @YES;
        self.settingData[TAB_LISTVIEW] = @YES;
        self.settingData[TAB_MYCLIP] = @YES;
        self.settingData[TAB_DEBUG] = @NO;
        self.settingData[TAB_FOOTBALL_TRAINING] = @YES;
        
        self.tabClassForIdentifier = @{
                                       TAB_CALENDAR: [CalendarViewController class],
                                       TAB_INJURY: [InjuryViewController class],
                                       TAB_LIVE2BENCH: [Live2BenchViewController class],
                                       TAB_CLIPVIEW: [ClipViewController class],
                                       TAB_LISTVIEW: [ListViewController class],
                                       TAB_MYCLIP: [BookmarkViewController class],
                                       TAB_DEBUG: [DebuggingTabViewController class],
                                       TAB_FOOTBALL_TRAINING: [FBTrainingTabViewController class],
                                       };
        self.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsRequest:) name:NOTIF_REQUEST_SETTINGS object:nil];
        
        
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_REQUEST_SETTINGS object:nil];
}

- (void)settingsRequest:(NSNotification *)note {
    if ([self isKindOfClass:note.userInfo[@"Class"]]) {
        void(^block)(NSArray *tabs) = note.userInfo[@"Block"];
        
        NSMutableArray *tabs = [NSMutableArray array];
        
        for (NSDictionary *toggle in self.toggles) {
            NSString *identifier = toggle[@"Identifier"];
            
            if ([self.settingData[identifier] boolValue]) {
                [tabs addObject:self.tabClassForIdentifier[identifier]];
            }
        }
        
        block(tabs);
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
    
    NSMutableArray *tabs = [NSMutableArray array];
    
    for (NSDictionary *toggle in self.toggles) {
        NSString *identifier = toggle[@"Identifier"];
        
        if ([self.settingData[identifier] boolValue]) {
            [tabs addObject:self.tabClassForIdentifier[identifier]];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_TABS_SETTING_CHANGED object:nil userInfo:@{ @"Tabs": tabs }];
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
