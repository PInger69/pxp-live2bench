
//
//  EncoderStatusMonitor.m
//  Live2BenchNative
//
//  Created by dev on 10/24/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "EncoderStatusMonitor.h"
#import "EncoderStatusMonitorProtocol.h"
#import "UserCenter.h"
#import "PxpURLProtocol.h"

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

    id <EncoderStatusMonitorProtocol>     checkedEncoder;
    // For Status
    NSString                * ipAddress;
    NSTimer                 * statusTimer;
    NSTimeInterval          statusInterval;
    int                     maxFailCount;
    int                     currentFailCount;
    EncoderStatus           statusCode;
    NSDate                  *startRequestTime;
    BOOL                    statusSync;
    NSInteger               timeoutCount;
    // For shutdown
    void (^onServerShutdown)(void);
    int                     maxCount;
    int                     currentCount;
    float                   shutdownTimerInterval;
    NSTimer                 * shutdownTimer;
    double                  timeout;
    BOOL                    isLegacy;
    NSString                * connectType;
    NSInteger               statusPick;
    NSArray                     * checkers;
    NSURLSessionConfiguration   * sessionConfig;
}



@synthesize isLookingForMaster = _isLookingForMaster;
@synthesize urlProtocol = _urlProtocol;

-(id)initWithDelegate:(id<EncoderStatusMonitorProtocol>)delegate
{
    self = [super init];
    if (self){
        checkedEncoder      = delegate;
        ipAddress           = delegate.ipAddress;
        statusInterval      = 1.0;
        timeoutCount        = 3;
        checkers            = @[
                                [NSNumber numberWithInteger:EncoderMonitorStatus],
                                [NSNumber numberWithInteger:EncoderMonitorSyncMe]
                                ];
        _urlProtocol        = @"http";
        maxFailCount        = 5; // 3 tries   0 index
        currentFailCount    = maxFailCount;

        sessionConfig                                   = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfig.allowsCellularAccess              = NO;
        sessionConfig.timeoutIntervalForRequest         = 10;
        sessionConfig.timeoutIntervalForResource        = 10;
        sessionConfig.HTTPMaximumConnectionsPerHost     = 1;
        sessionConfig.protocolClasses = @[[PxpURLProtocol class]];
        
        statusSync          = YES; // to make sure that Sync never runs more then once
        timeout             = 10 ;
        statusPick          = 0;
        statusTimer         = [NSTimer scheduledTimerWithTimeInterval:statusInterval target:self selector:@selector(statusLoop) userInfo:nil repeats:YES];
        isLegacy            = [checkedEncoder checkEncoderVersion];


    }
    return self;

}


-(void)onError:(NSError *)error
{
    if (currentFailCount--<=0)  {
        [checkedEncoder onEncoderMasterFallen:error];
        PXPLog(@"EncoderStatus Shutdown Monitor");
    } else {
        NSString * failType = [error.userInfo objectForKey:@"NSLocalizedDescription"];
        PXPLog(@"EncoderStatus Error Countdown %i: %@ %@", currentFailCount,failType,ipAddress);
        
    }

    if (![Utility hasWiFi]) {
        [self destroy];
        PXPLog(@"EncoderStatus Error Destroying Monitor");
        
    }

}


/*
    This is run once for every interval
 */
-(void)statusLoop
{

    statusPick ++;
    statusPick =  statusPick % [checkers count];
    switch ([checkers[statusPick]integerValue]) {
        case EncoderMonitorStatus:
            [self statusCheck];
            break;
        case EncoderMonitorSyncMe:
            [self syncCheck];
            break;
        default:
            break;
    }
}



-(void)statusCheck
{
    if (!statusSync)return;
    
    NSString * statusPath = [NSString stringWithFormat:@"%@://%@/min/ajax/encoderstatjson/",_urlProtocol,ipAddress];
    NSURLRequest * _urlRequest                          = [NSURLRequest requestWithURL: [ NSURL URLWithString:  statusPath]
                                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:timeout];

    connectType                         = STATUS;
    startRequestTime                    = [NSDate date];
    statusSync                          = NO;
    
   NSURLSession * sess = [NSURLSession sessionWithConfiguration:sessionConfig delegate:nil delegateQueue:[NSOperationQueue mainQueue]];

    NSURLSessionDataTask * dataT = [sess dataTaskWithRequest:_urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        statusSync                          = YES;
        if (error){
            [self onError:error];
        } else {
            [checkedEncoder onBitrate:startRequestTime];
            [self statusResponse:data];
            currentFailCount    = maxFailCount;
        }
    }];
    [dataT resume];
}

