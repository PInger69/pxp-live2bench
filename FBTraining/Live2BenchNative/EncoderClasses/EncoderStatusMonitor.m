//
//  EncoderStatusMonitor.m
//  Live2BenchNative
//
//  Created by dev on 10/24/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "EncoderStatusMonitor.h"
#import "Encoder.h"
#import <objc/runtime.h>
#define SHUTDOWN_RESPONCE   @"shutdown responce"
#define STATUS              @"status"
#define FEED_CHECK          @"feed check"
#define MASTER_SEARCH       @"master search"

/**
 *  This class is to just see what status the currentStatus the he incoder is in
 *  and will also check shutdown
 */

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

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation EncoderStatusMonitor
{
    Encoder                 * checkedEncoder;
    
    // For Status
    NSString                * ipAddress;
    NSTimer                 * statusTimer;
    float                   statusInterval;
    NSURLRequest            * urlRequest;
    NSURLConnection         * encoderConnection;
    int                     maxFailCount;
    int                     currentFailCount;
    EncoderStatus           statusCode;
    NSDate                  *startRequestTime;
    BOOL                    statusSync;
    
    // For shutdown
    void (^onServerShutdown)(void);
    int                     maxCount;
    int                     currentCount;
    float                   shutdownTimerInterval;
    NSTimer                 * shutdownTimer;
    NSURLRequest            * urlRequestShutdown;
    NSURLConnection         * encoderConnectionShutdown;
    
    NSInvocation            * statusInvocation;
    NSInvocation            * feedInvocation;
    
    NSString                * statusPath;
    NSString                * feedPath;
    double              timeout;
    NSMutableArray          * statusPack;

    
    BOOL                    flag; // simple flag to alternate status calls
}



@synthesize isLookingForMaster = _isLookingForMaster;


-(id)initWithEncoder:(Encoder*)encoder
{
    self = [super init];
    if (self){
        checkedEncoder      = encoder;
        ipAddress           = checkedEncoder.ipAddress;
        statusInterval      = 1.0;
        flag                = NO;
        maxFailCount        = 2; // 3 tries   0 index
        currentFailCount    = maxFailCount;
        statusPack          = [[NSMutableArray alloc]init];
        statusSync          = YES;
        statusTimer         = [NSTimer scheduledTimerWithTimeInterval:statusInterval target:self selector:@selector(statusLoop) userInfo:nil repeats:YES];

        
        // Build Invocation
        SEL selector_       = NSSelectorFromString(@"encoderStatusInvocker:type:timeout:");
        statusPath          = [NSString stringWithFormat:@"http://%@/min/ajax/encoderstatjson/",ipAddress];
        feedPath            = [NSString stringWithFormat:@"http://%@/min/ajax/getpastevents",ipAddress];
        timeout             = 6 ;
        statusInvocation    = [self _buildInvokSel:selector_ path:statusPath  type:STATUS       timeout:&timeout];
        feedInvocation      = [self _buildInvokSel:selector_ path:feedPath    type:FEED_CHECK   timeout:&timeout];

        
//        [statusPack addObject:feedInvocation];
        [statusPack addObject:statusInvocation];
    }
    return self;
}


-(NSInvocation * )_buildInvokSel:(SEL)aSelec path:(NSString*)aPath type:(NSString*)aType timeout:(double *)aTimeOut
{
    NSMethodSignature   * signature    = [self methodSignatureForSelector:aSelec];
    NSInvocation        * invocation       = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:self];
    [invocation setSelector:aSelec];

    [invocation setArgument:&aPath atIndex:2];
    [invocation setArgument:&aType atIndex:3];
    [invocation setArgument:aTimeOut atIndex:4];
    return invocation;
}


// Connections methods


-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
 
    if ([connection.connectionType isEqualToString: SHUTDOWN_RESPONCE])     currentCount = maxCount;
    
    if ([connection.connectionType isEqualToString: STATUS]){
        checkedEncoder.bitrate = (double)[[NSDate date] timeIntervalSinceDate:startRequestTime];
    }
}

// This collects the data
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    
    if (connection.cumulatedData == nil){
        connection.cumulatedData = [NSMutableData dataWithData:data];
    } else {
        [connection.cumulatedData appendData:data];
    }

}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    statusSync = YES;

    if ([connection.connectionType isEqualToString: SHUTDOWN_RESPONCE]){
        if (currentCount-- == 0) [self serverHasShutdown];
    } else {
        if (!currentFailCount--)  {
            checkedEncoder.status = ENCODER_STATUS_UNKNOWN;
        }
    }

    
    if ([connection.connectionType isEqualToString: STATUS])   {
       
    }
     
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    statusSync = YES;
    currentFailCount = maxFailCount;
    if ([connection.connectionType isEqualToString: STATUS])   {
        [self statusResponse:connection.cumulatedData];
    } else  if ([connection.connectionType isEqualToString: FEED_CHECK]) {
        [self checkFeeds:connection.cumulatedData];
    }
    // get cam check..... add it
}



-(void)statusLoop
{
    NSInvocation * toInvoke = [statusPack objectAtIndex:0];
    [toInvoke invoke];
    [statusPack removeObjectAtIndex:0];
    [statusPack addObject:toInvoke];
}

-(void)encoderStatusInvocker:(NSString*)aPath type:(NSString*)aType timeout:(NSTimeInterval)aTimeOut
{
   if (!statusSync)return;

    urlRequest                          = [NSURLRequest requestWithURL: [ NSURL URLWithString: aPath ] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:aTimeOut];
    encoderConnection                   = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType    = aType;
    startRequestTime                    = [NSDate date];
    statusSync                          = NO;
    flag                                = !flag;
}


