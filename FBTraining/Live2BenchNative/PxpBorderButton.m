//
//  PxpBorderButton.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-10.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpBorderButton.h"
#import "UIColor+Highlight.h"

#define DEFAULT_BORDER_WIDTH 1.0

@interface PxpBorderButton ()

@property (strong, nonatomic, nullable) UIColor *borderColor;

@end

@implementation PxpBorderButton

- (nonnull instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame borderWidth:DEFAULT_BORDER_WIDTH];
}

- (nonnull instancetype)initWithBorderWidth:(CGFloat)borderWidth {
    return [self initWithFrame:CGRectZero borderWidth:borderWidth];
}

- (nonnull instancetype)initWithFrame:(CGRect)frame borderWidth:(CGFloat)borderWidth {
    self = [super initWithFrame:frame];
    if (self) {
        self.borderWidth = borderWidth;
        
        [self updateColors];
    }
    return self;
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.borderWidth = [aDecoder containsValueForKey:@"borderWidth"] ? [aDecoder decodeFloatForKey:@"borderWidth"] : DEFAULT_BORDER_WIDTH;
        
        [self updateColors];
    }
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeFloat:self.borderWidth forKey:@"borderWidth"];
}

#pragma mark - Overrides

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self updateColors];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self updateColors];
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    [self updateColors];
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    [self updateColors];
}

#pragma mark - Getters / Setters

- (void)setBorderWidth:(CGFloat)borderWidth {
    self.layer.borderWidth = borderWidth;
}

- (CGFloat)borderWidth {
    return self.layer.borderWidth;
}

- (void)setBorderColor:(nullable UIColor *)borderColor {
    self.layer.borderColor = borderColor.CGColor;
}

- (UIColor *)borderColor {
    return [UIColor colorWithCGColor:self.layer.borderColor];
}

#pragma mark - Private Methods

- (void)updateColors {
    self.borderColor = self.enabled ? self.tintColor : self.tintColor.highlightedColor;
    self.backgroundColor = !self.highlighted ? [UIColor clearColor] : self.enabled ? self.tintColor : self.tintColor.highlightedColor;
    
    UIColor *textColor = self.highlighted ? [UIColor whiteColor] : self.tintColor;
    [self setTitleColor:self.enabled ? textColor : textColor.highlightedColor forState:UIControlStateNormal];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
