//
//  LiveButton.m
//  Live2BenchNative
//
//  Created by dev on 2014-12-03.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "LiveButton.h"

@implementation LiveButton

static UIImage * __nonnull _goToLiveImage;
static UIImage * __nonnull _goToLiveImageTemplate;

+ (void)initialize {
    _goToLiveImage = [UIImage imageNamed:@"gotolive"];
    _goToLiveImageTemplate = [_goToLiveImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (nonnull instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundImage:_goToLiveImageTemplate forState:UIControlStateNormal];
        [self setBackgroundImage:_goToLiveImage forState:UIControlStateHighlighted];
        
        [self setTitle:NSLocalizedString(@"Live", nil)  forState:UIControlStateNormal];
        
        self.layer.borderColor = self.tintColor.CGColor;
        self.layer.borderWidth = 1.0;
        
        [self setContentEdgeInsets:UIEdgeInsetsMake(3, 5, 3, 5)];
        
        [self setTitleColor:self.tintColor forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted | UIControlStateSelected];
        
        self.titleLabel.font = [UIFont systemFontOfSize:17.0];
    }
    return self;
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setBackgroundImage:_goToLiveImageTemplate forState:UIControlStateNormal];
        [self setBackgroundImage:_goToLiveImage forState:UIControlStateHighlighted];
        
        [self setTitle:NSLocalizedString(@"Live", nil)  forState:UIControlStateNormal];
        
        self.layer.borderColor = self.tintColor.CGColor;
        self.layer.borderWidth = 1.0;
        
        [self setContentEdgeInsets:UIEdgeInsetsMake(3, 5, 3, 5)];
        
        [self setTitleColor:self.tintColor forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted | UIControlStateSelected];
        
        self.titleLabel.font = [UIFont systemFontOfSize:17.0];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        if (!self.selected) self.backgroundColor = self.tintColor;
    } else {
        if (!self.selected) self.backgroundColor = [UIColor clearColor];
    }
    
}


- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.backgroundColor = selected ? self.tintColor : [UIColor clearColor];
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    [self setTitleColor:enabled ? self.tintColor : [UIColor grayColor] forState:UIControlStateNormal];
    self.layer.borderColor = (enabled ? self.tintColor : [UIColor grayColor]).CGColor;
    self.alpha = enabled ? 1.0 : 0.6;
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    if (self.enabled){
        [self setTitleColor:self.tintColor forState:UIControlStateNormal];
        self.layer.borderColor = self.tintColor.CGColor;
    }
}

@end
