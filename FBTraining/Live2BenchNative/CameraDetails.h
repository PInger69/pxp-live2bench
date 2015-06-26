//
//  CameraDetails.h
//  Live2BenchNative
//
//  Created by andrei on 2015-06-09.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "Encoder.h"

@interface CameraDetails : NSObject

@property (nonatomic, readonly)     NSString        *name;
@property (nonatomic, readonly)     NSString        *type;
@property (nonatomic, readonly)     NSNumber        *fps;
@property (nonatomic, weak)         Encoder         *encoder;

-(id)initWithDictionary:(NSDictionary *)dict encoderOwner:(Encoder *)encoder;

@end
