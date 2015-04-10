//
//  VideoZoomManager.m
//  Live2BenchNative
//
//  Created by dev on 2015-03-19.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "VideoZoomManager.h"
#import "RJLVideoPlayer.h"

@interface VideoZoomManager()<UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIPanGestureRecognizer *gestureRecognizer;

// This is the orange view that appears while dragging a finger on the
// video player
@property (strong, nonatomic) UIView *zoomView;

// This is the button that is used to reset the zoom of the video player
@property (strong, nonatomic) UIButton *undoZoomButton;

@property (strong, nonatomic) NSMutableArray *arrayOfPreviousFrames;
@property (strong, nonatomic) NSMutableArray *secondArrayOfPreviousFrames;

@property (strong, nonatomic) AVPlayerLayer *videoLayer;
@property (strong, nonatomic) AVPlayerLayer *secondLayer;

@property (strong, nonatomic) NSMutableArray *arrayOfVideoLayers;
@property (strong, nonatomic) UILabel *debugLabel;
@property (strong, nonatomic) UILabel *debugLabel2;

@end

@implementation VideoZoomManager{
    CGPoint beginningPoint;
    CGRect newVideoLayerFramee;
    CGPoint currentPoint;
    CGPoint relativePartialOrigin;
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
        self.tintColor = [UIColor colorWithRed:1.0 green:0.6 blue:0.0 alpha:1.0];
        self.gestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(gestureRecognizerReceivedTouch:)];
        self.gestureRecognizer.enabled = YES;
        self.gestureRecognizer.maximumNumberOfTouches = 1;
        self.gestureRecognizer.delegate = self;
        
        self.zoomView = [[UIView alloc]init];
        self.zoomView.backgroundColor = [self.tintColor colorWithAlphaComponent:0.25];
        self.zoomView.layer.borderColor = self.tintColor.CGColor;
        self.zoomView.layer.borderWidth = 1.0;
        
        self.arrayOfPreviousFrames = [NSMutableArray array];
        self.secondArrayOfPreviousFrames = [NSMutableArray array];
        self.arrayOfVideoLayers = [NSMutableArray array];
        
        self.undoZoomButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 25, 30, 30)];
        [self.undoZoomButton addTarget:self action:@selector(undoZoomButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.undoZoomButton setImage:[self undoZoomButtonImage] forState:UIControlStateNormal];
        
        self.debugLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 650, 150)];
        self.debugLabel.textColor = [UIColor redColor];
        self.debugLabel.numberOfLines = 0;
        
        self.debugLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 650, 150)];
        self.debugLabel2.textColor = [UIColor redColor];
        self.debugLabel2.numberOfLines = 0;
        
        self.viewsToAvoid = [NSMutableArray array];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newVideoLayer:) name:NOTIF_NEW_VIDEO_LAYER object: nil];
        
    }
    return self;
}

-(void)newVideoLayer: (NSNotification *) note{
    [self.arrayOfVideoLayers addObject: note.object];
}

-(void)setEnabled:(BOOL)enabled{
    self.gestureRecognizer.enabled = enabled;
}


-(void)setVideoPlayer:(UIViewController<PxpVideoPlayerProtocol> *)videoPLayer{
    _videoPlayer = videoPLayer;
    [((RJLVideoPlayer *)_videoPlayer).playBackView addGestureRecognizer:self.gestureRecognizer];
    self.videoLayer = ((RJLVideoPlayer *)_videoPlayer).playBackView.videoLayer;
    self.secondLayer = ((RJLVideoPlayer *)_videoPlayer).playBackView.secondLayer;
    [self.videoPlayer.playBackView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context: nil];
    
    self.undoZoomButton.frame = CGRectMake(0, _videoPlayer.videoControlBar.frame.origin.y - 30, 30, 30);
    
    //[self.arrayOfPreviousFrames addObject: [NSValue valueWithCGRect: _videoPlayer.view.bounds]];
}

