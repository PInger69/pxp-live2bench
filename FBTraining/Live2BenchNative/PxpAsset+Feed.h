//
//  PxpAsset+Feed.h
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-14.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PxpAsset.h"
#import "Feed.h"

@interface PxpAsset (Feed)

- (nullable instancetype)initWithFeed:(nonnull Feed *)feed;

@end
