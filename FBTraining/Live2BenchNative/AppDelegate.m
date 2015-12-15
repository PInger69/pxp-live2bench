
//
//  AppDelegate.m
//  Live2BenchNative
//
//  Created by DEV on 2013-01-21.
//  Copyright (c) 2013 DEV. All rights reserved.
//


#import "AppDelegate.h"
#import <Crashlytics/Crashlytics.h>

#import "EncoderClasses/EncoderManager.h"
#import "UserCenter.h"
#import "UtilityClasses/ActionList.h"
#import "AppDelegateActionPack.h"
#import "SpinnerView.h"
#import "ToastObserver.h"
#import "CustomAlertView.h"
#import "PxpFilterDefaultTabViewController.h"

@implementation AppDelegate
{
    ActionList                  * _actionList;
    RequestUserInfoAction       * requestInfoAction;
    RequestEulaAction           * requestEulaAction;
    ToastObserver               * _toastObserver;
    
    BOOL                        lostWifiIsRun;
}

@synthesize window;
@synthesize tabBarController;
@synthesize screenController    = _screenController;
@synthesize encoderManager      = _encoderManager;
@synthesize loginController     = _loginController;
@synthesize eulaViewController  = _eulaViewController;


//this loads first when you launch the app
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    APP_HEIGHT  = (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))?[[UIScreen mainScreen] bounds].size.width  : [[UIScreen mainScreen] bounds].size.height;
    APP_WIDTH   = (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))?[[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width;
    
    // This manages the thumbnails in the app
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    

    
    ///In order for crashlytics to work, we have to initialise it with the secret app key we get during sign up
    //we can also startwithapikey with a delay if we need to (not necessary)
    [Crashlytics startWithAPIKey:@"cd63aefd0fa9df5e632e5dc77360ecaae90108a1"];
    
    NSArray     * kpaths    = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString    * kdocumentsDirectory = [kpaths objectAtIndex:0];
    
    self.imageAssetManager = [[ImageAssetManager alloc]init];
   
    NSString * imageAssets = [kdocumentsDirectory stringByAppendingPathComponent:@"imageAssets"];
    BOOL isDir = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:imageAssets isDirectory:&isDir];
    if ( !isDir){
        [[NSFileManager defaultManager] createDirectoryAtPath:imageAssets withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    self.imageAssetManager.pathForFolderContainingImages = imageAssets;
    
    
    
    
    _screenController       = [[ScreenController alloc]init];
    _loginController        = [[LoginViewController alloc]init];
    _eulaViewController     = [[EulaModalViewController alloc]init];
    
    
    _actionList             = [[ActionList alloc]init];
    _userCenter             = [[UserCenter alloc]initWithLocalDocPath:kdocumentsDirectory];
    //[_userCenter enableObservers:YES];
    
    _encoderManager = [[EncoderManager alloc]initWithLocalDocPath: kdocumentsDirectory];

    

    
    self.tabBarController           = [[CustomTabBar alloc]init];
    self.window.rootViewController  = self.tabBarController;
    self.window.tintColor           = PRIMARY_APP_COLOR;
    [self.window makeKeyAndVisible];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(logoutApp:) name:NOTIF_USER_LOGGED_OUT object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(memoryWarning:) name:NOTIF_RECEIVE_MEMORY_WARNING object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(lostWifi) name:NOTIF_LOST_WIFI object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(lostEvent:) name:NOTIF_LIVE_EVENT_STOPPED object:nil];

    
    // action creation
    requestInfoAction = [[RequestUserInfoAction alloc]initWithAppDelegate:self];
    requestEulaAction = [[RequestEulaAction alloc]initWithAppDelegate:self];
    
    // run main logic for status checking

    
    [self actionListBlock];
    
    [_actionList onFinishList:^{
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_CLOSE_SPINNER object:nil];
//        _loginController        = nil;
//        _eulaViewController     = nil;

    }];
    
    [CustomAlertView staticInit];
    
    [_actionList start];
    
    _toastObserver = [[ToastObserver alloc]init];
    _toastObserver.parentView = self.window.rootViewController.view;
    
    _sharedFilter       = [[PxpFilter alloc]init];
    _sharedFilterTab    = [TabView sharedFilterTabBar];
    [_sharedFilterTab setPxpFilter:_sharedFilter];
    return YES;
}


