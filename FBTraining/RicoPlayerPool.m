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
        
        
        NSString * mode = [UserCenter getInstance].l2bMode;
        if ([mode isEqualToString:L2B_MODE_STREAM_OPTIMIZE]) {
            self.defaultController  = [RicoPlayerViewControllerSO new];
        } else if ([mode isEqualToString:L2B_MODE_HQ]) {
            self.defaultController  = [RicoPlayerViewController new];
        } else { // default L2B_MODE_PROXY
            self.defaultController  = [RicoPlayerViewController new];
        }
        
        
    }
    return self;
}


// maybe make a method to swap player Contollers



@end
