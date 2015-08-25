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
#import "SpinnerView.h"

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
    NSMutableData           * cumulatedData;
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
        statusSync          = YES; // to make sure that Sync never runs more then once
        statusTimer         = [NSTimer scheduledTimerWithTimeInterval:statusInterval target:self selector:@selector(statusLoop) userInfo:nil repeats:YES];
        
        //Building SyncMe Invocation
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithDictionary:@{
                                                                                     @"user"         : [UserCenter getInstance].userHID,
                                                                                     @"requesttime"  : GET_NOW_TIME_STRING, //[NSString stringWithFormat:@"%f",0]
                                                                                     @"event"        : @"live",
                                                                                     @"device"       : [UserCenter getInstance].customerAuthorization
                                                                                     }];
        

        NSString *jsonString = [Utility dictToJSON:dict];
        syncMePath = [NSString stringWithFormat:@"http://%@/min/ajax/syncme/%@", ipAddress, jsonString];
        

        selector_ = NSSelectorFromString(@"encoderStatusInvocker:type:timeout:");
        statusPath          = [NSString stringWithFormat:@"http://%@/min/ajax/encoderstatjson/",ipAddress];

        timeout             = 6 ;
        statusInvocation    = [self _buildInvokSel:selector_ path:statusPath  type:STATUS       timeout:&timeout];
        syncMeInvocation      = [self _buildInvokSel:selector_ path:syncMePath type:SYNC_ME       timeout:&timeout];
        
        [statusPack addObject: statusInvocation];
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
 
    if ([connectType isEqualToString: SHUTDOWN_RESPONCE])     currentCount = maxCount;
    
    if ([connectType isEqualToString: STATUS]){
        [checkedEncoder onBitrate:startRequestTime];
    }
    cumulatedData = [[NSMutableData alloc]init];

}

// This collects the data
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if(!cumulatedData)
    {
        cumulatedData = [NSMutableData data];
    }
    [cumulatedData appendData:data];
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
    cumulatedData = nil;
    
    /*[[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_OPEN_SPINNER
                                                       object:nil
                                                     userInfo:[SpinnerView message:@"Checking for WiFi..." progress:0 animated:YES]];*/
    BOOL hasWifi = [Utility hasInternet];
    //[[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_CLOSE_SPINNER object:nil];
    //[Utility hasWiFi];
    if (!hasWifi) {
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_LOST_WIFI object:nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_STATUS_LABEL_CHANGED object:nil userInfo:@{@"text":@"No Wifi"}];
        [self destroy];
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    statusSync = YES;
    currentFailCount = maxFailCount;
    if ([connectType isEqualToString: STATUS])   {
        [self statusResponse:cumulatedData];
    } else if( [connectType isEqualToString: SYNC_ME]){
        [checkedEncoder onTagsChange:cumulatedData];
    }
    cumulatedData = nil;
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
    connectType                         = aType;
    
    // debugging
    if ([connectType isEqualToString:@"SYNC_ME"]) {
       
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithDictionary:@{
                                                                                     @"user"         : [UserCenter getInstance].userHID,
                                                                                     @"requesttime"  : GET_NOW_TIME_STRING, //[NSString stringWithFormat:@"%f",0]
                                                                                     @"event"        : @"live",
                                                                                     @"device"       : [UserCenter getInstance].customerAuthorization
                                                                                     }];
        
        if (dict) {
            PXPLogAjax(@"http://%@/min/ajax/syncme/%@", ipAddress, dict);
        }
        
    } else {
            PXPLogAjax(aPath);
    }
    
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
    PXPLogAjax(checkURL.absoluteString);
    urlRequestShutdown          = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:1];
    encoderConnectionShutdown   = [NSURLConnection connectionWithRequest:urlRequestShutdown delegate:self];
    connectType                 = SHUTDOWN_RESPONCE;
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
    if (statusTimer)    [statusTimer invalidate];
    if (shutdownTimer)  [shutdownTimer invalidate];
}

@end

