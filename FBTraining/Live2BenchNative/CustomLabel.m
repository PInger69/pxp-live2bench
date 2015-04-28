//
//  CustomLabel.m
//  Live2BenchNative
//
//  Created by Dev on 2013-09-20.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "CustomLabel.h"

@implementation CustomLabel
{

    CGRect margin;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)init
{
    margin = CGRectMake(0, 0, 0, 0);
    return [super init];
}

+ (CustomLabel*)labelWithStyle:(CLStyleType)style{
    CustomLabel* label = [[CustomLabel alloc] init];
    switch (style) {
        case 1:
        case 4:
            label.textColor = PRIMARY_APP_COLOR;
            break;
        case 2:
        case 5:
            label.textColor = [UIColor blackColor];
            break;
        case 3:
        case 6:
            label.textColor = [UIColor whiteColor];
            break;
        case 7:
            label.textColor = [UIColor colorWithWhite:0.5f alpha:1.0f];
            break;
        default:
            break;
    }
    if (style < 4){
        label.font = [UIFont defaultFontOfSize:23.0f];
//        label.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    } else {
        label.font = [UIFont defaultFontOfSize:17.0f];
    }
    label.backgroundColor = [UIColor clearColor];
    return label;
}

-(void)setMargin:(CGRect)newMargin
{
    margin = newMargin;
}

-(void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = {margin.origin.x, margin.origin.y, margin.size.width,  margin.size.height};
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}



@end
