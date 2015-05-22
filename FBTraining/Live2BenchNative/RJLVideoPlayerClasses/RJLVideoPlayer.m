
//
//  RJLVideoPlayer.m
//  Live2BenchNative
//
//  Created by dev on 2015-01-28.
//  Copyright (c) 2015 DEV. All rights reserved.
//
#include <math.h>
#import "RJLVideoPlayer.h"
#import "RJLFreezeMonitor.h"
#import "RJLVideoPlayerResponder.h"
#import "ValueBuffer.h"


#define LIVE_BUFFER     5
#define SLOWMO_SPEED    0.5f

@implementation RJLVideoPlayer
{
    float   restoreAfterScrubbingRate;
    float   restoreAfterPauseRate;
    id      timeObserver;

    RJLVideoPlayerResponder * commander;
    NSURL   * mURL;
    
    // Anti Freeze Prop
    RJLFreezeMonitor * freezeMonitor;
    double  lastSeekTime;

    // Looping Prop
    id                  loopingObserver;
    
    // block to run when ready
    void (^onReadyBlock)();
    
    void (^onFeedReadyBlock)();
    
    UILabel * currentItemTime;
    CGRect videoFrame;

    
    BOOL  isFeedReady;
    ValueBuffer * liveBuffer;

}
static void *ViewControllerRateObservationContext           = &ViewControllerRateObservationContext;
static void *ViewControllerStatusObservationContext         = &ViewControllerStatusObservationContext;
static void *ViewControllerCurrentItemObservationContext    = &ViewControllerCurrentItemObservationContext;
static void *FeedQualityChangeContext                       = &FeedQualityChangeContext;

static void *RJLVideoPlayerStatusChange                     = &RJLVideoPlayerStatusChange;

static void *FeedAliveContext                               = &FeedAliveContext;

@synthesize status      = _status;
@synthesize looping     = _looping;
@synthesize feed        = _feed;
@synthesize mute        = _mute;

@synthesize playerContext = _playerContext;
@synthesize liveIndicatorLight,videoControlBar,playBackView,range;

@synthesize isAlive;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        _status         = RJLPS_Offline;
        // This listens to the app if it wants the player to do something
        self.isAlive = YES;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationCommands:) name:NOTIF_COMMAND_VIDEO_PLAYER object:nil];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(timeRequest:)          name:NOTIF_CURRENT_TIME_REQUEST object:nil];
        
        
        
        [self addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:&RJLVideoPlayerStatusChange];

        freezeMonitor = [[RJLFreezeMonitor alloc]initWithPlayer:self];
        commander = [[RJLVideoPlayerResponder alloc]initWithPlayer:self];
        videoFrame = frame;
        
        liveBuffer = [[ValueBuffer alloc]initWithValue:5 coolDownValue:10000000 coolDownTick:30];
        restoreAfterPauseRate = 1;
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _status         = RJLPS_Offline;
        self.isAlive = YES;
        // This listens to the app if it wants the player to do something
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationCommands:) name:NOTIF_COMMAND_VIDEO_PLAYER object:nil];
        [self addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:&RJLVideoPlayerStatusChange];

        commander       = [[RJLVideoPlayerResponder alloc]initWithPlayer:self];
        videoFrame      = CGRectMake(500, 60, 400, 300);
        restoreAfterPauseRate = 1;
    }
    return self;
}


-(void)viewDidLoad
{
    // every second, after 3 seconds fire if not reset
    

    self.playBackView           = [[RJLVideoPlayerPlaybackView alloc]initWithFrame:videoFrame];//CGRectMake(500, 60, 400, 300)
    self.zoomManager = [[VideoZoomManager alloc]init];
    self.zoomManager.videoPlayer = self;
    
    self.view                   = self.playBackView;
    self.view.backgroundColor   = [UIColor blackColor];

    liveIndicatorLight          = [[LiveLight alloc]init];
    liveIndicatorLight.frame    = CGRectMake(self.view.frame.size.width-30,0,10,10);
    liveIndicatorLight.hidden   = YES;
    
    videoControlBar             = [[VideoControlBarSlider alloc]initWithFrame:self.view.frame];
    [videoControlBar.timeSlider addTarget:self action:@selector(sliderValueChanged)
             forControlEvents:UIControlEventValueChanged];
    [videoControlBar.timeSlider addTarget:self action:@selector(scrubbingStart)
             forControlEvents:UIControlEventTouchDown];
    [videoControlBar.timeSlider addTarget:self action:@selector(willScrubbingEnd)
             forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchDownRepeat|UIControlEventTouchCancel];
    [videoControlBar setupPlay:@selector(play) Pause:@selector(pause) target:self];
    videoControlBar.enable = NO;
    
    self.clipControlBar = [[ClipControlBarSlider alloc] initWithFrame: self.view.frame];
    [self.clipControlBar.timeSlider addTarget:self action:@selector(sliderValueChanged)
                         forControlEvents:UIControlEventValueChanged];
    [self.clipControlBar.timeSlider addTarget:self action:@selector(scrubbingStart)
                         forControlEvents:UIControlEventTouchDown];
    [self.clipControlBar.timeSlider addTarget:self action:@selector(willScrubbingEnd)
                         forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchDownRepeat|UIControlEventTouchCancel];
    [self.clipControlBar setupPlay:@selector(play) Pause:@selector(pause) onCancelClip:@selector(cancelClip) target:self];
    self.clipControlBar.enable = NO;
    self.clipControlBar.hidden = YES;

    
    [self initBarTimer];

    [self.view addSubview:liveIndicatorLight];
    [self.view addSubview:videoControlBar];
    [self.view addSubview: self.clipControlBar];
    
    // debugging
    currentItemTime = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 500, 30)];
    currentItemTime.textColor = [UIColor whiteColor];
   if (DEBUG_MODE) [self.view addSubview:currentItemTime];
    
    [super viewDidLoad];
}


-(void)initBarTimer
{
    if (timeObserver)return;
    
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        return;
    }
    
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration))
    {
        [self addPeriodicTimeObserver];
    }
}

