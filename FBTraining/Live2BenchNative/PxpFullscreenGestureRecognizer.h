//
//  PxpFullscreenGestureRecognizer.h
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-11.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "NCTriPinchGestureRecognizer.h"

typedef NS_ENUM(NSUInteger, PxpFullscreenGestureResult) {
    PxpFullscreenGestureResultUnknown,
    PxpFullscreenGestureResultShow,
    PxpFullscreenGestureResultHide,
};

@interface PxpFullscreenGestureRecognizer : NCTriPinchGestureRecognizer

@property (readonly, assign, nonatomic) PxpFullscreenGestureResult result;

@end
