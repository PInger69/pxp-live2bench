//
//  TabView.m
//
//
//  Created by colin on 7/29/15.
//  Copyright (c) DEV. All rights reserved.
//

#import "TabView.h"

#import "PxpFilterHockeyTabViewController.h"
#import "PxpFilterFootballTabViewController.h"
#import "PxpFilterRugbyTabViewController.h"
#import "PxpFilterSoccerTabViewController.h"
#import "PxpFilterTabController.h"

@interface TabView ()



@end



static TabView  * sharedFilter;
static PxpFilterDefaultTabViewController  * sharedDefaultFilterTab;
static NSString * currentFilterSport;

@implementation TabView
{
    NSMutableArray *_tabs; //Array of PxpFilterTabControllers
    PxpFilterTabController *previousTab;  //The previous tab showed
}

+(PxpFilterDefaultTabViewController*)sharedDefaultFilterTab
{
    if (!sharedFilter) {
        sharedFilter = [[TabView alloc]init];
        sharedDefaultFilterTab = [PxpFilterDefaultTabViewController new];
        [sharedFilter addTab:sharedDefaultFilterTab];
        

        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(eventChanged:) name:NOTIF_EVENT_CHANGE object:nil];
    }
    

    return sharedDefaultFilterTab;
}

+(nonnull instancetype)sharedFilterTabBar
{
    if (!sharedFilter) {
        sharedFilter = [[TabView alloc]init];
        sharedDefaultFilterTab = [PxpFilterDefaultTabViewController new];
        [sharedFilter addTab:sharedDefaultFilterTab];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(eventChanged:) name:NOTIF_EVENT_CHANGE object:nil];
    }
    return sharedFilter;
}

+(void)eventChanged:(NSNotification *)note
{
    
    NSString * aSport = note.userInfo[@"eventType"];
    
    if ([currentFilterSport isEqualToString:@""]) return;
    
    for (PxpFilterTabController *aTab in sharedFilter.tabs) {
        if (![aTab isKindOfClass:[PxpFilterDefaultTabViewController class]]){
            [sharedFilter removeTab:aTab];
        }
    }

    

    if ([aSport isEqualToString:SPORT_HOCKEY]) {
        [sharedFilter addTab:[[PxpFilterHockeyTabViewController alloc]init]];
    } else if ([aSport isEqualToString:SPORT_FOOTBALL]) {
        [sharedFilter addTab:[[PxpFilterFootballTabViewController alloc]init]];
    } else if ([aSport isEqualToString:SPORT_FOOTBALL_TRAINING]) {
        
    } else if ([aSport isEqualToString:SPORT_SOCCER]) {
        [sharedFilter addTab:[[PxpFilterSoccerTabViewController alloc]init]];
    } else if ([aSport isEqualToString:SPORT_BASKETBALL]) {
        
    } else if ([aSport isEqualToString:SPORT_LACROSSE]) {
        
    } else if ([aSport isEqualToString:SPORT_RUGBY]) {
        [sharedFilter addTab:[[PxpFilterRugbyTabViewController alloc]init]];
    } else if ([aSport isEqualToString:SPORT_MEDICAL]) {
        
    }

    

    
}



- (id)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _tabs = [NSMutableArray array];
        previousTab=nil;
        self.preferredContentSize = CGSizeMake(800, 500);        
    }
    return self;
}

- (nonnull instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil tabs:(nullable NSArray *)tabs{  //init using an array of PxpFilterTabControllers
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _tabs = [NSMutableArray arrayWithArray:tabs];
        previousTab=nil;
        self.preferredContentSize = CGSizeMake(800, 500);
    }
    return self;
}

-(BOOL)checkTabAvailability:(PxpFilterTabController*)targetTab{  //Check whether the targetTab is available for showing or removing
    return targetTab&&[_tabs indexOfObject:targetTab]!=NSNotFound;
}

-(void)showTab:(nonnull PxpFilterTabController*)targetTab{   //Show the target tab in the tab view ()
    [self.view insertSubview:targetTab.view belowSubview:_mainTabBar];
    [targetTab show];
}

