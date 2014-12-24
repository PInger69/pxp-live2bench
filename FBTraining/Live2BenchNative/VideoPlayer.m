//
//  VideoPlayer.m
//  Live2BenchNative
//
//  Created by DEV on 4/8/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "VideoPlayer.h"

#import "SDWebImage/UIImageView+WebCache.h"

#define SLIDER_HEIGHT       30
#define BUTTON_HEIGHT       40
#define LABEL_WIDTH         60
#define CONTROL_BAR_HEIGHT  44
#define REFRESH_INTERVAL    0.5

#import "VideoPlayerFreezeTimer.h"
static void * feedContext  = &feedContext;

@interface VideoPlayer ()

@end

@implementation VideoPlayer{
    
    Globals                     * globals;
    UIPinchGestureRecognizer    * pinchGesture;         //pinch gesture: pinch to zoom video view to fullscreen view or back to normal view
    AVPlayerItem                * playerItem;

    CGRect                      smallFrame;             //frame size for normal view view
    id                          itemEndObserver;
    int                         noSeekableRangesCount;  //if the loadedrange start time is 0 and no seekable ranges available,this value will increase; When the value increases to 20(after 10sec), reset avplayer
    int                         resetPlayerCounter;     //this value used to track how many times the videoplayer has been reset
    BOOL                        seeking;                //this value is TRUE if avplayer hasnot finished seek to the required time
    BOOL                        isReseeking;
    BOOL                        _live;
    BOOL                        _isSeeking;
    BOOL                        _wasPlayBeforeSeek;
    playerStatus                _currentStatus;
    UILabel                     * statusLabel;
    
   
}

@synthesize avPlayer;
@synthesize videoURL;
@synthesize playerLayer;
@synthesize timeObserver;
@synthesize duration;
@synthesize isFullScreen;
@synthesize playerFrame;
@synthesize checkSeekTimer;
@synthesize startTime;
@synthesize teleBigView;
@synthesize richVideoControlBar;
@synthesize feed = _feed;
@synthesize context = _context;
@synthesize liveIndicatorLight = _liveIndicatorLight;
@synthesize rate    = _rate;
/**
 *  initialize video player with the given frame as well at build the playerLayer, added the control slider and sets the guestures.
 *
 *  @param frame Video player frame size
 */
-(void)initializeVideoPlayerWithFrame:(CGRect)frame
{
    _currentStatus              = PS_Offline;
    _wasPlayBeforeSeek          = NO;
    smallFrame                  = frame;     //this frame used to resize video view when it is back from fullscreen view
    playerFrame                 = frame;

    playerLayer                 = [AVPlayerLayer playerLayerWithPlayer:avPlayer];
    playerLayer.frame           = CGRectMake(0, 0, playerFrame.size.width, playerFrame.size.height);
    playerLayer.videoGravity    = AVLayerVideoGravityResizeAspect;     //set video gravity; AVLayerVideoGravityResizeAspect: will scale the video with the player layer's bounds in order to preserve the video's original aspect ratio;
    playerLayer.backgroundColor = [UIColor blackColor].CGColor;     //set he player layer's background colour to black; when there is no video playing, it will give user the black screen
    [self.view.layer addSublayer:playerLayer];     //add play layer to the view's layer
    
    self.richVideoControlBar          = [self buildVideoControlBar:frame];
    [self.view addSubview:self.richVideoControlBar];
    
    
    //add pinch gesture to the view for switch between fullscreen and normal screen
    pinchGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinchGuesture:)];
    [self.view addGestureRecognizer:pinchGesture];
    
    //add single tap to the view for showing or hiding video control bar
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSingleTapGesture:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:singleTap];
    
    //add double tap to the view for change video display aspect ratio
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleDoubleTapGesture:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:doubleTap];
    
    statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 100, 20)];
    statusLabel.text = @"Offline";

    statusLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:statusLabel];
    
    // this is so we know what Video Player belongs to what
    _context = @"";
    
    _rate = 0;
    _liveIndicatorLight =  [[LiveIndicatorLight alloc]initWithFrame:CGRectMake(playerFrame.size.width-32, 0, 32, 32)];
    
    [self.view addSubview:_liveIndicatorLight];

}


/**
 *  This builds the slider for the video player. This is just to keep the code clean and readable
 *
 *  @param frame video frame size for reference
 *
 *  @return instance of VideoControlBarSlider
 */
-(VideoControlBarSlider *)buildVideoControlBar:(CGRect)frame
{
    VideoControlBarSlider * vcb = [[VideoControlBarSlider alloc]initWithFrame:frame];

    [vcb.timeSlider addTarget:self action:@selector(sliderValueChanged)
         forControlEvents:UIControlEventValueChanged];
    
    [vcb.timeSlider addTarget:self action:@selector(scrubbingStart)
         forControlEvents:UIControlEventTouchDown];
    
    [vcb.timeSlider addTarget:self action:@selector(scrubbingEnd)
         forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchDownRepeat|UIControlEventTouchCancel];


    [vcb.playButton addTarget:self action:@selector(playVideo)
             forControlEvents:UIControlEventTouchUpInside];
    
    vcb.hidden = TRUE;
    return vcb;
}


-(void)setPlayerWithURL:(NSURL*)url
{
 
    videoURL    = url;
    
    if (playerItem !=nil){
        @try {
                    [playerItem removeObserver:self forKeyPath:@"status"];
        }
        @catch (NSException *exception) {}
    }
    
    
    playerItem  = [[AVPlayerItem alloc] initWithURL:videoURL];
    avPlayer    = [AVPlayer playerWithPlayerItem:playerItem];
    
    //init globals TODO try and remove these
    if(!globals)
    {
        globals=[Globals instance];
        //used to detect the event when current playing event name changed
        [globals addObserver:self forKeyPath:@"EVENT_NAME" options:0 context:nil];
    }
    
    
    if (self == globals.VIDEO_PLAYER_LIVE2BENCH || self == globals.VIDEO_PLAYER_LIST_VIEW) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"setvideourl" object:nil];
    }
    //if no event playing, donot set the avplayer
    if (!globals.CURRENT_PLAYBACK_EVENT ) {
        return;
    }
    
    //link player layer with avplayer
    [playerLayer setPlayer:avPlayer];
    //add observer for player item to check the playback status
    [avPlayer.currentItem addObserver:self forKeyPath:@"status" options:0 context:nil];
    
    //add observer for updating current time, duration, slider position
    [self addPlayerItemTimeObserver];
    //add observer for detecting event playback completes
    [self addItemEndObserverForPlayerItem];
    //TODO: make sure live event go to live, past event start with 0
    
    //init duration
    duration = 0;
    
    [self play];
    
    _antiFreeze = [[VideoPlayerFreezeTimer alloc]initWithVideoPlayer:self];

}



