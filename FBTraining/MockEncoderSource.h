//
//  MockEncoderSource.h
//  Live2BenchNative
//
//  Created by dev on 2016-02-17.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MockURLProtocol.h"
#import "PxpURLResponse.h"

@interface MockEncoderSource : NSObject




+(MockEncoderSource*) instance;


@property (nonatomic,strong) NSDictionary * eventData;
-(PxpURLResponse*) handleRequest:(NSURLRequest*) request;



@end
