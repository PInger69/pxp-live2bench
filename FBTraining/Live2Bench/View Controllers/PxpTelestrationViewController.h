//
//  PxpTelestrationViewController.h
//  PxpTelestration
//
//  Created by Nico Cvitak on 2015-07-09.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxpTelestrationRenderer.h"

@class PxpTelestrationViewController;

@protocol PxpTelestrationViewControllerDelegate

- (void)telestration:(nonnull PxpTelestration *)telestration didStartInViewController:(nonnull PxpTelestrationViewController *)viewController;
- (void)telestration:(nonnull PxpTelestration *)telestration didFinishInViewController:(nonnull PxpTelestrationViewController *)viewController;

@end

@interface PxpTelestrationViewController : UIViewController

/// The telestration view controller's delegate.
@property (weak, nonatomic, nullable) id<PxpTelestrationViewControllerDelegate> delegate;

/// The telestration view controller's time provider.
@property (weak, nonatomic, nullable) id<PxpTimeProvider> timeProvider;

/// The telestration managed by the view controller
@property (strong, nonatomic, nullable) PxpTelestration *telestration;

/// Specifies whether or not telestration controls should be visible.
@property (assign, nonatomic) BOOL showsControls;

/// True if the view controller is currently in a telestration session.
@property (readonly, assign, nonatomic) BOOL telestrating;

/// Specifies whether or not the telestration controller should generate stills over animations.
@property (assign, nonatomic) BOOL stillMode;

@end
