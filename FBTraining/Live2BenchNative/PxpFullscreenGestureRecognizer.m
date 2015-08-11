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
    return velocty > FULLSCREEN_GESTURE_VELOCITY ? PxpFullscreenResponseShow : velocty < -FULLSCREEN_GESTURE_VELOCITY ? PxpFullscreenResponseHide : PxpFullscreenResponseUnknown;
}

@end