-(UIPanGestureRecognizer *) panGestureRecognizer{
    return self.gestureRecognizer;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    beginningPoint = [touch locationInView:self.videoPlayer.view];
    for (UIView *viewToAvoid in self.viewsToAvoid) {
        if (CGRectContainsPoint(viewToAvoid.frame, beginningPoint) && !viewToAvoid.hidden) {
            beginningPoint.x = 0;
            beginningPoint.y = 0;
            return NO;
        }
    }
    
    CGRect f = self.videoPlayer.videoControlBar.frame;
    CGRect frameToAvoid = CGRectMake(f.origin.x, f.origin.y, f.size.width, self.videoPlayer.view.frame.size.height - f.origin.y);
    if ( CGRectContainsPoint(frameToAvoid, beginningPoint)) {
        beginningPoint.x = 0;
        beginningPoint.y = 0;
        return NO;
    }
    
    if ( CGRectContainsPoint(self.undoZoomButton.frame, beginningPoint) && !self.undoZoomButton.hidden) {
        beginningPoint.x = 0;
        beginningPoint.y = 0;
        return NO;
    }
    
    if (self.videoLayer.frame.size.width > 1000000) {
        return NO;
    }
    return YES;
}

-(void)gestureRecognizerReceivedTouch: (UIPanGestureRecognizer *) gestureRecognizer{
    
    switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
            beginningPoint = [gestureRecognizer locationInView:self.videoPlayer.view];
            newVideoLayerFramee = CGRectMake(beginningPoint.x, beginningPoint.y, 0, 0);
            self.zoomView.frame = newVideoLayerFramee;
            [self.videoPlayer.view addSubview: self.zoomView];
            break;
            
        case UIGestureRecognizerStateChanged:
            currentPoint = [gestureRecognizer locationInView:self.videoPlayer.view];
            //By calculating the frame based on minimum and maximum values,
            // the zoom view will adjust to any direction the user swipes
            newVideoLayerFramee.origin.x = MIN(currentPoint.x, beginningPoint.x);
            newVideoLayerFramee.origin.y = MIN(currentPoint.y, beginningPoint.y);
            newVideoLayerFramee.size.width = MAX(currentPoint.x - beginningPoint.x, beginningPoint.x - currentPoint.x);
            newVideoLayerFramee.size.height = MAX(currentPoint.y - beginningPoint.y, beginningPoint.y - currentPoint.y);
            self.zoomView.frame = newVideoLayerFramee;
            break;
            
        case UIGestureRecognizerStateEnded:
            [self.zoomView removeFromSuperview];
            
            [self zoomThePlayer];
            [self zoomTheSecondPlayer];
            //self.zoomFrame = viewFrame;
            // The extra and condition
            if (self.arrayOfPreviousFrames.count > 0) {
                [self.videoPlayer.view addSubview: self.undoZoomButton];
            }
            
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
    //((RJLVideoPlayer *)self.videoPlayer).playBackView.videoLayer.frame = ((RJLVideoPlayer *)self.videoPlayer).playBackView.videoLayer.superlayer.bounds;
    self.videoLayer.frame = [(NSValue *)[self.arrayOfPreviousFrames lastObject] CGRectValue];
    self.secondLayer.frame = [(NSValue *)[self.secondArrayOfPreviousFrames lastObject] CGRectValue];
    
    if (self.arrayOfPreviousFrames.count <= 1) {
        self.videoLayer.frame = self.videoPlayer.view.bounds;
        self.secondLayer.frame = self.secondLayer.superlayer.bounds;
        [self.undoZoomButton removeFromSuperview];
        [self.arrayOfPreviousFrames removeLastObject];
        [self.secondArrayOfPreviousFrames removeLastObject];
    }else{
        [self.arrayOfPreviousFrames removeLastObject];
        [self.secondArrayOfPreviousFrames removeLastObject];
    }
    
    //self.gestureRecognizer.enabled = YES;
}


-(UIImage *)undoZoomButtonImage{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(30, 35), NO, [UIScreen mainScreen].scale);
    UIBezierPath *path = [[UIBezierPath alloc]init];
    
    [path moveToPoint: CGPointMake(2, 17)];
    [path addArcWithCenter:CGPointMake(15, 17) radius:13 startAngle: M_PI endAngle: -M_PI/2 clockwise: NO];
    
    [path moveToPoint: CGPointMake(15, 3)];
    [path addLineToPoint: CGPointMake(15, 7)];
    [path addLineToPoint: CGPointMake(10, 5)];
    [path addLineToPoint: CGPointMake(15, 2)];
    [path addLineToPoint: CGPointMake(15, 7)];
    


    path.lineWidth = 2.0;
    
    [[UIColor orangeColor] setStroke];
    [path stroke];
    
    UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return returnImage;
    
}

