//
//  PxpAssetContext.h
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-14.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PxpMultiAsset.h"

@interface PxpAssetContext : NSObject

@property (strong, nonatomic, null_resettable) PxpMultiAsset *multiAsset;
@property (readonly, copy, nonatomic, nonnull) NSArray *assets;

@property (readonly, assign, nonatomic) BOOL loaded;

- (nonnull instancetype)init;
- (nonnull instancetype)initWithAsset:(nullable PxpAsset *)asset;
- (nonnull instancetype)initWithAssets:(nullable NSArray *)assets;
- (nonnull instancetype)initWithMultiAsset:(nullable PxpMultiAsset *)multiAsset;

@end
