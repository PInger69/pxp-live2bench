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
        self.hidden = YES;
        
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setContentMode:UIViewContentModeScaleAspectFit];
        self.opaque             = NO;
        myFirstShape            = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(5, 5, 20, 20)];
        shapeLayer              = [[CAShapeLayer alloc] initWithLayer:self.layer];
        shapeLayer.lineWidth    = 1.0;
        shapeLayer.fillColor    = [UIColor greenColor].CGColor;
        shapeLayer.path         = myFirstShape.CGPath;
        [self.layer addSublayer:shapeLayer];
        self.hidden = YES;
    }
    return self;
}

-(void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    if (hidden) {
        [self stopAnimating];
    } else if (!hidden){
        self.alpha = 1.0f;
        [UIImageView animateWithDuration:0.5f
                                   delay:0.0
                                 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse
                              animations:^{
                                  self.alpha = 0.0f;
                              }
                              completion:^(BOOL finished){
                              }];
        
    }
    
}




@end
