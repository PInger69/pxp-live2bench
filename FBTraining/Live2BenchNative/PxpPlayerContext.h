//
//  PxpPlayerContext.h
//  PxpPlayer
//
//  Created by Nico Cvitak on 2015-07-03.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PxpTimeProvider.h"
#import "UserCenter.h"
#import <AVFoundation/AVFoundation.h>

@class PxpPlayer;

/**
 * @breif An object used to manage multiple players playing similar content, such as multiple camera angles.
 * @author Nicholas Cvitak
 */
@interface PxpPlayerContext : NSObject<PxpTimeProvider>

/// The number of players managed by the context
@property (assign, nonatomic) NSUInteger playerCount;

/// The players associated with the context. (read-only)
@property (readonly, strong, nonatomic, nonnull) NSArray *players;

/// The player that should be used to control the context. (read-only)
@property (readonly, strong, nonatomic, nullable) PxpPlayer *mainPlayer;

#pragma mark - Initialization

/// Creates a new context.
+ (nonnull instancetype)context;

/// Creates a new context binding the given player.
+ (nonnull instancetype)contextWithPlayer:(nullable PxpPlayer *)player;

/// Creates a new context binding the given players.
+ (nonnull instancetype)contextWithPlayers:(nullable NSArray *)players;

/// Initializes a context binding the given player.
- (nonnull instancetype)initWithPlayer:(nullable PxpPlayer *)player;

/// Initializes a context binding the given players.
- (nonnull instancetype)initWithPlayers:(nullable NSArray *)players;

#pragma mark - Player Management

/// Tests if the context contains the specified player.
- (BOOL)containsPlayer:(nonnull PxpPlayer *)player;

/// Adds a player to the context.
- (void)addPlayer:(nonnull PxpPlayer *)player;

/// Adds multiple players to the context.
- (void)addPlayers:(nonnull NSArray *)players;

/// Removes a player from the context.
- (void)removePlayer:(nonnull PxpPlayer *)player;

/// Removes multiple players from the context.
- (void)removePlayers:(nonnull NSArray *)players;

/// Removes all players from the context.
- (void)removeAllPlayers;

/// Sorts all of the players in the context by name.
- (void)sortPlayers;

/// Mutes all players in the context expect for the specified player.
- (void)muteAllButPlayer:(nullable PxpPlayer *)player;

/// Reloads all players in the context.
- (void)reload;

/// Returns the first player in the context named 'name'.
- (nullable PxpPlayer *)playerForName:(nonnull NSString *)name;

//. Returns a time that live time minus the buffer Time
-(CMTime)bufferedLiveTime;
@end
