//
//  Slomo.m
//  QuickTest
//
//  Created by dev on 6/24/2014.
//  Copyright (c) 2014 dev. All rights reserved.
//

#import "Slomo.h"

@implementation Slomo

@synthesize slomoOn = _slomoOn;

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
		_slomoOn = NO;

		[self setFrame:frame];
		[self setContentMode:UIViewContentModeScaleAspectFill];
	
		[self setImage:normalSpeed forState:UIControlStateNormal];
    }
    return self;
}


//-(void)setHighlighted:(BOOL)highlighted
//{
//    [super setHighlighted:highlighted];
//    if (!highlighted) {
//        slomoOn = !slomoOn;
//        if (slomoOn){
//            [self setImage:slowSpeed forState:UIControlStateNormal];
//            [self setImage:slowSpeed forState:UIControlStateHighlighted];
//        } else {
//            [self setImage:normalSpeed forState:UIControlStateNormal];
//            [self setImage:normalSpeed forState:UIControlStateHighlighted];
//        }
//    }
//}

-(void)tintColorDidChange
{
    [super tintColorDidChange];

}


-(void)setSlomoOn:(BOOL)slomoOn
{
    _slomoOn = slomoOn;
    
    if (!_slomoOn){
        [self setImage:normalSpeed forState:UIControlStateNormal];
    } else {
         [self setImage:slowSpeed forState:UIControlStateNormal];
    }

}


-(BOOL)slomoOn
{

    return _slomoOn;

}


@end
