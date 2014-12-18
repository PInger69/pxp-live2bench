//
//  CustomProgressView.m
//  Live2BenchNative
//
//  Created by DEV on 2013-11-05.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "CustomProgressView.h"

@implementation CustomProgressView

@synthesize progressView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //self.layer.cornerRadius = 5;
        // clipsToBounds is important to stop the progressView from covering the original view and its round corners
        self.clipsToBounds = YES;
        
        self.progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, frame.size.height)];
        [self addSubview:self.progressView];
        [self setBackgroundColor:[UIColor whiteColor]];
        self.layer.borderColor = [UIColor orangeColor].CGColor;
        self.layer.borderWidth = 1;
    }
    
    return self;
}

-(void)setProgressColor:(UIColor *)theProgressColor {
    self.progressView.backgroundColor = theProgressColor;
}

-(void)setTrackColor:(UIColor *)theTrackColor {
    self.backgroundColor = theTrackColor;
}

-(void)setProgress:(float)theProgress {
    CGRect theFrame = self.progressView.frame;
    theFrame.size.width = self.frame.size.width * theProgress;
    self.progressView.frame = theFrame;
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
