//
//  Ticker.m
//  Live2BenchNative
//
//  Created by dev on 2016-06-13.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "Ticker.h"

@implementation Ticker
- (instancetype)initWithTick:(NSInteger)tick
{
    self = [super init];
    if (self) {
        self.maxTick        = tick;
        self.currentTick    = 0;
    }
    return self;
}


-(BOOL)ready
{
    if (self.currentTick == 0){
        self.currentTick = self.maxTick;
        return YES;
    } else {
        self.currentTick--;
        return NO;
    }
    
    
}

@end
