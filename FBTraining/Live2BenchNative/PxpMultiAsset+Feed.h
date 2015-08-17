//
//  PxpMultiAsset+Feed.h
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-14.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PxpMultiAsset.h"
#import "Feed.h"

@interface PxpMultiAsset (Feed)

- (nonnull instancetype)initWithFeeds:(nullable NSArray *)feeds;

@end
