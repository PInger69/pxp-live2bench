

//
//  RicoPlayer.m
//  Live2BenchNative
//
//  Created by dev on 2015-11-25.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "RicoPlayer.h"
#import "DebugOutput.h"
#import "RicoPlayerMonitor.h"
#import "Ticker.h"
#include <stdlib.h>
#import <TSMessages/TSMessage.h>




@interface RicoPlayer ()

@property (strong, nonatomic, nullable) id periodicObserver;
@property (strong, nonatomic, nullable) id rangeObserver;
@property (strong, nonatomic, nonnull) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSMapTable * observerMap;
//@property (strong, nonatomic) RicoPlayerChecker * checker; // check to see if the player is stuck seeking
@property (strong, nonatomic) NSTimer  * checkTimer;
@property (strong, nonatomic) RicoPlayerMonitor * monitor;
@property (strong, nonatomic) Ticker * ticker;
@end



@implementation RicoPlayer

NSString* const RicoPlayerWillWaitForSynchronizationNotification    = @"RicoPlayerWillWaitForSynchronizationNotification";
NSString* const RicoPlayerDidPlayerItemFailNotification             = @"RicoPlayerDidPlayerItemFailNotification";

@synthesize feed            = _feed;
@synthesize slomo           = _slomo;
@synthesize avPlayer        = _avPlayer;
@synthesize avPlayerLayer   = _avPlayerLayer;
@synthesize range           = _range;
@synthesize live;
@synthesize reliable        = _reliable;
@synthesize offsetTime      = _offsetTime;


static void * feedContext = &feedContext;
static void * itemContext = &itemContext;

static NSInteger playerCounter = 0; // count the number of players created and give unique names



+(void)initialize
{
   
    
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        playerCounter++;
        self.linkedRenderViews = [NSMutableArray new];
        self.name = [NSString stringWithFormat:@"instance%ld",(long)playerCounter ];
        [self setBackgroundColor:[UIColor blackColor]];
        self.operationQueue = [NSOperationQueue new];
        self.operationQueue.maxConcurrentOperationCount = 1;
        
        _debugOutput = [[UITextView alloc]initWithFrame:CGRectZero];
        [_debugOutput setHidden:!DEBUG_MODE];
        _debugOutput.allowsEditingTextAttributes = NO;
        [_debugOutput setText:@"*"];
        [_debugOutput setFont:[UIFont systemFontOfSize:10.0f]];
        [_debugOutput setTextColor:PRIMARY_APP_COLOR];
        
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityIndicator.color = PRIMARY_APP_COLOR;
        _activityIndicator.hidesWhenStopped = YES;
        _activityIndicator.frame = self.bounds;
        
        _observerMap    = [NSMapTable strongToStrongObjectsMapTable];
        _offsetTime     = kCMTimeZero;

        self.monitor = [[RicoPlayerMonitor alloc]initWithPlayer:self];
        self.streamStatus = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, 92, 12)];
        [self.streamStatus setTextAlignment:NSTextAlignmentCenter];
//        self.streamStatus.text = @"Corrupted Stream";
        [self.streamStatus setTextColor:[UIColor redColor]];
        [self.streamStatus setBackgroundColor:[UIColor blackColor]];
        [self.streamStatus setFont:[UIFont systemFontOfSize:10.0f]];
        [self.streamStatus setHidden:YES];
        self.reliable = YES;
        self.ticker = [[Ticker alloc]initWithTick:10];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        playerCounter++;
        self.linkedRenderViews = [NSMutableArray new];        
        self.name = [NSString stringWithFormat:@"instance%ld",(long)playerCounter ];
        self.instanceName  = [NSString stringWithFormat:@"instance%ld",(long)playerCounter ];
        [self setBackgroundColor:[UIColor blackColor]];
        self.operationQueue = [NSOperationQueue new];
        self.operationQueue.maxConcurrentOperationCount = 1;

        _debugOutput = [[UITextView alloc]initWithFrame:CGRectZero];
        [_debugOutput setHidden:!DEBUG_MODE];
        [_debugOutput setText:@"*"];
        [_debugOutput setSelectable:NO];
        [_debugOutput setFont:[UIFont systemFontOfSize:10.0f]];
        [_debugOutput setTextColor:[UIColor whiteColor]];
        [_debugOutput setBackgroundColor:[UIColor clearColor]];
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityIndicator.color = PRIMARY_APP_COLOR;
        _activityIndicator.hidesWhenStopped = YES;
        _activityIndicator.frame = self.bounds;

        self.debugValues = [NSMutableDictionary new];
        
        _observerMap = [NSMapTable strongToStrongObjectsMapTable];
        _offsetTime     = kCMTimeZero;
        self.monitor = [[RicoPlayerMonitor alloc]initWithPlayer:self];
        
        self.streamStatus = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, 92, 12)];
        [self.streamStatus setHidden:YES];
        [self.streamStatus setTextAlignment:NSTextAlignmentCenter];
        [self.streamStatus  setTextColor:[UIColor redColor]];
