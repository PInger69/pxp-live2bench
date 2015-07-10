//
//  EncoderStatusMonitor.m
//  Live2BenchNative
//
//  Created by dev on 10/24/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "EncoderStatusMonitor.h"
#import "Encoder.h"
#import "Event.h"
#import <objc/runtime.h>
#import "Tag.h"
#import "EncoderStatusMonitorProtocol.h"
#import "UserCenter.h"

#define SHUTDOWN_RESPONCE   @"shutdown responce"
#define STATUS              @"status"
#define FEED_CHECK          @"feed check"
#define MASTER_SEARCH       @"master search"
#define SYNC_ME             @"SYNC_ME"
#define GET_NOW_TIME_STRING [NSString stringWithFormat:@"%f",CACurrentMediaTime()]
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
    //Encoder                 * checkedEncoder;
    id <EncoderStatusMonitorProtocol>     checkedEncoder;
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
    NSInvocation            * syncMeInvocation;
    
    NSString                * syncMePath;
    NSString                * statusPath;
    NSString                * feedPath;
    double                  timeout;
    NSMutableArray          * statusPack;

    BOOL                    flag; // simple flag to alternate status calls
    BOOL                    isLegacy;
    SEL selector_;

    
    NSString                * connectType;
}



@synthesize isLookingForMaster = _isLookingForMaster;

-(id)initWithDelegate:(id<EncoderStatusMonitorProtocol>)delegate
{
    self = [super init];
    if (self){
        checkedEncoder      = delegate;
        ipAddress           = delegate.ipAddress;
        statusInterval      = 1.0;
        flag                = NO;
        maxFailCount        = 10; // 3 tries   0 index
        currentFailCount    = maxFailCount;
        statusPack          = [[NSMutableArray alloc]init];
        statusSync          = YES;
        statusTimer         = [NSTimer scheduledTimerWithTimeInterval:statusInterval target:self selector:@selector(statusLoop) userInfo:nil repeats:YES];
        
        //Building SyncMe Invocation
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithDictionary:@{
                                                                                     @"user"         : [UserCenter getInstance].userHID,
                                                                                     @"requesttime"  : GET_NOW_TIME_STRING, //[NSString stringWithFormat:@"%f",0]
                                                                                     @"event"        : @"live",
                                                                                     @"device"       : [UserCenter getInstance].customerAuthorization
                                                                                     }];
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
        NSString *jsonString;
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        syncMePath = [NSString stringWithFormat:@"http://%@/min/ajax/syncme/%@", ipAddress, jsonString];
        
        // Build Invocation
        //SEL selector_       = NSSelectorFromString(@"encoderStatusInvocker:type:timeout:");
        selector_ = NSSelectorFromString(@"encoderStatusInvocker:type:timeout:");
        statusPath          = [NSString stringWithFormat:@"http://%@/min/ajax/encoderstatjson/",ipAddress];
        feedPath            = [NSString stringWithFormat:@"http://%@/min/ajax/getpastevents",ipAddress];
        
        timeout             = 6 ;
        statusInvocation    = [self _buildInvokSel:selector_ path:statusPath  type:STATUS       timeout:&timeout];
        feedInvocation      = [self _buildInvokSel:selector_ path:feedPath    type:FEED_CHECK   timeout:&timeout];
        syncMeInvocation      = [self _buildInvokSel:selector_ path:syncMePath type:SYNC_ME       timeout:&timeout];
        
        [statusPack addObject:statusInvocation];
        [statusPack addObject: syncMeInvocation];
        isLegacy            = [checkedEncoder checkEncoderVersion];
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

#pragma mark -
#pragma mark Connections methods

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
 
    if ([connection.connectionType isEqualToString: SHUTDOWN_RESPONCE])     currentCount = maxCount;
    
    if ([connection.connectionType isEqualToString: STATUS]){
        [checkedEncoder onBitrate:startRequestTime];
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

    if (currentFailCount--<=0)  {
        [checkedEncoder onEncoderMasterFallen:error];
    } else {
        NSString * failType = [error.userInfo objectForKey:@"NSLocalizedDescription"];
        PXPLog(@"EncoderStatus Error Countdown %i: %@", currentFailCount,failType);
    }
    
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    statusSync = YES;
    currentFailCount = maxFailCount;
    if ([connection.connectionType isEqualToString: STATUS])   {
        [self statusResponse:connection.cumulatedData];
    } else  if ([connection.connectionType isEqualToString: FEED_CHECK]) {
        // no need to check feeds now
    } else if( [connection.connectionType isEqualToString: SYNC_ME]){
        [checkedEncoder onTagsChange:connection.cumulatedData];
    }
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
    NSDictionary * results          = [Utility JSONDatatoDict:data];
    NSString     * legacyStatus;

    if (isLegacy){
        legacyStatus = [results objectForKey:@"status"] ;
        
        if ([legacyStatus isEqualToString:@"Event is being stopped"]) {
            statusCode = ENCODER_STATUS_STOP;
        } else if ([legacyStatus isEqualToString:@"paused"]) {
            statusCode = ENCODER_STATUS_PAUSED;
        } else if ([legacyStatus isEqualToString:@"stopped"]) {
            statusCode = ENCODER_STATUS_READY;
        } else if ([legacyStatus isEqualToString:@"live"]) {
            statusCode = ENCODER_STATUS_LIVE;
        } else if ([legacyStatus isEqualToString:@"pro recoder disconnected"]) {
            statusCode = ENCODER_STATUS_NOCAM;
        } else if ([legacyStatus isEqualToString:@"camera disconnected"]) {
            statusCode = ENCODER_STATUS_NOCAM;
        } else if ([legacyStatus isEqualToString:@"streaming app is starting"]) {
            statusCode = ENCODER_STATUS_CAM_LOADING;
        } else if ([legacyStatus isEqualToString:@"preparing to stream"]) {
            statusCode = ENCODER_STATUS_START;
        } else {
            statusCode = ENCODER_STATUS_UNKNOWN;
        }

    }  else { // new encoder version
        statusCode  = [[results objectForKey:@"code"]integerValue];
    }
    
    // this is for the older encoder versions
    [checkedEncoder assignMaster:results extraData:isLegacy];
    
    [checkedEncoder encoderStatusStringChange:results];
    [checkedEncoder encoderStatusChange:statusCode];
    [checkedEncoder onMotionAlarm:results];
}



#pragma mark -
#pragma mark Shutting down methods

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

