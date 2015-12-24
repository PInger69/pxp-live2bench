
//
//  RicoPlayer.m
//  Live2BenchNative
//
//  Created by dev on 2015-11-25.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "RicoPlayer.h"
#include <stdlib.h>


@interface RicoPlayer ()

@property (strong, nonatomic, nullable) id periodicObserver;

@end



@implementation RicoPlayer

NSString* const RicoPlayerWillWaitForSynchronizationNotification    = @"RicoPlayerWillWaitForSynchronizationNotification";
NSString* const RicoPlayerDidPlayerItemFailNotification             = @"RicoPlayerDidPlayerItemFailNotification";

@synthesize feed            = _feed;
@synthesize avPlayer        = _avPlayer;
@synthesize avPlayerLayer   = _avPlayerLayer;


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
        [_debugOutput setHidden:YES];
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
        [_debugOutput setHidden:YES];
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

-(NSOperation*)play
{
    __weak RicoPlayer * weakSelf = self;
    NSBlockOperation * playOp =  [NSBlockOperation blockOperationWithBlock:^{
//        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.avPlayer play];
//         });
         NSLog(@"%@ play Operation  %f",weakSelf.name,weakSelf.avPlayer.rate);
    }];
    [self.operationQueue addOperation:playOp];
    return playOp;
}

-(NSOperation*)pause
{
    NSBlockOperation * pauseOp =  [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"%@ pause Operation",self.name);
        [_avPlayer pause];
//        float f = (float)(rand() % 6);
//        NSLog(@"%s",__FUNCTION__);
//        [NSThread sleepForTimeInterval:f];
        
    }];
    
    if (self.syncronized) {
        __weak RicoPlayer * weakSelf = self;
        [pauseOp setCompletionBlock:^{
             self.waitingForSynchronization = YES;
            dispatch_async(dispatch_get_main_queue(),^{
                [[NSNotificationCenter defaultCenter]postNotificationName:RicoPlayerWillWaitForSynchronizationNotification object:weakSelf ];
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




-(void)reset
{
    // get the time
    CMTime time = _avPlayer.currentTime;
    
    self.feed = _feed;
    [self seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
       //Somthing
    }];
}

// Getter setter

-(void)setFeed:(Feed *)feed
{
    // Clear all Queued operations
    [self.operationQueue cancelAllOperations];
    if (_avPlayer){
        [self.avPlayer pause];
        [self.avPlayer.currentItem cancelPendingSeeks];
        [self.avPlayer.currentItem.asset cancelLoading];
    }
    // if there was a feed before remove the observer for it
    if (_feed) {
        [_feed removeObserver:self forKeyPath:NSStringFromSelector(@selector(quality)) context:&feedContext];
    }
    
    // the feed is changed
    [self willChangeValueForKey:NSStringFromSelector(@selector(feed))];
    _feed = feed;
    [self didChangeValueForKey: NSStringFromSelector(@selector(feed))];
    
    
    
    
    // if the feed is nil stop processing
    if (!feed) {
        if (_avPlayer) {
            [self removePlayerTimeObserver];
            [_avPlayer.currentItem removeObserver:self forKeyPath:NSStringFromSelector(@selector(status)) context:&itemContext];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_avPlayer.currentItem];
            _avPlayer               = nil;
        }
        return;
    }
    
    
    if (_avPlayer) {
        [self removePlayerTimeObserver];
        [_avPlayer.currentItem removeObserver:self forKeyPath:NSStringFromSelector(@selector(status)) context:&itemContext];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_avPlayer.currentItem];
    }
    
    [_feed addObserver:self forKeyPath:NSStringFromSelector(@selector(quality)) options:0 context:&feedContext];
    
    
    _avPlayer               = nil;
    _avPlayer               = [AVPlayer playerWithPlayerItem:[[AVPlayerItem alloc] initWithURL:[_feed path]]];
    
    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlayToEndTimeNotification:) name:AVPlayerItemDidPlayToEndTimeNotification object:_avPlayer.currentItem];
    [_avPlayer.currentItem addObserver:self forKeyPath:NSStringFromSelector(@selector(status)) options:0 context:&itemContext];
    
    
    if (_avPlayerLayer){
        [_avPlayerLayer removeFromSuperlayer];
        _avPlayerLayer = nil;
    }
    
    _avPlayerLayer          = [AVPlayerLayer playerLayerWithPlayer:_avPlayer];
    _avPlayerLayer.frame    = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self.layer addSublayer:_avPlayerLayer];
    //
    self.isReadyOperation = [[RicoReadyPlayerItemOperation alloc]initWithPlayerItem:_avPlayer.currentItem];
    
    __weak RicoPlayer * weakSelf = self;
    [self.isReadyOperation setCompletionBlock:^{
        NSLog(@"Player Item is now ready");
        [weakSelf addPeriodicTimeObserver];
    }];
    [self.operationQueue addOperations:@[self.isReadyOperation] waitUntilFinished:NO];
    //    [self.operationQueue addOperation:self.isReadyOperation ];
    
    dispatch_async(dispatch_get_main_queue(),^ {
        [_debugOutput setFrame:CGRectMake(0, 60, self.frame.size.width, 80)];
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


#pragma mark - Synchronization Methods

-(void)setWaitingForSynchronization:(BOOL)waitingForSynchronization
{
    if (!self.syncronized) {
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
    _debugOutput.text = [NSString stringWithFormat:@"%@\n%@\nrate: %@ \n%@\n%@",
                         self.name,
                         _debugValues[@"itemStatus"],
                         _debugValues[@"rate"],
                         _debugValues[@"now"],
                         _debugValues[@"dur"]
                         
                         
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


-(void)dealloc
{

    NSLog(@"Rico dealloc");
}


@end
