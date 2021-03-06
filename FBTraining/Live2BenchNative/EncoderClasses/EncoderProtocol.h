//
//  EncoderProtocol.h
//  Live2BenchNative
//
//  Created by dev on 2015-03-27.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PxpEventContext.h"
#import "EncoderParseProtocol.h"
#import "CameraResource.h"


@class Event;
@class EncoderOperation;


typedef NS_OPTIONS(NSInteger, EncoderStatus)  {
    ENCODER_STATUS_UNKNOWN        = 0,
    ENCODER_STATUS_INIT           = 1<<0, //encoder is initializing (pxpservice just started)
    ENCODER_STATUS_CAM_LOADING    = 1<<1, //the camera is initializing (searching for teradek cube's or matrox monarch's)
    ENCODER_STATUS_READY          = 1<<2, //encoder is ready to start an event
    ENCODER_STATUS_LIVE           = 1<<3, //there is a live event
    ENCODER_STATUS_SHUTDOWN       = 1<<4, //encoder is shutting down
    ENCODER_STATUS_PAUSED         = 1<<5, //the live event is paused
    ENCODER_STATUS_STOP           = 1<<6, //live event is stopping
    ENCODER_STATUS_START          = 1<<7, //live event starting
    ENCODER_STATUS_NOCAM          = 1<<8,  //no camera found
    ENCODER_STATUS_LOCAL          = 1<<10,  //no camera found
    FILLER                        = 257
};






@protocol EncoderProtocol <NSObject>

@property (nonatomic,strong)    NSString                * name;
@property (nonatomic,assign)    EncoderStatus           status;
@property (nonatomic,strong)    NSString                * statusAsString;
@property (nonatomic,strong)    Event                   * event;        // the current event the encoder is looking at
@property (nonatomic,strong)    Event                   * liveEvent;
@property (nonatomic,strong)    NSMutableDictionary            * allEvents;    // all events on the encoder keyed by HID
@property (readonly, strong, nonatomic) PxpEventContext *eventContext;

@property (nonatomic,strong)    NSString        *urlProtocol;//http
@property (nonatomic,strong)    NSString        * ipAddress;
@property (nonatomic,strong)    id <EncoderParseProtocol> parseModule;
@property (nonatomic,strong)    NSMutableSet    *postedTagIDs;
@property (nonatomic,assign )  BOOL            authenticated;
@property (nonatomic,strong)    CameraResource              * cameraResource;
@property (nonatomic,strong)  NSString        * version;
@property (nonatomic,strong)    NSOperationQueue * operationQueue; // new

-(id <EncoderProtocol>)makePrimary;
-(id <EncoderProtocol>)removeFromPrimary;

-(void)issueCommand:(NSString *)methodName priority:(int)priority timeoutInSec:(float)time tagData:(NSMutableDictionary*)tData  timeStamp:(NSNumber *)aTimeStamp;



-(Event*)getEventByName:(NSString*)eventName;

// This adds a layer of abstarction so we let the encoder it self manage the operaions
-(void)runOperation:(EncoderOperation*)operation;

@optional
-(void)issueCommand:(NSString *)methodName priority:(int)priority timeoutInSec:(float)time tagData:(NSMutableDictionary*)tData  timeStamp:(NSNumber *)aTimeStamp onComplete:(void(^)(NSDictionary*userInfo))onComplete;
@property (nonatomic, copy) void(^onComplete)();

@property (nonatomic,assign)    double               bitrate;
@property (nonatomic,assign)    NSInteger       cameraCount;

@property (nonatomic,strong)    NSDictionary         * encoderTeams; // all teams on encoder
@property (nonatomic,strong)    NSDictionary         * encoderLeagues;
-(void)resetEventAfterRemovingFeed:(Event *)event;
-(void)clearQueueAndCurrent;
-(void) writeToPlist;
-(void)encoderStatusChange:(EncoderStatus)status;
-(void)encoderStatusStringChange:(NSDictionary *)data;
-(void)assignMaster:(NSDictionary *)data extraData:(BOOL)olderVersion;
@end
