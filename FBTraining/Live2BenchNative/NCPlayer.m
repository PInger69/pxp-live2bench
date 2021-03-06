//
//  NCPlayer.m
//  iOS Workspace
//
//  Created by Nico Cvitak on 2015-05-26.
//  Copyright (c) 2015 Nicholas Cvitak. All rights reserved.
//

#import "NCPlayer.h"

#define DEFAULT_SYNC_THRESHOLD 3.333
#define DEFAULT_MAX_SYNCS 3
#define DEFAULT_SYNC_WAIT_TIME 5

@interface NCPlayerContext ()

@property (strong, nonatomic, nonnull) NSMutableSet *playerSet;

@end

@interface NCPlayer ()

@property (readonly, nonatomic, nonnull) NSArray *contextPlayers;
@property (strong, nonatomic, nonnull) NSMutableArray *readyToPlayActionQueue;

@property (assign, nonatomic) BOOL seeking;
@property (assign, nonatomic) BOOL prerolling;

@property (assign, nonatomic) NSUInteger nSync;

@end

@implementation NCPlayer
{
    void *_statusContext;
    
    id _loopPeriodicObserver;
    id _loopBoundaryObserver;
    
    id _syncPeriodicObserver;
}

@synthesize context = _context;

- (void)initCommon {
    _statusContext = &_statusContext;
    
    self.masterClock = CMClockGetHostTimeClock();
    self.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    self.readyToPlayActionQueue = [NSMutableArray array];
    self.syncThreshold = CMTimeMakeWithSeconds(DEFAULT_SYNC_THRESHOLD, NSEC_PER_SEC);
    self.maximumSyncs = DEFAULT_MAX_SYNCS;
    self.syncWaitTime = CMTimeMakeWithSeconds(DEFAULT_SYNC_WAIT_TIME, NSEC_PER_SEC);
    
    [self addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:_statusContext];
}

- (instancetype)initWithPlayerItem:(AVPlayerItem *)item {
    self = [super initWithPlayerItem:item];
    if (self) {
        [self initCommon];
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)URL {
    AVURLAsset *urlAsset = [[AVURLAsset alloc] initWithURL:URL options:@{ AVURLAssetPreferPreciseDurationAndTimingKey: @YES }];
    return [self initWithPlayerItem:[[AVPlayerItem alloc] initWithAsset:urlAsset]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initCommon];
    }
    return self;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"status" context:_statusContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == _statusContext && self.status != AVPlayerItemStatusUnknown) {
        for (void (^action)(BOOL) in self.readyToPlayActionQueue) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                action(self.status == AVPlayerStatusReadyToPlay);
            });
        }
        [self.readyToPlayActionQueue removeAllObjects];
    }
}

#pragma mark - Getters / Setters

- (nonnull NSArray *)contextPlayers {
    //if there is no group we are the only player in the group
    return self.context ? self.context.players : @[self];
}

- (void)setContext:(nullable NCPlayerContext *)context {
    if (context != _context) {
        [_context.playerSet removeObject:self];
        _context = context;
        [_context.playerSet addObject:self];
    }
}

- (nullable NCPlayerContext *)context {
    return _context;
}

- (CMTime)duration {
    
    CMTimeRange seekableRange = [self.currentItem.seekableTimeRanges.firstObject CMTimeRangeValue];
    CMTime duration = CMTimeAdd(seekableRange.start, seekableRange.duration);
    
    // the time returned will not cause any errors :D
    return CMTIME_IS_NUMERIC(duration) ? duration : kCMTimeZero;
}