//this method will be called when video playback complete event is detected
-(void)playerItemDidReachEnd
{
    if ([globals.CURRENT_PLAYBACK_EVENT isEqualToString:@""]) {
        return;
    }

    if (globals.IS_IN_BOOKMARK_VIEW && self == globals.VIDEO_PLAYER_BOOKMARK) {
        //if the video player is in bookmark view, seek back to time zero, replay the video
        
        //if the user is not drawing telestration,continue playing, else pause the video
        if (!globals.IS_TELE) {
            [self play];
        }else{
            [self pause];
        }
        
        //make sure the video palyers in live2bench view and list view are paused
        [globals.VIDEO_PLAYER_LIST_VIEW pause];
        [globals.VIDEO_PLAYER_LIVE2BENCH pause];
    }else if ((self == globals.VIDEO_PLAYER_LIST_VIEW || self == globals.VIDEO_PLAYER_LIVE2BENCH )&& ![globals.EVENT_NAME isEqualToString: @"live"])
    {
        //if current event is not live event and is in list view or live2bench view, pause the video
        [self pause];
    }

}



// CLEAN THIS UP NOW!!!!!
//while the video is playing, we need to update the time labels and time slider position
-(void)updateVideoControlBar
{
    //get the current seekable duration
    duration = [self durationInSeconds];
    if (isfinite(duration) && (duration > 0) && !self.live)
    {
        //slider's current value is set to current time
        double currentTime = self.currentTimeInSeconds;
        [self.self.richVideoControlBar.timeSlider setValue:currentTime];
        [self.self.richVideoControlBar.leftTimeLabel setText:[NSString stringWithFormat:@"%@",[self translateTimeFormat:self.self.richVideoControlBar.timeSlider.value]]];
        //slider's max value is set to the seekable duration
        self.richVideoControlBar.timeSlider.maximumValue = duration;
    }
    
    //get current time
    float currentTime = self.currentTimeInSeconds;
    
    if (self.live) {
        if (duration - currentTime > 1 ){
            [avPlayer.currentItem cancelPendingSeeks];
            [self seekToTheTime:(duration +1)];
        }
       
    }
    
     [self.richVideoControlBar.leftTimeLabel setText:[NSString stringWithFormat:@"%@",[self translateTimeFormat:self.currentTimeInSeconds]]];

    //NSLog(@"current time %f, duration %f",currentTime,duration);
    if (duration - currentTime < 1 && (self == globals.VIDEO_PLAYER_LIVE2BENCH || self == globals.VIDEO_PLAYER_LIST_VIEW) && [globals.EVENT_NAME isEqualToString:@"live"])
    {
        //if current event is live event
        //if the difference between current time and the seekable duration is smaller than 5 secs, set the right time label to @"live"
//        [rightTimeLabel setText:@"live"];
        [self.richVideoControlBar.rightTimeLabel setText:@"live"];
    }else{
        if ((currentTime > duration || currentTime == duration) && ![globals.EVENT_NAME isEqualToString:@"live"]) {
//             [rightTimeLabel setText:@"00:00"];
             [self.richVideoControlBar.rightTimeLabel setText:@"00:00"];
        }else{
            //set the right time label text to the value : [self currentTimeInSeconds] - duration
//            [rightTimeLabel setText:[self translateTimeFormat:currentTime - duration]];
            [self.richVideoControlBar.rightTimeLabel setText:[self translateTimeFormat:currentTime - duration]];

           
        }
        
    }

    
   
    
}





#pragma mark - Scrubbing Controls
-(void)scrubbingStart{
    //if the video is not playing properly, just return
    if(avPlayer.status != AVPlayerStatusReadyToPlay)
    {
        return;
    }
    

    self.live   = NO;   //Any scrubbing turns off live
    
    // remembers player play or pause after scrubbing
    if (self.status == PS_Play){
        _wasPlayBeforeSeek = YES;
    } else if (self.status == PS_Paused) {
        _wasPlayBeforeSeek = NO;
    }
    

    

    
    
    
    seeking     = FALSE;
    isReseeking = FALSE;
    if (checkSeekTimer) {
        [checkSeekTimer invalidate];
        checkSeekTimer = nil;
    }
   
    //pause the video, otherwise the slider will randomly jump back and forward
    [self pause];
    
    [avPlayer removeTimeObserver:timeObserver];
    
    //if was looping tag, post notification to "destroy" loop  mode
    if (globals.IS_LOOP_MODE) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"scrubbingDestroyLoopMode" object:nil];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"StopUpdate" object:nil];
    globals.IS_TELE=FALSE;
    if (!globals.IS_IN_BOOKMARK_VIEW && !globals.IS_IN_LIST_VIEW) {
        globals.DID_GO_TO_LIVE = FALSE;
    }
    

    self.status = PS_Seeking;
}

/**
 *  This is used when ever a slider has slid.
 *  This also runs once before "scrubbingStart" is run
 */
-(void)sliderValueChanged {
    //return if video is not playing properly
    if (avPlayer.currentItem.status != AVPlayerItemStatusReadyToPlay) {
        return;
    }


    if (self.richVideoControlBar.timeSlider.value <= 0)  self.richVideoControlBar.timeSlider.value = 0.1;
    
    if(seeking){
        return;  //return to wait until the avplayer finish seeking to the right time
    }
    seeking = TRUE;
    
    //fix the problem:moving the slider, there is long time delay for the avplayer to seek to the right time

    float sliderValue = lroundf(self.richVideoControlBar.timeSlider.value);
    CMTime ttttt = CMTimeMakeWithSeconds(sliderValue, 1);
    //self.richVideoControlBar.timeSlider.value, NSEC_PER_SEC
    [avPlayer seekToTime:ttttt  completionHandler:^(BOOL finished) {
         dispatch_async(dispatch_get_main_queue(), ^{
             seeking = FALSE;
             
             // this update the slider bar times
        //     NSLog(@"Completed Seek to: %@",[NSString stringWithFormat:@"%@",[self translateTimeFormat:self.richVideoControlBar.timeSlider.value]]);

         });
    }];
    [self.richVideoControlBar.leftTimeLabel setText:[NSString stringWithFormat:@"%@",[self translateTimeFormat:self.richVideoControlBar.timeSlider.value]]];
    [self.richVideoControlBar.rightTimeLabel setText:[self translateTimeFormat:self.currentTimeInSeconds - [self durationInSeconds]]];
}


