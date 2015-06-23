//
//  SideTagButton.m
//  Live2BenchNative
//
//  Created by dev on 2015-06-23.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "SideTagButton.h"

@implementation SideTagButton
{
    BOOL                         isON;
    UIColor                      *accentColor;
    SideTagButtonModes           mode;
}

@synthesize durationID = _durationID;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        accentColor = PRIMARY_APP_COLOR;
        [self setBackgroundColor:[UIColor clearColor]];
        [[self layer] setBorderColor:accentColor.CGColor];
        [[self layer] setBorderWidth:1.0f];
        [self setContentEdgeInsets:UIEdgeInsetsMake(3, 5, 3, 5)];
        [self setTitleColor:accentColor forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [self setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [self.titleLabel setFont:[UIFont systemFontOfSize:17.0f]];
        [self getEnabled:false];

    }
    return self;
}

-(void)getEnabled:(BOOL)enabled
{
    //[super setEnabled:enabled];
    if (enabled) {
        [[self layer] setBorderColor:accentColor.CGColor];
        [self setAlpha:1.0];
        self.enabled = true;

    } else {
        [[self layer] setBorderColor:[UIColor grayColor].CGColor];
        [self setAlpha:0.4];
        self.enabled = false;
    }
}

-(void)setHighlighted:(BOOL)highlighted{
    super.highlighted = highlighted;
    [self setNeedsDisplay];
}

-(void)tintColorDidChange
{
    [super tintColorDidChange];
    [[self layer] setBorderColor:self.tintColor.CGColor];
    
    [self setTitleColor:self.tintColor forState:UIControlStateNormal];
}

-(void)setMode:(SideTagButtonModes)newMode
{
    if (mode == newMode) return;
    mode = newMode;
 
    switch (mode) {
        case SideTagButtonModeDisable :
            [self getEnabled:false];
            break;
        case SideTagButtonModeRegular :
            [self getEnabled:true];
            break;
        case SideTagButtonModeToggle :
            [self getEnabled:true];
            break;
        default:
            break;
    }
}

-(void)setIsON:(BOOL)isOnValue{
    if (mode == SideTagButtonModeToggle) {
        if (isON && !isOnValue) {
            isON = false;
            [self setHighlighted:false];
        }
        if (!isON && isOnValue) {
            isON = true;
            [self setHighlighted:true];
        }
    }
}




@end
