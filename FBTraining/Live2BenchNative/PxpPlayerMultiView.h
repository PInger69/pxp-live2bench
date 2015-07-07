//
//  PxpPlayerMultiView.h
//  PxpPlayer
//
//  Created by Nico Cvitak on 2015-06-29.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxpPlayer.h"

/**
 * @breif The standard view for viewing multiple sources in the player's context using a grid view and a companion view.
 * @author Nicholas Cvitak
 */
@interface PxpPlayerMultiView : UIView

/// The context that the multi view should load its data from.
@property (strong, nonatomic, nonnull) PxpPlayerContext *context;

@end
