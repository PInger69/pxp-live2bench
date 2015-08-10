//
//  PxpPlayer+Tag.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-10.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpPlayer+Tag.h"

@implementation PxpPlayer (Tag)

- (void)setTag:(nullable Tag *)tag {
    self.range = tag ? CMTimeRangeMake(CMTimeMakeWithSeconds(tag.startTime, 60), CMTimeMakeWithSeconds(tag.duration, 60)) : kCMTimeRangeInvalid;
}

@end
