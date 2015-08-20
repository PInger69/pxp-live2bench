//
//  PxpClipContext.m
//  PxpPlayer
//
//  Created by Nico Cvitak on 2015-07-02.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import "PxpClipContext.h"

#import "PxpPlayer+Feed.h"
#import "Clip.h"
#import "Feed.h"

@implementation PxpClipContext

+ (nonnull instancetype)contextWithClip:(nullable Clip *)clip {
    return [[self alloc] initWithClip:clip];
}

- (nonnull instancetype)initWithClip:(nullable Clip *)clip {
    self = [super init];
    if (self) {
        self.clip = clip;
    }
    return self;
}

- (nonnull instancetype)init {
    return [self initWithClip:nil];
}

- (void)setClip:(nullable Clip *)clip {
    _clip = clip;
    
    NSDictionary *videos = clip.videosBySrcKey;
    NSArray *sources = videos.allKeys;
    
    [self setPlayerCount:sources.count];
    
    // load clips
    for (NSUInteger i = 0; i < self.players.count; i++) {
        PxpPlayer *player = self.players[i];
        NSString *source = sources[i];
        
        player.feed = [[Feed alloc] initWithFileURL:videos[source]];
        player.name = source;
    }
    
    // default sync parameters
    self.mainPlayer.syncThreshold = CMTimeMake(1, 3);
    self.mainPlayer.syncInterval = CMTimeMake(5, 1);
    
    [self.mainPlayer addLoadAction:[PxpLoadAction loadActionWithTarget:self action:@selector(clipLoadComplete:)]];
}

- (void)clipLoadComplete:(PxpLoadAction *)loadAction {
    if (loadAction.success) {
        [self.mainPlayer seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            [self.mainPlayer prerollAtRate:self.mainPlayer.playRate completionHandler:^(BOOL finished) {
                [self.mainPlayer setRate:self.mainPlayer.playRate];
            }];
        }];
    }
}

@end
