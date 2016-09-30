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
#import "EncoderTask.h"
#import <objc/runtime.h>
#import "EncoderManagerActionPack.h"
#import "LogoutOperation.h"
#import "GetUserTagsOperation.h"
#import "LoginOperation.h"

#define PLIST_THUMBNAILS        @"Thumbnails.plist"
#define PLIST_PLAYER_SETUP      @"players-setup.plist"
#define PLIST_EVENT_HID         @"EventsHid.plist"
#define PLIST_ACCOUNT_INFO      @"accountInformation.plist"

#define GET_NOW_TIME [ NSNumber numberWithDouble:CACurrentMediaTime()]

#define ROLE_SUPERUSER    0
#define ROLE_COACH        1
#define ROLE_PLAYER       2
#define ROLE_USER         3
#define ROLE_TEAMADMIN    4
#define ROLE_MEDICAL      5

static UserCenter * instance;
@implementation UserCenter
{
    
    NSFileManager   * fileManager;
    id              tagNameObserver;
    BOOL            observering;
    NSDictionary    * rawResponce;
    
    NSArray * eventHIDs;
    CheckLoginPlistAction     * _checkLoginPlistAction;
}

@synthesize tagNames                = _tagNames;
@synthesize taggingTeam             = _taggingTeam;
@synthesize currentEventThumbnails  = _currentEventThumbnails;
@synthesize isLoggedIn              = _isLoggedIn;
@synthesize isEULA                  = _isEULA;
@synthesize accountInfoPath         = _accountInfoPath;
@synthesize customerColor           = _customerColor;
// about the userData

@synthesize customerID              = _customerID;
@synthesize customerDeviceID              = _customerDeviceID;
@synthesize customerAuthorization   = _customerAuthorization;
@synthesize customerEmail           = _customerEmail;
@synthesize userHID             = _userHID;
@synthesize localPath               = _localPath;
@synthesize role                  = _role;
@synthesize preRoll               = _preRoll;
@synthesize postRoll              = _postRoll;



+(instancetype)getInstance
{
    return instance;
}


-(id)initWithLocalDocPath:(NSString*)aLocalDocsPath
{
    self = [super init];
    if (self) {
        
        self.queue = [NSOperationQueue new];
        self.tagsFlaggedForAutoDownload = [[NSSet alloc]initWithObjects:@"", nil];
        
        // paths
        _localPath       = aLocalDocsPath;
        _accountInfoPath = [_localPath stringByAppendingPathComponent:PLIST_ACCOUNT_INFO];
        _isEULA         = NO;
        observering     = NO;
        fileManager     = [NSFileManager defaultManager];
        
        if ([fileManager fileExistsAtPath: _accountInfoPath])
        {
            rawResponce     = [[NSMutableDictionary alloc] initWithContentsOfFile: _accountInfoPath];
            [self updateCustomerInfoWith:rawResponce];
            _tagNames           = [self convertToL2BReadable: rawResponce key:@"tagnames"];
            _defaultTagNames    = [_tagNames copy];
        }
        
        eventHIDs = [[NSArray alloc]initWithContentsOfFile:[_localPath stringByAppendingPathComponent:PLIST_EVENT_HID]];
        
        _checkLoginPlistAction     = [[CheckLoginPlistAction alloc]initWithCenter:self];
//        logoutAction                = [[LogoutAction alloc]initWithUserCenter:self];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(logUserOutOfDevice:) name:NOTIF_LOGOUT_USER object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:@"setUserInfo" object:nil queue:nil usingBlock:^(NSNotification *note){
            void(^userCenterDataBlock)(NSDictionary *userInfo);
            userCenterDataBlock = note.userInfo[@"block"];
            userCenterDataBlock(rawResponce);
        }];
        instance = self;
    }
    
    return self;
}



#pragma mark -
#pragma mark Observer Methods

