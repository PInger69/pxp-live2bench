//
//  PxpAssetContext.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-14.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpAssetContext.h"

@interface PxpAssetContext ()

@end

@implementation PxpAssetContext

+ (nonnull NSSet *)keyPathsForValuesAffectingLoaded {
    return [NSSet setWithArray:@[@"multiAsset.loaded"]];
}

- (nonnull instancetype)init {
    return [self initWithMultiAsset:nil];
}

- (nonnull instancetype)initWithAsset:(nullable PxpAsset *)asset {
    return [self initWithMultiAsset:[[PxpMultiAsset alloc] initWithAsset:asset]];
}

- (nonnull instancetype)initWithAssets:(nullable NSArray *)assets {
    return [self initWithMultiAsset:[[PxpMultiAsset alloc] initWithAssets:assets]];
}

- (nonnull instancetype)initWithMultiAsset:(nullable PxpMultiAsset *)multiAsset {
    self = [super init];
    if (self) {
        self.multiAsset = multiAsset;
    }
    return self;
}

- (void)setMultiAsset:(nullable PxpMultiAsset *)multiAsset {
    _multiAsset = multiAsset ? multiAsset : [[PxpMultiAsset alloc] init];
}

- (nonnull NSArray *)assets {
    return self.multiAsset.assets;
}

- (BOOL)loaded {
    return self.multiAsset.loaded;
}

@end
