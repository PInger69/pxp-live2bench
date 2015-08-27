//
//  PxpFullscreenGestureRecognizer.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-11.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpFullscreenGestureRecognizer.h"

#define FULLSCREEN_GESTURE_VELOCITY 100.0

@implementation PxpFullscreenGestureRecognizer

- (PxpFullscreenResponse)fullscreenResponse {
    const CGFloat velocty = self.velocity;
    const CGFloat scale = self.scale;
    
    if (scale > 1 && velocty >= FULLSCREEN_GESTURE_VELOCITY) {
        return PxpFullscreenResponseEnter;
    } else if (scale < 1 && velocty <= -FULLSCREEN_GESTURE_VELOCITY) {
        return PxpFullscreenResponseLeave;
    } else {
        return PxpFullscreenResponseNone;
    }
}

@end