-(void)playClipWithFeed: (Feed*)aFeed andTimeRange:(CMTimeRange)aRange{
    [self playFeed:aFeed withRange:aRange];
    self.isInClipMode = YES;
    self.clipControlBar.hidden = NO;
    self.clipControlBar.enable = YES;
    self.clipControlBar.timeSlider.minimumValue = (aRange.start.value / aRange.start.timescale);
    self.clipControlBar.timeSlider.maximumValue = (aRange.start.value / aRange.start.timescale) + (aRange.duration.value/ aRange.duration.timescale);
    
    self.videoControlBar.hidden = YES;

}

-(void)cancelClip{
    self.isInClipMode           = NO;
    self.looping                = NO;
    self.clipControlBar.hidden  = YES;
    self.videoControlBar.hidden = NO;
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_CLIP_CANCELED object:self];
}

/**
 *  This makes sure the bar matches the data at all time when a video is running
 */
- (void)syncControlBar
{
    CMTime playerDuration = [self playerItemDuration];
    
    float checkDuration = ( isnan(CMTimeGetSeconds(playerDuration)) )? 0 : CMTimeGetSeconds(playerDuration);

    self.videoControlBar.timeSlider.maximumValue = checkDuration;
    if (_looping){
        videoControlBar.timeSlider.minimumValue = CMTimeGetSeconds(range.start);
        self.videoControlBar.timeSlider.maximumValue = CMTimeGetSeconds(CMTimeAdd(range.start, range.duration));
    }
    
    if (CMTIME_IS_INVALID(playerDuration))
    {
        videoControlBar.timeSlider.minimumValue = 0.0;
        return;
    }
    
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration))
    {
//        float minValue = [self.videoControlBar.timeSlider minimumValue];
//        float maxValue = [self.videoControlBar.timeSlider maximumValue];
        double time = CMTimeGetSeconds([self.playerItem currentTime]);
    
        self.videoControlBar.timeSlider.maximumValue = duration;
        videoControlBar.timeSlider.minimumValue = 0.0;
        [self.videoControlBar.timeSlider setValue:time];
        
        double clipControlBarValue = time;
        self.clipControlBar.value = clipControlBarValue;

//        [self.videoControlBar.timeSlider setValue:(maxValue - minValue) * time / duration + minValue];
    }
    
    [self.videoControlBar.leftTimeLabel setText:[self translateTimeFormat:self.videoControlBar.timeSlider.value]];
    [self.videoControlBar.rightTimeLabel setText:[self translateTimeFormat:self.videoControlBar.timeSlider.value - [self durationInSeconds]]];
   
    if (_status & RJLPS_Live){
       [self.videoControlBar.rightTimeLabel setText:@"Live"];
        self.videoControlBar.timeSlider.value       = self.videoControlBar.timeSlider.maximumValue;
    }
    
}



#pragma mark -
#pragma mark Control Bar Methods


/**
 *  This method is run during the scrub. There is a check for scrubbing to ensure that this does not get run before -(void)scrubbingStart
 */
-(void)sliderValueChanged {
    
    // not seeking and is Scrubbing    This is to prevent multi seeking
    if (!(_status & RJLPS_Seeking)!=0 && (_status & RJLPS_Scrubbing)!=0){

        self.status = _status | RJLPS_Seeking;
        self.status = _status & ~(RJLPS_Live);

        
        CMTime playerDuration = [self playerItemDuration];
        if (CMTIME_IS_INVALID(playerDuration)) {
            return;
        }
    
        if (_looping){
            playerDuration = range.duration;
            
        }
        double duration = CMTimeGetSeconds(playerDuration);
        
        if (isfinite(duration))
        {
            if (self.isInClipMode) {
//                float minValue  = [self.clipControlBar.timeSlider minimumValue];
//                float maxValue  = [self.clipControlBar.timeSlider maximumValue];
//                float value     = [self.clipControlBar.timeSlider value];
//                
//                double time     = duration * (value - minValue) / (maxValue - minValue);

//                float minValue  = [self.clipControlBar.timeSlider minimumValue];
//                float maxValue  = [self.clipControlBar.timeSlider maximumValue];
//                float value     = [self.clipControlBar.timeSlider value];
                
                //double time     = duration * (value - minValue) / (maxValue - minValue);
                double time = self.clipControlBar.timeSlider.value ;//- self.clipControlBar.timeSlider.minimumValue ;
                NSLog(@"The time is %f", time);
                lastSeekTime    = time;
                __block RJLVideoPlayer      * weakSelf      = self;
                
                CMTime accuraccy = [self precisionOfScrub:self.clipControlBar.timeSlider.scrubbingSpeed];
                
                [self.avPlayer seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) toleranceBefore:accuraccy toleranceAfter:accuraccy completionHandler:^(BOOL finished) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if (finished) {
                            weakSelf.status = weakSelf.status & ~(RJLPS_Seeking);
                        } else {
                            NSLog(@"Seek CANCELD");
                        }
                        weakSelf.status = weakSelf.status & ~(RJLPS_Seeking);
                    });
                }];
            }else{
                float minValue  = [self.videoControlBar.timeSlider minimumValue];
                float maxValue  = [self.videoControlBar.timeSlider maximumValue];
                float value     = [self.videoControlBar.timeSlider value];
                
                double time     = duration * (value - minValue) / (maxValue - minValue);
                lastSeekTime    = time;
                __block RJLVideoPlayer      * weakSelf      = self;
                
                CMTime accuraccy = [self precisionOfScrub:self.videoControlBar.timeSlider.scrubbingSpeed];
                
                [self.avPlayer seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) toleranceBefore:accuraccy toleranceAfter:accuraccy completionHandler:^(BOOL finished) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if (finished) {
                            weakSelf.status = weakSelf.status & ~(RJLPS_Seeking);
                        } else {
                            NSLog(@"Seek CANCELD");
                        }
                        weakSelf.status = weakSelf.status & ~(RJLPS_Seeking);
                    });
                }];
            }
            
        }
    
    
    }

    [self.videoControlBar.leftTimeLabel setText:[self translateTimeFormat:self.videoControlBar.timeSlider.value]];
    [self.videoControlBar.rightTimeLabel setText:[self translateTimeFormat:self.videoControlBar.timeSlider.value - [self durationInSeconds]]];
}

