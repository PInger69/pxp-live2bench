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

- (PxpFullscreenGestureResult)result {
    const CGFloat velocty = self.velocity;
    return velocty > FULLSCREEN_GESTURE_VELOCITY ? PxpFullscreenGestureResultShow : velocty < -FULLSCREEN_GESTURE_VELOCITY ? PxpFullscreenGestureResultHide : PxpFullscreenGestureResultUnknown;
}

@end
