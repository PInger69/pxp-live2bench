//
//  PxpPlayer.m
//  PxpPlayer
//
//  Created by Nico Cvitak on 2015-06-16.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import "PxpPlayer.h"

#import <CoreMedia/CoreMedia.h>
#import "PxpLoadAction.h"

#define MAX_SYNCS 3

#define NOTIF_MOTION_ALARM                  @"motionAlarm"

/// The clock used to keep all PxpPlayers in sync.
static CMClockRef _pxpPlayerMasterClock;

@interface PxpPlayer ()

/// An the player's queue of load actions to execute after the player loads.
@property (strong, nonatomic, nonnull) NSMutableArray *loadActionQueue;

/// All the players that would be in the player's context.
@property (readonly, strong, nonatomic, nonnull) NSArray *contextPlayers;

/// The player's range observer.
@property (strong, nonatomic, nullable) id rangeObserver;

/// The player's synchronization observer.
@property (strong, nonatomic, nullable) id syncObserver;

/// The player's prerolling status.
@property (assign, nonatomic) BOOL prerolling;

/// The player's seeking status.
@property (assign, nonatomic) BOOL seeking;

/// The player's syncing status.
@property (assign, nonatomic) BOOL syncing;

/// The number of sync attempt that have been made.
@property (assign, nonatomic) NSUInteger syncs;

@property (copy, nonatomic, nonnull) void(^syncBlock)(CMTime);
@property (strong, nonatomic, nullable) NSTimer *syncTimer;

@property (strong, nonatomic, nonnull) NSTimer *connectionTimer;

@end

@implementation PxpPlayer
{
    void *_statusObserverContext;
    void *_rateObserverContext;
    
    void *_currentItemObserverContext;
}

+ (void)initialize {
    // initialize the master clock so that it does not cause audio drift
    CMAudioClockCreate(kCFAllocatorDefault, &_pxpPlayerMasterClock);
}

- (void)initCommon {
    self.masterClock = _pxpPlayerMasterClock;
    self.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    
    _name = @"";
    
    _live = NO;
    _playRate = 1.0;
    _range = kCMTimeRangeInvalid;
    _syncs = 0;
    _failed = NO;
    
    _loadActionQueue = [NSMutableArray array];
    _statusObserverContext = &_statusObserverContext;
    _rateObserverContext = &_rateObserverContext;
    _currentItemObserverContext = &_currentItemObserverContext;
    
    [self addObserver:self forKeyPath:@"currentItem.status" options:0 context:_statusObserverContext];
    [self addObserver:self forKeyPath:@"rate" options:0 context:_rateObserverContext];
    [self addObserver:self forKeyPath:@"currentItem.seekableTimeRanges" options:0 context:_currentItemObserverContext];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(motionObserved:) name:NOTIF_MOTION_ALARM object:nil];
    
    __block PxpPlayer *player = self;
    
    _syncBlock = ^(CMTime time) {
        [player sync:time];
    };
}

- (nonnull instancetype)initWithPlayerItem:(AVPlayerItem *)item {
    self = [super initWithPlayerItem:item];
    if (self) {
        [self initCommon];
    }
    return self;
}

- (nonnull instancetype)initWithURL:(NSURL *)URL {
    self = [super initWithURL:URL];
    if (self) {
        [self initCommon];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initCommon];
    }
    return self;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"currentItem.status" context:_statusObserverContext];
    [self removeObserver:self forKeyPath:@"rate" context:_rateObserverContext];
    [self removeObserver:self forKeyPath:@"currentItem.seekableTimeRanges" context:_currentItemObserverContext];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_MOTION_ALARM object:nil];
    
    [self.syncTimer invalidate];
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary *)change context:(nullable void *)context {
    
    if (context == _statusObserverContext || context == _currentItemObserverContext) {
        if (self.status != AVPlayerStatusUnknown) {
            
            if (self.currentItem.status == AVPlayerItemStatusFailed) {
                PXPLog(@"%@: %@", self, self.currentItem.error);
                
                
                
                if (self.status == AVPlayerStatusFailed) {
                    
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:self.name message:self.currentItem.error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                     
                     [alert show];
                    
                } else {
                    // reload the asset
                    AVAsset *asset = self.currentItem.asset;
                    if ([asset isKindOfClass:[AVURLAsset class]]) {
                        NSURL *url = ((AVURLAsset *)asset).URL;
                        
                        [self replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:url]];
                    }
                }
                
                
                
                //[self reload];
            }
            
            // run actions
            for (PxpLoadAction *action in self.loadActionQueue) {
                [action runWithSuccess:self.status == AVPlayerStatusReadyToPlay];
            }
            
            // flush
            [self.loadActionQueue removeAllObjects];
        }
        
        
        [self willChangeValueForKey:@"failed"];
        _failed = self.status == AVPlayerStatusFailed;
        [self didChangeValueForKey:@"failed"];
        
        
        
    } else if (context == _rateObserverContext) {
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)replaceCurrentItemWithPlayerItem:(nullable AVPlayerItem *)item {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [super replaceCurrentItemWithPlayerItem:item];
    });
}

