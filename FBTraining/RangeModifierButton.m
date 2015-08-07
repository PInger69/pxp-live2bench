//
//  RangeModifierButton.m
//  Live2BenchNative
//
//  Created by dev on 9/8/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "RangeModifierButton.h"

@implementation RangeModifierButton

static UIImage * __nullable _extendStartImage;
static UIImage * __nullable _extendEndImage;

+ (void)initialize {
    _extendStartImage = [UIImage imageNamed:@"extendstartsec"];
    _extendEndImage = [UIImage imageNamed:@"extendendsec"];
}

- (nonnull instancetype)initWithFrame:(CGRect)frame type:(RangeButtonType)type {
    self = [super initWithFrame:frame];
    if (self) {
        self.type = type;
        self.contentMode = UIViewContentModeScaleAspectFill;
    }
    return self;
}

- (nonnull instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame type:RangeButtonExtendStart];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.type = [aDecoder decodeIntegerForKey:@"rangeButtonType"];
        self.contentMode = UIViewContentModeScaleAspectFill;
    }
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeInteger:_type forKey:@"rangeButtonType"];
}

#pragma mark - Getters / Setters

- (void)setType:(RangeButtonType)type {
    _type = type;
    
    [self setImage:_type == RangeButtonExtendStart ? _extendStartImage : _type == RangeButtonExtendEnd ? _extendEndImage : nil forState:UIControlStateNormal];
}

@end
