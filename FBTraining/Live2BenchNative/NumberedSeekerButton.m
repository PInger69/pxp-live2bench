//
//  NumberedSeekerButton.m
//  QuickTest
//
//  Created by dev on 6/19/2014.
//  Copyright (c) 2014 dev. All rights reserved.
//

#import "NumberedSeekerButton.h"

#import "UIColor+Highlight.h"

static UIImage * __nonnull _circleArrow;

@implementation NumberedSeekerButton
{
    UILabel * __nonnull _numberLabel;
}

+ (void)initialize {
    _circleArrow = [[UIImage imageNamed: @"seeklarge.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (nonnull instancetype)initWithFrame:(CGRect)frame backward:(BOOL)backward
{
    self = [super initWithFrame:frame];
    if (self) {
        const CGFloat w = self.bounds.size.width, h = self.bounds.size.height, s = MIN(w, h);
        const CGRect labelFrame = w > h ? CGRectMake((w - h) / 2.0, 0.0, h, h) : CGRectMake(0.0, (h - w) / 2.0, w, w);
        
        _numberLabel = [[UILabel alloc] initWithFrame:labelFrame];
        _numberLabel.text = @"";
        _numberLabel.textColor = self.tintColor;
        _numberLabel.textAlignment = NSTextAlignmentCenter;
        _numberLabel.font = [UIFont systemFontOfSize:0.5 * s];
        _numberLabel.adjustsFontSizeToFitWidth = YES;
        
        [self setImage:_circleArrow forState:UIControlStateNormal];
        [self addSubview:_numberLabel];
        
        self.backward = backward;
        self.textNumber = 1.0;
    }
    return self;
}

- (nonnull instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame backward:NO];
}

#pragma mark - NSCoding

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _numberLabel = [[UILabel alloc] init];
        _numberLabel.textColor = self.tintColor;
        _numberLabel.textAlignment = NSTextAlignmentCenter;
        _numberLabel.adjustsFontSizeToFitWidth = YES;
        
        [self setImage:_circleArrow forState:UIControlStateNormal];
        [self addSubview:_numberLabel];
        
        self.backward = [aDecoder decodeBoolForKey:@"backward"];
        self.textNumber = [aDecoder decodeFloatForKey:@"textNumber"];
    }
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeBool:_backward forKey:@"backward"];
    [aCoder encodeFloat:_textNumber forKey:@"textNumber"];
}

#pragma mark - Getters / Setters

- (void)setBackward:(BOOL)backward {
    _backward = backward;
    
    if (backward) {
        self.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        _numberLabel.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    } else {
        self.transform = CGAffineTransformMakeScale(1.0, 1.0);
        _numberLabel.transform = CGAffineTransformMakeScale(1.0, 1.0);
    }
}

/**
 *  Enter in a float number to be showen in the center of the icon.
 *  Reccomended range .01 to 999.49. If you go passed these ranges you will see  .00 or  1...
 *
 *  @param num nubmer to be displayed
 */
- (void)setTextNumber:(CGFloat)textNumber {
    _textNumber = textNumber;
    
    NSString *txtNum;
    if (textNumber < .25){
        txtNum = @"F";
    } else if (textNumber < 1){
        txtNum = [NSString stringWithFormat:@"%.02f",textNumber];
        txtNum = [txtNum substringFromIndex:1];
    } else if (textNumber >= 1 && textNumber <= 9) {
        txtNum = [NSString stringWithFormat:@"%.f",textNumber];
    } else {
        txtNum = [NSString stringWithFormat:@"%.f",textNumber];
    }
    
    _numberLabel.text = txtNum;
}

#pragma mark - Overrides

- (void)setEnabled:(BOOL)enabled{
    [super setEnabled:enabled];
    
    _numberLabel.enabled = enabled;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    _numberLabel.textColor = self.highlighted ? self.tintColor.highlightedColor : self.tintColor;
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    
    _numberLabel.textColor = self.highlighted ? self.tintColor.highlightedColor : self.tintColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    const CGFloat w = self.bounds.size.width, h = self.bounds.size.height, s = MIN(w, h);
    const CGRect labelFrame = w > h ? CGRectMake((w - h) / 2.0, 0.0, h, h) : CGRectMake(0.0, (h - w) / 2.0, w, w);
    
    _numberLabel.frame = labelFrame;
    _numberLabel.font = [UIFont systemFontOfSize:(1.0 - PHI_INV) * s];
}

@end
