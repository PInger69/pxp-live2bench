//
//  Slomo.m
//  QuickTest
//
//  Created by dev on 6/24/2014.
//  Copyright (c) 2014 dev. All rights reserved.
//

#import "Slomo.h"

@implementation Slomo

static UIImage * _normalSpeedImage;
static UIImage * _slowSpeedImage;

+ (void)initialize {
    _normalSpeedImage = [[UIImage imageNamed:@"normalsp.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _slowSpeedImage   = [[UIImage imageNamed:@"slowmo.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (nonnull instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		[self setContentMode:UIViewContentModeScaleAspectFit];
	
		[self setImage:_normalSpeedImage forState:UIControlStateNormal];
        [self setImage:_slowSpeedImage forState:UIControlStateSelected];
    }
    return self;
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setContentMode:UIViewContentModeScaleAspectFit];
        
        [self setImage:_normalSpeedImage forState:UIControlStateNormal];
        [self setImage:_slowSpeedImage forState:UIControlStateSelected];
    }
    return self;
}

#pragma mark - Overrides

- (void)setSelected:(BOOL)selected {
    [self willChangeValueForKey:@"slomoOn"];
    [super setSelected:selected];
    [self didChangeValueForKey:@"slomoOn"];
}

#pragma mark - Getters / Setters

- (void)setSlomoOn:(BOOL)slomoOn {
    self.selected = slomoOn;
}

- (BOOL)slomoOn {
    return self.selected;
}

@end
