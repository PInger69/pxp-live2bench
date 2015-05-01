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
#import "SocialSharingManager.h"
#import "CustomAlertView.h"

@implementation AppDelegate
{
    ActionList                  * _actionList;
    RequestUserInfoAction       * requestInfoAction;
    RequestEulaAction           * requestEulaAction;
    ToastObserver               * _toastObserver;
}

@synthesize window;
@synthesize tabBarController;
@synthesize screenController    = _screenController;
@synthesize encoderManager      = _encoderManager;
@synthesize loginController     = _loginController;
@synthesize eulaViewController  = _eulaViewController;


// will be boolean NO, meaning the URL was not handled by the authenticating application
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    [[DBSession sharedSession]handleOpenURL:url];
    return [self.session handleOpenURL:url];
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            NSLog(@"App linked successfully!");
            // At this point you can start making API calls
        }
        return YES;
    }
    // Add whatever other url handling code your app requires here
    return NO;
}

//this loads first when you launch the app
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    APP_HEIGHT  = (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))?[[UIScreen mainScreen] bounds].size.width  : [[UIScreen mainScreen] bounds].size.height;
    APP_WIDTH   = (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))?[[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width;
    
    self.imageAssetManager = [[ImageAssetManager alloc]init];

    ///In order for crashlytics to work, we have to initialise it with the secret app key we get during sign up
    //we can also startwithapikey with a delay if we need to (not necessary)
    [Crashlytics startWithAPIKey:@"cd63aefd0fa9df5e632e5dc77360ecaae90108a1"];
    
    NSArray     * kpaths    = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString    * kdocumentsDirectory = [kpaths objectAtIndex:0];
    
    _screenController       = [[ScreenController alloc]init];
    _loginController        = [[LoginViewController alloc]init];
    _eulaViewController     = [[EulaModalViewController alloc]init];
    
    
    _actionList             = [[ActionList alloc]init];
    _userCenter             = [[UserCenter alloc]initWithLocalDocPath:kdocumentsDirectory];
    [_userCenter enableObservers:YES];
    
    _encoderManager = [[EncoderManager alloc]initWithLocalDocPath: kdocumentsDirectory];

    (void)[[SocialSharingManager alloc]initWithSocialOptions: @[@"Mail", @"Album", @"Dropbox", @"Facebook", @"GoogleDrive"]];

    
    self.tabBarController           = [[CustomTabBar alloc]init];
    self.window.rootViewController  = self.tabBarController;
    self.window.tintColor           = PRIMARY_APP_COLOR;
    [self.window makeKeyAndVisible];
    
    
    
    
    NSFileManager                * fileManager;
    fileManager = [NSFileManager defaultManager];
    
    // Set these variables before launching the app
    NSString* appKey = @"huc2enjbl496cq8";
    NSString* appSecret = @"0w4addrpazk3p9n";
    NSString *root = kDBRootDropbox; // Should be set to either kDBRootAppFolder or kDBRootDropbox
	// You can determine if you have App folder access or Full Dropbox along with your consumer key/secret
	// from https://dropbox.com/developers/apps
	
	// Look below where the DBSession is created to understand how to use DBSession in your app
	
	NSString* errorMsg = nil;
	if ([appKey rangeOfCharacterFromSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]].location != NSNotFound) {
		errorMsg = @"Make sure you set the app key correctly in DBRouletteAppDelegate.m";
	} else if ([appSecret rangeOfCharacterFromSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]].location != NSNotFound) {
		errorMsg = @"Make sure you set the app secret correctly in DBRouletteAppDelegate.m";
	} else if ([root length] == 0) {
		errorMsg = @"Set your root to use either App Folder of full Dropbox";
	} else {
		NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
		NSData *plistData = [NSData dataWithContentsOfFile:plistPath];
		NSDictionary *loadedPlist = [NSPropertyListSerialization propertyListFromData:plistData mutabilityOption:0 format:NULL errorDescription:NULL];
		NSString *scheme = [[[[loadedPlist objectForKey:@"CFBundleURLTypes"] objectAtIndex:0] objectForKey:@"CFBundleURLSchemes"] objectAtIndex:1];
		if ([scheme isEqual:@"db-2b2wsv4gcnfwi1x"]) {
			errorMsg = @"Set your URL scheme correctly in DBRoulette-Info.plist";
		}
	}
	
	DBSession* session =[[DBSession alloc] initWithAppKey:appKey appSecret:appSecret root:root];
	session.delegate = self; // DBSessionDelegate methods allow you to handle re-authenticating
	[DBSession setSharedSession:session];
	
	[DBRequest setNetworkRequestDelegate:self];
    
    
	if (errorMsg != nil) {
		[[[UIAlertView alloc] initWithTitle:@"Error Configuring DropBox Session" message:errorMsg
                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
		 show];
	}
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(logoutApp:) name:NOTIF_USER_LOGGED_OUT object:nil];
    
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
    
    
    return YES;
}


