
//
//  CustomTabBar.m
//  Live2BenchNative
//
//  Created by DEV on 2013-01-21.
//  Copyright (c) 2013 DEV. All rights reserved.
//

/**
 *  This is the main App Tab Bar
 */

#import "LogoViewController.h"
#import "CalendarViewController.h"
#import "Live2BenchViewController.h"
#import "ClipViewController.h"
#import "ListViewController.h"
#import "BookmarkViewController.h"
#import "TabBarButton.h"
#import "UploadButton.h"
#import "LoginViewController.h"
#import "CustomTabBar.h"
#import "SpinnerView.h"
#import "EncoderClasses/EncoderManager.h"
#import "CustomTabViewController.h"
#import "DebuggingTabViewController.h"
#import "SettingsPageViewController.h"
#import "InjuryViewController.h"

#import "TabsSettingViewController.h"

#import "UserCenter.h"
//#import "StatsTabViewController.h"

typedef NS_OPTIONS(NSInteger, PXPTabs) {
    PXPTabsLogoTab      = 1<<1,
    PXPTabsCalendarTab  = 1<<2,
    PXPTabsL2BTab       = 1<<3,
    PXPTabsClipViewTab  = 1<<4,
    PXPTabsListViewTab  = 1<<5,
    PXPTabsMyClipsTab   = 1<<6,
    PXPTabsStatsTab     = 1<<7,
    PXPTabsDebuggingTab = 1<<10,
    //    EventButtonControlStatesDisabled    = STOP_HIDDEN | PAUSE_HIDDEN | RESUME_HIDDEN,
    
};


@interface CustomTabBar ()

@property (strong, nonatomic) NSMutableArray *tabList;
@property (strong, nonatomic) NSMutableArray *tabs;
@property (strong, nonatomic) NSMutableArray *arrayOfTabButtons;


@end


@implementation CustomTabBar
{
    // Tab Props
    NSMutableDictionary * tabNameReferenceDict;
    NSMutableArray      * tabButtonItems;
    
    // App Start Props
    EncoderManager      * encoderManager;
    AppDelegate         * appDel;
    UserCenter          * userCenter;
    LoginViewController * loginViewController;
}

-(id)init
{
    appDel              = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    encoderManager      = appDel.encoderManager;
    userCenter          = appDel.userCenter;
    
    self.arrayOfTabButtons = [[NSMutableArray alloc] init];
    
    self = [super init];
    if (self) {
        
    }
    return self;
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    [self setupView];
    
    //resize window so that there is no black strip at bottom, (black strip from native tab bar) move native tab bar off screen.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.0];
    UIView *nativeTabView = [self.view.subviews objectAtIndex:1];
    [nativeTabView setFrame:CGRectMake(-1024, -1024, nativeTabView.frame.size.width, nativeTabView.frame.size.height)];
    [UIView commitAnimations];
    
    // Add Observers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationSelectTab:)   name:NOTIF_SELECT_TAB object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleTabs:) name:NOTIF_TABS_SETTING_CHANGED object:nil];
}

/**
 *  This creates the tab buttons based off the supplied TabViewControllers sent in
 */
-(void)createTabButtons
{
    for (TabBarButton *tab in self.arrayOfTabButtons) {
        [tab removeFromSuperview];
    }
    //int tabCount = [self.viewControllers count];
    NSUInteger tabCount = [self.tabs count];
    tabNameReferenceDict = [[NSMutableDictionary alloc]init]; // this is so the tabs can be ref by name;
    for (int i =0; i<tabCount;i++){
        
        TabBarButton* btn = ((CustomTabViewController*)[self.tabs objectAtIndex:i]).sectionTab ;
        btn.frame = CGRectMake(i*(self.view.bounds.size.width/tabCount), 0, self.view.bounds.size.width/tabCount + 1, 55);
        [btn setClipsToBounds:TRUE];
        [btn setTag:i];
        [self.view addSubview:btn];
        [self.arrayOfTabButtons addObject:btn];
        
        [btn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [tabNameReferenceDict setObject:[NSNumber numberWithInt:i ] forKey:btn.tabName];
    }
}

/**
 *  Builds the TabViewControllers for each tab
 */
-(void)setupView
{
    NSMutableArray *tabViewControllers = [NSMutableArray array];
    
    SettingsPageViewController  *settingsVC = [[SettingsPageViewController alloc] initWithAppDelegate:appDel];

    [tabViewControllers addObject: settingsVC];
    
    __block NSArray *enabledTabs;
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REQUEST_SETTINGS
                                                        object:nil
                                                      userInfo:@{
                                                                 @"Class": [TabsSettingViewController class],
                                                                 @"Block":^(NSArray *tabs) {enabledTabs = tabs;}
                                                                 }];
    
    for (Class tabClass in enabledTabs) {
        [tabViewControllers addObject:[[tabClass alloc] initWithAppDelegate:appDel]];
    }
    
    
    self.tabs = tabViewControllers;
 
    for (UIViewController *vc in self.tabs) {
        [self addChildViewController:vc];
    }
}

