//
//  RJLFreezeCounter.m
//  Live2BenchNative
//
//  Created by dev on 2015-02-02.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "RJLFreezeCounter.h"

@implementation RJLFreezeCounter
{
    id      _target;
    SEL     _selector;
    int     _current;
    BOOL    isSubzero;
    
    void (^onFreeze)(BOOL);// BOOL is for subzero freeze
    void (^onSubzero)();
    

}

@synthesize freezeTimer     = _freezeTimer;
@synthesize freezeCounter   = _freezeCounter;
@synthesize maxfreeze       = _maxfreeze;
@synthesize subzeroCounter  = _subzeroCounter;


- (instancetype)initWithTarget:(id)target selector:(SEL)sel object:(id)arg
{
    self = [super init];
    if (self) {
        _target         = target;
        _selector       = sel;
        isSubzero       = NO;
        _subzeroCounter = 0;
    }
    return self;
}


-(instancetype)initWithOnFreeze:(void (^)(BOOL))onFreezeBlock  onCriticalFreeze:(void (^)())subZeroBlock
{
    self = [super init];
    if (self) {
        onFreeze    = onFreezeBlock;
        onSubzero   = subZeroBlock;
        isSubzero   = NO;
        _subzeroCounter = 0;
    }
    return self;
}

/**
 *  Start the Freeze counter
 *
 *  @param interval Time in one cycle 1 = 1 second
 *  @param max      How many cycles before it runs the send selector
 */
-(void)startTimer:(int)interval max:(int)max
{
    _maxfreeze              = max;
    _current                = _maxfreeze;
    NSTimeInterval  inter   =  interval;

    _freezeTimer            = [NSTimer timerWithTimeInterval:inter target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_freezeTimer forMode:NSDefaultRunLoopMode];
   [_freezeTimer fire];

}

-(void)reset
{
    _current = _maxfreeze;
    _subzeroCounter = 0;
}


-(void)timerFireMethod:(NSTimer *)timer
{
    NSLog(@"");
    if (_current-- <= 0){
        if (_target && [_target respondsToSelector:_selector]) {
            IMP imp = [_target methodForSelector:_selector];
            void (*func)(id, SEL) = (void *)imp;
            func(_target, _selector);
            
//            [_target performSelector:_selector withObject:nil];
            [self reset];
        } else if (onFreeze) {
            _current = _maxfreeze;
            onFreeze(NO);
        }
    }
}

-(void)start
{
    [self reset];
    [[NSRunLoop mainRunLoop] addTimer:_freezeTimer forMode:NSDefaultRunLoopMode];
     [_freezeTimer fire];
}


-(void)stop
{
    [_freezeTimer invalidate];
}





@end