//        [self.streamStatus setBackgroundColor:[UIColor blackColor]];
        [self.streamStatus setFont:[UIFont systemFontOfSize:10.0f]];
//        self.streamStatus.text = @"Corrupted Stream";
        self.reliable = YES;
        self.ticker = [[Ticker alloc]initWithTick:10];
    }
    return self;
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    
     AVPlayerItem * playerItembufferCheck = object;
    if (object == self.player.currentItem && [keyPath isEqualToString:@"playbackBufferEmpty"])
    {
        if (playerItembufferCheck.playbackBufferEmpty) {
            //Your code here
        }
    }
    
    else if (object == self.player.currentItem && [keyPath isEqualToString:@"playbackLikelyToKeepUp"])
    {
        if (playerItembufferCheck.playbackLikelyToKeepUp)
        {
            //Your code here
        }
    }
    
    
    
    if (context == &feedContext) {
        NSLog(@"quality change");
    } else if (context == &itemContext) {
        AVPlayerItem * playerItem = object;
        NSString * message;
        switch (playerItem.status) {
            case AVPlayerItemStatusFailed:
                message = @"AVPlayerItemStatusFailed";
                // when the player resets it will just reload the item the delegate will manage the seek after loading
                if (self.delegate && [self.delegate respondsToSelector:@selector(onReset:playerItemOperation:)]) {
//                    [self.delegate onReset:self playerItemOperation:[self loadFeed:_feed]];
                }
                break;
            case AVPlayerItemStatusReadyToPlay:
                [self.activityIndicator stopAnimating];
                message = @"AVPlayerItemStatusReadyToPlay";
                break;
            case AVPlayerItemStatusUnknown:
                message = @"AVPlayerItemStatusUnknown";
                break;
                
            default:
                break;
        }
        self.debugValues[@"itemStatus"] = message;
        self.debugValues[@"rate"]       = [NSString stringWithFormat:@"%f",self.avPlayer.rate];
        self.debugValues[@"now"]        = [NSString stringWithFormat:@"CT: %f", CMTimeGetSeconds(self.avPlayer.currentTime)];
        self.debugValues[@"dur"]        = [NSString stringWithFormat:@"DT: %f", CMTimeGetSeconds(self.duration)];

        [self updateDebugOutput];
        
    }


}


#pragma mark - Operation Methods

-(NSOperation*)play
{

    __weak RicoPlayer * weakSelf = self;
    
    
    NSBlockOperation * playOp =  [NSBlockOperation blockOperationWithBlock:^{


        if (weakSelf.avPlayer.status == AVPlayerStatusReadyToPlay) {
        
                [weakSelf.avPlayer play];
            if (weakSelf.slomo) _avPlayer.rate = RICO_SLOMO_RATE;
            
            if (CMTIME_IS_VALID(weakSelf.avPlayer.currentTime)){
                
                CMTime seekTime = weakSelf.avPlayer.currentTime;
                [weakSelf.avPlayer seekToTime:seekTime completionHandler:^(BOOL finished) {
//                    NSLog(@"PLAY SEEK %@",(finished)?@"pass":@"fail");

                }];
            }
                weakSelf.isPlaying = YES;

        }
    }];
    playOp.name = @"Play Block";
    [self.operationQueue addOperation:playOp];
    [self updateDebugOutput];
    return playOp;
}