-(void)scrubbingStart{
    self.status = _status | RJLPS_Scrubbing ; //| RJLPS_Seeking
    
    if (!((_status & RJLPS_Seeking)!=0))restoreAfterScrubbingRate = [self.avPlayer rate];
    [self.avPlayer setRate:0.f];
    
    [self removePlayerTimeObserver]; // remove time observers to prevent updating during scrubbing
}

/**
 *  This menthod is to do one last seek just before the observers are added back
 *  This will prevent the slider for moving around on quick seeks
 */
-(void)willScrubbingEnd
{
        self.status = _status | RJLPS_Seeking;
    
        CMTime playerDuration = [self playerItemDuration];
    
    if (_looping){
        playerDuration = range.duration;

    }
    
        if (CMTIME_IS_INVALID(playerDuration)) {
            return;
        }
        
        
        double duration = CMTimeGetSeconds(playerDuration);
    
    
        if (isfinite(duration))
        {
            if (self.isInClipMode) {
//                float minValue  = [self.clipControlBar.timeSlider minimumValue];
//                float maxValue  = [self.clipControlBar.timeSlider maximumValue];
//                float value     = [self.clipControlBar.timeSlider value];
//                
//                double time     = duration * (value - minValue) / (maxValue - minValue);
                //                float minValue  = [self.clipControlBar.timeSlider minimumValue];
                //                float maxValue  = [self.clipControlBar.timeSlider maximumValue];
                //                float value     = [self.clipControlBar.timeSlider value];
                
                //double time     = duration * (value - minValue) / (maxValue - minValue);
                double time = self.clipControlBar.timeSlider.value;// - self.clipControlBar.timeSlider.minimumValue ;
                lastSeekTime    = time;
                __block RJLVideoPlayer      * weakSelf      = self;
                
                CMTime accuraccy = [self precisionOfScrub:self.clipControlBar.timeSlider.scrubbingSpeed];
                
                [self.avPlayer seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) toleranceBefore:accuraccy toleranceAfter:accuraccy completionHandler:^(BOOL finished) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if (finished) {
                            weakSelf.status = weakSelf.status & ~(RJLPS_Seeking);
                        } else {
                            NSLog(@"Seek CANCELD");
                        }
                        [weakSelf scrubbingEnd];
                        weakSelf.status = weakSelf.status & ~(RJLPS_Seeking);
                    });
                }];
            }else{

                float minValue  = [self.videoControlBar.timeSlider minimumValue];
                float maxValue  = [self.videoControlBar.timeSlider maximumValue];
                float value     = [self.videoControlBar.timeSlider value];
                double time     = duration * (value - minValue) / (maxValue - minValue);
                lastSeekTime    = time;
                __block RJLVideoPlayer      * weakSelf      = self;
                
                CMTime accuraccy = [self precisionOfScrub:self.videoControlBar.timeSlider.scrubbingSpeed];
                
                [self.avPlayer seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) toleranceBefore:accuraccy toleranceAfter:accuraccy completionHandler:^(BOOL finished) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if (finished) {
                            
                        } else {
                            NSLog(@"Seek CANCELD");
                        }
                        [weakSelf scrubbingEnd];
                        weakSelf.status = weakSelf.status & ~(RJLPS_Seeking);
                    });
                }];
            }
        }
        
        
    
    
//    [self.videoControlBar.leftTimeLabel setText:[self translateTimeFormat:self.videoControlBar.timeSlider.value]];
//    [self.videoControlBar.rightTimeLabel setText:[self translateTimeFormat:self.videoControlBar.timeSlider.value - [self durationInSeconds]]];
}


-(void)scrubbingEnd{
    
    if (restoreAfterScrubbingRate)
    {
        [self.avPlayer setRate:restoreAfterScrubbingRate];
        restoreAfterScrubbingRate = 0.f;
    } else {
        
    }
    
    self.status = _status & ~(RJLPS_Scrubbing); // not scrubbing anymore

    if (!timeObserver)
    {
        CMTime playerDuration = [self playerItemDuration];
        if (_looping){
            playerDuration = range.duration;
            
        }
        if (CMTIME_IS_INVALID(playerDuration))
        {
            return;
        }
        
        double duration = CMTimeGetSeconds(playerDuration);
        if (isfinite(duration))
        {
            [self addPeriodicTimeObserver];
        }
    }
}

#pragma mark -
#pragma mark Observers


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
     if (context == ViewControllerStatusObservationContext){
         AVPlayerItemStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
         switch (status)
         {
                 /* Indicates that the status of the player is not yet known because
                  it has not tried to load new media resources for playback */
             case AVPlayerItemStatusUnknown:
             {
                 [self removePlayerTimeObserver];
                 videoControlBar.enable = NO;
             }
                 break;
                 
             case AVPlayerItemStatusReadyToPlay:
             {
                 videoControlBar.enable = YES;
                 
                 if ((_status & RJLPS_Scrubbing)==0 && (_status & RJLPS_Seeking)==0) {
                     [self initBarTimer];
                 }
                 
                 
                 
                 if(onReadyBlock) onReadyBlock();
                 self.videoControlBar.timeSlider.minimumValue = 0;
                 self.videoControlBar.timeSlider.maximumValue = [self durationInSeconds];
                 
             }
                 break;
                 
             case AVPlayerItemStatusFailed:
             {
                 videoControlBar.enable = NO;
                 AVPlayerItem *playerItem = (AVPlayerItem *)object;
                 [self assetFailedToPrepareForPlayback:playerItem.error];
             }
                 break;
         }
         
     
     } else  if (context == ViewControllerRateObservationContext) {
     
     
     }else  if (context == ViewControllerCurrentItemObservationContext) {
         
         
     } else if (context == FeedQualityChangeContext) { // the feed quality has changed
         self.URL = [_feed path];
         [self seekToInSec:CMTimeGetSeconds([self.playerItem currentTime])];
     }else if (context == RJLVideoPlayerStatusChange) {
         [self observeRJLPlayerStatusObject:object change:change];
     }
    
    
    
    if (context == &FeedAliveContext) {
 
        [object removeObserver:self forKeyPath:@"quality" context:FeedQualityChangeContext];
        [object removeObserver:self forKeyPath:NSStringFromSelector(@selector(isAlive)) context:&FeedAliveContext];
        
    }
    
    if (DEBUG_MODE){
        [currentItemTime setText:[NSString stringWithFormat:@"%f | %@",CMTimeGetSeconds([self.playerItem currentTime]), [self statusString]]];
    }

}

