//
//  DeviceEncoderSource.h
//  Live2BenchNative
//
//  Created by dev on 2016-01-11.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PxpURLResponse.h"

@interface DeviceEncoderSource : NSObject

+(DeviceEncoderSource*) instance;

@property (nonatomic,assign) NSInteger      cameraCount;
@property (nonatomic,strong) NSDictionary * eventData;
-(PxpURLResponse*) handleRequest:(NSURLRequest*) request;



@end
