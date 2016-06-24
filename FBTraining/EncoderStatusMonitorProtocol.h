//
//  EncoderStatusMonitorProtocol.h
//  Live2BenchNative
//
//  Created by dev on 2015-06-08.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"


@class Encoder;
@protocol EncoderStatusMonitorProtocol <NSObject>

//- (void) onUserInfo;
-(void)onEncoderMasterFallen:(NSError *)error;
- (void) onTagsChange:(NSData *) data;
//- (void) onMotionAlarm:(NSDictionary *)data;
- (void) encoderStatusChange:(EncoderStatus) status;
- (void) encoderStatusStringChange:(NSDictionary *)data;
- (BOOL) checkEncoderVersion;
- (void) assignMaster:(NSDictionary *)data extraData:(BOOL)olderVersion;
- (void) onBitrate:(NSDate *)startTime;

@property (nonatomic,strong)    NSString             * ipAddress;
@property (nonatomic,strong)    Event           * event;        // the current event the encoder is looking at
@property (nonatomic,strong)    Event           * liveEvent;


@end
