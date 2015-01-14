//
//  Encoder.h
//  Live2BenchNative
//
//  Created by dev on 10/17/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EncoderStatusMonitor.h"
#import "EncoderCommands.h"
#import "EncoderCommand.h"

#define OLD_VERSION  @"1.0.13"

#define NOTIF_ENCODER_CONNECTION_PROGRESS   @"encoderConnectionProgress"
#define NOTIF_ENCODER_CONNECTION_FINISH     @"encoderConnectionComplete"
#define NOTIF_ENCODER_FEEDS_UPDATED         @"encoderFeedsUpdated"
#define NOTIF_ENCODER_MASTER_FOUND          @"encoderMasterFound"
#define NOTIF_ENCODER_MASTER_HAS_FALLEN     @"encoderMasterLost"
#define NOTIF_ENCODER_MASTER_ENSLAVED       @"encoderMasterEnslaved"
#define NOTIF_THIS_ENCODER_IS_READY         @"encoderIsReady"
#define NOTIF_LIVE_EVENT_FOUND              @"encoderLiveFound"

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


#define STOP_EVENT      @"stopEvent:timeStamp:"
#define PAUSE_EVENT     @"pauseEvent:timeStamp:"
#define RESUME_EVENT    @"resumeEvent:timeStamp:"
#define START_EVENT     @"startEvent:timeStamp:"

@interface Encoder : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate,EncoderCommands>
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
@property (nonatomic,strong)    NSString        * event;        // the current event the encoder is looking at
@property (nonatomic,strong)    NSString        * eventType;        // the current event the encoder is looking at
@property (nonatomic,strong)    NSArray         * eventTags;        // the current event the encoder is looking at
@property (nonatomic,strong)    NSString        * liveEventName;
@property (nonatomic,strong)    NSDictionary    * eventData;   //raw dict
@property (nonatomic,strong)    NSArray         * allEvents;    // all events on the encoder
@property (nonatomic,strong)    NSArray         * allEventData;
@property (nonatomic,strong)    NSDictionary    * feeds;// feeds for current event

@property (nonatomic,strong)    NSDictionary    * teams;
@property (nonatomic,strong)    NSDictionary    * playerData;
@property (nonatomic,strong)    NSDictionary    * league;

@property (nonatomic,assign)    EncoderStatus   status;
@property (nonatomic,strong)    NSString        * statusAsString;
@property (nonatomic,assign)    double          bitrate;

@property (nonatomic,readonly)  NSMutableString * log;
@property (nonatomic,assign)    BOOL            isMaster;
@property (nonatomic,assign)    NSInteger       cameraCount;
@property (nonatomic,strong)    NSMutableDictionary     * eventTagsDict; // keys are event names

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

//-(void)deleteEvent:(NSString*) eventName;
//-(int)downloadProgress;
//-(void)downloadEventToUSB;
//-(void)checkSpace;
//
//-(void)shutdown;
//-(void)sync;
//-(void)getCameras;
//
//
////Live commands
//-(void)startLive;
//-(void)stopLive;
//-(void)pauseLive;


//mod tags
//make tags
//all tags

//get past events

//get cameras
//create tele set
//tele vid + catagory

@end
