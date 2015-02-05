//
//  RJLVideoPlayerPlaybackView.m
//  Live2BenchNative
//
//  Created by dev on 2015-01-28.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "RJLVideoPlayerPlaybackView.h"
#import <AVFoundation/AVFoundation.h>


@implementation RJLVideoPlayerPlaybackView

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

- (AVPlayer*)player
{
    return [(AVPlayerLayer*)[self layer] player];
}

- (void)setPlayer:(AVPlayer*)player
{
    [(AVPlayerLayer*)[self layer] setPlayer:player];
}

/* Specifies how the video is displayed within a player layer’s bounds.
 (AVLayerVideoGravityResizeAspect is default) */
- (void)setVideoFillMode:(NSString *)fillMode
{
    AVPlayerLayer *playerLayer = (AVPlayerLayer*)[self layer];
    playerLayer.videoGravity = fillMode;
}

@end
