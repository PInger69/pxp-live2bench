//
//  PxpMultiAsset.h
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-14.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PxpAsset.h"

@interface PxpMultiAsset : NSObject

@property (readonly, copy, nonatomic, nonnull) NSArray *assets;

@property (readonly, assign, nonatomic) BOOL loaded;

- (nonnull instancetype)init;
- (nonnull instancetype)initWithAsset:(nullable PxpAsset *)asset;
- (nonnull instancetype)initWithAssets:(nullable NSArray *)assets;

- (nullable PxpAsset *)assetNamed:(nullable NSString *)name;

@end
