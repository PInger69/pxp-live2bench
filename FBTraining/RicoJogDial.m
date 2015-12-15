//
//  RicoJogDial.m
//  Live2BenchNative
//
//  Created by dev on 2015-12-04.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "RicoJogDial.h"

@interface RicoJogDial ()

@property (nonatomic,strong) UIView * jogView;
@property (nonatomic,assign) CGFloat num;
@property (nonatomic,assign) CGFloat holdFirstTouchValue;
@property (nonatomic,assign) CGFloat lastTouchValue;


@property (nonatomic,strong) NSTimer *timer;

@property (nonatomic,assign) BOOL touched;
@end


@implementation RicoJogDial

@synthesize num = _num;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];

        _jogView = [UIView new];
        [self enable];
        self.sensitivity = 0.90;

    }
    return self;
}


-(void)enable
{
    UIPanGestureRecognizer * panGesture =  [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanFrom:)];
//    [self addGestureRecognizer:panGesture];
    
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
    longPress.minimumPressDuration = .1;
//    [self addGestureRecognizer:longPress];
}

- (void)longPress:(UILongPressGestureRecognizer*)recognizer {
    
//    NSLog(@"%s",__FUNCTION__);
    [self.timer invalidate];
    self.timer = nil;
    
    CGFloat stepDirection;
    

    
    if ((_lastTouchValue - [recognizer locationInView:self].x) > 0) {
        stepDirection = -1;
        
    } else if ((_lastTouchValue - [recognizer locationInView:self].x) < 0) {
        stepDirection = 1;
        
    }
    
    _lastTouchValue = [recognizer locationInView:self].x;
    
    if (self.delegate && stepDirection) {
        [self.delegate onMovement:self value:stepDirection];
    }

    
}



-(void)setNum:(CGFloat)num
{
    _num = num;
}

-(CGFloat)num
{
    return _num;
}


- (void)handlePanFrom:(UIPanGestureRecognizer*)recognizer {
    
//    if(self.touched) return;
    
    
    //CGPoint translation = [recognizer translationInView:recognizer.view];
    CGPoint velocity = [recognizer velocityInView:recognizer.view];
    
    CGFloat slideFactor = velocity.x;
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
//        <track the movement>
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
//        <animate to final position>
        self.num += slideFactor;
        CGFloat updateInterval = 0.2;
        
        
       if (!self.timer) self.timer = [NSTimer scheduledTimerWithTimeInterval:updateInterval target:self selector:@selector(updateMethod:) userInfo:nil repeats:YES];
    }
}


- (void) updateMethod:(NSTimer*) timer
{
    self.num = self.num *  self.sensitivity;
    if (self.num <= 10 && self.num >= -10)
    {
        [timer invalidate];
        self.timer = nil;
    }

    if (self.delegate) {
        [self.delegate onMovement:self value:self.num];
    }
}



-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.touched = YES;
    _lastTouchValue = [((UITouch *)[touches anyObject]) locationInView:self].x;
}


-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    NSLog(@"%s",__FUNCTION__);
    
    CGFloat stepDirection;
    
    if ((_lastTouchValue - [((UITouch *)[touches anyObject]) locationInView:self].x) > 0) {
        stepDirection = -1;
    } else {
        stepDirection = 1;
    }
    
    _lastTouchValue = [((UITouch *)[touches anyObject]) locationInView:self].x;
    
    if (self.delegate) {
        [self.delegate onMovement:self value:stepDirection];
    }
}



-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.touched = NO;
    NSLog(@"%s",__FUNCTION__);
    _lastTouchValue = 0;

}
//
//
//-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    NSLog(@"%s",__FUNCTION__);
//
//
//}

@end
