//
//  RJLFreezeMonitor.m
//  Live2BenchNative
//
//  Created by dev on 2015-03-20.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "RJLFreezeMonitor.h"
#import "RJLFreezeCounter.h"
#import "RJLVideoPlayer.h"


/**
 *  This class watches the status of the video player and reacts when is sees that its not updating
 *  like when the player freezes after a seek
 */
@implementation RJLFreezeMonitor
{
    RJLFreezeCounter * freezeCounter;
    UIViewController <PxpVideoPlayerProtocol>*    videoPlayer;
}

@synthesize enabled = _enabled;

- (instancetype)initWithPlayer:(UIViewController <PxpVideoPlayerProtocol>*)aPlayer
{
    self = [super init];
    if (self) {
        videoPlayer     = aPlayer;
        freezeCounter   = [[RJLFreezeCounter alloc]initWithTarget:self selector:@selector(onFreeze) object:nil];
        _enabled = YES;
        [freezeCounter startTimer:1 max:3];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(monitorPlayer:) name:PLAYER_TICK object:videoPlayer];
        
    }
    return self;
}


-(void)monitorPlayer:(NSNotification*)note
{
    if ((videoPlayer.status & RJLPS_Play)||(videoPlayer.status & RJLPS_Live)){
        if ((videoPlayer.status & RJLPS_Seeking) && !(videoPlayer.status & RJLPS_Scrubbing)){
//            [self onFreeze];
        }
    }

    [freezeCounter reset];
}


-(void)stop
{
    if (!_enabled) return;
    _enabled = NO;
   [freezeCounter stop];
}

-(void)start
{
    if (_enabled) return;
    _enabled = YES;
    [freezeCounter startTimer:1 max:3];
}


-(void)onFreeze
{
    
    if ((videoPlayer.status & RJLPS_Paused || videoPlayer.playerItem.status == AVPlayerItemStatusUnknown || videoPlayer.playerItem.status == AVPlayerItemStatusFailed)){
     
        [freezeCounter reset];
        return;
    }
    
    if ((videoPlayer.status & RJLPS_Scrubbing)){
        [videoPlayer.playerItem cancelPendingSeeks];
        [freezeCounter reset];
        return;
    } else {
        [videoPlayer.playerItem cancelPendingSeeks];
        [freezeCounter reset];
        
            __weak RJLVideoPlayer       * weakSelf      = (RJLVideoPlayer*)videoPlayer;
            __block RJLFreezeCounter    * weakCounter   = freezeCounter;
        
            if ([weakSelf.playerItem.seekableTimeRanges count]==0) return; // the video might be stopped at this point if ranges are 0
        
            double roundedLastTime;// = round (lastSeekTime--);//(round (lastSeekTime * 1000.0) / 1000.0)-1;
            double noise = 1 + freezeCounter.freezeCounter;//(-1 + (random()*2));
        
            roundedLastTime = (videoPlayer.videoControlBar.timeSlider.value + noise <= 0)?0:videoPlayer.videoControlBar.timeSlider.value + noise;
        
            CMTime mySeekTime = CMTimeMakeWithSeconds(roundedLastTime, 1000);
        
            CMTimeRange tempRange = [[weakSelf.playerItem.seekableTimeRanges objectAtIndex:0] CMTimeRangeValue];

            CMTime drr = tempRange.duration;
            if (CMTIME_COMPARE_INLINE(drr, >, mySeekTime)) {
                mySeekTime =  drr;
            }

        
        
        
            [videoPlayer.avPlayer seekToTime:mySeekTime completionHandler:^(BOOL finished) {
                //               dispatch_async(dispatch_get_main_queue(), ^{
                if (finished) {
                    NSLog(@"FreezeSeek FINISHED");
                    
                } else {
                    NSLog(@"FreezeSeek CANCELLED");
                }
//                weakSelf.status = weakSelf.status & ~(RJLPS_Thawing);
                weakSelf.status = weakSelf.status & ~(RJLPS_Seeking);
                [weakCounter reset];
                //                });
            }];
        
    }
        
        

    
    

}


-(void)dealloc
{
//    self.isAlive = NO;
    [freezeCounter stop];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:PLAYER_TICK object:videoPlayer];
}

@end
