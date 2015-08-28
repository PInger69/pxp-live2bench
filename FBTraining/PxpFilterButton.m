//
//  PxpFilterButton.m
//  Live2BenchNative
//
//  Created by dev on 2015-08-13.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpFilterButton.h"

@implementation PxpFilterButton
{
    UIImage * _buttonHighlightPixel;
    UIImage * _buttonNormalPixel;


}

@synthesize ownPredicate = _ownPredicate;

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _buttonHighlightPixel   = [Utility makeOnePixelUIImageWithColor:PRIMARY_APP_COLOR];
        _buttonNormalPixel      = [Utility makeOnePixelUIImageWithColor:[UIColor lightGrayColor]];
        [self addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
        [self setBackgroundImage:_buttonHighlightPixel forState:UIControlStateSelected];
        [self setBackgroundImage:_buttonNormalPixel forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    }
    return self;
}


-(void)encodeWithCoder:(nonnull NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _buttonHighlightPixel   = [Utility makeOnePixelUIImageWithColor:PRIMARY_APP_COLOR];
        _buttonNormalPixel      = [Utility makeOnePixelUIImageWithColor:[UIColor lightGrayColor]];
        [self addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
        [self setBackgroundImage:_buttonHighlightPixel forState:UIControlStateSelected];
        [self setBackgroundImage:_buttonNormalPixel forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    }
    return self;
}

-(void)buttonSelected:(id)sender
{
    self.selected = !self.selected;

    [_filterModuleDelegate onUserInput:self];
}


-(void)deselect
{
    self.selected = NO;
}

-(void)reset{
    [self deselect];
}

@end
