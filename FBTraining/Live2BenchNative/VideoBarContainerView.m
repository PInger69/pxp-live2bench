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
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    
    CGPoint pointForTargetView;
    NSInteger tounchCount = touchables.count-1;
    UIView * object;
    
    for (NSInteger i =tounchCount; i >= 0 ; i--){
        object = [touchables objectAtIndex:i];
        
//        // This removes it from touchables if its not on the view
//        if ( object.superview == nil || object.superview != self) {
//            [touchables removeObject:object];
//            continue;
//        }
        
        // check the tap
        pointForTargetView = [object convertPoint:point fromView:self];
        if (CGRectContainsPoint(object.bounds, pointForTargetView)) {
            return [object hitTest:pointForTargetView withEvent:event];
        }
    
    }
    

    return [super hitTest:point withEvent:event];
}


@end
