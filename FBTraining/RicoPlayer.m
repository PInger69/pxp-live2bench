
//
//  RicoPlayer.m
//  Live2BenchNative
//
//  Created by dev on 2015-11-25.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "RicoPlayer.h"
#import "DebugOutput.h"
#include <stdlib.h>


@interface RicoPlayer ()

@property (strong, nonatomic, nullable) id periodicObserver;
@property (strong, nonatomic, nullable) id rangeObserver;

@end



@implementation RicoPlayer

NSString* const RicoPlayerWillWaitForSynchronizationNotification    = @"RicoPlayerWillWaitForSynchronizationNotification";
NSString* const RicoPlayerDidPlayerItemFailNotification             = @"RicoPlayerDidPlayerItemFailNotification";

@synthesize feed            = _feed;
@synthesize slomo           = _slomo;
@synthesize avPlayer        = _avPlayer;
@synthesize avPlayerLayer   = _avPlayerLayer;
@synthesize range           = _range;

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
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        playerCounter++;
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
        
//        _debugOutput.layer.borderColor = [[UIColor whiteColor]CGColor];
//        _debugOutput.layer.borderWidth = 2;
        
        self.debugValues = [NSMutableDictionary new];
    }
    return self;
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
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
                    [self.delegate onReset:self playerItemOperation:[self loadFeed:_feed]];
                }
                break;
            case AVPlayerItemStatusReadyToPlay:
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
        self.debugValues[@"now"]        = [NSString stringWithFormat:@"Current Time  = %f", CMTimeGetSeconds(self.avPlayer.currentTime)];
        self.debugValues[@"dur"]        = [NSString stringWithFormat:@"Duration Time = %f", CMTimeGetSeconds(self.duration)];

        [self updateDebugOutput];
        
    }


}


#pragma mark - Operation Methods

-(NSOperation*)play
{
    __weak RicoPlayer * weakSelf = self;
    NSBlockOperation * playOp =  [NSBlockOperation blockOperationWithBlock:^{
//        dispatch_async(dispatch_get_main_queue(), ^{

            [weakSelf.avPlayer play];
            [weakSelf.avPlayer seekToTime:weakSelf.avPlayer.currentTime completionHandler:^(BOOL finished) {
                NSLog(@"PLAY SEEK %@",(finished)?@"pass":@"fail");
            }];
            weakSelf.isPlaying = YES;
         NSLog(@"PLAY %@",weakSelf.name);

//         });

    }];

    [self.operationQueue addOperation:playOp];
    return playOp;
}

-(NSOperation*)pause
{
    __weak RicoPlayer * weakSelf = self;
    NSBlockOperation * pauseOp =  [NSBlockOperation blockOperationWithBlock:^{
//        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"PAUSE %@",self.name);
            [_avPlayer pause];
            weakSelf.isPlaying = NO;
//        });            
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
    
    
    [self.operationQueue addOperation:pauseOp];
   
    return pauseOp;
}

-(NSOperation*)seekToTime:(CMTime)time toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter completionHandler:(nullable void (^)(BOOL finished))completionHandler
{
    NSOperation * seeker = [[RicoSeekOperation alloc]initWithAVPlayer:_avPlayer seekToTime:time toleranceBefore:toleranceBefore toleranceAfter:toleranceAfter];
//    seeker.completionBlock = completionHandler;
    if (self.syncronized) {
          __weak RicoPlayer * weakSelf = self;
        [seeker setCompletionBlock:^{
                weakSelf.waitingForSynchronization = YES;
            dispatch_async(dispatch_get_main_queue(),^{
                
                [[NSNotificationCenter defaultCenter]postNotificationName:RicoPlayerWillWaitForSynchronizationNotification object:weakSelf ];
            });
        }];
    }
    [self.operationQueue addOperation:seeker];

    return seeker;
}

-(NSOperation*)loadFeed:(Feed *)feed
{
    
    CMTimeRange oldTimeRange = _range;
    
    [self clear];
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(feed))];
    _feed = feed;
    [self didChangeValueForKey: NSStringFromSelector(@selector(feed))];
    
    
    if (_feed){
        [_feed addObserver:self forKeyPath:NSStringFromSelector(@selector(quality)) options:0 context:&feedContext];
        _avPlayer               = [AVPlayer playerWithPlayerItem:[[AVPlayerItem alloc] initWithURL:[_feed path]]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlayToEndTimeNotification:) name:AVPlayerItemDidPlayToEndTimeNotification object:_avPlayer.currentItem];
        [_avPlayer.currentItem addObserver:self forKeyPath:NSStringFromSelector(@selector(status)) options:0 context:&itemContext];
        _avPlayerLayer          = [AVPlayerLayer playerLayerWithPlayer:_avPlayer];
        _avPlayerLayer.frame    = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [self.layer addSublayer:_avPlayerLayer];
        
        
        if (CMTIMERANGE_IS_VALID(oldTimeRange)){
            self.range = oldTimeRange;
        }
    }
    
    self.isReadyOperation = [[RicoReadyPlayerItemOperation alloc]initWithPlayerItem:_avPlayer.currentItem];
    
    __weak RicoPlayer * weakSelf = self;
    [self.isReadyOperation setCompletionBlock:^{
        NSLog(@"LOAD %@-%@",weakSelf.name,[weakSelf.feed path]);
        [weakSelf addPeriodicTimeObserver];
    }];
    

    NSLog(@"%@",self.operationQueue);
    
    [self.operationQueue addOperations:@[self.isReadyOperation] waitUntilFinished:NO];
    
    dispatch_async(dispatch_get_main_queue(),^ {
        [_debugOutput setFrame:CGRectMake(0, 10, self.frame.size.width, 80)];
        [weakSelf addSubview:_debugOutput];
        [weakSelf updateDebugOutput];
    });
    
    return self.isReadyOperation;
}


