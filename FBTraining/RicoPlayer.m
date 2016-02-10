

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
@property (strong, nonatomic, nonnull) UIActivityIndicatorView *activityIndicator;

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
        self.debugValues[@"now"]        = [NSString stringWithFormat:@"Current Time  = %f", CMTimeGetSeconds(self.avPlayer.currentTime)];
        self.debugValues[@"dur"]        = [NSString stringWithFormat:@"Duration Time = %f", CMTimeGetSeconds(self.duration)];

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
                
                [weakSelf.avPlayer seekToTime:seekTime completionHandler:^(BOOL finished) {
                    NSLog(@"PLAY SEEK %@",(finished)?@"pass":@"fail");

                }];
            }
                weakSelf.isPlaying = YES;
             NSLog(@"PLAY %@",weakSelf.name);
        }
//         });
        NSLog(@"PLAY BLOCK FINISHED");
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
//        [_feed addObserver:self forKeyPath:NSStringFromSelector(@selector(quality)) options:0 context:&feedContext];
        
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
            [_debugOutput setFrame:CGRectMake(0, 10, self.frame.size.width, 80)];
            [weakSelf addSubview:_debugOutput];
            [weakSelf updateDebugOutput];
        });
        
        return self.isReadyOperation;
        
        
    }
    dispatch_async(dispatch_get_main_queue(),^ {
        [_debugOutput setFrame:CGRectMake(0, 10, self.frame.size.width, 80)];
        [self addSubview:_debugOutput];
        [self updateDebugOutput];
    });
    return nil;
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
//        [_feed removeObserver:self forKeyPath:NSStringFromSelector(@selector(quality)) context:&feedContext];
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
    
    
    if (_feed){
//        [_feed addObserver:self forKeyPath:NSStringFromSelector(@selector(quality)) options:0 context:&feedContext];
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
            [_debugOutput setFrame:CGRectMake(0, 10, self.frame.size.width, 80)];
            [weakSelf addSubview:_debugOutput];
            [weakSelf updateDebugOutput];
        });
        
    
    }
    

}

