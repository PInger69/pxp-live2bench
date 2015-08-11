//
//  PxpFullscreenViewController.h
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-04.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxpPlayerViewController.h"
#import "SeekButton.h"
#import "Slomo.h"
#import "PxpFullscreenButton.h"

@interface PxpFullscreenViewController : UIViewController

/// The underlying player view controller.
@property (readonly, strong, nonatomic, nonnull) PxpPlayerViewController *playerViewController;

/// The view above the player suitable for user interface elements.
@property (readonly, strong, nonatomic, nonnull) UIView *topBar;

/// The view below the player suitable for user interface elements.
@property (readonly, strong, nonatomic, nonnull) UIView *bottomBar;

/// The view where subview's should be added
@property (readonly, strong, nonatomic, nonnull) UIView *contentView;

/// The backward seek button.
@property (readonly, strong, nonatomic, nonnull) SeekButton *backwardSeekButton;

/// The forward seek button.
@property (readonly, strong, nonatomic, nonnull) SeekButton *forwardSeekButton;

/// The slomo button.
@property (readonly, strong, nonatomic, nonnull) Slomo *slomoButton;

/// The fullscreen button.
@property (readonly, strong, nonatomic, nonnull) PxpFullscreenButton *fullscreenButton;

/// The view controller's view hidden state.
@property (assign, nonatomic) BOOL hidden;

/// The target frame where the view controller should animated its views to and from.
@property (assign, nonatomic) CGRect targetFrame;

/// Initializes the fullscreen view contoller to use specific player view class.
- (nonnull instancetype)initWithPlayerViewClass:(nullable Class)playerViewClass;

/// Sets The view controller's view to the requested hidden state.
- (void)setHidden:(BOOL)hidden animated:(BOOL)animated;

/// Handler for PxpFullscreenButton and PxpFullscreenGestureRecognizer events.
- (void)fullscreenActionHandler:(nullable id)sender;

@end
