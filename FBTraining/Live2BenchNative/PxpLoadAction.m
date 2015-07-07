//
//  PxpLoadAction.m
//  PxpPlayer
//
//  Created by Nico Cvitak on 2015-07-03.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import "PxpLoadAction.h"

@interface PxpLoadAction ()

@property (copy, nonatomic, nullable) void(^block)(BOOL);

@end

@implementation PxpLoadAction

#pragma mark - Initialization

+ (nonnull instancetype)loadActionWithBlock:(void (^)(BOOL))block {
    return [[self alloc] initWithBlock:block];
}

+ (nonnull instancetype)loadActionWithTarget:(nullable id)target action:(nullable SEL)action {
    return [[self alloc] initWithTarget:target action:action];
}

- (nonnull instancetype)initWithBlock:(void (^)(BOOL))block {
    self = [super init];
    if (self) {
        _complete = NO;
        _success = nil;
        _block = block;
    }
    return self;
}

- (nonnull instancetype)initWithTarget:(nullable id)target action:(nullable SEL)action {
    self = [super init];
    if (self) {
        
        IMP method = [target methodForSelector:action];
        void (*f)(id, SEL, id) = (void (*)(id, SEL, id))method;
        
        __block PxpLoadAction *loadAction = self;
        
        _complete = NO;
        _success = nil;
        _block = f ? ^(BOOL success) { f(target, action, loadAction); } : nil;
    }
    return self;
}

- (nonnull instancetype)init {
    return [self initWithBlock:nil];
}

#pragma mark - Execution

- (void)runWithSuccess:(BOOL)success {
    
    // on the run the action if it has not ran before
    if (!self.complete) {
        
        // update the success property
        [self willChangeValueForKey:@"success"];
        _success = success;
        [self didChangeValueForKey:@"success"];
        
        // run the block
        if (self.block) {
            self.block(success);
        }
        
        // signal the completion
        [self willChangeValueForKey:@"complete"];
        _complete = YES;
        [self didChangeValueForKey:@"complete"];
    }
}

@end