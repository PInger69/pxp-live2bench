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
    [self setBackgroundImage:[self playImage] forState:UIControlStateNormal];
//    self.layer.backgroundColor = PRIMARY_APP_COLOR.CGColor;
//    for (int i  = 0; i <self.layer.sublayers.count; ++i){
//        CALayer *layer = self.layer.sublayers[i];
//        [layer removeFromSuperlayer];
//        layer = nil;
//    }
//    
//    CAShapeLayer *playLayer = [CAShapeLayer layer];
//    //playLayer.frame = self.layer.frame;
//    
//    UIBezierPath *path = [UIBezierPath bezierPath];
//    
//    [path moveToPoint:CGPointMake(8, 7)];
//    [path addLineToPoint:CGPointMake(23, 15)];
//    [path addLineToPoint:CGPointMake(8, 23)];
//    [path addLineToPoint:CGPointMake(8, 7)];
//    [path fill];
//    
//    if (self.highlighted) {
//        playLayer.path = path.CGPath;
//        playLayer.fillColor = PRIMARY_APP_COLOR.CGColor;
//        self.layer.backgroundColor = [UIColor clearColor].CGColor;
//    }else{
//        playLayer.path = path.CGPath;
//        playLayer.fillColor = [UIColor whiteColor].CGColor;
//    }
//    
//    
//    [self.layer addSublayer:playLayer];
    
    self.buttonContext = PLAY_BUTTON;
    
}

-(UIImage *) playImage{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(30, 30), NO , [UIScreen mainScreen].scale);
    
    
    
    UIBezierPath *backgroundPath = [UIBezierPath bezierPath];
    [backgroundPath moveToPoint:CGPointMake(0, 0)];
    [backgroundPath addLineToPoint:CGPointMake(0, 30)];
    [backgroundPath addLineToPoint:CGPointMake(30, 30)];
    [backgroundPath addLineToPoint:CGPointMake(30, 0)];
    [backgroundPath addLineToPoint:CGPointMake(0, 0)];
    
    [PRIMARY_APP_COLOR setFill];
    [backgroundPath fill];
    
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(8, 7)];
    [path addLineToPoint:CGPointMake(23, 15)];
    [path addLineToPoint:CGPointMake(8, 23)];
    [path addLineToPoint:CGPointMake(8, 7)];
    [[UIColor whiteColor] setFill];
    [path fill];

    
    UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return returnImage;
}


@end

