//
//  TabsSettingViewController.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-05-07.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "TabsSettingViewController.h"

#import "CalendarViewController.h"
#import "ClipViewController.h"
#import "ListViewController.h"
#import "BookmarkViewController.h"
#import "DebuggingTabViewController.h"
#import "DualViewTabViewController.h"
#import "MedicalViewController.h"
#import "AnalyzeTabViewController.h"
#import "RicoDualViewTabViewController.h"
#import "RicoLive2BenchViewController.h"


// Tab setting identifiers
#define TAB_CALENDAR @"Calendar"
#define TAB_INJURY @"Injury"
#define TAB_LIVE2BENCH @"Live2Bench"
#define TAB_CLIPVIEW @"ClipView"
#define TAB_LISTVIEW @"ListView"
#define TAB_MYCLIP @"MyClip"
#define TAB_DUALVIEW @"DualView"

#define TAB_DEBUG @"Debug"
#define TAB_MEDICAL @"Medical"
#define TAB_ANALYZE @"Analyze"



#define TAB_VISIBLE(v) [[[PxpPreference dictionary] objectForKey:@"Tabs"][v][@"Visible"] boolValue]
#define TAB_ACTIVE(v) [[[PxpPreference dictionary] objectForKey:@"Tabs"][v][@"Active"] boolValue]


@interface TabsSettingViewController () <ToggleSettingViewControllerDelegate>

@property (strong, nonatomic, nonnull) NSDictionary *tabClassForIdentifier;

@end

@implementation TabsSettingViewController

- (nonnull instancetype)initWithAppDelegate:(nonnull AppDelegate *)appDel {
   
    
    // this adds the toggles to the table
    NSMutableArray      * toggles = [NSMutableArray new];
    NSMutableDictionary * tabClassForIdentifierTemp = [NSMutableDictionary new];
    
    // This will add the toggles based on whe the PxpPreference plist is set to checking the Tabs > Active
    
    if (TAB_VISIBLE(@"Calendar"))   {
        [toggles addObject:@{@"Name": NSLocalizedString(@"Calendar", nil),   @"Identifier": TAB_CALENDAR}];
        [tabClassForIdentifierTemp setObject:[CalendarViewController class] forKey:TAB_CALENDAR];
    }
    if (TAB_VISIBLE(@"Medical"))    {
        [toggles addObject:@{@"Name": NSLocalizedString(@"Medical", nil),    @"Identifier":TAB_MEDICAL}];
        [tabClassForIdentifierTemp setObject:[MedicalViewController class] forKey:TAB_MEDICAL];
    }
    if (TAB_VISIBLE(@"DuelView"))   {
        [toggles addObject:@{@"Name": NSLocalizedString(@"Dual View", nil),  @"Identifier": TAB_DUALVIEW }];
//        [tabClassForIdentifierTemp setObject:[DualViewTabViewController class] forKey:TAB_DUALVIEW];
        [tabClassForIdentifierTemp setObject:[RicoDualViewTabViewController class] forKey:TAB_DUALVIEW];
    }
    if (TAB_VISIBLE(@"Live2Bench")) {
        [toggles addObject:@{@"Name": NSLocalizedString(@"Live2Bench", nil), @"Identifier": TAB_LIVE2BENCH }];
        [tabClassForIdentifierTemp setObject:[RicoLive2BenchViewController class] forKey:TAB_LIVE2BENCH];
    }
    if (TAB_VISIBLE(@"ClipView"))   {
        [toggles addObject:@{@"Name": NSLocalizedString(@"Clip View", nil),  @"Identifier": TAB_CLIPVIEW }];
        [tabClassForIdentifierTemp setObject:[ClipViewController class] forKey:TAB_CLIPVIEW];
    }
    if (TAB_VISIBLE(@"ListView"))   {
        [toggles addObject:@{@"Name": NSLocalizedString(@"List View", nil),  @"Identifier": TAB_LISTVIEW }];
        [tabClassForIdentifierTemp setObject:[ListViewController class] forKey:TAB_LISTVIEW];
    }
    if (TAB_VISIBLE(@"MyClip"))     {
        [toggles addObject:@{@"Name": NSLocalizedString(@"My Clip", nil),    @"Identifier": TAB_MYCLIP }];
        [tabClassForIdentifierTemp setObject:[BookmarkViewController class] forKey:TAB_MYCLIP];
    }
    if (TAB_VISIBLE(@"Analyze"))    {
        [toggles addObject:@{@"Name": NSLocalizedString(@"Analyze", nil),    @"Identifier": TAB_ANALYZE }];
        [tabClassForIdentifierTemp setObject:[AnalyzeTabViewController class] forKey:TAB_ANALYZE];
    }
    if (TAB_VISIBLE(@"Debug"))      {
        [toggles addObject:@{@"Name": NSLocalizedString(@"Debug", nil),      @"Identifier": TAB_DEBUG }];
        [tabClassForIdentifierTemp setObject:[DebuggingTabViewController class] forKey:TAB_DEBUG];
    }
    
    self = [super initWithAppDelegate:appDel
                                 name:NSLocalizedString(@"Main Tabs", nil)
                           identifier:@"Main Tabs"
                              toggles:[toggles copy]];
    
    if (self) {
        // These only take effect on app installs, these are the default visibility if the user has not selected anything
        // once the user makes a tab selection these are reundant
        self.settingData[TAB_CALENDAR]      = @(TAB_ACTIVE(@"Calendar"));
        self.settingData[TAB_LIVE2BENCH]    = @(TAB_ACTIVE(@"Live2Bench"));
        self.settingData[TAB_CLIPVIEW]      = @(TAB_ACTIVE(@"ClipView"));;
        self.settingData[TAB_LISTVIEW]      = @(TAB_ACTIVE(@"ListView"));
        self.settingData[TAB_MYCLIP]        = @(TAB_ACTIVE(@"MyClip"));
        self.settingData[TAB_DEBUG]         = @(TAB_ACTIVE(@"Debug"));
        self.settingData[TAB_DUALVIEW]      = @(TAB_ACTIVE(@"DuelView"));
        self.settingData[TAB_MEDICAL]       = @(TAB_ACTIVE(@"Medical"));
        self.settingData[TAB_ANALYZE]       = @(TAB_ACTIVE(@"Analyze"));
        
        self.tabClassForIdentifier = [tabClassForIdentifierTemp copy];
        
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
    
    NSMutableArray *tabsName = [NSMutableArray array];
    NSMutableArray *tabs = [NSMutableArray array];
    
    for (NSDictionary *toggle in self.toggles) {
        NSString *identifier = toggle[@"Identifier"];
        if ([self.settingData[identifier] boolValue]) {
            [tabsName addObject:identifier];
            [tabs addObject:self.tabClassForIdentifier[identifier]];
        }
    }

    // tabsName is for comparing, tabs is for getting the actual tab
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_TABS_SETTING_CHANGED object:nil userInfo:@{ @"Tabs": tabs, @"TabsName":tabsName }];
}

@end
