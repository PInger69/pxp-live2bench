

//
//  RicoPlayer.m
//  Live2BenchNative
//
//  Created by dev on 2015-11-25.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "RicoPlayer.h"
#import "DebugOutput.h"
#import "CustomAlertControllerQueue.h"
#include <stdlib.h>




@interface RicoPlayer ()

@property (strong, nonatomic, nullable) id periodicObserver;
@property (strong, nonatomic, nullable) id rangeObserver;
@property (strong, nonatomic, nonnull) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSMapTable * observerMap;
//@property (strong, nonatomic) RicoPlayerChecker * checker; // check to see if the player is stuck seeking
@property (strong, nonatomic) NSTimer  * checkTimer;
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
//        self.checker    = [[RicoPlayerChecker alloc]initWithRicoPlayer:self];
        
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
//        self.checker    = [[RicoPlayerChecker alloc]initWithRicoPlayer:self];
    }
    return self;
}

//-(void)commonInit
//{
//
//
//}


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
    
    
//    NSOperation * playOp = [[RicoPlayOperation alloc]initWithRicoPlayer:self];
    
    
    NSBlockOperation * playOp =  [NSBlockOperation blockOperationWithBlock:^{
//        dispatch_async(dispatch_get_main_queue(), ^{

        if (weakSelf.avPlayer.status == AVPlayerStatusReadyToPlay) {
        
                [weakSelf.avPlayer play];
            if (CMTIME_IS_VALID(weakSelf.avPlayer.currentTime)){
                
                CMTime seekTime = weakSelf.avPlayer.currentTime;
                
                
//                [weakSelf.avPlayer seekToTime:seekTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:nil];
                [weakSelf.avPlayer seekToTime:seekTime completionHandler:^(BOOL finished) {
//                    NSLog(@"PLAY SEEK %@",(finished)?@"pass":@"fail");

                }];
            }
                weakSelf.isPlaying = YES;
//             NSLog(@"PLAY %@",weakSelf.name);
        }
//         });
//        NSLog(@"PLAY BLOCK FINISHED");
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
    pauseOp.name = @"Pause Operation";
    
    [self.operationQueue addOperation:pauseOp];
   
    return pauseOp;
}

-(NSOperation*)seekToTime:(CMTime)time toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter completionHandler:(nullable void (^)(BOOL finished))completionHandler
{
    
    BOOL check = NO;
    NSLog(@"");
    if (check){
        
        CGFloat tt = 1;
        NSLog(@"");
        
        self.offsetTime = CMTimeMakeWithSeconds(tt, NSEC_PER_SEC);
    }
    
    CMTime timeWithOffset = CMTimeAdd(time, self.offsetTime);

    NSLog(@"Seeking to: %f   tolerance: %f / %f ",CMTimeGetSeconds(time),CMTimeGetSeconds(toleranceBefore),CMTimeGetSeconds(toleranceAfter));
    NSLog(@"offsetWitj:     %f      %f",CMTimeGetSeconds(timeWithOffset),CMTimeGetSeconds(self.offsetTime));
    NSOperation * seeker = [[RicoSeekOperation alloc]initWithAVPlayer:_avPlayer seekToTime:timeWithOffset toleranceBefore:toleranceBefore toleranceAfter:toleranceAfter];
    
    [seeker setCompletionBlock:^{
            NSLog(@"Seek finished: %f",CMTimeGetSeconds(self.currentTime));
    }];
//    seeker.completionBlock = completionHandler;
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

    return seeker;
}

-(NSOperation*)preroll:(float)rate
{

    NSOperation * preroll = [[RicoPrerollOperation alloc]initWithRicoPlayer:self rate:rate];
    [self.operationQueue addOperation:preroll];
    return preroll;
}



-(NSOperation*)loadFeed:(Feed *)feed
{
    
    CMTimeRange oldTimeRange = _range;
    
    [self clear];
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(feed))];
    _feed = feed;
    [self didChangeValueForKey: NSStringFromSelector(@selector(feed))];
    
        [self.checkTimer invalidate];
    if (_feed){
        
        self.offsetTime = CMTimeMakeWithSeconds(_feed.offset, NSEC_PER_SEC);
        
//        [_feed addObserver:self forKeyPath:NSStringFromSelector(@selector(quality)) options:0 context:&feedContext];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.checkTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateCheck) userInfo:nil repeats:YES];
        });
        NSURL * url = [_feed path];
        
            _avPlayer               = [AVPlayer playerWithPlayerItem:[[AVPlayerItem alloc] initWithURL:url]];

            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlayToEndTimeNotification:) name:AVPlayerItemDidPlayToEndTimeNotification object:_avPlayer.currentItem];
            [_avPlayer.currentItem addObserver:self forKeyPath:NSStringFromSelector(@selector(status)) options:0 context:&itemContext];
            _avPlayerLayer          = [AVPlayerLayer playerLayerWithPlayer:_avPlayer];
            _avPlayerLayer.frame    = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
