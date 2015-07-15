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

@property (weak, nonatomic, nullable) id<PxpTimeProvider> timeProvider;
@property (weak, nonatomic, nullable) id<PxpTelestrationCaptureAreaDelegate> delegate;

@property (assign, nonatomic) BOOL captureEnabled;

- (void)bindTelestration:(nullable PxpTelestration *)telestration;

- (void)pushAction;
- (void)popAction;

@end
