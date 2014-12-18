//
//  SortArrow.m
//  QuickTest
//
//  Created by dev on 8/18/2014.
//  Copyright (c) 2014 dev. All rights reserved.
//

#import "SortArrow.h"

@implementation SortArrow
{
    UIBezierPath * myFirstShape;


}

@synthesize nextState;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
//        self.layer.borderWidth = 1;
        myFirstShape = [[UIBezierPath alloc]init];
        
        
        [myFirstShape moveToPoint: CGPointMake(0,frame.size.height)];
        [myFirstShape addLineToPoint: CGPointMake(frame.size.width/2,0)];
        [myFirstShape addLineToPoint: CGPointMake(frame.size.width,frame.size.height)];
        [myFirstShape closePath];
        
        CAShapeLayer* shapeLayer;
        shapeLayer = [[CAShapeLayer alloc] initWithLayer:self.layer];
        shapeLayer.lineWidth = 1.0;
        shapeLayer.fillColor = [UIColor whiteColor].CGColor;
        
        [self.layer addSublayer:shapeLayer];
        
        shapeLayer.path = myFirstShape.CGPath;
        state           = None;
        nextState       = Ascend;

    }
    return self;
}


-(State)state
{
    return state;
}

-(void)setState:(State)newState
{
    state = newState;
    [self setHidden:FALSE];
    
    if          (state&Ascend){
        self.transform = CGAffineTransformMakeRotation(0);
        nextState = Descend;
    } else if   (state&Descend){
        self.transform = CGAffineTransformMakeRotation(M_PI);
        nextState = Ascend;
    } else {
        nextState = Ascend; // This is the state you want when you tap
        [self setHidden:TRUE];
    }

}

@end
