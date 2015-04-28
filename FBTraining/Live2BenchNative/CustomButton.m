//
//  CustomButton.m
//  Live2BenchNative
//
//  Created by DEV on 2013-04-16.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "CustomButton.h"

@interface CustomButton()

@property (assign, nonatomic) float downloadProgress;

@end

@implementation CustomButton

UIView *border;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)setBorderColour:(UIColor*)colour
{
    [[self layer] setBorderColor:[colour CGColor]];
}

- (void)setBorderWidth:(CGFloat)width
{
    [[self layer] setBorderWidth:width];
}

- (void)setFont:(UIFont *)font
{
    _titleFont = font;
    [self.titleLabel setFont:font];
}

-(void)setHighlighted:(BOOL)highlighted{
    super.highlighted = highlighted;
    [self setNeedsDisplay];
    //[super setHighlighted:highlighted];
    //[self redraw];
    
}

//-(void)redraw{
//    if (self.buttonContext & PLAY_BUTTON){
//        [self setPlayButton];
//    }else if (self.buttonContext & DOWNLOAD_BUTTON){
//        [self setDownloadButtonWithProgress:self.downloadProgress];
//    }
//}

-(void)setPlayButton{
    
    //CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    self.layer.backgroundColor = PRIMARY_APP_COLOR.CGColor;
    for (int i  = 0; i <self.layer.sublayers.count; ++i){
        CALayer *layer = self.layer.sublayers[i];
        [layer removeFromSuperlayer];
        layer = nil;
    }
    
    CAShapeLayer *playLayer = [CAShapeLayer layer];
    //playLayer.frame = self.layer.frame;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    [path moveToPoint:CGPointMake(8, 7)];
    [path addLineToPoint:CGPointMake(23, 15)];
    [path addLineToPoint:CGPointMake(8, 23)];
    [path addLineToPoint:CGPointMake(8, 7)];
    [path fill];
    
    if (self.highlighted) {
        playLayer.path = path.CGPath;
        playLayer.fillColor = PRIMARY_APP_COLOR.CGColor;
        self.layer.backgroundColor = [UIColor clearColor].CGColor;
    }else{
        playLayer.path = path.CGPath;
        playLayer.fillColor = [UIColor whiteColor].CGColor;
    }
    
    
    [self.layer addSublayer:playLayer];
    
    self.buttonContext = PLAY_BUTTON;
    
}

//-(void)setDownloadButtonWithProgress: (float) amountCompleted{
//    
//    //CGContextRef ctx = UIGraphicsGetCurrentContext();
//    
//    self.downloadProgress = amountCompleted;
//    self.layer.backgroundColor = [UIColor clearColor].CGColor;
//    
//    for (int i  = 0; i <self.layer.sublayers.count; ++i){
//        CALayer *layer = self.layer.sublayers[i];
//        [layer removeFromSuperlayer];
//        layer = nil;
//    }
//    
//    CAShapeLayer *downloadLayer = [CAShapeLayer layer];
//    //playLayer.frame = self.layer.frame;
//    
//    UIBezierPath *path = [UIBezierPath bezierPath];
//    
//    
//    [path moveToPoint:CGPointMake(7, 1)];
//    [path addLineToPoint:CGPointMake(23, 1)];
//    [path addLineToPoint:CGPointMake(23, 11)];
//    [path addLineToPoint:CGPointMake(30, 11)];
//    [path addLineToPoint:CGPointMake(15, 25)];
//    [path addLineToPoint:CGPointMake(0, 11)];
//    [path addLineToPoint:CGPointMake(7, 11)];
//    [path addLineToPoint:CGPointMake(7, 1)];
//    
//    path.lineWidth = 2.0;
//    //[[UIColor orangeColor] setStroke];
//    
//    //[path fill];
//    [path stroke];
//    downloadLayer.strokeColor = PRIMARY_APP_COLOR.CGColor;
//    //[[UIColor orangeColor] setStroke];
//    
//    if (self.highlighted) {
//        downloadLayer.path = path.CGPath;
//        downloadLayer.fillColor = PRIMARY_APP_COLOR.CGColor;
//    }else{
//        downloadLayer.path = path.CGPath;
//        downloadLayer.fillColor = [UIColor whiteColor].CGColor;
//    }
//    
//    
//    
//    CAShapeLayer *progressLayer = [CAShapeLayer layer];
//    //playLayer.frame = self.layer.frame;
//    
//    UIBezierPath *boxPath = [UIBezierPath bezierPath];
//    
//    
//    [boxPath moveToPoint:CGPointMake(0, 28)];
//    [boxPath addLineToPoint:CGPointMake(30, 28)];
//    [boxPath addLineToPoint:CGPointMake(30, 32)];
//    [boxPath addLineToPoint:CGPointMake(0, 32)];
//    [boxPath addLineToPoint:CGPointMake(0, 28)];
//    
//    boxPath.lineWidth = 2.0;
//    
//    //[path fill];
//    [boxPath stroke];
//    progressLayer.strokeColor = PRIMARY_APP_COLOR.CGColor;
//    //[[UIColor orangeColor] setStroke];
//    
//    progressLayer.path = boxPath.CGPath;
//    progressLayer.fillColor = [UIColor whiteColor].CGColor;
//    
//    CALayer *progressBarLayer = [CALayer layer];
//    [progressBarLayer setFrame: CGRectMake(0, 28, amountCompleted * 30, 4)];
//    progressBarLayer.backgroundColor = PRIMARY_APP_COLOR.CGColor;
//    
//    [self.layer addSublayer: progressLayer];
//    [self.layer addSublayer: downloadLayer];
//    [self.layer addSublayer: progressBarLayer];
//    
//    
//    
//    self.buttonContext = DOWNLOAD_BUTTON;
//    
//    //UIView *backgroundView = [[UIView alloc]initWithFrame:self.frame];
//    
//    
//    
//}

@end