/**
 *  This method is called when you stop scrubbing the slider
 */
-(void)scrubbingEnd{

    
    
    if(avPlayer.status != AVPlayerStatusReadyToPlay){
        return;
    }
    float scrubbingEndTime = self.richVideoControlBar.timeSlider.value;
    if (scrubbingEndTime < 0.1) {
        scrubbingEndTime = startTime;
    }
    //seek to the scrub end time
//    [self seekToTheTime:scrubbingEndTime];
    
//    if (checkSeekTimer) {
//        [checkSeekTimer invalidate];
//        checkSeekTimer = nil;
//    }
//    checkSeekTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(checkSeekingTimerCallback) userInfo:nil repeats:YES];
//    checkSeekTimer.accessibilityValue = [NSString stringWithFormat:@"%f",scrubbingEndTime];
//
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"RestartUpdate" object:nil];
//    
    [self addPlayerItemTimeObserver];
    
    if (_wasPlayBeforeSeek) {
        [self play];
        self.status = PS_Play;
    } else {
        self.status = PS_Paused;
    }
    
}


#pragma mark - Gesture

//The following three methods are gesture delegate methods which will be triggered when uigesture detected
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return TRUE;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return TRUE;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if (touch.view == self.view){
        return TRUE;
    }else{
        return FALSE;
    }
    
}
//this method will be triggered if user pinches the video view. Based on the pinch velocity, will enter full screen or back to normal screen
- (void)handlePinchGuesture:(UIGestureRecognizer *)recognizer{
    
    if((pinchGesture.velocity > 0.5 || pinchGesture.velocity < -0.5) && pinchGesture.numberOfTouches == 2){
        if (CGRectContainsPoint(self.view.bounds, [pinchGesture locationInView:self.view]))
        {
            /*
            if (pinchGesture.scale >1 && !isFullScreen) {
               [self enterFullscreen];
            }else if (pinchGesture.scale < 1 && isFullScreen){
               [self exitFullScreen];
            }
            */

            if (pinchGesture.scale >1) {
                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_FULLSCREEN object:self userInfo:@{@"context":_context,@"animated":[NSNumber numberWithBool:YES]}];
            }else if (pinchGesture.scale < 1){
                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SMALLSCREEN object:self userInfo:@{@"context":_context,@"animated":[NSNumber numberWithBool:YES]}];
            }
        }
    }
    
}


//this method will be called when user single taps the video view to show or hide video control bar
- (void)handleSingleTapGesture:(UIGestureRecognizer *)recognizer{
    
    if(self.richVideoControlBar.hidden == FALSE){
        //        videoConrolBar.hidden       = TRUE;
        self.richVideoControlBar.hidden   = TRUE;
        [self play];
    }else{
        //        videoConrolBar.hidden       = FALSE;
        self.richVideoControlBar.hidden   = FALSE;
        [self pause];
    }
    
}

//this method will be called when user double taps the video view to change video display ratio (4:3 or 16: 9)
//AVLayerVideoGravityResizeAspect: Preserve aspect ratio; fit within layer bounds.
//AVLayerVideoGravityResize: Stretch to fill layer bounds.
- (void)handleDoubleTapGesture:(UIGestureRecognizer *)recognizer{
    
    if (playerLayer.videoGravity == AVLayerVideoGravityResizeAspect) {
        playerLayer.videoGravity = AVLayerVideoGravityResize;
    }else if(playerLayer.videoGravity == AVLayerVideoGravityResize){
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    }
    
}

#pragma mark - Observers
//oberver to get avplayeritem's playback status
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if (context == feedContext)
    {
        [self onQualityChange:[[change objectForKey:@"new"]intValue]];
        return;
    }
    
    
    if ([object isKindOfClass:[Globals class]])
    {
        //if switch to different event, the event name will be changed
        if ([keyPath isEqualToString:@"EVENT_NAME"])
        {
            globals.SWITCH_TO_DIFFERENT_EVENT = TRUE;
            if ([globals.EVENT_NAME isEqualToString:@"live"])
            {
                //if the user is not drawing tele, continue play
                if (!globals.IS_TELE) {
                    [self play];
                    //seek to live for live event
                    [self goToLive];
                    
                }
                
            }
            //when switch to different event,remove local images from the old event to save space
            //BUT DONOT delete local images from downloaded event; Those images will be used for offline mode
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if (globals.THUMBNAILS_PATH && !globals.IS_LOCAL_PLAYBACK)
            {
                [fileManager removeItemAtPath:globals.THUMBNAILS_PATH error:NULL];
            }
            
        }
    }
    if ([object isKindOfClass:[AVPlayerItem class]])
    {
        AVPlayerItem *item = (AVPlayerItem *)object;
        
        if ([keyPath isEqualToString:@"status"])
        {
            switch(item.status)
            {//TODO
                case AVPlayerItemStatusFailed:
                    //play back failed; if there is event needs to play and video url was reset less than 20 times(more than 40 seconds), reset the video url
                    if (![videoURL isEqual:[NSURL URLWithString:@""] ] && ![globals.CURRENT_PLAYBACK_EVENT isEqualToString:@""]) {
                        if (resetPlayerCounter < 20) {
                            //reset video player with the event name string
                            videoURL = [NSURL URLWithString:globals.CURRENT_PLAYBACK_EVENT];
                            //reset avplayer after 2 seconds delay
                            [self performSelector:@selector(resetAvplayer) withObject:nil afterDelay:2];
                            
                            
                        }else{
                            
                            //if after reseting 10 times, still failed, set the current playback event to empty string and pop up the alter view
                            globals.CURRENT_PLAYBACK_EVENT = @"";
                            NSString *informStr = @"Video play back error. Please check the network condition and hardware connection.";//[NSString stringWithFormat:@"Poor signal. Please check the network condition. Current encoder status: %@, current event name: %@, current playing event: %@, current avplayer.currentItem.status: %@ error: %@",globals.CURRENT_ENC_STATUS,globals.EVENT_NAME,globals.CURRENT_PLAYBACK_EVENT,playerStatus,avPlayer.avPlayer.currentItem.error];
                            globals.VIDEO_PLAYBACK_FAILED = TRUE;
                            CustomAlertView *videoPlaybackFailedAlertView = [[CustomAlertView alloc]initWithTitle:@"myplayXplay" message:informStr delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                            [videoPlaybackFailedAlertView show];
                            //                            [globals.ARRAY_OF_POPUP_ALERT_VIEWS addObject:videoPlaybackFailedAlertView];
                            
                        }

                    }
                    break;
                case AVPlayerItemStatusReadyToPlay:
                    resetPlayerCounter = 0;
                    break;
                case AVPlayerItemStatusUnknown:
                    resetPlayerCounter = 0;
                    break;
            }
        }
        else if ([keyPath isEqualToString:@"playbackBufferEmpty"])
        {
            //            NSLog(@"empty");
        }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"])
        {
            
        }
    }
    
}