-(void)verifyGet:(NSMutableDictionary *)tData  timeStamp:(NSNumber *)aTimeStamp
{
    
    NSString * user             = [tData objectForKey:@"user"];
    NSString * password         = [tData objectForKey:@"password"];
    
    NSString *deviceName        = [[UIDevice currentDevice] name];
    NSString *UUID              = [[[UIDevice currentDevice] identifierForVendor]UUIDString];
    NSString *deviceType        = [Utility stringToSha1: @"tablet"];
    NSString *emailAddress      = [Utility stringToSha1: user];
    NSString *hashedPassword    = [Utility sha256HashFor: [password stringByAppendingString: @"azucar"]];
    NSString *pData             = [NSString stringWithFormat:@"&v0=%@&v1=%@&v2=%@&v3=%@&v4=%@",deviceType,emailAddress,hashedPassword,deviceName,UUID];
    
    NSData   *postData          = [pData dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postDataLength    = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc]init];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postDataLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current=Type"];
    [request setHTTPBody:postData];
    
  
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://myplayxplay.net/max/activate/ajax"]]];
    
    LoginOperation * loginOp = [[LoginOperation alloc]initWithEmail:user password:password];
    
    [loginOp setOnRequestComplete:^(NSData * data, NSOperation *op) {
        [self cloudCredentialsResponce:data];
    }];
    
    [self.queue addOperation:loginOp];
}

-(void)updateTagInfoFromCloud
{
    [self tagNamesGet:[NSMutableDictionary dictionaryWithDictionary:rawResponce] timeStamp:GET_NOW_TIME];
}

#pragma mark - Login methods



#pragma mark - Logout methods
-(void)logoutOfCloud
{
    NSDictionary * accountInfo  = [rawResponce copy];
    NSString * email            = _customerEmail;
    NSString * password         = [accountInfo objectForKey:@"password"];
    NSString * authorization    = [accountInfo objectForKey:@"authorization"];
    NSString * color            = [accountInfo objectForKey:@"tagColour"];
    NSString * customerHid      = [accountInfo objectForKey:@"customer"];
    
    LogoutOperation * logoutOperation = [[LogoutOperation alloc]initWithEmail:email password:password authorization:authorization color:color customerHid:customerHid];
    
    [logoutOperation setOnRequestComplete:^(NSData *data, NSOperation *op) {
        NSDictionary * jsonDict = [Utility JSONDatatoDict:data];
        
        if ([[jsonDict objectForKey:@"success"]boolValue]){
            NSString *filePath      = _accountInfoPath;
            NSError *error          = nil;
            _customerID             = nil;
            _customerAuthorization  = nil;
            _customerEmail          = nil;
            _customerColor          = nil;
            _userHID                = nil;
            _preRoll                = 10;
            _postRoll               = 10;
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        }
        
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_USER_LOGGED_OUT object:self userInfo:jsonDict];
        
    }];
    
    [self.queue addOperation:logoutOperation];
}


-(void)logUserOutOfDevice:(NSNotification *)notification
{
    [self logoutOfCloud];
}
#pragma mark -




-(void)tagNamesGet:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp
{
    NSString * user             = [tData objectForKey:@"emailAddress"];
    NSString * password         = [tData objectForKey:@"password"];
    NSString * authoriz         = [tData objectForKey:@"authorization"];
    NSString * customer         = [tData objectForKey:@"customer"];
    NSString * emailAddress     = [Utility stringToSha1: user];

    GetUserTagsOperation * verifyUserData = [[GetUserTagsOperation alloc]initEmail:emailAddress password:password authorization:authoriz customerHid:customer];
    
    [verifyUserData setOnRequestComplete:^(NSData * data, NSOperation *op) {
        [self tagNamesResponce:data];
    }];
    
    [self.queue addOperation:verifyUserData];
}

-(void)tagNamesResponce:(NSData *)data
{
    NSDictionary * jsonDict = [Utility JSONDatatoDict:data];
    if ([jsonDict objectForKey:@"tagbuttons"]){
        [self tagnameUpdate:jsonDict];
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SIDE_TAGS_READY_FOR_L2B object:nil];
}


