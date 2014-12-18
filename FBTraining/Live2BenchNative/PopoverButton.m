//
//  PopoverButton.m
//  Live2BenchNative
//
//  Created by Dev on 2013-09-17.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "PopoverButton.h"

@implementation PopoverButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor colorWithRed:0.8f green:0.4f blue:0.0f alpha:1.0f] forState:UIControlStateHighlighted];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self setBackgroundImage:[UIImage imageNamed:@"lightGreySelect"] forState:UIControlStateHighlighted];
        [self setFont:[UIFont defaultFontOfSize:23.0f]];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.titleLabel setFont:self.titleFont];
}

@end
