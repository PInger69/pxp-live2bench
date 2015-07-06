//
//  PxpGlowButton.h
//  PxpPlayer
//
//  Created by Nico Cvitak on 2015-06-09.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * @breif A button drawn using a Core Graphics path with a glow effect.
 * @author Nicholas Cvitak
 */
IB_DESIGNABLE @interface PxpGlowButton : UIButton

@property (readonly, strong, nonatomic, nonnull) CAShapeLayer *layer;

/// The glow radius of the button
@property (assign, nonatomic) IBInspectable CGFloat glowRadius;

@end
