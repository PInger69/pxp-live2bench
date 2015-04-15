//
//  Encoder.h
//  Live2BenchNative
//
//  Created by dev on 10/17/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EncoderProtocol.h"
#import "EncoderStatusMonitor.h"
#import "EncoderCommands.h" // Depricated
#import "EncoderCommand.h" // Depricated
#import "Event.h"

#define OLD_VERSION  @"1.0.13"

#define NOTIF_ENCODER_CONNECTION_PROGRESS   @"encoderConnectionProgress"
#define NOTIF_ENCODER_CONNECTION_FINISH     @"encoderConnectionComplete"
#define NOTIF_ENCODER_FEEDS_UPDATED         @"encoderFeedsUpdated"
#define NOTIF_ENCODER_MASTER_FOUND          @"encoderMasterFound"
#define NOTIF_ENCODER_MASTER_HAS_FALLEN     @"encoderMasterLost"
#define NOTIF_ENCODER_MASTER_ENSLAVED       @"encoderMasterEnslaved"
#define NOTIF_THIS_ENCODER_IS_READY         @"encoderIsReady"


#define AUTHENTICATE    @"authenticate:timeStamp:"
#define BUILD           @"buildEncoder:timeStamp:"
#define VERSION         @"requestVersion:timeStamp:"
#define SHUTDOWN        @"shutdown:timeStamp:"
#define MODIFY_TAG      @"modifyTag:timeStamp:"
#define MAKE_TAG        @"makeTag:timeStamp:"
#define SUMMARY_GET     @"summaryGet:timeStamp:"
#define SUMMARY_PUT     @"summaryPut:timeStamp:"
#define TEAMS_GET       @"teamsGet:timeStamp:"
#define EVENT_GET_TAGS  @"eventTagsGet:timeStamp:"
#define CAMERAS_GET     @"camerasGet:timeStamp:"
#define ALL_EVENTS_GET_ @"allEventsGet:timeStamp:"

#define STOP_EVENT      @"stopEvent:timeStamp:"
#define PAUSE_EVENT     @"pauseEvent:timeStamp:"
#define RESUME_EVENT    @"resumeEvent:timeStamp:"
#define START_EVENT     @"startEvent:timeStamp:"

@interface Encoder : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate,EncoderCommands,EncoderProtocol>
{
    
    
    
    NSURLRequest            * urlRequest;
    NSURLConnection         * encoderConnection;
    NSMutableDictionary     * queue;
    float                   timeOut;
    BOOL                    isWaitiing;


    EncoderCommand         * currentCommand;
    EncoderStatusMonitor    * statusMonitor;
    NSDictionary            * rawEncoderData; // Data from getpastevents
}

@property (nonatomic,readonly)  BOOL            authenticated;

@property (nonatomic,strong)    NSString        * name;
@property (nonatomic,readonly)  NSString        * version;
@property (nonatomic,strong)    NSString        * ipAddress;
@property (nonatomic,strong)    NSString        * customerID;
@property (nonatomic,strong)    NSString        * URL;
@property (nonatomic,strong)    Event           * event;        // the current event the encoder is looking at
@property (nonatomic,strong)    Event           * liveEvent;
@property (nonatomic,strong)    NSDictionary    * allEvents;    // all events on the encoder

@property (nonatomic,assign)    EncoderStatus   status;
@property (nonatomic,strong)    NSString        * statusAsString;
@property (nonatomic,assign)    double          bitrate;

@property (nonatomic,readonly)  NSMutableString * log;
@property (nonatomic,assign)    BOOL            isMaster;
@property (nonatomic,assign)    NSInteger       cameraCount;
@property (nonatomic,strong)    NSMutableDictionary     * eventTagsDict; // keys are event names


@property (nonatomic,assign)    BOOL            isBuild;
@property (nonatomic,assign)    BOOL            isReady;
@property (nonatomic,assign)    BOOL            isAlive;

/**
 *  This will create and instance of an endcoder at inputted ip
 *
 *  @param ip encoder ip
 *
 *  @return instance
 */
-(id)initWithIP:(NSString*)ip;

/**
 *  This will give access to an encoder if their ID mataches the encoder
 *
 *  @param custID customer ID
 */
-(void)authenticateWithCustomerID:(NSString*)custID;

/**
 *  This will get the Verions of the encoder
 *
 */
-(void)requestVersion;

-(void)buildEncoderRequest;

-(void)issueCommand:(NSString *)methodName priority:(int)priority timeoutInSec:(float)time tagData:(NSMutableDictionary*)tData  timeStamp:(NSNumber *)aTimeStamp;

-(void)clearQueueAndCurrent;

-(void)searchForMaster;




/**
 *  removes all observers and checker and release memory if possible
 */
-(void)destroy;


@end
