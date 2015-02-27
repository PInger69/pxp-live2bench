//
//  ValueBuffer.m
//  Live2BenchNative
//
//  Created by dev on 2015-02-19.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "ValueBuffer.h"

@implementation ValueBuffer
{

    int currentTick;
    int maxTick;
    int normalValue;
    int coolDownValue;
}

@synthesize value = _value;

- (instancetype)initWithValue:(int)value coolDownValue:(int)aCoolDownValue coolDownTick:(int)tick
{
    self = [super init];
    if (self) {
        maxTick         = tick;
        currentTick     = 0;
        normalValue     = value;
        coolDownValue   = aCoolDownValue;
    }
    return self;
}


-(int)value
{
    
    if (currentTick++ >= maxTick) {
        _value = normalValue;
    } else {
        _value = coolDownValue;
    }
    return _value;
}




-(void)setValue:(int)value
{
    
}

-(void)onCoolDown
{
    currentTick = 0;
}

@end
