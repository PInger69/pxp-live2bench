//
//  TabView.m
//  CWPopupDemo
//
//  Created by colin on 7/29/15.
//  Copyright (c) 2015 Cezary Wojcik. All rights reserved.
//

#import "TabView.h"
#import "ViewController.h"
#import "ViewController2.h"
#import "PxpFilterTabController.h"

@interface TabView ()



@end


@implementation TabView
{
    NSMutableArray *_tabs; //view controller of all tabs
}

- (id)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _tabs = [NSMutableArray array];
    }
    return self;
}

- (void)show:(NSUInteger)tabIndex {
    if (tabIndex < _tabs.count) {
        PxpFilterTabController *temp = _tabs[tabIndex];
        [self.view insertSubview:temp.view belowSubview:_mainTabBar];
        
        //test PxpFilter
        [temp setPxpFilter:self.pxpFilter];
    }
    
}

- (void)updateTabBar {
    _mainTabBar.tintColor = [UIColor orangeColor];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor orangeColor], NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    
    
    
    if (_mainTabBar) {
        NSMutableArray *tabItems = [NSMutableArray arrayWithCapacity:_tabs.count];
        for (PxpFilterTabController *vc in _tabs) {
            [vc.tabImage drawInRect:CGRectMake(0, 0, 30, 30)];
            UITabBarItem *tabItem = [[UITabBarItem alloc] initWithTitle:vc.title image:vc.tabImage selectedImage:nil];
            tabItem.imageInsets = UIEdgeInsetsMake(9, 0, -9, 0);
            [tabItems addObject:tabItem];
        };
        [_mainTabBar setItems:tabItems animated:YES];
        [_mainTabBar setSelectedItem:_mainTabBar.items[0]];
        
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //[[UITabBar appearance] setTintColor:[UIColor whiteColor]];
    
    //self.pxpFilter = [[PxpFilter alloc] init];
    //[self.pxpFilter init_];
    
    //show the first tab
    [self updateTabBar];
    [self show:0];
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
    
    //test pxpFilter
    
    //[self.pxpFilter viewPxpFilterModules];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    //UIToolbar *toolbarBackground = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 44, 200, 106)];
    //[self.view addSubview:toolbarBackground];
    //[self.view sendSubviewToBack:toolbarBackground];
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
