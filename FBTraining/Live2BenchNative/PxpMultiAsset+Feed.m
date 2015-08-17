//
//  PxpMultiAsset+Feed.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-14.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpMultiAsset+Feed.h"
#import "PxpAsset+Feed.h"

@implementation PxpMultiAsset (Feed)

- (nonnull instancetype)initWithFeeds:(nullable NSArray *)feeds {
    NSMutableArray *assets = [NSMutableArray array];
    
    for (Feed *feed in feeds) {
        const PxpAsset *asset = [[PxpAsset alloc] initWithFeed:feed];
        if (asset) {
            [assets addObject:asset];
        }
    }
    
    return [self initWithAssets:assets];
}

@end
