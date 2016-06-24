//
//  CameraDetails.h
//  Live2BenchNative
//
//  Created by andrei on 2015-06-09.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "Encoder.h"

@interface CameraDetails : NSObject

@property (nonatomic, strong)     NSString        *name;
@property (nonatomic, readonly)     NSString        *cameraID;
@property (nonatomic, readonly)     NSString        *ipAddress;
@property (nonatomic, readonly)     NSString        *source;
@property (nonatomic, readonly)     NSString        *type;
@property (nonatomic, readonly)     NSString        *resolution;
@property (nonatomic, readonly)     NSString        *rtsp;
@property (nonatomic, strong)       NSString        *recommendedPositionDual;
@property (nonatomic, strong)       NSString        *recommendedPositionQuad;
@property (nonatomic, readonly)     NSNumber        *fps;
@property (nonatomic, weak)         Encoder         *encoder;

-(id)initWithDictionary:(NSDictionary *)dict encoderOwner:(Encoder *)encoder;

@end