- (void)timerTick:(NSTimer *)timer {
    //[self sync:self.currentTime];
    
    return;
    dispatch_async(dispatch_get_main_queue(), ^{
        //self.syncBlock(self.currentTime);
        
        /*
        [self willChangeValueForKey:@"failed"];
        _failed = self.currentItem.status == AVPlayerItemStatusUnknown || self.currentItem.seekableTimeRanges.firstObject;
        [self didChangeValueForKey:@"failed"];
         */
    });
}

#pragma mark - Setters / Getters

- (void)setContext:(nullable PxpPlayerContext *)context {
    if (_context != context) {
        if ([_context containsPlayer:self]) {
            [_context removePlayer:self];
        }
        
        _context = context;
        
        if (![_context containsPlayer:self]) {
            [_context addPlayer:self];
        }
        
    }
}

- (void)setLive:(BOOL)live {
    if (_live != live) {
        _live = live;

        if (live) {
            [self goToLive];
        } else {
            // there cannot be motion if the player is not live
            [self willChangeValueForKey:@"motion"];
            _motion = NO;
            [self didChangeValueForKey:@"motion"];
        }
        
    }
}

- (void)setPlayRate:(float)playRate {
    for (PxpPlayer* player in self.contextPlayers) {
        [player willChangeValueForKey:@"playRate"];
        player->_playRate = playRate;
        [player didChangeValueForKey:@"playRate"];
    }
    _playRate = playRate;
    
    if (self.playing) {
        self.rate = playRate;
    }
}

- (BOOL)playing {
    return self.rate != 0.0;
}

- (void)setRange:(CMTimeRange)range {
    
    if (!CMTimeRangeEqual(range, _range)) {
        
        // can't be live if there is a loop range
        if (CMTIMERANGE_IS_VALID(range)) {
            self.live = NO;
        }
        
        // remove any existing range observers
        for (PxpPlayer *player in self.contextPlayers) {
            [player willChangeValueForKey:@"range"];
            
            player->_range = range;
            
            
            [player removeTimeObserver:player.rangeObserver];
            player.rangeObserver = nil;
            
            [player didChangeValueForKey:@"range"];
        }
        
        if (CMTIMERANGE_IS_VALID(range)) {
            // get start and end times
            CMTime start = range.start, end = CMTimeAdd(start, range.duration);
            
            // create a boundary observer at the range end points
            __block PxpPlayer *player = self;
            self.rangeObserver = [self addBoundaryTimeObserverForTimes:@[[NSValue valueWithCMTime:end]] queue:NULL usingBlock:^() {
                
                float rate = player.rate;
                [player pause];
                [player seekToTime:start toleranceBefore:kCMTimePositiveInfinity toleranceAfter:kCMTimeZero completionHandler:^(BOOL complete) {
                    [player prerollAtRate:rate completionHandler:^(BOOL complete) {
                        [player setRate:rate];
                    }];
                }];
                
            }];
            
            if (!CMTimeRangeContainsTime(range, self.currentTime)) {
                float rate = player.rate;
                [player pause];
                [player seekToTime:start toleranceBefore:kCMTimePositiveInfinity toleranceAfter:kCMTimeZero completionHandler:^(BOOL complete) {
                    [player prerollAtRate:rate completionHandler:^(BOOL complete) {
                        [player setRate:rate];
                    }];
                }];
            }
            
        }
        
    }
}

