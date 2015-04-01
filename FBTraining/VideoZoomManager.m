//
//  VideoZoomManager.m
//  Live2BenchNative
//
//  Created by dev on 2015-03-19.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "VideoZoomManager.h"
#import "RJLVideoPlayer.h"

@interface VideoZoomManager()

@property (strong, nonatomic) UIPanGestureRecognizer *gestureRecognizer;

// This is the orange view that appears while dragging a finger on the
// video player
@property (strong, nonatomic) UIView *zoomView;

// This is the button that is used to reset the zoom of the video player
@property (strong, nonatomic) UIButton *undoZoomButton;

@end

@implementation VideoZoomManager{
    CGPoint beginningPoint;
    CGRect viewFrame;
    CGPoint currentPoint;
}


-(instancetype)initForVideoPlayer: (UIViewController <PxpVideoPlayerProtocol> *) videoPlayer{
    // By calling the self init method, the other properties will already have been
    // initialized
    self = [self init];
    if (self) {
        self.videoPlayer = videoPlayer;
    }
    return self;
}


-(instancetype)init{
    self = [super init];
    if (self) {
        self.gestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(gestureRecognizerReceivedTouch:)];
        self.gestureRecognizer.maximumNumberOfTouches = 1;
        
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

-(void)setVideoPlayer:(UIViewController<PxpVideoPlayerProtocol> *)videoPLayer{
    _videoPlayer = videoPLayer;
    [((RJLVideoPlayer *)_videoPlayer).playBackView addGestureRecognizer:self.gestureRecognizer];
    
    [self.videoPlayer.playBackView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context: nil];
}

-(UIPanGestureRecognizer *) panGestureRecognizer{
    return self.gestureRecognizer;
}

-(void)gestureRecognizerReceivedTouch: (UIPanGestureRecognizer *) gestureRecognizer{
    
    switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
            beginningPoint = [gestureRecognizer locationInView:self.videoPlayer.view];
            viewFrame = CGRectMake(beginningPoint.x, beginningPoint.y, 0, 0);
            self.zoomView.frame = viewFrame;
            [self.videoPlayer.view addSubview: self.zoomView];
            break;
            
        case UIGestureRecognizerStateChanged:
            currentPoint = [gestureRecognizer locationInView:self.videoPlayer.view];
            //By calculating the frame based on minimum and maximum values,
            // the zoom view will adjust to any direction the user swipes
            viewFrame.origin.x = MIN(currentPoint.x, beginningPoint.x);
            viewFrame.origin.y = MIN(currentPoint.y, beginningPoint.y);
            viewFrame.size.width = MAX(currentPoint.x - beginningPoint.x, beginningPoint.x - currentPoint.x);
            viewFrame.size.height = MAX(currentPoint.y - beginningPoint.y, beginningPoint.y - currentPoint.y);
            self.zoomView.frame = viewFrame;
            break;
            
        case UIGestureRecognizerStateEnded:
            [self.zoomView removeFromSuperview];
            
            [self zoomThePlayer];
            //self.zoomFrame = viewFrame;
            // The extra and condition
            
            [self.videoPlayer.view addSubview: self.undoZoomButton];
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
    ((RJLVideoPlayer *)self.videoPlayer).playBackView.videoLayer.frame = ((RJLVideoPlayer *)self.videoPlayer).playBackView.videoLayer.superlayer.bounds;
    [self.undoZoomButton removeFromSuperview];
    self.gestureRecognizer.enabled = YES;
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

-(void)zoomThePlayer{
    CGRect newFrame = CGRectMake(0, 0, 0, 0);
    CGRect partialView = self.zoomView.frame;
    
    newFrame.size.width = (((RJLVideoPlayer *)self.videoPlayer).playBackView.frame.size.width / partialView.size.width) * ((RJLVideoPlayer *)self.videoPlayer).playBackView.frame.size.width;
    newFrame.size.height = (((RJLVideoPlayer *)self.videoPlayer).playBackView.frame.size.width / partialView.size.width) * ((RJLVideoPlayer *)self.videoPlayer).playBackView.frame.size.height;
    
    CGFloat xPositionMultiplier = partialView.origin.x / ((RJLVideoPlayer *)self.videoPlayer).playBackView.frame.size.width;
    CGFloat yPositionMultiplier = partialView.origin.y / ((RJLVideoPlayer *)self.videoPlayer).playBackView.frame.size.width;
    
    newFrame.origin.x = - xPositionMultiplier * newFrame.size.width;
    newFrame.origin.y = - yPositionMultiplier * newFrame.size.height;
    
    //All these conditions ensure that the videoLayer
    // does not end up leaving the view of the videoPLayer's frame
    
    // If the x value is greater than 0,
    // then it is too far too the right
    if (newFrame.origin.x > 0) {
        newFrame.origin.x = 0;
    }
    
    // If the y value is greater than 0,
    // then it is too far too the down
    if (newFrame.origin.y > 0) {
        newFrame.origin.y = 0;
    }

    CGRect superLayerFrame = ((RJLVideoPlayer *)self.videoPlayer).playBackView.videoLayer.superlayer.frame;
    
    // This is the case where it is too far to the left
    if ((newFrame.origin.x + newFrame.size.width) < superLayerFrame.size.width) {
        newFrame.origin.x += superLayerFrame.size.width - (newFrame.origin.x + newFrame.size.width);
    }
    
    // This is the case where it is too far up
    if ((newFrame.origin.y + newFrame.size.height) < superLayerFrame.size.height) {
        newFrame.origin.y += superLayerFrame.size.height - (newFrame.origin.y + newFrame.size.height);
    }
    
    ((RJLVideoPlayer *)self.videoPlayer).playBackView.videoLayer.frame = newFrame;
    self.gestureRecognizer.enabled = NO;
}



-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    CGRect anotherFrame = [((NSValue *)[change objectForKey:@"new"]) CGRectValue];
    if (anotherFrame.size.width == 1024) {
        CGRect newUndoZoomFrame = self.undoZoomButton.frame;
        newUndoZoomFrame.origin.x += 10;
        newUndoZoomFrame.origin.y += 30;
        self.undoZoomButton.frame = newUndoZoomFrame;
        [self undoZoomButtonPressed: self.undoZoomButton];
    }else{
        self.undoZoomButton.frame = CGRectMake(0, 0, 30, 30);
        [self undoZoomButtonPressed: self.undoZoomButton];
    }
    
}
@end
