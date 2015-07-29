//
//  PxpFullscreenButton.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-07-29.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpFullscreenButton.h"

@implementation PxpFullscreenButton

- (void)layoutSubviews {
    self.stroke = YES;
    self.layer.lineWidth = 0.05 * MIN(self.bounds.size.width, self.bounds.size.height);
    [super layoutSubviews];
    [self updateLayer];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self updateLayer];
}

- (void)updateLayer {
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGAffineTransform t = CGAffineTransformMakeScale(0.95, 0.95);
    t = CGAffineTransformTranslate(t, 0.025 * self.bounds.size.width, 0.025 * self.bounds.size.height);
    
    CGFloat w = 0.5 * PHI_INV * self.bounds.size.width, h = 0.5 * PHI_INV * self.bounds.size.height;
    
    CGPathMoveToPoint(path, &t, self.bounds.size.width, 0.0);
    CGPathAddLineToPoint(path, &t, self.bounds.size.width - w, h);
    
    CGPathMoveToPoint(path, &t, 0.0, self.bounds.size.height);
    CGPathAddLineToPoint(path, &t, w, self.bounds.size.height - h);
    
    if (!self.selected) {
        CGPathMoveToPoint(path, &t, self.bounds.size.width - w, 0.0);
        CGPathAddLineToPoint(path, &t, self.bounds.size.width, 0.0);
        CGPathAddLineToPoint(path, &t, self.bounds.size.width, h);
        
        CGPathMoveToPoint(path, &t, w, self.bounds.size.height);
        CGPathAddLineToPoint(path, &t, 0.0, self.bounds.size.height);
        CGPathAddLineToPoint(path, &t, 0.0, self.bounds.size.height - h);
        
    } else {
        CGPathMoveToPoint(path, &t, self.bounds.size.width - w, 0.0);
        CGPathAddLineToPoint(path, &t, self.bounds.size.width - w, h);
        CGPathAddLineToPoint(path, &t, self.bounds.size.width, h);
        
        CGPathMoveToPoint(path, &t, w, self.bounds.size.height);
        CGPathAddLineToPoint(path, &t, w, self.bounds.size.height - h);
        CGPathAddLineToPoint(path, &t, 0.0, self.bounds.size.height - h);
        
    }
    
    self.layer.path = path;
    CGPathRelease(path);
}

@end
