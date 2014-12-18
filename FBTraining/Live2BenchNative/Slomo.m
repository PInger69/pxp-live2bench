//
//  Slomo.m
//  QuickTest
//
//  Created by dev on 6/24/2014.
//  Copyright (c) 2014 dev. All rights reserved.
//

#import "Slomo.h"

@implementation Slomo

@synthesize slomoOn;

static UIImage * normalSpeed;
static UIImage * slowSpeed;
static BOOL * isStaticInit;


+(void)staticInit
{
	normalSpeed = [[UIImage imageNamed:@"normalsp.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	slowSpeed   = [[UIImage imageNamed:@"slowmo.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    	if (!isStaticInit) [Slomo staticInit];
		slomoOn = NO;

		[self setFrame:frame];
		[self setContentMode:UIViewContentModeScaleAspectFill];
	
		[self setImage:normalSpeed forState:UIControlStateNormal];
    }
    return self;
}


-(void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    if (!highlighted) {
        slomoOn = !slomoOn;
        if (slomoOn){
            [self setImage:slowSpeed forState:UIControlStateNormal];
        } else {
            [self setImage:normalSpeed forState:UIControlStateNormal];
        }
    }
}

-(void)tintColorDidChange
{
    [super tintColorDidChange];

}

@end