- (void)setLoopRange:(CMTimeRange)loopRange {
    
    if (!CMTimeRangeEqual(loopRange, _loopRange)) {
        
        // remove loop observers of other player in group
        for (NCPlayer *player in self.contextPlayers) {
            [player removeTimeObserver:player->_loopPeriodicObserver];
            [player removeTimeObserver:player->_loopBoundaryObserver];
            
            _loopPeriodicObserver = nil;
            _loopBoundaryObserver = nil;
            
            [player willChangeValueForKey:@"loopRange"];
            player->_loopRange = loopRange;
            [player didChangeValueForKey:@"loopRange"];
        }
        
        // if the range is valid add the appropriate observers
        if (CMTIMERANGE_IS_VALID(loopRange)) {
            CMTime end = CMTimeAdd(loopRange.start, loopRange.duration);
            
            __block NCPlayer *_self = self;
            
            /*
            _loopPeriodicObserver = [self addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
                
                if (CMTimeCompare(time, loopRange.start) < 0 || CMTimeCompare(time, end) > 0) {
                    float rate = _self.rate;
                    
                    [_self pause];
                    [_self seekToTime:loopRange.start toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL seekComplete) {
                        [_self setRate:rate];
                    }];
                    
                }
                
            }];
             */
            
            float rate = self.rate;
            
            [self pause];
            [self seekToTime:loopRange.start toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL seekComplete) {
                
                if (rate != 0.0) {
                    [self prerollAtRate:rate completionHandler:^(BOOL prerollComplete) {
                        [self setRate:rate];
                    }];
                }
                
            }];
            
            _loopBoundaryObserver = [self addBoundaryTimeObserverForTimes:@[[NSValue valueWithCMTime:end]] queue:dispatch_get_main_queue() usingBlock:^{
                
                float rate = _self.rate;
                
                [_self pause];
                [_self seekToTime:loopRange.start toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL seekComplete) {
                    [_self setRate:rate];
                }];
            }];
        }
        
    }
    
}

- (void)setSyncInterval:(CMTime)syncInterval {
    for (NCPlayer *player in self.contextPlayers) {
        [player removeTimeObserver:player->_syncPeriodicObserver];
        player->_syncPeriodicObserver = nil;
        player->_syncInterval = syncInterval;
    }
    
    if (CMTIME_IS_NUMERIC(syncInterval)) {
        __block NCPlayer *_self = self;
        
        _syncPeriodicObserver = [self addPeriodicTimeObserverForInterval:syncInterval queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            
            if (!_self.seeking && !_prerolling && CMTIME_IS_NUMERIC(_self.syncThreshold)) {
                // first calculate the maximum time difference
                CMTime max = kCMTimeZero;
                for (NCPlayer *player in _self.contextPlayers) {
                    CMTime diff = CMTimeAbsoluteValue(CMTimeSubtract(_self.currentTime, player.currentTime));
                    max = CMTimeMaximum(max, diff);
                }
                
                if (CMTimeCompare(max, _self.syncThreshold) > 0) {
                    _self.nSync++;
                    if (_self.maximumSyncs == 0 || _self.nSync < _self.maximumSyncs) {
                        [_self setRate:_self.rate atTime:time];
                    } else {
                        // sync failed
                        NSLog(@"NCPLAYER SYNC FAILED!");
                        
                        CMTime syncInterval = _self.syncInterval;
                        
                        _self.syncInterval = kCMTimePositiveInfinity;
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(CMTimeGetSeconds(_self.syncWaitTime) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            _self.syncInterval = syncInterval;
                        });
                        
                        _self.nSync = 0;
                    }
                } else {
                    _self.nSync = 0;
                }
            }
            
        }];
    }
}

- (void)setSlomo:(BOOL)slomo {
    _slomo = slomo;
    
    if (self.rate != 0.0) {
        self.rate = slomo ? 0.5 : 1.0;
    }

//    if ((self.rate-PAUSE_RATE)> PAUSE_RATE ) {
//        self.rate = slomo ? 0.5 : 1.0;
//    }
}

#pragma mark - Public Methods

- (void)setURL:(nonnull NSURL *)URL {
    AVURLAsset *urlAsset = [[AVURLAsset alloc] initWithURL:URL options:@{ AVURLAssetPreferPreciseDurationAndTimingKey: @YES}];
    [self replaceCurrentItemWithPlayerItem:[[AVPlayerItem alloc] initWithAsset:urlAsset]];
}

- (void)addReadyToPlayObserver:(nonnull void (^)(BOOL))readyBlock {
    if (self.status == AVPlayerStatusUnknown) {
        [self.readyToPlayActionQueue addObject:readyBlock];
    } else {
        readyBlock(self.status == AVPlayerStatusReadyToPlay);
    }
}

- (void)sync {
    [self setRate:self.rate atTime:self.currentTime];
}

- (void)prerollAndPlayAtRate:(float)rate {
    if (rate != 0.0) {
        [self prerollAtRate:rate completionHandler:^(BOOL prerolled) {
            //delay just in case ;)
            dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
            dispatch_after(delay, dispatch_get_main_queue(), ^{
                [self setRate:rate];
            });
        }];
    }
}

- (void)seekBy:(CMTime)time {
    CMTime newTime = CMTimeAdd(self.currentTime, time);
    
    [self seekToTime:newTime completionHandler:^(BOOL finish) {
        
    }];
}