- (void)setSyncInterval:(CMTime)syncInterval {
    if (CMTimeCompare(syncInterval, _syncInterval) != 0) {
        
        for (PxpPlayer *player in self.contextPlayers) {
            [player willChangeValueForKey:@"syncInterval"];
            player->_syncInterval = syncInterval;
            
            [player removeTimeObserver:player.syncObserver];
            player.syncObserver = nil;
            
            [player.syncTimer invalidate];
            player.syncTimer = nil;
            
            [player didChangeValueForKey:@"syncInterval"];
        }
        
        //self.syncTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
        
        self.syncObserver = [self addPeriodicTimeObserverForInterval:syncInterval queue:NULL usingBlock:_syncBlock];
        
    }
}

- (CMTime)duration {
    CMTime duration = self.currentItem.duration;
    if (self.currentItem.seekableTimeRanges.count > 0) {
        CMTimeRange seekableRange = [self.currentItem.seekableTimeRanges.firstObject CMTimeRangeValue];
        duration = CMTimeAdd(seekableRange.start, seekableRange.duration);
    }
    return duration;
}

- (CMTime)remainingTime {
    return CMTimeSubtract(self.duration, self.currentTime);
}

- (nonnull NSArray *)contextPlayers {
    return self.context ? self.context.players : @[self];
}

#pragma mark - Context Control

- (void)setRate:(float)rate multi:(BOOL)multi {
    if (self.status != AVPlayerStatusReadyToPlay) return;
    if (multi) {
        for (PxpPlayer *player in self.contextPlayers) [player setRate:rate multi:NO];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^() {
            [super setRate:rate time:kCMTimeInvalid atHostTime:CMClockGetTime(_pxpPlayerMasterClock)];
            [super setRate:rate];
        });
    }
}

- (void)setRate:(float)rate multi:(BOOL)multi time:(CMTime)itemTime atHostTime:(CMTime)hostClockTime {
    if (self.status != AVPlayerStatusReadyToPlay) return;
    if (multi) {
        for (PxpPlayer *player in self.contextPlayers) [player setRate:rate multi:NO time:itemTime atHostTime:hostClockTime];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^() {
            [super setRate:rate time:itemTime atHostTime:hostClockTime];
        });
    }
}

- (void)prerollAtRate:(float)rate multi:(BOOL)multi completionHandler:(nonnull void (^)(BOOL))completionHandler {
    
    if (multi) {
        self.prerolling = YES;
        
        NSUInteger total = self.contextPlayers.count;
        
        __block NSUInteger tried = 0;
        __block NSUInteger complete = 0;
        
        void (^handler)(BOOL) = ^(BOOL success) {
            tried++, complete += success ? 1 : 0;
            
            if (tried >= total) {
                completionHandler(complete >= total);
                self.prerolling = NO;
            }
        };
        
        for (PxpPlayer *player in self.contextPlayers) [player prerollAtRate:rate multi:NO completionHandler:handler];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^() {
            [super cancelPendingPrerolls];
            if (self.status != AVPlayerStatusReadyToPlay) {
                completionHandler(NO);
            } else {
                [super prerollAtRate:rate completionHandler:completionHandler];
            }
        });
        
    }
}

- (void)cancelPendingPrerollsMulti:(BOOL)multi {
    if (self.status != AVPlayerStatusReadyToPlay) return;
    if (multi) {
        for (PxpPlayer *player in self.contextPlayers) [player cancelPendingPrerollsMulti:NO];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^() {
            [super cancelPendingPrerolls];
        });
    }
}

