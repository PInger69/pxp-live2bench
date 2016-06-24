//
//  Ticker.h
//  Live2BenchNative
//
//  Created by dev on 2016-06-13.
//  Copyright © 2016 DEV. All rights reserved.
//

// This class just returns true when the ticks = 0 and them repeats the cycle

#import <Foundation/Foundation.h>


@interface Ticker : NSObject
@property (nonatomic,assign) NSInteger maxTick;
@property (nonatomic,assign) NSInteger currentTick;

- (instancetype)initWithTick:(NSInteger)tick;

-(BOOL)ready;

@end
