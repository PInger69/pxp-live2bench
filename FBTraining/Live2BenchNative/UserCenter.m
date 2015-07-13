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


#define PLIST_THUMBNAILS        @"Thumbnails.plist"
#define PLIST_PLAYER_SETUP      @"players-setup.plist"
#define PLIST_EVENT_HID         @"EventsHid.plist"
#define PLIST_ACCOUNT_INFO      @"accountInformation.plist"

#define GET_NOW_TIME [ NSNumber numberWithDouble:CACurrentMediaTime()]


@interface NSURLConnection (Context)

@property (nonatomic,strong)    NSNumber        * timeStamp;
@property (nonatomic,strong)    NSMutableData   * cumulatedData;
@property (nonatomic,strong)    NSString        * connectionType;

-(NSNumber*)timeStamp;
-(void)setTimeStamp:(NSNumber*)time;

@end

@implementation NSURLConnection (Context)

@dynamic timeStamp;
@dynamic cumulatedData;
@dynamic connectionType;

-(void)setTimeStamp:(NSNumber*)time
{
    objc_setAssociatedObject(self, @selector(timeStamp), time,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSNumber*)timeStamp
{
    return (NSNumber*)objc_getAssociatedObject(self,@selector(timeStamp));
}

-(void)setCumulatedData:(NSMutableData*)data
{
    objc_setAssociatedObject(self, @selector(cumulatedData), data,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSMutableData*)cumulatedData
{
    return (NSMutableData*)objc_getAssociatedObject(self,@selector(cumulatedData));
}


-(void)setConnectionType:(NSString*)type
{
    objc_setAssociatedObject(self, @selector(connectionType), type,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSString*)connectionType
{
    return (NSString*)objc_getAssociatedObject(self,@selector(connectionType));
}


@end


/**
 *  This will manage connection and avaiability with its encoder
 *  Note: Look in to "sendAsynchronousRequest:queue:completionHandler:"
 *  This might be the correct way to Request
 */


@interface Command : NSObject

@property (nonatomic)           SEL                 selector;
@property (nonatomic)           id                  target;
@property (nonatomic,assign)    int                 priority;
@property (nonatomic,assign)    float               timeOut;
@property (nonatomic,strong)    NSMutableDictionary * tagData;
//@property (nonatomic)           void                * context;
@property (nonatomic)           NSNumber            * timeStamp;

@end

@implementation Command

@end





static UserCenter * instance;
@implementation UserCenter
{

    NSFileManager   * fileManager;
    id              tagNameObserver;
    BOOL            observering;
    
    NSDictionary    * rawResponce;
    
    
    NSArray * eventHIDs;
    
    

    LogoutAction                * logoutAction;
    CheckLoginPlistAction     * _checkLoginPlistAction;
}

@synthesize tagNames                = _tagNames;
@synthesize userPick                = _userPick;
@synthesize currentEventThumbnails  = _currentEventThumbnails;
@synthesize isLoggedIn              = _isLoggedIn;
@synthesize isEULA                  = _isEULA;

@synthesize accountInfoPath         = _accountInfoPath;
@synthesize customerColor           = _customerColor;
// about the userData

@synthesize customerID              = _customerID;
@synthesize customerAuthorization   = _customerAuthorization;
@synthesize customerEmail           = _customerEmail;
@synthesize userHID             = _userHID;
@synthesize localPath               = _localPath;


+(instancetype)getInstance
{
    return instance;
}


-(id)initWithLocalDocPath:(NSString*)aLocalDocsPath
{
    self = [super init];
    if (self) {
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
            _tagNames       = [self convertToL2BReadable: rawResponce key:@"tagnames"];
        }
        
        
        
        eventHIDs = [[NSArray alloc]initWithContentsOfFile:[_localPath stringByAppendingPathComponent:PLIST_EVENT_HID]];
        
        
        // notifications will mostly be coming from the cloud Encoder
        //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(checkCredentials:)         name:NOTIF_CREDENTIALS_TO_VERIFY object:nil]; // listen to the app for check
        //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(cloudCredentialsResponce:) name:NOTIF_CLOUD_VERIFY_RESULTS object:nil]; // listen to the Cloud for check
        //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dataRequest:)              name:NOTIF_USER_CENTER_DATA_REQUEST object:nil]; // listen to the Cloud for check
        //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(logoutUser:)               name:NOTIF_USER_LOGGED_OUT object:nil]; // listen to the Cloud for check
        
        _checkLoginPlistAction     = [[CheckLoginPlistAction alloc]initWithCenter:self];
        logoutAction                = [[LogoutAction alloc]initWithUserCenter:self];
        
        [[NSNotificationCenter defaultCenter]addObserverForName:NOTIF_LOGOUT_USER     object:nil queue:nil usingBlock:^(NSNotification *note) {
            [self.logoutAction start];
        }];
        
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


// a logged out user get their plist deleted
-(void)logoutUser:(NSData *)data
{
    NSDictionary * jsonDict = [Utility JSONDatatoDict:data];
    
    if ([[jsonDict objectForKey:@"success"]boolValue]){
        NSString *filePath      = _accountInfoPath;
        NSError *error          = nil;
        _customerID             = nil;
        _customerAuthorization  = nil;
        _customerEmail          = nil;
        _customerColor          = nil;
        _userHID                = nil;
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_USER_LOGGED_OUT object:self userInfo:jsonDict];

}



/**
 *  Passing the Request from the app to the Cloud Encoder
 *
 *  @param note NSNotification
 */
/*-(void)dataRequest:(NSNotification*)note
{
    if ([note.userInfo objectForKey:@"tagbuttons"]){
        
        NSString * requestType = note.userInfo[@"type"];
        
        if ([requestType isEqualToString:UC_REQUEST_EVENT_HIDS]) {
            void (^passingDataBack)(NSArray*) = [note.userInfo objectForKey:@"block"];
            passingDataBack(eventHIDs);
        } else if ([requestType isEqualToString:UC_REQUEST_USER_INFO]){
            void (^passingDataBack)(NSDictionary*) = [note.userInfo objectForKey:@"block"];
            passingDataBack(rawResponce);
        }
        
    }

    
}*/


/** O
 *  Passing the Request from the app to the Cloud Encoder
 *
 *  @param note NSNotification
 */
/*-(void)checkCredentials:(NSNotification*)note
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithDictionary:note.userInfo];
    [self verifyGet:dic timeStamp:GET_NOW_TIME];
}*/

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
    
    NSData *postData            = [pData dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postDataLength    = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc]init];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postDataLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current=Type"];
    [request setHTTPBody:postData];
    
    request.timeoutInterval = currentCommand.timeOut;
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://myplayxplay.net/max/activate/ajax"]]];
    
    urlRequest = request;
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = CE_VERIFY_GET;
    encoderConnection.timeStamp             = aTimeStamp;
    [encoderConnection start];
    
}

-(void)updateTagInfoFromCloud
{
        [self tagNamesGet:[NSMutableDictionary dictionaryWithDictionary:rawResponce] timeStamp:GET_NOW_TIME];
}

-(void)logoutOfCloud
{
        [self logout:[NSMutableDictionary dictionaryWithDictionary:rawResponce] timeStamp:GET_NOW_TIME];
}


-(void)tagNamesGet:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp
{
    NSString * user             = [tData objectForKey:@"emailAddress"];
    NSString * password         = [tData objectForKey:@"password"];
    NSString * authoriz         = [tData objectForKey:@"authorization"];
    NSString * customer         = [tData objectForKey:@"customer"];
    NSString * emailAddress     = [Utility stringToSha1: user];
    
    //    NSString *UUID              = [[[UIDevice currentDevice] identifierForVendor]UUIDString];
    //    NSString *deviceType        = [Utility stringToSha1: @"tablet"];
    //    NSString *hashedPassword    = [Utility sha256HashFor: [password stringByAppendingString: @"azucar"]];
    //    NSString *deviceName        = [[UIDevice currentDevice] name];
    NSString *pData             = [NSString stringWithFormat:@"&v0=%@&v1=%@&v2=%@&v3=%@&v4=%@",authoriz,emailAddress,password,@"( . Y . )",customer];
    // v0 autherzation  v1 hashedEmail  v2 password v3 ( . Y . )  v4 customerID
    NSData   *postData          = [pData dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postDataLength    = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc]init];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postDataLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current=Type"];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://myplayxplay.net/max/requesttagnames/ajax"]]];
    
    request.timeoutInterval = currentCommand.timeOut;
    [request setHTTPBody:postData];
    
    
    
    
    
    //      NSURLRequest  * reqUrl                  = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    urlRequest = request;
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = CE_TAG_NAMES_GET;
    encoderConnection.timeStamp             = aTimeStamp;
    [encoderConnection start];
}