//method used to remove periodic time observer which will be called when video playback stopps or user navigates to other views
-(void)removePlayerItemTimeObserver{
    [avPlayer removeTimeObserver:timeObserver];
    timeObserver = nil;
}

//method used to add periodic time observer which is used to update current time, duration and slider value
- (void)addPlayerItemTimeObserver{
    //create 0.5 second refresh interval
    CMTime interval = CMTimeMakeWithSeconds(REFRESH_INTERVAL, NSEC_PER_SEC);
    //main dispatch queue; Use the main queue as you will typically use this type of notification to update the user interface on the main thread.
    dispatch_queue_t queue = dispatch_get_main_queue();
    //create callback block for time observer
    //have to use weak reference, otherwise will cause memory leak
    __weak VideoPlayer *weakSelf = self;
    void(^callback)(CMTime time) = ^(CMTime time){
        // NSLog(@"addPlayerItemTimeObserver time %lld",time.value);
        //update slider and duration
        [weakSelf updateVideoControlBar];
        
    };
    
    //add observer and store pointer for future use
    timeObserver = [avPlayer addPeriodicTimeObserverForInterval:interval queue:queue usingBlock:callback];
}

//add observer to detect the event that video playback complete
- (void)addItemEndObserverForPlayerItem{
    //notification name
    NSString *name = AVPlayerItemDidPlayToEndTimeNotification;
    //main dispatch queue
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    //create callback block for observer
    __weak VideoPlayer *weakSelf = self;
    void(^callback)(NSNotification *note) = ^(NSNotification *notification){
        if (avPlayer.currentItem.status == 1) {
            [weakSelf.avPlayer seekToTime:kCMTimeZero completionHandler:^(BOOL finished){
                [weakSelf playerItemDidReachEnd];
            }];
        }
        
    };
    //add observer and store observer for future use
    itemEndObserver = [[NSNotificationCenter defaultCenter] addObserverForName:name object: avPlayer.currentItem queue:queue usingBlock:callback];
}



#pragma mark -


int counter = 0;
-(void)checkSeekingTimerCallback{
    counter++;
    //NSLog(@"checkSeekingTimerCallback ＊＊＊＊＊＊ avPlayer.currentItem.status %d",avPlayer.currentItem.status);
    //if (counter > 0) {
        
        //avplayeritem cannot service a seek request with a completion handler until its status is AVPlayerItemStatusReadyToPlay;otherwise, the app will crash
        if (avPlayer.currentItem.status == AVPlayerItemStatusReadyToPlay) {
            [self seekToTheTime:[checkSeekTimer.accessibilityValue floatValue]];
        }
       
    //}
}
//for debugging
int seekAttempts = 0;
-(void)seekToTheTime:(float)seekTime{

    isReseeking = FALSE;
    //NSLog(@"seek");
//    [avPlayer.currentItem cancelPendingSeeks];
    if (counter > 0) { //gets here when the timer counter starts ticking - i.e. this is re-seeking
        //-------------------------------------
        //if seeking doesn't work the first time (since iOS7.1), need to try to re-seek.
        //however seeking to the same point does not always work, so we need to seek
        //to a slightly different time - hence the seekTimeMargin
        //-------------------------------------
        //generate a random margin for seeking around the desired point
        //the following line produces a number between -1 and 1:
        //arc4random()/0x100000000 produces a number between 0 and 1, so arc4dandom/0x100000000*2 (or arc4random/0x80000000)
        //will produce a number between 0 and 2, then offset it by -1 to give a resulting range of [-1,1]
        double seekTimeMargin = 1;//((double)arc4random()/0x80000000)-1;
        seekAttempts++;
        seekTime = seekTime - seekTimeMargin * seekAttempts;

        //the following two cases can happen due to the time margin
        if(seekTime<self.richVideoControlBar.timeSlider.minimumValue){ //make sure the time doesn't go below the starting time
            seekTime = self.richVideoControlBar.timeSlider.minimumValue;
        }
        if(seekTime>self.richVideoControlBar.timeSlider.maximumValue){ //same way, make sure scrubbing didn't go over the max possible time
            seekTime = self.richVideoControlBar.timeSlider.maximumValue;
        }
        counter = 0;
     
    }
    
    [avPlayer seekToTime:CMTimeMakeWithSeconds(seekTime, 600) completionHandler:^(BOOL finished) {
//        if (_rate > 0) {
//            [self play];
//        }
        if (isReseeking) {
           //NSLog(@"seeking finished");
            seekAttempts = 0;
            [checkSeekTimer invalidate];
            
            //if the play button set to pause or the user is drawing telestration, pause the video else continue playing
            if (    self.richVideoControlBar.playButton.selected || globals.IS_TELE) {
                [avPlayer pause];
            }else{
                [self play];
            }
            //update slider
            [self updateVideoControlBar];
            //set slider value to current time
            self.richVideoControlBar.timeSlider.value = [self currentTimeInSeconds];
        }else{
            //if the user is drawing telestration pause the video else continue playing
            if (globals.IS_TELE) {
                [self pause];
            }else{
                [self play];
            }
            
            //NSLog(@"seeking finished by canced!");
        }
        
        
    }];
    isReseeking = TRUE;

}


-(AVPlayerItem*)playerItem{
    return playerItem;
}



/**
 * this method will be call when press play button
 */
-(void)playVideo{
    
    BOOL isSelected = self.richVideoControlBar.playButton.selected ? FALSE: TRUE;
    self.richVideoControlBar.playButton.selected = isSelected;

    if (isSelected) {
        [self pause];
    }else{
        [self play];
        //if was viewing telestration, post nitification to "destroy" telestration mode and also set globals.IS_PLAYBACK_TELE, globals.IS_LOOP_MODE to be FALSE
        if (globals.IS_PLAYBACK_TELE) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_DESTROY_TELE object:nil];
            globals.IS_PLAYBACK_TELE = FALSE;
            globals.IS_LOOP_MODE = FALSE;
            globals.IS_TELE = FALSE;
        }
    }
}



