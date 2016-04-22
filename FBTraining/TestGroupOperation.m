//
//  TestGroupOperation.m
//  Live2BenchNative
//
//  Created by dev on 2016-04-15.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "TestGroupOperation.h"

@implementation TestGroupOperation


- (instancetype)init
{
    
    
    NSBlockOperation * blk1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"blk1");

    }];
    
    
    NSBlockOperation * blk2 = [NSBlockOperation blockOperationWithBlock:^{
          NSLog(@"blk2");
    }];
    
    NSBlockOperation * blk3 = [NSBlockOperation blockOperationWithBlock:^{
          NSLog(@"blk3");
    }];
    
    [blk3 addDependency:blk2];
    [blk2 addDependency:blk1];

    
    
    self = [super initWithOperations:@[blk1,blk3,blk2]];
    if (self) {
        
    }
    return self;
}



@end
