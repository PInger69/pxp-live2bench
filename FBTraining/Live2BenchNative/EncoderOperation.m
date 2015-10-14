//
//  EncoderOperation.m
//  Live2BenchNative
//
//  Created by dev on 2015-10-13.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "EncoderOperation.h"

@implementation EncoderOperation



- (instancetype)initURL:(NSURL*)aURL
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (instancetype)initString:(NSString*)stringUrl
{
    self = [self initURL:[NSURL URLWithString:stringUrl]];
    if (self) {
        // nothing
    }
    return self;
}


@end