//-(void)zoomThePlayer{
//    CGRect newFrame = CGRectMake(0, 0, 0, 0);
//    CGRect partialView = self.zoomView.frame;
//    
//    newFrame.size.width = (((RJLVideoPlayer *)self.videoPlayer).playBackView.videoLayer.frame.size.width / partialView.size.width) * ((RJLVideoPlayer *)self.videoPlayer).playBackView.frame.size.width;
//    newFrame.size.height = (((RJLVideoPlayer *)self.videoPlayer).playBackView.frame.size.width / partialView.size.width) * ((RJLVideoPlayer *)self.videoPlayer).playBackView.frame.size.height;
//    
//    CGFloat xPositionMultiplier = partialView.origin.x / ((RJLVideoPlayer *)self.videoPlayer).playBackView.frame.size.width;
//    CGFloat yPositionMultiplier = partialView.origin.y / ((RJLVideoPlayer *)self.videoPlayer).playBackView.frame.size.width;
//    
//    newFrame.origin.x = - xPositionMultiplier * newFrame.size.width;
//    newFrame.origin.y = - yPositionMultiplier * newFrame.size.height;
//    
//    //All these conditions ensure that the videoLayer
//    // does not end up leaving the view of the videoPLayer's frame
//    
//    // If the x value is greater than 0,
//    // then it is too far too the right
//    if (newFrame.origin.x > 0) {
//        newFrame.origin.x = 0;
//    }
//    
//    // If the y value is greater than 0,
//    // then it is too far too the down
//    if (newFrame.origin.y > 0) {
//        newFrame.origin.y = 0;
//    }
//
//    CGRect superLayerFrame = ((RJLVideoPlayer *)self.videoPlayer).playBackView.videoLayer.superlayer.frame;
//    
//    // This is the case where it is too far to the left
//    if ((newFrame.origin.x + newFrame.size.width) < superLayerFrame.size.width) {
//        newFrame.origin.x += superLayerFrame.size.width - (newFrame.origin.x + newFrame.size.width);
//    }
//    
//    // This is the case where it is too far up
//    if ((newFrame.origin.y + newFrame.size.height) < superLayerFrame.size.height) {
//        newFrame.origin.y += superLayerFrame.size.height - (newFrame.origin.y + newFrame.size.height);
//    }
//    
//    ((RJLVideoPlayer *)self.videoPlayer).playBackView.videoLayer.frame = newFrame;
//}

