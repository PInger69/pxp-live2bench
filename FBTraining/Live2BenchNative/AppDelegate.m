
//
//  AppDelegate.m
//  Live2BenchNative
//
//  Created by DEV on 2013-01-21.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>
#import "AppDelegate.h"

#import "PxpURLProtocol.h"
#import "MockURLProtocol.h"
#import "EncoderClasses/EncoderManager.h"
#import "UserCenter.h"
#import "UtilityClasses/ActionList.h"
#import "AppDelegateActionPack.h"
#import "SpinnerView.h"
#import "ToastObserver.h"
#import "CustomAlertControllerQueue.h"
#import "PxpFilterDefaultTabViewController.h"
#import "DeviceAssetLibrary.h"
#import <DropboxSDK/DropboxSDK.h>

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

    [Crashlytics startWithAPIKey:@"cd63aefd0fa9df5e632e5dc77360ecaae90108a1"];
    
    //
    [DeviceAssetLibrary getInstance];
    
    // This is for the standalone build
    [NSURLProtocol registerClass:[PxpURLProtocol class]];
    [NSURLProtocol registerClass:[MockURLProtocol class]];
    
    APP_HEIGHT  = (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))?[[UIScreen mainScreen] bounds].size.width  : [[UIScreen mainScreen] bounds].size.height;
    APP_WIDTH   = (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))?[[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width;
    
    // This manages the thumbnails in the app
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    // This reads the
    
    ///In order for crashlytics to work, we have to initialise it with the secret app key we get during sign up
    //we can also startwithapikey with a delay if we need to (not necessary)


    
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
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(logoutApp:)        name:NOTIF_USER_LOGGED_OUT object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(memoryWarning:)    name:NOTIF_RECEIVE_MEMORY_WARNING object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(lostWifi)          name:NOTIF_LOST_WIFI object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(lostEvent:)        name:NOTIF_LIVE_EVENT_STOPPED object:nil];

    
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
    

    
    [_actionList start];
    
    _toastObserver = [[ToastObserver alloc]init];
    _toastObserver.parentView = self.window.rootViewController.view;
    
    _sharedFilter       = [[PxpFilter alloc]init];
    _sharedFilterTab    = [TabView sharedFilterTabBar];
    [_sharedFilterTab setPxpFilter:_sharedFilter];
    
//    [self testFileCheck:kdocumentsDirectory];
    
    return YES;
}


//-(void)testFileCheck:(NSString*)docPath
//{
//    
//    
//    
//   
//    
//    NSString * workingVideo     = [NSString stringWithFormat:@"%@/events/%@",docPath,@"2016-07-06_12-25-20_1dec3b359b4563602c32639acd4679263c5c3ca1_local/main_00hq.mp4"];
//    NSString * nonworkingVideo  =  [NSString stringWithFormat:@"%@/events/%@",docPath,@"2016-07-16_08-36-16_3e0d30e03e09dc4b23273796d757281c2726cb04_local/main_00hq.mp4"];
//
//    BOOL isDir = NO;
//    BOOL isFoundWorking = [[NSFileManager defaultManager] fileExistsAtPath:workingVideo isDirectory:&isDir];
//    NSLog(@"VIDEO WV FOUND:  %@",(isFoundWorking)? @"YES":@"NO");
//
//    BOOL isFoundNonWorking = [[NSFileManager defaultManager] fileExistsAtPath:nonworkingVideo isDirectory:&isDir];
//    NSLog(@"VIDEO NON FOUND: %@",(isFoundNonWorking)? @"YES":@"NO");
//
//    
//}


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
  
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:alertMessageTitle
                                                                    message:@"Wifi is lost. Please check your connection."
                                                             preferredStyle:UIAlertControllerStyleAlert];
    // build NO button
    UIAlertAction* cancelButtons = [UIAlertAction
                                    actionWithTitle:@"OK"
                                    style:UIAlertActionStyleCancel
                                    handler:^(UIAlertAction * action)
                                    {
                                        [[CustomAlertControllerQueue getInstance] dismissViewController:alert animated:YES completion:nil];
                                    }];
    [alert addAction:cancelButtons];
    
//    [[CustomAlertControllerQueue getInstance] dismissViewController:alert animated:YES completion:nil];
     [[CustomAlertControllerQueue getInstance] presentViewController:alert inController:self.tabBarController animated:YES style:AlertImportant completion:nil];
    lostWifiIsRun = true;
    [_encoderManager declareCurrentEvent:nil];
}

-(void)lostEvent:(NSNotification*)note{
    if (!lostWifiIsRun) {
        lostWifiIsRun = false;
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:alertMessageTitle
                                                                        message:@"Live Event is stopped"
                                                                 preferredStyle:UIAlertControllerStyleAlert];
        // build NO button
        UIAlertAction* cancelButtons = [UIAlertAction
                                        actionWithTitle:@"OK"
                                        style:UIAlertActionStyleCancel
                                        handler:^(UIAlertAction * action)
                                        {
                                            [[CustomAlertControllerQueue getInstance] dismissViewController:alert animated:YES completion:nil];
                                        }];
        [alert addAction:cancelButtons];
        
        [[CustomAlertControllerQueue getInstance] presentViewController:alert inController:self.tabBarController animated:YES style:AlertImportant completion:nil];     
    }
}

#pragma mark -

-(void)applicationDidBecomeActive:(UIApplication *)application
{


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
   
}

- (void)applicationWillTerminate:(UIApplication *)application
{

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

#pragma mark - Dropbox
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
//            [navigationController pushViewController:rootViewController.photoViewController animated:YES];
        }
        return YES;
    }
    
    return NO;
}



-(void)memoryWarning:(NSNotification*)note
{

}


@end
