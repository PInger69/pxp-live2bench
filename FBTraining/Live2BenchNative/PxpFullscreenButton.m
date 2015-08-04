//
//  PxpFullscreenButton.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-07-29.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpFullscreenButton.h"

@implementation PxpFullscreenButton

- (nonnull instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addTarget:self action:@selector(toggleFullscreenAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self addTarget:self action:@selector(toggleFullscreenAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

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
    
    CGAffineTransform t = CGAffineTransformMakeScale(0.5 * self.bounds.size.width, 0.5 * self.bounds.size.height);
    t = CGAffineTransformTranslate(t, 1.0, 1.0);
    t = CGAffineTransformScale(t, 0.8, 0.8);
    
    CGPathAddRect(path, &t, CGRectMake(-1.0, -1.0, 2.0, 2.0));
    
    t = CGAffineTransformScale(t, PHI_INV, PHI_INV);
    
    CGFloat w = PHI_INV, h = PHI_INV;
    
    CGPathMoveToPoint(path, &t, 1.0, -1.0);
    CGPathAddLineToPoint(path, &t, 1.0 - w, -1.0 + h);
    
    CGPathMoveToPoint(path, &t, -1.0, 1.0);
    CGPathAddLineToPoint(path, &t, -1.0 + w, 1.0 - h);
    
    if (!self.selected) {
        CGPathMoveToPoint(path, &t, 1.0 - w, -1.0);
        CGPathAddLineToPoint(path, &t, 1.0, -1.0);
        CGPathAddLineToPoint(path, &t, 1.0, -1.0 + h);
        
        CGPathMoveToPoint(path, &t, -1.0 + w, 1.0);
        CGPathAddLineToPoint(path, &t, -1.0, 1.0);
        CGPathAddLineToPoint(path, &t, -1.0, 1.0 - h);
        
    } else {
        CGPathMoveToPoint(path, &t, 1.0 - w, -1.0);
        CGPathAddLineToPoint(path, &t, 1.0 - w, -1.0 + h);
        CGPathAddLineToPoint(path, &t, 1.0, -1.0 + h);
        
        CGPathMoveToPoint(path, &t, -1.0 + w, 1.0);
        CGPathAddLineToPoint(path, &t, -1.0 + w, 1.0 - h);
        CGPathAddLineToPoint(path, &t, -1.0, 1.0 - h);
        
    }
    
    self.layer.path = path;
    CGPathRelease(path);
}

- (void)toggleFullscreenAction:(UIButton *)sender {
    self.selected = !self.selected;
}

@end