//        _avPlayerLayer.contentsCenter = _avPlayerLayer.frame;
//            [_avPlayerLayer setVideoGravity:AVLayerVideoGravityResize];
//        [_avPlayerLayer removeAllAnimations];
//        [self.layer removeAllAnimations];

            [self.layer addSublayer:_avPlayerLayer];

        [_activityIndicator startAnimating];
        _activityIndicator.hidden = NO;
        [self addSubview:_activityIndicator];
        
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
//                [weakSelf addPeriodicTimeObserver];
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
//        [_feed removeObserver:self forKeyPath:NSStringFromSelector(@selector(quality)) context:&feedContext];
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
        [self.operationQueue addOperations:@[self.isReadyOperation] waitUntilFinished:YES];
        
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
        
        AVPlayerItem * zzz =  _avPlayer.currentItem;
        NSArray * xxx = zzz.seekableTimeRanges;
        
        if (_avPlayer.currentItem.seekableTimeRanges.count > 0) {
            CMTimeRange seekableRange = [_avPlayer.currentItem.seekableTimeRanges.firstObject CMTimeRangeValue];
            NSArray * testlist = _avPlayer.currentItem.loadedTimeRanges;
            CMTimeRange loadedRange = [_avPlayer.currentItem.loadedTimeRanges.firstObject CMTimeRangeValue];
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
                        
                        [weakSelf updateDebugOutput];
//                        [weakSelf.checker refreshCoolDown];
                        if (weakSelf.delegate) {
                            [weakSelf.delegate tick:weakSelf];
                        }
                    }];

    
    [self.observerMap setObject:pObserver forKey:self.avPlayer];
    
//    dispatch_async(dispatch_get_main_queue(),^{
//        self.periodicObserver = [self.avPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)
//                                                                   queue:NULL
//                                                              usingBlock:^(CMTime time)
//                        {
//
//                            weakSelf.debugValues[@"rate"] = [NSString stringWithFormat:@"%f",weakSelf.avPlayer.rate];
//                            weakSelf.debugValues[@"now"] = [NSString stringWithFormat:@"Current Time  = %f", CMTimeGetSeconds(weakSelf.avPlayer.currentTime)];
//                            weakSelf.debugValues[@"dur"] = [NSString stringWithFormat:@"Duration Time = %f", CMTimeGetSeconds(weakSelf.duration)];
//                            weakSelf.debugValues[@"op"] = [NSString stringWithFormat:@"Operation Count = %lu", (unsigned long)weakSelf.operationQueue.operationCount];
//                            [weakSelf updateDebugOutput];
//                            if (weakSelf.delegate) {
//                                [weakSelf.delegate tick:weakSelf];
//                            }
//                        }];
//    });
    
    
    
    
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
    [self seekToTime:start toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:nil];

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
      dispatch_async(dispatch_get_main_queue(),^ {
    _debugOutput.text = [NSString stringWithFormat:@"%@\n%@\nrate: %@ \n%@\n%@\n%@\n%@",
                         self.name,
                         _debugValues[@"itemStatus"],
                         _debugValues[@"rate"],
                         _debugValues[@"now"],
                         _debugValues[@"dur"],
                         _debugValues[@"op"],
                         _debugValues[@"offset"]
                         
                         ];
  });
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
    NSLog(@"Rico dealloc %@",self.name);
}

#pragma mark - RJL play methods

#pragma mark -

-(void)updateCheck
{
    BOOL i = NO;
    
    
    if ((CMTimeGetSeconds(self.duration) == 0 && self.isReadyOperation.isFinished)|| i) {
        NSLog(@"PLAYER CRASH");
        PXPLog(@"PLAYER CRASH");
        
        
        
        if (DEBUG_MODE){
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Pxp Player Alert"
                                                                            message:@"Player lost connection, attempting to reconnect"
                                                                     preferredStyle:UIAlertControllerStyleAlert];
            // build NO button
            UIAlertAction* cancelButtons = [UIAlertAction
                                            actionWithTitle:@"OK"
                                            style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action)
                                            {
                                                [[CustomAlertControllerQueue getInstance] dismissViewController:alert animated:YES completion:nil];
                                            }];
            [alert addAction:cancelButtons];
            
            [[CustomAlertControllerQueue getInstance] presentViewController:alert inController:[UIApplication sharedApplication].keyWindow.rootViewController animated:YES style:AlertImportant completion:nil];
        }
        [self reset];
    }
}

-(void)refresh
{
    _avPlayerLayer.player =nil;// self.avPlayer;
    _avPlayerLayer.player =self.avPlayer;
}


-(NSString*)description
{
    return [NSString stringWithFormat:@"RicoPlayer %@: FeedName:%@",self.name,self.feed.sourceName ];
}

@end



























