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

typedef NS_OPTIONS(int, BUTTON_CONTEXT) {
    PLAY_BUTTON     = 1,
    DOWNLOAD_BUTTON = 2
};

@interface CustomButton : UIButton

@property (nonatomic,readonly) UIFont *titleFont;
@property (assign, nonatomic) BUTTON_CONTEXT buttonContext;

-(void)setBorderColour:(UIColor*)colour;
-(void)setBorderWidth:(CGFloat)width;
-(void)setFont:(UIFont *)font;
-(void)setPlayButton;
//-(void)setDownloadButtonWithProgress: (float) amountCompleted;

@property (nonatomic, strong) NSDictionary* associatedTag;

@end