// check if self.tabs have the tab that should be visible
-(Boolean)check:(NSString*)name{
    for (CustomTabViewController *vc in self.tabs) {
        NSArray *words = [vc.name componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
        NSString *vcName;
        if (words.count > 1 ) {
            vcName = [NSString stringWithFormat:@"%@%@",words[0],words[1]];
        }else{
            vcName = words[0];
        }
        if ([vcName isEqualToString:name]) {
            return true;
        }
    }
    return false;
}

// check if the tab in self.tabs should be visible
-(Boolean)check:(CustomTabViewController*)vc array:(NSArray*)array{
    NSArray *words = [vc.name componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
    NSString *vcName;
    if (words.count > 1 ) {
        vcName = [NSString stringWithFormat:@"%@%@",words[0],words[1]];
    }else{
        vcName = words[0];
    }
    
    for (NSString *name in array) {
        if ([vcName isEqualToString:name]) {
            return true;
        }
    }
    return false;
}

-(void)toggleTabs:(NSNotification *)note {
    NSArray *tabsName   = note.userInfo[@"TabsName"];
    NSArray *tabs       = note.userInfo[@"Tabs"];
    
    // If there is tab that is not already visible, add it
    for (NSString *name in tabsName) {
        if(![self check:name]) {
            NSInteger index = [tabsName indexOfObject:name];
            Class tabClass = [tabs objectAtIndex:index];
            CustomTabViewController *vc = [[tabClass alloc]initWithAppDelegate:appDel];
            [self.tabs addObject:vc];
            [self addChildViewController:vc];
        }
    }
    
    // If there is tab that is already gone, remove it
    for (CustomTabViewController *vc in [self.tabs copy]) {
        if (![self check:vc array:tabsName] && ![vc isKindOfClass:[SettingsPageViewController class]]) {
            [vc removeFromParentViewController];
            [self.tabs removeObject:vc];
        }

    }
    
    // this notification allows some tab to set itself up
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_TAB_CREATED object:nil];
    [self createTabButtons];
    //[self refreshTabs];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self createTabButtons];
}

#pragma mark - Tab Navigation Methods

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    [super setSelectedIndex:selectedIndex];
    [self changeButtonHighlightForTab:selectedIndex];
    [self.selectedViewController viewDidAppear:YES];
}

- (void)changeButtonHighlightForTab: (NSInteger)tabNum
{
    [((CustomTabViewController *)[self.viewControllers objectAtIndex:tabNum]).sectionTab setSelected:TRUE];
    
    for(CustomTabViewController *tabs in self.viewControllers)
    {
        if ([self.viewControllers indexOfObject:tabs] != tabNum) {
            [((CustomTabViewController *)tabs).sectionTab setSelected:FALSE];
        }
    }
    
    for(CustomButton *tempbtn in tabButtonItems)
    {
        if([tabButtonItems indexOfObject:tempbtn] == tabNum)
        {
            [tempbtn setSelected:TRUE];
        }else{
            [tempbtn setSelected:FALSE];
        }
    }
    
    [self.tabBarController setSelectedIndex:tabNum];
    
    //In the event the Tele is fullscreened and the tab is changed, get rid of the tele interface
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"Close Tele" object:nil];
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController
{
    NSInteger vcIndex = [self.viewControllers indexOfObject:selectedViewController];
    [self setSelectedIndex:vcIndex];
}

/**
 *  This Looks for a notification to move to a different tab
 *
 *  @param note
 */
-(void)notificationSelectTab:(NSNotification*)note
{
    NSString * tabName = [note.userInfo objectForKey:@"tabName"];
    NSInteger tabIndex = [[tabNameReferenceDict objectForKey:tabName]integerValue];
    [self selectTab: tabIndex   ];
}

/**
 *  what happens when a tab is selected also for external use
 *
 *  @param tabID Tab Id
 */
- (void)selectTab:(NSInteger)tabID
{
    self.selectedIndex = tabID;
}


//tab bar button is clicked
- (void)buttonClicked:(id)sender
{
    NSInteger tagNum = [sender tag];
    //    if (self.selectedIndex != tagNum){
    //        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SWITCH_MAIN_TAB object:self];
    //    }
    [((CustomTabViewController *)[self.viewControllers objectAtIndex:tagNum]).sectionTab setHighlighted:true];
    [self selectTab:tagNum];
}



-(void)didReceiveMemoryWarning {
    PXPLog(@"*********************************");
    PXPLog(@"**** didReceiveMemoryWarning ****");
    PXPLog(@"*********************************");
    [super didReceiveMemoryWarning];
}

@end