-(void)cloudCredentialsResponce:(NSData *)data
{
    

    
 // role
//    0 = superUser
//    1 = coach
//    2 = play
//    3 = user
//    4 = team admin
//    5 = 
    NSError * error;
//    NSDictionary * jsonDict = [Utility JSONDatatoDict:data];
    NSDictionary * jsonDict = [Utility JSONDatatoDict:data error:&error];
    
    if (error) {
        NSLog(@"%s",__FUNCTION__);

    }
    

    
    rawResponce = jsonDict;
    
    
    if ([[rawResponce objectForKey:@"success"]boolValue]) {
        [self updateCustomerInfoWith:rawResponce];
        [self updateTagInfoFromCloud];
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_CREDENTIALS_VERIFY_RESULT object:self userInfo:jsonDict];
}


-(void)updateCustomerInfoWith:(NSDictionary *)dataDict
{
    /*
     ROLE_SUPERUSER
     ROLE_COACH
     ROLE_PLAYER
     ROLE_USER
     ROLE_TEAMADMIN
     ROLE_MEDICAL
     
     */
    
    self.role               = [[dataDict objectForKey:@"role"]integerValue];
    if ([dataDict objectForKey:@"role"]){
        NSInteger checkRole = [[dataDict objectForKey:@"role"] integerValue];
//        checkRole               = ROLE_MEDICAL;
        self.role               = checkRole;
        switch (checkRole) {
            case ROLE_SUPERUSER :
                self.rolePermissions = [[NSSet alloc]initWithArray:@[@ROLE_SUPERUSER,@ROLE_COACH, @ROLE_PLAYER,@ROLE_TEAMADMIN,@ROLE_USER,@ROLE_MEDICAL]];
                self.roleName = @"Super User";
                break;
            case ROLE_COACH :
                self.rolePermissions = [[NSSet alloc]initWithArray:@[@ROLE_COACH, @ROLE_PLAYER,@ROLE_TEAMADMIN,@ROLE_USER]];
                self.roleName = @"Coach";
                break;
            case ROLE_PLAYER :
                self.rolePermissions = [[NSSet alloc]initWithArray:@[@ROLE_COACH, @ROLE_PLAYER,@ROLE_TEAMADMIN,@ROLE_USER]];
                self.roleName = @"Player";
                break;
            case ROLE_USER :
                self.rolePermissions = [[NSSet alloc]initWithArray:@[@ROLE_COACH, @ROLE_PLAYER,@ROLE_TEAMADMIN,@ROLE_USER]];
                self.roleName = @"User";
                break;
            case ROLE_TEAMADMIN :
                self.rolePermissions = [[NSSet alloc]initWithArray:@[@ROLE_COACH, @ROLE_PLAYER,@ROLE_TEAMADMIN,@ROLE_USER]];
                self.roleName = @"Team Admin";
                break;
            case ROLE_MEDICAL :
                self.rolePermissions = [[NSSet alloc]initWithArray:@[@ROLE_MEDICAL]];
                self.roleName = @"Medical";
                break;
            default:
                self.rolePermissions = [[NSSet alloc]initWithArray:@[@ROLE_COACH, @ROLE_PLAYER,@ROLE_TEAMADMIN,@ROLE_USER]];
                self.roleName = @"Coach";
                break;
        }
        
    } else {
        
        self.rolePermissions = [[NSSet alloc]initWithArray:@[@ROLE_COACH, @ROLE_PLAYER]];
    }
    
    
    
    
    _customerID             = [dataDict objectForKey:@"customer"];
    _customerEmail          = [dataDict objectForKey:@"emailAddress"];
    _userHID                = [dataDict objectForKey:@"hid"];
    _customerColor          = [Utility colorWithHexString:[dataDict objectForKey:@"tagColour"]];
    _customerAuthorization  = [dataDict objectForKey:@"authorization"];
    
    
//    if ([dataDict objectForKey:@"role"]) self.role = [[dataDict objectForKey:@"role"]integerValue];
    
    
    NSUserDefaults *defaults           = [NSUserDefaults standardUserDefaults];
    NSDictionary * userDefaults        = [defaults objectForKey:_customerEmail];
    
    _preRoll = [[userDefaults objectForKey:@"preRoll"]doubleValue];
    _postRoll = [[userDefaults objectForKey:@"postRoll"]doubleValue];
    
    if (_preRoll == 0)  _preRoll  = 10;
    if (_postRoll == 0) _postRoll = 10;
    
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_USER_LOGGED_IN object:nil];
}



