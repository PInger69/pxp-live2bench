//
//  PxpClipSource.m
//  Live2Bench
//
//  Created by BC Holmes on 2017-02-07.
//  Copyright © 2017 Avoca. All rights reserved.
//

#import "PxpClipSource.h"

@implementation PxpClipSource

-(instancetype) initWithPath:(NSString *)path name:(NSString *)name sourceId:(NSString*) source {
    if (self = [super init]) {
        self.path = path;
        self.source = source;
        self.proposedVideoName = name;
    }
    return self;
}

-(BOOL) videoFileExists {
    return [[NSFileManager defaultManager] fileExistsAtPath:self.path];
}

-(NSURL*) url {
    return [NSURL fileURLWithPath:self.path];
}

@end