- (void)seekToDate:(nonnull NSDate *)date multi:(BOOL)multi completionHandler:(nonnull void (^)(BOOL))completionHandler {
    if (self.status != AVPlayerStatusReadyToPlay) return;
    if (multi) {
        self.seeking = YES;
        NSUInteger total = self.contextPlayers.count;
        
        __block NSUInteger tried = 0;
        __block NSUInteger complete = 0;
        
        void (^handler)(BOOL) = ^(BOOL success) {
            tried++, complete += success ? 1 : 0;
            
            if (tried >= total) {
                self.seeking = NO;
                completionHandler(complete >= total);
            }
        };
        
        for (PxpPlayer *player in self.contextPlayers) [player seekToDate:date multi:NO completionHandler:handler];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^() {
            [super seekToDate:date completionHandler:^(BOOL success) {
                completionHandler(success);
            }];
        });
    }
}

- (void)seekToTime:(CMTime)time multi:(BOOL)multi toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter completionHandler:(nonnull void (^)(BOOL))completionHandler {
    time = [self clampTime:time];
    
    if (multi) {
        self.seeking = YES;
        NSUInteger total = self.contextPlayers.count;
        
        __block NSUInteger tried = 0;
        __block NSUInteger complete = 0;
        
        void (^handler)(BOOL) = ^(BOOL success) {
            tried++, complete += success ? 1 : 0;
            
            if (tried >= total) {
                completionHandler(complete >= total);
                self.seeking = NO;
            }
        };
        
        for (PxpPlayer *player in self.contextPlayers) [player seekToTime:time multi:NO toleranceBefore:toleranceBefore toleranceAfter:toleranceAfter completionHandler:handler];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (tried < total) {
                [self cancelPendingSeeks];
            }
        });
    } else {
        
        if (CMTIME_IS_INDEFINITE(time)) {
            time = kCMTimePositiveInfinity;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self.currentItem cancelPendingSeeks];
            if (self.status != AVPlayerStatusReadyToPlay || CMTIME_IS_INVALID(time)) {
                completionHandler(NO);
            } else if (CMTimeCompare(toleranceBefore, kCMTimePositiveInfinity) == 0 && CMTimeCompare(toleranceAfter, kCMTimePositiveInfinity) == 0) {
                [super seekToTime:time completionHandler:completionHandler];
            } else {
                [super seekToTime:time toleranceBefore:toleranceBefore toleranceAfter:toleranceAfter completionHandler:completionHandler];
            }
        });
        
    }
}

#pragma mark - Overrides

- (nullable NSString *)description {
    return [NSString stringWithFormat:@"%@(%@)", [super description], self.name];
}

- (void)play {
    [self setRate:self.playRate];
}

- (void)setRate:(float)rate {
    if (self.live && rate != 1.0) self.live = NO;
    [self setRate:rate multi:YES];
}

- (void)setRate:(float)rate time:(CMTime)itemTime atHostTime:(CMTime)hostClockTime {
    if (self.live && rate != 1.0) self.live = NO;
    [self setRate:rate multi:YES time:itemTime atHostTime:hostClockTime];
}

- (void)prerollAtRate:(float)rate completionHandler:( void (^)(BOOL))completionHandler {
    if (!completionHandler) completionHandler = ^(BOOL complete) {};
    if (rate != 0.0) {
        [self prerollAtRate:rate multi:YES completionHandler:completionHandler];
    } else {
        completionHandler(YES);
    }
    
}

- (void)seekToDate:(nonnull NSDate *)date {
    self.live = NO;
    [self seekToDate:date multi:YES completionHandler:^(BOOL finished) {}];
}

- (void)seekToDate:(nonnull NSDate *)date completionHandler:(nonnull void (^)(BOOL))completionHandler {
    self.live = NO;
    [self seekToDate:date multi:YES completionHandler:completionHandler];
}

- (void)seekToTime:(CMTime)time {
    if (self.live && CMTimeCompare(time, self.duration) != 0) self.live = NO;
    [self seekToTime:time multi:YES toleranceBefore:kCMTimePositiveInfinity toleranceAfter:kCMTimePositiveInfinity completionHandler:^(BOOL finished) {}];
}

- (void)seekToTime:(CMTime)time completionHandler:(nonnull void (^)(BOOL))completionHandler {
    if (self.live && CMTimeCompare(time, self.duration) != 0) self.live = NO;
    [self seekToTime:time multi:YES toleranceBefore:kCMTimePositiveInfinity toleranceAfter:kCMTimePositiveInfinity completionHandler:completionHandler];
}

