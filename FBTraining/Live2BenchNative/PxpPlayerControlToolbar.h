//
//  PxpPlayerControlToolbar.h
//  PxpPlayer
//
//  Created by Nico Cvitak on 2015-06-09.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * @breif A toolbar that looks good with a player.
 * @author Nicholas Cvitak
 */
IB_DESIGNABLE @interface PxpPlayerControlToolbar : UIToolbar

/// The toolbar's left bar button item.
@property (strong, nonatomic, nonnull) UIBarButtonItem *leftBarButtonItem;

/// The toolbar's right bar button item.
@property (strong, nonatomic, nonnull) UIBarButtonItem *rightBarButtonItem;

@end
