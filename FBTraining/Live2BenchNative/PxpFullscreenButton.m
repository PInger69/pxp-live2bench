//
//  PxpFullscreenButton.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-07-29.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpFullscreenButton.h"

#import "UIColor+Highlight.h"

@implementation PxpFullscreenButton

- (nonnull instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentMode = UIViewContentModeRedraw;
    }
    return self;
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.contentMode = UIViewContentModeRedraw;
    }
    return self;
}


- (void)tintColorDidChange {
    [super tintColorDidChange];
    [self setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected {
    [self willChangeValueForKey:@"isFullscreen"];
    [super setSelected:selected];
    [self didChangeValueForKey:@"isFullscreen"];
    
    [self setNeedsDisplay];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(ctx);
    
    CGContextSetLineWidth(ctx, 0.05 * MIN(self.bounds.size.width, self.bounds.size.height));
    CGContextSetStrokeColorWithColor(ctx, self.highlighted ? self.tintColor.highlightedColor.CGColor : self.tintColor.CGColor);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    
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
    
    CGContextAddPath(ctx, path);
    CGContextDrawPath(ctx, kCGPathStroke);
    
    CGPathRelease(path);
    CGContextRestoreGState(ctx);
}

- (BOOL)isFullscreen {
    return self.selected;
}

- (void)setIsFullscreen:(BOOL)isFullscreen {
    self.selected = isFullscreen;
}

@end
