//
//  UIColor+Highlight.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-07-22.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "UIColor+Highlight.h"

@implementation UIColor (Highlight)

- (nonnull UIColor *)highlightedColor {
    CGFloat h, s, b, a;
    [self getHue:&h saturation:&s brightness:&b alpha:&a];
    return [UIColor colorWithHue:h saturation:s brightness:fmod(b + 0.5, 1.0) alpha:a];
}

@end
