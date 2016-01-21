//
//  PxpResponse.m
//  Live2BenchNative
//
//  Created by dev on 2016-01-11.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "PxpURLResponse.h"

@implementation PxpURLResponse


+(PxpURLResponse*) responseWithDictionary:(NSDictionary*) dictionary errorCode:(NSInteger)errorCode {
    PxpURLResponse* ret = [[PxpURLResponse alloc] init];
    
    ret.response    = dictionary;
    ret.errorCode   = errorCode;

    return ret;
}

@end
