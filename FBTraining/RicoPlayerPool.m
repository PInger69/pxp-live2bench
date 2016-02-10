//
//  RicoPlayerPool.m
//  Live2BenchNative
//
//  Created by dev on 2016-02-04.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "RicoPlayerPool.h"
static RicoPlayerPool * instance;

@implementation RicoPlayerPool


+(instancetype)instance
{
    return instance;
}

+(void)initialize
{
    instance = [RicoPlayerPool new];
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.pooledPlayers      = [NSMutableArray new];
        self.defaultController  = [RicoPlayerViewController new];
    }
    return self;
}






@end
