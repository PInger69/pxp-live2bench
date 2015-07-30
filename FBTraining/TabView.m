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

@synthesize tabs;
@synthesize mainTabBar;

- (void)show:(NSInteger)tag_num{
    PxpFilterTabController *temp = [tabs objectForKey:[NSNumber numberWithInteger:tag_num]];
    [self.view insertSubview:temp.view belowSubview:mainTabBar];
    
    //test PxpFilter
    [temp setPxpFilter:self.pxpFilter];
    
}

//Use hard coded dict as a initializer for all the tabs

-(void)initAllTabs{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                 [NSNumber numberWithInteger:1],@"ViewController",
                                 [NSNumber numberWithInteger:2],@"ViewController2",nil];
    for(id key in dict){
        PxpFilterTabController *temp = [[NSClassFromString(key) alloc] initWithNibName:key bundle:nil];
        tabs[dict[key]] = temp;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
    tabs = [[NSMutableDictionary alloc]init];
    [self initAllTabs];
    
    //self.pxpFilter = [[PxpFilter alloc] init];
    //[self.pxpFilter init_];
    
    //show the first tab
    [self show:1];
}

- (void)addTab:(PxpFilterTabController *)newTab{
    
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    // test adding tab
    if(item.tag == 100){
//        [self addTab()];
    }
    [self show:item.tag];
    
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