-(NSOperation*)pause
{
    [self updateDebugOutput];
    __weak RicoPlayer * weakSelf = self;
    NSBlockOperation * pauseOp =  [NSBlockOperation blockOperationWithBlock:^{
            NSLog(@"PAUSE %@",self.name);
            [_avPlayer pause];
            weakSelf.isPlaying = NO;
    }];
    
    if (self.syncronized) {
  
        [pauseOp setCompletionBlock:^{
             self.waitingForSynchronization = YES;
            dispatch_async(dispatch_get_main_queue(),^{
                [[NSNotificationCenter defaultCenter]postNotificationName:RicoPlayerWillWaitForSynchronizationNotification object:weakSelf ];
                NSLog(@"SYNC %@",self.name);
            });
        }];
    }
    pauseOp.name = @"Pause Operation";
    
    [self.operationQueue addOperation:pauseOp];
   
    return pauseOp;
}

-(NSOperation*)seekToTime:(CMTime)time toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter completionHandler:(nullable void (^)(BOOL finished))completionHandler
{
    NSLog(@"currenttime: %f",CMTimeGetSeconds(self.currentTime));
    NSLog(@"MaxTime: %f",CMTimeGetSeconds(self.duration));
    NSLog(@"Seeking to:  %f   tolerance: %f / %f ",CMTimeGetSeconds(time),CMTimeGetSeconds(toleranceBefore),CMTimeGetSeconds(toleranceAfter));
    NSLog(@"Has Range: %@",(CMTIMERANGE_IS_VALID(self.range))?@"YES":@"NO");
    NSLog(@"PlayerStatus: %@",(self.avPlayer.status == AVPlayerStatusReadyToPlay)?@"Ready":@" not Ready");
    NSLog(@"PlayerStatusItem: %@",(self.avPlayer.currentItem.status == AVPlayerItemStatusReadyToPlay)?@"Ready":@" not Ready");
    if (CMTIMERANGE_IS_VALID(self.range)) {
        CMTime start = self.range.start, end = CMTimeAdd(start, self.range.duration);
        if ( CMTIME_COMPARE_INLINE(time, >, end) || CMTIME_COMPARE_INLINE(time, <, start)) {
            time = start;
        }
    }
    
    
    RicoSeekOperation* seeker = [[RicoSeekOperation alloc]initWithAVPlayer:_avPlayer seekToTime:time toleranceBefore:toleranceBefore toleranceAfter:toleranceAfter];
    
    [seeker setCompletionBlock:^{
            NSLog(@"Seek finished: %f",CMTimeGetSeconds(self.currentTime));
    }];
    
    [seeker setCompletionHandler:^(BOOL finished, NSError* error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(),^{
                [self showErrorMessage:@"Playback error" error:error];
            });
        }
    }];

    if (self.syncronized) {
          __weak RicoPlayer * weakSelf = self;
        [seeker setCompletionBlock:^{
            weakSelf.waitingForSynchronization = YES;
            NSLog(@"%@ Seek finished: %f",self.name,CMTimeGetSeconds(self.currentTime));
            dispatch_async(dispatch_get_main_queue(),^{
                [[NSNotificationCenter defaultCenter]postNotificationName:RicoPlayerWillWaitForSynchronizationNotification object:weakSelf ];
            });
        }];
    }
    [self.operationQueue addOperation:seeker];
    NSLog(@"Operations %lu",(unsigned long)self.operationQueue.operationCount);
    return seeker;
}

-(void) showErrorMessage:(NSString*) title error:(NSError*) e {
    NSString* errorMessage = [NSString stringWithFormat:@"%@",e.localizedFailureReason];
    [TSMessage showNotificationInViewController:[TSMessage defaultViewController]
                                          title:title
                                       subtitle:errorMessage
                                           type:TSMessageNotificationTypeError
                                       duration:3];
}


