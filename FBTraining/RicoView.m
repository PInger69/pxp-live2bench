//
//  RicoView.m
//  Live2BenchNative
//
//  Created by dev on 2016-02-04.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "RicoView.h"
#import "RicoPlayer.h"




@implementation RicoView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}
- (AVPlayer*)player {
    return [(AVPlayerLayer *)[self layer] player];
}
- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}


-(void)setRicoPlayer:(RicoPlayer *)ricoPlayer
{
    [ricoPlayer.linkedRenderViews addObject:self];
    self.player = ricoPlayer.avPlayer;
}


@end
