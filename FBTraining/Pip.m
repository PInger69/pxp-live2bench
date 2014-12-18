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
    
    
}
@synthesize avPlayerItem;
@synthesize avPlayer;
@synthesize avPlayerLayer;
@synthesize isDragAble;
@synthesize dragBounds;
@synthesize quality = _quality;
@synthesize feed = _feed;
@synthesize selected = _selected;

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
    
    @try {
        [avPlayer removeTimeObserver:self];
    }
    @catch (NSException * __unused exception) {}
    
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
    
    @try {
        [avPlayer removeTimeObserver:self];
    }
    @catch (NSException * __unused exception) {}
    
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



////
//-(void)playQualityURL:(NSDictionary *)urls
//{
//    _qualityFeeds = urls;
//    NSURL URLWithString:<#(NSString *)#>
//    _feed = [Feed alloc]initWithURLString:  quality:<#(int)#>
//    
//    @try {
//        [avPlayer removeTimeObserver:self];
//    }
//    @catch (NSException * __unused exception) {}
//    
//    NSURL * url;
//    if (self.hasHighQuality){
//        url = [_qualityFeeds objectForKey:@"hq"];
//        _quality = 1;
//    } else {
//        url = [_qualityFeeds objectForKey:@"lq"];
//        _quality = 0;
//    }
//    
//    
//    avPlayer = nil;
//    avPlayerItem  = [[AVPlayerItem alloc] initWithURL:url];
//    avPlayer    = [AVPlayer playerWithPlayerItem:avPlayerItem];
//    
//    
//    if (avPlayerLayer)[avPlayerLayer removeFromSuperlayer];
//    avPlayerLayer                 = [AVPlayerLayer playerLayerWithPlayer:avPlayer];
//    avPlayerLayer.frame           = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
//    [self.layer addSublayer:avPlayerLayer];
//    [avPlayer setRate:1];
//    
//}



-(void)playPlayerItem:(AVPlayerItem *) avpi
{
    if (avPlayer.status != AVPlayerStatusReadyToPlay)return;
    
    NSURL * nextURL     = [self urlOfCurrentlyPlayingInPlayer:avpi];
    seekToFromNewAVPlayerItem     = avpi.currentTime;
    
    [self playerURL:nextURL];
    [avPlayer addObserver:self forKeyPath:@"status" options:0 context:nil];
}


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
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayer * ply = (AVPlayer *)object;
        if (ply.status == AVPlayerStatusReadyToPlay) {
            //[avPlayer seekToTime:seekToFromNewAVPlayerItem];
            [object removeObserver:self forKeyPath:NSStringFromSelector(@selector(status))];
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

-(void)seekTo:(CMTime)time
{
    [avPlayer seekToTime:time];
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

// NSCopy Protocol so that this class can be used as a key in a dict
//- (id)copyWithZone:(NSZone *)zone
//{
//    Pip * copy = [[[self class] alloc] init];
//    if (copy){
//        copy.avPlayer	    = self.avPlayer;
//        copy.avPlayerLayer	= self.avPlayerLayer;
//        copy.avPlayerItem	= self.avPlayerItem;
//        copy.isDragAble	    = self.isDragAble;
//        copy.dragBounds	    = self.dragBounds;
//        copy.muted	        = self.muted;
//        copy.showFeedLabel	= self.showFeedLabel;
//        copy.selected	    = self.selected;
//        copy.quality	    = self.quality;
//        copy.feed	        = self.feed;
//    
//        
//        copy -> seekToFromNewAVPlayerItem   = seekToFromNewAVPlayerItem;
//        copy -> debugLabel                  = debugLabel;
//        copy -> _rate                       = _rate;
//        copy -> _qualityFeeds               = _qualityFeeds;
//    }
//    
//    return copy;
//}


@end
