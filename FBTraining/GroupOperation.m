//
//  GroupOperation.m
//
//  Created by dev on 2016-04-08.
//  Copyright © 2016 Richard. All rights reserved.
//

#import "GroupOperation.h"

@interface GroupOperation ()

@end


@implementation GroupOperation
{
    BOOL _isFinished;
    BOOL _isExecuting;
}



- (instancetype)initWithOperations:(NSArray*)operations withQueue:(NSOperationQueue*)queue
{
    self = [super init];
    if (self) {
        _isExecuting                = NO;
        _isFinished                 = NO;
        
        // empty operation to to make all other operation dependant on
        self.startingOperation      = [NSBlockOperation blockOperationWithBlock:^{}];
        
        // finishing block that will depend on all other operation
        __block GroupOperation * weakSelf = self;
        self.finishingOperation      = [NSBlockOperation blockOperationWithBlock:^{
            [weakSelf completeOperation];
        }];
        
        self.internalQueue           = queue;
        self.internalQueue.maxConcurrentOperationCount = 1;
        self.internalQueue.suspended = YES;
        [self.internalQueue addOperation:self.startingOperation];
        
        for (NSOperation * ops  in operations) {
            [ops addDependency:self.startingOperation];
            [self.finishingOperation addDependency:ops];
            [self.internalQueue addOperation:ops];
        }
        
    }
    return self;
}

- (instancetype)initWithOperations:(NSArray*)operations
{
    self = [super init];
    if (self) {
        _isExecuting                = NO;
        _isFinished                 = NO;
        
        // empty operation to to make all other operation dependant on
        self.startingOperation      = [NSBlockOperation blockOperationWithBlock:^{
            NSLog(@"%s",__FUNCTION__);

        }];
        
        // finishing block that will depend on all other operation
        __block GroupOperation * weakSelf = self;
        self.finishingOperation      = [NSBlockOperation blockOperationWithBlock:^{
            [weakSelf completeOperation];            
        }];
        
        self.internalQueue           = [NSOperationQueue new];
        self.internalQueue.suspended = YES;
        [self.internalQueue addOperation:self.startingOperation];
        
        for (NSOperation * ops  in operations) {
            [ops addDependency:self.startingOperation];
            [self.finishingOperation addDependency:ops];
            [self.internalQueue addOperation:ops];
        }
        
    }
    return self;
}

-(BOOL)isConcurrent
{
    return YES;
}

- (void)setExecuting:(BOOL)isExecuting {
    if (isExecuting != _isExecuting) {
        [self willChangeValueForKey:@"isExecuting"];
        _isExecuting = isExecuting;
        [self didChangeValueForKey:@"isExecuting"];
    }
}

- (BOOL)isExecuting
{
    return _isExecuting;
}

- (void)setFinished:(BOOL)isFinished
{
    [self willChangeValueForKey:@"isFinished"];
    _isFinished = isFinished;
    [self didChangeValueForKey:@"isFinished"];
}

- (BOOL)isFinished
{
    return _isFinished || [self isCancelled];
}

/**
 *  Cancelling the operation will cancel all nested operations
 */
-(void)cancel
{
    [self.internalQueue cancelAllOperations];
    
    [self setExecuting:NO];
    [self setFinished:YES];
    
    
    [super cancel];
}

-(void)main
{
    self.internalQueue.suspended = NO;
    [self.internalQueue addOperation:self.finishingOperation];
}

/**
 *  Quick KVO to finish operation
 */
-(void)completeOperation {
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = NO;
    _isFinished  = YES;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}



@end