-(void)statusResponse:(NSData *)data
{
    NSDictionary    * results;
    if(NSClassFromString(@"NSJSONSerialization"))
    {
        NSError *error = nil;
        id object = [NSJSONSerialization
                     JSONObjectWithData:data
                     options:0
                     error:&error];
        
        if([object isKindOfClass:[NSDictionary class]])
        {
            results     = object;
            statusCode  = [[results objectForKey:@"code"]integerValue] ;
         
            // this is for the older encoder versions
            if ([checkedEncoder.version compare:OLD_VERSION options:NSNumericSearch]){
//            if ([Utility sumOfVersion:checkedEncoder.version] >= [Utility sumOfVersion:OLD_VERSION]){
                BOOL checkIfNobel =[[results objectForKey:@"master"]boolValue];
                checkedEncoder.isMaster = checkIfNobel;
            }
            
            if (checkedEncoder.status != statusCode && (!(checkedEncoder.status & ENCODER_STATUS_LIVE) || checkedEncoder.liveEventName)) {
                checkedEncoder.statusAsString   = ([results objectForKey:@"status"])?[results objectForKey:@"status"]:@"";
                checkedEncoder.status           = statusCode; /// maybe make this mod directly
                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_ENCODER_STAT object:checkedEncoder];
                
            }
        
            if ([results objectForKey:@"alarms"]) {
                NSArray * feedsChecked = (checkedEncoder.feeds)?[checkedEncoder.feeds allKeys]:@[];
                NSArray * alarmedFeeds = [results objectForKey:@"alarms"];
                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MOTION_ALARM object:checkedEncoder userInfo:@{
                                                                                                                              @"feeds"    : feedsChecked,
                                                                                                                              @"alarms"   : alarmedFeeds
                                                                                                                              }];
            }

        }
    }
}

//
//-(void)serverInfoResponse:(NSData *)data
//{
//    NSDictionary    * results;
//    if(NSClassFromString(@"NSJSONSerialization"))
//    {
//        NSError *error = nil;
//        id object = [NSJSONSerialization
//                     JSONObjectWithData:data
//                     options:0
//                     error:&error];
//        
//        if([object isKindOfClass:[NSDictionary class]])
//        {
//            results     = object;
//            statusCode  = [[results objectForKey:@"code"]integerValue] ;
//            if (checkedEncoder.status != statusCode) checkedEncoder.status = statusCode; /// maybe make this mod directly
//        }
//    }
//}
//


// This section is to check feed changes
-(void)checkFeeds:(NSData *)data
{
    NSString        * currentEvent = checkedEncoder.event;
    NSDictionary    * tempFeeds    = @{};
    if (currentEvent == nil ||[currentEvent isEqualToString:@""]){
        return;
    }
    
    
    if(NSClassFromString(@"NSJSONSerialization"))
    {
        NSError *error = nil;
        id object = [NSJSONSerialization
                     JSONObjectWithData:data
                     options:0
                     error:&error];
        
        if([object isKindOfClass:[NSDictionary class]])
        {
            

            NSArray         * events = [object objectForKey:@"events"];
            NSMutableArray  * pool   = [[NSMutableArray alloc]init];
            
            
            @try {
                NSEnumerator *enumerator = [events objectEnumerator];
                id value;
               
                while ((value = [enumerator nextObject])) {
                    NSDictionary * dict = value;
                    if ([dict isKindOfClass:[NSDictionary class]]  &&[[dict objectForKey:@"name"] isEqualToString:currentEvent]) {
                        [pool addObject:[dict objectForKey:@"name"]];
                        
                        
                        if ([dict objectForKey:@"live"]){
                            
                            tempFeeds = [self _convertToFeed:[dict objectForKey:@"live"]];
                        } else {
                            tempFeeds = [self _convertToFeed:[dict objectForKey:@"vid"]];
                        }
                        
                        
                    }
                }
            }
            @catch (NSException *exception) {
                NSLog(@"error parsing json data: %@",exception);
            }
            @finally {
                
            }
            
            // If the feeds are different... update and using  .feeds the encoder will dispatch an event about the chnage
           // if ( !(tempFeeds == nil) && (checkedEncoder.feeds == nil)){
                if (![tempFeeds isEqualToDictionary:checkedEncoder.feeds]){
                 //   checkedEncoder.feeds = tempFeeds;
                }
           // }
                
        }
    }
    
}




-(NSDictionary*)_convertToFeed:(id)data
{
    NSDictionary * output;
    if ([data isKindOfClass:[NSString class]]){
        output = @{@"s1":@{@"lq":data}};
    } else {
        output = (NSDictionary *)data;
    }

    return output;
}










// Shutting down methods

-(void)startShutdownChecker:(void(^)(void))onShutdown
{
    shutdownTimerInterval   = 1;
    maxCount                = 20;
    currentCount            = maxCount;
    onServerShutdown        = onShutdown;
    shutdownTimer           = [NSTimer scheduledTimerWithTimeInterval:shutdownTimerInterval target:self selector:@selector(checking) userInfo:nil repeats:YES];
}

-(void)checking
{
    NSURL * checkURL            = [NSURL URLWithString:   [NSString stringWithFormat:@"http://%@/min/ajax/encoderstatjson/",ipAddress]  ];
    urlRequestShutdown          = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:1];
    encoderConnectionShutdown   = [NSURLConnection connectionWithRequest:urlRequestShutdown delegate:self];
    encoderConnectionShutdown.connectionType = SHUTDOWN_RESPONCE;
}


/**
 *  Invalidates timer and runs block
 */
-(void)serverHasShutdown
{
    [shutdownTimer invalidate];
    if (onServerShutdown) onServerShutdown();
}

-(void)destroy
{
    if (statusTimer) [statusTimer invalidate];
    if (shutdownTimer) [shutdownTimer invalidate];
}


@end
