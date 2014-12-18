//
//  UIFont+Default.m
//  Live2BenchNative
//
//  Created by Dev on 2013-09-18.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "UIFont+Default.h"

@implementation UIFont (Default)

+(UIFont *)defaultFontOfSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:fontSize];
}

+(UIFont *)lightFontOfSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:fontSize];
}

+(UIFont *)regularFontOfSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"HelveticaNeue" size:fontSize];
    
}

+(UIFont *)boldFontOfSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"HelveticaNeue-bold" size:fontSize];
}
@end
