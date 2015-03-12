//
//  Pip.m
//  Live2BenchNative
//
//  Created by dev on 10/10/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "Pip.h"
#import "Utility.h"



#define DESELECT_COLOR  [UIColor darkGrayColor]
#define SELECTED_COLOR   PRIMARY_APP_COLOR
@implementation Pip
{
    UITextView                     * debugLabel;
    NSDictionary                * _qualityFeeds;
    float                       _rate;
    BOOL                        isSeeking;
    void                        (^seekReady)();
    id                           loopingObserver;
    id                           timeObserver;
    CMTimeRange                 _range; // this is the range of the player.... used for looping

    
}
@synthesize avPlayerItem;
@synthesize avPlayer;
@synthesize avPlayerLayer;
@synthesize isDragAble;
@synthesize dragBounds;
@synthesize quality     = _quality;
@synthesize feed        = _feed;
@synthesize selected    = _selected;
@synthesize muted       = _muted;
@synthesize looping     = _looping;
@synthesize status      =_status;
@synthesize freezeCounter = _freezeCounter;

static void * pipContext = &pipContext;


#pragma mark -
#pragma mark Statics

+(void)swapPip:(Pip*)thisPip with:(Pip*)thatPip
{
    
    AVPlayer           * tempAvPlayer       = thisPip.avPlayer;
    AVPlayerLayer      * tempAvPlayerLayer  = thisPip.avPlayerLayer;
    AVPlayerItem       * tempAvPlayerItem   = thisPip.avPlayerItem;
    BOOL               tempMuted            = thisPip.muted;

    
    thisPip.avPlayer        = thatPip.avPlayer;
    thisPip.avPlayerLayer   = thatPip.avPlayerLayer;

    thisPip.avPlayerItem    = thatPip.avPlayerItem;
    thisPip.muted           = thatPip.muted;

    thatPip.avPlayer        = tempAvPlayer;
    thatPip.avPlayerLayer   = tempAvPlayerLayer;
    thatPip.avPlayerItem    = tempAvPlayerItem;
    thatPip.muted           = tempMuted;

    thisPip.avPlayerLayer.frame = CGRectMake(0,0,thisPip.frame.size.width,thisPip.frame.size.height);
    thatPip.avPlayerLayer.frame = CGRectMake(0,0,thatPip.frame.size.width,thatPip.frame.size.height);
    [thisPip.avPlayerLayer removeAllAnimations];
    [thatPip.avPlayerLayer removeAllAnimations];
    [thisPip.layer addSublayer:thisPip.avPlayerLayer];
    [thatPip.layer addSublayer:thatPip.avPlayerLayer];
}



#pragma mark -
#pragma mark Pip setup methods



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor blackColor]];
        self.layer.borderWidth  = 1;
        self.layer.borderColor  = [DESELECT_COLOR CGColor];
        self.isDragAble         = NO;
        avPlayer.muted          = NO;
        _rate                   = 1.0;
        _quality                = 0;
        debugLabel              = [[UITextView alloc]initWithFrame:CGRectMake(5, 5, frame.size.width-10, frame.size.height *.5)];
        debugLabel.textColor    = [UIColor whiteColor];
        _status                 = PIP_Offline;
    }
    return self;
}

#pragma mark -
#pragma mark Commands


-(void)playerURL:(NSURL *)url
{
    [self removePlayerTimeObserver];
    _feed          = [[Feed alloc]initWithURLString:  [url absoluteString]   quality:_quality];
    avPlayer        = nil;
    avPlayerItem    = [[AVPlayerItem alloc] initWithURL:[_feed path]];
    avPlayer        = [AVPlayer playerWithPlayerItem:avPlayerItem];
    avPlayer.muted  = _muted;
    if (avPlayerLayer)[avPlayerLayer removeFromSuperlayer];
    avPlayerLayer                 = [AVPlayerLayer playerLayerWithPlayer:avPlayer];
    avPlayerLayer.frame           = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
   [self.layer addSublayer:avPlayerLayer];
   [avPlayer setRate:1];
    [avPlayer play];
}

-(void)playWithFeed:(Feed*)aFeed
{
    
    [self prepareWithFeed:aFeed];
    [avPlayer setRate:_rate];
}

-(void)playWithFeed:(Feed*)feed withRange:(CMTimeRange)range
{
    _range = range;
    [self playWithFeed:feed];
}


