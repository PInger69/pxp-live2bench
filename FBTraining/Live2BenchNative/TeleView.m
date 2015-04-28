//
//  TeleView.m
//  Live2BenchNative
//
//  Created by dev on 2014-05-22.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "TeleView.h"

@interface TeleView ()

@property (nonatomic, strong) NSMutableArray *arrayOfUndos;

@end

@implementation TeleView

@synthesize isBlank;
@synthesize isStraight;

float hue;
float red, green, blue;
CGPoint straightPoint;
NSMutableArray *points;
CGRect lastStraightRect;
CGRect lastArrowRect;
//CGPoint minFocusPoint;
//CGPoint maxFocusPoint;
CGContextRef straightTempContext;
CGContextRef arrowTempContext;
//CGContextRef focusTempContext;
CGContextRef cacheContext;
CGContextRef undoContext;
CGContextRef undoContext2;
//CGContextRef undoContext2;
//CGContextRef undoContext3;
BOOL undoToEmptyIsPossible = YES;
BOOL didUndo = NO;
BOOL touchEnded = NO;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        red = green = blue = 0.0;
        straightPoint = CGPointMake(-1, -1);
        lastStraightRect = CGRectZero;
        lastArrowRect = CGRectZero;
        points = [[NSMutableArray alloc] init];
        for (int i = 0; i < 6; i++){
            [points addObject:[NSValue valueWithCGPoint:CGPointMake(-1, -1)]];
        }
        //NSLog(@"initBlank");
        self.isBlank = YES;
        self.opaque = NO;
        [self initContextWithTag:0 withSize:frame.size];
        [self setBackgroundColor:[UIColor clearColor]];
        self.multipleTouchEnabled = YES;
        
        self.arrayOfUndos = [[NSMutableArray alloc] init];
    }
    return self;
}
-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
}
- (void)layoutSubviews{
    [super layoutSubviews];
    [self initContextWithTag:0 withSize:self.bounds.size];
}

- (BOOL)hasUndoState {
    if (!self.arrayOfUndos.count) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)isEmptyCanvas {
    if ((!self.arrayOfUndos.count && didUndo && undoToEmptyIsPossible) || self.isBlank) {
        return YES;
    } else {
        return NO;
    }
}

