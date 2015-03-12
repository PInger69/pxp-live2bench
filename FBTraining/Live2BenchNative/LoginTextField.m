//
//  LoginTextField.m
//  Live2BenchNative
//
//  Created by Dev on 2013-09-18.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "LoginTextField.h"
#import "UIFont+Default.h"

@implementation LoginTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 10.0f, self.bounds.size.height)];
        [leftView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleRightMargin];
        [self setLeftView:leftView];
        [self setLeftViewMode:UITextFieldViewModeAlways];
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews{
    [self setTextColor:[UIColor orangeColor]];
    [self setContentVerticalAlignment: UIControlContentVerticalAlignmentCenter];
    [self setAutocapitalizationType: UITextAutocapitalizationTypeNone];
    [self setAutocorrectionType: UITextAutocorrectionTypeNo];
    [self setFont:[UIFont defaultFontOfSize:20.0f]];
    [self setBackgroundColor:[UIColor clearColor]];
    [super layoutSubviews];
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
