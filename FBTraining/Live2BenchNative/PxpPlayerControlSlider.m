//
//  PxpPlayerControlSlider.m
//  PxpPlayer
//
//  Created by Nico Cvitak on 2015-06-09.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import "PxpPlayerControlSlider.h"

@implementation PxpPlayerControlSlider

- (void)initCommon {
    self.layer.shadowOffset = CGSizeZero;
    self.layer.shadowOpacity = 0.5;
    self.layer.shadowRadius = 5.5;
    
    if (self.tintColor) {
        self.layer.shadowColor = self.tintColor.CGColor;
    }
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
    }
    return self;
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    
    if (self.tintColor) {
        self.layer.shadowColor = self.tintColor.CGColor;
    }
}

- (void)setGlowRadius:(CGFloat)glowRadius {
    [self willChangeValueForKey:@"glowRadius"];
    self.layer.shadowRadius = glowRadius;
    [self didChangeValueForKey:@"glowRadius"];
}

- (CGFloat)glowRadius {
    return self.layer.shadowRadius;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
