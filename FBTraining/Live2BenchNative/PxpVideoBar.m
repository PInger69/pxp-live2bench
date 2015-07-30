//
//  PxpVideoBar.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-07-29.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpVideoBar.h"

@implementation PxpVideoBar

- (void)initVideoBar {
    _backwardSeekButton = [SeekButton makeBackwardAt:CGPointZero];
    _forwardSeekButton = [SeekButton makeForwardAt:CGPointZero];
    _slomoButton = [[Slomo alloc] init];
    
    [self addSubview:_backwardSeekButton];
    //[self addSubview:_forwardSeekButton];
    [self addSubview:_slomoButton];
    
    self.backgroundColor = [UIColor grayColor];
}

- (nonnull instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initVideoBar];
    }
    return self;
}

- (nonnull instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initVideoBar];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat w = self.bounds.size.width, h = self.bounds.size.height;
    
    
    _backwardSeekButton.center = CGPointMake(0.0, 0.0);
    //_backwardSeekButton.frame = CGRectMake(h, 0.0, h, h);
    //_forwardSeekButton.frame = CGRectMake(w - 2.0 * h, 0.0, h, h);
    
    _slomoButton.frame = CGRectMake(1.5 * h, 0.0, h, h);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