-(void)logoutApp:(NSNotification *)note
{
    if ([[note.userInfo objectForKey:@"success"]boolValue]){

        // when log out it will clear our all encoders
        for (Encoder * enc in _encoderManager.authenticatedEncoders) {
            [_encoderManager unRegisterEncoder:enc];
        }
        
        _loginController        = [[LoginViewController alloc]init];
        _eulaViewController     = [[EulaModalViewController alloc]init];
        [_actionList clear];
        [self actionListBlock];
        
        [_actionList onFinishList:^{
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_CLOSE_SPINNER object:nil];
//            _loginController        = nil;
//            _eulaViewController     = nil;
            
        }];
        
        [_actionList start];
    }
}

-(void)lostWifi{
    NSString *string = [NSString stringWithFormat:@"encoder count:%lu",(unsigned long)_encoderManager.authenticatedEncoders.count];
    PXPLog(string);
    CustomAlertView *alert = [[CustomAlertView alloc]initWithTitle:@"No Wifi" message:@"Wifi is lost. Please check your connection." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert showView];
    lostWifiIsRun = true;
    [_encoderManager declareCurrentEvent:nil];
}

-(void)lostEvent:(NSNotification*)note{
    if (!lostWifiIsRun) {
        lostWifiIsRun = false;
        CustomAlertView *alert = [[CustomAlertView alloc]initWithTitle:@"Event Stopped" message:@"Live Event is stopped" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert showView];
    }
}

#pragma mark -
#pragma mark UIAlertViewDelegate methods

- (void)alertView:(CustomAlertView *)alertView clickedButtonAtIndex:(NSInteger)index {
    relinkUserId = nil;
    [alertView viewFinished];
}

-(void)applicationDidBecomeActive:(UIApplication *)application
{
//    if (globals.CURRENT_APP_STATE != apstNotInited)
//    {
//        globals.CURRENT_APP_STATE = apstReactiveCheck;
//    }

}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
//    if(!globals.HAS_MIN || (globals.HAS_MIN && !globals.eventExistsOnServer)){
//        [uController writeTagsToPlist];
//    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    //save all the tags when the app exit
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.  
    
}

- (void)applicationDidEnterForeground:(UIApplication *)application
{
    // check for login and eula

//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    // check for login and eula
//    NSString *path = [globals.LOCAL_DOCS_PATH stringByAppendingPathComponent:@"accountInformation.plist"];
//
//    if ([fileManager fileExistsAtPath: path])
//    {
//        globals.IS_LOGGED_IN=TRUE;
//        //set eula boolean value depending on whether or not user has accepted -- from the users info
//        globals.IS_EULA = [globals.ACCOUNT_INFO objectForKey:@"eula"];
//    }

//    [self.lVController refreshUI];
   
}

