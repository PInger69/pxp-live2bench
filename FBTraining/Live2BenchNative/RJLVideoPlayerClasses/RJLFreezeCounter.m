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

    int     _max;
    int     _current;
}

@synthesize freezeTimer =_freezeTimer;
- (instancetype)initWithTarget:(id)target selector:(SEL)sel object:(id)arg
{
    self = [super init];
    if (self) {
        _target     = target;
        _selector   = sel;
    }
    return self;
}

-(void)startTimer:(int)interval max:(int)max
{
    _max            = max;
    _current        = _max;
    NSTimeInterval  inter =  interval;

    _freezeTimer    = [NSTimer timerWithTimeInterval:inter target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_freezeTimer forMode:NSDefaultRunLoopMode];
//    [_freezeTimer fire];

}

-(void)reset
{
    _current = _max;
}


-(void)timerFireMethod:(NSTimer *)timer
{
    if (_current-- <= 0){
        if (_target && [_target respondsToSelector:_selector]) {
            IMP imp = [_target methodForSelector:_selector];
            void (*func)(id, SEL) = (void *)imp;
            func(_target, _selector);
            
//            [_target performSelector:_selector withObject:nil];
            [self reset];
        }
    }
}

-(void)start
{

    [[NSRunLoop mainRunLoop] addTimer:_freezeTimer forMode:NSDefaultRunLoopMode];
}


-(void)stop
{
    [_freezeTimer invalidate];
}





@end
