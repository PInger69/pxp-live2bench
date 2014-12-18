//
//  DashedLineView.m
//  Live2BenchNative
//
//  Created by Si Te Feng on 6/11/14.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "DashedLineView.h"

@implementation DashedLineView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, [UIColor darkGrayColor].CGColor);
    CGContextSetLineWidth(context, 3);
    
//    float lengths[] = {5,10};
//    CGContextSetLineDash(context, 1, lengths, 2);
    CGContextSetLineCap(context, kCGLineCapRound);
    
    CGContextMoveToPoint(context, rect.size.width, 0);
    
    CGContextAddLineToPoint(context, 0, 0);
    
    CGContextStrokePath(context);
    
}


@end