-(void)logout:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp
{
    
    NSDictionary        *accountInfo           = [tData copy];
    NSString            *emailAddress          = [Utility stringToSha1:[accountInfo objectForKey:@"emailAddress"] ];
    NSString            *accountInfoString     = [NSString stringWithFormat:@"v0=%@&v1=%@&v2=%@&v3=%@&v4=%@",[accountInfo objectForKey:@"authorization"],emailAddress,[accountInfo objectForKey:@"password"],[accountInfo objectForKey:@"tagColour"],[accountInfo objectForKey:@"customer"]];
    NSData              *accountInfoData       = [accountInfoString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString            *postDataLength        = [NSString stringWithFormat:@"%lu",(unsigned long)[accountInfoData length]];
    NSMutableURLRequest *request               = [[NSMutableURLRequest alloc]init];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://myplayxplay.net/max/deactivate/ajax"]]];
    
    //create post request
    [request setHTTPMethod:@"POST"];
    [request setValue:postDataLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current=Type"];
    [request setHTTPBody:accountInfoData];
    
    
    urlRequest = request;
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = CE_LOGOUT;
    encoderConnection.timeStamp             = aTimeStamp;
    [encoderConnection start];
    
}


-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSString * failType = [error.userInfo objectForKey:@"NSLocalizedDescription"];
    
    PXPLog(@"User Center Error");
    PXPLog(@"  connection type: %@ ",connection.connectionType);
    PXPLog(@"  url: %@ ",[[connection originalRequest]URL]);
    PXPLog(@"  reason: %@ ",failType);
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_ENCODER_CONNECTION_FINISH object:self userInfo:nil];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (connection.cumulatedData == nil){
        connection.cumulatedData = [NSMutableData dataWithData:data];
    } else {
        [connection.cumulatedData appendData:data];
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_ENCODER_CONNECTION_PROGRESS object:self userInfo:nil];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString    * connectionType   = connection.connectionType;
    NSData      * finishedData     = connection.cumulatedData;
    
    if ([connectionType isEqualToString: CE_TAG_NAMES_GET]){
        [self tagNamesResponce:finishedData];
    } else if ([connectionType isEqualToString: CE_VERIFY_GET]) {
        [self cloudCredentialsResponce:finishedData];
    } else if ([connectionType isEqualToString: CE_LOGOUT]) {
        [self logoutUser:finishedData];
    }
    
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
     NSDictionary * jsonDict = [Utility JSONDatatoDict:data];
    rawResponce = jsonDict;
    
    if ([[rawResponce objectForKey:@"success"]boolValue]) {
        [self updateCustomerInfoWith:rawResponce];
        [self updateTagInfoFromCloud];
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_CREDENTIALS_VERIFY_RESULT object:self userInfo:jsonDict];
}


