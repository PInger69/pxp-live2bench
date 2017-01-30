//
//  LoginViewController.h
//  Live2BenchNative
//
//  Created by dev on 13-01-22.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sys/socket.h"
#import "netinet/in.h"
#import "SystemConfiguration/SystemConfiguration.h"
#import "LoginTextField.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate>{

    UIView *loadingView;
    NSMutableURLRequest *request;
    NSDictionary *userDictionary;
    int isSuccess;
    NSString *responseMsg;
    NSString *emailAddress;
    NSString *password;
    NSTimer *wifiTimer ;
}

@property (nonatomic,strong) UIView *loadingView;
@property (strong, nonatomic) UILabel           * noInternetLabel;
@property (strong, nonatomic) UILabel           * noInternetLoginLabel;
@property (strong, nonatomic) UIButton          * goToCalendarButton;
@property (strong, nonatomic) UIButton          * goToL2BButton;
@property (strong, nonatomic) UILabel           * accountLoginLabel;
@property (strong, nonatomic) UILabel           * emailAddressLabel;
@property (strong, nonatomic) UILabel           * passwordLabel;
@property (strong, nonatomic) LoginTextField    * emailAddressTextField;
@property (strong, nonatomic) LoginTextField    * passwordTextField;
@property (strong, nonatomic) UIButton          * submitButton;
@property (nonatomic) CGRect rect;

@property (nonatomic, assign) BOOL      success;
@property (nonatomic, assign) BOOL      hasInternet;


@end
