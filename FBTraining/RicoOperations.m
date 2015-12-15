//
//  RicoOperationsPack.m
//  Live2BenchNative
//
//  Created by dev on 2015-12-01.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "RicoOperations.h"

#import "RicoPlayerViewController.h"

@implementation RicoOperations


@end


@implementation RicoSyncOperation

- (instancetype)init
{
    self = [super init];
    if (self) {
        executing               = NO;
        finished                = NO;

    }
    return self;
}

-(void)start
{
    NSLog(@"sync running") ;
    if ([self isCancelled]) {
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }

    [self willChangeValueForKey:@"isExecuting"];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
   
}

-(void)syncComplete
{
     NSLog(@"sync syncComplete") ;
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    finished = YES;
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}



-(BOOL)isConcurrent
{
    return YES;
}

-(BOOL)isExecuting
{
    return executing;
}

-(BOOL)isFinished
{
    return finished;
}



@end






@implementation RicoReadyPlayerItemOperation


- (instancetype)initWithPlayerItem:(AVPlayerItem *)playerItem
{
    self = [super init];
    if (self) {
        self.observedItem       = playerItem;
        executing               = NO;
        finished                = NO;
    }
    return self;
}

-(void)start
{
    
    if ([self isCancelled] ||  self.observedItem.status == AVPlayerItemStatusReadyToPlay) {
        
        self.observedItem       = nil;
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    
    }

    [self willChangeValueForKey:@"isExecuting"];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self.observedItem addObserver:self forKeyPath:@"status" options:0 context:NULL];
    

}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    AVPlayerItem * item = object;
    switch (item.status) {
        case AVPlayerItemStatusReadyToPlay:
            self.success = YES;
            [self.observedItem removeObserver:self forKeyPath:@"status"];
            self.observedItem = nil;
            [self willChangeValueForKey:@"isFinished"];
            finished = YES;
            [self didChangeValueForKey:@"isFinished"];
            [self willChangeValueForKey:@"isExecuting"];
            executing = NO;
            [self didChangeValueForKey:@"isExecuting"];
//            if (self.delegate) [self.delegate onPlayerOperationItemReady:self];
            break;
        case AVPlayerItemStatusFailed:
            self.success = NO;
            [self.observedItem removeObserver:self forKeyPath:@"status"];
            self.observedItem = nil;

            [self willChangeValueForKey:@"isFinished"];
            finished = YES;
            [self didChangeValueForKey:@"isFinished"];
            [self willChangeValueForKey:@"isExecuting"];
            executing = NO;
            [self didChangeValueForKey:@"isExecuting"];
//            if (self.delegate) [self.delegate onPlayerOperationItemFail:self];
            break;
        default:
            break;
    }
}

-(BOOL)isConcurrent
{
    return YES;
}

-(BOOL)isExecuting
{
    return executing;
}

-(BOOL)isFinished
{
    return finished;
}

-(void)dealloc
{
    if (self.observedItem) {
        [self.observedItem removeObserver:self forKeyPath:@"status"];
    }
}

@end
































// RicoSeekOperation

@interface RicoSeekOperation ()

@property (nonatomic,assign) BOOL dynamicIsExecuting;
@property (nonatomic,assign) BOOL dynamicIsFinished;

@end


@implementation RicoSeekOperation

- (instancetype)initWithAVPlayer:(AVPlayer*)aPlayer seekToTime:(CMTime)seekTo toleranceBefore:(CMTime)tBefore toleranceAfter:(CMTime)tAfter
{
    self = [super init];
    if (self) {
        self.player             = aPlayer;
        self.seekToTime         = seekTo;
        self.toleranceBefore    = tBefore;
        self.toleranceAfter     = tAfter;
        executing               = NO;
        finished                = NO;;
    }
    return self;
}


-(void)start
{
    self.dynamicIsExecuting = YES;
    NSLog(@"Run RicoSeekOperation");
    __block RicoSeekOperation* weakself = self;
    
    __block AVPlayer * avp = self.player;
    __block AVPlayerItem * avi = self.player.currentItem;
    
    [self.player seekToTime:self.seekToTime toleranceBefore:self.toleranceBefore toleranceAfter:self.toleranceAfter completionHandler:^(BOOL afinished) {
        weakself.success = afinished;
        if (weakself.completionHandler != nil) {
            weakself.completionHandler(finished);
        }
        NSLog(@"%@ %f  %@" ,self.player ,CMTimeGetSeconds(avi.currentTime), (afinished)?@"Pass":@"FAIL");
        avp;
        avi;
        
        [weakself willChangeValueForKey:@"isFinished"];
        [weakself willChangeValueForKey:@"isExecuting"];
        finished = YES;
        executing = YES;
        [weakself didChangeValueForKey:@"isExecuting"];
        [weakself didChangeValueForKey:@"isFinished"];
        NSLog(@"Seeking Complete");
    }];

}

-(BOOL)isConcurrent
{
    return YES;
}

-(BOOL)isExecuting
{
    return executing;
}

-(BOOL)isFinished
{
    return finished;
}

@end
