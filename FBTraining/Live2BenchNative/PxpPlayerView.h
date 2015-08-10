//
//  PxpPlayerView.h
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-07.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PxpPlayer.h"

// Change this to what ever player view your heart desires
#define PXP_PLAYER_VIEW_DEFAULT NSClassFromString(@"PxpPlayerMultiView")

// Post to set player with userInfo = @{ @"identifier": playerViewIdentifer, @"player": playerToSet }
#define NOTIF_PXP_PLAYER_VIEW_SET_PLAYER @"PxpPlayerSetPlayer"

/**
 * @breif Abstract PxpPlayerView class
 * @author Nicholas Cvitak
 */
IB_DESIGNABLE
@interface PxpPlayerView : UIView

/// The identifier of the player view.
@property (copy, nonatomic, nonnull) IBInspectable NSString *identifier;

/// The player who's contents should be displayed by the view.
@property (strong, nonatomic, nullable) PxpPlayer *player;

/// The player's context.
@property (strong, nonatomic, nullable) PxpPlayerContext *context;

/// True if the playerView is only viewing a single PxpPlayer.
@property (readonly, assign, nonatomic) BOOL fullView;

@end
