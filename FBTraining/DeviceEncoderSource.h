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

@property (atomic,strong) NSString               * customerID;
@property (atomic,strong) NSString               * customerAuthorization;
@property (atomic,strong) NSString               * customerEmail;
@property (atomic,strong) NSString               * userHID;
@property (atomic,strong) UIColor                * customerColor;


-(PxpURLResponse*) handleRequest:(NSURLRequest*) request;



@end
