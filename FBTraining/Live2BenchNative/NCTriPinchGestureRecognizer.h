//
//  NCTriPinchGestureRecognizer.h
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-05.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * @breif A Gesture Recognizer that can detect a three finger pinch.
 * @author Nicholas Cvitak
 */
@interface NCTriPinchGestureRecognizer : UIGestureRecognizer

/// The scale factor of the pinch relative to the initial size. (read-only)
@property (readonly, assign, nonatomic) CGFloat scale;

/// The velocity of the pinch. (read-only)
@property (readonly, assign, nonatomic) CGFloat velocity;

@end
