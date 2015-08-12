//
//  PxpPlayer+Feed.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-10.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpPlayer+Feed.h"

@implementation PxpPlayer (Feed)

- (void)setFeed:(nullable Feed *)feed {
    NSURL *url = feed.path;
    CMTime time = self.currentTime;
    float rate = self.rate;
    
    [super replaceCurrentItemWithPlayerItem:url ? [AVPlayerItem playerItemWithAsset:[AVURLAsset assetWithURL:url] automaticallyLoadedAssetKeys:@[@"playable", @"tracks", @"duration"]] : nil];
    
    if (url) {
        __block PxpPlayer *player = self;
        [self addLoadAction:[PxpLoadAction loadActionWithBlock:^(BOOL ready) {
            NSLog(@"READY: %d", ready);
            if (ready) {
                [player seekToTime:time completionHandler:^(BOOL complete) {
                    [player prerollAtRate:ready completionHandler:^(BOOL complete) {
                        [player setRate:rate];
                    }];
                }];
            }
        }]];
    }
    
}

@end
