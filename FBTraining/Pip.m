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
    CMTime          seekToFromNewAVPlayerItem;
    UILabel         * debugLabel;
    float           _rate;
    NSDictionary    * _qualityFeeds;
    
    void (^seekReady)();
    
}
@synthesize avPlayerItem;
@synthesize avPlayer;
@synthesize avPlayerLayer;
@synthesize isDragAble;
@synthesize dragBounds;
@synthesize quality     = _quality;
@synthesize feed        = _feed;
@synthesize selected    = _selected;

+(void)swapPip:(Pip*)thisPip with:(Pip*)thatPip
{
    
    AVPlayer           * tempAvPlayer       = thisPip.avPlayer;
    AVPlayerLayer      * tempAvPlayerLayer  = thisPip.avPlayerLayer;
    AVPlayerItem       * tempAvPlayerItem   = thisPip.avPlayerItem;
    BOOL               tempMuted            = thisPip.isMuted;

    
    thisPip.avPlayer        = thatPip.avPlayer;
    thisPip.avPlayerLayer   = thatPip.avPlayerLayer;

    thisPip.avPlayerItem    = thatPip.avPlayerItem;
    thisPip.muted           = thatPip.isMuted;

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



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor blackColor]];
        self.layer.borderWidth  = 1;
        self.layer.borderColor  = [DESELECT_COLOR CGColor];
        self.isDragAble         = NO;
        _rate                   = 1.0;
        _quality                = 0;
        debugLabel              = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, 100, 30)];
    }
    return self;
}

-(void)playerURL:(NSURL *)url
{
    _feed          = [[Feed alloc]initWithURLString:  [url absoluteString]   quality:_quality];
    
//    @try {
//        [avPlayer removeTimeObserver:self];
//   
//    }
//    @catch (NSException * __unused exception) {}
    
    avPlayer        = nil;
    avPlayerItem    = [[AVPlayerItem alloc] initWithURL:[_feed path]];
    avPlayer        = [AVPlayer playerWithPlayerItem:avPlayerItem];
    
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

-(void)prepareWithFeed:(Feed*)aFeed
{
    _feed = aFeed;
//    @try {
//
//        if (avPlayer)[avPlayer removeTimeObserver:self];
//
//    }
//    @catch (NSException * __unused exception) {}
    
    _feed.quality   = _quality;
    NSURL * url     = [_feed path];
    avPlayer        = nil;
    avPlayerItem    = [[AVPlayerItem alloc] initWithURL:url];
    avPlayer        = [AVPlayer playerWithPlayerItem:avPlayerItem];
    
    if (avPlayerLayer)[avPlayerLayer removeFromSuperlayer];
    avPlayerLayer                 = [AVPlayerLayer playerLayerWithPlayer:avPlayer];
    avPlayerLayer.frame           = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self.layer addSublayer:avPlayerLayer];


}


static void * pipContext = &pipContext;
//-(void)playPlayerItem:(AVPlayerItem *) avpi
//{
//    if (avPlayer.status != AVPlayerStatusReadyToPlay)return;
//    
//    NSURL * nextURL     = [self urlOfCurrentlyPlayingInPlayer:avpi];
//    seekToFromNewAVPlayerItem     = avpi.currentTime;
//    
//    [self playerURL:nextURL];
//    [avPlayer addObserver:self forKeyPath:@"status" options:0 context:pipContext];
//}


-(NSURL *)urlOfCurrentlyPlayingInPlayer:(AVPlayerItem *)playerItem{
    // get current asset
    AVAsset *currentPlayerAsset = playerItem.asset;
    // make sure the current asset is an AVURLAsset
    if (![currentPlayerAsset isKindOfClass:AVURLAsset.class]) return nil;
    // return the NSURL
    return [(AVURLAsset *)currentPlayerAsset URL];
}


- (void)observeValueForKeyPath:(NSString *)keyPath  ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &pipContext) {
        AVPlayer * ply = (AVPlayer *)object;
        if (ply.status == AVPlayerStatusReadyToPlay) {
            //[avPlayer seekToTime:seekToFromNewAVPlayerItem];
            [object removeObserver:self forKeyPath:NSStringFromSelector(@selector(status))];
        }
    }
    
    if (context == &seekContext){
        AVPlayerItem * plyItm = (AVPlayerItem *)object;
        if (plyItm.status == AVPlayerStatusReadyToPlay) {
            [self.avPlayerItem removeObserver:self forKeyPath:NSStringFromSelector(@selector(status)) context:&seekContext];
           if(seekReady) seekReady();
        }
    
    }
    

}




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



// Controls for the video



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
    AVPlayerItem * avplyeritm  = avPlayerItem;
    if (self.avPlayerItem.status != AVPlayerItemStatusReadyToPlay){
    
        [self.avPlayerItem addObserver:self forKeyPath:NSStringFromSelector(@selector(status)) options:NSKeyValueObservingOptionNew context:&seekContext];
        // MAKES BLOCK
        seekReady = ^void(){
            
            if (difference == 1 ){
                [avplyer seekToTime:avplyeritm.duration];
            }
            
            [avplyer seekToTime:time];
            
        };
    } else { // avplayer item is ready to play
//        if (playerTime.value ==0)return;
        if (difference == 1 ){
            [avPlayer seekToTime:self.avPlayerItem.duration];
        }
        [avPlayer seekToTime:time];
    }
}

-(void)playRate:(float)rate
{
    _rate = rate;
    [avPlayer setRate:_rate];
}




-(CMTime)currentTimePosition
{

    return [avPlayer currentTime];
}







-(BOOL)isMuted{
    return avPlayer.muted;
}

-(void)setMuted:(BOOL)muted
{
    avPlayer.muted = muted;
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
        self.layer.borderColor  = [SELECTED_COLOR CGColor];
    } else {
        self.layer.borderColor  = [DESELECT_COLOR CGColor];
    }
}

-(BOOL)selected
{
    return _selected;
}


@end
