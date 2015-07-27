//
//  NCGhostView.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-07-24.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "NCGhostView.h"

@implementation NCGhostView

- (BOOL)pointInside:(CGPoint)point withEvent:(nullable UIEvent *)event {
    BOOL pointInside = NO;
    for (UIView *subview in self.subviews) {
        if ((pointInside = [subview pointInside:[subview convertPoint:point fromView:self] withEvent:event])) {
            break;
        }
    }
    return pointInside;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
