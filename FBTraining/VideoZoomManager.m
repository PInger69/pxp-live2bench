//
//  VideoZoomManager.m
//  Live2BenchNative
//
//  Created by dev on 2015-03-19.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "VideoZoomManager.h"

@interface VideoZoomManager()
@property (strong, nonatomic) UIPanGestureRecognizer *gestureRecognizer;
@property (strong, nonatomic) UIView *zoomView;
@property (strong, nonatomic) UIButton *undoZoomButton;

@end

@implementation VideoZoomManager{
    CGPoint beginningPoint;
    CGRect viewFrame;
    CGPoint currentPoint;
    
    id zoomTarget;
    SEL zoomAction;
}


-(instancetype)initForVideoView: (UIView *) videoView{
    self = [self init];
    if (self) {
        self.videoView = videoView;
    }
    return self;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        self.gestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(gestureRecognizerReceivedTouch:)];
        
        self.zoomView = [[UIView alloc]init];
        self.zoomView.backgroundColor = [UIColor colorWithRed:1.0 green:0.6 blue:0.0 alpha:0.25];
        self.zoomView.layer.borderColor = [UIColor orangeColor].CGColor;
        self.zoomView.layer.borderWidth = 1.0;
        
        self.undoZoomButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [self.undoZoomButton addTarget:self action:@selector(undoZoomButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.undoZoomButton setImage:[self undoZoomButtonImage] forState:UIControlStateNormal];
        
    }
    return self;
}

-(void)setVideoView:(UIView *)videoView{
    _videoView = videoView;
    [_videoView addGestureRecognizer:self.gestureRecognizer];
}

-(void)gestureRecognizerReceivedTouch: (UIPanGestureRecognizer *) gestureRecognizer{
    
    switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
            beginningPoint = [gestureRecognizer locationInView:self.videoView];
            viewFrame = CGRectMake(beginningPoint.x, beginningPoint.y, 0, 0);
            self.zoomView.frame = viewFrame;
            [self.videoView addSubview: self.zoomView];
            break;
            
        case UIGestureRecognizerStateChanged:
            currentPoint = [gestureRecognizer locationInView:self.videoView];
            viewFrame.origin.x = MIN(currentPoint.x, beginningPoint.x);
            viewFrame.origin.y = MIN(currentPoint.y, beginningPoint.y);
            viewFrame.size.width = MAX(currentPoint.x - beginningPoint.x, beginningPoint.x - currentPoint.x);
            viewFrame.size.height = MAX(currentPoint.y - beginningPoint.y, beginningPoint.y - currentPoint.y);
            self.zoomView.frame = viewFrame;
            break;
            
        case UIGestureRecognizerStateEnded:
            [self.zoomView removeFromSuperview];
            self.zoomFrame = viewFrame;
            if (zoomTarget) {
                [zoomTarget performSelector:zoomAction withObject:self];
            }
            [self.videoView addSubview: self.undoZoomButton];
            break;
            
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            [self.zoomView removeFromSuperview];
            break;
            
        case UIGestureRecognizerStatePossible:
            break;
    }
}

-(void)undoZoomButtonPressed: (UIButton *)undoZoomButton{
    self.zoomFrame = self.videoView.bounds;
    if (zoomTarget) {
        [zoomTarget performSelector:zoomAction withObject:self];
    }
    [self.undoZoomButton removeFromSuperview];
}

-(void)addTarget: (id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents{
    zoomTarget = target;
    zoomAction = action;
}

-(UIImage *)undoZoomButtonImage{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(30, 30), NO, [UIScreen mainScreen].scale);
    UIBezierPath *path = [[UIBezierPath alloc]init];
    
    [path moveToPoint: CGPointMake(2, 15)];
    [path addArcWithCenter:CGPointMake(15, 15) radius:13 startAngle: M_PI endAngle: -M_PI/2 clockwise: NO];
    
    [path moveToPoint: CGPointMake(15, 0)];
    [path addLineToPoint: CGPointMake(15, 5)];
    [path addLineToPoint: CGPointMake(10, 3)];
    [path addLineToPoint: CGPointMake(15, 0)];
    


    path.lineWidth = 2.0;
    
    [[UIColor orangeColor] setStroke];
    [path stroke];
    
    UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return returnImage;
    
}
@end
