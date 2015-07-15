//
//  PxpCircleButton.m
//  PxpTelestration
//
//  Created by Nico Cvitak on 2015-07-14.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import "PxpCircleButton.h"

@implementation PxpCircleButton


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    UIColor *color = [self buttonColor];
    CGContextSetStrokeColorWithColor(ctx, color.CGColor);
    CGContextSetFillColorWithColor(ctx, [UIColor clearColor].CGColor);
    
    CGContextSetBlendMode(ctx, kCGBlendModeCopy);
    
    CGPoint c = self.center;
    CGFloat r = self.radius;
    CGFloat w = r * 0.1;
    
    CGContextSaveGState(ctx);
    CGContextSetFillColorWithColor(ctx, color.CGColor);
    CGContextSetLineWidth(ctx, w);
    CGContextAddArc(ctx, c.x, c.y, r - (w / 2.0), 0, 2 * M_PI, 0);
    
    CGContextDrawPath(ctx, self.selected ? kCGPathFillStroke : kCGPathStroke);
    
    CGContextRestoreGState(ctx);
}

- (CGPoint)center {
    return CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

- (CGFloat)radius {
    return MIN(self.bounds.size.width, self.bounds.size.height) / 2.0;
}

- (nullable UIColor *)buttonColor {
    if (self.highlighted) {
        CGFloat h, s, b, a;
        [self.tintColor getHue:&h saturation:&s brightness:&b alpha:&a];
        return [UIColor colorWithHue:h saturation:s brightness:fmod(b + 0.5, 1.0) alpha:a];
    } else {
        return self.tintColor;
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self setNeedsDisplay];
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    [self setNeedsDisplay];
}

@end
