//
//  PxpPlayerLight.h
//  PxpPlayer
//
//  Created by Nico Cvitak on 2015-06-09.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * @breif A light that looks good on a player.
 * @author Nicholas Cvitak
 */
IB_DESIGNABLE @interface PxpPlayerLight : UIView

/// The color of the light.
@property (strong, nonatomic, nonnull) IBInspectable UIColor *color;

@end