/**
 *  this recieved data from the Cloud Encoder about the users Credentials
 *
 *  @param note NSNotification
 */
/*-(void)cloudCredentialsResponce:(NSNotification*)note
{
    rawResponce = note.userInfo;
    
    if ([[rawResponce objectForKey:@"success"]boolValue]) {
        [self updateCustomerInfoWith:rawResponce];
    }
    
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_CREDENTIALS_VERIFY_RESULT object:self userInfo:note.userInfo];
    

}*/



-(void)updateCustomerInfoWith:(NSDictionary *)dataDict
{
    _customerID             = [dataDict objectForKey:@"customer"];
    _customerEmail          = [dataDict objectForKey:@"emailAddress"];
    _userHID                = [dataDict objectForKey:@"hid"];
    _customerColor          = [Utility colorWithHexString:[dataDict objectForKey:@"tagColour"]];
    _customerAuthorization  = [dataDict objectForKey:@"authorization"];
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
        _tagNames = [self convertToL2BReadable: tgnames key:@"tagbuttons"];
            
            
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
            
        _tagNames =[self convertToL2BReadable: rawResponce key:@"tagnames"];
        //                _tagNames = [self _buildTagNames:localPath];
    }

}

/*-(void)enableObservers:(BOOL)isObserve
{
    if (observering && !isObserve){
        [[NSNotificationCenter defaultCenter]removeObserver:tagNameObserver];
    } else if (!observering && isObserve) {
        NSLog(@"UserCenter see data from Cloud Encoder");
    
        tagNameObserver     =    [[NSNotificationCenter defaultCenter]addObserverForName:NOTIF_TAG_NAMES_FROM_CLOUD object:nil queue:nil usingBlock:^(NSNotification *note) {
        
       NSMutableDictionary         * tgnames = [note.userInfo mutableCopy];
           
        // this is clearing out all the illigal NULL in the dict, so the plist can be written
        NSMutableDictionary         * onlyTags = [[tgnames objectForKey:@"tagbuttons"]mutableCopy];
        [tgnames setObject:onlyTags forKey:@"tagbuttons"];
            
        for (NSString * theKey in [onlyTags allKeys]) {
            NSMutableDictionary * checkedTag =  [[onlyTags objectForKey:theKey]mutableCopy];
            [onlyTags setObject:checkedTag forKey:theKey];
            [checkedTag removeObjectForKey:@"subtags"];
//            if ([checkedTag objectForKey:@"subtags"]) {
//                NSMutableArray * listSubtags = [checkedTag objectForKey:@"subtags"];
//                for (int i=0; i<[listSubtags count]; i++) {
//                    NSLog(@"");
//                    if ([listSubtags objectAtIndex:i] == [NSNull null]  ){
//                        [listSubtags replaceObjectAtIndex:i withObject:@""];
//                    }
//                }
//            }
        }
            
        // get user info plist
        NSString                * plistPath   = [_localPath stringByAppendingPathComponent:PLIST_ACCOUNT_INFO];
        NSMutableDictionary     * userInfo    = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        
        if (tgnames){// no respoince from cloud
            
            // convert new tags for Live to bench
            _tagNames = [self convertToL2BReadable: tgnames key:@"tagbuttons"];
            
      
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
            
            _tagNames =[self convertToL2BReadable: rawResponce key:@"tagnames"];
//                _tagNames = [self _buildTagNames:localPath];
        }
        }];
    }
    observering = isObserve;
}*/



