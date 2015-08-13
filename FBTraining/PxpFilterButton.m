//
//  PxpFilterButton.m
//  Live2BenchNative
//
//  Created by dev on 2015-08-13.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpFilterButton.h"

@implementation PxpFilterButton

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    [[self layer] setBorderColor:[[UIColor clearColor] CGColor]];
    [[self layer] setBorderWidth:1];
    UIImage *buttonHighlightPixel   = [Utility makeOnePixelUIImageWithColor:PRIMARY_APP_COLOR];
    UIImage *buttonNormalPixel      = [Utility makeOnePixelUIImageWithColor:[UIColor lightGrayColor]];
    [self setImage:buttonHighlightPixel forState:UIControlStateHighlighted];
    [self setImage:buttonNormalPixel forState:UIControlStateNormal];
    [self setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    return self;
}

-(void)setHighlighted:(BOOL)highlighted{
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
}

@end