-(void)tagnameUpdate:(NSDictionary *)dic
{
    NSMutableDictionary         * tgnames = [dic mutableCopy];
    
    // this is clearing out all the illigal NULL in the dict, so the plist can be written
    NSMutableDictionary         * onlyTags = [[tgnames objectForKey:@"tagbuttons"]mutableCopy];
    [tgnames setObject:onlyTags forKey:@"tagbuttons"];
    
    if ([onlyTags isKindOfClass:[NSDictionary class]]){
        
        for (NSString * theKey in [onlyTags allKeys]) {
            NSMutableDictionary * checkedTag =  [[onlyTags objectForKey:theKey]mutableCopy];
            [onlyTags setObject:checkedTag forKey:theKey];
            [checkedTag removeObjectForKey:@"subtags"];
        }
    } else {
        // there was no take
    }
    
    
    NSString                * plistPath   = [_localPath stringByAppendingPathComponent:PLIST_ACCOUNT_INFO];
    NSMutableDictionary     * userInfo    = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
    if (tgnames){// no respoince from cloud
        
        // convert new tags for Live to bench
        if ([self.currentTagSetName isEqualToString:@"Default (non editable)"]) {
            _tagNames = [self convertToL2BReadable: tgnames key:@"tagbuttons"];
        }
        
        // delete old tags if there
        if ([userInfo objectForKey:@"tagnames"]){
            [userInfo removeObjectForKey:@"tagnames"];
        }
        
        // write new tags
        [userInfo setObject:[tgnames objectForKey:@"tagbuttons"] forKey:@"tagnames"];
        
        //             save data
        if ([[userInfo copy] writeToFile:plistPath atomically: YES]) {
            NSLog(@"WRITE");
        } else {
            NSLog(@"Fail");
        }
        
    } else {
        if ([self.currentTagSetName isEqualToString:@"Default (non editable)"]) {
            _tagNames =[self convertToL2BReadable: rawResponce key:@"tagnames"];
            //                _tagNames = [self _buildTagNames:localPath];
        }
    }
    
}


-(NSMutableArray*)convertToL2BReadable:(NSDictionary *)toConvert key:(NSString*)key
{
    NSDictionary * buttons      = [toConvert objectForKey:key];
    
    NSMutableArray * tempLeft   = [[NSMutableArray alloc]init];
    NSMutableArray * tempRigh   = [[NSMutableArray alloc]init];
    
    if  ([buttons isKindOfClass:[NSArray class]]){
        
        NSArray * items2 = [toConvert objectForKey:key] ;
        
        
        for (int i=0; i<[items2 count]; i++) {
            NSDictionary  * tbtn = items2[i];
            NSString * side = [tbtn objectForKey:@"position"];
            if ([side isEqualToString:@"left"]) {
                
                [tempLeft addObject:@{@"name":items2[i][@"name"], @"position":side, @"order": [NSNumber numberWithInt:i]}];
            } else {
                [tempRigh addObject:@{@"name":items2[i][@"name"], @"position":side, @"order": [NSNumber numberWithInt:i]}];
            }
        }
        
        
    } else {
        NSArray * items = [buttons allKeys];
        
        for (NSString * i in items){
            NSDictionary  * tbtn = [buttons objectForKey:i];
            NSString * side = [tbtn objectForKey:@"side"];
            if ([side isEqualToString:@"left"]) {
                [tempLeft addObject:@{@"name":i, @"position":side, @"order": [tbtn objectForKey:@"order"]}];
            } else {
                [tempRigh addObject:@{@"name":i, @"position":side, @"order": [tbtn objectForKey:@"order"]}];
            }
        }
    }
    
    NSMutableArray * temp = [[NSMutableArray alloc]init];
    [temp addObjectsFromArray:tempLeft];
    [temp addObjectsFromArray:tempRigh];
    return temp;
}


-(void)writeAccountInfoToPlist
{
    [rawResponce writeToFile: _accountInfoPath atomically:YES];
}


