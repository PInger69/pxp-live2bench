
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
#import "Reachability.h"
#import "UploadButton.h"
#import "LoginViewController.h"
#import "CustomTabBar.h"
#import "SpinnerView.h"
#import "EncoderClasses/EncoderManager.h"
#import "CustomTabViewController.h"
#import "DebuggingTabViewController.h"
#import "SettingsPageViewController.h"

#import "UserCenter.h"
//#import "StatsTabViewController.h"

#define SHOW_STATS_TAB              YES

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



@implementation CustomTabBar
{
    // Tab Props
    NSMutableDictionary * tabNameReferenceDict;
    //NSArray             * tabBarItems;
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
}


/**
 *  This creates the tab buttons based off the supplied TabViewControllers sent in
 */
-(void)createTabButtons
{
    int tabCount = [self.viewControllers count];
    tabNameReferenceDict = [[NSMutableDictionary alloc]init]; // this is so the tabs can be ref by name;
    for (int i =0; i<tabCount;i++){
        
        TabBarButton* btn = ((CustomTabViewController*)[self.viewControllers objectAtIndex:i]).sectionTab ;
        btn.frame = CGRectMake(i*(self.view.bounds.size.width/tabCount), 0, self.view.bounds.size.width/tabCount + 1, 55);
        [btn setClipsToBounds:TRUE];
        [btn setTag:i];
        [self.view addSubview:btn];
        [btn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [tabNameReferenceDict setObject:[NSNumber numberWithInt:i ] forKey:btn.tabName];
        
    }
}

/**
 *  Builds the TabViewControllers for each tab
 */
-(void)setupView
{

    SettingsPageViewController  *settingsVC = [[SettingsPageViewController alloc] initWithAppDelegate:appDel];
    //LogoViewController          *logoVC     = [[LogoViewController alloc] initWithAppDelegate:appDel];
    CalendarViewController      *calendarVC = [[CalendarViewController alloc] initWithAppDelegate:appDel];
    Live2BenchViewController    *liveVC     = [[Live2BenchViewController alloc] initWithAppDelegate:appDel];
    ClipViewController          *clipVC     = [[ClipViewController alloc] initWithAppDelegate:appDel];
   ListViewController          *listVC     = [[ListViewController alloc] init];
    BookmarkViewController      *bookmarkVC = [[BookmarkViewController alloc] initWithAppDelegate:appDel];
//  StatsTabViewController      *statsVC    = [[StatsTabViewController alloc] init];
  DebuggingTabViewController  *debugTabView  = [[DebuggingTabViewController alloc]initWithAppDelegate:appDel];
  
    NSMutableArray              *vcArray    = [NSMutableArray arrayWithObjects:
                                               settingsVC,
                                            /* logoVC, */
                                               calendarVC,
                                               liveVC,
                                               clipVC,
                                               listVC,
                                               bookmarkVC,
                                               debugTabView,
                                               nil];
    if(SHOW_STATS_TAB)
        //   [vcArray addObject:statsVC];
        //    if(SHOW_STATS_TAB)
      //  [vcArray addObject:debugTabView];
    for (UIViewController *vc in vcArray) {
        [self addChildViewController:vc];

    }
    
    //[self createTabButtons];


}



-(void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

//    //array of tab bar items -- this array is used to create buttons in the tab bar
//   // TabBarButton *welcomeTab    = [[TabBarButton alloc] initWithName:@"Welcome"     andImageName:@"logoTab"];
//    TabBarButton *calendarTab   = [[TabBarButton alloc] initWithName:@"Calendar"    andImageName:@"calendarTab"];
//    TabBarButton *live2BenchTab = [[TabBarButton alloc] initWithName:@"Live2Bench"  andImageName:@"live2BenchTab"];
//    TabBarButton *clipTab       = [[TabBarButton alloc] initWithName:@"Clip View"   andImageName:@"clipTab"];
//    TabBarButton *listTab       = [[TabBarButton alloc] initWithName:@"List View"   andImageName:@"listTab"];
//    TabBarButton *myClipTab     = [[TabBarButton alloc] initWithName:@"My Clip"     andImageName:@"myClipTab"];
//    TabBarButton *statsTab      = [[TabBarButton alloc] initWithName:@"Stats"       andImageName:@"statsTab"];
//
//    NSMutableArray* tabItems = [NSMutableArray arrayWithObjects:/* welcomeTab,*/ calendarTab, live2BenchTab, clipTab, listTab, myClipTab, nil];
//    if(SHOW_STATS_TAB)
//        [tabItems addObject:statsTab];
//    
//    tabBarItems = [tabItems copy];
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
    
    for(CustomTabViewController *tabs in self.viewControllers)
    {
        [((CustomTabViewController *)tabs).sectionTab setSelected:FALSE];
    }
    [((CustomTabViewController *)[self.viewControllers objectAtIndex:tabNum]).sectionTab setSelected:TRUE];
    
    
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Close Tele" object:nil];
    
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
- (void)selectTab:(int)tabID
{
    self.selectedIndex = tabID;
}


//tab bar button is clicked
- (void)buttonClicked:(id)sender
{
    int tagNum = [sender tag];
    //    if (self.selectedIndex != tagNum){
    //        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SWITCH_MAIN_TAB object:self];
    //    }
    [self selectTab:tagNum];
}





@end
