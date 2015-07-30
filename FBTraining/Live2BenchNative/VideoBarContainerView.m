//
//  VideoBarContainerView.m
//  Live2BenchNative
//
//  Created by dev on 9/2/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "VideoBarContainerView.h"

@implementation VideoBarContainerView
{
    NSMutableArray * touchables;
}


/**
 *  This adds subviews that will be touchable outside of the parent bounds
 *
 *  @param view tapable views
 */
-(void)addTouchableSubview:(UIView *)view
{
    if (!touchables) touchables = [[NSMutableArray alloc]init];
    [touchables addObject:view];
    [super addSubview:view];
}

/**
 *  This is a overrident hit test to allow views outside of the parents view bounds be tapable
 *
 *  @param point location of touch
 *  @param event type of touch
 *
 *  @return view that is touched
 */

- (UIView *)hitTest:(CGPoint)point withEvent:(nullable UIEvent *)event {
    for (UIView *view in touchables) {
        const CGPoint p = [view convertPoint:point fromView:self];
        
        if ([view pointInside:p withEvent:event]) {
            return [view hitTest:p withEvent:event];
        }
    }
    
    return [super hitTest:point withEvent:event];
}

@end
