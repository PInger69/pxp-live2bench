//
//  UploadButton.m
//  Live2BenchNative
//
//  Created by DEV on 2013-11-22.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "UploadButton.h"

@implementation UploadButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSURL *url = [[NSBundle mainBundle]URLForResource:@"uploading" withExtension:@"gif"];
        [self setImage:[UIImage animatedImageWithAnimatedGIFURL:url] forState:UIControlStateNormal];
        [self setAccessibilityValue:@"localTagUploadingPNG"];
    }
    return self;
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
