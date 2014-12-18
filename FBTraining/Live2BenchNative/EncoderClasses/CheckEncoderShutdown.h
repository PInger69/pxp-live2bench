//
//  CheckEncoderShutdown.h
//  Live2BenchNative
//
//  Created by dev on 10/23/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CheckEncoderShutdown : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

-(id)initWithIP:(NSString*)ip block:(void(^)(void))onShutdown;

-(void)start;
@end
