//
//  NCPlayer.h
//  iOS Workspace
//
//  Created by Nico Cvitak on 2015-05-26.
//  Copyright (c) 2015 Nicholas Cvitak. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "NCPlayerContext.h"

@interface NCPlayer : AVPlayer

@property (weak, nonatomic, nullable) NCPlayerContext *context;

@property (readonly, nonatomic) CMTime duration;
@property (assign, nonatomic) CMTimeRange loopRange;
@property (assign, nonatomic) CMTime syncInterval;
@property (assign, nonatomic) CMTime syncThreshold;
@property (assign, nonatomic) BOOL slomo;
@property (assign, nonatomic) NSUInteger maximumSyncs;

- (void)setURL:(nonnull NSURL *)URL;
- (void)addReadyToPlayObserver:(nonnull void(^)(BOOL))readyBlock;
- (void)prerollAndPlayAtRate:(float)rate;
- (void)seekBy:(CMTime)time;

- (void)setRate:(float)rate atTime:(CMTime)time;

@end
