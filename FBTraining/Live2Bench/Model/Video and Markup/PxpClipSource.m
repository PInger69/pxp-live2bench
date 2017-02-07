//
//  PxpClipSource.m
//  Live2Bench
//
//  Created by BC Holmes on 2017-02-07.
//  Copyright © 2017 Avoca. All rights reserved.
//

#import "PxpClipSource.h"

@implementation PxpClipSource

-(instancetype) initWithPath:(NSString *)path name:(NSString *)name {
    if (self = [super init]) {
        self.url = [NSURL fileURLWithPath:path];
        self.proposedVideoName = name;
    }
    return self;
}

@end