- (void)seekToTime:(CMTime)time toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter {
    if (self.live && CMTimeCompare(time, self.duration) != 0) self.live = NO;
    [self seekToTime:time toleranceBefore:toleranceBefore toleranceAfter:toleranceAfter completionHandler:^(BOOL finished) {}];
}

- (void)seekToTime:(CMTime)time toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter completionHandler:(nonnull void (^)(BOOL))completionHandler {
    if (self.live && CMTimeCompare(time, self.duration) != 0) self.live = NO;
    [self seekToTime:time multi:YES toleranceBefore:toleranceBefore toleranceAfter:toleranceAfter completionHandler:completionHandler];
}

- (void)cancelPendingPrerolls {
    [self cancelPendingPrerollsMulti:YES];
}

#pragma mark - Notification Handlers

- (void)motionObserved:(NSNotification *)note {
    
    // we only care about motion if the player is live
    if (self.live) {
        [self willChangeValueForKey:@"motion"];
        _motion = [note.userInfo[@"alarms"] containsObject:self.name];
        [self didChangeValueForKey:@"motion"];
    }
}

#pragma mark - Public Methods

- (void)seekBy:(CMTime)time {
    [self seekToTime:CMTimeAdd(self.currentTime, time) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (void)seekBy:(CMTime)time completionHandler:(nullable void (^)(BOOL finished))completionHandler {
    [self seekToTime:CMTimeAdd(self.currentTime, time) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:completionHandler];
}

- (void)cancelPendingSeeks {
    for (PxpPlayer *player in self.contextPlayers) {
        [player.currentItem cancelPendingSeeks];
    }
}

- (void)addLoadAction:(nonnull PxpLoadAction *)loadAction {
    const NSUInteger total = self.contextPlayers.count;
    
    __block NSUInteger tried = 0;
    __block NSUInteger complete = 0;
    
    void (^handler)(BOOL) = ^(BOOL ready) {
        tried++;
        complete += ready ? 1 : 0;
        
        NSLog(@"tried: %lu, total: %lu", (unsigned long)tried, (unsigned long)total);
        if (tried >= total) {
            [loadAction runWithSuccess:complete >= total];
        }
    };
    
    for (PxpPlayer *player in self.contextPlayers) {
        if (player.currentItem.status == AVPlayerStatusUnknown) {
            [player.loadActionQueue addObject:[PxpLoadAction loadActionWithBlock:handler]];
        } else {
            handler(player.currentItem.status == AVPlayerStatusReadyToPlay);
        }
    }
}

- (void)sync {
    PxpPlayer *player = self.context.mainPlayer ? self.context.mainPlayer : self;
    
    player.syncing = NO;
    [player sync:player.currentTime];
}

- (void)reload {
    static BOOL canReload = YES;
    
    if (canReload && self.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        canReload = NO;
        
        AVPlayerItem *item = self.currentItem;
        [self replaceCurrentItemWithPlayerItem:nil];
        [self replaceCurrentItemWithPlayerItem:item];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            canReload = YES;
        });
    }
}

#pragma mark - Private Methods

/// Clamps the specified time to the loop range
- (CMTime)clampTime:(CMTime)time {
    if (CMTIMERANGE_IS_VALID(self.range) && !CMTimeRangeContainsTime(self.range, time)) {
        return self.range.start;
    } else {
        return time;
    }
}

/// Makes the player play from live
- (void)goToLive {
    if (self.live) {
        if (!self.syncing) {
            self.syncing = YES;
            // invalidate the range
            self.range = kCMTimeRangeInvalid;
            
            [self seekToTime:kCMTimePositiveInfinity multi:YES toleranceBefore:kCMTimePositiveInfinity toleranceAfter:kCMTimePositiveInfinity completionHandler:^(BOOL complete){
                
                [self play];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.syncing = NO;
                });
                
                /*
                [self prerollAtRate:self.playRate completionHandler:^(BOOL complete) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self setRate:self.playRate];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            self.syncing = NO;
                        });
                    });
                }];
                 */
            }];
            
            [self willChangeValueForKey:@"live"];
            _live = YES;
            [self didChangeValueForKey:@"live"];
        }
    } else {
        self.live = YES;
    }
    
}

