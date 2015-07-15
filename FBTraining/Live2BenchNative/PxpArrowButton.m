//
//  PxpArrowButton.m
//  PxpTelestration
//
//  Created by Nico Cvitak on 2015-07-14.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import "PxpArrowButton.h"

@implementation PxpArrowButton


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGPoint c = self.center;
    CGFloat r = self.radius;
    
    CGContextSaveGState(ctx);
    
    CGContextTranslateCTM(ctx, c.x, c.y);
    CGContextRotateCTM(ctx, 27 * M_PI / 16.0);
    
    CGContextBeginPath(ctx);
    
    CGFloat l = 0.75 * r;
    CGContextMoveToPoint(ctx, l * cos(0.0), l * sin(0.0));
    CGContextAddLineToPoint(ctx, l * cos(5.0 * M_PI / 6.0), l * sin(5.0 * M_PI / 6.0));
    CGContextAddLineToPoint(ctx, 0.25 * l * cos(6.0 * M_PI / 6.0), 0.25 * l * sin(6.0 * M_PI / 6.0));
    CGContextAddLineToPoint(ctx, l * cos(7.0 * M_PI / 6.0), l * sin(7.0 * M_PI / 6.0));
    CGContextAddLineToPoint(ctx, l * cos(0.0), l * sin(0.0));
    
    CGContextDrawPath(ctx, kCGPathFillStroke);
    
    CGContextRestoreGState(ctx);
}


@end
