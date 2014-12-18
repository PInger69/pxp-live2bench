//
//  BorderButton.m
//  Live2BenchNative
//
//  Created by Dev on 2013-09-17.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "BorderButton.h"

UIColor *accentColor;

@implementation BorderButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        accentColor = [UIColor orangeColor];
        [self setBackgroundColor:[UIColor clearColor]];
        [self setBorderColour:accentColor];
        [self setBorderWidth:1.0f];
        [self setContentEdgeInsets:UIEdgeInsetsMake(3, 5, 3, 5)];
        [self setTitleColor:accentColor forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [self setBackgroundImage:[UIImage imageNamed:@"orangeSelect"] forState:UIControlStateHighlighted];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [self setBackgroundImage:[UIImage imageNamed:@"orangeSelect"] forState:UIControlStateSelected];
        [self setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [self setFont:[UIFont defaultFontOfSize:17.0f]];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.titleLabel setFont:self.titleFont];
}

- (void)setAccentColour:(UIColor *)colour
{
    accentColor = colour;
    [self setBorderColour:accentColor];
    [self setTitleColor:accentColor forState:UIControlStateNormal];
    if (accentColor == [UIColor orangeColor]){
        [self setBackgroundImage:[UIImage imageNamed:@"orangeSelect"] forState:UIControlStateHighlighted];
    } else if (accentColor == [UIColor redColor]){
        [self setBackgroundImage:[UIImage imageNamed:@"redSelect"] forState:UIControlStateHighlighted];
    } else if (accentColor == [UIColor greenColor]){
        [self setBackgroundImage:[UIImage imageNamed:@"greenSelect"] forState:UIControlStateHighlighted];
    } else if (accentColor == [UIColor blueColor]){
        [self setBackgroundImage:[UIImage imageNamed:@"blueSelect"] forState:UIControlStateHighlighted];
    }
}

-(void)changeBackgroundColor:(UIColor*)colour : (float)alphaVal{
    
    [self setBackgroundColor:colour];
    [self setAlpha:alphaVal];
}

-(void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    if (enabled) {
        [self setBorderColour:accentColor];
    } else {
        [self setBorderColour:[UIColor grayColor]];
    }
}

-(void)tintColorDidChange
{
    [super tintColorDidChange];
    [self setBorderColour:self.tintColor];
    
    [self setTitleColor:self.tintColor forState:UIControlStateNormal];

}

@end
