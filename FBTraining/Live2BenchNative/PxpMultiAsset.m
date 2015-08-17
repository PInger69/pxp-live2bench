//
//  PxpMultiAsset.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-14.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpMultiAsset.h"

@interface PxpMultiAsset ()

@property (assign, nonatomic) BOOL loaded;

@end

@implementation PxpMultiAsset
{
    NSSet * __nonnull _assetSet;
    void * _assetLoadedObserverContext;
}

- (nonnull instancetype)init {
    return [self initWithAssets:nil];
}

- (nonnull instancetype)initWithAsset:(nullable PxpAsset *)asset {
    return [self initWithAssets:asset ? @[asset] : nil];
}

- (nonnull instancetype)initWithAssets:(nullable NSArray *)assets {
    self = [super init];
    if (self) {
        _assetSet = [NSSet setWithArray:assets ? [NSArray arrayWithArray:assets] : @[]];
        
        _assetLoadedObserverContext = &_assetLoadedObserverContext;
        for (PxpAsset *asset in _assetSet) {
            [asset addObserver:self forKeyPath:@"loaded" options:0 context:_assetLoadedObserverContext];
        }
    }
    return self;
}

- (void)dealloc {
    for (PxpAsset *asset in _assetSet) {
        [asset removeObserver:self forKeyPath:@"loaded" context:_assetLoadedObserverContext];
    }
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary *)change context:(nullable void *)context {
    if (context == _assetLoadedObserverContext) {
        const BOOL loaded = [self assetsLoaded];
        if (self.loaded != loaded) {
            self.loaded = loaded;
        }
    } else {
        return [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (nonnull NSArray *)assets {
    return _assetSet.allObjects;
}

#pragma mark - Public Methods

- (nullable PxpAsset *)assetNamed:(nullable NSString *)name {
    if (name) {
        for (PxpAsset *asset in _assetSet) {
            if ([asset.name isEqualToString:name]) {
                return asset;
            }
        }
    }
    return nil;
}

#pragma mark - Private Methods

- (BOOL)assetsLoaded {
    for (PxpAsset *asset in _assetSet) {
        if (!asset.loaded) {
            return NO;
        }
    }
    return YES;
}

@end
