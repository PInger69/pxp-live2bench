//
//  PxpEventContext.m
//  PxpPlayer
//
//  Created by Nico Cvitak on 2015-06-29.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import "PxpEventContext.h"
#import "PxpPlayer+Feed.h"

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
        PXPLog(@"Event Context Created!");
    }
    return self;
}

- (nonnull instancetype)init {
    return [self initWithEvent:nil];
}

- (void)setEvent:(nullable Event *)event {
    _event = event;
    
    NSMutableDictionary *feeds = [NSMutableDictionary dictionary];
    if (event) {
        
        if (event.live || event.local || !event.mp4s) { // use the provided feed (HLS for live, mp4 for local)
            for (NSString *name in event.feeds.keyEnumerator) {
                feeds[name] = event.feeds[name];
            }
        } else if (!event.live && !event.local) {
        
            feeds = [event.feeds mutableCopy];
            
        } else { // use mp4 from encoder
            for (NSString *name in event.mp4s.keyEnumerator) {
                
                id mp4 = event.mp4s[name];
                
                if ([mp4 isKindOfClass:[NSString class]]) {
                    feeds[name] = [[Feed alloc] initWithURLString:mp4 quality:0];
                } else if ([mp4 isKindOfClass:[NSDictionary class]]) {
                    feeds[name] = [[Feed alloc] initWithURLString:mp4[@"hq"] quality:0];
                }
            }
        }
        
    }
    
    [self setPlayerCount:feeds.allKeys.count];
    
    // update the player data
    for (NSUInteger i = 0; i < self.players.count; i++) {
        __block PxpPlayer   * player    = self.players[i];
        NSString    * name      = feeds.allKeys[i];
        Feed        * afeed     = feeds[name];
        player.name = name;
        player.feed = afeed;
        if ([afeed.type isEqualToString:FEED_TYPE_ENCODER]){ // finished m3u8 files always start at the end of the file not the start so seek to the start and play
            
           PxpLoadAction* action =  [PxpLoadAction loadActionWithBlock:^(BOOL value) {
               [player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
                   [player play];
               }];

           }];
            
            [player addLoadAction:action];
        }
        
        
    }
    
    [self sortPlayers];
    
    if (event) {
        // default sync parameters
        self.mainPlayer.syncThreshold = CMTimeMake(5, NSEC_PER_SEC);// was 1 before not 5
        self.mainPlayer.syncInterval = CMTimeMake(30, NSEC_PER_SEC); // was 5 before not 30
        
        [self.mainPlayer addLoadAction:[PxpLoadAction loadActionWithTarget:self action:@selector(loadComplete:)]];
    }
    
}

- (void)loadComplete:(PxpLoadAction *)loadAction {
    if (self.event.live) {
        [self.mainPlayer goToLive];
    } else {
        [self.mainPlayer seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            [self.mainPlayer prerollAtRate:self.mainPlayer.playRate completionHandler:^(BOOL finished) {
                [self.mainPlayer setRate:self.mainPlayer.playRate];
            }];
        }];
    }
}

@end