//This method returns video's current duration in seconds
-(Float64)durationInSeconds{
    AVPlayerItem* currentItem = avPlayer.currentItem;
    NSArray* seekableRanges = currentItem.seekableTimeRanges;

    if (seekableRanges.count > 0)
    {
        noSeekableRangesCount = 0;
        CMTimeRange range = [[seekableRanges objectAtIndex:0] CMTimeRangeValue];
        //CMTime durationTime = range.duration;
        //start time of the video. Normally, this value is 0; BUT if the playback video is very looooong (ex: 20h), avplayer couldnot playback properly, this value will be negative.
        startTime = CMTimeGetSeconds(range.start);
        //seekable duration
        duration = CMTimeGetSeconds(range.duration) + startTime;
        //NSLog(@"starttime %f,duration %f,current time %f ",startTime,duration,self.currentTimeInSeconds);
    }

    //is duration is not valid, set it to zero
    if (isnan(duration)) {
        duration = 0;
    }
    return duration;

}

//pause video for buffering
-(void)prepareToPlay{
    [avPlayer setRate:_rate];
    [avPlayer pause];
}


//play video with the right playback rate
-(void)play{
   
    //if the globals playback speed is 0, set it to 1, then play the video with normal speed
    if (_rate == 0.0) {
        _rate = 1.0;
    }
    [avPlayer setRate:_rate];
    
    self.richVideoControlBar.playButton.selected = FALSE;

//    switch (avPlayer.currentItem.status) {
//        case AVPlayerStatusUnknown:
//            NSLog(@"AVPlayerStatusUnknown");
//            break;
//        case AVPlayerStatusReadyToPlay:
//            NSLog(@"AVPlayerStatusReadyToPlay");
//            break;
//        case AVPlayerStatusFailed:
//            NSLog(@"AVPlayerStatusFailed");
//            break;
//        default:
//            break;
//    }
     self.status = PS_Play;
}


//pause video control
-(void)pause{
    
    [avPlayer pause];
    self.richVideoControlBar.playButton.selected = TRUE;
    self.status = PS_Paused;
}


- (double) availableDuration
{
    NSArray *loadedTimeRanges = [[avPlayer currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [[loadedTimeRanges objectAtIndex:0] CMTimeRangeValue];
    Float64 startSeconds = CMTimeGetSeconds(timeRange.start);
    Float64 durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;
    return (double)result;
}


//force the video to go to live
-(void)goToLive{
    duration = [self durationInSeconds];
    if (avPlayer.currentItem.status == AVPlayerItemStatusReadyToPlay && duration > 0) {
        [avPlayer.currentItem cancelPendingSeeks];
        [self seekToTheTime:(duration +1)];
        [self play];
    }
    self.live = TRUE;
}



//This method returns video's current time in second
- (Float64)currentTimeInSeconds{
    //int32_t timeScale = self.avPlayer.currentTime.timescale;
    //globals.TIME_SCALE = timeScale;
    CMTime curTime = self.avPlayer.currentItem.currentTime;
    Float64 currentTime = CMTimeGetSeconds(curTime);
    return currentTime;

}

//this method will be called when user pinches video view to go to fullscreen
- (void)enterFullscreen{
    UIView *newParentView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    //if not fullscreen, enter fullscreen
    if((avPlayer.currentItem.status == AVPlayerItemStatusReadyToPlay && globals.EVENT_NAME) || (globals.IS_PLAYBACK_TELE && globals.IS_IN_BOOKMARK_VIEW))
    {
        [UIView animateWithDuration:.1 delay:0 options:nil animations: ^{
            
            isFullScreen = TRUE;
            //hide the toolbar while going to fullscreen
//            videoConrolBar.hidden = TRUE;
            self.richVideoControlBar.hidden = TRUE;
            playerFrame = newParentView.bounds;
            [self.view removeFromSuperview];
            
            if(globals.IS_PLAYBACK_TELE && (globals.IS_IN_LIST_VIEW || globals.IS_IN_BOOKMARK_VIEW))
            {
                //here we are going to overlay only the telestration onto the video
                
                [self pause];
                
                if(!self.teleBigView)
                {
                    self.teleBigView = [[UIImageView alloc] init];
                }
                
                if (globals.IS_IN_LIST_VIEW) {
                    
                    [self.teleBigView setFrame:CGRectMake(0, 20, playerFrame.size.width, 740)];
                    if ([[globals.CURRENT_PLAYBACK_TAG objectForKey:@"teleurl"] rangeOfString:@"http://"].location != NSNotFound) {
                        NSURL *teleUrl = [NSURL URLWithString:[globals.CURRENT_PLAYBACK_TAG objectForKey:@"teleurl"]];
                        [self.teleBigView setImageWithURL:teleUrl placeholderImage:[UIImage imageNamed:@"live.png"] options:nil completed: ^(UIImage *image, NSError *error, SDImageCacheType cacheType) {}];
                    }else{
                        UIImage *teleImage = [UIImage imageWithContentsOfFile:[globals.CURRENT_PLAYBACK_TAG objectForKey:@"teleurl"]];
                        [self.teleBigView setImage:teleImage];
                    }
                    
                }else{
                    [self.teleBigView setFrame:CGRectMake(0, 80, playerFrame.size.width, 576)];
                    // [self.teleBigView setFrame:CGRectMake(0, 0, playerFrame.size.width, playerFrame.size.height)];
                    NSString *teleFilePath;
                    teleFilePath = [globals.BOOKMARK_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"telestration_%@_%@.png",[globals.CURRENT_PLAYBACK_TAG objectForKey:@"event"],[globals.CURRENT_PLAYBACK_TAG objectForKey:@"id"]] ];
                    if (![[NSFileManager defaultManager] fileExistsAtPath:teleFilePath]) {
                        teleFilePath = [globals.BOOKMARK_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"telestration_%@_%@.jpg",[globals.CURRENT_PLAYBACK_TAG objectForKey:@"event"],[globals.CURRENT_PLAYBACK_TAG objectForKey:@"id"]] ];
                    }
                    
                    UIImage *teleImage = [UIImage imageWithContentsOfFile:teleFilePath];
                    [self.teleBigView setContentMode:UIViewContentModeScaleAspectFit];
                    [self.teleBigView setImage:teleImage];
                }
                
                [self.view addSubview:self.teleBigView];
                
                //hide the video player's tool bar
//                videoConrolBar.hidden = TRUE;
                self.richVideoControlBar.hidden = TRUE;
            }

            
        }completion:^ (BOOL finished){
            
            [UIView animateWithDuration:0 delay: 0 options:nil animations: ^{
                //reset playerview's and playerlayer's frame and bounds
                self.view.frame = playerFrame;
                self.view.bounds = playerFrame;
                playerLayer.frame = playerFrame;
                playerLayer.bounds = playerFrame;
                [self.view setFrame:playerFrame];
                [self.view setBounds:playerFrame];
                [newParentView addSubview:self.view];
                
            }completion:^ (BOOL finished){
                //resize toolbar for fullscreen
                self.richVideoControlBar.frame = CGRectMake(0.0f, playerFrame.size.height - 134.0f, playerFrame.size.width, 44.0f);
//
                [self.richVideoControlBar.timeSliderItem setWidth:playerFrame.size.width - 220];

                [[NSNotificationCenter defaultCenter] postNotificationName:@"Entering FullScreen" object:nil];
            }];
        }];
    }

}

