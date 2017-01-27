//
//  AppDelegate.h
//  Live2BenchNative
//
//  Created by DEV on 2013-01-21.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTabBar.h"

#import <Foundation/Foundation.h>
#import <netinet/in.h>
#include <arpa/inet.h>
#import "ScreenController.h"
#import "ImageAssetManager.h"
#import "LoginViewController.h"
#import "EulaModalViewController.h"

#import "TabView.h"
#import "PxpFilter.h"
#import "PxpTheme.h"

@class CustomTabBar;
@class EncoderManager;
@class UserCenter;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate,UIAlertViewDelegate>
{
    IBOutlet UIWindow   * window;
}

@property (strong, nonatomic) UIWindow                  * window;
@property (strong, nonatomic) CustomTabBar              * tabBarController;
@property (strong, nonatomic) ScreenController          * screenController; // this is wher you get access to otherscreens
@property (strong, nonatomic) EncoderManager            * encoderManager;
@property (strong, nonatomic) UserCenter                * userCenter;

@property (strong, nonatomic) LoginViewController       * loginController;
@property (strong, nonatomic) EulaModalViewController   * eulaViewController;
@property (strong, nonatomic) ImageAssetManager         * imageAssetManager;
@property (strong, nonatomic) TabView                   * sharedFilterTab;
@property (strong, nonatomic) PxpFilter                 * sharedFilter;

@property (strong, nonatomic) PxpTheme                  * theme;

+(AppDelegate*) instance;


@end