-(void)prepareWithFeed:(Feed*)aFeed
{
        [self removePlayerTimeObserver];
    _feed = aFeed;
    _feed.quality   = _quality;
    NSURL * url     = [_feed path];
    avPlayer        = nil;
    avPlayerItem    = [[AVPlayerItem alloc] initWithURL:url];
    avPlayer        = [AVPlayer playerWithPlayerItem:avPlayerItem];
    avPlayer.muted  = _muted;
    if (avPlayerLayer)[avPlayerLayer removeFromSuperlayer];
    avPlayerLayer                 = [AVPlayerLayer playerLayerWithPlayer:avPlayer];
    avPlayerLayer.frame           = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self.layer addSublayer:avPlayerLayer];
    NSLog(avPlayer.muted?@"mute":@"sound");
    if (DEBUG_MODE) {
        [self addSubview:debugLabel];
        debugLabel.editable = NO;
        [debugLabel setBackgroundColor:[UIColor clearColor] ];

    }
}





-(NSURL *)urlOfCurrentlyPlayingInPlayer:(AVPlayerItem *)playerItem{
    // get current asset
    AVAsset *currentPlayerAsset = playerItem.asset;
    // make sure the current asset is an AVURLAsset
    if (![currentPlayerAsset isKindOfClass:AVURLAsset.class]) return nil;
    // return the NSURL
    return [(AVURLAsset *)currentPlayerAsset URL];
}




-(void)play
{
    [avPlayer setRate:_rate];
}

-(void)pause
{
    [avPlayer setRate:0.0];
}


static void * seekContext = &seekContext;
-(void)seekTo:(CMTime)time
{
    CMTime playerTime   = self.avPlayerItem.duration;
    int difference      = CMTimeCompare(time, playerTime);
    AVPlayer * avplyer  = avPlayer;
    avplyer.muted       = _muted;
    AVPlayerItem * avplyeritm  = avPlayerItem;
    __block Pip      * weakSelf      = self;
    weakSelf.status = weakSelf.status | PIP_Seeking;
    
    if (self.avPlayerItem.status != AVPlayerItemStatusReadyToPlay){
        
        [self.avPlayerItem addObserver:self forKeyPath:NSStringFromSelector(@selector(status)) options:NSKeyValueObservingOptionNew context:&seekContext];
        // MAKES BLOCK
        seekReady = ^void(){
            
            if (difference == 1 ){
                [weakSelf.avPlayer seekToTime:avplyeritm.duration];
            }
            
            //            [avplyer seekToTime:time];
            [weakSelf.avPlayer seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimePositiveInfinity completionHandler:^(BOOL finished) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (finished) {
                        NSLog(@"seekTo Finished");
                        weakSelf.status = weakSelf.status & ~(PIP_Seeking);
                    } else {
                        NSLog(@"seekTo CANCELLED");
                        weakSelf.status = weakSelf.status & ~(PIP_Seeking);
                    }
                    
                });
            }];
        };
    } else { // avplayer item is ready to play
        //        if (playerTime.value ==0)return;
        if (difference == 1 ){
            [avPlayer seekToTime:self.avPlayerItem.duration];
        }
        [avPlayer seekToTime:time completionHandler:^(BOOL finished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (finished) {
                        NSLog(@"seekTo Finished");
                    weakSelf.status = weakSelf.status & ~(PIP_Seeking);
                } else {
                    NSLog(@"seekTo CANCELLED");
                    weakSelf.status = weakSelf.status & ~(PIP_Seeking);
                }
                
            });
        }];
    }
}

-(void)playRate:(float)rate
{
    _rate = rate;
    [avPlayer setRate:_rate];
}




-(void)live
{
    AVPlayerItem* currentItem   = avPlayer.currentItem;
    NSArray* seekableRanges     = currentItem.seekableTimeRanges;
    seekReady                   = nil;
    CMTime time;
    
    if (seekableRanges.count > 0)
    {
        CMTimeRange range   = [[seekableRanges objectAtIndex:0] CMTimeRangeValue];
        CMTime startT       = range.start;
        CMTime endT         = CMTimeAdd(startT,range.duration);
        
        time                = endT;
        
    } else {
        
        time                = CMTimeMakeWithSeconds(0, NSEC_PER_SEC);
    }
    
    if (avPlayer.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        [avPlayer.currentItem cancelPendingSeeks];
        [self seekTo:time];
        [self play];
         self.status = _status | PIP_Live;
    } else {
        
        __block Pip      * weakSelf      = self;
        seekReady = ^void(){
            [weakSelf.avPlayer seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimePositiveInfinity completionHandler:^(BOOL finished) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (finished) {
                            NSLog(@"Live Seek Finishe");
                            weakSelf.status = weakSelf.status & ~(PIP_Seeking);
                        } else {
                            NSLog(@"Live Seek CANCELLED");
                            weakSelf.status = weakSelf.status & ~(PIP_Seeking);
                        }
    
                    });
            }];
        }; // SeekReady
            
            
    
    }//
    
    
}


