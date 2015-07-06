//
//  PxpPlayerPipView.h
//  PxpPlayer
//
//  Created by Nico Cvitak on 2015-06-26.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import "PxpPlayerSwapView.h"

/**
 * @breif A player view capable of being moved around within it's superview. (Note: zooming is disabled)
 * @author Nicholas Cvitak
 */
@interface PxpPlayerPipView : PxpPlayerSwapView

/// Specifies whether or not movement is enabled for the pip view.
@property (assign, nonatomic) BOOL movementEnabled;

@end
