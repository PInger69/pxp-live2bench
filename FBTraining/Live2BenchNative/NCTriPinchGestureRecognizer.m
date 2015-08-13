//
//  NCTriPinchGestureRecognizer.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-05.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "NCTriPinchGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

// computes the center of triangle abc
static CGPoint _centerTriangle(const CGPoint a, const CGPoint b, const CGPoint c)
{
    return CGPointMake((a.x + b.x + c.x) / 3.0, (a.y + b.y + c.y) / 3.0);
}

// computes the distance between two points a and b
static CGFloat _distance(const CGPoint a, const CGPoint b)
{
    return sqrt((b.x - a.x) * (b.x - a.x) + (b.y - a.y) * (b.y - a.y));
}

// computes the maximum distance between points triangle's bounds
static CGFloat _maxDistanceTriangle(const CGPoint a, const CGPoint b, const CGPoint c)
{
    const CGPoint o = _centerTriangle(a, b, c);
    const CGFloat oa = _distance(o, a), ob = _distance(o, b), oc = _distance(o, c);

    return 2.0 * MAX(MAX(oa, ob), oc);
}

static CGFloat _sign(CGFloat n) {
    return n > 0.0 ? +1.0 : n < 0.0 ? -1.0 : 0.0;
}

@interface NCTriPinchGestureRecognizer ()

@property (readwrite, assign, nonatomic) CGFloat scale;
@property (readwrite, assign, nonatomic) CGFloat velocity;

@end

@implementation NCTriPinchGestureRecognizer
{
    CGFloat _initialDistance;
    CGFloat _previousDistance;
    NSDate * __nullable _previousDate;
}

#pragma mark - Overrides

- (void)reset {
    [super reset];
    
    self.scale = 1.0;
    self.velocity = 0.0;
    
    _initialDistance = 0.0;
    _previousDistance = 0.0;
    _previousDate = nil;
}

- (void)touchesBegan:(nonnull NSSet *)touches withEvent:(nonnull UIEvent *)event {
    NSSet *gestureTouches = [event touchesForGestureRecognizer:self];
    
    if (gestureTouches.count > 3) {
        self.state = UIGestureRecognizerStateFailed;
    } else if (gestureTouches.count == 3) {
        self.scale = 1.0;
        self.velocity = 0.0;
        
        _initialDistance = [self maxDistanceBetweenTouches:gestureTouches];
        _previousDistance = _initialDistance;
        _previousDate = [NSDate date];
        
        self.state = UIGestureRecognizerStateBegan;
    }
}

- (void)touchesMoved:(nonnull NSSet *)touches withEvent:(nonnull UIEvent *)event {
    NSSet *gestureTouches = [event touchesForGestureRecognizer:self];
    if (gestureTouches.count == 3) {
        if (self.state == UIGestureRecognizerStatePossible) {
            
            self.scale = 1.0;
            self.velocity = 0.0;
            
            _initialDistance = [self maxDistanceBetweenTouches:gestureTouches];
            _previousDistance = _initialDistance;
            _previousDate = [NSDate date];
            
            self.state = UIGestureRecognizerStateBegan;
            
        } else {
            
            CGFloat currentDistance = [self maxDistanceBetweenTouches:gestureTouches];
            NSDate *currentDate = [NSDate date];
            
            const CGFloat ds = currentDistance - _previousDistance;
            const NSTimeInterval dt = [currentDate timeIntervalSinceDate:_previousDate];
            
            
            self.scale = currentDistance / _initialDistance;
            self.velocity = ds / dt;
            
            _previousDistance = currentDistance;
            _previousDate = currentDate;
            
            self.state = UIGestureRecognizerStateChanged;
            
        }
    } else if (self.state != UIGestureRecognizerStatePossible) {
        self.state = UIGestureRecognizerStateFailed;
    }
}

- (void)touchesEnded:(nonnull NSSet *)touches withEvent:(nonnull UIEvent *)event {
    NSSet *gestureTouches = [event touchesForGestureRecognizer:self];
    
    CGFloat currentDistance = [self maxDistanceBetweenTouches:gestureTouches];
    NSDate *currentDate = [NSDate date];
    
    const CGFloat ds = currentDistance - _previousDistance;
    const NSTimeInterval dt = [currentDate timeIntervalSinceDate:_previousDate];
    
    self.scale = currentDistance / _initialDistance;
    self.velocity = ds / dt;
    
    _previousDistance = currentDistance;
    _previousDate = currentDate;
    
    self.state = UIGestureRecognizerStateEnded;
}

- (void)touchesCancelled:(nonnull NSSet *)touches withEvent:(nonnull UIEvent *)event {
    self.state = UIGestureRecognizerStateCancelled;
}

- (CGFloat)maxDistanceBetweenTouches:(nonnull NSSet *)touches {
    NSArray *allTouches = touches.allObjects;
    
    return allTouches.count >= 3 ? _maxDistanceTriangle([allTouches[0] locationInView:self.view], [allTouches[1] locationInView:self.view], [allTouches[2] locationInView:self.view]) : 0.0;
    
}

- (BOOL)canPreventGestureRecognizer:(nonnull UIGestureRecognizer *)preventedGestureRecognizer {
    return NO;
}

@end
