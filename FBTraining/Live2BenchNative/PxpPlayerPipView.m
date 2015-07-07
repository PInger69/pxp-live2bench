//
//  PxpPlayerPipView.m
//  PxpPlayer
//
//  Created by Nico Cvitak on 2015-06-26.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import "PxpPlayerPipView.h"

@implementation PxpPlayerPipView

- (void)initPipView {
    _movementEnabled = YES;
    
    self.layer.shadowColor = self.tintColor.CGColor;
    self.layer.shadowRadius = 2.0;
    self.layer.shadowOpacity = 1.0;
    self.layer.shadowOffset = CGSizeZero;
    
    [self addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pipMoveGestureRecognized:)]];
    
    self.zoomEnabled = NO;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initPipView];
    }
    return self;
}

- (instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initPipView];
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

#pragma mark - Overrides
     
- (void)tintColorDidChange {
    [super tintColorDidChange];
    
    self.layer.shadowColor = self.tintColor.CGColor;
}
     
- (void)setZoomEnabled:(BOOL)zoomEnabled {
    [super setZoomEnabled:NO];
}

- (BOOL)zoomEnabled {
    return NO;
}

#pragma mark - Gesture Recognizers

- (void)pipMoveGestureRecognized:(UIPanGestureRecognizer *)recognizer {
    static CGPoint origin;
    
    if (self.movementEnabled && recognizer.view == self && self.superview) {
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            origin = self.frame.origin;
        }
        
        CGRect bounds = self.superview.bounds;
        
        CGPoint translation = [recognizer translationInView:self.superview];
        
        CGFloat x = origin.x + translation.x, y = origin.y + translation.y;
        
        x = MAX(0.0, x);
        y = MAX(0.0, y);
            
        x = MIN(bounds.size.width - self.frame.size.width, x);
        y = MIN(bounds.size.height - self.frame.size.height, y);
        
        self.frame = CGRectMake(x, y, self.frame.size.width, self.frame.size.height);
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