-(void)logoutApp:(NSNotification *)note
{
    if ([[note.userInfo objectForKey:@"success"]boolValue]){

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



#pragma mark -
#pragma mark DBSessionDelegate methods

- (void)sessionDidReceiveAuthorizationFailure:(DBSession*)session userId:(NSString *)userId {
	relinkUserId = userId;
	[[[UIAlertView alloc]
      initWithTitle:@"myplayXplay" message:@"Error authenticating DropBox please try to relink the account in the MyplayXplay settings page." delegate:self
      cancelButtonTitle:@"Ok" otherButtonTitles:nil]
	 show];
    PXPLog(@"Error authenticating DropBox");
}


#pragma mark -
#pragma mark UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)index {
	if (index != alertView.cancelButtonIndex) {
		[[DBSession sharedSession] linkUserId:relinkUserId fromController:self.tabBarController.selectedViewController];
	}
	relinkUserId = nil;
}


#pragma mark -
#pragma mark DBNetworkRequestDelegate methods

static int outstandingRequests;

- (void)networkRequestStarted {
	outstandingRequests++;
    [[NSNotificationCenter defaultCenter]postNotificationName:@"Show DB Upload" object:nil];
    if (outstandingRequests == 1) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	}
}

- (void)networkRequestStopped {
	outstandingRequests--;
	if (outstandingRequests == 0) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"Stop DB Upload" object:nil];
        		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	}
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
 
    //Richard
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
        PXPLog(succsess?@"   SUCCSESS":@"   FAIL");
    }];

    //Check Cloud
    [_actionList addItem:_encoderManager.checkForACloudAction   onItemStart:^{
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_UPDATE_SPINNER
                                                           object:nil
                                                         userInfo:[SpinnerView message:@"Checking for Cloud..." progress:.2 animated:YES]];
    } onItemFinish:^(BOOL succsess) {
        PXPLog(@"Cloud Connection Checking...");
        PXPLog(succsess?@"   SUCCSESS":@"   FAIL");
        weakSelf.loginController.hasInternet = succsess;
    }];
    
    //Check if user plist exists
    [_actionList addItem:[_userCenter checkLoginPlistAction]    onItemStart:^{
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_UPDATE_SPINNER
                                                           object:nil
                                                         userInfo:[SpinnerView message:@"Checking user credentials..." progress:.3 animated:YES]];
        
    } onItemFinish:^(BOOL succsess) {
        PXPLog(@"User Plist Checking...");
        PXPLog(succsess?@"   SUCCSESS":@"   FAIL");
        
        if(succsess){ // get the ID from the userCenter and sets it to the Manager so it can look for encoders
            weakEM.customerID = weakSelf.userCenter.customerID;
            weakEM.searchForEncoders = weakEM.hasWiFi;
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SIDE_TAGS_READY_FOR_L2B object:nil];
            // add to action list success list bransh
            
        } else {
            [weakAList addItem:weakReq];
            [weakAList addItem:weakEula onItemFinish:^(BOOL succsess) {
                if (succsess){
                    weakSelf.userCenter.isEULA = YES;
                    [weakSelf.userCenter writeAccountInfoToPlist];
                    weakEM.customerID = weakSelf.userCenter.customerID;
                    weakEM.searchForEncoders = weakEM.hasWiFi;
                    // present Eula and accept
                    // if info is okay and Eula is accepted
                    // save to plist
                }
                
            }];
            [weakAList addItem:[weakSelf.userCenter checkLoginPlistAction]];
        }
    }];
    

    
}

@end
