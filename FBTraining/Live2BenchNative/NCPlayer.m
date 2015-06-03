//
//  NCPlayer.m
//  iOS Workspace
//
//  Created by Nico Cvitak on 2015-05-26.
//  Copyright (c) 2015 Nicholas Cvitak. All rights reserved.
//

#import "NCPlayer.h"

#define DEFAULT_SYNC_THRESHOLD 0.250

@interface NCPlayerContext ()

@property (strong, nonatomic, nonnull) NSMutableSet *playerSet;

@end

@interface NCPlayer ()

@property (readonly, nonatomic, nonnull) NSArray *contextPlayers;
@property (strong, nonatomic, nonnull) NSMutableArray *readyToPlayActionQueue;

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
    
    if (CMTIME_IS_NUMERIC(syncInterval) && CMTIME_IS_NUMERIC(self.syncThreshold)) {
        __block NCPlayer *_self = self;
        
        _syncPeriodicObserver = [self addPeriodicTimeObserverForInterval:syncInterval queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            
            // first calculate the maximum time difference
            CMTime max = kCMTimeZero;
            for (NCPlayer *player in _self.contextPlayers) {
                CMTime diff = CMTimeAbsoluteValue(CMTimeSubtract(_self.currentTime, player.currentTime));
                max = CMTimeMaximum(max, diff);
            }
            
            if (CMTimeCompare(max, _self.syncThreshold) > 0) {
                [_self setRate:_self.rate atTime:time];
            }
            
        }];
    }
}

- (void)setSlomo:(BOOL)slomo {
    _slomo = slomo;
    
    if (self.rate != 0.0) {
        self.rate = slomo ? 0.5 : 1.0;
    }
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
    float rate = self.rate;
    
    [self pause];
    [self seekToTime:newTime completionHandler:^(BOOL finish) {
        [self setRate:rate];
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
        [super prerollAtRate:rate completionHandler:completionHandler];
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
        [super seekToDate:date];
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
        [super seekToDate:date completionHandler:completionHandler];
    }
}

- (void)seekToTime:(CMTime)time multi:(BOOL)multi {
    if (multi) {
        for (NCPlayer *player in self.contextPlayers) [player seekToTime:time multi:NO];
    } else {
        [super seekToTime:time];
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
        [super seekToTime:time completionHandler:completionHandler];
    }
}

- (void)seekToTime:(CMTime)time multi:(BOOL)multi toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter {
    if (multi) {
        for (NCPlayer *player in self.contextPlayers) [player seekToTime:time multi:NO toleranceBefore:toleranceBefore toleranceAfter:toleranceAfter];
    } else {
        [super seekToTime:time toleranceBefore:toleranceBefore toleranceAfter:toleranceAfter];
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
        [super seekToTime:time toleranceBefore:toleranceBefore toleranceAfter:toleranceAfter completionHandler:completionHandler];
    }
}


#pragma mark - Overrides

- (void)play {
    [self setRate:self.slomo ? 0.5 : 1.0];
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
    [self seekToTime:time multi:YES];
}

- (void)seekToTime:(CMTime)time completionHandler:(void (^)(BOOL))completionHandler {
    [self seekToTime:time multi:YES completionHandler:completionHandler];
}

- (void)seekToTime:(CMTime)time toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter {
    [self seekToTime:time multi:YES toleranceBefore:toleranceBefore toleranceAfter:toleranceAfter];
}

- (void)seekToTime:(CMTime)time toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter completionHandler:(void (^)(BOOL))completionHandler {
    [self seekToTime:time multi:YES toleranceBefore:toleranceBefore toleranceAfter:toleranceAfter completionHandler:completionHandler];
}

- (void)setRate:(float)rate atTime:(CMTime)time {
    
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
