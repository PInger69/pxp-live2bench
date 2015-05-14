//
//  RJLVideoPlayerResponder.m
//  Live2BenchNative
//
//  Created by dev on 2015-02-04.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "RJLVideoPlayerResponder.h"
#import "Feed.h"


@implementation RJLVideoPlayerResponder
{

    RJLVideoPlayer * player;
    
}

- (instancetype)initWithPlayer:(RJLVideoPlayer*)aPlayer
{
    self = [super init];
    if (self) {
        player = aPlayer;
    }
    return self;
}


-(void)processCommand:(NSDictionary* )dict
{
    NSString            * thisContext   = ([dict objectForKey:@"context"])?[dict objectForKey:@"context"]:@"all";
    
    if (![dict objectForKey:@"command"]) return;
    
    VideoPlayerCommand  command         = [[dict objectForKey:@"command"]integerValue];
    
    
    if (![thisContext isEqualToString:player.playerContext]){  // || [thisContext isEqualToString:@"all"] ||
        return;
    }
    
    if ( command & VideoPlayerCommandPlayFeed ) {
        [self playFeed:dict];
    }
    
    if ( command & VideoPlayerCommandPlay ) {
        [player play];
    }
    
    if ( command & (VideoPlayerCommandPause | VideoPlayerCommandStop)) {
        [player pause];
    }
    
    if ( command & VideoPlayerCommandLive ) {
        [player gotolive];
    }
    
    if ( command & VideoPlayerCommandLooping ) {
        player.looping = YES;
    }
    if ( command & VideoPlayerCommandNoLooping ) {
        player.looping = NO;
    }
    
    if ( command & VideoPlayerCommandSlowmo ) {
        player.slowmo  = YES;
    }
    
    if ( command & VideoPlayerCommandNoSlomo ) {
        player.slowmo = NO;
    }
    
    
    if ( command & VideoPlayerCommandMute ) {
        player.mute  = YES;
    }
    
    if ( command & VideoPlayerCommandUnmute ) {
        player.mute = NO;
    }
    
    if ( command & VideoPlayerCommandClear ) {
        [player clear];
    }
    
    
}

-(void)playFeed:(NSDictionary*)dict
{
    [player clear];
    Feed * feed = [dict objectForKey:@"feed"];
    
    if ([dict objectForKey:@"range"]) {
        CMTimeRange range = [((NSValue*)[dict objectForKey:@"range"])CMTimeRangeValue];
        if (CMTIMERANGE_IS_EMPTY(range)){
            player.looping = NO;
            [player playFeed:feed withRange:range];
            player.looping = YES;
        }
    } else {
        [player playFeed:feed];
    }
}




@end