-(void)hideTab:(nonnull PxpFilterTabController*)targetTab{   //Hide the target tab in the tab view
    [targetTab.view removeFromSuperview];
    [targetTab hide];
}

-(void)show:(NSUInteger)tabIndex{                   //Show a tab in the tabs array with tabIndex (Hide the previous tab at the same time)
    
    PxpFilterTabController *currentTab = _tabs[tabIndex];
    
    if([self checkTabAvailability:previousTab])
        [self hideTab:previousTab];
    
    [self showTab:currentTab];
    [currentTab setPxpFilter:_pxpFilter];
    previousTab = currentTab;
}

- (void)customizeTabBarAppearance{          //Customize the tab bar appearance by setting the title color (normal state and selected state)
   
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor orangeColor], NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    
}

- (void)updateTabBar {                      //Update the tab bar by readding the tab items based on tabs array

    if (_mainTabBar) {
        _mainTabBar.tintColor = [UIColor orangeColor];
        _mainTabBar.translucent = NO;
        NSMutableArray *tabItems = [NSMutableArray arrayWithCapacity:_tabs.count];
        [[UITabBarItem appearance]setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Arial" size:25.0f], NSFontAttributeName,nil]forState:UIControlStateNormal];
        for (PxpFilterTabController *vc in _tabs) {
            [vc.tabImage drawInRect:CGRectMake(0,0, 30, 30)];
            UITabBarItem *tabItem = [[UITabBarItem alloc] initWithTitle:vc.title image:vc.tabImage selectedImage:nil];
            
            //position adjustment for tabitem titles and images
            CGSize textSize = [vc.title sizeWithAttributes:@{ NSFontAttributeName : [UIFont fontWithName:@"Arial" size:25.0f] }];
            
            tabItem.imageInsets = UIEdgeInsetsMake(8, -25-textSize.width/2.0, -8, 25+textSize.width/2.0);

            tabItem.titlePositionAdjustment = UIOffsetMake(40.0/_tabs.count,-4);
            
            [tabItems addObject:tabItem];
        };
        
        [_mainTabBar setItems:tabItems animated:YES];
        [_mainTabBar setSelectedItem:_mainTabBar.items[0]];
        [self show:0];

    }
}

- (void)viewDidLoad {       //After the tab view is load, custom setting will be set and the tab bar will be created
    [super viewDidLoad];
    
    [self customizeTabBarAppearance];
    [self updateTabBar];
}




#pragma mark - Getters / Setters

- (void)setTabs:(NSArray *)tabs {
    _tabs = [NSMutableArray arrayWithArray:tabs];
    
    for (PxpFilterTabController * items in tabs) {
            items.pxpFilter = self.pxpFilter;
    }
    
    [self updateTabBar];
}


-(void)setPxpFilter:(PxpFilter * __nullable)pxpFilter
{
    _pxpFilter = pxpFilter;
    for (PxpFilterTabController * items in _tabs) {
        items.pxpFilter = self.pxpFilter;
    }
}


#pragma mark - Public Methods

- (void)addTab:(PxpFilterTabController *)newTab{        //adding a new tab
    [_tabs addObject:newTab];
    
    newTab.pxpFilter = self.pxpFilter;
    
    [self updateTabBar];
}

- (BOOL)removeTab: (PxpFilterTabController *)tabToRemove{   //removing a tab (return NO if there is no such tab)
    if([self checkTabAvailability:tabToRemove]){
        [_tabs removeObject:tabToRemove];
        if(tabToRemove == previousTab){
            [self hideTab:previousTab];
            if(_tabs.count > 0){
                previousTab = _tabs[0];
                [self showTab:previousTab];
            }
        }
        [self updateTabBar];
        return YES;
    }else{
        [self updateTabBar];
        return NO;
    }
}

#pragma mark - TabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item { 
    NSUInteger itemIndex = [tabBar.items indexOfObject:item];
    [self show:itemIndex];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

@end