-(void)syncCheck
{
    if (!statusSync  || ![checkedEncoder event])return;

    
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithDictionary:@{
                                                                                 @"user"         : [UserCenter getInstance].userHID,
                                                                                 @"requesttime"  : GET_NOW_TIME_STRING, //[NSString stringWithFormat:@"%f",0]
                                                                                 @"event"        : ([[checkedEncoder event].name isEqualToString:[checkedEncoder liveEvent].name])?@"live":[checkedEncoder event].name,//,
                                                                                 @"device"       : [UserCenter getInstance].customerAuthorization
                                                                                 }];
    
    NSString *jsonString = [Utility dictToJSON:dict];
    NSString * syncPath = [NSString stringWithFormat:@"%@://%@/min/ajax/syncme/%@",_urlProtocol, ipAddress, jsonString];
    
    
    
    

    NSURLRequest * _urlRequest          = [NSURLRequest requestWithURL: [ NSURL URLWithString: syncPath ] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:timeout];
    connectType                         = SYNC_ME;
    startRequestTime                    = [NSDate date];
    statusSync                          = NO;
    
    
    NSURLSession * sess = [NSURLSession sessionWithConfiguration:sessionConfig delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    __weak NSURLSession * weakSess = sess;
    NSURLSessionDataTask * dataT = [sess dataTaskWithRequest:_urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        statusSync                          = YES;
        if (error){
            [self onError:error];
        } else {
            [checkedEncoder onTagsChange:data];
            currentFailCount    = maxFailCount;
        }
//        [weakSess finishTasksAndInvalidate];
    }];
    [dataT resume];
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
            timeoutCount--;
            if (timeoutCount < 0){
                statusCode = ENCODER_STATUS_UNKNOWN;
            } else {
                PXPLogAjax(@"Error in connection");
            }
        }
        
        if (legacyStatus){
            timeoutCount = 3;
        }

    }  else { // new encoder version
        
        
        statusCode  = [[results objectForKey:@"code"]integerValue];
    }
    
    // this is for the older encoder versions
    [checkedEncoder assignMaster:results extraData:isLegacy];
    
    [checkedEncoder encoderStatusStringChange:results];
    [checkedEncoder encoderStatusChange:statusCode];
    
    
//    if ([self.motionDelegate respondsToSelector:@selector(onMotionAlarm:)]){
        if ([results objectForKey:@"alarms"] && [((NSArray*)[results objectForKey:@"alarms"]) count]) {
//            [self.motionDelegate onMotionAlarm:results];
            self.onMotion(self,results);
        }
//    }
    
    
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
    NSURL * checkURL            = [NSURL URLWithString:   [NSString stringWithFormat:@"%@://%@/min/ajax/encoderstatjson/",_urlProtocol,ipAddress]  ];
    NSURLRequest * urlRequestShutdown  = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:1];
    connectType                 = SHUTDOWN_RESPONCE;
    
    
   NSURLSessionConfiguration* sessionConfig2        = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig2.allowsCellularAccess              = NO;
    sessionConfig2.timeoutIntervalForRequest         = 3;
    sessionConfig2.timeoutIntervalForResource        = 3;
    sessionConfig2.HTTPMaximumConnectionsPerHost     = 1;
    
    NSURLSession * sess = [NSURLSession sessionWithConfiguration:sessionConfig2 delegate:nil delegateQueue:nil];
    __weak NSURLSession * weakSess = sess;
    NSURLSessionDataTask * dataT = [sess dataTaskWithRequest:urlRequestShutdown completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        if (error){
            [self onError:error];
        } else {
            currentCount = maxCount;
        }
        
//        [weakSess finishTasksAndInvalidate];

    }];
    [dataT resume];
    
}

/**
 *  Invalidates timer and runs block
 */
-(void)serverHasShutdown
{
    [shutdownTimer invalidate];
    if (onServerShutdown) onServerShutdown();
}


#pragma mark -
-(void)destroy
{
    if (statusTimer)    [statusTimer invalidate];
    if (shutdownTimer)  [shutdownTimer invalidate];
}

-(void)dealloc
{
    if (statusTimer)    [statusTimer invalidate];
    if (shutdownTimer)  [shutdownTimer invalidate];
}

@end