-(NSOperation*)loadFeed:(Feed *)feed
{
    self.reliable = YES;
    CMTimeRange oldTimeRange = _range;
    
    [self clear];
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(feed))];
    _feed = feed;
    [self didChangeValueForKey: NSStringFromSelector(@selector(feed))];
    
        [self.checkTimer invalidate];
    
    [self.monitor stop];
    if (_feed){
        [self.monitor start];
        self.offsetTime = CMTimeMakeWithSeconds(_feed.offset, NSEC_PER_SEC);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.checkTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateCheck) userInfo:nil repeats:YES];
        });
        NSURL * url = [_feed path];
        
            _avPlayer               = [AVPlayer playerWithPlayerItem:[[AVPlayerItem alloc] initWithURL:url]];

            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlayToEndTimeNotification:) name:AVPlayerItemDidPlayToEndTimeNotification object:_avPlayer.currentItem];
            [_avPlayer.currentItem addObserver:self forKeyPath:NSStringFromSelector(@selector(status)) options:0 context:&itemContext];
        
        
        
            _avPlayerLayer          = [AVPlayerLayer playerLayerWithPlayer:_avPlayer];
            _avPlayerLayer.frame    = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);

            [self.layer addSublayer:_avPlayerLayer];

        [_activityIndicator startAnimating];
        _activityIndicator.hidden = NO;
        [self addSubview:_activityIndicator];
        
        
        [self addSubview:self.streamStatus];
        if (CMTIMERANGE_IS_VALID(oldTimeRange)){
            self.range = oldTimeRange;
        }
        
        
        
        self.isReadyOperation = [[RicoReadyPlayerItemOperation alloc]initWithPlayerItem:_avPlayer.currentItem];
        
        __weak RicoPlayer * weakSelf = self;
        [self.isReadyOperation setCompletionBlock:^{
            NSLog(@" LOAD %@ - URL:%@",weakSelf.name,[weakSelf.feed path]);
            
            if (weakSelf.isReadyOperation.isCancelled) {
                NSLog(@"");
            }
            
            if (weakSelf.isReadyOperation.success) {
                [weakSelf addPeriodicTimeObserver];
                dispatch_async(dispatch_get_main_queue(),^ {
                    [weakSelf.activityIndicator stopAnimating];
                    if([weakSelf.activityIndicator superview]) [weakSelf.activityIndicator removeFromSuperview];
                });
            } else {
                NSLog(@"Item Load Fail");
            }
            
        }];
        
        [self.operationQueue addOperation:self.isReadyOperation];

        
        dispatch_async(dispatch_get_main_queue(),^ {
            [_debugOutput setFrame:CGRectMake(0, 10, self.frame.size.width, 90)];
            [weakSelf addSubview:_debugOutput];
            [weakSelf updateDebugOutput];
        });
        
        return self.isReadyOperation;
        
        
    }
    dispatch_async(dispatch_get_main_queue(),^ {
        [_debugOutput setFrame:CGRectMake(0, 10, self.frame.size.width, 90)];
        [self addSubview:_debugOutput];
        [self updateDebugOutput];
    });
    return nil;
}


-(void)reset
{
    // get the time
    CMTime time = _avPlayer.currentTime;
    BOOL wasPlaying = (_avPlayer.rate > 0);
    Feed * feed = _feed;

        [self clear];
    //
    self.feed = feed;
    NSOperation * seekOp = [self seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
       //Somthing
    }];
    
    if (wasPlaying) {
        NSOperation * playOp = [self play];
        [playOp addDependency:seekOp];
    }

}


// this destroy
-(void)clear
{
    
    self.offsetTime = kCMTimeZero;
    _range = kCMTimeRangeInvalid;
    if (self.rangeObserver) {
        [self.avPlayer removeTimeObserver:self.rangeObserver];
        self.rangeObserver = nil;
    }
    
    // Clear all Queued operations
    [self.operationQueue cancelAllOperations];
    self.operationQueue.suspended = NO;

    // remove old player
    if (_avPlayer){
        [self removePlayerTimeObserver];
        [self.avPlayer pause];
        [self.avPlayer.currentItem cancelPendingSeeks];
        [self.avPlayer.currentItem.asset cancelLoading];
        [_avPlayer.currentItem removeObserver:self forKeyPath:NSStringFromSelector(@selector(status)) context:&itemContext];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_avPlayer.currentItem];
        _avPlayer               = nil;
    }
    
    // remove old feed
    if (_feed) {
        _feed = nil;
    }
    
    // remove old layer
    if (_avPlayerLayer){
        [_avPlayerLayer removeFromSuperlayer];
        _avPlayerLayer = nil;
    }
    
    self.error = nil;
}


// Getter setter

