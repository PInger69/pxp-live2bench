//
//  CustomTabBar.h
//  Live2BenchNative
//
//  Created by DEV on 2013-01-21.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "LogoViewController.h"
#import "CalendarViewController.h"
#import "Live2BenchViewController.h"
#import "ClipViewController.h"
#import "ListViewController.h"
#import "BookmarkViewController.h"
#import "EulaModalViewController.h"
#import "LoginViewController.h"
#import "Globals.h"
#import "SpinnerView.h"
#import "UtilitiesController.h"
#import "Toast.h"
//#import "AppQueue.h"
#import "VideoPlayer.h"
#import "TabBarButton.h"
#import "Reachability.h"
#import "UploadButton.h"

@class Toast;


@interface CustomTabBar : UITabBarController <NSNetServiceBrowserDelegate,NSNetServiceDelegate>{
    Toast *toast; //when new tag is received, pop up the toast with tag name and user's colour
    NSTimer *toastTimer; //timer controls the display of toast
    BOOL toastAnimationDidStart; //the animation of toast did start
    Globals *globals;
    UtilitiesController *uController;
    NSNetServiceBrowser *serviceBrowser; //serviceBrowser searches for services
    NSMutableArray *services; //array of netservices which are detected
    int timerCounter; //timer counter waiting for server responses
    int lastAppState; //the old app state
    BOOL firstLoadGoToCalendar; //when the app is opened, should it go to calendar view or live2bench view
    UIPopoverController *chooseIPPopup; //if there are more than one encoder detected, pop up "chooseIPPopup" to give the user option to choose which encoder to use
    NSMutableDictionary *dictOfIPs; //dictionary of all IPs detected
    LoginViewController *loginViewController;
    UITabBar *tBar;
}

@property (nonatomic,strong) UITabBar *tBar;
@property (nonatomic,strong) SpinnerView *spinnerView;
@property (nonatomic,strong) LoginViewController *loginViewController;
@property (nonatomic,strong) UIProgressView *loadingProgressView;  //when open the app, display the loading progress
@property (nonatomic,strong) UILabel *progressViewTextLabel;
@property (nonatomic,strong) UILabel *uploadLocalTagsLabel; //display this label if there are local tags uploading to the server
@property (nonatomic,strong) NSTimer *updateAppStateTimer; //timer to call method updateAppState
@property (nonatomic)BOOL waitingEncoderSelection; //used to reset the timer counter when waiting the user selects the right encoder
//flash button used to indicate local tags are uploading to the server
@property (nonatomic,strong) UploadButton *uploadLocalTagButton;
//uitextview shows the uploading local tags progress
//@property (nonatomic,strong)UITextView *popoverView;
@property (nonatomic,strong)UIPopoverController *popoverController;



//create custom tabbar's titiles
-(void) addCustomElements;
//hide the native IOS tab bar
-(void) hideExistingTabBar;
//select the tab at index "tabID"
-(void) selectTab:(int)tabID;
//-(void)popupForTeamPlayerSelection; //there are two teams, the user needs to choose which team's players he/she wants to tag in the app

@end

//app states (used in the initializing switch() statement)
enum{
    apstNotInited           = 0,
    apstReactiveCheck       = 1, //used for when control/notification center is opened and closed (similar to apstNotInited)
    apstNoWifi              = 2,
    apstHasWifi             = 3,
    apstWaitGameTags        = 4,
    apstWaitEvents          = 5,
    apstWaitEncStatus       = 6,
    apstNoMin               = 7,
    apstMinNoLive           = 8,
    apstMinLive             = 9,
    apstWaitLogin           = 10,
    apstWaitEula            = 11,
    apstLoginCheck          = 12,
    apstEulaCheck           = 13,
    apstWaitPlaybackStrt    = 14,
    apstWaitTeams           = 15,
    apstEncStatusCheck      = 16,
    apstSkipTimer           = 99 //used for getting out of switch without stopping the timer
};
