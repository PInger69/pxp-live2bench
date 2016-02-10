//
//  RicoBaseFullScreenViewController.h
//  Live2BenchNative
//
//  Created by dev on 2016-02-08.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxpFullscreenButton.h"
#import "PxpFullscreenResponder.h"

// The point of this class is just to handle a full screen View

@class RicoBaseFullScreenViewController;
@protocol RicoBaseFullScreenDelegate <NSObject>

-(void)onFullScreenShow:(RicoBaseFullScreenViewController*)fullscreenController;
-(void)onFullScreenLeave:(RicoBaseFullScreenViewController*)fullscreenController;


@end

@interface RicoBaseFullScreenViewController : UIViewController

@property (nonatomic,strong) id <RicoBaseFullScreenDelegate> delegate;
@property (nonatomic,assign) BOOL animated;


/// The view above the player suitable for user interface elements.
@property (readonly, strong, nonatomic, nonnull) UIView *topBar;

/// The view below the player suitable for user interface elements.
@property (readonly, strong, nonatomic, nonnull) UIView *bottomBar;

/// The view where subview's should be added
@property (readonly, strong, nonatomic, nonnull) UIView *contentView;

/// The view controller's view hidden state.
@property (assign, nonatomic) BOOL fullscreen;

-(instancetype)initWithView:(UIView*)view;


/// Sets The view controller's view to the requested hidden state.
- (void)setFullscreen:(BOOL)fullscreen animated:(BOOL)animated;

/// Handler for PxpFullscreenButton and PxpFullscreenGestureRecognizer events.
- (void)fullscreenResponseHandler:(nullable id<PxpFullscreenResponder>)sender;

@end
