//
//  PxpUndoButton.m
//  PxpTelestration
//
//  Created by Nico Cvitak on 2015-07-14.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import "PxpUndoButton.h"

@implementation PxpUndoButton


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
    
    CGContextMoveToPoint(ctx, c.x, c.y + 0.25 * r);
    CGContextAddLineToPoint(ctx, c.x, c.y + 0.6 * r);
    CGContextAddLineToPoint(ctx, c.x - 0.6 * r, c.y);
    CGContextAddLineToPoint(ctx, c.x, c.y - 0.6 * r);
    CGContextAddLineToPoint(ctx, c.x, c.y - 0.25 * r);
    
    CGPoint ac = CGPointMake(c.x, c.y + 0.5 * r);
    
    CGContextSaveGState(ctx);
    CGContextTranslateCTM(ctx, ac.x, ac.y);
    
    CGContextSaveGState(ctx);
    CGContextScaleCTM(ctx, 1.25, 1.5);
    CGContextAddArc(ctx, 0.0, 0.0, r * 0.5, -M_PI / 2.0, 0, NO);
    CGContextRestoreGState(ctx);
    
    CGContextSaveGState(ctx);
    CGContextScaleCTM(ctx, 1.25, 0.5);
    CGContextAddArc(ctx, 0.0, 0.0, r * 0.5, 0, -M_PI / 2.0, YES);
    
    CGContextRestoreGState(ctx);
    
    CGContextRestoreGState(ctx);
    
    CGContextDrawPath(ctx, kCGPathStroke);
    
    CGContextRestoreGState(ctx);
    
}


@end
