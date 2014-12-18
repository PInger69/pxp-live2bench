//
//  CustomTabViewController.m
//  Live2BenchNative
//
//  Created by dev on 9/26/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "CustomTabViewController.h"


// All main tabs will inhar

@interface CustomTabViewController ()

@end



@implementation CustomTabViewController

@synthesize sectionTab  = _sectionTab;
@synthesize name        = _name;

//-(id)initWithAppDelegate:(id<UIApplicationDelegate >) mainappDelegate
//{
//    
//    mainAppDelegate = mainappDelegate;
//    self = [super init];
//    if (self) {
//       //        [self.view setBackgroundColor:[UIColor grayColor]];
//    }
//    return self;
//}


-(id)initWithAppDelegate:(AppDelegate *) appDel
{
    
    _appDel = appDel;
    self = [super init];
    if (self) {
        //        [self.view setBackgroundColor:[UIColor grayColor]];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
//        [self.view setBackgroundColor:[UIColor grayColor]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)setMainSectionTab:(NSString*)name imageName:(NSString*)imgName
{
    _name       = name;
    _sectionTab = [[TabBarButton alloc] initWithName:name andImageName:imgName];

}

-(TabBarButton *)sectionTab
{
    if (!_sectionTab){
        _sectionTab = [[TabBarButton alloc] initWithName:@"not set" andImageName:@""];
    }

    return _sectionTab;
}

-(void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SWITCH_MAIN_TAB object:self];
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

-(void)viewDidAppear:(BOOL)animated
{

    [super viewDidAppear:animated];
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


@end