-(void)observeRJLPlayerStatusObject:(id)object change:(NSDictionary *)change
{
    PlayerStatus pStatus = ((RJLVideoPlayer*) object).status;
    if ((pStatus & RJLPS_Live) !=0){
        [liveIndicatorLight setHidden:NO];
    } else if ((pStatus & RJLPS_Live) ==0) {
        [liveIndicatorLight setHidden:YES];
    }
}



/**
 *  This might be put in another class
 *
 *  @param note <#note description#>
 */
-(void)notificationCommands:(NSNotification*)note
{
    [commander processCommand:note.userInfo];
}


-(void)timeRequest:(NSNotification*)note
{

//    NSString            * thisContext   = ([dict objectForKey:@"context"])?[dict objectForKey:@"context"]:@"all";

    
    
//    if (![thisContext isEqualToString:self.playerContext]){
//        return;
//    }
    
    
    
//    void (^passingDataBack)(float) = [note.userInfo objectForKey:@"block"];


}


-(void)removePlayerTimeObserver
{
    if (timeObserver)
    {
        [self.avPlayer removeTimeObserver:timeObserver];
        timeObserver = nil;
    }
}


-(void)addPeriodicTimeObserver
{
    double                      interval        = 0.5f;
    __block RJLVideoPlayer      * weakSelf      = self;
    __block UILabel             * weakLabel     = currentItemTime;

    timeObserver = [self.avPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)
                                                               queue:NULL
                                                          usingBlock:^(CMTime time)
                    {
                        
                        
                        [weakLabel setText:[NSString stringWithFormat:@"%f | %@",CMTimeGetSeconds([weakSelf.playerItem currentTime]), [weakSelf statusString]]];
                        [weakSelf syncControlBar];
                        [[NSNotificationCenter defaultCenter]postNotificationName:PLAYER_TICK object:weakSelf];
                        /**
                         *  Should add check life to keep up to date
                         */
                        if (weakSelf.status & RJLPS_Live){
                        
                            double duration = CMTimeGetSeconds([weakSelf playerItemDuration]);
                            double ctime    = CMTimeGetSeconds([weakSelf.playerItem currentTime]);
                            if (duration - ctime > weakSelf -> liveBuffer.value){
                                [weakSelf -> liveBuffer onCoolDown];
                                [weakSelf seekToInSec:duration];
                            }
                        }
                    }];

}


#pragma mark -
#pragma mark Commands

/**
 *  This takes the video right to the end of the current feed and stops all seek or anything else
 */
-(void)gotolive{
    [self.videoControlBar setHidden:NO];
    [self.clipControlBar setHidden:YES];
    self.looping                                = NO;
    self.videoControlBar.playButton.selected    = FALSE;
    onReadyBlock                                = nil; //clear out any queued seeking
   
    self.status                                 = (_status | RJLPS_Live  | RJLPS_Play) & ~(RJLPS_Slomo) ; // At the end of a live feed
    
    // if it was paused then remove the pause and set the rate
    if (_status & RJLPS_Paused) {
        [self.avPlayer setRate:restoreAfterPauseRate];
        self.status                             = _status & ~(RJLPS_Paused);
    }
    
    // if it was seeking remove the seek and cancel what ever it was seeking too
    if ( (_status & RJLPS_Seeking) ) {
        self.status                             = _status & ~(RJLPS_Seeking);
        [_playerItem cancelPendingSeeks];
    }

    // seek to the end of the clip
    [self seekToInSec:[self durationInSeconds]];
    [self.avPlayer setRate:1];
    restoreAfterPauseRate = 1;
    if (self.playerItem.status == AVPlayerItemStatusUnknown){
        __block RJLVideoPlayer *weakSelf = self;
        onReadyBlock = ^void(){
            [weakSelf gotolive];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ReadyToCreateTagMarkers" object:nil];
        };
    }
}

-(void)play{
    if (!_feed)return;
    [self.avPlayer play];
    [freezeMonitor start];
    if (_status & RJLPS_Paused) [self.avPlayer setRate:restoreAfterPauseRate];
    self.status                                 = _status | RJLPS_Play;
    self.status                                 = _status & ~(RJLPS_Paused);
    [self.videoControlBar setHidden:NO];
    //self.videoControlBar.playButton.selected    = FALSE;
    onReadyBlock                                = nil;
    __block RJLVideoPlayer  * weakSelf          = self;
    if (self.playerItem.status == AVPlayerItemStatusUnknown){ // This delays the seek if its not ready
//        self.status                             = _status | RJLPS_Seeking;
//        [self removePlayerTimeObserver];
        onReadyBlock = ^void(){
//            weakSelf.status = weakSelf.status & ~(RJLPS_Seeking);
//            [weakSelf addPeriodicTimeObserver];
            [weakSelf play];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ReadyToCreateTagMarkers" object:nil];
        };
    }
}

-(void)pause{
    if (_status & RJLPS_Paused) return;
    restoreAfterPauseRate = [self.avPlayer rate];
    [self.avPlayer pause];
    //self.videoControlBar.playButton.selected    = TRUE;
    self.status                                 = _status & ~( RJLPS_Live | RJLPS_Play);
    self.status                                 = _status | RJLPS_Paused;
}

