//
//  UserColorButton.m
//  Live2BenchNative
//
//  Created by dev on 8/15/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "UserColorButton.h"

@implementation UserColorButton

- (id)initWithFrame:(CGRect)frame btnText:(NSString*)btnTxt accessibilityLabel:(NSString*)aLabel
{
    self = [super initWithFrame:frame];
    if (self) {
       
//        [self setFrame:frame];
        [self setBackgroundColor:[self colorWithHexString:btnTxt]];
        [self setTitle:btnTxt forState:UIControlStateNormal];
        [self setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        [self setAccessibilityLabel:aLabel];
        [self setSelected:NO];
   
    }
    return self;
}

-(void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if(selected){
        [self setAlpha:1.0f];
    } else {
        [self setAlpha:0.1f];
    }
}


-(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}


@end