- (void)initContextWithTag:(int)contextNum withSize:(CGSize)size {
    //NSLog(@"Init context: %d",contextNum);
    int bitmapByteCount;
    int	bitmapBytesPerRow;
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow = ((size.width) * 4);
    bitmapByteCount = (bitmapBytesPerRow * size.height);
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    switch (contextNum) {
        case 1:
            //            undoContext1 = CGBitmapContextCreate(NULL, size.width, size.height, 8, bitmapBytesPerRow, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
            //            break;
        case 2:
            //            undoContext2 = CGBitmapContextCreate(NULL, size.width, size.height, 8, bitmapBytesPerRow, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
            //            break;
        case 3:
            //            NSLog(@"somethibn");
            //            struct CGContextRef someUndoContext;
            //            undoContext2 = CGBitmapContextCreate(NULL, size.width, size.height, 8, bitmapBytesPerRow, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
            //[self.arrayOfUndos addObject: (__bridge id)(someUndoContext)];
            break;
        case 4:
            straightTempContext = CGBitmapContextCreate(NULL, size.width, size.height, 8, bitmapBytesPerRow, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
            break;
        case 5:
            arrowTempContext = CGBitmapContextCreate(NULL, size.width, size.height, 8, bitmapBytesPerRow, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
            break;
            //        case 6:
            //            focusTempContext = CGBitmapContextCreate(NULL, size.width, size.height, 8, bitmapBytesPerRow, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
            //            break;
        default:
            cacheContext = CGBitmapContextCreate(NULL, size.width, size.height, 8, bitmapBytesPerRow, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
            break;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    didUndo = NO;
    //NSLog(@"touchesBeganNotBlank");
    self.isBlank = NO;
    //    if (self.isFocus) {
    //        minFocusPoint = CGPointMake(-1, -1);
    //        maxFocusPoint = CGPointMake(-1, -1);
    //    }
    [self reassignUndoStates];
    //    [self initContextWithTag: 1 withSize:self.bounds.size];
    if (self.tvController) {
        [self.tvController checkUndoState];
    }
    for (int i=0; i< points.count; i++) {
        points[i] = [NSValue valueWithCGPoint:CGPointMake(-1, -1)];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if ([self distanceBetweenPoint:[points[points.count-1] CGPointValue] andPoint:[touch locationInView:self]] >= 5){
        [self cyclePointsWithNewPoint:[touch locationInView:self]];
    }
    [self drawToCache:touch];
    
    if ([UIScreen screens].count > 1) {
        UIGraphicsBeginImageContext(self.bounds.size);
        [self drawRect:self.bounds];
        UIImage * finishedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_POST_ON_EXTERNAL_SCREEN object:finishedImage];
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    touchEnded = YES;
    if (isStraight) {
        straightPoint = CGPointMake(-1, -1);
        CGImageRef cgImage = CGBitmapContextCreateImage(straightTempContext);
        CGContextDrawImage(cacheContext, self.bounds, cgImage);
        CGContextClearRect(straightTempContext, self.bounds);
        CGImageRelease(cgImage);
    } else {
        [self cyclePointsWithNewPoint:[[touches anyObject] locationInView:self]];
        [self drawToCache:[touches anyObject]];
    }
    if (self.isArrow) {
        CGImageRef arrowImage = CGBitmapContextCreateImage(arrowTempContext);
        CGContextDrawImage(cacheContext, self.bounds, arrowImage);
        CGContextClearRect(arrowTempContext, self.bounds);
        CGImageRelease(arrowImage);
    }
    touchEnded = NO;
    
    if ([UIScreen screens].count > 1) {
        UIGraphicsBeginImageContext(self.bounds.size);
        [self drawRect:self.bounds];
        UIImage * finishedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_POST_ON_EXTERNAL_SCREEN object:finishedImage];
    }
}

- (void)cyclePointsWithNewPoint:(CGPoint)point {
    for (int i=0; i < points.count - 1; i++) {
        points[i] = points[i+1];
    }
    points[points.count-1]= [NSValue valueWithCGPoint:point];
}

- (void)drawToCache:(UITouch*)touch {
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
    
    CGContextSetStrokeColorWithColor(cacheContext, [color CGColor]);
    CGContextSetLineCap(cacheContext, kCGLineCapRound);
    CGContextSetLineWidth(cacheContext, 5);
    
    CGPoint lastPoint = [touch previousLocationInView:self];
    CGPoint newPoint = [touch locationInView:self];
    
    //    if (self.isFocus) {
    //        if (minFocusPoint.x < 0){
    //            [self initContextWithTag:6 withSize:self.bounds.size];
    //        }
    //        CGContextSetStrokeColorWithColor(focusTempContext, [[UIColor colorWithWhite:1.0f alpha:0.6f] CGColor]);
    //        CGContextSetLineCap(focusTempContext, kCGLineCapRound);
    //        CGContextSetLineWidth(focusTempContext, 3);
    //        CGContextMoveToPoint(focusTempContext, lastPoint.x, lastPoint.y);
    //        CGContextAddLineToPoint(focusTempContext, newPoint.x, newPoint.y);
    //        CGContextStrokePath(focusTempContext);
    //        CGRect displayRect = CGRectMake(MIN(lastPoint.x-5, newPoint.x-5), MIN(lastPoint.y-5, newPoint.y-5), fabsf(lastPoint.x - newPoint.x) + 10, fabsf(lastPoint.y - newPoint.y) + 10);
    //        if (minFocusPoint.x < 0 || minFocusPoint.x > newPoint.x) {
    //            minFocusPoint.x = newPoint.x;
    //        }
    //        if (minFocusPoint.y < 0 || minFocusPoint.y > newPoint.y) {
    //            minFocusPoint.y = newPoint.y;
    //        }
    //        if (maxFocusPoint.x < 0 || maxFocusPoint.x < newPoint.x) {
    //            maxFocusPoint.x = newPoint.x;
    //        }
    //        if (maxFocusPoint.y < 0 || maxFocusPoint.y < newPoint.y) {
    //            maxFocusPoint.y = newPoint.y;
    //        }
    ////        hue += 0.05;
    ////        if (hue > 1.0)
    ////            hue = 0.0;
    ////        CGContextSetFillColorWithColor(focusTempContext, [UIColor colorWithHue:hue saturation:0.7 brightness:1.0 alpha:0.3].CGColor);
    ////        CGContextFillRect(focusTempContext, CGRectMake(minFocusPoint.x, minFocusPoint.y, maxFocusPoint.x - minFocusPoint.x, maxFocusPoint.y - minFocusPoint.y));
    //        [self setNeedsDisplayInRect:displayRect];
    //    } else {
    if (isStraight && straightPoint.x < 0) {
        straightPoint = lastPoint;
        [self initContextWithTag:4 withSize:self.bounds.size];
    } else if (isStraight) {
        CGContextClearRect(straightTempContext, lastStraightRect);
    }
    if (self.isArrow && !arrowTempContext) {
        [self initContextWithTag:5 withSize:self.bounds.size];
    } else if (self.isArrow) {
        CGContextClearRect(arrowTempContext, lastArrowRect);
    }
    if (isStraight) {
        CGContextSetStrokeColorWithColor(straightTempContext, [color CGColor]);
        CGContextSetLineCap(straightTempContext, kCGLineCapRound);
        CGContextSetLineWidth(straightTempContext, 5);
        CGContextMoveToPoint(straightTempContext, straightPoint.x, straightPoint.y);
        CGContextAddLineToPoint(straightTempContext, newPoint.x, newPoint.y);
        CGContextStrokePath(straightTempContext);
        CGRect displayRect = CGRectMake(MIN(straightPoint.x-5, newPoint.x-5), MIN(straightPoint.y-5, newPoint.y-5), fabsf(straightPoint.x - newPoint.x) + 10, fabsf(straightPoint.y - newPoint.y) + 10);
        [self setNeedsDisplayInRect:CGRectUnion(displayRect, lastStraightRect)];
        lastStraightRect = displayRect;
        
    } else if ([points[points.count-3] CGPointValue].x > -1) {
        double x0 = ([points[points.count-4] CGPointValue].x > -1) ? [points[points.count-4] CGPointValue].x : [points[points.count-3] CGPointValue].x; //after 4 touches we should have a back anchor point, if not, use the current anchor point
        double y0 = ([points[points.count-4] CGPointValue].y > -1) ? [points[points.count-4] CGPointValue].y : [points[points.count-3] CGPointValue].y; //after 4 touches we should have a back anchor point, if not, use the current anchor point
        double x1 = [points[points.count-3] CGPointValue].x;
        double y1 = [points[points.count-3] CGPointValue].y;
        double x2 = [points[points.count-2] CGPointValue].x;
        double y2 = [points[points.count-2] CGPointValue].y;
        double x3 = [points[points.count-1] CGPointValue].x;
        double y3 = [points[points.count-1] CGPointValue].y;
        
        double xc1 = (x0 + x1) / 2.0;
        double yc1 = (y0 + y1) / 2.0;
        double xc2 = (x1 + x2) / 2.0;
        double yc2 = (y1 + y2) / 2.0;
        double xc3 = (x2 + x3) / 2.0;
        double yc3 = (y2 + y3) / 2.0;
        
        double len1 = sqrt((x1-x0) * (x1-x0) + (y1-y0) * (y1-y0));
        double len2 = sqrt((x2-x1) * (x2-x1) + (y2-y1) * (y2-y1));
        double len3 = sqrt((x3-x2) * (x3-x2) + (y3-y2) * (y3-y2));
        
        double k1 = len1 / (len1 + len2);
        double k2 = len2 / (len2 + len3);
        
        double xm1 = xc1 + (xc2 - xc1) * k1;
        double ym1 = yc1 + (yc2 - yc1) * k1;
        double xm2 = xc2 + (xc3 - xc2) * k2;
        double ym2 = yc2 + (yc3 - yc2) * k2;
        
        double smooth_value = 0.1;
        float ctrl1_x = xm1 + (xc2 - xm1) * smooth_value + x1 - xm1;
        float ctrl1_y = ym1 + (yc2 - ym1) * smooth_value + y1 - ym1;
        float ctrl2_x = xm2 + (xc2 - xm2) * smooth_value + x2 - xm2;
        float ctrl2_y = ym2 + (yc2 - ym2) * smooth_value + y2 - ym2;
        
        CGContextMoveToPoint(cacheContext, [points[points.count-3] CGPointValue].x, [points[points.count-3] CGPointValue].y);
        CGContextAddCurveToPoint(cacheContext, ctrl1_x, ctrl1_y, ctrl2_x, ctrl2_y, [points[points.count-2] CGPointValue].x, [points[points.count-2] CGPointValue].y);
        if (touchEnded) {
            CGContextAddLineToPoint(cacheContext, [points[points.count-1] CGPointValue].x, [points[points.count-1] CGPointValue].y);
        }
        CGContextStrokePath(cacheContext);
        
        CGRect dirtyPoint1 = CGRectMake([points[points.count-3] CGPointValue].x-10, [points[points.count-3] CGPointValue].y-10, 20, 20);
        CGRect dirtyPoint2 = CGRectMake([points[points.count-2] CGPointValue].x-10, [points[points.count-2] CGPointValue].y-10, 20, 20);
        [self setNeedsDisplayInRect:CGRectUnion(dirtyPoint1, dirtyPoint2)];
    }
    if (self.isArrow && [points[points.count-4] CGPointValue].x > -1) {
        CGPoint dirPoint;
        if (self.isStraight) {
            [self drawArrowHeadWithTip:newPoint usingPoint:straightPoint];
        } else {
            if ([points[points.count-4] CGPointValue].x > -1) {
                float distance = -1;
                float avgX = 0;
                float avgY = 0;
                for (int i = points.count - 1; i >= 0; i--) {
                    avgX += [points[i] CGPointValue].x;
                    avgY += [points[i] CGPointValue].y;
                    distance = [self distanceBetweenPoint:[points[i] CGPointValue] andPoint:newPoint];
                    if (distance >= 25.0f){
                        dirPoint = [points[i] CGPointValue];
                        break;
                    } else if (i == 0){
                        dirPoint = CGPointMake(avgX/points.count, avgY/points.count);
                    }
                }
            } else {
                dirPoint = [points[points.count-2] CGPointValue];
            }
            [self drawArrowHeadWithTip:newPoint usingPoint:dirPoint];
        }
    }
    //    }
}

- (float)distanceBetweenPoint:(CGPoint)point1 andPoint:(CGPoint)point2 {
    float x = point1.x - point2.x;
    float y = point1.y - point2.y;
    return sqrtf(x*x+y*y);
}

- (float)thetaForPoint:(CGPoint)point1 toPoint:(CGPoint)point2 {
    return atan2f(point2.x - point1.x,point1.y - point2.y);
}

- (float)cosForTheta:(float)theta {
    float cos = cosf(theta);
    if (theta > 0 && theta < M_PI_2) {
        cos = -cos;
    } else if (theta > M_PI && theta < 3*M_PI_2) {
        cos = -cos;
    }
    return cos;
}

- (float)sinForTheta:(float)theta {
    float sin = sinf(theta);
    if (theta > M_PI_2 && theta < M_PI) {
        sin = -sin;
    } else if (theta > 3*M_PI_2 && theta < 2*M_PI) {
        sin = -sin;
    }
    return sin;
}

- (void)drawArrowHeadWithTip:(CGPoint)tipPoint usingPoint:(CGPoint)dirPoint{
    float theta = [self thetaForPoint:tipPoint toPoint:dirPoint];
    float height = 25.0f;
    tipPoint = CGPointMake(tipPoint.x - 10*sinf(theta), tipPoint.y + 10*cosf(theta));
    CGPoint origin = CGPointMake(tipPoint.x + height*sinf(theta), tipPoint.y - height*cosf(theta));
    CGPoint left = CGPointMake(origin.x - height*cosf(theta+M_PI)/3, origin.y - height*sinf(theta+M_PI)/3);
    CGPoint right = CGPointMake(origin.x + height*cosf(theta+M_PI)/3, origin.y + height *sinf(theta+M_PI)/3);
    origin = CGPointMake(tipPoint.x + (height-2.0f)*sinf(theta), tipPoint.y - (height-2.0f)*cosf(theta));
    CGContextMoveToPoint(arrowTempContext, tipPoint.x, tipPoint.y);
    CGContextAddLineToPoint(arrowTempContext, left.x, left.y);
    CGContextAddLineToPoint(arrowTempContext, origin.x, origin.y);
    CGContextAddLineToPoint(arrowTempContext, right.x, right.y);
    CGContextAddLineToPoint(arrowTempContext, tipPoint.x, tipPoint.y);
    CGContextSetFillColorWithColor(arrowTempContext, [[UIColor colorWithRed:red green:green blue:blue alpha:1.0f] CGColor]);
    CGContextFillPath(arrowTempContext);
    CGRect renderFrame = CGRectMake(MIN(tipPoint.x, MIN(left.x,right.x)) - 5.0f, MIN(tipPoint.y, MIN(left.y,right.y)) - 5.0f, 60.0f, 60.0f);
    [self setNeedsDisplayInRect:CGRectUnion(renderFrame, lastArrowRect)];
    lastArrowRect = renderFrame;
}
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    //    if (self.isFocus) {
    //        CGImageRef tempImage = CGBitmapContextCreateImage(focusTempContext);
    //        CGContextDrawImage(context, self.bounds, tempImage);
    //        CGImageRelease(tempImage);
    //    } else {
    CGImageRef cacheImage = CGBitmapContextCreateImage(cacheContext);
    CGContextDrawImage(context, self.bounds, cacheImage);
    CGImageRelease(cacheImage);
    if (self.isStraight) {
        CGImageRef tempImage = CGBitmapContextCreateImage(straightTempContext);
        CGContextDrawImage(context, self.bounds, tempImage);
        CGImageRelease(tempImage);
    }
    if (self.isArrow) {
        CGImageRef arrowImage = CGBitmapContextCreateImage(arrowTempContext);
        CGContextDrawImage(context, self.bounds, arrowImage);
        CGImageRelease(arrowImage);
    }
    // }
    
    /* For debugging render area
     hue += 0.05;
     if (hue > 1.0)
     hue = 0.0;
     CGContextSetFillColorWithColor(context, [UIColor colorWithHue:hue saturation:0.7 brightness:1.0 alpha:0.3].CGColor);
     CGContextFillRect(context, self.bounds);
     */
}

- (void)setColourWithRed:(float)redt green:(float)greent blue:(float)bluet {
    red = redt;
    green = greent;
    blue = bluet;
}

- (void)clearTelestration {
    CGContextClearRect(cacheContext, self.bounds);
    [self.arrayOfUndos removeAllObjects];
    undoToEmptyIsPossible = YES;
    [self setNeedsDisplay];
    NSLog(@"clearTeleBlank");
    self.isBlank = YES;
    [self.tvController checkUndoState];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_POST_ON_EXTERNAL_SCREEN object:nil];
}

- (BOOL)saveTelestration {
    [self.arrayOfUndos removeAllObjects];
    UIGraphicsBeginImageContext(self.bounds.size);
    [self drawRect:self.bounds];
    self.teleImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_POST_ON_EXTERNAL_SCREEN object:nil];
    [self clearTelestration];
    if (self.teleImage) {
        return YES;
    } else {
        return NO;
    }
}

- (void)reassignUndoStates{
    [self recordToUndoContextWithTag:3];
    //   [self recordToUndoContextWithTag:2];
    //   [self recordToUndoContextWithTag:1];
}

- (void)undoStroke {
    //    if (!self.arrayOfUndos.count) {
    //        return;
    //    }
    didUndo = YES;
    //    [self replaceContextWithTag:0];
    //    [self replaceContextWithTag:1];
    //    [self replaceContextWithTag:2];
    //    undoContext3 = nil;
    
    if (self.tvController) {
        [self.tvController checkUndoState];
    }
    [self replaceContextWithTag: 1];
    [self setNeedsDisplay];
}

- (void)recordToUndoContextWithTag:(int)contextNum {
    CGImageRef cgImage;
    switch (contextNum) {
            //     case 1:
            //            if (!cacheContext) {
            //                return;
            //            }
            //            if (!undoContext1) {
            //                [self initContextWithTag:contextNum withSize:self.bounds.size];
            //            }
            //            CGContextClearRect(undoContext1, self.bounds);
            //            cgImage = CGBitmapContextCreateImage(cacheContext);
            //            CGContextDrawImage(undoContext1, self.bounds, cgImage);
            //            break;
            //      case 2:
            //            if (!undoContext1) {
            //                return;
            //            }
            //            if (!undoContext2) {
            //                [self initContextWithTag:contextNum withSize:self.bounds.size];
            //            }
            //            CGContextClearRect(undoContext2, self.bounds);
            //            cgImage = CGBitmapContextCreateImage(undoContext1);
            //            CGContextDrawImage(undoContext2, self.bounds, cgImage);
            //            break;
        case 3:{
            //            if (!undoContext2) {
            //                return;
            //            }
            //            if (!undoContext3) {
            //                [self initContextWithTag:contextNum withSize:self.bounds.size];
            //            } else {
            //                undoToEmptyIsPossible = NO; //Controls whether or not to display "Clear" instead of "Close"
            //            }
            //            CGContextClearRect(undoContext3, self.bounds);
            //            cgImage = CGBitmapContextCreateImage(undoContext2);
            //            CGContextDrawImage(undoContext3, self.bounds, cgImage);
            //            break;
            //            if (!self.arrayOfUndos.count) {
            //                return;
            //            }
            
            
            //            undoContext = (__bridge CGContextRef)([self.arrayOfUndos lastObject]);
            //            undoContext2 = (__bridge CGContextRef)(self.arrayOfUndos[self.arrayOfUndos.count -1]);
            //
            //            CGContextClearRect(undoContext, self.bounds);
            //            cgImage = CGBitmapContextCreateImage(undoContext2);
            //            CGContextDrawImage(undoContext, self.bounds, cgImage);
            CGSize size = self.bounds.size;
            
            int bitmapByteCount;
            int	bitmapBytesPerRow;
            
            // Declare the number of bytes per row. Each pixel in the bitmap in this
            // example is represented by 4 bytes; 8 bits each of red, green, blue, and
            // alpha.
            bitmapBytesPerRow = ((size.width) * 4);
            bitmapByteCount = (bitmapBytesPerRow * size.height);
            
            
            CGContextRef someUndoContext = CGBitmapContextCreate(NULL, size.width, size.height, 8, bitmapBytesPerRow, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
            
            cgImage = CGBitmapContextCreateImage(cacheContext);
            CGContextDrawImage(someUndoContext, self.bounds, cgImage);
            CGImageRelease(cgImage);
            [self.arrayOfUndos addObject: (__bridge id)(someUndoContext)];
        }
            break;
            
        default:
            break;
    }
    
}

- (void)replaceContextWithTag:(int)contextNum {
    switch (contextNum) {
        case 1:
            //            if (undoContext2) {
            //                CGContextClearRect(undoContext1, self.bounds);
            //                CGImageRef cacheImage = CGBitmapContextCreateImage(undoContext2);
            //                CGContextDrawImage(undoContext1, self.bounds, cacheImage);
            //                CGImageRelease(cacheImage);
            //                CGContextClearRect(undoContext2, self.bounds);
            //            } else {
            //                undoContext1 = nil;
            //            }
            //            break;
        case 2:
            //            if (undoContext3) {
            //                CGContextClearRect(undoContext2, self.bounds);
            //                CGImageRef cacheImage = CGBitmapContextCreateImage(undoContext3);
            //                CGContextDrawImage(undoContext2, self.bounds, cacheImage);
            //                CGImageRelease(cacheImage);
            //                CGContextClearRect(undoContext3, self.bounds);
            //            } else {
            //                undoContext2 = nil;
            //            }
            //            break;
        case 3:
            NSLog(@"Undo on telestration");
            CGContextRef someUndoContext = (__bridge CGContextRef)(self.arrayOfUndos[self.arrayOfUndos.count - 1]);
            
            CGContextClearRect(cacheContext, self.bounds);
            CGImageRef cacheImage = CGBitmapContextCreateImage(someUndoContext);
            CGContextDrawImage(cacheContext, self.bounds, cacheImage);
            CGImageRelease(cacheImage);
            [self.arrayOfUndos removeLastObject];
            [self.tvController checkUndoState];
            break;
        default:
            //            if (undoContext1) {
            //                CGContextClearRect(cacheContext, self.bounds);
            //                CGImageRef cacheImage = CGBitmapContextCreateImage(undoContext1);
            //                CGContextDrawImage(cacheContext, self.bounds, cacheImage);
            //                CGImageRelease(cacheImage);
            //                CGContextClearRect(undoContext1, self.bounds);
            //            }
            break;
    }
    
    
}

- (void) didReceiveMemoryWarning{
    [self.arrayOfUndos removeAllObjects];
}

@end
