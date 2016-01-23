//
//  RicoFullScreenViewController.h
//  Live2BenchNative
//
//  Created by dev on 2016-01-22.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SeekButton.h"
#import "PxpBorderButton.h"
#import "Slomo.h"
#import "PxpFullscreenButton.h"
#import "PxpFullscreenResponder.h"
#import "RicoPlayerViewController.h"
#import "RicoPlayerControlBar.h"

@class RicoFullScreenViewController;
@protocol RicoFullScreenDelegate <NSObject>

-(void)onFullScreenShow:(RicoFullScreenViewController*)fullscreenController;
-(void)onFullScreenLeave:(RicoFullScreenViewController*)fullscreenController;


@end



@interface RicoFullScreenViewController : UIViewController

@property (nonatomic,strong) id <RicoFullScreenDelegate> delegate;

/// The underlying player view controller.
@property (readonly, strong, nonatomic, nonnull) RicoPlayerViewController *playerViewController;

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


@property (strong,nonatomic, nonnull) RicoPlayerControlBar  * controlBar;


/// The view controller's view hidden state.
@property (assign, nonatomic) BOOL fullscreen;

/// Initializes the fullscreen view contoller to use.
- (nonnull instancetype)initWithPlayerViewController:(nonnull RicoPlayerViewController *)playerViewController;

/// Sets The view controller's view to the requested hidden state.
- (void)setFullscreen:(BOOL)fullscreen animated:(BOOL)animated;

/// Handler for PxpFullscreenButton and PxpFullscreenGestureRecognizer events.
- (void)fullscreenResponseHandler:(nullable id<PxpFullscreenResponder>)sender;

@end