-(void)zoomThePlayer{
    
    //CGRect originalVideoFrame = [(NSValue *)[self.arrayOfPreviousFrames firstObject] CGRectValue];
    CGRect originalVideoFrame = self.videoPlayer.view.frame;
    float  originalVideoRatio = originalVideoFrame.size.width / originalVideoFrame.size.height;
    
    //CGRect newFrame = CGRectMake(0, 0, 0, 0);
    CGRect partialView = self.zoomView.frame;
    //float partialViewRatio = partialView.size.width / partialView.size.height;
    
    //This is to ensure that the width or height does not become infinite
    if (partialView.size.height == 0 || partialView.size.width == 0) {
        return;
    }//else if (partialView.size.height > partialView.size.width){
//        partialView.size.height = partialView.size.width;
//    }
    
    //if (partialViewRatio < originalVideoRatio) {
        partialView.size.height = partialView.size.width / originalVideoRatio;
   // }
    
    // This code is added at the beginning to ensure that undoing a zoom works just as well
    // If it has been zoomed only once as well
    [self.arrayOfPreviousFrames addObject: [NSValue valueWithCGRect: self.videoLayer.frame]];
    
    CGPoint relativeOrigin = CGPointMake(0, 0);
    
    relativeOrigin.x = (partialView.origin.x + (-self.videoLayer.frame.origin.x)) / self.videoLayer.frame.size.width;
    relativeOrigin.y = (partialView.origin.y + (-self.videoLayer.frame.origin.y) )/ self.videoLayer.frame.size.height;
    relativePartialOrigin = relativeOrigin;
    
    CGSize newVideoLayerSize = CGSizeMake(0, 0);
    
    float relativeWidth = self.videoPlayer.view.frame.size.width / partialView.size.width ;
    newVideoLayerSize.width = relativeWidth * self.videoLayer.frame.size.width;
    
    float relativeHeight = self.videoPlayer.view.frame.size.height / partialView.size.height ;
    newVideoLayerSize.height = relativeHeight * self.videoLayer.frame.size.height;
    
    CGPoint actualOrigin = CGPointMake(-(relativeOrigin.x * newVideoLayerSize.width), -(relativeOrigin.y * newVideoLayerSize.height));
    
    CGRect newVideoLayerFrame = CGRectMake(actualOrigin.x, actualOrigin.y, newVideoLayerSize.width, newVideoLayerSize.height);
    
    //[self.arrayOfPreviousFrames addObject: [NSValue valueWithCGRect:newVideoLayerFrame]];

    // All these conditions ensure that the videoLayer
    // does not end up leaving the view of the videoPLayer's frame
    
    // If the x value is greater than 0,
    // then it is too far too the right
    if (newVideoLayerFrame.origin.x > 0) {
        newVideoLayerFrame.origin.x = 0;
    }
    
    // If the y value is greater than 0,
    // then it is too far too the down
    if (newVideoLayerFrame.origin.y > 0) {
        newVideoLayerFrame.origin.y = 0;
    }
    
    CGRect superLayerFrame = self.videoLayer.superlayer.frame;
    
    // This is the case where it is too far to the left
    if ((newVideoLayerFrame.origin.x + newVideoLayerFrame.size.width) < superLayerFrame.size.width) {
        newVideoLayerFrame.origin.x += superLayerFrame.size.width - (newVideoLayerFrame.origin.x + newVideoLayerFrame.size.width);
    }
    
    // This is the case where it is too far up
    if ((newVideoLayerFrame.origin.y + newVideoLayerFrame.size.height) < superLayerFrame.size.height) {
        newVideoLayerFrame.origin.y += superLayerFrame.size.height - (newVideoLayerFrame.origin.y + newVideoLayerFrame.size.height);
    }

    self.videoLayer.frame = newVideoLayerFrame;

    NSString *debugString = [NSString stringWithFormat: @"VideoLayer: newVideoLayerFrame - %@,   relativeOrigin - %@, partialView - %@", NSStringFromCGRect(newVideoLayerFrame), NSStringFromCGPoint(relativeOrigin), NSStringFromCGRect(partialView)];
    [self.debugLabel setText: debugString];
    
    self.debugLabel.hidden = YES;
    if (DEBUG_MODE){
        [self.videoPlayer.view addSubview: self.debugLabel];
        self.debugLabel.hidden = NO;
    }
    //[NSThread sleepForTimeInterval:2];
}

