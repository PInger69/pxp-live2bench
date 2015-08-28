//
//  PxpRangeModifierButton.m
//  Live2BenchNative
//
//  Created by dev on 9/8/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "PxpRangeModifierButton.h"
#import "UIImage+Blend.h"

@implementation PxpRangeModifierButton

static UIImage * __nullable _extendStartImage;
static UIImage * __nullable _extendEndImage;

+ (void)initialize {
    
    _extendStartImage = [[UIImage imageNamed:@"extendstartsec"] imageBlendedWithColor:PRIMARY_APP_COLOR];
    _extendEndImage = [[UIImage imageNamed:@"extendendsec"] imageBlendedWithColor:PRIMARY_APP_COLOR];
}

- (nonnull instancetype)initWithFrame:(CGRect)frame end:(BOOL)end {
    self = [super initWithFrame:frame];
    if (self) {
        self.end = end;
        self.contentMode = UIViewContentModeScaleAspectFill;
    }
    return self;
}

- (nonnull instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame end:NO];
}

- (nonnull instancetype)initWithEnd:(BOOL)end {
    return [self initWithFrame:CGRectZero end:end];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.end = [aDecoder decodeBoolForKey:@"rangeButtonEnd"];
        self.contentMode = UIViewContentModeScaleAspectFill;
    }
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeBool:_end forKey:@"rangeButtonEnd"];
}

#pragma mark - Getters / Setters

- (void)setEnd:(BOOL)end {
    _end = end;
    
    [self setImage:_end ? _extendEndImage : _extendStartImage forState:UIControlStateNormal];
}

@end