-(void)playFeed:(Feed*)aFeed
{

    self.feed = aFeed;
    self.URL = [self.feed path];
    [self play];
}

-(void)playFeed:(Feed*)aFeed withRange:(CMTimeRange)aRange
{

    onFeedReadyBlock    = nil;
    range               = aRange;
    
    if ([[self.feed path] isEqual:[aFeed path]]){
        [self seekToInSec:CMTimeGetSeconds(aRange.start)];
        return;
    }
    
    self.status                             = _status | RJLPS_Seeking;
    
    __block RJLVideoPlayer  * weakSelf          = self;
    __block CMTime rStart                       = aRange.start;
    onFeedReadyBlock = ^void(){
        
        [weakSelf.avPlayer seekToTime:rStart completionHandler:^(BOOL finished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (finished) {
                    
                } else {
                    NSLog(@"seekToInSec: CANCELLED");
                }
                weakSelf.status = weakSelf.status & ~(RJLPS_Seeking);
            });
        }];
        
    };

    
    
    
    
    // range will be the tag times.... might have to make a new class for this
    self.feed = aFeed;
    self.URL = [self.feed path];
//    [self seekToInSec:CMTimeGetSeconds(aRange.start)];
}


-(void)clear
{
    self.status = RJLPS_Offline;
    [self removePlayerTimeObserver];
    self.looping = NO;
    currentItemTime.text = @"";
    videoControlBar.enable = NO;
    [freezeMonitor stop];
    //videoControlBar.timeSlider.hidden = YES;
    
    
    if (self.playerItem)
    {
        /* Remove existing player item key value observers and notifications. */
        
        [self.playerItem removeObserver:self forKeyPath:@"status"];
        
       [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:self.playerItem];
        self.playerItem = nil;
    }
    
    if (self.avPlayer) {
        [self.avPlayer removeObserver:self forKeyPath:@"currentItem"];
        [self.avPlayer removeObserver:self forKeyPath:@"rate"];
        self.avPlayer = nil;
    }
    

        [self setPlayer:nil];
        [self.playBackView setPlayer:nil];
        
        self.zoomManager.enabled = NO;
    
    
    

    

    //[self.player replaceCurrentItemWithPlayerItem:nil];
//  self.view.layer.sublayers = @[];
//  self.view.layer.sublayers = nil;
//    self.view.layer.backgroundColor = [[UIColor blackColor]CGColor];
//    self.view.layer = nil;
}


#pragma mark -
#pragma mark Seekers

/**
 *  Seek to a spacific time in seconds
 *
 *  @param seekTime Time in seconds
 */
-(void)seekToInSec:(float)seekTime
{

    self.status                         = _status | RJLPS_Seeking;
    onReadyBlock                        = nil;
    __block RJLVideoPlayer  * weakSelf  = self;
    
    float _seekTime                     = [self seekClamp:seekTime];
    NSLog(@"                          Seeking too: %f",_seekTime);


    if (self.playerItem.status == AVPlayerItemStatusUnknown){ // This delays the seek if its not ready
        onReadyBlock = ^void(){
        
            [weakSelf.avPlayer seekToTime:CMTimeMakeWithSeconds(_seekTime, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
                dispatch_async(dispatch_get_main_queue(), ^{
                
                if (finished) {
//                    weakSelf.status = weakSelf.status & ~(RJLPS_Seeking);

                } else {
                    NSLog(@"seekToInSec: CANCELLED");
                }
                weakSelf.status = weakSelf.status & ~(RJLPS_Seeking);
                });
            }];
            
        };
        return;
    }
    
    
    [self.avPlayer seekToTime:CMTimeMakeWithSeconds(_seekTime, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
        
            if (finished) {
                NSLog(@"Player Time is: %f",CMTimeGetSeconds(weakSelf.avPlayer.currentTime));
                
            } else {
                NSLog(@"seekToInSec: CANCELLED");
            }
            weakSelf.status = weakSelf.status & ~(RJLPS_Seeking);
        });
    }];
}


/**
 *  Seek from current time adding or minusing seconds
 *
 *  @param secValue seconds from
 */
-(void)seekBy:(float)secValue
{

    self.status                             = _status | RJLPS_Seeking;
    onReadyBlock                               = nil;

    float currTime                          = CMTimeGetSeconds([self.playerItem currentTime]);
    float duration                          = [self durationInSeconds];
    
    float  sliderValue                      = currTime + secValue;
    CMTime seekTime                         = CMTimeMakeWithSeconds((currTime + secValue), NSEC_PER_SEC);
    
    if (currTime + secValue > duration)
    {
        seekTime    = CMTimeMakeWithSeconds(duration, NSEC_PER_SEC);
        sliderValue = self.videoControlBar.timeSlider.maximumValue;
        
    } else if (currTime + secValue < 0) {
        seekTime    = kCMTimeZero;
        sliderValue =   self.videoControlBar.timeSlider.minimumValue;
    }
    
    self.videoControlBar.timeSlider.value   = sliderValue;
    __block RJLVideoPlayer  * weakSelf      = self;
    
    if (self.playerItem.status == AVPlayerItemStatusUnknown){ // This delays the seek if its not ready
        onReadyBlock = ^void(){
            [weakSelf seekBy:secValue];
        };
        return;
    }
    
    // Do the seeking
//    [self.avPlayer seekToTime:seekTime completionHandler:^(BOOL finished) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (finished) {
//                
//            } else {
//                NSLog(@"seekBy: CANCELLED");
//            }
//            weakSelf.status = weakSelf.status & ~(RJLPS_Seeking);
//        });
//    }];

    
    [self.avPlayer seekToTime:seekTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (finished) {
                
            } else {
                NSLog(@"seekBy: CANCELLED");
            }
            weakSelf.status = weakSelf.status & ~(RJLPS_Seeking);
        });
    }];

    
    
}


