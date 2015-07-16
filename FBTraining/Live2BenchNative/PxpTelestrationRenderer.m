//
//  PxpTelestrationRenderer.m
//  PxpTelestration
//
//  Created by Nico Cvitak on 2015-07-08.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import "PxpTelestrationRenderer.h"

#define RENDER_GRANULARITY 16

@interface PxpTelestrationRenderer ()

/// GPU optimized target used to store path rendering.
@property (assign, nonatomic, nullable) CGLayerRef layer;
@property (assign, nonatomic, nullable) CGLayerRef cache;

@property (strong, nonatomic, nullable) PxpTelestrationPoint *cachedPoint;
@property (assign, nonatomic) NSUInteger cachedIndex;
@property (readonly, assign, nonatomic) NSTimeInterval currentTime;

@end

@implementation PxpTelestrationRenderer

- (nonnull instancetype)initWithTelestration:(nonnull PxpTelestration *)telestration {
    self = [super init];
    if (self) {
        _telestration = telestration;
        _layer = nil;
        _cache = nil;
        _cachedPoint = nil;
    }
    return self;
}

- (nonnull instancetype)init {
    self = [super init];
    if (self) {
        _telestration = [[PxpTelestration alloc] init];
        _layer = nil;
        _cache = nil;
        _cachedPoint = nil;
    }
    return self;
}

- (void)renderInContext:(CGContextRef)context size:(CGSize)size {
    [self renderInContext:context size:size atTime:INFINITY];
}

