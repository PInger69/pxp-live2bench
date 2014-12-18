//
//  AppDelegate.m
//  Live2BenchNative
//
//  Created by DEV on 2013-01-21.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "AppDelegate.h"

#import "Live2BenchViewController.h"
#import "EncoderClasses/EncoderManager.h"
#import "UserCenter.h"
#import "CalendarViewController.h"
#import <Crashlytics/Crashlytics.h>

@implementation AppDelegate
@synthesize window;
@synthesize tabBarController;
//@synthesize ctabBar=_ctabBar;
@synthesize lVController=_lVController;
//@synthesize bmViewController;
@synthesize screenController;
//@synthesize encoderManager = _encoderManager;

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
            //NSLog(@"App linked successfully!");
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
    ///In order for crashlytics to work, we have to initialise it with the secret app key we get during sign up
    //we can also startwithapikey with a delay if we need to (not necessary)
    [Crashlytics startWithAPIKey:@"cd63aefd0fa9df5e632e5dc77360ecaae90108a1"];
    
    // set up external screens
    screenController = [[ScreenController alloc]init];
  
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // Build Encoder Manager
    
    NSArray                      * kpaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString                     * kdocumentsDirectory = [kpaths objectAtIndex:0];
    NSFileManager                * fileManager;
    fileManager = [NSFileManager defaultManager];
    
    NSString *accountInformationPath = [kdocumentsDirectory stringByAppendingPathComponent:@"accountInformation.plist"];
    NSMutableDictionary *accountInfo = [[NSMutableDictionary alloc] initWithContentsOfFile: accountInformationPath];
    NSString * custID = [accountInfo objectForKey:@"customer"];
    
    _encoderManager = [[EncoderManager alloc]initWithID: custID
                                           localDocPath: kdocumentsDirectory];
    
    
    
    _userCenter     = [[UserCenter alloc]initWithLocalDocPath:kdocumentsDirectory];

    [_userCenter enableObservers:_encoderManager.hasInternet];
    // end Build encoder manager
    
    self.tabBarController           = [[CustomTabBar alloc]init];
    self.window.rootViewController  = self.tabBarController;
    self.window.tintColor           = [UIColor orangeColor];
    [self.window makeKeyAndVisible];
    uController                     = [[UtilitiesController alloc]init];
    globals                         = [Globals instance];

    
    globals.LOCAL_DOCS_PATH         = [[NSString alloc]initWithString:documentsDirectory];
    globals.LOG_PATH                = [globals.LOCAL_DOCS_PATH stringByAppendingPathComponent:@"log.plist"];
    globals.BOOKMARK_PATH           = [globals.LOCAL_DOCS_PATH stringByAppendingPathComponent:@"bookmark"];
    globals.BOOKMARK_TAGS_PATH      = [globals.BOOKMARK_PATH stringByAppendingPathComponent:@"bookmarktags.plist"];
    globals.BOOKMARK_QUEUE_PATH     = [globals.BOOKMARK_PATH stringByAppendingPathComponent:@"bookmarkqueue.plist"];
    globals.BOOKMARK_VIDEO_PATH     = [globals.BOOKMARK_PATH stringByAppendingPathComponent:@"bookmarkvideo"];
    globals.EVENTS_PATH             = [globals.LOCAL_DOCS_PATH stringByAppendingPathComponent:@"events"];
    globals.TAGS_PLIST_PATH         = [globals.LOCAL_DOCS_PATH stringByAppendingString:@"tags.plist"];
    BOOL isDir;
    if(![[NSFileManager defaultManager] fileExistsAtPath:globals.EVENTS_PATH isDirectory:&isDir])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:globals.EVENTS_PATH withIntermediateDirectories:YES attributes:nil error:NULL];
    }

    globals.EVENT_NAME= @"";
    globals.WHICH_SPORT = @"";
    globals.CURRENT_PLAYBACK_EVENT = @"";
    globals.ACCOUNT_PLIST_PATH=[globals.LOCAL_DOCS_PATH stringByAppendingPathComponent:@"accountInformation.plist"];
   // globals.DOWNLOADED_EVENTS_PLIST = [globals.LOCAL_DOCS_PATH stringByAppendingPathComponent:@"downloadedEvents.plist"];
    //make sure live folder is cleared when start the app
    if ([[NSFileManager defaultManager] fileExistsAtPath:[globals.EVENTS_PATH stringByAppendingPathComponent:@"live"]]) {
        [[NSFileManager defaultManager]removeItemAtPath:[globals.EVENTS_PATH stringByAppendingPathComponent:@"live"] error:nil];
    }
    //get all the local events which have offline tags
    //LocalEvents.plist saved all the local events which have offline tags
    if ([[NSFileManager defaultManager] fileExistsAtPath:[globals.EVENTS_PATH stringByAppendingPathComponent:@"LocalEvents.plist"]]) {
        globals.LOCAL_MODIFIED_EVENTS = [[NSMutableArray alloc]initWithContentsOfFile:[globals.EVENTS_PATH stringByAppendingPathComponent:@"LocalEvents.plist"]];
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:globals.LOG_PATH]) {
        globals.LOG_INFO = [[NSMutableDictionary alloc]initWithContentsOfFile:globals.LOG_PATH];
    }else{
        globals.LOG_INFO = [[NSMutableDictionary alloc]init];
    }
    NSMutableDictionary *bookmarkTags;
    NSString *bookmarkTagPath = globals.BOOKMARK_TAGS_PATH;
    if ([[NSFileManager defaultManager] fileExistsAtPath: bookmarkTagPath])
    {
        bookmarkTags = [[NSMutableDictionary alloc]initWithContentsOfFile:bookmarkTagPath];
    }else{
        bookmarkTags = [[NSMutableDictionary alloc]init];
    }
    globals.BOOKMARK_TAGS = bookmarkTags;
    
    //check if user has already logged in on this device at least once
    globals.ACCOUNT_FIELDS = [[NSArray alloc]initWithObjects:@"emailAddress",@"password",@"authorization",@"customer",@"hid",@"tagColour",nil];
    
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
    

    return YES;
}

