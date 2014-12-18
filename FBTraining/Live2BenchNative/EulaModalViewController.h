//
//  EulaModalViewController.h
//  Live2BenchNative
//
//  Created by DEV on 2013-02-20.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Globals.h"
#import "LoginViewController.h"

@class LoginViewController;

@interface EulaModalViewController : UIViewController
{
    Globals *globals;
    LoginViewController *lVController;
}

- (id)initWithController:(LoginViewController*)loginViewController;
- (void)dismissView:(id)sender;
- (void)acceptEula:(id)sender;


@property (strong, nonatomic) UIButton *acceptEulaButton;


@end
