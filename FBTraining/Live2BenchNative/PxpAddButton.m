//
//  PxpAddButton.m
//  PxpTelestration
//
//  Created by Nico Cvitak on 2015-07-14.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import "PxpAddButton.h"

@implementation PxpAddButton


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGPoint c = self.center;
    CGFloat r = self.radius;
    
    CGContextSaveGState(ctx);
    
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, c.x - 0.75 * r, c.y);
    CGContextAddLineToPoint(ctx, c.x + 0.75 * r, c.y);
    CGContextMoveToPoint(ctx, c.x, c.y - 0.75 * r);
    CGContextAddLineToPoint(ctx, c.x, c.y + 0.75 * r);
    
    CGContextDrawPath(ctx, kCGPathStroke);
    
    CGContextRestoreGState(ctx);
}

@end
