//
//  RicoOperationsPack.m
//  Live2BenchNative
//
//  Created by dev on 2015-12-01.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "RicoOperations.h"
#import "RicoPlayer.h"
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
        [self willChangeValueForKey:@"isExecuting"];
        finished = YES;
        executing = NO;
        [self didChangeValueForKey:@"isFinished"];
        [self didChangeValueForKey:@"isExecuting"];
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
    executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

//-(void)cancel
//{
//
//
//    [self willChangeValueForKey:@"isFinished"];
//    [self willChangeValueForKey:@"isExecuting"];
//    finished    = YES;
//    executing   = NO;
//    [self didChangeValueForKey:@"isExecuting"];
//    [self didChangeValueForKey:@"isFinished"];
//        [super cancel];
//}

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

-(NSString*)description
{
    return [NSString stringWithFormat:@"%@  Finished:%@  executing: %@  canceled: %@",[self class],(self.isFinished)?@"yes":@"no",(self.executing)?@"yes":@"no",(self.cancelled)?@"yes":@"no"];
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
    NSLog(@"RicoOperation Load Item start");
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
    
    if ([self isCancelled] ||item.status == AVPlayerItemStatusUnknown ){
        return;
    }
    
    switch (item.status) {
        case AVPlayerItemStatusReadyToPlay:
            self.success = YES;
            NSLog(@"RicoOperation Load Item success");
//            if (self.delegate) [self.delegate onPlayerOperationItemReady:self];
            break;
        case AVPlayerItemStatusFailed:
            self.success = NO;
//            if (self.delegate) [self.delegate onPlayerOperationItemFail:self];
            break;
        default:
            break;
    }
    if (self.observedItem) {
        [self.observedItem removeObserver:self forKeyPath:@"status"];
        self.observedItem = nil;
    }

    [self completeOperation];
    
}

-(void)cancel
{

    [super cancel];
    if (self.observedItem && executing) {
        [self.observedItem removeObserver:self forKeyPath:@"status"];
        self.observedItem = nil;
    }
    [self completeOperation];

}


- (void)completeOperation {
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    executing = NO;
    finished = YES;
    
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

-(void)dealloc
{
    if (self.observedItem) {
        [self.observedItem removeObserver:self forKeyPath:@"status"];
    }
}

-(NSString*)description
{
    return [NSString stringWithFormat:@"%@  Finished:%@  executing: %@  canceled: %@",[self class],(self.isFinished)?@"yes":@"no",(self.executing)?@"yes":@"no",(self.cancelled)?@"yes":@"no"];
}


@end
































// RicoSeekOperation

@interface RicoSeekOperation ()

//@property (nonatomic,assign) BOOL dynamicIsExecuting;
//@property (nonatomic,assign) BOOL dynamicIsFinished;

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
        finished                = NO;
        self.name               = @"Seek Op";
    }
    return self;
}


