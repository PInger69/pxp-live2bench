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
    
    if (tag) {
        if (tag.telestration.isStill) {
            self.range = kCMTimeRangeInvalid;
            [self pause];
            [self seekToTime:CMTimeMakeWithSeconds(tag.telestration.startTime, 60) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        } else {
            [self play];
            self.range = CMTimeRangeMake(CMTimeMakeWithSeconds(tag.startTime, 60), CMTimeMakeWithSeconds(tag.duration, 60));
        }
    } else {
        self.range = kCMTimeRangeInvalid;
    }
}

@end
