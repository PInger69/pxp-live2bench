//
//  DelayOperation.h
//  OperationLab
//
//  Created by Atomicflare on 2016-04-17.
//  Copyright © 2016 Atomicflare. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DelayOperation : NSOperation
{
    BOOL        executing;
    BOOL        finished;
}

@property (nonatomic,assign) NSTimeInterval time;

- (instancetype)initWithDelay:(NSTimeInterval)aTime;

@end