-(void)seekWithSeekerButton:(id)sender
{
    self.status         = _status & ~(RJLPS_Live);
    float currentTime   = CMTimeGetSeconds([self.playerItem currentTime]);
    float seekAmount    = 0;
                                           
    if ([sender respondsToSelector:@selector(speed)]){
        seekAmount  = (double)[sender speed];
    } else {
        NSLog(@"\tSpeed Not found on sender");
        return;
    }

    // This is for frame stepping
    if (fabsf(seekAmount) < 0.25f){
        [self pause];
        
        double beforeFrame    = CMTimeGetSeconds([self.playerItem currentTime]);
        [_playerItem stepByCount:(seekAmount>0)? 1 : -1];
        double acterFrame    = CMTimeGetSeconds([self.playerItem currentTime]);
        if (beforeFrame == acterFrame) {
            [self seekBy:(seekAmount>0)? 0.0333 : -0.0333];
        }
        

        return;
    }
    
    

    if (currentTime+seekAmount > [self durationInSeconds]) {
        [self seekToInSec:[self durationInSeconds]];
    } else {
        [self seekBy:seekAmount];
    }
}


#pragma mark -
#pragma mark Getters and Setters

-(PlayerStatus)status
{
    return _status;
}

-(void)setStatus:(PlayerStatus)status
{
    [self willChangeValueForKey:NSStringFromSelector(@selector(status))];
    _status = status;
    [self didChangeValueForKey:NSStringFromSelector(@selector(status))];
}


-(BOOL)live
{
    return ((_status & RJLPS_Live)!=0);
}

-(void)setLive:(BOOL)live
{
    if (live) {
        self.status = _status | RJLPS_Live;
    } else {
        self.status = _status & ~RJLPS_Live;
    }

}



-(BOOL)looping
{
    return  _looping;
}

-(void)setLooping:(BOOL)looping
{
    if (_looping == looping) return;
    
    [self willChangeValueForKey:@"looping"];
    _looping = looping;
    [self didChangeValueForKey:@"looping"];
    
    if(loopingObserver) { // remove it if it has it :)
        [self.avPlayer removeTimeObserver:loopingObserver];
        loopingObserver = nil;
        self.status     = _status & ~(RJLPS_Looping);
    }
    
    if (_looping) {
        self.status                 = _status | RJLPS_Looping;
        CMTime startT               = range.start;
        CMTime endT                 = CMTimeAdd(startT, range.duration);
        NSArray *times              = @[ [NSValue valueWithCMTime: endT] ];
        __block AVPlayer *weakRef   = self.avPlayer;
        __block RJLVideoPlayer  * weakSelf      = self;
        loopingObserver = [self.avPlayer addBoundaryTimeObserverForTimes:times queue:NULL usingBlock:^{
            
            weakSelf.status = weakSelf.status |RJLPS_Seeking;
            [weakRef seekToTime:startT completionHandler:^(BOOL finished) {
                if (finished) {
                    weakSelf.status = weakSelf.status & ~(RJLPS_Seeking);
                } else {
                    NSLog(@"seekin LoopBy: CANCELLED");
                }

            }];
            
        }];
    }
    
}

-(BOOL)slowmo
{
    if (!self.avPlayer) return NO;
    return ([self.avPlayer rate] >= 1.0)? NO : YES;
}

-(void)setSlowmo:(BOOL)slowmo
{
    [self willChangeValueForKey:@"slowmo"];
    if (slowmo) {
        [self.avPlayer setRate:SLOWMO_SPEED];
        self.status = _status & ~(RJLPS_Live);
        self.status = _status | RJLPS_Slomo;
        
    } else {
        [self.avPlayer setRate:1];
       self.status = _status & ~(RJLPS_Slomo);
        
    }
    [self didChangeValueForKey:@"slowmo"];

}

-(BOOL)mute
{
    return self.avPlayer.muted;
}

-(void)setMute:(BOOL)mute
{
    
    if (self.avPlayer.muted == mute) return;
    
    [self willChangeValueForKey:@"mute"];
    
    // this will compensate for playRate
    if (!self.avPlayer.muted && mute) {
        self.status = _status | RJLPS_Mute;
        self.avPlayer.muted = mute;
        
    } else if (self.avPlayer.muted && !mute) {
        self.status = _status & ~(RJLPS_Mute);
        self.avPlayer.muted = mute;
    }
    
    [self didChangeValueForKey:@"mute"];
}




-(Feed*)feed
{
    return _feed;
}

-(void)setFeed:(Feed *)feed
{
    [self willChangeValueForKey:@"feed"];
    if (_feed){
        [_feed removeObserver:self forKeyPath:@"quality" context:FeedQualityChangeContext];
        [_feed removeObserver:self forKeyPath:NSStringFromSelector(@selector(isAlive)) context:&FeedAliveContext];
    }
    _feed = feed;
    [_feed addObserver:self forKeyPath:@"quality" options:NSKeyValueObservingOptionNew context:FeedQualityChangeContext];
    [_feed addObserver:self forKeyPath:NSStringFromSelector(@selector(isAlive)) options:NSKeyValueObservingOptionNew context:&FeedAliveContext];
    [self didChangeValueForKey:@"feed"];
}





-(void)setURL:(NSURL*)URL
{
    if (mURL != URL)
    {
        mURL = [URL copy];
        
        /*
         Create an asset for inspection of a resource referenced by a given URL.
         Load the values for the asset key "playable".
         */
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:mURL options:nil];
        
        NSArray *requestedKeys = @[@"playable"];
        
        /* Tells the asset to load the values of any of the specified keys that are not already loaded. */
        [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:
         ^{
             dispatch_async( dispatch_get_main_queue(),
                            ^{
                                /* IMPORTANT: Must dispatch to main queue in order to operate on the AVPlayer and AVPlayerItem. */
                                [self prepareToPlayAsset:asset withKeys:requestedKeys];
                                
                            });
         }];
    }
}

