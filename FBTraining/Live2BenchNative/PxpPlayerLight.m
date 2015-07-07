//
//  PxpPlayerLight.m
//  PxpPlayer
//
//  Created by Nico Cvitak on 2015-06-09.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import "PxpPlayerLight.h"

@interface PxpPlayerLight ()

@property (readonly, strong, nonatomic, nonnull) CAShapeLayer *layer;

@end

@implementation PxpPlayerLight

// the layer will be a CAShapeLayer at runtime
@dynamic layer;

+ (Class)layerClass {
    return [CAShapeLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.shadowRadius = 11.0;
        self.layer.shadowOpacity = 1.0;
        self.layer.shadowOffset = CGSizeZero;
        
        self.color = [UIColor whiteColor];
    }
    return self;
}

#pragma mark - Getters / Setters

- (void)setColor:(nonnull UIColor *)color {
    _color = color;
    
    // update layer colors
    self.layer.fillColor = color.CGColor;
    self.layer.shadowColor = color.CGColor;
}

#pragma mark - Overrides

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    CGFloat size = MIN(frame.size.width, frame.size.height);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddEllipseInRect(path, NULL, CGRectMake(0, 0, size, size));
    
    self.layer.path = path;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
