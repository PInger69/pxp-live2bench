//
//  ClipCornerVIew.m
//  Live2BenchNative
//
//  Created by Sukhwinder Lall on 2013-09-19.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "ClipCornerView.h"

@implementation ClipCornerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

//-(void)drawRect:(CGRect)rect
//{
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    
//    CGContextBeginPath(ctx);
//    CGContextMoveToPoint   (ctx, CGRectGetMinX(rect), CGRectGetMinY(rect));  // top left
//    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMinY(rect));  // mid right
//    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMaxY(rect));  // bottom left
//    CGContextClosePath(ctx);
//    
//    CGContextFillPath(ctx);
//
//}
//

-(void)changeColor:(UIColor*)colorToChange withRect:(CGRect)rect;
{
    
    //this is an arbitrary size for example
    CGSize aSize = rect.size;
    
    //this can take any CGSize
    //it works like the frame.size would in the drawRect: method
    //in the way that it represents the context's size
    UIGraphicsBeginImageContext(aSize);
    
    //this gets the graphic context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //you can do drawing just like you would in the drawRect: method
    //I am drawing a square just for an example to show you that you can do any sort of drawing in here
    CGContextMoveToPoint(context, 0.f, 0.f);
    CGContextAddLineToPoint(context, aSize.width, 0.f);
    CGContextAddLineToPoint(context, aSize.width, aSize.height);
    CGContextClosePath(context);
    
    //you can stroke and/or fill
    CGContextSetStrokeColorWithColor(context,colorToChange.CGColor);
    CGContextSetFillColorWithColor(context, colorToChange.CGColor);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    //now get the image from the context
    UIImage *squareImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    UIImageView *squareImageView = [[UIImageView alloc]initWithImage:squareImage];
    [self addSubview:squareImageView];
    
//    CGColorRef color = [colorToChange CGColor];
 
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