//-(NSMutableArray*)_buildTagNames:(NSString*)aLocalPath
//{
//
//    
//    
//    
//    
//    NSString        * tagFilePath   = [aLocalPath stringByAppendingPathComponent:PLIST_ACCOUNT_INFO];
//    NSDictionary    * userInfo      =  [[NSDictionary alloc] initWithContentsOfFile:tagFilePath];
//    NSDictionary    * tagnames      = [userInfo objectForKey:@"tagnames"];
//    return  tagnames;
//}


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
        
//        
//        for (NSString * i in items){
//            NSDictionary  * tbtn = [buttons objectForKey:i];
//            NSString * side = [tbtn objectForKey:@"side"];
//            if ([side isEqualToString:@"left"]) {
//                [tempLeft addObject:@{@"name":i, @"position":side, @"order": [tbtn objectForKey:@"order"]}];
//            } else {
//                [tempRigh addObject:@{@"name":i, @"position":side, @"order": [tbtn objectForKey:@"order"]}];
//            }
//        }
        
        
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

-(id<ActionListItem>)checkLoginPlistAction
{
    return [_checkLoginPlistAction reset];
}

-(id<ActionListItem>)logoutAction
{
    logoutAction.isFinished = NO;
    logoutAction.isSuccess  = NO;
    return logoutAction;
}



@end
