//
//  UIImage+Blend.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-25.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "UIImage+Blend.h"

@implementation UIImage (Blend)

- (nonnull UIImage *)imageBlendedWithColor:(nonnull UIColor *)color {
    const CGRect bounds = CGRectMake(0.0, 0.0, self.size.width, self.size.height);
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    const CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextFillRect(context, bounds);
    
    [self drawInRect:bounds blendMode:kCGBlendModeNormal alpha:1.0];
    
    CGContextSetBlendMode(context, kCGBlendModeMultiply);
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, bounds);
    
    [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

@end
