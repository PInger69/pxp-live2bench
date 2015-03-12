//
//  drawXYZ.m
//  Live2BenchNative
//
//  Created by dev on 13-01-23.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "drawXYZ.h"

@implementation drawXYZ

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 1.0);
//    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    CGRect rectangle = CGRectMake(10,0,1,40);
//    CGContextAddRect(context, rectangle);
//    CGContextStrokePath(context);
    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
    CGContextFillRect(context, rectangle);
    
    
    CGContextSetLineWidth(context, 1.0);
    //    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGRect rectangle2 = CGRectMake(20,0,1,40);
    //    CGContextAddRect(context, rectangle);
    //    CGContextStrokePath(context);
    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
    CGContextFillRect(context, rectangle2);
    
    CGContextSetLineWidth(context, 1.0);
    //    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGRect rectangle3 = CGRectMake(40,0,1,40);
    //    CGContextAddRect(context, rectangle);
    //    CGContextStrokePath(context);
    CGContextSetFillColorWithColor(context, [UIColor blueColor].CGColor);
    CGContextFillRect(context, rectangle3);

    
}


@end