#pragma mark -
#pragma mark DBSessionDelegate methods

- (void)sessionDidReceiveAuthorizationFailure:(DBSession*)session userId:(NSString *)userId {
	relinkUserId = userId;
	[[[UIAlertView alloc]
      initWithTitle:@"myplayXplay" message:@"Error authenticating DropBox please try to relink the account in the MyplayXplay settings page." delegate:self
      cancelButtonTitle:@"Ok" otherButtonTitles:nil]
	 show];
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
    if (globals.CURRENT_APP_STATE != apstNotInited)
    {
        globals.CURRENT_APP_STATE = apstReactiveCheck;
    }

}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    if(!globals.HAS_MIN || (globals.HAS_MIN && !globals.eventExistsOnServer)){
        [uController writeTagsToPlist];
    }
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

    NSFileManager *fileManager = [NSFileManager defaultManager];
    // check for login and eula
    NSString *path = [globals.LOCAL_DOCS_PATH stringByAppendingPathComponent:@"accountInformation.plist"];

    if ([fileManager fileExistsAtPath: path])
    {
        globals.IS_LOGGED_IN=TRUE;
        //set eula boolean value depending on whether or not user has accepted -- from the users info
        globals.IS_EULA = [globals.ACCOUNT_INFO objectForKey:@"eula"];
    }

    [self.lVController refreshUI];
   
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    if(!globals.HAS_MIN || (globals.HAS_MIN && !globals.eventExistsOnServer)){
        [uController writeTagsToPlist];
    }
    if (globals.HAS_MIN) {
        NSMutableArray *unfinishedTagArray;
        
        //tags in current event haven't processed yet (in globals.BOOKMARK_QUEUE)
        if (globals.BOOKMARK_QUEUE.count > 0) {
            for(NSDictionary *dict in globals.BOOKMARK_QUEUE){
                if (!unfinishedTagArray) {
                    unfinishedTagArray = [NSMutableArray arrayWithObject:[dict objectForKey:@"tag"]];
                }else{
                    [unfinishedTagArray addObject:[dict objectForKey:@"tag"]];
                }
            }
        }
        
        //tag videos haven't been converted by AV Foundation (in globals.TAGS_DOWNLOADED_FROM_SERVER)
        if (globals.TAGS_DOWNLOADED_FROM_SERVER.count > 0) {
            for(NSDictionary *dict in globals.TAGS_DOWNLOADED_FROM_SERVER){
                if (!unfinishedTagArray) {
                    unfinishedTagArray = [NSMutableArray arrayWithObject:[dict objectForKey:@"tag"]];
                }else{
                    [unfinishedTagArray addObject:[dict objectForKey:@"tag"]];
                }
            }
        }
        
        //tags not sucessfully processed (lobals.BOOKMARK_TAGS_UNFINISHED) from the past
        if (globals.BOOKMARK_TAGS_UNFINISHED.count > 0) {
            for(NSDictionary *dict in globals.BOOKMARK_TAGS_UNFINISHED){
                if (!unfinishedTagArray) {
                    unfinishedTagArray = [NSMutableArray arrayWithObject:dict];
                }else{
                    [unfinishedTagArray addObject:dict];
                }
            }
        }
        
        if(![[NSFileManager defaultManager]fileExistsAtPath:globals.BOOKMARK_QUEUE_PATH]){
            [[NSFileManager defaultManager]createFileAtPath:globals.BOOKMARK_QUEUE_PATH contents:nil attributes:nil];
        }
        [unfinishedTagArray writeToFile:globals.BOOKMARK_QUEUE_PATH atomically:YES];
    }
   
    //make sure live folder is cleared when close the app
    if ([[NSFileManager defaultManager] fileExistsAtPath:[globals.EVENTS_PATH stringByAppendingPathComponent:@"live"]]) {
        [[NSFileManager defaultManager]removeItemAtPath:[globals.EVENTS_PATH stringByAppendingPathComponent:@"live"] error:nil];
    }
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (UIWindow*)window {
    if (window == nil) {
        window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    
    return window;
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end
