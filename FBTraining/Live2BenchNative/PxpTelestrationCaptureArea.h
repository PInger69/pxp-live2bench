//
//  PxpTelestrationCaptureArea.h
//  PxpTelestration
//
//  Created by Nico Cvitak on 2015-07-08.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxpTimeProvider.h"
#import "PxpTelestration.h"

@class PxpTelestrationCaptureArea;

@protocol PxpTelestrationCaptureAreaDelegate

- (nonnull UIColor *)strokeColorInCaptureArea:(nonnull PxpTelestrationCaptureArea *)captureArea;
- (CGFloat)strokeWidthInCaptureArea:(nonnull PxpTelestrationCaptureArea *)captureArea;
- (PxpTelestrationActionType)actionTypeInCaptureArea:(nonnull PxpTelestrationCaptureArea *)captureArea;

@end

@interface PxpTelestrationCaptureArea : UIView

/// The capture area's time provider.
@property (weak, nonatomic, nullable) id<PxpTimeProvider> timeProvider;

/// The capture area's delegate.
@property (weak, nonatomic, nullable) id<PxpTelestrationCaptureAreaDelegate> delegate;

/// Sets whether or not the capture area is enabled.
@property (assign, nonatomic) BOOL captureEnabled;

/// Binds a telestration for capturing data.
- (void)bindTelestration:(nullable PxpTelestration *)telestration;

@end
