//
//  GroupOperation.m
//  Live2BenchNative
//
//  Created by dev on 2016-04-08.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "GroupOperation.h"

@interface GroupOperation ()
@property (nonatomic,strong) NSOperationQueue * internalQueue;
@property (nonatomic,strong) NSBlockOperation * startingOperation;
@property (nonatomic,strong) NSBlockOperation * finishingOperation;
@end


@implementation GroupOperation
{
    
    BOOL _isFinished;
    BOOL _isExecuting;
}

- (instancetype)initWithOperations:(NSArray*)operations
{
    self = [super init];
    if (self) {
        _isExecuting               = NO;
        _isFinished                = NO;
        
        self.startingOperation      = [NSBlockOperation blockOperationWithBlock:^{
//            NSLog(@"Group op start");
        }];
        
        __block GroupOperation * weakSelf = self;
        self.finishingOperation     = [NSBlockOperation blockOperationWithBlock:^{
            [weakSelf completeOperation];            
        }];
        
        self.internalQueue          = [NSOperationQueue new];
        self.internalQueue.suspended = YES;
        [self.internalQueue addOperation:self.startingOperation];
        
        for (NSOperation * ops  in operations) {
            
            
            
            [self addOperation:ops];
            
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

- (void)completeOperation {
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = NO;
    _isFinished = YES;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}




-(void)addOperation:(NSOperation*)operation
{
    [operation addDependency:self.startingOperation];
    [self.finishingOperation addDependency:operation];
    [self.internalQueue addOperation:operation];
}



@end
