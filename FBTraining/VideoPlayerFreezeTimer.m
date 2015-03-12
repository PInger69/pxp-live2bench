//
//  VideoPlayerFreezeTimer.m
//  Live2BenchNative
//
//  Created by dev on 10/2/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//



// This class is used to just check if the videoplay has frozen and tells it to reset if it is not updating and
// is not playing
#import "VideoPlayerFreezeTimer.h"
#import "VideoPlayer.h"

#define MAX_TIME    3
#define COOL_DOWN   10



@implementation VideoPlayerFreezeTimer
{
    
    NSInteger               maxTime;            // how many seconds till player is reset - const
    NSInteger               coolDown;           // after a restart wait these second - const
    NSInteger               timeOutCounter;     // the main counter
    NSTimer                 * timer;            // the checker that runs every second
    __weak VideoPlayer      * checkedPlayer;    // video being checked if frozen
    id                      timeObserver;
    float                   prevLeft;           // the time on the left side of slider to seek to on reset
    float                   prevRight;          // the time on the right side of slider to seek to on reset
}

@synthesize enable = _enable;


/**
 *  This will taking in the instance of the video player
 *
 *  @param player standard
 *
 *  @return instance
 */
-(id)initWithVideoPlayer:(VideoPlayer*)player
{
    self = [super init];
    if (self){
        maxTime             = MAX_TIME;
        coolDown            = COOL_DOWN;
        checkedPlayer       = player;
        timeOutCounter      = maxTime;
    }
    return self;
}



/**
 *  Method used to add periodic time observer which is used to update current time, duration and slider value
 *
 *  @param player
 */
- (void)addPlayerItemTimeObserver:(AVPlayer *)player{

    CMTime interval         = CMTimeMakeWithSeconds(1, NSEC_PER_SEC);
    dispatch_queue_t queue  = dispatch_get_main_queue();

    void(^callback)(CMTime time) = ^(CMTime time){
        timeOutCounter = (timeOutCounter > MAX_TIME)?timeOutCounter:MAX_TIME;
    };

    timeObserver = [player addPeriodicTimeObserverForInterval:interval queue:queue usingBlock:callback];

}






/**
 *  This is being run every second to watch the player if it has stopped updating
 */
-(void)cycle
{
    // skip cycle if video is complete
    if ( ([checkedPlayer duration]-[checkedPlayer currentTimeInSeconds] ) < 5 ) return;
    
    if (checkedPlayer.status == PS_Play || checkedPlayer.status == PS_Live){
        
        timeOutCounter -= 1;
        
        // when counter is at zero we need to reset the player
        if (timeOutCounter == 0) {
            [self resetAVplayerLayer:checkedPlayer];
            
            // saves the values from the slider
            prevLeft    = checkedPlayer.richVideoControlBar.timeSlider.value;
            prevRight   = checkedPlayer.currentTimeInSeconds - [checkedPlayer durationInSeconds];
            
            // Add observer to see when the player is ready for seeking
            [checkedPlayer.avPlayer addObserver:self forKeyPath:@"status" options:0 context:nil];
        }
    }
    
    
}


/**
 *  This resets the player by recalling the URL that it was currently loaded with
 *
 *  @param player that is being checked
 */
-(void)resetAVplayerLayer:(VideoPlayer*)player
{
    [player setVideoURL:player.videoURL];
    [player setPlayerWithURL:player.videoURL];
}

/**
 *  Enable or disable the antiFreeze class
 *
 *  @param enable
 */
-(void)setEnable:(BOOL)enable
{
    if (!_enable && enable){
        timer               = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                               target:self
                                                             selector:@selector(cycle)
                                                             userInfo:nil
                                                              repeats:YES];
        
        [self addPlayerItemTimeObserver:checkedPlayer.avPlayer];
    } else if (_enable && !enable) {
        [timer invalidate];
        timer = nil;
    }
    _enable = enable;
}

-(BOOL)enable{
    return _enable;
}

/**
 *  KVO
 *
 *  @param keyPath
 *  @param object
 *  @param change
 *  @param context
 */
- (void)observeValueForKeyPath:(NSString *)keyPath  ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayer * ply = (AVPlayer *)object;
        if (ply.status == AVPlayerStatusReadyToPlay) {
            if ([checkedPlayer seekTo:prevLeft]){
                timeOutCounter = coolDown; // add to cooldown and readd the timeobservers, they are removed before they restart
                [self addPlayerItemTimeObserver:checkedPlayer.avPlayer];
                [object removeObserver:self forKeyPath:NSStringFromSelector(@selector(status))];
            }
        }
    }
}

-(void)dealloc
{
    NSLog(@"DEALLOC ANTIFREEZE");
    @try{
        [checkedPlayer.avPlayer removeObserver:self forKeyPath:NSStringFromSelector(@selector(status))];
    }@catch(id anException){
        //do nothing, obviously it wasn't attached because an exception was thrown
    }
    
    if (timeObserver) [checkedPlayer.avPlayer removeTimeObserver:timeObserver];
}



@end
