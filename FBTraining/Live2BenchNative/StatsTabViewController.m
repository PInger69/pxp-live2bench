//
//  StatsTabViewController.m
//  Live2BenchNative
//
//  Created by Si Te Feng on 7/15/14.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "StatsTabViewController.h"
#import "StatsViewController.h"
#import "ImportTagsViewController.h"
#import "ZoneGraphViewController.h"


@interface StatsTabViewController ()

@end


@implementation StatsTabViewController
@synthesize sectionTab = _sectionTab;

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setMainSectionTab:@"Stats" imageName:@"statsTab"];
        StatsViewController* statsController = [[StatsViewController alloc] initWithNibName:nil bundle:nil];
        
        ImportTagsViewController* importController = [[ImportTagsViewController alloc] initWithNibName:nil bundle:nil];
        ZoneGraphViewController* graphController = [[ZoneGraphViewController alloc] initWithNibName:nil bundle:nil];
        
        
        self.viewControllers = @[statsController, graphController, importController];
        self.selectedIndex = 0;
        
        tabAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                         [UIFont defaultFontOfSize:35.0f], NSFontAttributeName,
                         [UIColor colorWithWhite:0.3f alpha:1.0f], NSForegroundColorAttributeName,
                         nil];
        tabSelectedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [UIFont defaultFontOfSize:35.0f], NSFontAttributeName,
                                 [UIColor orangeColor], NSForegroundColorAttributeName,
                                 nil];
        
    }
    return self;
}

-(void)setMainSectionTab:(NSString*)name imageName:(NSString*)imgName
{
    _sectionTab = [[TabBarButton alloc] initWithName:name andImageName:imgName];
    
}

-(TabBarButton *)sectionTab
{
    if (!_sectionTab){
        _sectionTab = [[TabBarButton alloc] initWithName:@"not set" andImageName:@""];
    }
    
    return _sectionTab;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tabBar.hidden = YES;

    flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    fix = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fix.width = 5.0f;
    
    self.customTabBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, self.view.bounds.size.height - 60.0f, self.view.bounds.size.width, 60.0f)];
    self.customTabBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    self.customTabBar.tintColor = [UIColor lightGrayColor];
    
    [self.view addSubview:self.customTabBar];
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reload];
}


- (void)reload
{
    NSMutableArray* tabBarItems = [@[] mutableCopy];
    self.barButtonItems = [NSMutableArray array];
    
    for(int i = 0; i<[self.viewControllers count]; i++)
    {
        UIViewController * controller = self.viewControllers[i];
        
        UIBarButtonItem* barButton = [[UIBarButtonItem alloc] initWithTitle:controller.title style:UIBarButtonItemStylePlain target:self action:@selector(selectTab:)];
        barButton.tag = i;
        [barButton setTitleTextAttributes:tabAttributes forState:UIControlStateNormal];
        if(i==self.selectedIndex)
            [barButton setTitleTextAttributes:tabSelectedAttributes forState:UIControlStateNormal];
        
        [self.barButtonItems addObject:barButton];
        
        [tabBarItems addObjectsFromArray:@[flex, barButton]];
    }
    
    [tabBarItems addObject:flex];
    self.customTabBar.items = (NSArray*)tabBarItems;
}



- (void)selectTab: (UIBarButtonItem*)button
{
    self.selectedIndex = button.tag;
    
    for(UIBarButtonItem* item in self.barButtonItems)
    {
        [item setTitleTextAttributes:tabAttributes forState:UIControlStateNormal];
        
        if(item.tag == button.tag)
            [item setTitleTextAttributes:tabSelectedAttributes forState:UIControlStateNormal];
    }
}


- (void)setViewControllers:(NSArray *)viewControllers
{
    super.viewControllers = viewControllers;
    
    [self reload];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/






@end