- (NSURL*)URL
{
    return mURL;
}


/**
 *  This is for debugging
 *
 *  @param playerContext
 */
-(void)setPlayerContext:(NSString *)playerContext
{
    _playerContext = playerContext;
    

    
}

-(NSString*)playerContext
{
    return _playerContext;
}


-(float)fps
{

    float fps=0.00;
    if (self.player.currentItem.asset) {
        
//        AVAsset * ch = self.player.currentItem.asset;
//        NSArray *asdf  =[ch tracks];
        AVAssetTrack * videoATrack = [[self.player.currentItem.asset tracksWithMediaType:AVMediaTypeVideo] lastObject];
        if(videoATrack)
        {
            fps = videoATrack.nominalFrameRate;
        }
    }
    return fps;
}



#pragma mark -
- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys
{
    /* Make sure that the value of each key has loaded successfully. */
    for (NSString *thisKey in requestedKeys)
    {
        NSError *error = nil;
        AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
        if (keyStatus == AVKeyValueStatusFailed)
        {
            [self assetFailedToPrepareForPlayback:error];
            return;
        }
        /* If you are also implementing -[AVAsset cancelLoading], add your code here to bail out properly in the case of cancellation. */
    }
    
    /* Use the AVAsset playable property to detect whether the asset can be played. */
    if (!asset.playable)
    {
        /* Generate an error describing the failure. */
        NSString *localizedDescription = NSLocalizedString(@"Item cannot be played", @"Item cannot be played description");
        NSString *localizedFailureReason = NSLocalizedString(@"The assets tracks were loaded, but could not be made playable.", @"Item cannot be played failure reason");
        NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   localizedDescription, NSLocalizedDescriptionKey,
                                   localizedFailureReason, NSLocalizedFailureReasonErrorKey,
                                   nil];
        NSError *assetCannotBePlayedError = [NSError errorWithDomain:@"StitchedStreamPlayer" code:0 userInfo:errorDict];
        
        /* Display the error to the user. */
        [self assetFailedToPrepareForPlayback:assetCannotBePlayedError];
        
        return;
    }
    
    /* At this point we're ready to set up for playback of the asset. */
    
    /* Stop observing our prior AVPlayerItem, if we have one. */
    if (self.playerItem)
    {
        /* Remove existing player item key value observers and notifications. */
        
        [self.playerItem removeObserver:self forKeyPath:@"status"];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:self.playerItem];
    }
    
    /* Create a new instance of AVPlayerItem from the now successfully loaded AVAsset. */
    self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
   

    
    /* Observe the player item "status" key to determine when it is ready to play. */
    [self.playerItem addObserver:self
                       forKeyPath:@"status"
                          options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                          context:&ViewControllerStatusObservationContext];
    
    /* When the player item has played to its end time we'll toggle
     the movie controller Pause button to be the Play button */
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(playerItemDidReachEnd:)
//                                                 name:AVPlayerItemDidPlayToEndTimeNotification
//                                               object:self.playerItem];
    
    //Why????????????????????????No?????????
    seekToZeroBeforePlay = NO;
    
    /* Create new player, if we don't already have one. */
    if (!self.avPlayer)
    {
        /* Get a new AVPlayer initialized to play the specified player item. */
        [self setPlayer:[AVPlayer playerWithPlayerItem:self.playerItem]];
        
        
        [self.playBackView setPlayer:self.avPlayer];
        
        /* Observe the AVPlayer "currentItem" property to find out when any
         AVPlayer replaceCurrentItemWithPlayerItem: replacement will/did
         occur.*/
        [self.avPlayer addObserver:self
                      forKeyPath:@"currentItem"
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:ViewControllerCurrentItemObservationContext];
        
        /* Observe the AVPlayer "rate" property to update the scrubber control. */
        [self.avPlayer addObserver:self
                      forKeyPath:@"rate"
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:ViewControllerRateObservationContext];
    }
    
    /* Make our new AVPlayerItem the AVPlayer's current item. */
    if (self.avPlayer.currentItem != self.playerItem)
    {
        /* Replace the player item with a new player item. The item replacement occurs
         asynchronously; observe the currentItem property to find out when the
         replacement will/did occur
         
         If needed, configure player item here (example: adding outputs, setting text style rules,
         selecting media options) before associating it with a player
         */
        [self.avPlayer replaceCurrentItemWithPlayerItem:self.playerItem];
  
//        [self syncPlayPauseButtons];
    }
    
//    [self.mScrubber setValue:0.0];

    _status = _status | RJLPS_Play;

    if (onFeedReadyBlock) {
        onFeedReadyBlock();
    }// if there is a place to seek to when ready
    
}

