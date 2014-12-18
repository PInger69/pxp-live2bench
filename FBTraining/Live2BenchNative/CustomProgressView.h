//
//  CustomProgressView.h
//  Live2BenchNative
//
//  Created by DEV on 2013-11-05.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomProgressView : UIView

@property (nonatomic, retain) UIView *progressView;

//initialise self frame
- (id)initWithFrame:(CGRect)frame;
//set the backgroud color for progress view
-(void)setProgressColor:(UIColor *)theProgressColor;
////set track color for progress view
//-(void)setTrackColor:(UIColor *)theTrackColor;
//update the progress view
-(void)setProgress:(float)theProgress;
@end