-(void)setFeed:(Feed *)feed
{
//    [feed setQuality:0];

    // clear player
    [self clear];
    
    
    // the feed is changed
    [self willChangeValueForKey:NSStringFromSelector(@selector(feed))];
    _feed = feed;
    [self didChangeValueForKey: NSStringFromSelector(@selector(feed))];
    
    [self.checkTimer invalidate];
    if (_feed){
        
        self.offsetTime = CMTimeMakeWithSeconds(_feed.offset, NSEC_PER_SEC);
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.checkTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateCheck) userInfo:nil repeats:YES];
        });
        

        _avPlayer               = [AVPlayer playerWithPlayerItem:[[AVPlayerItem alloc] initWithURL:[_feed path]]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlayToEndTimeNotification:) name:AVPlayerItemDidPlayToEndTimeNotification object:_avPlayer.currentItem];
        [_avPlayer.currentItem addObserver:self forKeyPath:NSStringFromSelector(@selector(status)) options:0 context:&itemContext];
        _avPlayerLayer          = [AVPlayerLayer playerLayerWithPlayer:_avPlayer];
        _avPlayerLayer.frame    = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [self.layer addSublayer:_avPlayerLayer];
  
    
        self.isReadyOperation = [[RicoReadyPlayerItemOperation alloc]initWithPlayerItem:_avPlayer.currentItem];
        
        __weak RicoPlayer * weakSelf = self;
        [self.isReadyOperation setCompletionBlock:^{
            if (weakSelf.isReadyOperation.isCancelled) {
            
                NSLog(@"");
            }
            NSLog(@"LOAD %@-%@",weakSelf.name,[weakSelf.feed path]);
            [weakSelf addPeriodicTimeObserver];
        }];
        [self.operationQueue addOperations:@[self.isReadyOperation] waitUntilFinished:NO];
        
        dispatch_async(dispatch_get_main_queue(),^ {
            [_debugOutput setFrame:CGRectMake(0, 10, self.frame.size.width, 90)];
            [weakSelf addSubview:_debugOutput];
            [weakSelf updateDebugOutput];
        });
        
    
    }
    

}

-(void)didPlayToEndTimeNotification:(NSNotification*)note
{
    if (self.looping){
        

        
        (void)[self pause];
        CMTime timeWithOffset = CMTimeAdd(kCMTimeZero, self.offsetTime);
        
        [self.operationQueue addOperationWithBlock:^{
            [_avPlayer seekToTime:timeWithOffset completionHandler:^(BOOL finished) {
                [_avPlayer play];
                if (self.slomo) _avPlayer.rate = RICO_SLOMO_RATE;
            }];
        }];
        

        if (self.syncronized){
            __weak RicoPlayer * weakSelf = self;
            [self.operationQueue addOperationWithBlock:^{
                 NSLog(@"waiting for synchronization   %@",weakSelf);
                self.waitingForSynchronization = YES;
                
                dispatch_async(dispatch_get_main_queue(),^{
                    [[NSNotificationCenter defaultCenter]postNotificationName:RicoPlayerWillWaitForSynchronizationNotification object:weakSelf ];
                });
            }];
        }
        
//        (void)[self play];



    }

}

-(Feed *)feed
{
    return _feed;
}



-(CMTime)duration {
    
    if (!_avPlayer.currentItem) {
        return kCMTimeZero;
    } else if (!CMTimeCompare(_avPlayer.currentItem.duration, kCMTimeIndefinite)) {
        // we might have to check the asset instead of the item
        
        if (_avPlayer.currentItem.seekableTimeRanges.count > 0) {
            CMTimeRange seekableRange = [_avPlayer.currentItem.seekableTimeRanges.firstObject CMTimeRangeValue];
            return seekableRange.duration;
        } else {
            return kCMTimeZero;
        }
    } else {
        return _avPlayer.currentItem.duration;
    }
}

-(CMTime)currentTime
{
    if (!_avPlayer.currentItem) {
        return kCMTimeZero;
    } else if (!CMTimeCompare(_avPlayer.currentTime, kCMTimeIndefinite)) {
        return kCMTimeZero;
    } else {
        return _avPlayer.currentTime;
    }
}

#pragma mark - TimeObservers Methods

-(void)removePlayerTimeObserver
{
//    [self.checker stop];
    id pObserver = [self.observerMap objectForKey:self.avPlayer];
    
    if (pObserver)
    {
            [self.avPlayer removeTimeObserver:pObserver];
            self.periodicObserver = nil;
        
        [self.observerMap removeObjectForKey:self.avPlayer];
    }
}


