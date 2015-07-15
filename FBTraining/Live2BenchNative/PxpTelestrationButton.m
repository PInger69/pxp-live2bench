//
//  PxpStartTelestrationButton.m
//  PxpTelestration
//
//  Created by Nico Cvitak on 2015-07-14.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import "PxpTelestrationButton.h"

@implementation PxpTelestrationButton


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGPoint c = self.center;
    CGFloat r = self.radius;
    
    CGContextSaveGState(ctx);
    
    CGContextSetFillColorWithColor(ctx, [UIColor clearColor].CGColor);
    
    CGContextTranslateCTM(ctx, c.x, c.y);
    CGContextRotateCTM(ctx, 27 * M_PI / 16.0);
    
    CGContextBeginPath(ctx);
    
    CGContextMoveToPoint(ctx, - 0.75 * r , 0.0);
    CGContextAddLineToPoint(ctx, - 0.52 * r, - 0.15 * r);
    CGContextAddLineToPoint(ctx, + 0.52 * r, - 0.15 * r);
    CGContextAddLineToPoint(ctx, + 0.52 * r, + 0.15 * r);
    CGContextAddLineToPoint(ctx, - 0.52 * r, + 0.15 * r);
    CGContextAddLineToPoint(ctx, - 0.75 * r, 0.0);
    
    CGContextMoveToPoint(ctx, + 0.58 * r, - 0.15 * r);
    CGContextAddLineToPoint(ctx, + 0.75 * r, - 0.15 * r);
    CGContextAddLineToPoint(ctx, + 0.75 * r, + 0.15 * r);
    CGContextAddLineToPoint(ctx, + 0.58 * r, + 0.15 * r);
    CGContextAddLineToPoint(ctx, + 0.58 * r, - 0.15 * r);
    
    CGContextDrawPath(ctx, kCGPathFillStroke);
    
    CGContextRestoreGState(ctx);
}


@end
