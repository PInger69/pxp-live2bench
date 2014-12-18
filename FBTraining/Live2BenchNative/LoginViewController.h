//
//  LoginViewController.h
//  Live2BenchNative
//
//  Created by dev on 13-01-22.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Live2BenchViewController.h"
#import "CalendarViewController.h" //should be Calendar view
#import "CustomTabBar.h"
#import "UtilitiesController.h"
#import "sys/socket.h"
#import "netinet/in.h"
#import "SystemConfiguration/SystemConfiguration.h"
//#import "AppQueue.h"
#import "Globals.h"
#import "LoginTextField.h"

@class Live2BenchViewController;
@class CalendarViewController;
@class UtilitiesController;
@class CustomTabBar;

@interface LoginViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>{
    Live2BenchViewController *live2BenchViewController;
    CalendarViewController *calendarViewController;
    CustomTabBar *customTabBar;
    UtilitiesController *uController;
    UIView *loadingView;
    //AppQueue *appQueue;
    NSMutableURLRequest *request;
    NSDictionary *userDictionary;
    int isSuccess;
    NSString *responseMsg;
    Globals *globals;
    NSString *emailAddress;
    NSString *password;
    NSTimer *wifiTimer ;
}

@property (nonatomic,strong) UIView *loadingView;
@property (nonatomic,strong) UtilitiesController *uController;
@property (strong, nonatomic) UILabel *noInternetLabel;
@property (strong, nonatomic) UILabel *noInternetLoginLabel;
@property (strong, nonatomic) UIButton *goToCalendarButton;
@property (strong, nonatomic) UIButton *goToL2BButton;
@property (strong, nonatomic) UILabel *accountLoginLabel;
@property (strong, nonatomic) UILabel *emailAddressLabel;
@property (strong, nonatomic) LoginTextField *emailAddressTextField;
@property (strong, nonatomic) UILabel *passwordLabel;
@property (strong, nonatomic) LoginTextField *passwordTextField;
@property (strong, nonatomic) UIButton *submitButton;
@property (nonatomic,strong) Live2BenchViewController *live2BenchViewController;
@property (nonatomic,strong) CalendarViewController *calendarViewController;
@property (nonatomic, strong) CustomTabBar *customTabBar;
@property (nonatomic) CGRect rect;


- (void)refreshUI;
//- (BOOL)hasConnectivity;
- (id)initWithController:(Live2BenchViewController*)live2BenchViewController;
- (NSString *)stringToSha1:(NSString *)hashkey;
-(NSString*)sha256HashFor:(NSString*)input;
- (NSString *) platform;
- (NSString *) platformString;
-(BOOL) textFieldShouldReturn:(UITextField *)textField;
//- (void) responseFromUController;

@end
