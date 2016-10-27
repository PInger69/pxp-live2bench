//
//  GroupOperation.h
//
//  Created by dev on 2016-04-08.
//  Copyright © 2016 Richard. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 This is an abstract class that makes a group of
 
 */
@interface GroupOperation : NSOperation
@property (nonatomic,strong) NSOperationQueue * internalQueue;
@property (nonatomic,strong) NSBlockOperation * startingOperation;
@property (nonatomic,strong) NSBlockOperation * finishingOperation;


- (instancetype)initWithOperations:(NSArray*)operations withQueue:(NSOperationQueue*)queue;

/**
 *  Create GroupOperation instance
 *
 *  @param operations Array operations to act as one operation
 *
 *  @return instancetype
 */
- (instancetype)initWithOperations:(NSArray*)operations;

@end
