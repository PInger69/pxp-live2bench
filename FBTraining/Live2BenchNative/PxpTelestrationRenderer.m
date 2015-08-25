//
//  PxpTelestrationRenderer.m
//  PxpTelestration
//
//  Created by Nico Cvitak on 2015-07-08.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import "PxpTelestrationRenderer.h"

/// The number of samples used to calculate the approximate tangent vector of the arrow.
#define ARROW_TANGENT_SAMPLES 4

/// Makes a vector from point a to point b.
static CGVector CGVectorMakeWithPoints(const CGPoint a, const CGPoint b)
{
    return CGVectorMake(b.x - a.x, b.y - a.y);
}

/// Multiplies a vector by a scalar and returns the result.
static CGVector CGVectorMultiplyByScalar(const CGVector x, const CGFloat c)
{
    return CGVectorMake(c * x.dx, c * x.dy);
}

/// Adds two vectors together and returns the result.
static CGVector CGVectorAdd(const CGVector x, const CGVector y)
{
    return CGVectorMake(x.dx + y.dx, x.dy + y.dy);
}

@interface PxpTelestrationRenderer ()

@property (readonly, assign, nonatomic) NSTimeInterval currentTime;

@end

@implementation PxpTelestrationRenderer

/// The path of the arrow to be drawn.
static UIBezierPath *__nonnull _arrow;

+ (void)initialize {
    
    // create the arrow.
    _arrow = [UIBezierPath bezierPath];
    [_arrow moveToPoint:CGPointMake(0.0, 0.0)];
    [_arrow addLineToPoint:CGPointMake(1.0 - cos(1.0), -cos(1.0))];
    [_arrow addLineToPoint:CGPointMake(2.0 - 2.0 * sin(1.0), 0.0)];
    [_arrow addLineToPoint:CGPointMake(1.0 - cos(1.0), +cos(1.0))];
    [_arrow addLineToPoint:CGPointMake(0.0, 0.0)];
}

- (nonnull instancetype)initWithTelestration:(nullable PxpTelestration *)telestration {
    self = [super init];
    if (self) {
        _telestration = telestration;
    }
    return self;
}

- (nonnull instancetype)init {
    return [self initWithTelestration:nil];
}

- (void)renderInContext:(CGContextRef)context size:(CGSize)size {
    [self renderInContext:context size:size atTime:INFINITY];
}

- (void)renderInContext:(nullable CGContextRef)context size:(CGSize)size atTime:(NSTimeInterval)time {
    if (self.telestration) {
        
        // adjust time if needed.
        if (self.telestration.isStill) {
            time = self.telestration.thumbnailTime;
        }
        
        // get actions for time.
        NSArray *actions = self.telestration ? [self.telestration actionStackForTime:time] : @[];
        
        // calculate the scaling required to display the telestration in the current context.
        const CGVector scale = self.telestration.size.width && self.telestration.size.height ? CGVectorMake(size.width / self.telestration.size.width, size.height / self.telestration.size.height) : CGVectorMake(1.0, 1.0);
        
        // push main context.
        CGContextSaveGState(context);
        
        // setup main context.
        CGContextSetBlendMode(context, kCGBlendModeCopy);
        CGContextSetLineCap(context, kCGLineCapRound);
        CGContextSetLineJoin(context, kCGLineJoinRound);
        
        // clear the drawing area.
        CGContextClearRect(context, CGRectMake(0.0, 0.0, size.width, size.height));
        
        // push draw context.
        CGContextSaveGState(context);
        CGContextScaleCTM(context, scale.dx, scale.dy);
        
        for (PxpTelestrationAction *action in actions) {
            const NSArray *points = action.points;
            
            // setup context for action.
            CGContextSetStrokeColorWithColor(context, action.strokeColor.CGColor);
            CGContextSetFillColorWithColor(context, action.strokeColor.CGColor);
            CGContextSetLineWidth(context, action.strokeWidth);
            
            if (action.type & PxpLine) {
                // draw line.
                
                CGPoint a = [points.firstObject position], b = a;
                
                for (PxpTelestrationPoint *point in points.reverseObjectEnumerator) {
                    if (point.displayTime <= time) {
                        b = point.position;
                        break;
                    }
                }
                
                CGContextBeginPath(context);
                CGContextMoveToPoint(context, a.x, a.y);
                CGContextAddLineToPoint(context, b.x, b.y);
                CGContextDrawPath(context, kCGPathStroke);
                
            } else {
                // draw curve.
                
                CGContextBeginPath(context);
                for (NSUInteger i = 0; i < points.count && [points[i] displayTime] <= time; i++) {
                    const PxpTelestrationPoint * point = points[i];
                    if (i == 0) {
                        CGContextMoveToPoint(context, point.position.x, point.position.y);
                    } else {
                        CGContextAddLineToPoint(context, point.position.x, point.position.y);
                    }
                }
                CGContextDrawPath(context, kCGPathStroke);
            }
            
            if (action.type & PxpArrow) {
                // draw arrow.
                
                // find the index of the end point.
                NSUInteger i = action.points.count - 1;
                while (i < action.points.count && [action.points[i] displayTime] > time) {
                    i--;
                }
                
                if (i > 1) {
                    // get the end point.
                    const CGPoint a = [action.points[i] position];
                    
                    CGVector tangent = CGVectorMake(0.0, 0.0);
                    if (action.type & PxpLine) {
                        tangent = CGVectorMakeWithPoints([action.points.firstObject position], a);
                    } else {
                        // calculate the number of tangent samples to use.
                        const NSUInteger t = MIN(i - 1, ARROW_TANGENT_SAMPLES);
                        
                        // calculate the tangent vector.
                        for (NSUInteger j = i - 1; i - 1 - t <= j && j <= i - 1; j--) {
                            const CGVector v = CGVectorMakeWithPoints([action.points[j] position], [action.points[j + 1] position]);
                            
                            tangent = CGVectorAdd(tangent, CGVectorMultiplyByScalar(v, 1.0 / t));
                        }
                    }
                    
                    // calculate the tangent angle.
                    const CGFloat angle = -atan2(tangent.dy, -tangent.dx);
                    
                    // push arrow context.
                    CGContextSaveGState(context);
                    
                    // setup arrow context.
                    CGContextTranslateCTM(context, a.x, a.y);
                    CGContextScaleCTM(context, 8.0 * action.strokeWidth, 8.0 * action.strokeWidth);
                    CGContextRotateCTM(context, angle);
                    CGContextTranslateCTM(context, -action.strokeWidth / 32.0, 0.0);
                    
                    // draw arrow.
                    CGContextBeginPath(context);
                    CGContextAddPath(context, _arrow.CGPath);
                    CGContextDrawPath(context, kCGPathFill);
                    
                    // pop arrow context.
                    CGContextRestoreGState(context);
                }
            }
            
        }
        
        // pop draw context.
        CGContextRestoreGState(context);
        
        // pop main context.
        CGContextRestoreGState(context);
    }
}

- (nonnull UIImage *)image {
    UIGraphicsBeginImageContext(self.telestration.size);
    
    [self renderInContext:UIGraphicsGetCurrentContext() size:self.telestration.size];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

- (NSTimeInterval)currentTime {
    return self.timeProvider ? self.timeProvider.currentTimeInSeconds : INFINITY;
}


@end