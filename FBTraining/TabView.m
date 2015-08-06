//
//  TabView.m
//  Test12
//
//  Created by colin on 7/29/15.
//  Copyright (c) 2015 Cezary Wojcik. All rights reserved.
//

#import "TabView.h"
#import "PxpFilterTabViewController.h"
#import "PxpFilterTabViewController2.h"
#import "PxpFilterTabController.h"

@interface TabView ()



@end



static TabView* sharedFilter;

@implementation TabView
{
    NSMutableArray *_tabs; //view controller of all tabs
}

+(TabView*)sharedFilterTab
{
    if (!sharedFilter) sharedFilter= [[TabView alloc]init];
    return sharedFilter;
}


- (id)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _tabs = [NSMutableArray array];
    }
    return self;
}

-(void)show:(NSUInteger)tabIndex{
    PxpFilterTabController *temp = _tabs[tabIndex];

    [self.view insertSubview:temp.view belowSubview:_mainTabBar];
        [temp setPxpFilter:self.pxpFilter];
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
            tabItem.imageInsets = UIEdgeInsetsMake(15, -50, -15, 50);
            tabItem.titlePositionAdjustment = UIOffsetMake(20+40.0/_tabs.count,0);
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
    
    [self updateTabBar];
}

#pragma mark - Public Methods

- (void)addTab:(PxpFilterTabController *)newTab{
    [_tabs addObject:newTab];
    
    [self updateTabBar];
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
