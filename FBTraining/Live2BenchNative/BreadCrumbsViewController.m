//
//  BreadCrumbsViewController.m
//  Live2BenchNative
//
//  Created by dev on 7/31/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "BreadCrumbsViewController.h"
#import "BreadCrumbView.h"
#import "AbstractFilterViewController.h"

#define CRUMB_WIDTH     100
#define LIMIT           9
@interface BreadCrumbsViewController ()

@end


@implementation BreadCrumbsViewController
{
    NSMutableArray * listOfCrubs;
    
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
  

}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_FILTER_CHANGE object:nil];
}


-(id)initWithPoint:(CGPoint)pt
{
    self = [super init];
    if (self) {
        [self.view setFrame:CGRectMake(pt.x, pt.y, 0, 0)];
        listOfCrubs = [[NSMutableArray alloc]init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBreadCrumbWithFilter:) name:NOTIF_FILTER_CHANGE object:nil];
    }
    return self;
}


-(void)inputList:(NSArray *)list
{
    [self clear];
    for (int i =0; i<list.count; i++) {
        if (i > LIMIT) break;
        CGRect rect = CGRectMake(i * (CRUMB_WIDTH-5), 0, CRUMB_WIDTH, 40);
        BreadCrumbView * crumb = [[BreadCrumbView alloc]initWithFrame:rect label:list[i]];
        [self.view addSubview:crumb];
        if (!i) [crumb setFirst];
        
        [listOfCrubs addObject:crumb];
    }

}



-(void)clear
{
	for (BreadCrumbView * crumb in  listOfCrubs) {
        [crumb removeFromSuperview];
    }
    [listOfCrubs removeAllObjects];
}






- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


-(void)updateBreadCrumbWithFilter:(NSNotification *)notification
{
    // the [notification object]; is the filter is self
    AbstractFilterViewController * checkFilter = (AbstractFilterViewController *)[notification object];;
    [self inputList: [checkFilter.tabManager invokedComponentNames]];
    
  
}


- (void)didReceiveMemoryWarning
{
     [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_RECEIVE_MEMORY_WARNING object:self userInfo:nil];
    [super didReceiveMemoryWarning];
    PXPLog(@"*** didReceiveMemoryWarning ***");
    // Dispose of any resources that can be recreated.
}


@end
