//
//  EncoderStatusMonitor.h
//  Live2BenchNative
//
//  Created by dev on 10/24/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Encoder;
typedef NS_ENUM(NSInteger, EncoderStatus)  {
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


@interface EncoderStatusMonitor : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic,assign)    BOOL    isLookingForMaster;

-(id)initWithEncoder:(Encoder*)encoder;
-(void)startShutdownChecker:(void(^)(void))onShutdown;
-(void)destroy;

@end
