//
//  PopUpTagSetButtonEditViewController.m
//  Live2BenchNative
//
//  Created by dev on 2015-12-07.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PopUpTagSetButtonEditViewController.h"

@interface PopUpTagSetButtonEditViewController ()
@end

@implementation PopUpTagSetButtonEditViewController

- (instancetype)init
{
    UIViewController *viewController = [[UIViewController alloc] init];
    self                            = [super initWithContentViewController:viewController];

    if (self) {
        viewController.view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 300)];
        self.makeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.makeButton setFrame:CGRectMake(0, 0, 100, 100)];
//        self.makeButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
        [self.makeButton setTitle:@"Make" forState:UIControlStateNormal];
        

        [viewController.view addSubview:self.makeButton];
        viewController.view.layer.borderWidth=1;
    }
    return self;
}




@end
