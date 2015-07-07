//
//  PxpPlayerContext.m
//  PxpPlayer
//
//  Created by Nico Cvitak on 2015-07-03.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import "PxpPlayerContext.h"

#import "PxpPlayer.h"

@interface PxpPlayerContext ()

/// The set of players bound to the context.
@property (strong, nonatomic, nonnull) NSMutableSet *boundPlayers;

@end

@implementation PxpPlayerContext

#pragma mark - Initialization

+ (nonnull instancetype)context {
    return [[self alloc] init];
}

+ (nonnull instancetype)contextWithPlayer:(nullable PxpPlayer *)player {
    return [[self alloc] initWithPlayer:player];
}

+ (nonnull instancetype)contextWithPlayers:(nullable NSArray *)players {
    return [[self alloc] initWithPlayers:players];
}

- (nonnull instancetype)init {
    return [self initWithPlayers:nil];
}

- (nonnull instancetype)initWithPlayer:(nullable PxpPlayer *)player {
    return [self initWithPlayers:player ? @[player] : nil];
}

- (nonnull instancetype)initWithPlayers:(nullable NSArray *)players {
    self = [super init];
    if (self) {
        _boundPlayers = [NSMutableSet set];
        
        if (players) {
            [self addPlayers:players];
        }
    }
    return self;
}

#pragma mark - Getters / Setters

- (void)setPlayerCount:(NSUInteger)playerCount {
    
    // remove unnecessary players
    while (self.players.count > playerCount) {
        [self removePlayer:self.players.lastObject];
    }
    
    // add necessary players
    while (self.players.count < playerCount) {
        [self addPlayer:[[PxpPlayer alloc] init]];
    }
}

- (NSUInteger)playerCount {
    return self.players.count;
}

- (nullable PxpPlayer *)mainPlayer {
    return self.players.firstObject;
}

#pragma mark - Player Management

- (void)addPlayer:(nonnull PxpPlayer *)player {
    [self addPlayers:@[player]];
}

- (void)addPlayers:(nonnull NSArray *)players {
    [self willChangeValueForKey:@"playerCount"];
    if (players.count) {
        
        // add the players to the new context
        [self.boundPlayers addObjectsFromArray:players];
        
        // move the players to this context
        for (PxpPlayer *player in players) {
            player.context = self;
        }
        
        [self sortPlayers];
    }
    [self didChangeValueForKey:@"playerCount"];
}

- (void)removePlayer:(nonnull PxpPlayer *)player {
    [self removePlayers:@[player]];
}

- (void)removePlayers:(nonnull NSArray *)players {
    [self willChangeValueForKey:@"playerCount"];
    if (players.count) {
        
        // move the players to this context
        for (PxpPlayer *player in players) {
            [self.boundPlayers removeObject:player];
            player.context = nil;
        }
        
        [self sortPlayers];
    }
    [self didChangeValueForKey:@"playerCount"];
}

- (void)removeAllPlayers {
    [self removePlayers:self.players];
}

- (BOOL)containsPlayer:(nonnull PxpPlayer *)player {
    return [self.boundPlayers containsObject:player];
}

- (void)sortPlayers {
    [self willChangeValueForKey:@"players"];
    
    // sort the players by name
    _players = [[NSMutableArray arrayWithArray:self.boundPlayers.allObjects]
                sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
    
    [self didChangeValueForKey:@"players"];
}

@end
