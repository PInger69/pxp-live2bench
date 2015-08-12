//
//  PxpPlayerControlBar.h
//  PxpPlayer
//
//  Created by Nico Cvitak on 2015-06-16.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PxpPlayer;
@class PxpPlayerContext;
@class PxpPlayerControlBar;

@protocol PxpPlayerControlBarDelegate

- (void)didCancelTimeRangeInControlBar:(nonnull PxpPlayerControlBar *)controlBar;

@end

/**
 * @breif A view that displays user interface elements to control a player.
 * @author Nicholas Cvitak
 */
IB_DESIGNABLE @interface PxpPlayerControlBar : UIView

/// The control bar's delegate.
@property (weak, nonatomic, nullable) id<PxpPlayerControlBarDelegate> delegate;

/// The player to be controlled.
@property (weak, nonatomic, nullable) PxpPlayer *player;

@end
