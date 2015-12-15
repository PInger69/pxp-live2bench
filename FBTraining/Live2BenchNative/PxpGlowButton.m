//
//  PxpGlowButton.m
//  PxpPlayer
//
//  Created by Nico Cvitak on 2015-06-09.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import "PxpGlowButton.h"

@interface PxpGlowButton ()

@property (readonly, nonatomic, nullable) UIColor *highlightColor;

@end

@implementation PxpGlowButton

// we know the layer will be a CAShapeLayer at runtime
@dynamic layer;

+ (Class)layerClass {
    return [CAShapeLayer class];
}

- (void)initCommon {
    self.layer.shadowRadius = 11.0;
    self.layer.shadowOpacity = 1.0;
    self.layer.shadowOffset = CGSizeZero;
    self.layer.lineWidth = 0.0;
    
    // change current layer colors according to state
    UIColor *color = self.highlighted ? self.highlightColor : self.tintColor;
    
    if (color) {
        self.layer.fillColor = self.stroke ? nil : color.CGColor;
        self.layer.strokeColor = color.CGColor;
        self.layer.shadowColor = color.CGColor;
    }
    
    
}

- (nonnull instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initCommon];
    }
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initCommon];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    UIColor *color = self.highlighted ? self.highlightColor : self.tintColor;
    
    if (color) {
        self.layer.fillColor = self.stroke ? nil : color.CGColor;
        self.layer.strokeColor = color.CGColor;
        self.layer.shadowColor = color.CGColor;
    }
}

#pragma mark - Getters / Setters

- (void)setGlowRadius:(CGFloat)glowRadius {
    [self willChangeValueForKey:@"glowRadius"];
    self.layer.shadowRadius = glowRadius;
    [self didChangeValueForKey:@"glowRadius"];
}

- (CGFloat)glowRadius {
    return self.layer.shadowRadius;
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    
    // change current layer colors according to state
    UIColor *color = self.highlighted ? self.highlightColor : self.tintColor;
    
    if (color) {
        self.layer.fillColor = self.stroke ? nil : color.CGColor;
        self.layer.strokeColor = color.CGColor;
        self.layer.shadowColor = color.CGColor;
    }
}

- (nullable UIColor *)highlightColor {
    if (self.tintColor) {
        CGFloat h, s, b, a;
        [self.tintColor getHue:&h saturation:&s brightness:&b alpha:&a];
        return [UIColor colorWithHue:h saturation:s brightness:fmod(b + 0.5, 1.0) alpha:a];
    } else {
        return nil;
    }
}

#pragma mark - Overrides

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    // change current layer colors according to state
    UIColor *color = self.highlighted ? self.highlightColor : self.tintColor;
    
    if (color) {
        self.layer.fillColor = self.stroke ? nil : color.CGColor;
        self.layer.strokeColor = color.CGColor;
        self.layer.shadowColor = color.CGColor;
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
