//
//  PxpBorderLabel.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-10.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpBorderLabel.h"
#import "UIColor+Highlight.h"

#define DEFAULT_BORDER_WIDTH 2.0

@interface PxpBorderLabel ()

@property (strong, nonatomic, nullable) UIColor *borderColor;

@end

@implementation PxpBorderLabel

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
        self.textAlignment = NSTextAlignmentCenter;
        self.adjustsFontSizeToFitWidth = YES;
        [self updateColors];
    }
    return self;
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.borderWidth = [aDecoder containsValueForKey:@"borderWidth"] ? [aDecoder decodeFloatForKey:@"borderWidth"] : DEFAULT_BORDER_WIDTH;
        self.textAlignment = NSTextAlignmentCenter;
        self.adjustsFontSizeToFitWidth = YES;
        [self updateColors];
    }
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeFloat:self.borderWidth forKey:@"borderWidth"];
}

#pragma mark - Overrides

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

- (nullable UIColor *)borderColor {
    return [UIColor colorWithCGColor:self.layer.borderColor];
}

#pragma mark - Private Methods

- (void)updateColors {
    self.borderColor = self.highlighted ? self.tintColor.highlightedColor : self.tintColor;
    self.textColor = self.highlighted ? self.tintColor.highlightedColor : self.tintColor;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
