//
//  RJLVideoPlayer.m
//  Live2BenchNative
//
//  Created by dev on 2015-01-28.
//  Copyright (c) 2015 DEV. All rights reserved.
//
#include <math.h>
#import "RJLVideoPlayer.h"
#import "RJLFreezeCounter.h"
#import "RJLVideoPlayerResponder.h"

#define LIVE_BUFFER     3
#define SLOWMO_SPEED    0.5f

@implementation RJLVideoPlayer
{
    float   restoreAfterScrubbingRate;
    id      timeObserver;

    RJLVideoPlayerResponder * commander;
    BOOL    isSeeking;
    NSURL   * mURL;
    int     seekAttempt;
    
    // Anti Freeze Prop
    RJLFreezeCounter * freezeCounter;
    double  lastSeekTime;

    // Looping Prop
    id                  loopingObserver;
    
    // block to run when ready
    void (^onReadyBlock)();
    
    UILabel * currentItemTime;
    CGRect videoFrame;

}
static void *ViewControllerRateObservationContext           = &ViewControllerRateObservationContext;
static void *ViewControllerStatusObservationContext         = &ViewControllerStatusObservationContext;
static void *ViewControllerCurrentItemObservationContext    = &ViewControllerCurrentItemObservationContext;
static void *FeedQualityChangeContext                       = &FeedQualityChangeContext;

static void *RJLVideoPlayerStatusChange                     = &RJLVideoPlayerStatusChange;

@synthesize status      = _status;
@synthesize looping     = _looping;
@synthesize feed        = _feed;
@synthesize mute        = _mute;

@synthesize liveIndicatorLight,playerContext,videoControlBar,playBackView,range;


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        _status         = RJLPS_Offline;
        
        // This listens to the app if it wants the player to do something
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationCommands:) name:NOTIF_COMMAND_VIDEO_PLAYER object:nil];
        [self addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:&RJLVideoPlayerStatusChange];
        freezeCounter   = [[RJLFreezeCounter alloc]initWithTarget:self selector:@selector(onFreeze) object:nil];
        
        commander = [[RJLVideoPlayerResponder alloc]initWithPlayer:self];
        videoFrame = frame;
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _status         = RJLPS_Offline;
        
        // This listens to the app if it wants the player to do something
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationCommands:) name:NOTIF_COMMAND_VIDEO_PLAYER object:nil];
        [self addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:&RJLVideoPlayerStatusChange];
        freezeCounter   = [[RJLFreezeCounter alloc]initWithTarget:self selector:@selector(onFreeze) object:nil];
        commander       = [[RJLVideoPlayerResponder alloc]initWithPlayer:self];
        videoFrame      = CGRectMake(500, 60, 400, 300);
    }
    return self;
}


-(void)viewDidLoad
{
    // every second, after 3 seconds fire if not reset
    [freezeCounter startTimer:1 max:3];
    
    self.playBackView           = [[RJLVideoPlayerPlaybackView alloc]initWithFrame:videoFrame];//CGRectMake(500, 60, 400, 300)
    self.view                   = self.playBackView;
    self.view.backgroundColor   = [UIColor blackColor];

    liveIndicatorLight          = [[LiveIndicatorLight alloc]init];
    liveIndicatorLight.frame    = CGRectMake(self.view.frame.size.width-30,0,10,10);

    id component                = [[VideoControlBarSlider alloc]initWithFrame:self.view.frame];
    
    videoControlBar             = component;
    
    [videoControlBar.timeSlider addTarget:self action:@selector(sliderValueChanged)
             forControlEvents:UIControlEventValueChanged];
    
    [videoControlBar.timeSlider addTarget:self action:@selector(scrubbingStart)
             forControlEvents:UIControlEventTouchDown];
    
    [videoControlBar.timeSlider addTarget:self action:@selector(scrubbingEnd)
             forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchDownRepeat|UIControlEventTouchCancel];
    
    
    [videoControlBar setupPlay:@selector(play) Pause:@selector(pause) target:self];
    
//    [videoControlBar.playButton addTarget:self action:@selector(play)
//             forControlEvents:UIControlEventTouchUpInside];

    videoControlBar.enable = NO;
    
//    videoControlBar.hidden = TRUE;
    [self initBarTimer];
    isSeeking = NO;
    

    seekAttempt = 0;
    [self.view addSubview:liveIndicatorLight];
    [self.view addSubview:videoControlBar];
    
    // debugging
    currentItemTime = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 30)];
    currentItemTime.textColor = [UIColor whiteColor];
    [self.view addSubview:currentItemTime];
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







/**
 *  This makes sure the bar matches the data at all time when a video is running
 */