#pragma mark -
#pragma mark Observers

- (void)observeValueForKeyPath:(NSString *)keyPath  ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &pipContext) {
        AVPlayer * ply = (AVPlayer *)object;
        if (ply.status == AVPlayerStatusReadyToPlay) {
            [object removeObserver:self forKeyPath:NSStringFromSelector(@selector(status))];
        }
    }
    
    if (context == &seekContext){
        AVPlayerItem * plyItm = (AVPlayerItem *)object;
        if (plyItm.status == AVPlayerStatusReadyToPlay) {
            [self.avPlayerItem removeObserver:self forKeyPath:NSStringFromSelector(@selector(status)) context:&seekContext];
           if(seekReady) seekReady();
            [self removePlayerTimeObserver];
            [self addPeriodicTimeObserver];
            
        }
    
    }
    

}

// Controls for the video

-(void)addPeriodicTimeObserver
{
    double                      interval            = 0.5f;
    __block UITextField        * weakLabel         = debugLabel;
//    __block AVPlayerItem        * weakPlayerItem    = avPlayerItem;
    __block RJLFreezeCounter    * weakCounter       = _freezeCounter;
    __block Pip                 * weakSelf          = self;
    timeObserver = [self.avPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)
                                                               queue:NULL
                                                          usingBlock:^(CMTime time)
                    {
                        if (weakCounter){
                             [weakCounter reset];
                        }
                        [weakLabel setText:[weakSelf description]];
                    }];
    
}

-(void)removePlayerTimeObserver
{
    if (timeObserver)
    {
        [self.avPlayer removeTimeObserver:timeObserver];
        timeObserver = nil;
    }
}




#pragma mark -
#pragma mark

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!isDragAble) return;

    UITouch *aTouch             = [touches anyObject];
    CGPoint location            = [aTouch locationInView:self];
    CGPoint previousLocation    = [aTouch previousLocationInView:self];
    self.frame                  = CGRectOffset(self.frame, (location.x - previousLocation.x), (location.y - previousLocation.y));
    
    if ( !CGRectIsEmpty(self.dragBounds) && !CGRectContainsRect(self.dragBounds,self.frame) ) { // if its has bounds AND is outside them
        CGRect difference       = CGRectUnion(self.dragBounds,self.frame);
        float xCorrection       = (difference.origin.x < self.dragBounds.origin.x)? (difference.origin.x - self.dragBounds.origin.x): (difference.size.width - self.dragBounds.size.width);
        float yCorrection       = (difference.origin.y < self.dragBounds.origin.y)? (difference.origin.y - self.dragBounds.origin.y): (difference.size.height - self.dragBounds.size.height);
        self.frame              = CGRectOffset(self.frame, -xCorrection,-yCorrection);
    }
}



-(CMTime)currentTimePosition
{

    return [avPlayer currentTime];
}

#pragma mark -
#pragma mark Getters and setters


-(PipStatus)status
{
    return _status;
}

-(void)setStatus:(PipStatus)status
{
    [self willChangeValueForKey:NSStringFromSelector(@selector(status))];
    _status = status;
    [self didChangeValueForKey:NSStringFromSelector(@selector(status))];
}



-(BOOL)muted{
    return _muted;
}

-(void)setMuted:(BOOL)muted
{
    _muted = muted;
    avPlayer.muted = _muted;
    self.status = (avPlayer.muted)? _status | PIP_Mute : _status & ~PIP_Mute;
}

-(BOOL)hasHighQuality
{
    return ([_qualityFeeds objectForKey:@"hq"] !=nil)? YES:NO;
}

-(BOOL)hasLowQuality
{
    return ([_qualityFeeds objectForKey:@"lq"] !=nil)? YES:NO;
}


-(int)quality
{
    return _quality;
}

