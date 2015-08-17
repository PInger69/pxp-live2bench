//
//  PxpAsset.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-14.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpAsset.h"

@interface PxpAsset ()

@property (assign, nonatomic) BOOL highQualityLoaded;
@property (assign, nonatomic) BOOL lowQualityLoaded;

@end

@implementation PxpAsset

static NSArray *_loadKeys;

+ (void)initialize {
    _loadKeys = @[@"tracks", @"playable", @"duration"];
}

+ (nonnull NSSet *)keyPathsForValuesAffectingLoaded {
    return [NSSet setWithArray:@[@"highQualityLoaded", @"lowQualityLoaded"]];
}

- (nonnull instancetype)initWithName:(nonnull NSString *)name URL:(nonnull NSURL *)URL {
    return [self initWithName:name highQualityURL:URL lowQualityURL:nil];
}

- (nonnull instancetype)initWithName:(nonnull NSString *)name highQualityURL:(nonnull NSURL *)highQualityURL lowQualityURL:(nullable NSURL *)lowQualityURL {
    self = [super init];
    if (self) {
        _highQualityLoaded = NO;
        _lowQualityLoaded = NO;
        
        _name = [NSString stringWithString:name];
        _highQualityAsset = [AVURLAsset assetWithURL:highQualityURL];
        _lowQualityAsset = lowQualityURL ? [AVURLAsset assetWithURL:lowQualityURL] : _highQualityAsset;
        
        [_highQualityAsset loadValuesAsynchronouslyForKeys:_loadKeys completionHandler:^() {
            self.highQualityLoaded = YES;
        }];
        [_lowQualityAsset loadValuesAsynchronouslyForKeys:_loadKeys completionHandler:^() {
            self.lowQualityLoaded = YES;
        }];
        
        
    }
    return self;
}

- (BOOL)loaded {
    return _highQualityLoaded && _lowQualityLoaded;
}

@end
