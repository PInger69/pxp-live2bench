//
//  PxpPlayerRebooter.m
//  Live2BenchNative
//
//  Created by dev on 2015-10-27.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpPlayerRebooter.h"

@implementation PxpPlayerRebooter


-(instancetype)initWithPlayer:(PxpPlayer *)player
{
    self = [super init];
    if (self) {
        self.timeOfFail = player.currentTime;
        
        
    }
    return self;

}

- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}


@end