//This is a test enterFullScreen

- (void)enterFullscreenOn:(UIView *)parentView{
    UIView *newParentView = parentView;

    //if not fullscreen, enter fullscreen
    //if((avPlayer.currentItem.status == AVPlayerItemStatusReadyToPlay && globals.EVENT_NAME) || (globals.IS_PLAYBACK_TELE && globals.IS_IN_BOOKMARK_VIEW)){
        [UIView animateWithDuration:.1 delay:0 options:nil animations: ^{
            
            isFullScreen = TRUE;
            //hide the toolbar while going to fullscreen
            //            videoConrolBar.hidden = TRUE;
            self.richVideoControlBar.hidden = TRUE;
            playerFrame = newParentView.bounds;
            [self.view removeFromSuperview];
            
            if(globals.IS_PLAYBACK_TELE && (globals.IS_IN_LIST_VIEW || globals.IS_IN_BOOKMARK_VIEW))
            {
                //here we are going to overlay only the telestration onto the video
                
                [self pause];
                
                if(!self.teleBigView)
                {
                    self.teleBigView = [[UIImageView alloc] init];
                }
                
                if (globals.IS_IN_LIST_VIEW) {
                    
                    [self.teleBigView setFrame:CGRectMake(0, 20, playerFrame.size.width, 740)];
                    if ([[globals.CURRENT_PLAYBACK_TAG objectForKey:@"teleurl"] rangeOfString:@"http://"].location != NSNotFound) {
                        NSURL *teleUrl = [NSURL URLWithString:[globals.CURRENT_PLAYBACK_TAG objectForKey:@"teleurl"]];
                        [self.teleBigView setImageWithURL:teleUrl placeholderImage:[UIImage imageNamed:@"live.png"] options:nil completed: ^(UIImage *image, NSError *error, SDImageCacheType cacheType) {}];
                    }else{
                        UIImage *teleImage = [UIImage imageWithContentsOfFile:[globals.CURRENT_PLAYBACK_TAG objectForKey:@"teleurl"]];
                        [self.teleBigView setImage:teleImage];
                    }
                    
                }else{
                    [self.teleBigView setFrame:CGRectMake(0, 80, playerFrame.size.width, 576)];
                    // [self.teleBigView setFrame:CGRectMake(0, 0, playerFrame.size.width, playerFrame.size.height)];
                    NSString *teleFilePath;
                    teleFilePath = [globals.BOOKMARK_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"telestration_%@_%@.png",[globals.CURRENT_PLAYBACK_TAG objectForKey:@"event"],[globals.CURRENT_PLAYBACK_TAG objectForKey:@"id"]] ];
                    if (![[NSFileManager defaultManager] fileExistsAtPath:teleFilePath]) {
                        teleFilePath = [globals.BOOKMARK_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"telestration_%@_%@.jpg",[globals.CURRENT_PLAYBACK_TAG objectForKey:@"event"],[globals.CURRENT_PLAYBACK_TAG objectForKey:@"id"]] ];
                    }
                    
                    UIImage *teleImage = [UIImage imageWithContentsOfFile:teleFilePath];
                    [self.teleBigView setContentMode:UIViewContentModeScaleAspectFit];
                    [self.teleBigView setImage:teleImage];
                }
                
                [self.view addSubview:self.teleBigView];
                
                //hide the video player's tool bar
                //                videoConrolBar.hidden = TRUE;
                self.richVideoControlBar.hidden = TRUE;
            }
            
            
        }completion:^ (BOOL finished){
            [UIView animateWithDuration:0 delay: 0 options:nil animations: ^{
                //reset playerview's and playerlayer's frame and bounds
                self.view.frame = playerFrame;
                self.view.bounds = playerFrame;
                playerLayer.frame = playerFrame;
                playerLayer.bounds = playerFrame;
                [self.view setFrame:playerFrame];
                [self.view setBounds:playerFrame];
                [newParentView addSubview:self.view];
                
            }completion:^ (BOOL finished){
                //resize toolbar for fullscreen
                self.richVideoControlBar.frame = CGRectMake(0.0f, playerFrame.size.height - 134.0f, playerFrame.size.width, 44.0f);

                [[NSNotificationCenter defaultCenter] postNotificationName:@"Entering FullScreen" object:nil];
            }];
        }];
    
    //}
    
}


//this method will be called when user pinches video view to go back to normal view
- (void)exitFullScreen{
    //if in fullscreen, exit fullscreen
  
    //remove the telestration layout
    if(self.teleBigView && globals.IS_IN_FIRST_VIEW){
        [self.teleBigView removeFromSuperview];
        self.teleBigView = nil;
    }
    if(!isFullScreen)
    {
        return;
    }
        isFullScreen        = FALSE;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Close Tele" object:nil];
//    videoConrolBar.hidden = TRUE;
    self.richVideoControlBar.hidden = TRUE;
    playerFrame = smallFrame;
    
    if(globals.IS_PLAYBACK_TELE && (globals.IS_IN_LIST_VIEW || globals.IS_IN_BOOKMARK_VIEW) && self.teleBigView)
    {
        [self.teleBigView setFrame:CGRectMake(0, -17, playerFrame.size.width, playerFrame.size.height+40)];
    }
    
    
    //self.view.frame = CGRectMake(0.0f, 0.0f, playerFrame.size.width, playerFrame.size.height);
    playerLayer.frame = CGRectMake(0.0f, 0.0f, playerFrame.size.width, playerFrame.size.height);
    self.view.frame = playerFrame;
    //self.view.bounds = currentFrame;
//    [timeSliderItem setWidth:playerFrame.size.width - 220];
//    videoConrolBar.frame = CGRectMake(0.0f, playerFrame.size.height - 44.0f, playerFrame.size.width, 44.0f);
    self.richVideoControlBar.frame = CGRectMake(0.0f, playerFrame.size.height - 44.0f, playerFrame.size.width, 44.0f);
    [self.richVideoControlBar.timeSliderItem setWidth:playerFrame.size.width - 220];
    [self.view removeFromSuperview];


    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PLAYER_EXITING_FULL_SCREEN object:nil];
    playerLayer.hidden  = false;

    
}

