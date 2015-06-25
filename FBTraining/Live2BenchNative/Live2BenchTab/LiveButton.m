//
//  LiveButton.m
//  Live2BenchNative
//
//  Created by dev on 2014-12-03.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "LiveButton.h"
#import "BorderButton.h"
@implementation LiveButton
UIColor *accentColor;

@synthesize enabled = _enabled;

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
//    self = [BorderButton buttonWithType:UIButtonTypeCustom];
    if (self){
        [self setFrame:frame];
        [self setBackgroundImage:[[UIImage imageNamed:@"gotolive"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]       forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"gotolive"] forState:UIControlStateHighlighted];
        [self setTitle:NSLocalizedString(@"Live", nil)  forState:UIControlStateNormal];
        _enabled = YES;
        
        accentColor = PRIMARY_APP_COLOR;
        [self setBackgroundColor:[UIColor clearColor]];
        [self setBorderColour:self.tintColor];
        [self setBorderWidth:1.0f];
        [self setContentEdgeInsets:UIEdgeInsetsMake(3, 5, 3, 5)];
        [self setTitleColor:self.tintColor forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
//        [self setBackgroundImage:[UIImage imageNamed:@"orangeSelect"] forState:UIControlStateHighlighted];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
//        [self setBackgroundImage:[UIImage imageNamed:@"orangeSelect"] forState:UIControlStateSelected];
//        [self setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [self setFont:[UIFont defaultFontOfSize:17.0f]];
        
    }
    return self;
}

-(void)setHighlighted:(BOOL)highlighted{
    super.highlighted = highlighted;
    [self setNeedsDisplay];
    
    if (highlighted) {
        if (!self.selected) self.backgroundColor = self.tintColor;
    } else {
        if (!self.selected) self.backgroundColor = [UIColor clearColor];
    }
    
}


-(void)setSelected:(BOOL)selected
{
    super.selected = selected;
    [self setNeedsDisplay];
    
    if (selected) {
        self.backgroundColor = self.tintColor;
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
    
}

-(void)isActive:(BOOL)enabled
{
    if (enabled && !_enabled) {
        [self setEnabled:TRUE];
        [self setAlpha:1.0];
        _enabled = enabled;
    } else if (!enabled && _enabled){
        [self setEnabled:FALSE];
        [self setAlpha:0.6];
        _enabled = enabled;
    }
    
    
}


- (void)setAccentColour:(UIColor *)colour
{
    accentColor = colour;
    [self setBorderColour:accentColor];
    [self setTitleColor:accentColor forState:UIControlStateNormal];
    if (accentColor == PRIMARY_APP_COLOR){
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
        self.tintColor = self.window.tintColor;
        [self setTitleColor:self.tintColor forState:UIControlStateNormal];
        [self setBorderColour:self.tintColor];

    } else {
        self.tintColor = [UIColor grayColor];
        [self setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self setBorderColour:[UIColor grayColor]];
    }
}

-(void)tintColorDidChange
{
    [super tintColorDidChange];
    if (self.enabled){
        [self setBorderColour:self.tintColor];
        [self setTitleColor:self.tintColor forState:UIControlStateNormal];
    }
}

@end
