//
//  BooleanOperation.m
//  Live2BenchNative
//
//  Created by dev on 2016-02-10.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "BooleanOperation.h"

@implementation BooleanOperation


@synthesize success = _success;


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.onFailOperations       = [NSMutableArray new];
        self.onSuccessOperations    = [NSMutableArray new];
        self.success                = NO;
    }
    return self;
}



-(void)setSuccess:(BOOL)success
{
    NSOperationQueue * q = [NSOperationQueue mainQueue];
    if (success) {
        [q addOperations:[self.onSuccessOperations copy] waitUntilFinished:NO];
        [self.onSuccessOperations removeAllObjects];
    } else {
        [q addOperations:[self.onFailOperations copy] waitUntilFinished:NO];
        [self.onFailOperations removeAllObjects];
    
    }
    _success = success;
    
}




@end