/// Synchronizes all other players to the player
- (void)sync:(CMTime)currentTime {
    
    if (CMTIMERANGE_IS_VALID(self.range)) {
        return;
    }
    
    static CMTime smartSync;
    if (!CMTIME_IS_NUMERIC(smartSync)) {
        smartSync = kCMTimeZero;
    }
    
    if (CMTIME_IS_NUMERIC(self.syncThreshold) && !self.prerolling && !self.seeking && !self.syncing && self.rate != 0.0) {
        // calculate time distribution among players
        CMTime distribution = kCMTimeZero;
        CMTime average = kCMTimeZero;
        for (PxpPlayer *player in self.contextPlayers) {
            if (player != self) {
                CMTime difference = CMTimeSubtract(currentTime, player.currentTime);
                
                distribution = CMTimeMaximum(distribution, CMTimeAbsoluteValue(difference));
                average = CMTimeAdd(average, CMTIME_IS_NUMERIC(difference) ? difference : kCMTimeZero);
            }
        }
        
        BOOL synced = CMTimeCompare(distribution, self.syncThreshold) <= 0;
        
        if (self.contextPlayers.count > 1) {
            Float64 f = 1.0 / (self.contextPlayers.count - 1);
            average = CMTimeMultiplyByFloat64(average, f);
        }
        
        if (!synced && CMTimeCompare(CMTimeAbsoluteValue(average), CMTimeMake(10, 1)) < 0) {
            smartSync = CMTimeMaximum(CMTimeAdd(smartSync, average), kCMTimeZero);
        }
        
        /*
        NSLog(@"DIST: %f", CMTimeGetSeconds(distribution));
        NSLog(@"AVG: %f", CMTimeGetSeconds(average));
        NSLog(@"SMRT: %f", CMTimeGetSeconds(smartSync));
         */
        
        if (self.live) {
            synced = synced && CMTimeCompare(self.remainingTime, CMTimeMake(5, 1)) <= 0;
        }
        
        
        if (synced) {
            // players in sync
            self.syncing = 0;
            self.syncs = 0;
            //NSLog(@"Players SYNCED!");
            
        } else if (self.live && CMTIMERANGE_IS_INVALID(self.range)) {
            NSLog(@"Syncing (Live)");
            [self goToLive];
            
        }/* else if (self.syncs < MAX_SYNCS && NO) {
            if (self.live) {
                NSLog(@"Syncing (Live)");
                [self goToLive];
            } else {
                NSLog(@"Syncing (Freeze)");
                self.syncing = YES;
                [self pause];
                [self seekToTime:currentTime multi:YES toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL complete){
                    [self prerollAtRate:self.playRate completionHandler:^(BOOL complete) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            
                            [self setRate:self.playRate];
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                self.syncing = NO;
                            });
                        });
                    }];
                }];
            }
            
            self.syncs++;
           } */ else {
               
            NSLog(@"Syncing (Adaptive)");
            
            self.syncing = YES;
            for (PxpPlayer *player in self.contextPlayers) {
                if (player != self) {
                    
                    
                    [player seekToTime:CMTimeAdd(currentTime, smartSync) multi:NO toleranceBefore:kCMTimePositiveInfinity toleranceAfter:kCMTimePositiveInfinity completionHandler:^(BOOL complete) {
                        
                        // ensure no players get stuck
                        for (PxpPlayer *player in self.contextPlayers) {
                            if (player.rate == 0.0) {
                                [player setRate:self.playRate multi:NO];
                            }
                        }
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            self.syncing = NO;
                        });
                        
                    }];
                    
                    /*
                    [player seekToTime:currentTime multi:NO toleranceBefore:kCMTimeZero toleranceAfter:kCMTimePositiveInfinity completionHandler:^(BOOL complete) {
                    
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            self.syncing = NO;
                        });
                    }];
                     */
                }
            }
        }
    }
}

#pragma mark - PxpTimeProvider

- (NSTimeInterval)currentTimeInSeconds {
    return CMTimeGetSeconds(self.currentTime);
}

@end