-(void)addPeriodicTimeObserver
{
//    [self.checker start];
    
    double                      interval        = 0.5f;
    __weak RicoPlayer          * weakSelf      = self;

    id pObserver = [self.avPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)
                                                               queue:NULL
                                                          usingBlock:^(CMTime time)
                    {
                        
                        weakSelf.debugValues[@"rate"]   = [NSString stringWithFormat:@"%f",weakSelf.avPlayer.rate];
                        weakSelf.debugValues[@"now"]    = [NSString stringWithFormat:@"CT: %f", CMTimeGetSeconds(weakSelf.avPlayer.currentTime)];
                        weakSelf.debugValues[@"dur"]    = [NSString stringWithFormat:@"DT: %f", CMTimeGetSeconds(weakSelf.duration)];
                        weakSelf.debugValues[@"op"]     = [NSString stringWithFormat:@"OpC: %lu", (unsigned long)weakSelf.operationQueue.operationCount];
                        weakSelf.debugValues[@"offset"] = [NSString stringWithFormat:@"offest: %f", CMTimeGetSeconds(weakSelf.offsetTime)];
                        weakSelf.debugValues[@"other"]  = [NSString stringWithFormat:@"%@",weakSelf.operationQueue.operations];
                        
                        [weakSelf updateDebugOutput];

                        
//                        [weakSelf.monitor update:weakSelf];
                        
                        
                        if (weakSelf.delegate) {
                            [weakSelf.delegate tick:weakSelf];
                        }
                    }];

    
    [self.observerMap setObject:pObserver forKey:self.avPlayer];
}

#pragma mark - RicoPlayerItemOperationDelegate Methods

-(void)onPlayerOperationItemFail:(PxpReadyPlayerItemOperation *)operation
{
    NSLog(@"Player Item fail - cancelAllOperations");
    [self.operationQueue cancelAllOperations];
    // This resume the the operation queue and let its view conteroller know that its unreliable if it was in the middle of a sync
    if (self.syncronized){
        self.waitingForSynchronization = NO;
    }
    
    __weak RicoPlayer * weakSelf = self;
    dispatch_async(dispatch_get_main_queue(),^{
        [[NSNotificationCenter defaultCenter]postNotificationName:RicoPlayerDidPlayerItemFailNotification object:weakSelf ];
    });
}

-(void)onPlayerOperationItemReady:(PxpReadyPlayerItemOperation *)operation
{
    NSLog(@"Player item is ready Delegate Method Time %f",CMTimeGetSeconds(self.currentTime) );
    // just for completeness
    [_avPlayer play];
}

- (void)setRange:(CMTimeRange)range {

    if (self.rangeObserver) {
       [self.avPlayer removeTimeObserver:self.rangeObserver];
       self.rangeObserver = nil;
    }
    
    if (!CMTIMERANGE_IS_VALID(range)) {
        [self willChangeValueForKey:@"range"];
        _range = kCMTimeRangeInvalid;
        [self didChangeValueForKey:@"range"];
        return;
    }

    [self willChangeValueForKey:@"range"];
    _range = range;
    [self didChangeValueForKey:@"range"];

    CMTime start = range.start, end = CMTimeAdd(start, range.duration);

    // create a boundary observer at the range end points
    __block RicoPlayer *weakself = self;

    self.rangeObserver = [self.avPlayer addBoundaryTimeObserverForTimes:@[[NSValue valueWithCMTime:end]] queue:NULL usingBlock:^() {
       [weakself seekToTime:start toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:nil];
    }];

    [self seekToTime:start toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:nil];
    [self seekToTime:start toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:nil];// this was doulbled from a reason

}


#pragma mark - Synchronization Methods

-(void)setWaitingForSynchronization:(BOOL)waitingForSynchronization
{
    if (!self.syncronized || !self.operationQueue) {
        return;
    }
    self.operationQueue.suspended = waitingForSynchronization;
}

-(BOOL)waitingForSynchronization
{
    if (!self.syncronized) {
        return NO;
    }
    
    return self.operationQueue.suspended;
}