-(void)assetFailedToPrepareForPlayback:(NSError *)error
{
    [self removePlayerTimeObserver];
//    [self syncControlBar];
//    [self disableScrubber];
//    [self disablePlayerButtons];
//    
    /* Display the error. */
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                        message:[error localizedFailureReason]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

//translate seconds to hh:mm:ss format
-(NSString*)translateTimeFormat:(float)time{
    NSUInteger dTotalSeconds = fabsf(time);
    NSUInteger dHours = floor(dTotalSeconds / 3600);
    NSUInteger dMinutes = floor(dTotalSeconds % 3600 / 60);
    NSUInteger dSeconds = floor(dTotalSeconds % 3600 % 60);
    NSString *displayTime;
    if (time < 0) {
        if (dHours > 0) {
            displayTime = [NSString stringWithFormat:@"-%i:%02i:%02i",dHours, dMinutes, dSeconds];
        }else{
            displayTime = [NSString stringWithFormat:@"-%02i:%02i", dMinutes, dSeconds];
        }
    }else{
        if (dHours > 0) {
            displayTime = [NSString stringWithFormat:@"%i:%02i:%02i",dHours, dMinutes, dSeconds];
        }else{
            displayTime = [NSString stringWithFormat:@"%02i:%02i", dMinutes, dSeconds];
        }
    }
    return displayTime;
}

-(Float64)durationInSeconds{
    AVPlayerItem* currentItem = self.avPlayer.currentItem;
    NSArray* seekableRanges = currentItem.seekableTimeRanges;
    
    Float64 duration = 0;
    
    CMTime itemDuration = kCMTimeInvalid;
    itemDuration = [self.playerItem duration];
    itemDuration = [[self.playerItem asset] duration];
    
  if ([seekableRanges count] > 0)
   {
        CMTimeRange tempRange = [[seekableRanges objectAtIndex:0] CMTimeRangeValue];
        duration = CMTimeGetSeconds(tempRange.duration) + CMTimeGetSeconds(tempRange.start);
   }
    
    if (isnan(duration)) {
        duration = 0;
    }
    return duration;
}

-(Float64)currentTimeInSeconds{
    Float64 returnTime = [self.avPlayer currentTime].value / [self.avPlayer currentTime].timescale;
    return returnTime;
}


-(float)seekClamp:(float)seekTime
{
    AVPlayerItem    * currentItem       = self.avPlayer.currentItem;
    NSArray         * seekableRanges    = currentItem.seekableTimeRanges;
    
    
    Float64         duration = 0;
//    float           _seekTime;
    
    if ([seekableRanges count] > 0)
    {
        CMTimeRange tempRange = [[seekableRanges objectAtIndex:0] CMTimeRangeValue];
        duration = CMTimeGetSeconds(tempRange.duration) + CMTimeGetSeconds(tempRange.start);
    }
    
    if (isnan(duration)) {

        return 0;
    } else if (seekTime < duration && seekTime >= 0) {
        return seekTime;
    } else if (seekTime > duration) {
        return duration;
    }
    
    
    
    
    return duration;



}


-(CMTime)playerItemDuration
{
    AVPlayerItem *playerItem = self.playerItem;
    if (playerItem.status == AVPlayerItemStatusReadyToPlay)
    {
        NSArray* seekableRanges = playerItem.seekableTimeRanges;
        if ([seekableRanges count] > 0)
        {
            CMTimeRange srange = [[seekableRanges objectAtIndex:0] CMTimeRangeValue];
            return srange.duration;
        }
    }
    return(kCMTimeInvalid);
}


-(CMTime)precisionOfScrub:(float)val
{
    if (val == 0.5f){
        return CMTimeMake(2, NSEC_PER_SEC);
    } else if (val == .25f) {
        return CMTimeMake(1, NSEC_PER_SEC);
    } else if (val <= 0.25f) { // most accurate
        return kCMTimeZero;
    } else /* anything goes */ {
        return kCMTimePositiveInfinity;
    }

}


-(void)onFreeze
{

    
//    if ( !(_status & RJLPS_Thawing) && !(_status & RJLPS_Scrubbing) && ((_status & RJLPS_Play)||(_status & RJLPS_Live)) ) {
//            [_playerItem cancelPendingSeeks];
//            __weak RJLVideoPlayer       * weakSelf      = self;
//            __block RJLFreezeCounter    * weakCounter   = freezeCounter;
//            weakSelf.status = weakSelf.status  | RJLPS_Thawing;
//            double roundedLastTime;// = round (lastSeekTime--);//(round (lastSeekTime * 1000.0) / 1000.0)-1;
//            double noise = 1 + freezeCounter.freezeCounter;//(-1 + (random()*2));
//            roundedLastTime = (videoControlBar.timeSlider.value + noise <= 0)?0:videoControlBar.timeSlider.value + noise;
//            [self.avPlayer seekToTime:CMTimeMakeWithSeconds(roundedLastTime, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
////               dispatch_async(dispatch_get_main_queue(), ^{
//                    if (finished) {
//                        NSLog(@"FreezeSeek FINISHED");
//                        
//                    } else {
//                        NSLog(@"FreezeSeek CANCELLED");
//                    }
//                    weakSelf.status = weakSelf.status & ~(RJLPS_Thawing);
//                    [weakCounter reset];
////                });
//            }];
//    }
//    
//    [freezeCounter reset];
}



-(void)dealloc
{
    self.isAlive = NO;
}

-(NSString*)statusString
{
    NSMutableString * txt = [NSMutableString stringWithFormat:@""];
    if ((_status & RJLPS_Offline) !=0 ) {
        [txt appendString:@" Offline "];
    }
    if ((_status & RJLPS_Live) !=0 ) {
        [txt appendString:@" Live "];
    }
    
    if ((_status & RJLPS_Play) !=0 ) {
        [txt appendString:@" Play "];
    }
    
    if ((_status & RJLPS_Stop) !=0 ) {
        [txt appendString:@" Stop "];
    }
    
    if ((_status & RJLPS_Paused) !=0 ) {
        [txt appendString:@" Paused "];
    }
    
    if ((_status & RJLPS_Seeking) !=0 ) {
        [txt appendString:@" Seeking "];
    }
    
    if ((_status & RJLPS_Scrubbing) !=0 ) {
        [txt appendString:@" Scrubbing "];
    }
    
    if ((_status & RJLPS_Slomo) !=0 ) {
        [txt appendString:@" Slomo "];
    }
    
    if ((_status & RJLPS_Error) !=0 ) {
        [txt appendString:@" Error "];
    }
    
    if ((_status & RJLPS_Mute) !=0 ) {
        [txt appendString:@" Mute "];
    }
    
    if ((_status & RJLPS_Thawing) !=0 ) {
        [txt appendString:@" Thawing "];
    }
    
    if ((_status & RJLPS_Looping) !=0 ) {
        [txt appendString:@" Looping "];
    }
    return [NSString stringWithString: txt];
    
}

-(NSString*)description
{
    NSMutableString * txt = [NSMutableString stringWithFormat:@"RJLPlayer - Feed: %@\n ",_feed.path];
    [txt appendFormat:@"Rate: %f\n",_avPlayer.rate];
    [txt appendString:@"Status: "];
    [txt appendString:[self statusString]];
    
    
    return [NSString stringWithString: txt];


    
}

@end
