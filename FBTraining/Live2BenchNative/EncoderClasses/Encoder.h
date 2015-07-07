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
#import "ActionListItem.h"


@class EncoderManager;



#define OLD_VERSION  @"1.0.13"

#define NOTIF_ENCODER_CONNECTION_PROGRESS   @"encoderConnectionProgress"
#define NOTIF_ENCODER_CONNECTION_FINISH     @"encoderConnectionComplete"
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
#define MAKE_TELE_TAG   @"makeTeleTag:timeStamp:"
#define SUMMARY_GET     @"summaryGet:timeStamp:"
#define SUMMARY_PUT     @"summaryPut:timeStamp:"
#define TEAMS_GET       @"teamsGet:timeStamp:"
#define EVENT_GET_TAGS  @"eventTagsGet:timeStamp:"
#define CAMERAS_GET     @"camerasGet:timeStamp:"
#define ALL_EVENTS_GET_ @"allEventsGet:timeStamp:"
#define DELETE_EVENT    @"deleteEvent:timeStamp:"

#define STOP_EVENT      @"stopEvent:timeStamp:"
#define PAUSE_EVENT     @"pauseEvent:timeStamp:"
#define RESUME_EVENT    @"resumeEvent:timeStamp:"
#define START_EVENT     @"startEvent:timeStamp:"

@interface Encoder : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate,EncoderCommands,EncoderProtocol,EncoderStatusMonitorProtocol,ActionListItem>
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
@property (nonatomic,strong)    NSMutableDictionary    * allEvents;    // all events on the encoder
@property (nonatomic,weak)      EncoderManager  * encoderManager;
@property (nonatomic,assign)    EncoderStatus   status;
@property (nonatomic,strong)    NSString        * statusAsString;
@property (nonatomic,assign)    double          bitrate;

@property (nonatomic,assign)    BOOL            isMaster;
@property (nonatomic,assign)    NSInteger       cameraCount;
//@property (nonatomic,strong)    NSMutableDictionary     * eventTagsDict; // keys are event names


@property (nonatomic,strong)    NSDictionary         * encoderTeams; // all teams on encoder
@property (nonatomic,strong)    NSDictionary         * encoderLeagues;

@property (nonatomic,assign)    BOOL            isBuild;
@property (nonatomic,assign)    BOOL            isReady;
@property (nonatomic,assign)    BOOL            isAlive;
@property (nonatomic,assign)    BOOL            justStarted;
@property (nonatomic,assign)    BOOL            pressingStart;

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

-(Event*)getEventByName:(NSString*)eventName;


//Don't know why I need all these, but have to add them to get rid of errors
-(void)getAllEventsResponse:(NSData *)data;
-(void)stopResponce:(NSData *)data;
-(void)startResponce:(NSData *)data;
-(void)pauseResponce:(NSData *)data;
-(void)resumeResponce:(NSData *)data;
-(void)camerasGetResponce:(NSData *)data;
-(void)eventTagsGetResponce:(NSData *)data extraData:(NSDictionary*)dict;
-(void)deleteEventResponse: (NSData *) data;
-(void)removeFromQueue:(EncoderCommand *)obj;
-(void)addToQueue:(EncoderCommand *)obj;
-(EncoderCommand *)getNextInQueue;

/**
 *  removes all observers and checker and release memory if possible
 */
-(void)destroy;


// ActionListItem Methods
@property (nonatomic,assign) BOOL isFinished;
@property (nonatomic,assign) BOOL isSuccess;
@property (nonatomic,weak)  id <ActionListItemDelegate>  delegate;

-(void)start;

//Methods for Local Encoder to update its tags
//-(void)makeTag:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp;



@end
