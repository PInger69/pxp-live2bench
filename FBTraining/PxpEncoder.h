//
//  PxpEncoder.h
//  Live2BenchNative
//
//  Created by dev on 2016-06-10.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CameraResource.h"
#import "EncoderProtocol.h"
#import "EncoderStatusMonitor.h"
#import "EncoderParseProtocol.h"

@interface PxpEncoder : NSObject <EncoderStatusMonitorProtocol>


// Encoder
@property (nonatomic,assign)  BOOL            authenticated;
@property (nonatomic,strong)    PxpEventContext * eventContext;
@property (nonatomic,strong)    NSString        * name;
@property (nonatomic,strong)  NSString        * version;
@property (nonatomic,strong)    NSString        * ipAddress;
@property (nonatomic,strong)    NSString        * customerID;
@property (nonatomic,strong)    NSString        * URL;
@property (nonatomic,strong)    Event           * event;        // the current event the encoder is looking at
@property (nonatomic,strong)    Event           * liveEvent;




@property (nonatomic,strong)    NSMutableSet                *postedTagIDs;      // This is used to keep track of Duration Tag IDs
@property (nonatomic,strong)    id <EncoderParseProtocol>       parseModule;    // This is an interface layer with Encoder (maybe move to Encoder operation)
@property (nonatomic,strong)    CameraResource              * cameraResource;   // This keeps track of Cameras on Encoder
@property (nonatomic,strong)    EncoderStatusMonitor        * statusMonitor;    // status monitor as well as Motion. set Motion delegate to get motion
@property (nonatomic,assign)    EncoderStatus   status;
@property (nonatomic,assign)    double          bitrate;

-(id)initWithIP:(NSString*)ip;


-(void)runOperation:(EncoderOperation*)operation;

-(void)destroy;

@end
