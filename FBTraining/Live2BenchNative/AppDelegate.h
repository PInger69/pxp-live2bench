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
#import <FacebookSDK/FacebookSDK.h>
#import <DropboxSDK/DropboxSDK.h>
#import "ScreenController.h"
#import "ImageAssetManager.h"
#import "LoginViewController.h"
#import "EulaModalViewController.h"


@class CustomTabBar;
@class EncoderManager;
@class UserCenter;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate,DBSessionDelegate,DBNetworkRequestDelegate>
{
    IBOutlet UIWindow   * window;
    NSString            * relinkUserId; // TODO move out

}

@property (strong, nonatomic) UIWindow                  * window;
@property (strong, nonatomic) CustomTabBar              * tabBarController;
@property (strong, nonatomic) FBSession                 * session; // TODO MOVE OUT
@property (strong, nonatomic) ScreenController          * screenController; // this is wher you get access to otherscreens
@property (strong, nonatomic) EncoderManager            * encoderManager;
@property (strong, nonatomic) UserCenter                * userCenter;

@property (strong, nonatomic) LoginViewController       * loginController;
@property (strong, nonatomic) EulaModalViewController   * eulaViewController;
@property (strong, nonatomic) ImageAssetManager         * imageAssetManager;

@end
