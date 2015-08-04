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
        /*self.leftSwipGestureRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipes:)];
        self.rightSwipGestureRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipes:)];
        self.leftSwipGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        self.rightSwipGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
        
        [self.view addGestureRecognizer:self.leftSwipGestureRecognizer];
        [self.view addGestureRecognizer:self.rightSwipGestureRecognizer];*/
        
    }
    return self;
}

/*- (void)handleSwipes:(UISwipeGestureRecognizer *)sender
{
    if(sender.direction == UISwipeGestureRecognizerDirectionLeft){
        NSInteger itemIndex = [_mainTabBar.items indexOfObject:_mainTabBar.selectedItem];
        PxpFilterTabController *previous = _tabs[itemIndex];
        itemIndex++;
        if(itemIndex>=_mainTabBar.items.count)itemIndex=0;
        [_mainTabBar setSelectedItem:_mainTabBar.items[itemIndex]];
        [self show:itemIndex withPrevious:previous andDirection:sender.direction];
    }else{
        NSInteger itemIndex = [_mainTabBar.items indexOfObject:_mainTabBar.selectedItem];
        PxpFilterTabController *previous = _tabs[itemIndex];
        itemIndex--;
        if(itemIndex<0)itemIndex=_mainTabBar.items.count-1;
        [_mainTabBar setSelectedItem:_mainTabBar.items[itemIndex]];
        [self show:itemIndex withPrevious:previous andDirection:sender.direction];
    }
}*/

-(void)show:(NSUInteger)tabIndex{
    PxpFilterTabController *temp = _tabs[tabIndex];
    [self.view insertSubview:temp.view belowSubview:_mainTabBar];
    [temp setPxpFilter:self.pxpFilter];
}

/*- (void)show:(NSUInteger)tabIndex withPrevious:(PxpFilterTabController *)previous andDirection:(UISwipeGestureRecognizerDirection)dir{
    if (tabIndex < _tabs.count) {
        PxpFilterTabController *temp = _tabs[tabIndex];
        CGFloat windowWidth = self.view.frame.size.width;
        CGFloat windowHeight = self.view.frame.size.width;
        CGRect onScreen = self.view.frame;
        CGRect offScreenRight = CGRectMake(windowWidth,0.0,windowWidth,windowHeight);
        CGRect offScreenLeft = CGRectMake(-windowWidth,0.0,windowWidth,windowHeight);
        [self.view insertSubview:temp.view belowSubview:_mainTabBar];
        if(dir == UISwipeGestureRecognizerDirectionLeft){
            [UIView animateWithDuration:0.65 animations:^{
                previous.view.frame = offScreenLeft;
                temp.view.frame = onScreen;
            }completion:^(BOOL finished){
                
            }];
        }else{
            [UIView animateWithDuration:0.65 animations:^{
                previous.view.frame = offScreenRight;
                temp.view.frame = onScreen;
            }completion:^(BOOL finished){
                
            }];
        }
        //test PxpFilter
        [temp setPxpFilter:self.pxpFilter];
    }
    
}*/

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
        /*//test for adding a tab
         UITabBarItem *tabItem = [[UITabBarItem alloc] initWithTitle:@"+" image:nil selectedImage:nil];
        [tabItems addObject:tabItem];
        */
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
    
    
    /*
    //test for adding a new tab
     if(itemIndex>=_tabs.count){
        [self addTab:[[ViewController alloc]init]];
    }else{
        [self show:itemIndex];
    }*/
    
    [self show:itemIndex];
    //test pxpFilter
    
    //[self.pxpFilter viewPxpFilterModules];
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
