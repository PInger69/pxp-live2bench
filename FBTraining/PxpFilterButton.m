//
//  PxpFilterButton.m
//  Live2BenchNative
//
//  Created by dev on 2015-08-13.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpFilterButton.h"

@implementation PxpFilterButton
@synthesize ownPredicate = _ownPredicate;

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    [[self layer] setBorderColor:[[UIColor clearColor] CGColor]];
    [[self layer] setBorderWidth:1];
    //UIImage *buttonHighlightPixel   = [Utility makeOnePixelUIImageWithColor:PRIMARY_APP_COLOR];
    //UIImage *buttonNormalPixel      = [Utility makeOnePixelUIImageWithColor:[UIColor redColor]];
    [self addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
    //[self setImage:buttonHighlightPixel forState:UIControlStateSelected];
    //[self setImage:buttonNormalPixel forState:UIControlStateNormal];
    [self setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    return self;
}

-(void)buttonSelected:(id)sender
{
    self.selected = !self.selected;
    [_ownDelegate onButtonSelected:self];
}


-(void)deselect
{
    self.selected = NO;
}

-(void)reset{
    [self deselect];
}

@end
