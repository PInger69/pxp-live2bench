//
//  PxpAsset+Feed.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-14.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpAsset+Feed.h"

@implementation PxpAsset (Feed)

- (nullable instancetype)initWithFeed:(nonnull Feed *)feed {
    NSURL *hqPath = feed.hqPath;
    NSURL *lqPath = feed.lqPath;
    
    if (lqPath || hqPath) {
        return [self initWithName:feed.sourceName highQualityURL:hqPath ? hqPath : lqPath lowQualityURL:hqPath ? lqPath : nil];
    } else {
        return nil;
    }
}

@end
