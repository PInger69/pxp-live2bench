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

@property (strong, nonatomic, nonnull) NSArray *players;

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
        _players = @[];
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
    // sort the players by name
    self.players = [[NSMutableArray arrayWithArray:self.boundPlayers.allObjects]
                sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
    
}

- (void)muteAllButPlayer:(nullable PxpPlayer *)player {
    for (PxpPlayer *p in self.players) {
        if (p != player) {
            p.muted = YES;
        }
    }
}

- (void)reload {
    for (PxpPlayer *player in self.players) {
        [player reload];
    }
}

- (nullable PxpPlayer *)playerForName:(nonnull NSString *)name {
    for (PxpPlayer *player in self.players) {
        if ([player.name isEqualToString:name]) {
            return player;
        }
    }
    return self.players.firstObject;
}

#pragma mark - PxpTimeProvider

- (NSTimeInterval)currentTimeInSeconds {
    return CMTimeGetSeconds(self.mainPlayer.currentTime);
}

-(CMTime)bufferedLiveTime
{

    CMTime tt = kCMTimePositiveInfinity;
    
    for (PxpPlayer * aPlayer in _players) {
       
        AVPlayerItem * it = aPlayer.currentItem;

       
        
        CMTime duration = it.duration;
        
        if (it.seekableTimeRanges.count > 0) {
            CMTimeRange seekableRange = [it.seekableTimeRanges.firstObject CMTimeRangeValue];
            duration = CMTimeAdd(seekableRange.start, seekableRange.duration);
        }
        
        
        
        if (CMTimeCompare(duration, tt) < 0)
        {
            tt = duration;
            NSLog(@"set = %f", CMTimeGetSeconds(tt));
        }
    }

    tt = CMTimeSubtract(tt, CMTimeMake([UserCenter getInstance].preferenceLiveBuffer, 1));

    
    return tt;
}



-(void)dealloc
{

}

@end
