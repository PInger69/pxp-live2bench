//
//  UserCenter.m
//  Live2BenchNative
//
//  Created by dev on 2014-12-04.
//  Copyright (c) 2014 DEV. All rights reserved.
//




// This class is the center point for all user data such as the tag names and other user data
// all plists will be loaded to this class if it should be accsessed
// it will manage making, updating and retreving pl data
#import "UserCenter.h"
#import "ActionList.h"
#import "UserCenterActionPack.h" // This has all the user Actions
#import "CloudEncoder.h"// to get defins

#define PLIST_THUMBNAILS        @"Thumbnails.plist"
#define PLIST_PLAYER_SETUP      @"players-setup.plist"
#define PLIST_ACCOUNT_INFO      @"accountInformation.plist"


@implementation UserCenter
{
    NSString        * localPath;
    NSFileManager   * fileManager;
    id              tagNameObserver;
    BOOL            observering;
    
    NSDictionary    * rawResponce;
    
    CheckLoginPlistAction     * _checkLoginPlistAction;
}

@synthesize tagNames                = _tagNames;
@synthesize userPick                = _userPick;
@synthesize currentEventThumbnails  = _currentEventThumbnails;
@synthesize isLoggedIn              = _isLoggedIn;
@synthesize isEULA                  = _isEULA;

@synthesize accountInfoPath         = _accountInfoPath;

// about the userData

@synthesize customerID              = _customerID;
@synthesize customerAuthorization   = _customerAuthorization;
@synthesize customerEmail           = _customerEmail;
@synthesize customerHid             = _customerHid;
@synthesize customerColor           = _customerColor;


-(id)initWithLocalDocPath:(NSString*)aLocalDocsPath
{
    self = [super init];
    if (self) {
        // paths
        localPath       = aLocalDocsPath;
        _accountInfoPath = [localPath stringByAppendingPathComponent:PLIST_ACCOUNT_INFO];
        _isEULA         = NO;
        observering     = NO;
        fileManager     = [NSFileManager defaultManager];
        
        
        
        if ([fileManager fileExistsAtPath: _accountInfoPath])
        {
            rawResponce     = [[NSMutableDictionary alloc] initWithContentsOfFile: _accountInfoPath];
            [self updateCustomerInfoWith:rawResponce];
          
        }
        
        
        
        
        // notifications will mostly be coming from the cloud Encoder
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(update:) name:NOTIF_USER_CENTER_UPDATE object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(checkCredentials:) name:NOTIF_CREDENTIALS_TO_VERIFY object:nil]; // listen to the app for check
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(cloudCredentialsResponce:) name:NOTIF_CLOUD_VERIFY_RESULTS object:nil]; // listen to the Cloud for check
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(userInfoRequest:) name:NOTIF_UC_REQUEST_USER_INFO object:nil]; // listen to the Cloud for check
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(logoutUser:) name:NOTIF_USER_LOGGED_OUT object:nil]; // listen to the Cloud for check
        
        _checkLoginPlistAction     = [[CheckLoginPlistAction alloc]initWithCenter:self];
        
    }
    return self;
}


// a logged out user get their plist deleted
-(void)logoutUser:(NSNotification *)note
{
    if ([[note.userInfo objectForKey:@"success"]boolValue]){
        NSString *filePath = _accountInfoPath;
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    }

}



/**
 *  Passing the Request from the app to the Cloud Encoder
 *
 *  @param note NSNotification
 */
-(void)userInfoRequest:(NSNotification*)note
{
    void (^passingDataBack)(NSDictionary*) = [note.userInfo objectForKey:@"block"];
    
    passingDataBack(rawResponce);
}


/**
 *  Passing the Request from the app to the Cloud Encoder
 *
 *  @param note NSNotification
 */
-(void)checkCredentials:(NSNotification*)note
{
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_CLOUD_VERIFY object:self userInfo:note.userInfo];
}

/**
 *  this recieved data from the Cloud Encoder about the users Credentials
 *
 *  @param note NSNotification
 */
-(void)cloudCredentialsResponce:(NSNotification*)note
{
    rawResponce = note.userInfo;
    
    if ([[rawResponce objectForKey:@"success"]boolValue]) {
        [self updateCustomerInfoWith:rawResponce];
    }
    
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_CREDENTIALS_VERIFY_RESULT object:self userInfo:note.userInfo];
    

}



-(void)updateCustomerInfoWith:(NSDictionary *)dataDict
{
    _customerID             = [dataDict objectForKey:@"customer"];
    _customerEmail          = [dataDict objectForKey:@"emailAddress"];
    _customerHid            = [dataDict objectForKey:@"hid"];
    _customerColor          = [Utility colorWithHexString:[dataDict objectForKey:@"tagColour"]];
    _customerAuthorization  = [dataDict objectForKey:@"authorization"];
}



// This updates this class based of the keys in the userdict
-(void)update:(NSNotification*)note
{
    NSDictionary * data = note.userInfo;

    if ([data objectForKey:@"userPick"]) self.userPick = [data objectForKey:@"userPick"];
}


-(void)enableObservers:(BOOL)isObserve
{
    if (observering && !isObserve){
        [[NSNotificationCenter defaultCenter]removeObserver:tagNameObserver];
    } else if (!observering && isObserve) {
        tagNameObserver =    [[NSNotificationCenter defaultCenter]addObserverForName:NOTIF_TAG_NAMES_FROM_CLOUD object:nil queue:nil usingBlock:^(NSNotification *note) {
            NSLog(@"UserCenter see data from Cloud Encoder");
            NSMutableArray * tgnames = [note.userInfo mutableCopy];
            if (tgnames){
                _tagNames = tgnames;
                
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
               
                
                NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:PLIST_ACCOUNT_INFO];
//                if (![fileManager fileExistsAtPath: plistPath])
//                {
//                    NSString *bundle = [[NSBundle mainBundle] pathForResource:@”myPlistFile” ofType:@”plist”];
//                    [fileManager copyItemAtPath:bundle toPath:plistPath error:&error];
//                }
                [_tagNames writeToFile:plistPath atomically: YES];

              
            } else {
                _tagNames = [self _buildTagNames:localPath];
            }
        }];
    }
    observering = isObserve;
}



-(NSMutableArray*)_buildTagNames:(NSString*)aLocalPath
{

    NSString        * tagFilePath   = [aLocalPath stringByAppendingPathComponent:PLIST_ACCOUNT_INFO];
    NSDictionary    * userInfo      =  [[NSDictionary alloc] initWithContentsOfFile:tagFilePath];
    NSDictionary    * tagnames      = [userInfo objectForKey:@"tagnames"];
    return  tagnames;
}


-(void)writeAccountInfoToPlist
{
    [rawResponce writeToFile: _accountInfoPath atomically:YES];
}

-(id<ActionListItem>)checkLoginPlistAction
{
    return [_checkLoginPlistAction reset];
}



@end