#pragma mark - Multi Player Methods

- (void)setRate:(float)rate multi:(BOOL)multi {
    if (multi) {
        for (NCPlayer *player in self.contextPlayers) [player setRate:rate multi:NO];
    } else {
        [super setRate:rate];
    }
}

- (void)setRate:(float)rate multi:(BOOL)multi time:(CMTime)itemTime atHostTime:(CMTime)hostClockTime {
    if (multi) {
        for (NCPlayer *player in self.contextPlayers) [player setRate:rate multi:NO time:itemTime atHostTime:hostClockTime];
    } else {
        [super setRate:rate time:itemTime atHostTime:hostClockTime];
    }
}

- (void)prerollAtRate:(float)rate multi:(BOOL)multi completionHandler:(nonnull void (^)(BOOL))completionHandler {
    if (multi) {
        NSUInteger total = self.contextPlayers.count;
        
        __block NSUInteger tried = 0;
        __block NSUInteger complete = 0;
        
        void (^handler)(BOOL) = ^(BOOL success) {
            tried++, complete += success ? 1 : 0;
            
            if (tried == total) {
                completionHandler(total == complete);
            }
        };
        
        for (NCPlayer *player in self.contextPlayers) [player prerollAtRate:rate multi:NO completionHandler:handler];
    } else {
        self.prerolling = YES;
        [super prerollAtRate:rate completionHandler:^(BOOL success) {
            completionHandler(success);
            self.prerolling = NO;
        }];
    }
}

- (void)cancelPendingPrerollsMulti:(BOOL)multi {
    if (multi) {
        for (NCPlayer *player in self.contextPlayers) [player cancelPendingPrerollsMulti:NO];
    } else {
        [super cancelPendingPrerolls];
    }
}

- (void)seekToDate:(nonnull NSDate *)date multi:(BOOL)multi {
    if (multi) {
        for (NCPlayer *player in self.contextPlayers) [player seekToDate:date multi:NO];
    } else {
        self.seeking = YES;
        [super seekToDate:date completionHandler:^(BOOL success) {
            self.seeking = NO;
        }];
    }
}

- (void)seekToDate:(nonnull NSDate *)date multi:(BOOL)multi completionHandler:(nonnull void (^)(BOOL))completionHandler {
    if (multi) {
        NSUInteger total = self.contextPlayers.count;
        
        __block NSUInteger tried = 0;
        __block NSUInteger complete = 0;
        
        void (^handler)(BOOL) = ^(BOOL success) {
            tried++, complete += success ? 1 : 0;
            
            if (tried == total) {
                completionHandler(total == complete);
            }
        };
        
        for (NCPlayer *player in self.contextPlayers) [player seekToDate:date multi:NO completionHandler:handler];
    } else {
        self.seeking = YES;
        [super seekToDate:date completionHandler:^(BOOL success) {
            completionHandler(success);
            self.seeking = NO;
        }];
    }
}

- (void)seekToTime:(CMTime)time multi:(BOOL)multi {
    if (multi) {
        for (NCPlayer *player in self.contextPlayers) [player seekToTime:time multi:NO];
    } else {
        self.seeking = YES;
        [super seekToTime:time completionHandler:^(BOOL success) {
            self.seeking = NO;
        }];
    }
}

- (void)seekToTime:(CMTime)time multi:(BOOL)multi completionHandler:(nonnull void (^)(BOOL))completionHandler {
    if (multi) {
        NSUInteger total = self.contextPlayers.count;
        
        __block NSUInteger tried = 0;
        __block NSUInteger complete = 0;
        
        void (^handler)(BOOL) = ^(BOOL success) {
            tried++, complete += success ? 1 : 0;
            
            if (tried == total) {
                completionHandler(total == complete);
            }
        };
        
        for (NCPlayer *player in self.contextPlayers) [player seekToTime:time multi:NO completionHandler:handler];
    } else {
        self.seeking = YES;
        [super seekToTime:time completionHandler:^(BOOL success) {
            completionHandler(success);
            self.seeking = NO;
        }];
    }
}

- (void)seekToTime:(CMTime)time multi:(BOOL)multi toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter {
    if (multi) {
        for (NCPlayer *player in self.contextPlayers) [player seekToTime:time multi:NO toleranceBefore:toleranceBefore toleranceAfter:toleranceAfter];
    } else {
        self.seeking = YES;
        [super seekToTime:time toleranceBefore:toleranceBefore toleranceAfter:toleranceAfter completionHandler:^(BOOL success) {
            self.seeking = NO;
        }];
    }
}

