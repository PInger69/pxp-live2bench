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

@interface PxpTelestrationRenderer : NSObject

@property (weak, nonatomic, nullable) id<PxpTimeProvider> timeProvider;

@property (strong, nonatomic, nonnull) PxpTelestration *telestration;

- (nonnull instancetype)initWithTelestration:(nonnull PxpTelestration *)telestration;

- (void)renderInContext:(nullable CGContextRef)context size:(CGSize)size;
- (void)renderInContext:(nullable CGContextRef)context size:(CGSize)size atTime:(NSTimeInterval)time;

@end
