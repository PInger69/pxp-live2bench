//
//  PxpPlayPauseButton.h
//  PxpPlayer
//
//  Created by Nico Cvitak on 2015-06-10.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import "PxpGlowButton.h"

@class PxpPlayPauseButton;

/// @author Nicholas Cvitak
@protocol PxpPlayPauseButtonDelegate

/// Invoked when the state of a play/pause button changes.
- (void)button:(nonnull PxpPlayPauseButton *)button didChangeToPaused:(BOOL)paused;

@end

/**
 * @breif A button that toggles between play and pause states.
 * @author Nicholas Cvitak
 */
IB_DESIGNABLE @interface PxpPlayPauseButton : PxpGlowButton

/// The delegate of the play/pause button.
@property (weak, nonatomic, nullable) id<PxpPlayPauseButtonDelegate> delegate;

/// The state of the play/pause buttom
@property (assign, nonatomic) IBInspectable BOOL paused;

@end
