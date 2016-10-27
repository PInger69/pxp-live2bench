//
//  DelayOperation.m
//  OperationLab
//
//  Created by Atomicflare on 2016-04-17.
//  Copyright © 2016 Atomicflare. All rights reserved.
//

#import "DelayOperation.h"

@implementation DelayOperation
- (instancetype)initWithDelay:(NSTimeInterval)aTime
{
    self = [super init];
    if (self) {
        executing               = NO;
        finished                = NO;
        self.time = aTime;
    }
    return self;
}



-(void)main
{
    if ([self isCancelled] ) {
        
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
        
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];

    
    dispatch_time_t t = dispatch_time(DISPATCH_TIME_NOW,(int64_t)(self.time * NSEC_PER_SEC));
    dispatch_after(t, dispatch_get_main_queue(), ^{
        if (!self.cancelled) {
            [self completeOperation];
        }
    });

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


-(void)cancel
{
    [super cancel];
}


- (void)completeOperation {
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    

    
    executing = NO;
    finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}


@end