-(void)didPlayToEndTimeNotification:(NSNotification*)note
{
    if (self.looping){
        
        
        
        (void)[self pause];
   
        [self.operationQueue addOperationWithBlock:^{
            [_avPlayer seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
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
    if (self.periodicObserver)
    {
//        dispatch_async(dispatch_get_main_queue(),^{
            [self.avPlayer removeTimeObserver:self.periodicObserver];
            self.periodicObserver = nil;
//        });
    }
}


-(void)addPeriodicTimeObserver
{
    double                      interval        = 0.5f;
    __weak RicoPlayer          * weakSelf      = self;

//    dispatch_async(dispatch_get_main_queue(),^{
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
      dispatch_async(dispatch_get_main_queue(),^ {
    _debugOutput.text = [NSString stringWithFormat:@"%@\n%@\nrate: %@ \n%@\n%@\n%@",
                         self.name,
                         _debugValues[@"itemStatus"],
                         _debugValues[@"rate"],
                         _debugValues[@"now"],
                         _debugValues[@"dur"],
                         _debugValues[@"op"]
                         
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
//- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys
//{
//    /* Make sure that the value of each key has loaded successfully. */
//    for (NSString *thisKey in requestedKeys)
//    {
//        NSError *error = nil;
//        AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
//        if (keyStatus == AVKeyValueStatusFailed)
//        {
//            [self assetFailedToPrepareForPlayback:error];
//            return;
//        }
//        /* If you are also implementing -[AVAsset cancelLoading], add your code here to bail out properly in the case of cancellation. */
//    }
//    
//    /* Use the AVAsset playable property to detect whether the asset can be played. */
//    if (!asset.playable)
//    {
//        /* Generate an error describing the failure. */
//        NSString *localizedDescription = NSLocalizedString(@"Item cannot be played", @"Item cannot be played description");
//        NSString *localizedFailureReason = NSLocalizedString(@"The assets tracks were loaded, but could not be made playable.", @"Item cannot be played failure reason");
//        NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
//                                   localizedDescription, NSLocalizedDescriptionKey,
//                                   localizedFailureReason, NSLocalizedFailureReasonErrorKey,
//                                   nil];
//        NSError *assetCannotBePlayedError = [NSError errorWithDomain:@"StitchedStreamPlayer" code:0 userInfo:errorDict];
//        
//        /* Display the error to the user. */
//        [self assetFailedToPrepareForPlayback:assetCannotBePlayedError];
//        
//        return;
//    }
//    
//    /* At this point we're ready to set up for playback of the asset. */
//    
//    /* Stop observing our prior AVPlayerItem, if we have one. */
//    if (self.playerItem)
//    {
//        /* Remove existing player item key value observers and notifications. */
//        
//        [self.playerItem removeObserver:self forKeyPath:@"status"];
//        
//        [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                        name:AVPlayerItemDidPlayToEndTimeNotification
//                                                      object:self.playerItem];
//    }
//    
//    /* Create a new instance of AVPlayerItem from the now successfully loaded AVAsset. */
//    self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
//    
//    
//    
//    /* Observe the player item "status" key to determine when it is ready to play. */
//    [self.playerItem addObserver:self
//                      forKeyPath:@"status"
//                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
//                         context:&ViewControllerStatusObservationContext];
//    
//    /* When the player item has played to its end time we'll toggle
//     the movie controller Pause button to be the Play button */
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(playerItemDidReachEnd:)
//                                                 name:AVPlayerItemDidPlayToEndTimeNotification
//                                               object:self.playerItem];
//    
//    //Why????????????????????????No?????????
//    seekToZeroBeforePlay = NO;
//    
//    /* Create new player, if we don't already have one. */
//    if (!self.avPlayer)
//    {
//        /* Get a new AVPlayer initialized to play the specified player item. */
//        //[self setPlayer:[AVPlayer playerWithPlayerItem:self.playerItem]];
//        
//        
//        //[self.playBackView setPlayer:self.avPlayer];
//        
//        /* Observe the AVPlayer "currentItem" property to find out when any
//         AVPlayer replaceCurrentItemWithPlayerItem: replacement will/did
//         occur.*/
//        [self.avPlayer addObserver:self
//                        forKeyPath:@"currentItem"
//                           options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
//                           context:ViewControllerCurrentItemObservationContext];
//        
//        /* Observe the AVPlayer "rate" property to update the scrubber control. */
//        [self.avPlayer addObserver:self
//                        forKeyPath:@"rate"
//                           options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
//                           context:ViewControllerRateObservationContext];
//        self.avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndPause;
//    }
//    
//    [self.playBackView setPlayer:self.avPlayer];
//    
//    /* Make our new AVPlayerItem the AVPlayer's current item. */
//    if (self.avPlayer.currentItem != self.playerItem)
//    {
//        /* Replace the player item with a new player item. The item replacement occurs
//         asynchronously; observe the currentItem property to find out when the
//         replacement will/did occur
//         
//         If needed, configure player item here (example: adding outputs, setting text style rules,
//         selecting media options) before associating it with a player
//         */
//        [self.avPlayer replaceCurrentItemWithPlayerItem:self.playerItem];
//        
//        //        [self syncPlayPauseButtons];
//    }
//    
//    //    [self.mScrubber setValue:0.0];
//    
//    _status = _status | RJLPS_Play;
//    
//    if (onFeedReadyBlock) {
//        onFeedReadyBlock();
//    }// if there is a place to seek to when ready
//    
//}
//
//-(void)assetFailedToPrepareForPlayback:(NSError *)error
//{
//    [self removePlayerTimeObserver];
//    //    [self syncControlBar];
//    //    [self disableScrubber];
//    //    [self disablePlayerButtons];
//    //
//    /* Display the error. */
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
//                                                        message:[error localizedFailureReason]
//                                                       delegate:nil
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil];
//    [alertView show];
//    
//    PXPLog(@"*** VIDEO PLAYER ERROR");
//    PXPLog(@"%@",error);
//    PXPLog(@"**********");
//}

-(void)refresh
{
    _avPlayerLayer.player =nil;// self.avPlayer;
    _avPlayerLayer.player =self.avPlayer;
}

@end
