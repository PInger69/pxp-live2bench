//
//  ButtonMultiScreen.m
//  Live2BenchNative
//
//  Created by dev on 2016-02-19.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "ButtonMultiScreen.h"


@interface ButtonMultiScreen ()
@property (nonatomic,strong) UIColor * buttonBackgroundColor;
@end


@implementation ButtonMultiScreen


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [super setBackgroundColor:[UIColor clearColor]];
//        scrMulti.layer.cornerRadius = 3;
        
//        CGContextRef buttonContext = UIGraphicsG
        
        
//        UIBezierPath * cell = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 10, 10) cornerRadius:2];
        
//        scrMulti.layer
        
        _buttonBackgroundColor = PRIMARY_APP_COLOR;
//        [self drawGraphic];
        [self setNeedsDisplay];
    }
    return self;
}





- (void)drawRect:(CGRect)rect
{
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGFloat corner      = 2;
    CGFloat gusit       = 1;
    CGFloat cellWidth   = self.frame.size.width*.5-gusit;
    CGFloat cellHeight  = self.frame.size.height*.5-gusit;

    UIBezierPath *path1 =     [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, cellWidth, cellHeight) cornerRadius:corner];
    UIBezierPath *path2 =     [UIBezierPath bezierPathWithRoundedRect:CGRectMake(self.frame.size.width-cellWidth, 0, cellWidth, cellHeight) cornerRadius:corner];
    UIBezierPath *path3 =     [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, self.frame.size.height-cellHeight, cellWidth, cellHeight) cornerRadius:corner];
    UIBezierPath *path4 =     [UIBezierPath bezierPathWithRoundedRect:CGRectMake(self.frame.size.width-cellWidth, self.frame.size.height-cellHeight, cellWidth, cellHeight) cornerRadius:corner];
    [_buttonBackgroundColor setFill];
    [path1 fill];
//    [_buttonBackgroundColor setFill];
    [path2 fill];
//    [_buttonBackgroundColor setFill];
    [path3 fill];
//    [_buttonBackgroundColor setFill];
    [path4 fill];
    CGContextSaveGState(currentContext);
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
            [self setNeedsDisplay];
}


-(void)setBackgroundColor:(UIColor *)backgroundColor
{
    _buttonBackgroundColor = backgroundColor;
     [self setNeedsDisplay];
}


-(UIColor*)backgroundColor
{
    return _buttonBackgroundColor;
}


@end
