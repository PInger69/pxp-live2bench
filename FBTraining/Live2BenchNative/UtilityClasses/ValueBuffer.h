//
//  ValueBuffer.h
//  Live2BenchNative
//
//  Created by dev on 2015-02-19.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ValueBuffer : NSObject
@property (nonatomic, assign) int value;
- (instancetype)initWithValue:(int)value coolDownValue:(int)aCoolDownValue coolDownTick:(int)tick;
-(void)onCoolDown;
@end
