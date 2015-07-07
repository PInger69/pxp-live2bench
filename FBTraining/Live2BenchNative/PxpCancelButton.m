//
//  PxpCancelButton.m
//  PxpPlayer
//
//  Created by Nico Cvitak on 2015-06-09.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import "PxpCancelButton.h"

@implementation PxpCancelButton

- (nonnull instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.lineWidth = 3.0;
        self.layer.lineCap = kCALineCapRound;
    }
    return self;
}

#pragma mark - Overrides

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    // calculate key points
    CGFloat height = MIN(frame.size.width, frame.size.height);
    CGFloat width = height;
    
    CGFloat minX = (frame.size.width - width) / 2.0;
    CGFloat maxX = minX + width;
    
    CGFloat minY = (frame.size.height - height) / 2.0;
    CGFloat maxY = minY + height;
    
    // create the path
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, minX, minY);
    CGPathAddLineToPoint(path, NULL, maxX, maxY);
    CGPathMoveToPoint(path, NULL, maxX, minY);
    CGPathAddLineToPoint(path, NULL, minX, maxY);
    
    // set the layer's path
    self.layer.path = path;
    
    // release the path
    CGPathRelease(path);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