-(void)reset
{
    // get the time
//    CMTime time = _avPlayer.currentTime;
//    
//    self.feed = _feed;
//    [self seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
//       //Somthing
//    }];
    
    
    // clear clear
    [self.operationQueue cancelAllOperations];
    self.operationQueue.suspended = NO;
//    self.operationQueue = nil;
//    self.operationQueue = [NSOperationQueue new];
    
    
    // remove old player
    if (_avPlayer){
        [self.avPlayer pause];
        [self.avPlayer.currentItem cancelPendingSeeks];
        [self.avPlayer.currentItem.asset cancelLoading];
        
        [self removePlayerTimeObserver];
        [_avPlayer.currentItem removeObserver:self forKeyPath:NSStringFromSelector(@selector(status)) context:&itemContext];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_avPlayer.currentItem];
        _avPlayer               = nil;        
    }
    
    // remove old feed
    if (_feed) {
        [_feed removeObserver:self forKeyPath:NSStringFromSelector(@selector(quality)) context:&feedContext];
        _feed = nil;
    }
    
    // remove old layer
    if (_avPlayerLayer){
        [_avPlayerLayer removeFromSuperlayer];
        _avPlayerLayer = nil;
    }

}


// this destroy
-(void)clear
{
    _range = kCMTimeRangeInvalid;
    if (self.rangeObserver) {
        [self.avPlayer removeTimeObserver:self.rangeObserver];
        self.rangeObserver = nil;
    }
    
    // Clear all Queued operations
    [self.operationQueue cancelAllOperations];
    self.operationQueue.suspended = NO;
//    self.operationQueue = nil;
//    self.operationQueue = [NSOperationQueue new];
    // remove old player
    if (_avPlayer){
        [self.avPlayer pause];
        [self.avPlayer.currentItem cancelPendingSeeks];
        [self.avPlayer.currentItem.asset cancelLoading];
        
        [self removePlayerTimeObserver];
        [_avPlayer.currentItem removeObserver:self forKeyPath:NSStringFromSelector(@selector(status)) context:&itemContext];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_avPlayer.currentItem];
        _avPlayer               = nil;
    }
    
    // remove old feed
    if (_feed) {
        [_feed removeObserver:self forKeyPath:NSStringFromSelector(@selector(quality)) context:&feedContext];
        _feed = nil;
    }
    
    // remove old layer
    if (_avPlayerLayer){
        [_avPlayerLayer removeFromSuperlayer];
        _avPlayerLayer = nil;
    }
    
    
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
    
    
    if (_feed){
        [_feed addObserver:self forKeyPath:NSStringFromSelector(@selector(quality)) options:0 context:&feedContext];
        _avPlayer               = [AVPlayer playerWithPlayerItem:[[AVPlayerItem alloc] initWithURL:[_feed path]]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlayToEndTimeNotification:) name:AVPlayerItemDidPlayToEndTimeNotification object:_avPlayer.currentItem];
        [_avPlayer.currentItem addObserver:self forKeyPath:NSStringFromSelector(@selector(status)) options:0 context:&itemContext];
        _avPlayerLayer          = [AVPlayerLayer playerLayerWithPlayer:_avPlayer];
        _avPlayerLayer.frame    = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [self.layer addSublayer:_avPlayerLayer];
    }
    
    self.isReadyOperation = [[RicoReadyPlayerItemOperation alloc]initWithPlayerItem:_avPlayer.currentItem];
    
    __weak RicoPlayer * weakSelf = self;
    [self.isReadyOperation setCompletionBlock:^{
        NSLog(@"LOAD %@-%@",weakSelf.name,[weakSelf.feed path]);
        [weakSelf addPeriodicTimeObserver];
    }];
    [self.operationQueue addOperations:@[self.isReadyOperation] waitUntilFinished:NO];
    
    dispatch_async(dispatch_get_main_queue(),^ {
        [_debugOutput setFrame:CGRectMake(0, 10, self.frame.size.width, 80)];
        [weakSelf addSubview:_debugOutput];
        [weakSelf updateDebugOutput];
    });
}

