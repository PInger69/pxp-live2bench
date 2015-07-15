//
//  PxpLineButton.m
//  PxpTelestration
//
//  Created by Nico Cvitak on 2015-07-14.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import "PxpLineButton.h"

@implementation PxpLineButton


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
    
    CGFloat d = 0.5 * M_PI / r;
    CGFloat l = 0.75 * r;
    CGContextMoveToPoint(ctx, l * cos(-d), l * sin(-d));
    CGContextAddLineToPoint(ctx, l * cos(+d), l * sin(+d));
    CGContextAddLineToPoint(ctx, l * cos(M_PI - d), l * sin(M_PI - d));
    CGContextAddLineToPoint(ctx, l * cos(M_PI + d), l * sin(M_PI + d));
    CGContextAddLineToPoint(ctx, l * cos(-d), l * sin(- d));
    
    CGContextDrawPath(ctx, kCGPathFillStroke);
    
    CGContextRestoreGState(ctx);
}


@end
