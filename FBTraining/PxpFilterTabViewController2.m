//
//  ViewController2.m
//  Test12
//
//  Created by colin on 7/29/15.
//  Copyright (c) 2015 colin. All rights reserved.
//

#import "PxpFilterTabViewController2.h"

@interface PxpFilterTabViewController2 ()

@end

@implementation PxpFilterTabViewController2


@synthesize tabImage;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"VC2";
        
        /*self.modules = [[NSMutableArray alloc]initWithObjects:
                        @"A",@"B",@"A",
                        @"B",@"C",nil];*/
        tabImage =  [UIImage imageNamed:@"settingsButton"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
