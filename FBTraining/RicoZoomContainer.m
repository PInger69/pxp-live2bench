//
//  RicoZoomContainer.m
//  Live2BenchNative
//
//  Created by dev on 2015-12-03.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "RicoZoomContainer.h"
#define MAX_ZOOM_SCALE 16.0

@interface RicoZoomContainer () <UIScrollViewDelegate>
@property (strong, nonatomic, nonnull) UILabel *zoomLabel;


@end



@implementation RicoZoomContainer


- (instancetype)init
{
    self = [super init];
    if (self) {
        _zoomEnabled = YES;
        
        self.minimumZoomScale = 1.0;
        self.maximumZoomScale = MAX_ZOOM_SCALE;
        self.bounces = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.bouncesZoom = NO;
        self.delegate = self;
    }
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _zoomEnabled = YES;
        
        self.minimumZoomScale = 1.0;
        self.maximumZoomScale = MAX_ZOOM_SCALE;
        self.bounces = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.bouncesZoom = NO;
        self.delegate = self;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
//    if (!self.zooming) {
//        self.frame = self.bounds;
//        
//        self.zoomScale = 1.0;
//        self.contentSize = self.bounds.size;
//      
//    }

    self.zoomLabel.frame = CGRectMake(0, 0, self.bounds.size.width, 22);

}



- (void)setShowsZoomLevel:(BOOL)showsZoomLevel {
    [self willChangeValueForKey:@"showsZoomLevel"];
    self.zoomLabel.hidden = !showsZoomLevel;
    [self didChangeValueForKey:@"showsZoomLevel"];
}

- (BOOL)showsZoomLevel {
    return !self.zoomLabel.hidden;
}

- (void)setZoomEnabled:(BOOL)zoomEnabled {
    [self willChangeValueForKey:@"zoomEnabled"];
    
//    if (!self.lockFullView) {
        if (!zoomEnabled) {
            self.zoomScale = 1.0;
            self.contentSize = self.bounds.size;
            
//            self.avPlayerView.frame = self.scrollView.bounds;
        }
        
        self.maximumZoomScale = zoomEnabled ? MAX_ZOOM_SCALE : 1.0;
//    }
    
    _zoomEnabled = zoomEnabled;
    
    [self didChangeValueForKey:@"zoomEnabled"];
}





-(void)addToContainer:(UIView*)view
{
    if (self.view) {
        [self.view removeFromSuperview];
    }
    self.view = view;
    [self addSubview:self.view];
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (self.view) {
        [self.view setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    }
    
    self.contentSize =frame.size;
    
}


#pragma mark - UIScrollViewDelegate

- (nullable UIView *)viewForZoomingInScrollView:(nonnull UIScrollView *)scrollView {
    return self.view;
}

- (void)scrollViewDidZoom:(nonnull UIScrollView *)scrollView {
    [self willChangeValueForKey:@"zoomLevel"];
    _zoomLevel = self.zoomScale;
    [self didChangeValueForKey:@"zoomLevel"];
    self.zoomLabel.text = _zoomLevel > 1.0 ? [NSString stringWithFormat:@"%.1fx", _zoomLevel] : nil;
    
//    [self.delegate playerView:self changedFullViewStatus:self.fullView];
}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
