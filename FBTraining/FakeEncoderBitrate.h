//
//  FakeEncoderBitrate.h
//  Live2BenchNative
//
//  Created by dev on 2016-04-18.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EncoderProtocol.h"
@class Event;
@class PxpEventContext;


@interface FakeEncoderBitrate : NSObject <EncoderProtocol>


@property (nonatomic,strong)    NSString                * name;
@property (nonatomic, weak)     EncoderManager          * encoderManager;
@property (nonatomic,assign)    EncoderStatus           status;
@property (nonatomic,strong)    NSString                * statusAsString;
@property (nonatomic,strong)    Event                   * event;        // the current event the encoder is looking at
@property (nonatomic,strong)    NSDictionary            * allEvents;    // all events on the encoder keyed by HID
@property (readonly, strong, nonatomic) PxpEventContext *eventContext;
@property (nonatomic, copy) void(^onComplete)();
@property (nonatomic,readonly)    NSString             * version;
@property (nonatomic,assign)    double               bitrate;
@property (nonatomic,assign)    NSInteger       cameraCount;
@property (nonatomic,strong)    Event                * liveEvent;
@property (nonatomic,strong)    NSDictionary         * encoderTeams; // all teams on encoder
@property (nonatomic,strong)    NSDictionary         * encoderLeagues;

-(void)resetEventAfterRemovingFeed:(Event *)event;
-(void)clearQueueAndCurrent;
-(void) writeToPlist;
-(void)issueCommand:(NSString *)methodName priority:(int)priority timeoutInSec:(float)time tagData:(NSMutableDictionary*)tData  timeStamp:(NSNumber *)aTimeStamp onComplete:(void(^)(NSDictionary*userInfo))onComplete;
-(void)issueCommand:(NSString *)methodName priority:(int)priority timeoutInSec:(float)time tagData:(NSMutableDictionary*)tData  timeStamp:(NSNumber *)aTimeStamp;
-(Event*)getEventByName:(NSString*)eventName;
-(void)runOperation:(EncoderOperation*)operation;
-(id <EncoderProtocol>)makePrimary;
-(id <EncoderProtocol>)removeFromPrimary;


@end
