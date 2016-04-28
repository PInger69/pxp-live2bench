//
//  NullCameraDetails.m
//  Live2BenchNative
//
//  Created by dev on 2016-04-27.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "NullCameraDetails.h"

@implementation NullCameraDetails


- (instancetype)init
{
    NSDictionary * dict = @{
                            @"type"	: @"",
                            @"fps"	: @0,
                            @"sidx"	: @"",
                            @"mac"	: @"",
                            @"ip"	: @"",
                            @"name"	: @"none",
                            @"url"	: @""
                            };
    
    
    self = [super initWithDictionary:dict encoderOwner:nil];
    if (self) {
        
        
        
        
    }
    return self;
}

@end