-(void)updateDebugOutput
{
    if (!DEBUG_MODE && !self.reliable) {
        _debugOutput.hidden = NO;
        _debugOutput.text = @"";//@"Error"
    } else {
        dispatch_async(dispatch_get_main_queue(),^ {
            _debugOutput.text = [NSString stringWithFormat:@"%@  %@\n%@\nrate: %@ \n%@\n%@\n%@\n%@\n%@",
                                 self.name,
                                 (self.reliable)?@"R":@"F",
                                 _debugValues[@"itemStatus"],
                                 _debugValues[@"rate"],
                                 _debugValues[@"now"],
                                 _debugValues[@"dur"],
                                 _debugValues[@"op"],
                                 _debugValues[@"offset"],
                                 _debugValues[@"other"]
                                 ];
        });
    }
    
}


-(void)destroy
{
    self.feed = nil;
    [self.operationQueue cancelAllOperations];
    if (self.periodicObserver)
    {
        [self.avPlayer removeTimeObserver:self.periodicObserver];
        self.periodicObserver = nil;
    }
}

-(void)setSlomo:(BOOL)slomo
{
    if (slomo) {
        self.avPlayer.rate = RICO_SLOMO_RATE;
    } else {
        self.avPlayer.rate = 1.0;
    }
    _slomo = slomo;
}

-(void)setFrame:(CGRect)frame
{
    _avPlayerLayer.frame        = CGRectMake(0, 0, frame.size.width, frame.size.height);
    _activityIndicator.center   = CGPointMake(frame.size.width/2, frame.size.height/2);
    [super setFrame:frame];
}



-(void)dealloc
{
    NSLog(@"Rico dealloc %@",self.name);
}

#pragma mark - RJL play methods

#pragma mark -

-(void)updateCheck
{
    BOOL i = NO;
    
    
    
    if ((CMTimeGetSeconds(self.duration) == 0 && self.isReadyOperation.isFinished && self.avPlayer.status == AVPlayerStatusReadyToPlay)|| i) {

        if (!self.error) {
            NSString     * errVideoURL  = [((AVURLAsset*) self.avPlayer.currentItem.asset).URL absoluteString];
            NSDictionary * userInfo     = @{
                                           NSLocalizedDescriptionKey:               @"Video failed to play.",
                                           NSLocalizedFailureReasonErrorKey:        [NSString stringWithFormat:@"Player %@ has no duration and status is ReadyToPlay URL: %@",self.name,errVideoURL],
                                           NSLocalizedRecoverySuggestionErrorKey:   [NSString stringWithFormat:@"Check connections and/or restart player"]
                                           };
            self.error =  [NSError errorWithDomain:PxpErrorDomain code:PLAYER_ERROR_NO_DURATION userInfo:userInfo];
        }
        
        

        if ([self.ticker ready]) {
            [self reset];
        }
    }
}

-(void)refresh
{
    _avPlayerLayer.player =nil;
    _avPlayerLayer.player =self.avPlayer;
}




-(BOOL)live
{
    if (!self.avPlayer.currentItem) {
        return NO;
    } else if (self.avPlayer.currentItem.status == AVPlayerItemStatusReadyToPlay && !CMTimeCompare(_avPlayer.currentItem.duration, kCMTimeIndefinite)) {
        return YES;
    } else {
        return NO;
    }

}



-(void)setReliable:(BOOL)reliable
{
    [self willChangeValueForKey:@"reliable"];
    _reliable = reliable;
    self.streamStatus.hidden = _reliable;
    
    if (!DEBUG_MODE)[_debugOutput setHidden:YES];
    [self didChangeValueForKey:@"reliable"];
}

-(BOOL)reliable
{
    return _reliable;
}


-(void)setOffsetTime:(CMTime)offsetTime
{
    _offsetTime = offsetTime;
    
}

-(CMTime)offsetTime
{
    if (CMTimeCompare(_offsetTime, CMTimeMakeWithSeconds(_feed.offset, NSEC_PER_SEC))) {
        _offsetTime =  CMTimeMakeWithSeconds(_feed.offset, NSEC_PER_SEC);
    }
    return  _offsetTime;
}



-(NSString*)description
{
    return [NSString stringWithFormat:@"RicoPlayer %@: FeedName:%@",self.name,self.feed.sourceName ];
}

@end