-(void)setQuality:(int)aQuality
{
    if (aQuality == _quality) return;
    int correctedQuality;
    if (aQuality>1) correctedQuality =1;
    if (aQuality<0) correctedQuality =0;
    [self willChangeValueForKey:@"quality"];
    CMTime time = avPlayer.currentTime;
    if (aQuality == 1 && self.hasHighQuality){
        [self playerURL:[_qualityFeeds objectForKey:@"hq"]];
        
    } else if (aQuality == 0 && self.hasLowQuality){
        [self playerURL:[_qualityFeeds objectForKey:@"lq"]];
    }
    [self seekTo:time];
    _quality = aQuality;
    [self didChangeValueForKey:@"quality"];

}



-(void)setSelected:(BOOL)selected
{
    _selected = selected;
    if (_selected){
        self.status = _status | PIP_Selected;
        self.layer.borderColor  = [SELECTED_COLOR CGColor];
    } else {
        self.status = _status & ~PIP_Selected;
        self.layer.borderColor  = [DESELECT_COLOR CGColor];
    }
}

-(BOOL)selected
{
    return _selected;
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
        [avPlayer removeTimeObserver:loopingObserver];
        loopingObserver = nil;
        self.status     = _status & ~(PIP_Looping);
    }
    
    if (_looping) {
        self.status                 = _status | PIP_Looping;
        CMTime startT               = _range.start;
        CMTime endT                 = _range.duration;
        NSArray *times              = @[ [NSValue valueWithCMTime:endT ] ];
        __block AVPlayer *weakRef   = avPlayer;
        
        loopingObserver = [avPlayer addBoundaryTimeObserverForTimes:times queue:NULL usingBlock:^{
            [weakRef seekToTime:startT]; // maybe add seek param
        }];
    }
    
}


-(Feed*)feed
{
    return _feed;
}

-(void)setFeed:(Feed *)feed
{
    [self willChangeValueForKey:@"feed"];
//    if (_feed){
//        [_feed removeObserver:self forKeyPath:@"quality" context:FeedQualityChangeContext];
//    }
    _feed = feed;
//    [_feed addObserver:self forKeyPath:@"quality" options:NSKeyValueObservingOptionNew context:FeedQualityChangeContext];
    [self didChangeValueForKey:@"feed"];
}





-(Feed*)removeFeed
{
    Feed* cutFeed = self.feed;
    
    [self removePlayerTimeObserver];
    
    return cutFeed;
}

-(void)seekToTime:(CMTime)time completionHandler:(void(^)(BOOL finished) )block
{
    CMTime inRange = time;
    
    self.status = _status | PIP_Seeking;
    if ( CMTimeGetSeconds(time)>CMTimeGetSeconds(avPlayerItem.duration) ){
        inRange = avPlayerItem.duration;
    }
    __block Pip      * weakSelf      = self;
    [self.avPlayer seekToTime:inRange completionHandler:^(BOOL finished) {
        
        if (finished){
            weakSelf.status = _status & ~(PIP_Seeking);
        } else {
            weakSelf.status = _status & ~(PIP_Seeking);
        
        }
        block(finished);
    }];
}


-(void)clear
{

    [self removePlayerTimeObserver];
    self.looping        = NO;
    if (avPlayerLayer)[avPlayerLayer removeFromSuperlayer];
    _feed               = nil;
    debugLabel.text     = @"";
}


#pragma mark -
#pragma mark Checkers




-(void)dealloc
{
    [self.avPlayerItem removeObserver:self forKeyPath:NSStringFromSelector(@selector(status)) context:&seekContext];
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(status))];
}


-(NSString*)description
{

    NSString * txt =  [NSString stringWithFormat:@"%f  \nStatus: ",CMTimeGetSeconds(self.currentTimePosition) ];
    
    if (_status & PIP_Live){
       txt = [txt stringByAppendingString:@" LIVE "];
    }
    
    if (_status & PIP_Play){
       txt = [txt stringByAppendingString:@" PLAY "];
    }

    if (_status & PIP_Stop){
      txt =  [txt stringByAppendingString:@" STOP "];
    }

    if (_status & PIP_Paused){
      txt =  [txt stringByAppendingString:@" PAUSE "];
    }

    if (_status & PIP_Seeking){
      txt =  [txt stringByAppendingString:@" SEEK "];
    }

    if (_status & PIP_Scrubbing){
      txt =  [txt stringByAppendingString:@" SCRUB "];
    }
    
    return txt;
}



@end
