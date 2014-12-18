//
//  BorderlessButton.m
//  Live2BenchNative
//
//  Created by Dev on 2013-09-20.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "BorderlessButton.h"

@implementation BorderlessButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin];
        [self setFont:[UIFont defaultFontOfSize:20.0f]];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self.titleLabel setFont:self.titleFont];
    [self.titleLabel setLineBreakMode:NSLineBreakByClipping];
}

@end
