//
//  PxpResponse.h
//  Live2BenchNative
//
//  Created by dev on 2016-01-11.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PxpURLResponse : NSObject

@property(assign, nonatomic) NSInteger  errorCode;
@property(strong, nonatomic) NSDictionary* response;

+(PxpURLResponse*) responseWithDictionary:(NSDictionary*) dictionary errorCode:(NSInteger) errorCode;

@end

