//
//  PxpPlayPauseButton.m
//  PxpPlayer
//
//  Created by Nico Cvitak on 2015-06-10.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import "PxpPlayPauseButton.h"

@implementation PxpPlayPauseButton

- (void)initCommon {
    _paused = YES;
    
    // add target to toggle between states
    [self addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initCommon];
    }
    return self;
}

- (instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initCommon];
        
        self.layer.borderWidth = 1;
        self.layer.borderColor = [[UIColor redColor]CGColor];
    }
    return self;
}

# pragma mark - Getters / Getters

- (void)setPaused:(BOOL)paused {
    
    if (paused != _paused) {
        _paused = paused;
        
        // update layer
        [self updateLayer];
    }
}

# pragma mark - Overrides

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    // update layer
    [self updateLayer];
}

# pragma mark - Actions

- (void)touchUpInside:(nonnull UIButton *)sender {
    if (sender == self) {
        self.paused = !self.paused;
        [self.delegate button:self didChangeToPaused:self.paused];
    }
}

- (void)updateLayer {
    if (!self.paused) {
        // draw pause button
        
        // calculate key points
        CGFloat height = MIN(self.frame.size.width, self.frame.size.height);
        CGFloat width = height * cos(0.5);
        
        CGFloat minX = (self.frame.size.width - width) / 2.0;
        CGFloat minY = (self.frame.size.height - height) / 2.0;
        
        // create the path
        CGMutablePathRef path = CGPathCreateMutable();
        
        CGPathAddRect(path, NULL, CGRectMake(minX, minY, width * (2.0 / 5.0), height));
        CGPathAddRect(path, NULL, CGRectMake(minX + width * (3.0 / 5.0), minY, width * (2.0 / 5.0), height));
        
        // set the layer's path
        self.layer.path = path;
        
        // release the path
        CGPathRelease(path);
        
    } else {
        // draw play button
        
        // calculate key points
        CGFloat height = MIN(self.frame.size.width, self.frame.size.height);
        CGFloat width = height * cos(0.5);
        
        CGFloat minX = (self.frame.size.width - width) / 2.0;
        CGFloat maxX = minX + width;
        
        CGFloat minY = (self.frame.size.height - height) / 2.0;
        CGFloat maxY = minY + height;
        CGFloat midY = minY + height / 2.0;
        
        // create the path
        CGMutablePathRef path = CGPathCreateMutable();
        
        CGPathMoveToPoint(path, NULL, minX, minY);
        CGPathAddLineToPoint(path, NULL, minX, maxY);
        CGPathAddLineToPoint(path, NULL, maxX, midY);
        CGPathAddLineToPoint(path, NULL, minX, minY);
        
        // set the layer's path
        self.layer.path = path;
        
        // release the path
        CGPathRelease(path);
        
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
