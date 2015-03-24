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


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.videoLayer = [AVPlayerLayer layer];
        [self.videoLayer setFrame: self.layer.bounds];
        [self.layer addSublayer: self.videoLayer];
        
        
    }
    return self;
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    
    CGRect videoLayerFrame = frame;
    videoLayerFrame.origin.x = 0;
    videoLayerFrame.origin.y = 0;
    
    self.videoLayer.frame = videoLayerFrame;
    
    CALayer *maskLayer = [CALayer layer];
    maskLayer.frame = self.bounds;
    maskLayer.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0].CGColor;
    
    self.layer.mask = maskLayer;
}

//+ (Class)layerClass
//{
//    return [AVPlayerLayer class];
//}

- (AVPlayer*)player
{
    //return [(AVPlayerLayer*)[self layer] player];
    return [self.videoLayer player];
}

- (void)setPlayer:(AVPlayer*)player
{
    [self.videoLayer setPlayer:player];
    
    
}

/* Specifies how the video is displayed within a player layer’s bounds.
 (AVLayerVideoGravityResizeAspect is default) */
- (void)setVideoFillMode:(NSString *)fillMode
{
    //AVPlayerLayer *playerLayer = (AVPlayerLayer*)[self layer];
    self.videoLayer.videoGravity = fillMode;
}

@end
