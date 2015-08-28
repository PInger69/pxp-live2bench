//
//  PxpPlayer.h
//  PxpPlayer
//
//  Created by Nico Cvitak on 2015-06-16.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "PxpPlayerContext.h"
#import "PxpLoadAction.h"
#import "PxpTimeProvider.h"

/**
 * @breif A video player optimized for live video, synchronization, and looping.
 * @author Nicholas Cvitak
 */
@interface PxpPlayer : AVPlayer<PxpTimeProvider>

/// The player's context.
@property (weak, nonatomic, nullable) PxpPlayerContext *context;

/// The name of the player.
@property (copy, nonatomic, nonnull) NSString *name;

/// The live playback status of the player. (read-only)
@property (readonly, assign, nonatomic) BOOL live;

/// The playing status of the player. (read-only)
@property (readonly, assign, nonatomic) BOOL playing;

/// The standard playback rate of the player.
@property (assign, nonatomic) float playRate;

/// The sync time interval between sync attempts.
@property (assign, nonatomic) CMTime syncInterval;

/// The minimum time difference to cause a sync.
@property (assign, nonatomic) CMTime syncThreshold;

/// The loop range of the player.
@property (assign, nonatomic) CMTimeRange range;

/// The duration of the player's item. (read-only)
@property (readonly, assign, nonatomic) CMTime duration;

/// The time remaining till the end of the stream.
@property (readonly, assign, nonatomic) CMTime remainingTime;

/// The failed status of the player. (read-only)
@property (readonly, assign, nonatomic) BOOL failed;

/// The motion status of the player's feed. (read-only)
@property (readonly, assign, nonatomic) BOOL motion;

/// Seeks forward or backward releative to the current time.
- (void)seekBy:(CMTime)time;

/// Seeks forward or backward releative to the current time with a completion handler.
- (void)seekBy:(CMTime)time completionHandler:(nullable void (^)(BOOL finished))completionHandler;

/// Cancels any pending seeks.
- (void)cancelPendingSeeks;

/// Adds an action to be executed when the player loads.
- (void)addLoadAction:(nonnull PxpLoadAction *)loadAction;

/// Syncs all players in the context to the time of the current player
- (void)sync;

/// Reloads the player's currentItem.
- (void)reload;

/// Brings the player to Live.
- (void)goToLive;

@end
