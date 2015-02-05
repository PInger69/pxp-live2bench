//
//  CloudEncoder.m
//  Live2BenchNative
//
//  Created by dev on 2014-12-04.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "CloudEncoder.h"
#import "EncoderCommand.h"
#import <objc/runtime.h>
#import "Utility.h"
#import "EncoderManager.h"

#define GET_NOW_TIME [ NSNumber numberWithDouble:CACurrentMediaTime()]


// catagory  // catagory  // catagory  // catagory  // catagory  // catagory  // catagory  // catagory  // catagory

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



// END HELPER CLASSS





@implementation CloudEncoder
{


}

@synthesize loggedIn = _loggedIn;



- (instancetype)init
{
    self = [super init];
    if (self) {
        _loggedIn = NO;
    }
    return self;
}





-(void)startObserving
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(verifyUser:) name:NOTIF_CLOUD_VERIFY object:nil];// UserCenter is what is dispatching

}

/**
 *  Asked to check user info
 *
 *  @param note
 */
-(void)verifyUser:(NSNotification*)note
{

    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:note.userInfo];
    [self issueCommand:CE_VERIFY_GET priority:1 timeoutInSec:15 tagData:dict timeStamp:GET_NOW_TIME];
}

-(void)updateTagInfoFromCloud
{
    __block CloudEncoder * weakSelf = self;
   
   
    void (^onRecieveData)(NSDictionary*) = ^void(NSDictionary* theData){
        [weakSelf issueCommand:CE_TAG_NAMES_GET priority:99 timeoutInSec:15 tagData:[NSMutableDictionary dictionaryWithDictionary:theData] timeStamp:GET_NOW_TIME];
    };
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_UC_REQUEST_USER_INFO object:self userInfo:@{@"block":onRecieveData}];
}

-(void)logoutOfCloud
{
    __block CloudEncoder * weakSelf = self;
    
    
    
    void (^onRecieveData)(NSDictionary*) = ^void(NSDictionary* theData){
        [weakSelf issueCommand:CE_LOGOUT priority:99 timeoutInSec:15 tagData:[NSMutableDictionary dictionaryWithDictionary:theData] timeStamp:GET_NOW_TIME];
    };
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_UC_REQUEST_USER_INFO object:self userInfo:@{@"block":onRecieveData}];
    
    
}



#pragma mark -
#pragma mark Commands

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
    NSString *postDataLength    = [NSString stringWithFormat:@"%d",[postData length]];
    
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

-(void)verifyGet:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp
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
    NSString *postDataLength    = [NSString stringWithFormat:@"%d",[postData length]];
    
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


-(void)logout:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp
{
 
    NSDictionary        *accountInfo           = [tData copy];
    NSString            *emailAddress          = [Utility stringToSha1:[accountInfo objectForKey:@"emailAddress"] ];
    NSString            *accountInfoString     = [NSString stringWithFormat:@"v0=%@&v1=%@&v2=%@&v3=%@&v4=%@",[accountInfo objectForKey:@"authorization"],emailAddress,[accountInfo objectForKey:@"password"],[accountInfo objectForKey:@"tagColour"],[accountInfo objectForKey:@"customer"]];
    NSData              *accountInfoData       = [accountInfoString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString            *postDataLength        = [NSString stringWithFormat:@"%d",[accountInfoData length]];
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


#pragma mark -
#pragma mark Connections

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{

    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_TAG_NAMES_FROM_CLOUD object:self];
    [super connection:connection didFailWithError:error];
}


-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString    * connectionType   = connection.connectionType;
    NSData      * finishedData     = connection.cumulatedData;
    
    if ([connectionType isEqualToString: CE_TAG_NAMES_GET]){
        [self tagNamesResponce: finishedData];
    } else if ([connectionType isEqualToString: CE_VERIFY_GET]) {
        [self verifyResponce: finishedData];
    } else if ([connectionType isEqualToString: CE_LOGOUT]) {
        [self logoutResponce: finishedData];
    }
    
    
    [super connectionDidFinishLoading:connection];
    
}


#pragma mark -
#pragma  mark Responces


-(void)tagNamesResponce:(NSData *)data
{

    NSDictionary * jsonDict = [Utility JSONDatatoDict:data];
    if ([jsonDict objectForKey:@"tagbuttons"]){
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_TAG_NAMES_FROM_CLOUD object:self userInfo:jsonDict];
    }
    
}

-(void)verifyResponce:(NSData *)data
{
    
    NSDictionary * jsonDict = [Utility JSONDatatoDict:data];
     if ([[jsonDict objectForKey:@"success"]boolValue]) {
         self.loggedIn = YES;
     }
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_CLOUD_VERIFY_RESULTS object:self userInfo:jsonDict];
}


-(void)logoutResponce:(NSData *)data
{
    NSDictionary * jsonDict = [Utility JSONDatatoDict:data];
    if ([[jsonDict objectForKey:@"success"]boolValue]) {
        self.loggedIn = NO;
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_USER_LOGGED_OUT object:self userInfo:jsonDict];
}



@end