- (void)renderInContext:(nullable CGContextRef)context size:(CGSize)size atTime:(NSTimeInterval)time {
    
    CGVector scale = self.telestration.size.width && self.telestration.size.height ? CGVectorMake(size.width / self.telestration.size.width, size.height / self.telestration.size.height) : CGVectorMake(1.0, 1.0);
    
    CGContextSaveGState(context);
    
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, CGRectMake(0.0, 0.0, size.width, size.height));
    
    CGSize pixelSize = CGSizeMake([UIScreen mainScreen].scale * size.width, [UIScreen mainScreen].scale * size.height);
    
    if (!self.layer || !CGSizeEqualToSize(CGLayerGetSize(self.layer), pixelSize))  {
        CGLayerRelease(self.layer);
        CGLayerRelease(self.cache);
        self.layer = CGLayerCreateWithContext(context, pixelSize, NULL);
        self.cache = CGLayerCreateWithContext(context, pixelSize, NULL);
        
        self.cachedPoint = nil;
    }
    
    CGContextRef ctx = CGLayerGetContext(self.layer);
    CGContextSaveGState(ctx);
    
    CGContextSetBlendMode(ctx, kCGBlendModeCopy);
    
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    
    CGContextScaleCTM(ctx, [UIScreen mainScreen].scale, [UIScreen mainScreen].scale);
    
    CGContextSetFillColorWithColor(ctx, [UIColor clearColor].CGColor);
    CGContextFillRect(ctx, CGRectMake(0.0, 0.0, size.width, size.height));
    
    NSArray *actions = self.telestration ? [self.telestration actionStackForTime:time] : @[];
    
    PxpTelestrationAction *lastAction = actions.lastObject;
    BOOL cached = self.cachedPoint && self.cachedIndex < lastAction.points.count && [lastAction.points[self.cachedIndex] isEqual:self.cachedPoint] && self.cachedPoint.displayTime <= time;
    
    // draw old image
    if (cached) {
        CGContextDrawLayerInRect(ctx, CGRectMake(0.0, 0.0, size.width, size.height), self.cache);
    } else {
        self.cachedPoint = nil;
    }
    
    CGContextSaveGState(ctx);
    CGContextScaleCTM(ctx, scale.dx, scale.dy);
    for (NSUInteger i = 0; i < actions.count; i++) {
        PxpTelestrationAction *action = actions[i];
        
        if (!(action.type & PxpLine)) {
            UIBezierPath *path = [self pathForAction:action atTime:time];
            if (path) {
                CGContextSetStrokeColorWithColor(ctx, action.strokeColor.CGColor);
                CGContextSetLineWidth(ctx, action.strokeWidth);
            
                CGContextBeginPath(ctx);
                CGContextAddPath(ctx, path.CGPath);
                CGContextDrawPath(ctx, kCGPathStroke);
            }
        }
    }
    CGContextRestoreGState(ctx);
    
    
    CGContextRestoreGState(ctx);
    
    CGContextRef bctx = CGLayerGetContext(self.cache);
    CGContextSetBlendMode(bctx, kCGBlendModeCopy);
    CGContextSetFillColorWithColor(bctx, [UIColor clearColor].CGColor);
    CGContextFillRect(bctx, CGRectMake(0.0, 0.0, pixelSize.width, pixelSize.height));
    CGContextDrawLayerInRect(bctx, CGRectMake(0.0, 0.0, pixelSize.width, pixelSize.height), self.layer);
    CGContextDrawLayerInRect(context, CGRectMake(0.0, 0.0, size.width, size.height), self.layer);
    
    CGContextSaveGState(context);
    CGContextScaleCTM(context, scale.dx, scale.dy);
    for (NSUInteger i = 0; i < actions.count; i++) {
        PxpTelestrationAction *action = actions[i];
        
        CGContextSetStrokeColorWithColor(context, action.strokeColor.CGColor);
        CGContextSetFillColorWithColor(context, action.strokeColor.CGColor);
        CGContextSetLineWidth(context, action.strokeWidth);
        
        if ((action.type & PxpLine) && [action.points.firstObject displayTime] <= time) {
            // just draw first to last
            CGPoint a = [action.points.firstObject position], b = a;
            
            for (PxpTelestrationPoint *point in action.points.reverseObjectEnumerator) {
                if (point.displayTime <= time) {
                    b = point.position;
                    break;
                }
            }
            
            CGContextBeginPath(context);
            CGContextMoveToPoint(context, a.x, a.y);
            CGContextAddLineToPoint(context, b.x, b.y);
            CGContextDrawPath(context, kCGPathStroke);
        }
        
        if (action.type & PxpArrow) {
            // draw the arrow
            
            if (action.points.count > 2 && [action.points.firstObject displayTime] <= time) {
                NSUInteger i = action.points.count - 1;
                while (i < action.points.count && [action.points[i] displayTime] > time) {
                    i--;
                }
                
                NSUInteger j = action.type & PxpLine ? 0 : i - 1;
                j = j > i ? i : j;
                
                while (j < action.points.count && j > 0 && CGPointEqualToPoint([action.points[i] position], [action.points[j] position])) {
                    j--;
                }
                
                CGPoint a = [action.points[i] position], b = [action.points[j] position];
                
                CGVector v = CGVectorMake(b.x - a.x, b.y - a.y);
                
                CGFloat angle = atan2(v.dy, v.dx);
                
                
                UIBezierPath *arrow = [self arrow];
                
                CGContextSaveGState(context);
                
                CGContextTranslateCTM(context, a.x, a.y);
                CGContextScaleCTM(context, 8.0 * action.strokeWidth, 8.0 * action.strokeWidth);
                CGContextRotateCTM(context, angle);
                CGContextTranslateCTM(context, -action.strokeWidth / 32.0, 0.0);
                
                CGContextBeginPath(context);
                CGContextAddPath(context, arrow.CGPath);
                CGContextDrawPath(context, kCGPathFill);
                
                CGContextRestoreGState(context);
            }
            
        }
    }
    CGContextRestoreGState(context);
    
    CGContextRestoreGState(context);
    self.cachedPoint = [actions.lastObject points].lastObject;
}

