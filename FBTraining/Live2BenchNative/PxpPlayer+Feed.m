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


    AVPlayerItem * playerItem = [AVPlayerItem playerItemWithURL:feed.path];
//    playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = NO;
    [self replaceCurrentItemWithPlayerItem:feed.path ? playerItem : nil];
//    [self seekToTime:CMTimeMake(0, 1)];
}

@end
