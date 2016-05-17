//
//  RicoPlayerMonitor.m
//  Live2BenchNative
//
//  Created by dev on 2016-05-04.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "RicoPlayerMonitor.h"
#define MAX_RESETS 3
#import "RicoPlayer.h"


// Simple counter class

@interface Counter : NSObject
@property (nonatomic,assign) NSInteger max;
//@property (nonatomic,assign) NSInteger coolDownCycles;
@property (nonatomic,assign) NSInteger current;
-(BOOL)isComplete;
-(void)reset;
@end


@implementation Counter

- (instancetype)initWithMaxCount:(NSInteger)count
{
    self = [super init];
    if (self) {
        self.max        = count;
//        self.coolDownCycles = 3;
        [self reset];
    }
    return self;
}

-(BOOL)isComplete
{
//    if (self.coolDownCycles ==0) {
//        self.coolDownCycles = 3;
        if (self.current==0) {
            return YES;
        } else {
            self.current--;
            
            return NO;
        }
//    } else {
//        
//    
//        self.coolDownCycles--;
//        return NO;
//    }
    
    
}


-(void)reset
{
    self.current    = self.max;
}
@end



















@interface RicoPlayerMonitor ()

@property (nonatomic,strong) Counter * softFailCounter;
@property (nonatomic,strong) Counter * resetCounter;
@property (nonatomic,strong) Counter * coolDownCounter;
@property (nonatomic,assign) Float64 lastDurationTime;
@property (nonatomic,strong) NSTimer * timer;
@property (nonatomic,weak)   RicoPlayer* player;

@end


@implementation RicoPlayerMonitor

- (instancetype)initWithPlayer:(RicoPlayer*)player
{
    self = [super init];
    if (self) {
        self.player = player;
        self.log                = [NSMutableArray new];
        self.softFailCounter    = [[Counter alloc]initWithMaxCount:MAX_RESETS];
        self.resetCounter       = [[Counter alloc]initWithMaxCount:MAX_RESETS];
        self.coolDownCounter    = [[Counter alloc]initWithMaxCount:5];
    }
    return self;
}


//- (instancetype)init
//{
//    self = [super init];
//    if (self) {
//        self.log                = [NSMutableArray new];
//        self.softFailCounter    = [[Counter alloc]initWithMaxCount:MAX_RESETS];
//        self.resetCounter       = [[Counter alloc]initWithMaxCount:MAX_RESETS];
//        self.coolDownCounter    = [[Counter alloc]initWithMaxCount:5];
//     
//    }
//    return self;
//}


-(void)start
{
   self.timer              = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(update) userInfo:nil repeats:YES];
}

-(void)stop
{
if (self.timer)    [self.timer invalidate];
}


-(void)update
{
    if (self.coolDownCounter.isComplete) {
        
        if ( CMTimeGetSeconds(self.player.duration) == self.lastDurationTime  && self.player.live) {
            
            
            if (self.softFailCounter.isComplete) {
                // throw Error
                self.player.reliable = NO;
            }
            
        }
        [self.coolDownCounter reset];
        self.lastDurationTime = CMTimeGetSeconds(self.player.duration);
    }


}

-(void)update:(RicoPlayer*)player
{
    
//    NSLog(@"%f   %f %f",CMTimeGetSeconds(player.curr.entTime),self.lastDurationTime,CMTimeGetSeconds(player.duration));

    if (self.coolDownCounter.isComplete) {
    
        if ( CMTimeGetSeconds(player.duration) == self.lastDurationTime  && player.live) {
           
            
            if (self.softFailCounter.isComplete) {
                // throw Error
                player.reliable = NO;
            }
        
        }
        [self.coolDownCounter reset];
        self.lastDurationTime = CMTimeGetSeconds(player.duration);
    }
    
    
}



-(void)reset
{
    [self.log    removeAllObjects];
    [self.softFailCounter reset];
}

-(void)dealloc
{
    if (self.timer)    [self.timer invalidate];
    
    
}

@end