- (nonnull UIImage *)image {
    UIGraphicsBeginImageContext(self.telestration.size);
    
    [self renderInContext:UIGraphicsGetCurrentContext() size:self.telestration.size];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

- (NSTimeInterval)currentTime {
    return self.timeProvider ? self.timeProvider.currentTime : INFINITY;
}

#pragma mark - Private Methods

- (nullable UIBezierPath *)pathForAction:(nonnull PxpTelestrationAction *)action atTime:(NSTimeInterval)time {
    
    if (action.points.count > 0) {
        
        NSArray *points = action.points;
        
        if (self.cachedPoint && self.cachedPoint.displayTime <= time) {
            
            // find the next index to render that is not cached.
            NSUInteger a = [action.points indexOfObject:self.cachedPoint inSortedRange:NSMakeRange(0, action.points.count) options:NSBinarySearchingInsertionIndex usingComparator:[PxpTelestrationAction sortMethod]];
        
            // make a sub array.
            a = a >= 5 ? a - 5 : 0;
            a /= 4;
            a *= 4;
            
            points = [points subarrayWithRange:NSMakeRange(a, action.points.count - a)];
        }
        
        NSUInteger b = [points indexOfObject:[[PxpTelestrationPoint alloc] initWithPosition:CGPointZero displayTime:time] inSortedRange:NSMakeRange(0, points.count) options:NSBinarySearchingInsertionIndex usingComparator:[PxpTelestrationAction sortMethod]];
        
        points = [points subarrayWithRange:NSMakeRange(0, b > points.count ? points.count - 1 : b)];
        
        if (points.count == 0) {
            return nil;
        }
        
        UIBezierPath *path = [[UIBezierPath alloc] init];
        
        
        
        if (points.count < 4) {
            [path moveToPoint:[points[0] position]];
            
            for (NSUInteger i = 1; i < points.count; i++) {
                [path addLineToPoint:[points[i] position]];
            }
        }
        else {
            [path moveToPoint:[points[0] position]];
            
            for (NSUInteger i = 1; i < points.count - 2; i += 2) {
                CGPoint p0 = [points[i - 1] position];
                CGPoint p1 = [points[i] position];
                CGPoint p2 = [points[i + 1] position];
                CGPoint p3 = [points[i + 2] position];
                
                for (NSUInteger j = 1; j < RENDER_GRANULARITY; j++) {
                    CGFloat t = j * (1.0 / RENDER_GRANULARITY);
                    CGFloat tt = t * t;
                    CGFloat ttt = t * t * t;
                    
                    CGPoint p;
                    p.x = 0.5 * (2*p1.x+(p2.x-p0.x)*t + (2*p0.x-5*p1.x+4*p2.x-p3.x)*tt + (3*p1.x-p0.x-3*p2.x+p3.x)*ttt);
                    p.y = 0.5 * (2*p1.y+(p2.y-p0.y)*t + (2*p0.y-5*p1.y+4*p2.y-p3.y)*tt + (3*p1.y-p0.y-3*p2.y+p3.y)*ttt);
                    
                    [path addLineToPoint:p];
                    
                }
                
                [path addLineToPoint:p2];
            }
            
        }
        
        
        
        /*
        for (NSUInteger i = 0; i < points.count - 4 && points.count > 4; i++) {
            if (i % 3 == 0) {
                [path moveToPoint:[points[i] position]];
                [path addCurveToPoint:[points[i + 3] position] controlPoint1:[points[i + 1] position] controlPoint2:[points[i + 2] position]];
            }
        }
        */
        
        /*
        [path moveToPoint:[points.firstObject position]];
        for (NSUInteger i = 1; i < points.count; i++) {
            [path addLineToPoint:[points[i] position]];
        }
        */
        
        return path;
    } else {
        return nil;
    }
}


- (nonnull UIBezierPath *)arrow {
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    [path moveToPoint:CGPointMake(0.0, 0.0)];
    [path addLineToPoint:CGPointMake(1.0 - cos(1.0), -cos(1.0))];
    [path addLineToPoint:CGPointMake(2.0 - 2.0 * sin(1.0), 0.0)];
    [path addLineToPoint:CGPointMake(1.0 - cos(1.0), +cos(1.0))];
    [path addLineToPoint:CGPointMake(0.0, 0.0)];
    
    return path;
}

@end