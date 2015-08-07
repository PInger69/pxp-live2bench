//
//  TabView.m
//  Test12
//
//  Created by colin on 7/29/15.
//  Copyright (c) 2015 Cezary Wojcik. All rights reserved.
//

#import "TabView.h"
#import "PxpFilterDefaultTabViewController.h"
#import "PxpFilterHockeyTabViewController.h"
#import "PxpFilterFootballTabViewController.h"
#import "PxpFilterTabController.h"

@interface TabView ()



@end



static TabView* sharedFilter;

@implementation TabView
{
    NSMutableArray *_tabs; //view controller of all tabs
    PxpFilterTabController *previousTab;
}

+(nonnull instancetype)sharedFilterTab
{
    if (!sharedFilter) sharedFilter = [[TabView alloc]init];
    return sharedFilter;
}


- (id)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _tabs = [NSMutableArray array];
        previousTab=nil;
    }
    return self;
}

- (nonnull instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil tabs:(nullable NSArray *)tabs{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _tabs = [NSMutableArray arrayWithArray:tabs];
        previousTab=nil;
    }
    return self;
}

-(BOOL)checkTabAvailability:(PxpFilterTabController*)targetTab{
    return targetTab&&[_tabs indexOfObject:targetTab]!=NSNotFound;
}

-(void)showTab:(PxpFilterTabController*)targetTab{
    [self.view insertSubview:targetTab.view belowSubview:_mainTabBar];
    [targetTab show];
}

-(void)hideTab:(PxpFilterTabController*)targetTab{
    [targetTab.view removeFromSuperview];
    [targetTab hide];
}

-(void)show:(NSUInteger)tabIndex{
    
    PxpFilterTabController *currentTab = _tabs[tabIndex];
    
    if([self checkTabAvailability:previousTab])
        [self hideTab:previousTab];
    
    [self showTab:currentTab];
    
    previousTab = currentTab;
}

- (void)customizeTabBarAppearance{
   
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor orangeColor], NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    
}

- (void)updateTabBar {
    
    
    if (_mainTabBar) {
        _mainTabBar.tintColor = [UIColor orangeColor];
        _mainTabBar.translucent = NO;
        NSMutableArray *tabItems = [NSMutableArray arrayWithCapacity:_tabs.count];
        [[UITabBarItem appearance]setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Arial" size:25.0f], NSFontAttributeName,nil]forState:UIControlStateNormal];
        for (PxpFilterTabController *vc in _tabs) {
            [vc.tabImage drawInRect:CGRectMake(0, 0, 30, 30)];
            UITabBarItem *tabItem = [[UITabBarItem alloc] initWithTitle:vc.title image:vc.tabImage selectedImage:nil];
            
            //position adjustment for tabitem titles and images
            CGSize textSize = [vc.title sizeWithAttributes:@{ NSFontAttributeName : [UIFont fontWithName:@"Arial" size:25.0f] }];
            
            tabItem.imageInsets = UIEdgeInsetsMake(15, -50-textSize.width/2.0, -15, 50+textSize.width/2.0);
            tabItem.titlePositionAdjustment = UIOffsetMake(40.0/_tabs.count,0);
            
            [tabItems addObject:tabItem];
        };
        
        [_mainTabBar setItems:tabItems animated:YES];
        [_mainTabBar setSelectedItem:_mainTabBar.items[0]];
        [self show:0];

    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
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

- (void)addTab:(PxpFilterTabController *)newTab{
    [_tabs addObject:newTab];
    
    newTab.pxpFilter = self.pxpFilter;
    
    [self updateTabBar];
}

- (BOOL)removeTab: (PxpFilterTabController *)tabToRemove{
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