- (void)seekToTime:(CMTime)time multi:(BOOL)multi toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter completionHandler:(nonnull void (^)(BOOL))completionHandler {
    if (multi) {
        NSUInteger total = self.contextPlayers.count;
        
        __block NSUInteger tried = 0;
        __block NSUInteger complete = 0;
        
        void (^handler)(BOOL) = ^(BOOL success) {
            tried++, complete += success ? 1 : 0;
            
            if (tried == total) {
                completionHandler(total == complete);
            }
        };
        
        for (NCPlayer *player in self.contextPlayers) [player seekToTime:time multi:NO toleranceBefore:toleranceBefore toleranceAfter:toleranceAfter completionHandler:handler];
    } else {
        self.seeking = YES;
        [super seekToTime:time toleranceBefore:toleranceBefore toleranceAfter:toleranceAfter completionHandler:^(BOOL success) {
            completionHandler(success);
            self.seeking = NO;
        }];
    }
}


#pragma mark - Overrides

- (void)play {
    [self setRate:self.slomo ? 0.5 : 1.0];
}

- (void)pause
{
     [self setRate:0.0];
}

- (void)setRate:(float)rate {
    if (rate != 0.0) {
        [self prerollAtRate:rate completionHandler:^(BOOL complete){
            dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
            dispatch_after(delay, dispatch_get_main_queue(), ^{
                [self setRate:rate multi:YES];
            });
        }];
    } else {
        [self setRate:rate multi:YES];
    }
}

- (void)setRate:(float)rate time:(CMTime)itemTime atHostTime:(CMTime)hostClockTime {
    [self setRate:rate multi:YES time:itemTime atHostTime:hostClockTime];
}


- (void)prerollAtRate:(float)rate completionHandler:(void (^)(BOOL))completionHandler {
    [self prerollAtRate:rate multi:YES completionHandler:completionHandler];
}

- (void)cancelPendingPrerolls {
    [self cancelPendingPrerollsMulti:YES];
}

- (void)seekToDate:(NSDate *)date {
    [self seekToDate:date multi:YES];
}

- (void)seekToDate:(NSDate *)date completionHandler:(void (^)(BOOL))completionHandler {
    [self seekToDate:date multi:YES completionHandler:completionHandler];
}

- (void)seekToTime:(CMTime)time {
    if (CMTIMERANGE_IS_VALID(self.loopRange) && !CMTimeRangeContainsTime(self.loopRange, time)) time = self.loopRange.start;
    [self seekToTime:time multi:YES];
}

- (void)seekToTime:(CMTime)time completionHandler:(void (^)(BOOL))completionHandler {
    if (CMTIMERANGE_IS_VALID(self.loopRange) && !CMTimeRangeContainsTime(self.loopRange, time)) time = self.loopRange.start;
    [self seekToTime:time multi:YES completionHandler:completionHandler];
}

- (void)seekToTime:(CMTime)time toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter {
    if (CMTIMERANGE_IS_VALID(self.loopRange) && !CMTimeRangeContainsTime(self.loopRange, time)) time = self.loopRange.start;
    [self seekToTime:time multi:YES toleranceBefore:toleranceBefore toleranceAfter:toleranceAfter];
}

- (void)seekToTime:(CMTime)time toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter completionHandler:(void (^)(BOOL))completionHandler {
    if (CMTIMERANGE_IS_VALID(self.loopRange) && !CMTimeRangeContainsTime(self.loopRange, time)) time = self.loopRange.start;
    [self seekToTime:time multi:YES toleranceBefore:toleranceBefore toleranceAfter:toleranceAfter completionHandler:completionHandler];
}

- (void)setRate:(float)rate atTime:(CMTime)time {
    if (CMTIMERANGE_IS_VALID(self.loopRange) && !CMTimeRangeContainsTime(self.loopRange, time)) time = self.loopRange.start;
    
    [self pause];
    [self seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL seekComplete) {
        
        if (rate != 0.0) {
            [self prerollAtRate:rate completionHandler:^(BOOL prerollComplete) {
                
                //delay just in case ;)
                dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
                dispatch_after(delay, dispatch_get_main_queue(), ^{
                    [self setRate:rate];
                });
                
            }];
        }
    }];
}

@end
