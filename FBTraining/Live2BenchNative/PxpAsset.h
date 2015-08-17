//
//  PxpAsset.h
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-14.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface PxpAsset : NSObject

@property (readonly, nonatomic, nonnull) NSString *name;
@property (readonly, strong, nonatomic, nonnull) AVAsset *highQualityAsset;
@property (readonly, strong, nonatomic, nonnull) AVAsset *lowQualityAsset;

@property (readonly, assign, nonatomic) BOOL loaded;

- (nonnull instancetype)initWithName:(nonnull NSString *)name URL:(nonnull NSURL *)URL;
- (nonnull instancetype)initWithName:(nonnull NSString *)name highQualityURL:(nonnull NSURL *)highQualityURL lowQualityURL:(nullable NSURL *)lowQualityURL;

@end
