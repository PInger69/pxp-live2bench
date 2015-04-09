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
        self.secondLayer = [AVPlayerLayer layer];
        [self.secondLayer setFrame: self.layer.bounds];
        [self.layer addSublayer: self.secondLayer];
        
        self.videoLayer = [AVPlayerLayer layer];
        [self.videoLayer setFrame: self.layer.bounds];
        [self.layer addSublayer: self.videoLayer];
        
        if ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0) {
            self.maskView = [[UIView alloc] initWithFrame:self.bounds];
            self.maskView.backgroundColor =[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        }else{
            self.layer.mask = [CALayer layer];
            self.layer.mask.frame = self.bounds;
            self.layer.mask.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0].CGColor;
        }
        
    }
    return self;
}

-(void)setFrame:(CGRect)frame{
    
    CGRect videoLayerFrame = self.videoLayer.frame;
    videoLayerFrame.size.width += frame.size.width - self.frame.size.width;
    videoLayerFrame.size.height += frame.size.height - self.frame.size.height;
    
    [super setFrame:frame];
    [self didChangeValueForKey:@"frame"];
    
    self.videoLayer.frame = videoLayerFrame;
    
    if (self.secondLayer.superlayer == self.videoLayer.superlayer) {
        self.secondLayer.frame = videoLayerFrame;
    }
    if ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0) {
        self.maskView.frame = self.bounds;
    }else{
        self.layer.mask.frame = self.bounds;
    }
    
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
    [self.secondLayer setPlayer: player];
    
}

/* Specifies how the video is displayed within a player layer’s bounds.
 (AVLayerVideoGravityResizeAspect is default) */
- (void)setVideoFillMode:(NSString *)fillMode
{
    //AVPlayerLayer *playerLayer = (AVPlayerLayer*)[self layer];
    self.videoLayer.videoGravity = fillMode;
}

@end