-(NSDictionary*)namedCamerasByUser
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"cameraNames"]) {
        return [defaults objectForKey:@"cameraNames"];
    } else {
        return @{};
    }
}
-(void)addCameraName:(NSString*)name camID:(NSString*)camID
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSMutableDictionary * dict = [[defaults objectForKey:@"cameraNames"] mutableCopy];
    if (!dict) {
        [defaults setObject:[NSMutableDictionary new] forKey:@"cameraNames"];
        dict = [[defaults objectForKey:@"cameraNames"]mutableCopy];
    }
    
    [dict setObject:name forKey:camID];
    [defaults setObject:dict forKey:@"cameraNames"];
    [defaults synchronize];
}

-(void)savePickByCameraLocation:(NSString*)camLocation pick:(NSString*)userPick
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary * dict = [[defaults objectForKey:@"cameraPicks"] mutableCopy];
    if (!dict) {
        [defaults setObject:[NSMutableDictionary new] forKey:@"cameraPicks"];
        dict = [[defaults objectForKey:@"cameraPicks"]mutableCopy];
    }
    
    [dict setObject:userPick forKey:camLocation];
    [defaults setObject:dict forKey:@"cameraPicks"];
    [defaults synchronize];
    
}

-(NSString*)getPickByCameraLocation:(NSString*)camLocation
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary * dict;
    
    if ([defaults objectForKey:@"cameraPicks"]) {
        dict = [defaults objectForKey:@"cameraPicks"];
    } else {
        return nil;
    }
    
    
    return [dict objectForKey:camLocation];
    
}

/**
 *  This saves video data that was saved to the MAX cloud as well as the key to find the data
 *
 *  @param reciept all data for clip
 */
-(void)saveVideoRecieptData:(NSDictionary*)reciept
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary * dict = [[defaults objectForKey:@"videoReciepts"] mutableCopy];
    if (!dict) {
        [self videoRecieptDataClear];
    }
    dict = [[defaults objectForKey:@"videoReciepts"] mutableCopy];
    
    
    NSString * key = reciept[@"xsKey"];
    
    
    
    
    
    
    [dict setObject:reciept forKey:key];
    
    [defaults setObject:dict forKey:@"videoReciepts"];
    [defaults synchronize];


}

-(NSDictionary*)videoRecieptDataForKey:(NSString*)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary * dict = [[defaults objectForKey:@"videoReciepts"] mutableCopy];

    
    return dict[key];
}


-(void)videoRecieptDataClear
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSMutableDictionary new] forKey:@"videoReciepts"];
    [defaults synchronize];
}

-(NSArray*)videoRecieptKeys
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary * dict = [[defaults objectForKey:@"videoReciepts"] mutableCopy];
    if (dict) {
    
        return [dict allValues];
    }
    

    return @[];
}


-(void)setPreRoll:(double)preRoll
{
    
    NSUserDefaults *defaults           = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary * userDefaults = [[defaults objectForKey:[UserCenter getInstance].customerEmail]mutableCopy];
    [userDefaults setObject:[NSNumber numberWithDouble:preRoll] forKey:@"preRoll"];
    [defaults setObject:userDefaults forKey:[UserCenter getInstance].customerEmail];
    [defaults synchronize];
    
    _preRoll = preRoll;
}


-(void)setPostRoll:(double)postRoll
{
    NSUserDefaults *defaults           = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary * userDefaults = [[defaults objectForKey:[UserCenter getInstance].customerEmail]mutableCopy];
    [userDefaults setObject:[NSNumber numberWithDouble:postRoll] forKey:@"postRoll"];
    [defaults setObject:userDefaults forKey:[UserCenter getInstance].customerEmail];
    [defaults synchronize];
    
    _postRoll = postRoll;
}

-(double)preRoll
{
    return _preRoll;
}

-(double)postRoll
{
    return _postRoll;
}

-(id<ActionListItem>)checkLoginPlistAction
{
    return [_checkLoginPlistAction reset];
}

//-(id<ActionListItem>)logoutAction
//{
//    logoutAction.isFinished = NO;
//    logoutAction.isSuccess  = NO;
//    return logoutAction;
//}

-(NSString*)l2bMode
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * mode =  [defaults objectForKey:@"mode"];
    return mode;
}

-(NSString*)deviceTypeHash
{
    return [Utility stringToSha1: @"tablet"];
}

@end
