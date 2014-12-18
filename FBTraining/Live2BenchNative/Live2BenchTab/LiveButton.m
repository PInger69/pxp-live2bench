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


@synthesize enabled = _enabled;

-(id)initWithFrame:(CGRect)frame
{

    self = [BorderButton buttonWithType:UIButtonTypeCustom];
    if (self){
        [self setFrame:frame];
        [self setBackgroundImage:[UIImage imageNamed:@"gotolive"]       forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"gotoliveSelect"] forState:UIControlStateHighlighted];
        [self setTitle:@"Live" forState:UIControlStateNormal];
        _enabled = YES;
    }
    return self;
}

-(void)setEnabled:(BOOL)enabled
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


@end