-(void)start
{
    
    if ([self isCancelled]) {
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    

    __block RicoSeekOperation* weakself = self;
    
    __block AVPlayer        * avp = self.player;
    __block AVPlayerItem    * avi = self.player.currentItem;
    
    
    if (self.player.status == AVPlayerStatusReadyToPlay && self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        [avp cancelPendingPrerolls];
        [avi cancelPendingSeeks];
        
        NSLog(@"Start Rico Seek");
        [self.player seekToTime:self.seekToTime toleranceBefore:self.toleranceBefore toleranceAfter:self.toleranceAfter completionHandler:^(BOOL afinished) {
            weakself.success = afinished;
            if (weakself.completionHandler != nil) {
                weakself.completionHandler(finished);
                
            }
            NSLog(@"Finish Rico Seek");
//             dispatch_async(dispatch_get_main_queue(),^{

                 [weakself completeOperation];
                
//              });
            NSLog(@"Seeking Complete %@",(afinished)?@"PASS":@"FAIL");
        }];
    } else {
        [self completeOperation];
        NSLog(@"Seeking Complete FAIL");
    }
}



- (void)completeOperation {
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    executing = NO;
    finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}



-(void)main
{



}


/*
 -(void)start
 {
 
 if ([self isCancelled]) {
 [self willChangeValueForKey:@"isFinished"];
 //        [self willChangeValueForKey:@"isExecuting"];
 finished = YES;
 //        executing = NO;
 [self didChangeValueForKey:@"isFinished"];
 //        [self didChangeValueForKey:@"isExecuting"];
 return;
 }
 
 [self willChangeValueForKey:@"isExecuting"];
 executing = YES;
 [self didChangeValueForKey:@"isExecuting"];
 
 
 //    self.dynamicIsExecuting = YES;
 __block RicoSeekOperation* weakself = self;
 
 __block AVPlayer        * avp = self.player;
 __block AVPlayerItem    * avi = self.player.currentItem;
 
 [avp cancelPendingPrerolls];
 [avi cancelPendingSeeks];
 
 if (self.player.status == AVPlayerStatusReadyToPlay && self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
 NSLog(@"Start Rico Seek");
 [self.player seekToTime:self.seekToTime toleranceBefore:self.toleranceBefore toleranceAfter:self.toleranceAfter completionHandler:^(BOOL afinished) {
 weakself.success = afinished;
 if (weakself.completionHandler != nil) {
 weakself.completionHandler(finished);
 
 }
 NSLog(@"Finish Rico Seek");
 //        NSLog(@"%@ %f  %@" ,self.player ,CMTimeGetSeconds(avi.currentTime), (afinished)?@"Pass":@"FAIL");
 dispatch_async(dispatch_get_main_queue(),^{
 [weakself willChangeValueForKey:@"isFinished"];
 [weakself willChangeValueForKey:@"isExecuting"];
 finished = YES;
 executing = NO;
 [weakself didChangeValueForKey:@"isExecuting"];
 [weakself didChangeValueForKey:@"isFinished"];
 
 });
 NSLog(@"Seeking Complete %@",(afinished)?@"PASS":@"FAIL");
 }];
 } else {
 [weakself willChangeValueForKey:@"isFinished"];
 [weakself willChangeValueForKey:@"isExecuting"];
 finished = YES;
 executing = NO;
 [weakself didChangeValueForKey:@"isExecuting"];
 [weakself didChangeValueForKey:@"isFinished"];
 NSLog(@"Seeking Complete FAIL");
 }
 }

 */

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

-(NSString*)description
{
    return [NSString stringWithFormat:@"%@  Finished:%@  executing: %@  canceled: %@",[self class],(self.isFinished)?@"yes":@"no",(self.executing)?@"yes":@"no",(self.cancelled)?@"yes":@"no"];
}

@end




































@implementation RicoPlayOperation


- (instancetype)initWithRicoPlayer:(RicoPlayer*)player
{
    self = [super init];
    if (self) {
        self.player = player;
    }
    return self;
}

-(void)start
{
    NSLog(@"RicoOperation PLay");
    if ([self isCancelled]  ||  self.player.avPlayer.currentItem.status != AVPlayerItemStatusReadyToPlay) {
        [self willChangeValueForKey:@"isFinished"];
        [self willChangeValueForKey:@"isExecuting"];
        finished = YES;
        executing = NO;
        [self didChangeValueForKey:@"isFinished"];
        [self didChangeValueForKey:@"isExecuting"];
        
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    
    [self.player.avPlayer play];
    [self.player.avPlayer seekToTime:self.player.avPlayer.currentTime completionHandler:^(BOOL finished) {
        NSLog(@"PLAY SEEK %@",(finished)?@"pass":@"fail");
        
    }];
    
    self.player.isPlaying = YES;
    
//    [self willChangeValueForKey:@"isFinished"];
//    [self willChangeValueForKey:@"isExecuting"];
//    finished    = YES;
//    executing   = NO;
//    [self didChangeValueForKey:@"isExecuting"];
//    [self didChangeValueForKey:@"isFinished"];
    
}




-(void)cancel
{
    
    [super cancel];

    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    finished    = YES;
    executing   = NO;
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

-(void)dealloc
{

}

-(NSString*)description
{
    return [NSString stringWithFormat:@"%@  Finished:%@  executing: %@  canceled: %@",[self class],(self.isFinished)?@"yes":@"no",(self.executing)?@"yes":@"no",(self.cancelled)?@"yes":@"no"];
}


@end








