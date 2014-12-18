//
//  DownloadButton.m
//  Live2BenchNative
//
//  Created by Dev on 2013-10-04.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "DownloadButton.h"

@implementation DownloadButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setState:DBDefault];
    }
    return self;
}

- (void)setState:(DBDownloadState)state
{
    switch (state) {
        case 1:
        {
            NSURL *url = [[NSBundle mainBundle] URLForResource:@"downloading" withExtension:@"gif"];
            [self setImage:[UIImage animatedImageWithAnimatedGIFURL:url] forState:UIControlStateNormal];
            [self setAccessibilityValue:@"bookmarkDownloadingPNG"];
        }
            break;
        case 2:
        {
            [self setImage:[UIImage imageNamed:@"download_selected"] forState:UIControlStateNormal];
            [self setAccessibilityValue:@"bookmarkSelectedPNG"];
        }
            break;
        case 0:
        default:
        {
            [self setImage:[UIImage imageNamed:@"download_unselected"] forState:UIControlStateNormal];
            [self setAccessibilityValue:@"bookmarkUnselectedPNG"];
        }
            break;
    }
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
