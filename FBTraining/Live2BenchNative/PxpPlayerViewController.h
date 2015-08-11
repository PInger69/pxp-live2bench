//
//  PxpPlayerViewController.h
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-07.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PxpPlayerView.h"
#import "PxpTelestrationViewController.h"
#import "PxpFullscreenGestureRecognizer.h"

@interface PxpPlayerViewController : UIViewController

/// The underlying player view.
@property (readonly, strong, nonatomic, nonnull) PxpPlayerView *playerView;

/// The telestration view controller.
@property (readonly, strong, nonatomic, nonnull) PxpTelestrationViewController *telestrationViewController;

/// The fullscreen gesture recognizer.
@property (readonly, strong, nonatomic, nonnull) PxpFullscreenGestureRecognizer *fullscreenGestureRecognizer;

/// Initializes a player view controller with a specific player view subclass.
- (nonnull instancetype)initWithPlayerViewClass:(nullable Class)playerViewClass;

@end
