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

@property (weak, nonatomic, nullable) id<PxpTelestrationViewControllerDelegate> delegate;
@property (weak, nonatomic, nullable) id<PxpTimeProvider> timeProvider;

@property (strong, nonatomic, nullable) PxpTelestration *telestration;

@property (assign, nonatomic) BOOL showsControls;

@property (assign, nonatomic) BOOL showsClearButton;

@property (readonly, assign, nonatomic) BOOL telestrating;

@end