- (void)applicationWillTerminate:(UIApplication *)application
{
//    if(!globals.HAS_MIN || (globals.HAS_MIN && !globals.eventExistsOnServer)){
//        [uController writeTagsToPlist];
//    }
//    if (globals.HAS_MIN) {
//        NSMutableArray *unfinishedTagArray;
//        
//        //tags in current event haven't processed yet (in globals.BOOKMARK_QUEUE)
//        if (globals.BOOKMARK_QUEUE.count > 0) {
//            for(NSDictionary *dict in globals.BOOKMARK_QUEUE){
//                if (!unfinishedTagArray) {
//                    unfinishedTagArray = [NSMutableArray arrayWithObject:[dict objectForKey:@"tag"]];
//                }else{
//                    [unfinishedTagArray addObject:[dict objectForKey:@"tag"]];
//                }
//            }
//        }
//        
//        //tag videos haven't been converted by AV Foundation (in globals.TAGS_DOWNLOADED_FROM_SERVER)
//        if (globals.TAGS_DOWNLOADED_FROM_SERVER.count > 0) {
//            for(NSDictionary *dict in globals.TAGS_DOWNLOADED_FROM_SERVER){
//                if (!unfinishedTagArray) {
//                    unfinishedTagArray = [NSMutableArray arrayWithObject:[dict objectForKey:@"tag"]];
//                }else{
//                    [unfinishedTagArray addObject:[dict objectForKey:@"tag"]];
//                }
//            }
//        }
//        
//        //tags not sucessfully processed (lobals.BOOKMARK_TAGS_UNFINISHED) from the past
//        if (globals.BOOKMARK_TAGS_UNFINISHED.count > 0) {
//            for(NSDictionary *dict in globals.BOOKMARK_TAGS_UNFINISHED){
//                if (!unfinishedTagArray) {
//                    unfinishedTagArray = [NSMutableArray arrayWithObject:dict];
//                }else{
//                    [unfinishedTagArray addObject:dict];
//                }
//            }
//        }
//        
//        if(![[NSFileManager defaultManager]fileExistsAtPath:globals.BOOKMARK_QUEUE_PATH]){
//            [[NSFileManager defaultManager]createFileAtPath:globals.BOOKMARK_QUEUE_PATH contents:nil attributes:nil];
//        }
//        [unfinishedTagArray writeToFile:globals.BOOKMARK_QUEUE_PATH atomically:YES];
//    }
//   
    //make sure live folder is cleared when close the app
//    if ([[NSFileManager defaultManager] fileExistsAtPath:[globals.EVENTS_PATH stringByAppendingPathComponent:@"live"]]) {
//        [[NSFileManager defaultManager]removeItemAtPath:[globals.EVENTS_PATH stringByAppendingPathComponent:@"live"] error:nil];
//    }
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (UIWindow*)window {
    if (window == nil) {
        window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    
    return window;
}


#pragma mark -
#pragma mark Start Up ActionList methods

/**
 *  this is where the make actionlist code resides
 */
-(void)actionListBlock
{
 
    //Richard I really don't know what to do anymore, at the moment i'm just praciting typing which i'm pretty sure i don't need practice doing, but i need to do something, theis is work. I'm typing to type with my eyes closed. since this is the only chanllange that I can think of/ Please somenoe . give me an task/ please please please/ I'm gpoing to type the alphabet. abcdefghijkl,mp[qrstuvwxyz/ now l's see if i'm orrect/not too bad/ 
    [SpinnerView initTheGlobalSpinner];
 
    __block EncoderManager * weakEM             = _encoderManager;
    __block AppDelegate    * weakSelf           = self;
    __block ActionList     * weakAList          = _actionList;
    __block id<ActionListItem> weakReq          = [requestInfoAction reset];
    __block id<ActionListItem> weakEula         = [requestEulaAction reset];
   
    
    
    
    //Check wifi
    [_actionList addItem:_encoderManager.checkForWiFiAction     onItemStart:^{
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_OPEN_SPINNER
                                                           object:nil
                                                         userInfo:[SpinnerView message:@"Checking for WiFi..." progress:.1 animated:YES]];
    } onItemFinish:^(BOOL succsess) {
        PXPLog(@"WIFI Checking...");
        PXPLog(succsess?@"   SUCCESS":@"   FAIL");
    }];

    //Check Cloud
    [_actionList addItem:_encoderManager.checkForACloudAction   onItemStart:^{
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_UPDATE_SPINNER
                                                           object:nil
                                                         userInfo:[SpinnerView message:@"Checking for Cloud..." progress:.2 animated:YES]];
    } onItemFinish:^(BOOL succsess) {
        PXPLog(@"Cloud Connection Checking...");
        PXPLog(succsess?@"   SUCCESS":@"   FAIL");
        if (!succsess)PXPLog(@"   NO INTERNET FOUND!");
        weakSelf.loginController.hasInternet = succsess;
    }];
    
    //Check if user plist exists
    [_actionList addItem:[_userCenter checkLoginPlistAction]    onItemStart:^{
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_UPDATE_SPINNER
                                                           object:nil
                                                         userInfo:[SpinnerView message:@"Checking user credentials..." progress:.3 animated:YES]];
        
    } onItemFinish:^(BOOL succsess) {
        PXPLog(@"User credentials on device Checking...");
        PXPLog(succsess?@"   SUCCESS":@"   FAIL");
        
        if(succsess){ // get the ID from the userCenter and sets it to the Manager so it can look for encoders
//            weakEM.customerID = weakSelf.userCenter.customerID;
            weakEM.searchForEncoders = [Utility hasWiFi];
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SIDE_TAGS_READY_FOR_L2B object:nil];
            // add to action list success list bransh
            
        } else {
            PXPLog(@"User credentials on cloud Checking...");

            
            [weakAList addItem:weakReq];
            [weakAList addItem:weakEula onItemFinish:^(BOOL succsess) {
                if (succsess){
                    PXPLog(succsess?@"   SUCCESS":@"   FAIL");
                    weakSelf.userCenter.isEULA = YES;
                    [weakSelf.userCenter writeAccountInfoToPlist];
//                    weakEM.customerID = weakSelf.userCenter.customerID;
                    weakEM.searchForEncoders = [Utility hasWiFi];
                    // present Eula and accept
                    // if info is okay and Eula is accepted
                    // save to plist
                }
                
            }];
            [weakAList addItem:[weakSelf.userCenter checkLoginPlistAction]];
        }
    }];
    

    
}


-(void)memoryWarning:(NSNotification*)note
{

}


@end