- (void)syncControlBar
{
    CMTime playerDuration = [self playerItemDuration];
    
    
    float checkDuration = ( isnan(CMTimeGetSeconds(playerDuration)) )? 0 : CMTimeGetSeconds(playerDuration);


    self.videoControlBar.timeSlider.maximumValue = checkDuration;

    
    
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
         [self.videoControlBar.timeSlider setValue:time];

//        [self.videoControlBar.timeSlider setValue:(maxValue - minValue) * time / duration + minValue];
    }
    
    [self.videoControlBar.leftTimeLabel setText:[self translateTimeFormat:self.videoControlBar.timeSlider.value]];
    [self.videoControlBar.rightTimeLabel setText:[self translateTimeFormat:self.videoControlBar.timeSlider.value - [self durationInSeconds]]];
   
    if (_status & RJLPS_Live){
       [self.videoControlBar.rightTimeLabel setText:@"Live"];
    }
    
}






#pragma mark -
#pragma mark Control Bar Methods

-(void)sliderValueChanged {
    

    
    
    if (!isSeeking){
        isSeeking   = YES;
        self.status = _status | RJLPS_Seeking;
        self.status = _status & ~(RJLPS_Live);
        
        CMTime playerDuration = [self playerItemDuration];
        if (CMTIME_IS_INVALID(playerDuration)) {
            return;
        }
    
    
        double duration = CMTimeGetSeconds(playerDuration);
        if (isfinite(duration))
        {
            float minValue  = [self.videoControlBar.timeSlider minimumValue];
            float maxValue  = [self.videoControlBar.timeSlider maximumValue];
            float value     = [self.videoControlBar.timeSlider value];
            NSLog(@"SeekSPeed: %f",self.videoControlBar.timeSlider.scrubbingSpeed);
            NSLog(@"Seek Attempt: %i",++seekAttempt);
            double time     = duration * (value - minValue) / (maxValue - minValue);
            lastSeekTime    = time;
            __block RJLVideoPlayer      * weakSelf      = self;
            
            CMTime accuraccy = [self precisionOfScrub:self.videoControlBar.timeSlider.scrubbingSpeed];
            
            [self.avPlayer seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) toleranceBefore:accuraccy toleranceAfter:accuraccy completionHandler:^(BOOL finished) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (finished) {
                        isSeeking = NO;
                        weakSelf.status = weakSelf.status & ~(RJLPS_Seeking);
                    } else {
                        NSLog(@"Seek CANCELD");
                    }
                    NSLog(@"Seek Attempt COMPLETE: %i",seekAttempt);
                });
            }];
            
//            [self.avPlayer seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    
//                    if (finished) {
//                        isSeeking = NO;
//                         weakSelf.status = weakSelf.status & ~(RJLPS_Seeking);
//                    } else {
//                         NSLog(@"Seek CANCELD");
//                    }
//                    NSLog(@"Seek Attempt COMPLETE: %i",seekAttempt);
//                });
//            }];
        }
    
    
    }

    [self.videoControlBar.leftTimeLabel setText:[self translateTimeFormat:self.videoControlBar.timeSlider.value]];
    [self.videoControlBar.rightTimeLabel setText:[self translateTimeFormat:self.videoControlBar.timeSlider.value - [self durationInSeconds]]];
}

-(void)scrubbingStart{
    self.status = _status | RJLPS_Scrubbing ; //| RJLPS_Seeking
    
    restoreAfterScrubbingRate = [self.avPlayer rate];
    [self.avPlayer setRate:0.f];
    
    [self removePlayerTimeObserver];
}

