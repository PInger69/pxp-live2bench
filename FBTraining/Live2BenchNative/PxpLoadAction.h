//
//  PxpLoadAction.h
//  PxpPlayer
//
//  Created by Nico Cvitak on 2015-07-03.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @breif A container for an action to be executed when a player finishes loading.
 * @author Nicholas Cvitak
 */
@interface PxpLoadAction : NSObject

/// The completion status of the load action.
@property (readonly, assign, nonatomic) BOOL complete;

/// The load success status of the load action.
@property (readonly, assign, nonatomic) BOOL success;

#pragma mark - Initialization

/// Creates a new load action with a block to be executed when a player finishes loading.
+ (nonnull instancetype)loadActionWithBlock:(nullable void(^)(BOOL))block;

/// Creates a new load action with a selector to be performed when a player finises loading.
+ (nonnull instancetype)loadActionWithTarget:(nullable id)target action:(nullable SEL)action;

/// Initializes a load action with a block to be executed when a player finishes loading.
- (nonnull instancetype)initWithBlock:(nullable void(^)(BOOL))block;

/// Initializes a load action with a selector to be performed when a player finises loading.
- (nonnull instancetype)initWithTarget:(nullable id)target action:(nullable SEL)action;

#pragma mark - Execution

/// Runs the load action with the appropriate success flag.
- (void)runWithSuccess:(BOOL)success;

@end
