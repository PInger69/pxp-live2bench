//
//  CustomButton.m
//  Live2BenchNative
//
//  Created by DEV on 2013-04-16.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "CustomButton.h"

@implementation CustomButton

UIView *border;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setBorderColour:(UIColor*)colour
{
    [[self layer] setBorderColor:[colour CGColor]];
}

- (void)setBorderWidth:(CGFloat)width
{
    [[self layer] setBorderWidth:width];
}

- (void)setFont:(UIFont *)font
{
    _titleFont = font;
    [self.titleLabel setFont:font];
}

@end