-(void)scrubbingEnd{
    
    self.status = _status & ~(RJLPS_Scrubbing); // not scrubbing anymore

    if (!timeObserver)
    {
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
    
    if (restoreAfterScrubbingRate)
    {
        [self.avPlayer setRate:restoreAfterScrubbingRate];
        restoreAfterScrubbingRate = 0.f;
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
                 
                if ((_status & RJLPS_Scrubbing)==0 && (_status & RJLPS_Seeking)==0) [self initBarTimer];
                 

                 
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
    __block RJLFreezeCounter    * weakCounter   = freezeCounter;
    __block UILabel             * weakLabel     = currentItemTime;
    
    timeObserver = [self.avPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)
                                                               queue:NULL
                                                          usingBlock:^(CMTime time)
                    {
                        [weakSelf syncControlBar];
                        [weakCounter reset];
                        [weakLabel setText:[NSString stringWithFormat:@"%f",CMTimeGetSeconds([weakSelf.playerItem currentTime]) ]];
                        /**
                         *  Should add check life to keep up to date
                         */
                        if (weakSelf.status & RJLPS_Live){
                        
                            double duration = CMTimeGetSeconds([weakSelf playerItemDuration]);
                            double ctime    = CMTimeGetSeconds([weakSelf.playerItem currentTime]);
                            if (duration - ctime > LIVE_BUFFER){
                                [weakSelf seekToInSec:duration];
                            }
                        }
                        
                    }];

}


#pragma mark -
#pragma mark Commands


-(void)gotolive{
    self.status                                 = _status | RJLPS_Live;
    self.status                                 = _status & ~(RJLPS_Looping);
    self.looping    = NO;
    self.videoControlBar.timeSlider.value =         self.videoControlBar.timeSlider.maximumValue;
    [self play];
}

-(void)play{
    self.status                                 = _status | RJLPS_Play;
    [self.avPlayer play];
    [self.videoControlBar setHidden:NO];
    self.videoControlBar.playButton.selected    = FALSE;
    onReadyBlock                                = nil;
    __block RJLVideoPlayer  * weakSelf          = self;
    if (self.playerItem.status == AVPlayerItemStatusUnknown){ // This delays the seek if its not ready
        onReadyBlock = ^void(){
            [weakSelf play];
        };
    }
    
}

-(void)pause{
    [self.avPlayer pause];
    self.videoControlBar.playButton.selected    = TRUE;
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
    range = aRange;
    // range will be the tag times.... might have to make a new class for this
    [self playFeed:aFeed];
    [self seekToInSec:CMTimeGetSeconds(aRange.start)];
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

    self.status                             = _status | RJLPS_Seeking;
    onReadyBlock                               = nil;
    __block RJLVideoPlayer  * weakSelf      = self;
    
    
    
    if (self.playerItem.status == AVPlayerItemStatusUnknown){ // This delays the seek if its not ready
        onReadyBlock = ^void(){
            [weakSelf seekBy:seekTime];
        };
        return;
    }
    
    [self.avPlayer seekToTime:CMTimeMakeWithSeconds(seekTime, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (finished) {
                isSeeking = NO;
                weakSelf.status = weakSelf.status & ~(RJLPS_Seeking);
            } else {
                NSLog(@"seekToInSec: CANCELLED");
            }

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
    [self.avPlayer seekToTime:seekTime completionHandler:^(BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (finished) {
                isSeeking = NO;
                weakSelf.status = weakSelf.status & ~(RJLPS_Seeking);
            } else {
                NSLog(@"seekBy: CANCELLED");
            }

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
        
        loopingObserver = [self.avPlayer addBoundaryTimeObserverForTimes:times queue:NULL usingBlock:^{
            [weakRef seekToTime:startT];
        }];
    }
    
}

-(BOOL)slowmo
{
    return ([self.avPlayer rate] >= 1.0)? NO : YES;
}

-(void)setSlowmo:(BOOL)slowmo
{
    
    // this will compensate for playRate
    if ([self.avPlayer rate] > 1.0) {
        self.status = _status & ~(RJLPS_Slomo);

        [self.avPlayer setRate:1.0f];
    } else if ([self.avPlayer rate] < 1) {
        self.status = _status | RJLPS_Slomo;

        [self.avPlayer setRate:SLOWMO_SPEED];
    }


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
    }
    _feed = feed;
    [_feed addObserver:self forKeyPath:@"quality" options:NSKeyValueObservingOptionNew context:FeedQualityChangeContext];
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.playerItem];
    
    seekToZeroBeforePlay = NO;
    
    /* Create new player, if we don't already have one. */
    if (!self.avPlayer)
    {
        /* Get a new AVPlayer initialized to play the specified player item. */
        [self setPlayer:[AVPlayer playerWithPlayerItem:self.playerItem]];
        
        
        [playBackView setPlayer:self.avPlayer];
        
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
    if ( (_status & RJLPS_Seeking) && !(_status & RJLPS_Scrubbing) && ((_status & RJLPS_Play)||(_status & RJLPS_Live)) ) {
            [_playerItem cancelPendingSeeks];
            __weak RJLVideoPlayer       * weakSelf      = self;
            double roundedLastTime;// = round (lastSeekTime--);//(round (lastSeekTime * 1000.0) / 1000.0)-1;
            double noise = -1;//(-1 + (random()*2));
            roundedLastTime = (videoControlBar.timeSlider.value + noise <= 0)?0:videoControlBar.timeSlider.value + noise;
            [self.avPlayer seekToTime:CMTimeMakeWithSeconds(roundedLastTime, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (finished) {
                        isSeeking = NO;
                        weakSelf.status = weakSelf.status & ~(RJLPS_Seeking);
                    } else {
                        NSLog(@"FreezeSeek CANCELLED");
                    }
                    
                });
            }];
    }
}







@end
