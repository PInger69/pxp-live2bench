//
//  VideoControlBar.m
//  QuickTest
//
//  Created by dev on 6/24/2014.
//  Copyright (c) 2014 dev. All rights reserved.
//

#import "VideoControlBar.h"

#define SIDE_MARGINS 20

@implementation VideoControlBar
{
    NSArray * touchables;
}

@synthesize tagEventName;
@synthesize slomo;
@synthesize seekForward;
@synthesize seekBackward;



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}


-(void)setup
{

	[self setBackgroundColor:[UIColor colorWithWhite:0.9f alpha:1.0f]];
	[self setUserInteractionEnabled:TRUE];//?

    tagEventName = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.frame)- (150/2), 0, 150, 30)];
    [tagEventName setBackgroundColor:[UIColor clearColor]];
    tagEventName.layer.borderColor = PRIMARY_APP_COLOR.CGColor;
    tagEventName.layer.borderWidth = 1;
    [tagEventName setText:@"Event Name"];
    [tagEventName setTextColor:self.tintColor];
    [tagEventName setTextAlignment:NSTextAlignmentCenter];
    
    slomo           = [[Slomo alloc]initWithFrame:CGRectMake(SIDE_MARGINS+40+5,0, 60, 30)];
    seekForward     = [SeekButton makeForwardAt:CGPointMake(self.frame.size.width-40-SIDE_MARGINS, -5)];
    seekBackward    = [SeekButton makeBackwardAt:CGPointMake(SIDE_MARGINS, -5)];
    
	[self addSubview:tagEventName];
	[self addSubview:slomo];
	[self addSubview:seekForward];
	[self addSubview:seekBackward];

    touchables = @[slomo,seekForward,seekBackward];

    
}

/**
 *  This will allow the subviews in the list to be clicked even outside the parent bounds
 *
 *  @param point
 *  @param event
 *
 *  @return 
 */
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {

    
    CGPoint pointForTargetView;
    
    for (UIView * object in touchables) {
        pointForTargetView = [object convertPoint:point fromView:self];
        if (CGRectContainsPoint(object.bounds, pointForTargetView)) {
            return [object hitTest:pointForTargetView withEvent:event];
        }
    }
    
    return [super hitTest:point withEvent:event];
}

-(void)setHiddenControls:(BOOL)val
{
	[tagEventName setHidden:val];
	[slomo setHidden:val];
	[seekForward setHidden:val];
	[seekBackward setHidden:val];
}

-(void)tintColorDidChange
{
    [super tintColorDidChange];
    tagEventName.layer.borderColor = self.tintColor.CGColor;
    [tagEventName setTextColor:self.tintColor];

}

@end
