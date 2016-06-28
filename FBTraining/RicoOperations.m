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



























/*
 @interface RicoPlayerChecker : NSObject
 
 @property (strong,nonatomic) NSTimer            * timer;
 @property (assign,nonatomic) NSInteger          maxCoolDownTick;
 @property (assign,nonatomic) NSInteger          currentCoolDownTick;
 @property (assign,nonatomic) NSTimeInterval     tick;
 
 @property (strong,nonatomic) RicoPlayer         * player;
 
 -(void)start;
 -(void)stop;
 -(void)refreshCoolDown;
 
 @end
 
 @implementation RicoPlayerChecker
 
 - (instancetype)initWithRicoPlayer:(RicoPlayer*)player
 {
 self = [super init];
 if (self) {
 self.player                 = player;
 self.maxCoolDownTick        = 3;
 self.currentCoolDownTick    = self.maxCoolDownTick;
 self.tick                   = 1.0;
 }
 return self;
 }
 
 
 
 -(void)start
 {

 }
 
 -(void)stop
 {
 [self.timer invalidate];
 }
 
 -(void)refreshCoolDown
 {
 self.currentCoolDownTick = self.maxCoolDownTick;
 }
 

 
 @end


*/

// RicoSeekOperation

@interface RicoSeekOperation ()


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
 
//        self.maxCoolDownTick        = 3;
//        self.currentCoolDownTick    = self.maxCoolDownTick;
//        self.tick                   = 1.0;

        
        
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
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.tick target:self selector:@selector(update) userInfo:nil repeats:YES];
//    });
//    
    
    if (self.player.status == AVPlayerStatusReadyToPlay && self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        [avp cancelPendingPrerolls];
        [avi cancelPendingSeeks];
        
//        NSLog(@"Start Rico Seek");
        
        
        
        [self.player seekToTime:self.seekToTime toleranceBefore:self.toleranceBefore toleranceAfter:self.toleranceAfter completionHandler:^(BOOL afinished) {
            weakself.success = afinished;
            

            
            if (weakself.completionHandler != nil) {
                weakself.completionHandler(finished);
                
            }
            
            [weakself completeOperation];
        }];
    } else {
        [self completeOperation];
        NSLog(@"Seeking Complete FAIL");
    }
}

-(void)cancel
{
    [super cancel];
    [self completeOperation];
}

-(void)update
{
//    if (self.currentCoolDownTick == 0 && self.player.rate !=0) {
//        
//        // something is wrong
//        [self reSeek];
//         self.currentCoolDownTick = self.maxCoolDownTick;
//        
//        
//    } else {
//        self.currentCoolDownTick--;
//    }
    
}



- (void)completeOperation {
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    executing = NO;
    finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
//    [self.timer invalidate];
}


-(void)reSeek
{
//      [self.timer invalidate];
    if ([self isCancelled]) return;
    
    if (!finished && executing) {
        
        __block RicoSeekOperation* weakself = self;
        
        __block AVPlayer        * avp = self.player;
        __block AVPlayerItem    * avi = self.player.currentItem;
        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.timer = [NSTimer scheduledTimerWithTimeInterval:self.tick target:self selector:@selector(update) userInfo:nil repeats:YES];
//        });
        
        
        if (self.player.status == AVPlayerStatusReadyToPlay && self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
            [avp cancelPendingPrerolls];
            [avi cancelPendingSeeks];
            
            //        NSLog(@"Start Rico Seek");
            [self.player seekToTime:self.seekToTime toleranceBefore:self.toleranceBefore toleranceAfter:self.toleranceAfter completionHandler:^(BOOL afinished) {
                weakself.success = afinished;
                if (weakself.completionHandler != nil) {
                    weakself.completionHandler(finished);
                    
                }
                [weakself completeOperation];
            }];
        } else {
            [self completeOperation];
            NSLog(@"Seeking Complete FAIL op");
        }

    
    
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
//        NSLog(@"PLAY SEEK %@",(finished)?@"pass":@"fail");
        
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




//@implementation RicoPrerollOperation
//{
//    float _rate;
//}
//
//- (instancetype)initWithRicoPlayer:(RicoPlayer*)player rate:(float)rate
//{
//    self = [super init];
//    if (self) {
//        self.player = player;
//        _rate = rate;
//        self.name = @"Preroll Op";
//    }
//    return self;
//}
//
//-(void)start
//{
//    NSLog(@"RicoOperation Preroll");
//    if ([self isCancelled]  ||  self.player.avPlayer.currentItem.status != AVPlayerItemStatusReadyToPlay) {
//        [self willChangeValueForKey:@"isFinished"];
//        [self willChangeValueForKey:@"isExecuting"];
//        finished = YES;
//        executing = NO;
//        [self didChangeValueForKey:@"isFinished"];
//        [self didChangeValueForKey:@"isExecuting"];
//        
//        return;
//    }
//    
//    [self willChangeValueForKey:@"isExecuting"];
//    executing = YES;
//    [self didChangeValueForKey:@"isExecuting"];
//    
//    
//           __block RicoPrerollOperation* weakself = self;
//    [self.player.avPlayer prerollAtRate:_rate completionHandler:^(BOOL afinished) {
//        weakself.success = afinished;
//        
//        [weakself completeOperation];
//        
//
//    }];
//    
//
//    
//}
//
//
//
//- (void)completeOperation {
//    [self willChangeValueForKey:@"isFinished"];
//    [self willChangeValueForKey:@"isExecuting"];
//    
//    executing = NO;
//    finished = YES;
//    
//    [self didChangeValueForKey:@"isExecuting"];
//    [self didChangeValueForKey:@"isFinished"];
//}
//
//
//
//-(void)cancel
//{
//    [super cancel];
//    [self completeOperation];
//}
//
//-(BOOL)isConcurrent
//{
//    return YES;
//}
//
//-(BOOL)isExecuting
//{
//    return executing;
//}
//
//-(BOOL)isFinished
//{
//    return finished;
//}
//
//-(void)dealloc
//{
//    
//}
//
//
//
//
//@end