-(void)didPlayToEndTimeNotification:(NSNotification*)note
{
    if (self.looping){
        (void)[self pause];
          __weak RicoPlayer * weakSelf = self;
        [self.operationQueue addOperationWithBlock:^{
            [_avPlayer seekToTime:kCMTimeZero toleranceBefore:kCMTimePositiveInfinity toleranceAfter:kCMTimeZero];
        }];
        
        RicoPreRollOperation * preroll = [[RicoPreRollOperation alloc]initWithAVPlayer:_avPlayer prerollAtRate:1];

        [self.operationQueue addOperation:preroll];

        if (self.syncronized){
            
            [self.operationQueue addOperationWithBlock:^{
                 NSLog(@"waiting for synchronization   %@",weakSelf);
                self.waitingForSynchronization = YES;
                
                dispatch_async(dispatch_get_main_queue(),^{
                    [[NSNotificationCenter defaultCenter]postNotificationName:RicoPlayerWillWaitForSynchronizationNotification object:weakSelf ];
                });
            }];
        }
        
        (void)[self play];



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
        
        AVPlayerItem * zzz =  _avPlayer.currentItem;
        NSArray * xxx = zzz.seekableTimeRanges;
        
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
    if (self.periodicObserver)
    {
        [self.avPlayer removeTimeObserver:self.periodicObserver];
        self.periodicObserver = nil;
    }
}


-(void)addPeriodicTimeObserver
{
    double                      interval        = 0.5f;
    __weak RicoPlayer          * weakSelf      = self;
    
    
    self.periodicObserver = [self.avPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)
                                                               queue:NULL
                                                          usingBlock:^(CMTime time)
                    {

                        weakSelf.debugValues[@"rate"] = [NSString stringWithFormat:@"%f",weakSelf.avPlayer.rate];
                        weakSelf.debugValues[@"now"] = [NSString stringWithFormat:@"Current Time  = %f", CMTimeGetSeconds(weakSelf.avPlayer.currentTime)];
                        weakSelf.debugValues[@"dur"] = [NSString stringWithFormat:@"Duration Time = %f", CMTimeGetSeconds(weakSelf.duration)];
                        weakSelf.debugValues[@"op"] = [NSString stringWithFormat:@"Operation Count = %lu", (unsigned long)weakSelf.operationQueue.operationCount];
                        [weakSelf updateDebugOutput];
                        if (weakSelf.delegate) {
                            [weakSelf.delegate tick:weakSelf];
                        }
                    }];
    
}

#pragma mark - RicoPlayerItemOperationDelegate Methods

-(void)onPlayerOperationItemFail:(PxpReadyPlayerItemOperation *)operation
{
    NSLog(@"Player Item fail - cancelAllOperations");
    [self.operationQueue cancelAllOperations];
//    self.operationQueue = nil;
//    self.operationQueue = [NSOperationQueue new];
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
    
//   if (!CMTimeRangeEqual(range, _range)) {
    
       [self willChangeValueForKey:@"range"];
       _range = range;
       [self didChangeValueForKey:@"range"];
       
       CMTime start = range.start, end = CMTimeAdd(start, range.duration);
       
       // create a boundary observer at the range end points
       __block RicoPlayer *weakself = self;
       
       self.rangeObserver = [self.avPlayer addBoundaryTimeObserverForTimes:@[[NSValue valueWithCMTime:end]] queue:NULL usingBlock:^() {
           [weakself seekToTime:start toleranceBefore:kCMTimePositiveInfinity toleranceAfter:kCMTimeZero completionHandler:nil];
       }];

       [self seekToTime:start toleranceBefore:kCMTimePositiveInfinity toleranceAfter:kCMTimeZero completionHandler:nil];
//   }
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
    _debugOutput.text = [NSString stringWithFormat:@"%@\n%@\nrate: %@ \n%@\n%@\n%@",
                         self.name,
                         _debugValues[@"itemStatus"],
                         _debugValues[@"rate"],
                         _debugValues[@"now"],
                         _debugValues[@"dur"],
                         _debugValues[@"op"]
                         
                         ];

}


-(void)destroy
{
    self.feed = nil;
//    [self.operationQueue cancelAllOperations];
//    self.operationQueue     = nil;
//    self.feed               = nil;
//    self.isReadyOperation   = nil;
//    self.avPlayer           = nil;
//    self.avPlayerLayer      = nil;
//    
//    
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
    _avPlayerLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    [super setFrame:frame];
}

-(void)dealloc
{
    NSLog(@"Rico dealloc");
}


@end
