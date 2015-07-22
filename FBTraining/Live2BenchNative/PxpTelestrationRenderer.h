//
//  PxpTelestrationRenderer.h
//  PxpTelestration
//
//  Created by Nico Cvitak on 2015-07-08.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxpTimeProvider.h"
#import "PxpTelestration.h"

/*!
 * @breif An object used to render a telestration to Core Graphics context.
 * @author Nicholas Cvitak
 */
@interface PxpTelestrationRenderer : NSObject

/// The renderer's time provider.
@property (weak, nonatomic, nullable) id<PxpTimeProvider> timeProvider;

/// The renderer's telestration to render.
@property (strong, nonatomic, nonnull) PxpTelestration *telestration;

/// Initializes a renderer with a telestration.
- (nonnull instancetype)initWithTelestration:(nonnull PxpTelestration *)telestration;

/// Renderes the telestration at INFINITY time in the given context.
- (void)renderInContext:(nullable CGContextRef)context size:(CGSize)size;

/// Renderes the telestration at the given time, and in the given context.
- (void)renderInContext:(nullable CGContextRef)context size:(CGSize)size atTime:(NSTimeInterval)time;

@end