-(void)playTele{
    //here we are going to overlay only the telestration onto the video
    
    [self pause];
    
    if(!self.teleBigView)
    {
        self.teleBigView = [[UIImageView alloc] init];
    }
    
    if (globals.IS_IN_LIST_VIEW || globals.IS_IN_FIRST_VIEW) {
        
        [self.teleBigView setFrame:CGRectMake(0, 55, playerFrame.size.width, playerFrame.size.height)];
        [self.teleBigView setContentMode:UIViewContentModeScaleAspectFill];
        
        NSString *teleImageName = [[globals.CURRENT_PLAYBACK_TAG objectForKey:@"teleurl"] lastPathComponent];
        
        NSString *tUrl = [globals.THUMBNAILS_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",teleImageName]];
        
        [self.teleBigView setImage:[[UIImage alloc] initWithContentsOfFile:tUrl]];
        
        //                    if ([[globals.CURRENT_PLAYBACK_TAG objectForKey:@"teleurl"] rangeOfString:@"http://"].location != NSNotFound) {
        //                        NSURL *teleUrl = [NSURL URLWithString:[globals.CURRENT_PLAYBACK_TAG objectForKey:@"teleurl"]];
        //                        [self.teleBigView setImageWithURL:teleUrl placeholderImage:[UIImage imageNamed:@"live.png"] options:nil completed: ^(UIImage *image, NSError *error, SDImageCacheType cacheType) {}];
        //                    }else{
        //                        UIImage *teleImage = [UIImage imageWithContentsOfFile:[globals.CURRENT_PLAYBACK_TAG objectForKey:@"teleurl"]];
        //                        [self.teleBigView setImage:teleImage];
        //                    }
        
    }else{
        [self.teleBigView setFrame:CGRectMake(0, 80, playerFrame.size.width, 576)];
        // [self.teleBigView setFrame:CGRectMake(0, 0, playerFrame.size.width, playerFrame.size.height)];
        NSString *teleFilePath;
        teleFilePath = [globals.BOOKMARK_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"telestration_%@_%@.png",[globals.CURRENT_PLAYBACK_TAG objectForKey:@"event"],[globals.CURRENT_PLAYBACK_TAG objectForKey:@"id"]] ];
        if (![[NSFileManager defaultManager] fileExistsAtPath:teleFilePath]) {
            teleFilePath = [globals.BOOKMARK_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"telestration_%@_%@.jpg",[globals.CURRENT_PLAYBACK_TAG objectForKey:@"event"],[globals.CURRENT_PLAYBACK_TAG objectForKey:@"id"]] ];
        }
        
        UIImage *teleImage = [UIImage imageWithContentsOfFile:teleFilePath];
        [self.teleBigView setContentMode:UIViewContentModeScaleAspectFit];
        [self.teleBigView setImage:teleImage];
    }
    
    [self.view addSubview:self.teleBigView];
    
    //hide the video player's tool bar
    // videoConrolBar.hidden = TRUE;
    self.richVideoControlBar.hidden = TRUE;
}

//this method will be called if user swiped the video view with direction to the left, video will seek back X seconds. X is the value of secValue
-(void)seekBack: (float)secValue{
    [self seekBy:-secValue];
}


//this method will be called if user swiped the video view with direction to the right video will seek forward X seconds. X is the value of secValue
-(void)seekForward: (float)secValue
{
    [self seekBy:secValue];
    return;
}


