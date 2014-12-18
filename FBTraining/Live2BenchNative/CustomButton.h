//
//  CustomButton.h
//  Live2BenchNative
//
//  Created by DEV on 2013-04-16.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "UIFont+Default.h"

@interface CustomButton : UIButton

@property (nonatomic,readonly) UIFont *titleFont;

-(void)setBorderColour:(UIColor*)colour;
-(void)setBorderWidth:(CGFloat)width;
-(void)setFont:(UIFont *)font;

@property (nonatomic, strong) NSDictionary* associatedTag;

@end
