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

+ (nonnull instancetype)loadActionWithLoadActions:(nullable NSArray *)loadActions {
    return [[self alloc] initWithLoadActions:loadActions];
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
    IMP method = [target methodForSelector:action];
    void (*f)(id, SEL, id) = (void (*)(id, SEL, id))method;
    
    return [self initWithBlock:^(BOOL success) { f(target, action, self); }];
}

- (nonnull instancetype)initWithLoadActions:(nullable NSArray *)loadActions {
    return [self initWithBlock:^(BOOL success) {
        for (PxpLoadAction *loadAction in loadActions) {
            [loadAction runWithSuccess:success];
        }
    }];
}

- (nonnull instancetype)init {
    return [self initWithBlock:nil];
}

#pragma mark - Execution

- (void)runWithSuccess:(BOOL)success {
    
    // on the run the action if it has not ran before
    if (!_complete) {
        
        // update the success property
        [self willChangeValueForKey:@"success"];
        _success = success;
        [self didChangeValueForKey:@"success"];
        
        // run the block
        if (_block) {
            dispatch_async(dispatch_get_main_queue(), ^() {
                _block(success);
            });
        }
        
        // signal the completion
        [self willChangeValueForKey:@"complete"];
        _complete = YES;
        [self didChangeValueForKey:@"complete"];
    }
}

-(NSString*)description {
    return [NSString stringWithFormat:@"%@",[super description]];
}

@end