-(void)zoomTheSecondPlayer{
    //CGRect originalVideoFrame = [(NSValue *)[self.arrayOfPreviousFrames firstObject] CGRectValue];
    CGRect originalVideoFrame = self.videoPlayer.view.frame;
    float  originalVideoRatio = originalVideoFrame.size.width / originalVideoFrame.size.height;
    
    //CGRect newFrame = CGRectMake(0, 0, 0, 0);
    CGRect partialView = self.zoomView.frame;
    //float partialViewRatio = partialView.size.width / partialView.size.height;
    
    //This is to ensure that the width or height does not become infinite
    if (partialView.size.height == 0 || partialView.size.width == 0) {
        return;
    }//else if (partialView.size.height > partialView.size.width){
    //        partialView.size.height = partialView.size.width;
    //    }
    
   // if (partialViewRatio < originalVideoRatio) {
    //    partialView.size.height = partialView.size.width / originalVideoRatio;
    //}else if (partialViewRatio > originalVideoRatio){
        partialView.size.height = partialView.size.width / originalVideoRatio;
    //}
        
    //}
    
    // This code is added at the beginning to ensure that undoing a zoom works just as well
    // If it has been zoomed only once as well
    [self.secondArrayOfPreviousFrames addObject: [NSValue valueWithCGRect: self.secondLayer.frame]];
    
    CGPoint relativeOrigin = CGPointMake(0, 0);
    
    relativeOrigin.x = ( (partialView.origin.x/self.videoPlayer.view.frame.size.width) * self.secondLayer.superlayer.frame.size.width + (-self.secondLayer.frame.origin.x)) / self.secondLayer.frame.size.width;
    relativeOrigin.y = ( (partialView.origin.y/self.videoPlayer.view.frame.size.height) * self.secondLayer.superlayer.frame.size.height + (-self.secondLayer.frame.origin.y)) / self.secondLayer.frame.size.height;
    
    relativeOrigin = relativePartialOrigin;
    
    CGSize newVideoLayerSize = CGSizeMake(0, 0);
    
    float relativeWidth = self.videoPlayer.view.frame.size.width / partialView.size.width ;
    newVideoLayerSize.width = relativeWidth * self.secondLayer.frame.size.width;
    
    float relativeHeight = self.videoPlayer.view.frame.size.height / partialView.size.height ;
    newVideoLayerSize.height = relativeHeight * self.secondLayer.frame.size.height;
    
    CGPoint actualOrigin = CGPointMake(-(relativeOrigin.x * newVideoLayerSize.width), -(relativeOrigin.y * newVideoLayerSize.height));
    
    CGRect newVideoLayerFrame = CGRectMake(actualOrigin.x, actualOrigin.y, newVideoLayerSize.width, newVideoLayerSize.height);
    
    //[self.arrayOfPreviousFrames addObject: [NSValue valueWithCGRect:newVideoLayerFrame]];
    
    // All these conditions ensure that the videoLayer
    // does not end up leaving the view of the videoPLayer's frame
    
    // If the x value is greater than 0,
    // then it is too far too the right
    if (newVideoLayerFrame.origin.x > 0) {
        newVideoLayerFrame.origin.x = 0;
    }
    
    // If the y value is greater than 0,
    // then it is too far too the down
    if (newVideoLayerFrame.origin.y > 0) {
        newVideoLayerFrame.origin.y = 0;
    }
    
    CGRect superLayerFrame = self.secondLayer.superlayer.frame;
    
    CGRect tempNewVideoFrame = newVideoLayerFrame;
    if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0) {
        // This is the case where it is too far to the left
        if ((newVideoLayerFrame.origin.x + newVideoLayerFrame.size.width) < superLayerFrame.size.width) {
            newVideoLayerFrame.origin.x += superLayerFrame.size.width - (newVideoLayerFrame.origin.x + newVideoLayerFrame.size.width);
        }
        

        // This is the case where it is too far up
        if ((newVideoLayerFrame.origin.y + newVideoLayerFrame.size.height) < superLayerFrame.size.height) {
            
            newVideoLayerFrame.origin.y += superLayerFrame.size.height - (newVideoLayerFrame.origin.y + newVideoLayerFrame.size.height);
        }

    }else{
        // This is the case where it is too far to the left
        if ((newVideoLayerFrame.origin.x + newVideoLayerFrame.size.width) < superLayerFrame.size.height) {
            newVideoLayerFrame.origin.x += superLayerFrame.size.height - (newVideoLayerFrame.origin.x + newVideoLayerFrame.size.width);
        }
        
        //CGRect tempNewVideoFrame = newVideoLayerFrame;
        // This is the case where it is too far up
        if ((newVideoLayerFrame.origin.y + newVideoLayerFrame.size.height) < superLayerFrame.size.width) {
            
            newVideoLayerFrame.origin.y += superLayerFrame.size.width - (newVideoLayerFrame.origin.y + newVideoLayerFrame.size.height);
        }

    }
    
    if (self.secondLayer.superlayer == self.videoLayer.superlayer) {
        self.secondLayer.frame = self.videoLayer.frame;
    }else{
        self.secondLayer.frame = newVideoLayerFrame;
    }
    
    self.debugLabel2.hidden = YES;
    if ( DEBUG_MODE) {
        self.debugLabel2.hidden = NO;
        [self.videoPlayer.view addSubview: self.debugLabel2];
    }

    
    NSString *debugString = [NSString stringWithFormat: @"SecondLayer: newVideoLayerFrame - %@,   relativeOrigin - %@, partialView - %@, superLayer - %@, tempFrame - %@", NSStringFromCGRect(newVideoLayerFrame), NSStringFromCGPoint(relativeOrigin), NSStringFromCGRect(partialView),  NSStringFromCGRect(superLayerFrame), NSStringFromCGRect(tempNewVideoFrame)];
    [self.debugLabel2 setText: debugString];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    CGRect anotherFrame = [((NSValue *)[change objectForKey:@"new"]) CGRectValue];
    if (anotherFrame.size.width == 1024) {
        
//        CGRect zoomViewFrame = self.zoomView.frame;
//        zoomViewFrame.size.width *=
//        self.zoomView.frame = zoomViewFrame;
//        [self zoomThePlayer];

        self.undoZoomButton.frame = CGRectMake(5, 610, 30, 30);
        self.undoZoomButton.enabled = YES;
        
    }else{
         self.undoZoomButton.frame = CGRectMake(5, anotherFrame.size.height - 72, 30, 30);
    }
    
}

-(void)setEnabled:(BOOL)enabled{
    self.gestureRecognizer.enabled = enabled;
}
@end
