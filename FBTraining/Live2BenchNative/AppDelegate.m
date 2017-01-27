
//
//  AppDelegate.m
//  Live2BenchNative
//
//  Created by DEV on 2013-01-21.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <Fabric/Fabric.h>
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

@interface AppDelegate()

@property (nonatomic, strong) ToastObserver* toastObserver;
@property (nonatomic, strong) ActionList* actionList;
@property (nonatomic, strong) RequestUserInfoAction* requestInfoAction;
@property (nonatomic, strong) RequestEulaAction* requestEulaAction;

@property (nonatomic, assign) BOOL lostWifiIsRun;

@end

@implementation AppDelegate

@synthesize window;

//this loads first when you launch the app
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    [Fabric with:@[[Crashlytics class]]];

//    [Crashlytics startWithAPIKey:@"cd63aefd0fa9df5e632e5dc77360ecaae90108a1"];
    
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
    
    self.theme = [PxpTheme new];
    [self.theme activate];
    
    self.imageAssetManager.pathForFolderContainingImages = imageAssets;
    
    self.screenController       = [[ScreenController alloc]init];
    self.loginController        = [[LoginViewController alloc]init];
    self.eulaViewController     = [[EulaModalViewController alloc]init];
    self.actionList             = [[ActionList alloc]init];
    self.userCenter             = [[UserCenter alloc]initWithLocalDocPath:kdocumentsDirectory];
    self.encoderManager         = [[EncoderManager alloc]initWithLocalDocPath: kdocumentsDirectory];

    self.tabBarController           = [[CustomTabBar alloc]init];
    self.window.rootViewController  = self.tabBarController;
    self.window.tintColor           = PRIMARY_APP_COLOR;
    [self.window makeKeyAndVisible];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(logoutApp:)        name:NOTIF_USER_LOGGED_OUT object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(memoryWarning:)    name:NOTIF_RECEIVE_MEMORY_WARNING object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(lostWifi)          name:NOTIF_LOST_WIFI object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(lostEvent:)        name:NOTIF_LIVE_EVENT_STOPPED object:nil];

    
    // action creation
    self.requestInfoAction = [[RequestUserInfoAction alloc]initWithAppDelegate:self];
    self.requestEulaAction = [[RequestEulaAction alloc]initWithAppDelegate:self];
    
    // run main logic for status checking
    
    [self actionListBlock];
    
    [self.actionList onFinishList:^{
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_CLOSE_SPINNER object:nil];
    }];
    
    [self.actionList start];
    
    self.toastObserver = [[ToastObserver alloc]init];
    self.toastObserver.parentView = self.window.rootViewController.view;
    self.sharedFilter       = [[PxpFilter alloc]init];
    self.sharedFilterTab    = [TabView sharedFilterTabBar];
    [self.sharedFilterTab setPxpFilter:self.sharedFilter];
    
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    PXPDeviceLog(@"### APP Started %@",[formatter stringFromDate:[NSDate new]]);
    
    return YES;
}


-(void)logoutApp:(NSNotification *)note
{
    if ([[note.userInfo objectForKey:@"success"]boolValue]){

        // when log out it will clear our all encoders
        NSArray * temp = [self.encoderManager.authenticatedEncoders copy];
        for (Encoder * enc in temp) {
            [self.encoderManager unRegisterEncoder:enc];
        }
        
        self.loginController        = [[LoginViewController alloc]init];
        self.eulaViewController     = [[EulaModalViewController alloc]init];
        [self.actionList clear];
        [self actionListBlock];
        
        [self.actionList onFinishList:^{
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_CLOSE_SPINNER object:nil];
//            _loginController        = nil;
//            _eulaViewController     = nil;
            
        }];
        
        [self.actionList start];
        PXPDeviceLog(@"USER LOGGED OUT");
    }
}

-(void)lostWifi{
    NSString *string = [NSString stringWithFormat:@"encoder count:%lu",(unsigned long)self.encoderManager.authenticatedEncoders.count];
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
    
    PXPDeviceLog(@"!Wifi is lost");
     [[CustomAlertControllerQueue getInstance] presentViewController:alert inController:self.tabBarController animated:YES style:AlertImportant completion:nil];
    self.lostWifiIsRun = true;
    [self.encoderManager declareCurrentEvent:nil];
}

-(void)lostEvent:(NSNotification*)note{
    if (!self.lostWifiIsRun) {
        self.lostWifiIsRun = false;
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
    PXPDeviceLog(@"!applicationDidEnterBackground");
}

- (void)applicationDidEnterForeground:(UIApplication *)application
{
   PXPDeviceLog(@"!applicationDidEnterForeground");
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    PXPDeviceLog(@"!!! app Terminate");
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
    [SpinnerView initTheGlobalSpinner];
 
    __block EncoderManager * weakEM             = self.encoderManager;
    __block AppDelegate    * weakSelf           = self;
    __block ActionList     * weakAList          = self.actionList;
    __block id<ActionListItem> weakReq          = [self.requestInfoAction reset];
    __block id<ActionListItem> weakEula         = [self.requestEulaAction reset];
   
    
    
    
    //Check wifi
    [self.actionList addItem:self.encoderManager.checkForWiFiAction     onItemStart:^{
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_OPEN_SPINNER
                                                           object:nil
                                                         userInfo:[SpinnerView message:@"Checking for WiFi..." progress:.1 animated:YES]];
    } onItemFinish:^(BOOL succsess) {
        PXPLog(@"WIFI Checking...");
        PXPLog(succsess?@"   SUCCESS":@"   FAIL");
    }];

    //Check Cloud
    [self.actionList addItem:self.encoderManager.checkForACloudAction   onItemStart:^{
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_UPDATE_SPINNER
                                                           object:nil
                                                         userInfo:[SpinnerView message:@"Checking for Cloud..." progress:.2 animated:YES]];
    } onItemFinish:^(BOOL succsess) {
        PXPLog(@"Cloud Connection Checking...");
        PXPLog(succsess?@"   SUCCESS":@"   FAIL");
        if (!succsess)PXPLog(@"   No Connection to cloud found!");
        weakSelf.loginController.hasInternet = succsess;
    }];
    
    //Check if user plist exists
    [self.actionList addItem:[self.userCenter checkLoginPlistAction]    onItemStart:^{
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

+(AppDelegate*) instance {
    return (AppDelegate*) [[UIApplication sharedApplication] delegate];
}

@end