//avplayer will seek to the required time and slider's value will be set to the the proper position
- (void)setTime:(Float64)timeInSeconds{
    if (timeInSeconds>[self durationInSeconds])
    {
        return;
    }
    if (!isnan(timeInSeconds)) {
        [avPlayer seekToTime: CMTimeMakeWithSeconds(timeInSeconds, NSEC_PER_SEC)];
    }
    
    // timeSlider.value = [self currentTimeInSeconds];
    self.richVideoControlBar.timeSlider.value = [self currentTimeInSeconds];
    
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


//if the video play back failed, reset the avplayer
-(void)resetAvplayer{
//    
//    //for testing
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"myplayXplay" message:[NSString stringWithFormat:@"reset video player in Video player; count: %d",resetPlayerCounter] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//    [alert show];
//    
    //resetPlayerCounter: used to record how many times the avplayer has been reset
    resetPlayerCounter++;
    //videoURL = vURL;
    [self setPlayerWithURL:videoURL];
    //if live event is playing currently and the encoder status  is also live, go to live after 5 seconds delay(in order to get the right duration)
    if ([globals.CURRENT_ENC_STATUS isEqualToString:encStateLive] && [globals.EVENT_NAME isEqualToString:@"live"]) {
        [self performSelector:@selector(goToLive) withObject:nil afterDelay:5];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 *  This will toggle Slowmo
 *
 *  @return if slow then TRUE if normal then false
 */
-(BOOL)toggleSlowmo
{
    
    BOOL isSlow = NO;
    
    // this will compensate for playRate
    if (_rate>=1.0) {
        _rate = 1;
    }else if (_rate<1) {
        _rate = .5;
    }
    
    _rate = (_rate==1.0f)?0.5f:1.0f;

    if (_rate ==1.0f) isSlow = YES;
    
    [self play];
    return isSlow;
}



/**
 *  This is a new method added to be used with the new seek buttons
 *
 *  @param secValue value in positive or negative
 */
-(void)seekBy:(float)secValue
{
    globals.IS_TELE=FALSE;
    self.live = NO;
    
    // this could be useless but its added to be inline with the other seeks
    if (!globals.IS_IN_BOOKMARK_VIEW && !globals.IS_IN_LIST_VIEW) {
        globals.DID_GO_TO_LIVE = FALSE;
    } else if (secValue < 0) {
        globals.DID_GO_TO_LIVE = FALSE;
    }
    
    Float64 currTime = CMTimeGetSeconds([self.avPlayer currentTime]);
    
    if (currTime + secValue > duration)
    {
        self.richVideoControlBar.timeSlider.value = duration;
        [avPlayer seekToTime:CMTimeMakeWithSeconds(duration, NSEC_PER_SEC)];
        return;
    } else if (currTime + secValue < 0)
    {
        self.richVideoControlBar.timeSlider.value = 0;
        [avPlayer seekToTime:kCMTimeZero];
        return;
    }
    self.richVideoControlBar.timeSlider.value = currTime +secValue;
    [avPlayer seekToTime:CMTimeMakeWithSeconds((currTime + secValue), NSEC_PER_SEC)];
}



/**
 *  This is to be used with seeker button class or anything that as a "speed" double propertie
 *
 *  @param sender seeker button
 */
-(void)seekWithSeekerButton:(id)sender
{
    double currentTime  = [self currentTimeInSeconds];
    double seekAmount = 0;
    if ([sender respondsToSelector:@selector(speed)]){
        seekAmount  = (double)[sender speed];
    } else {
        NSLog(@"\tSpeed Not found on sender");
        return;
    }
    
    if (globals.IS_LOOP_MODE){
        if(currentTime+seekAmount >= globals.HOME_END_TIME || currentTime+seekAmount <= globals.HOME_START_TIME-1.0) {
            [self setTime: globals.HOME_START_TIME];
        } else {
            [self seekBy:seekAmount];
        }
    } else {
        if (currentTime+seekAmount > self.duration) {
            [self goToLive];
        } else {
            [self seekBy:seekAmount];
        }
    }
    
    
}

// Debugging
-(BOOL)seekTo:(float)seekTime
{
    BOOL checkIfSeek = NO;
    if (avPlayer.status == AVPlayerStatusReadyToPlay){      
        
        [avPlayer seekToTime:CMTimeMakeWithSeconds(seekTime, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
        
        }];
        checkIfSeek = YES;
    }
    return checkIfSeek;
}

-(BOOL)isSlowmo
{
    BOOL isSlow = NO;
    
    // this will compensate for playRate
    if (_rate>1.0) {
        isSlow = NO;
        self.status = PS_Play;
    } else if (_rate < 1) {
        isSlow = YES;
        self.status = PS_Slomo;
    }

    return isSlow;
}


/**
 *  Getter for Live
 *
 *  @return is in live mode or not
 */
-(BOOL)live{
    return _live;
}


/**
 *  property for when you set it to live
 *
 *  @param live is it live Yes or No
 */
-(void)setLive:(BOOL)live
{
    _live = live;
    
    if (live){
        [_liveIndicatorLight setHidden:NO];
        [self.richVideoControlBar.rightTimeLabel setText:@"live"];
        self.richVideoControlBar.timeSlider.maximumValue = duration;
        self.richVideoControlBar.timeSlider.value =         self.richVideoControlBar.timeSlider.maximumValue;
        // Key the scrub bar at max and live will always say live
        // disable the update on the controll bar
        // maybe have a spooling icon if the video is more then 5 sec slow from max
        self.status = PS_Live;
    } else {
//        NSLog(@"not live");
        [_liveIndicatorLight setHidden:YES];
    }
}




// This will show what the hell the player is doing
-(void)setStatus:(playerStatus)status
{
    if (_currentStatus == status) return;
    
    [self willChangeValueForKey:@"status"];
    _currentStatus = status;
    [self didChangeValueForKey:@"status"];
    
    return;
    switch (status) {
        case PS_Offline:
            statusLabel.text = @"Offline";
            break;
        case PS_Live:
            statusLabel.text = @"Live";
            break;
        case PS_Play:
            statusLabel.text = @"Play";
            break;
        case PS_Paused:
            statusLabel.text = @"Paused";
            break;
        case PS_Seeking:
            statusLabel.text = @"Seeking";
            break;
        case PS_Slomo:
            statusLabel.text = @"Slomo";
            break;
        case PS_Error:
            statusLabel.text = @"Error play restart";
            break;
        case PS_Stop:
            statusLabel.text = @"player stopped";
            break;
        default:
            statusLabel.text = @"unknown";
            break;
    }
    

}

-(playerStatus)status
{
    
//    if (avPlayer.rate == 0.0f && _currentStatus !=PS_Paused)
//    {
//
//        _currentStatus = PS_Paused;
//
//    }
    
    return _currentStatus;
}



-(void)resetAVplayerLayer
{
    [playerLayer removeFromSuperlayer];
    playerLayer                 = [AVPlayerLayer playerLayerWithPlayer:avPlayer];
    playerLayer.frame           = CGRectMake(0, 0, playerFrame.size.width, playerFrame.size.height);
    playerLayer.videoGravity    = AVLayerVideoGravityResizeAspect;
    playerLayer.backgroundColor = [UIColor blackColor].CGColor;
    [self.view.layer insertSublayer:playerLayer atIndex:0];
  
}

#pragma mark - Feed Methods
///////////////////// NEW FEED METHODS //////////////////////////////////

-(void)setFeed:(Feed *)feed
{
    [self willChangeValueForKey:@"feed"];
    if (_feed){
        [_feed removeObserver:self forKeyPath:@"quality" context:feedContext];
    }
    _feed = feed;
    [_feed addObserver:self forKeyPath:@"quality" options:NSKeyValueObservingOptionNew context:feedContext];
    [self didChangeValueForKey:@"feed"];
//    [self setPlayerWithURL:[_feed path]];
}

-(void)onQualityChange:(int)quality
{
    float cTime = [self currentTimeInSeconds];
    [self setPlayerWithURL:[_feed path]];
    [self seekTo:cTime];
}


-(void)playFeed:(Feed*)feed
{
    self.feed = feed;

    
    if (playerItem !=nil){
        @try {
            [playerItem removeObserver:self forKeyPath:@"status"];
        }
        @catch (NSException *exception) {}
    }
    
    
    playerItem  = [[AVPlayerItem alloc] initWithURL:[feed path]];
    avPlayer    = [AVPlayer playerWithPlayerItem:playerItem];
    

    [playerLayer setPlayer:avPlayer];

    
   
    
    [avPlayer.currentItem addObserver:self forKeyPath:@"status" options:0 context:nil];
    
    [self addPlayerItemTimeObserver];
    [self addItemEndObserverForPlayerItem];
    [self play];
    _antiFreeze = [[VideoPlayerFreezeTimer alloc]initWithVideoPlayer:self];
 [avPlayer setRate:1];

}


///////////////////// END OF NEW FEED METHODS ///////////////////////////




@end
