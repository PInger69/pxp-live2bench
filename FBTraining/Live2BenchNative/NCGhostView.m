//
//  NCGhostView.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-07-24.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "NCGhostView.h"

@implementation NCGhostView

- (void)touchesBegan:(nonnull NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    [self.nextResponder touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(nonnull NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    [self.nextResponder touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(nonnull NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    [self.nextResponder touchesCancelled:touches withEvent:event];
}

- (void)touchesCancelled:(nullable NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    [self.nextResponder touchesCancelled:touches withEvent:event];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
