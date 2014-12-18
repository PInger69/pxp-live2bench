//
//  LBCloudPlayerView.m
//  Live2BenchNative
//
//  Created by Si Te Feng on 8/25/14.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "LBCloudPlayerView.h"

@implementation LBCloudPlayerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    return self;
}


+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

- (void)setPlayer:(AVPlayer *)player
{
    _player = player;
    
    [(AVPlayerLayer*)self.layer setPlayer:player];
    
}



- (void)setVideoFillMode:(NSString *)fillMode
{
    AVPlayerLayer *playerLayer = (AVPlayerLayer*)[self layer];
    playerLayer.videoGravity = fillMode;
}




@end
