//
//  PxpPlayerControlSlider.h
//  PxpPlayer
//
//  Created by Nico Cvitak on 2015-06-09.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBSlider.h"

/**
 * @breif A slider used to control a player.
 * @author Nicholas Cvitak
 */
IB_DESIGNABLE @interface PxpPlayerControlSlider : OBSlider

/// The glow radius of the slider
@property (assign, nonatomic) IBInspectable CGFloat glowRadius;

@end
