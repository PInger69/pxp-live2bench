//
//  PxpPlayerSwapView.h
//  PxpPlayer
//
//  Created by Nico Cvitak on 2015-06-26.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PxpPlayerSingleView.h"

/**
 * @breif A player view capable of swaping its player with players in the same context
 * @author Nicholas Cvitak
 */
@interface PxpPlayerSwapView : PxpPlayerSingleView

/// Specifies whether or not the view swaps to the next player with a tap.
@property (assign, nonatomic) BOOL tapToAdvanceEnabled;

/// Swaps the current player with the next player in the same context.
- (void)nextPlayer;

/// Swaps the current player with the previous player in the same context.
- (void)previousPlayer;

@end
