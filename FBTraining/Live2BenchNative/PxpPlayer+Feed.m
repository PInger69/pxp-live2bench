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
    [self replaceCurrentItemWithPlayerItem:feed.path ? [AVPlayerItem playerItemWithURL:feed.path] : nil];
}

@end
