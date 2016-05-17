//
//  NameCameraCellView.m
//  Live2BenchNative
//
//  Created by dev on 2016-04-11.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "NameCameraCellView.h"

@implementation NameCameraCellView



- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSBundle mainBundle]loadNibNamed:@"NameCameraCellView" owner:self options:nil];
        self.bounds = self.view.bounds;
        [self addSubview:self.view];
//        self.view.layer.borderWidth = 1;
        self.view.layer.cornerRadius = 3;
        self.camIDLabel.text = @"x";
        self.UserInputField.text = @"x";
        [self.heightAnchor constraintEqualToConstant:self.view.bounds.size.height].active = YES;
        [self.widthAnchor constraintEqualToConstant:self.view.bounds.size.width].active  = YES;
    }
    return self;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
