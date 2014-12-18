//
//  LiveIndicatorLight.m
//  Live2BenchNative
//
//  Created by dev on 2014-12-05.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "LiveIndicatorLight.h"

@implementation LiveIndicatorLight
{

    UIBezierPath    * myFirstShape;
    CAShapeLayer    * shapeLayer;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        [self setContentMode:UIViewContentModeScaleAspectFit];
        self.opaque             = NO;
        myFirstShape            = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(5, 5, 20, 20)];
        shapeLayer              = [[CAShapeLayer alloc] initWithLayer:self.layer];
        shapeLayer.lineWidth    = 1.0;
        shapeLayer.fillColor    = [UIColor greenColor].CGColor;
        shapeLayer.path         = myFirstShape.CGPath;
        [self.layer addSublayer:shapeLayer];
    }
    return self;
}


@end
