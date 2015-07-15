//
//  PxpColorPicker.m
//  PxpTelestration
//
//  Created by Nico Cvitak on 2015-07-13.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import "PxpColorPicker.h"

#define NUM_COLORS 12

@interface PxpColorPicker ()

@property (assign, nonatomic) CGVector vector;
@property (assign, nonatomic) CGPoint location;

@end

@implementation PxpColorPicker

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _color = [UIColor colorWithHue:0.0 saturation:1.0 brightness:1.0 alpha:1.0];
        _vector = CGVectorMake(1.0, 0.0);
    }
    return self;
}

- (instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _color = [UIColor colorWithHue:0.0 saturation:1.0 brightness:1.0 alpha:1.0];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    CGContextSetLineCap(ctx, kCGLineCapRound);
    
    CGPoint c = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    CGFloat d = MIN(rect.size.width, rect.size.height);
    CGFloat w = d * 0.05;
    CGFloat r = (d - w) / 2.0;
    
    //draw colors
    for (NSUInteger i = 0; i < NUM_COLORS; i++) {
        CGFloat a = (CGFloat) i / NUM_COLORS, b = (CGFloat) (i + 1) / NUM_COLORS;
        
        UIColor *color = [UIColor colorWithHue:a saturation:1.0 brightness:1.0 alpha:1.0];
        
        a -= 0.5 / NUM_COLORS, b -= 0.5 / NUM_COLORS;
        
        CGContextSetFillColorWithColor(ctx, color.CGColor);
        CGContextBeginPath(ctx);
        CGContextAddArc(ctx, c.x, c.y, r, a * 2 * M_PI, b * 2 * M_PI, NO);
        CGContextAddLineToPoint(ctx, c.x, c.y);
        CGContextDrawPath(ctx, kCGPathFill);
    }
    
    //draw ring
    
    CGContextSetStrokeColorWithColor(ctx, self.color.CGColor);
    CGContextSetLineWidth(ctx, w);
    CGContextBeginPath(ctx);
    CGContextAddArc(ctx, c.x, c.y, r, 0.0, 2 * M_PI, NO);
    CGContextDrawPath(ctx, kCGPathStroke);
    
    //draw line
    CGContextSetLineWidth(ctx, w * 0.5);
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, c.x, c.y);
    CGContextAddLineToPoint(ctx, c.x + (r - 2.0 * w) * self.vector.dx, c.y + (r - 2.0 * w) * self.vector.dy);
    CGContextDrawPath(ctx, kCGPathStroke);
    
    //draw dot
    
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextBeginPath(ctx);
    
    CGContextAddArc(ctx, c.x + (r - w) * self.vector.dx, c.y + (r - w) * self.vector.dy, w, 0, 2 * M_PI, NO);
    //CGContextAddArc(ctx, location.x, location.y, w, 0, 2 * M_PI, NO);
    
    CGContextDrawPath(ctx, kCGPathFill);
    
    
    CGContextRestoreGState(ctx);
}

- (void)touchesBegan:(nonnull NSSet*)touches withEvent:(nullable UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self updateWithTouch:touches.anyObject];
    
}

- (void)touchesMoved:(nonnull NSSet *)touches withEvent:(nullable UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    [self updateWithTouch:touches.anyObject];
}

- (void)touchesEnded:(nonnull NSSet *)touches withEvent:(nullable UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self updateWithTouch:touches.anyObject];
}

- (void)updateWithTouch:(nullable UITouch *)touch {
    if (touch) {
        CGPoint c = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        CGPoint t = [touch locationInView:self];
        
        self.location = t;
        
        CGVector v = CGVectorMake(t.x - c.x, t.y - c.y);
        CGFloat l = sqrt(v.dx * v.dx + v.dy * v.dy);
        self.vector = CGVectorMake(v.dx / l, v.dy / l);
        
        CGFloat h = atan2(self.vector.dy, self.vector.dx) / (2 * M_PI);
        
        h = round(h * NUM_COLORS) / NUM_COLORS;
        
        self.color = [UIColor colorWithHue:h < 0 ? h + 1.0 : h saturation:1.0 brightness:1.0 alpha:1.0];
        
        [self setNeedsDisplay];
    }
}

@end
