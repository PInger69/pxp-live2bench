//
//  PxpEventContext.m
//  PxpPlayer
//
//  Created by Nico Cvitak on 2015-06-29.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import "PxpEventContext.h"

#import "Event.h"
#import "Feed.h"

@implementation PxpEventContext

+ (nonnull instancetype)contextWithEvent:(nullable Event *)event {
    return [[self alloc] initWithEvent:event];
}

- (nonnull instancetype)initWithEvent:(nullable Event *)event {
    self = [super init];
    if (self) {
        self.event = event;
    }
    return self;
}

- (nonnull instancetype)init {
    return [self initWithEvent:nil];
}

- (void)setEvent:(nullable Event *)event {
    _event = event;
    
    NSMutableArray *names = [NSMutableArray array];
    NSMutableArray *items = [NSMutableArray array];
    
    if (event) {
        
        if (event.live || event.local || !event.mp4s) { // use the provided feed (HLS for live, mp4 for local)
            for (NSString *name in event.feeds) {
                
                Feed *feed = event.feeds[name];
                
                // get the data
                [names addObject:name];
                [items addObject:[AVPlayerItem playerItemWithURL:feed.path]];
            }
        } else { // use mp4 from encoder
            for (NSString *name in event.mp4s) {
                
                NSString *path = event.mp4s[name];
                
                // get the data
                [names addObject:name];
                [items addObject:[AVPlayerItem playerItemWithURL:[NSURL URLWithString:path]]];
            }
        }
        
    }
    
    [self setPlayerCount:items.count];
    
    // update the player data
    for (NSUInteger i = 0; i < self.players.count; i++) {
        PxpPlayer *player = self.players[i];
        
        player.name = names[i];
        [player replaceCurrentItemWithPlayerItem:items[i]];
    }
    
    [self sortPlayers];
    
    // default sync parameters
    self.mainPlayer.syncThreshold = CMTimeMake(1, 3);
    self.mainPlayer.syncInterval = CMTimeMake(5, 1);
}

@end
