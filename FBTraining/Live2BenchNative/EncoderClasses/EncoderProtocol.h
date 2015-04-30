//
//  EncoderProtocol.h
//  Live2BenchNative
//
//  Created by dev on 2015-03-27.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Event;
@class EncoderManager;


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
@property (nonatomic, weak)     EncoderManager          *encoderManager;
@property (nonatomic,assign)    EncoderStatus           status;
@property (nonatomic,strong)    NSString                * statusAsString;
@property (nonatomic,strong)    Event                   * event;        // the current event the encoder is looking at
@property (nonatomic,strong)    NSDictionary            * allEvents;    // all events on the encoder keyed by HID

-(void)issueCommand:(NSString *)methodName priority:(int)priority timeoutInSec:(float)time tagData:(NSMutableDictionary*)tData  timeStamp:(NSNumber *)aTimeStamp;
-(Event*)getEventByName:(NSString*)eventName;

@optional
@property (nonatomic,strong)    Event                * liveEvent;
@property (nonatomic,strong)    NSDictionary         * encoderTeams; // all teams on encoder
@property (nonatomic,strong)    NSDictionary         * encoderLeagues;
-(void)clearQueueAndCurrent;




// depricated
//@property (nonatomic,strong)    NSString                * eventType;        // the current event the encoder is looking at
//@property (nonatomic,strong)    NSArray                 * eventTags;        // the current event the encoder is looking at
//@property (nonatomic,strong)    NSDictionary            * eventData;   //raw dict
//@property (nonatomic,strong)    NSArray                 * allEventData;
//@property (nonatomic,strong)    NSMutableDictionary     * eventTagsDict; // keys are event names
//@property (nonatomic,strong)    NSDictionary            * feeds;// feeds for current event

//@property (nonatomic,strong)    NSDictionary    * playerData;






@end
