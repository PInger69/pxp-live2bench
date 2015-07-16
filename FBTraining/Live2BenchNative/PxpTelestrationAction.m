//
//  PxpTelestrationAction.m
//  PxpTelestration
//
//  Created by Nico Cvitak on 2015-07-08.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import "PxpTelestrationAction.h"



static __nonnull NSComparator _pxpTelestrationActionSortMethod;

@implementation PxpTelestrationAction
{
    __nonnull NSMutableArray *_points;
}

@synthesize points = _points;

+ (void)initialize {
    _pxpTelestrationActionSortMethod = ^(PxpTelestrationPoint *a, PxpTelestrationPoint *b) {
        NSTimeInterval interval = a.displayTime - b.displayTime;
        
        return interval < 0.0 ? NSOrderedAscending : interval > 0.0 ? NSOrderedDescending : NSOrderedAscending;
    };
}

+ (nonnull NSComparator)sortMethod {
    return _pxpTelestrationActionSortMethod;
}

+ (nonnull instancetype)clearActionAtTime:(NSTimeInterval)time {
    PxpTelestrationAction *action = [[self alloc] init];
    action.type = PxpClear;
    [action addPoint:[[PxpTelestrationPoint alloc] initWithPosition:CGPointZero displayTime:time]];
    return action;
}

- (nonnull instancetype)init {
    self = [super init];
    if (self) {
        CGFloat r = drand48(), g = drand48(), b = drand48();
        _strokeColor = [UIColor colorWithRed:r green:g blue:b alpha:1.0];
        _strokeWidth = 1.0;
        _type = 0;
        _points = [NSMutableArray array];
    }
    return self;
}

- (nonnull instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        NSUInteger len;
        struct PxpTelestrationActionData *data = [aDecoder decodeBytesWithReturnedLength:&len];
        
        if (len >= sizeof(struct PxpTelestrationActionData)) {
            CGFloat r = data->color.r / 255.0, g = data->color.g / 255.0, b = data->color.b / 255.0, a = data->color.a / 255.0;
            NSUInteger n_points = 0;//data->n_points;
            
            _strokeColor = [UIColor colorWithRed:r green:g blue:b alpha:a];
            _strokeWidth = (CGFloat) data->width;
            _type = (PxpTelestrationActionType) data->type;
            
            
            _points = [NSMutableArray arrayWithCapacity:n_points];
            
            for (NSUInteger i = 0; i < n_points; i++) {
                struct PxpTelestrationPointData point_data = data->points[i];
                [_points addObject:[[PxpTelestrationPoint alloc] initWithPointData:point_data]];
            }
            
        } else {
            _strokeColor = [UIColor redColor];
            _strokeWidth = 1.0;
            _type = 0;
            _points = [NSMutableArray array];
        }
    }
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    
    CGFloat r, g, b, a;
    [self.strokeColor getRed:&r green:&g blue:&b alpha:&a];
    
    NSUInteger size = sizeof(struct PxpTelestrationActionData) + self.points.count * sizeof(struct PxpTelestrationPointData);
    struct PxpTelestrationActionData *data = malloc(size);
    
    data->color.r = (UInt8) round(255.0 * r);
    data->color.g = (UInt8) round(255.0 * g);
    data->color.b = (UInt8) round(255.0 * b);
    data->color.a = (UInt8) round(255.0 * a);
    
    data->width = (Float32) self.strokeWidth;
    
    data->type = (UInt32) self.type;
    
    data->n_points = (UInt32) self.points.count;
    
    for (NSUInteger i = 0; i < self.points.count; i++) {
        data->points[i] = [self.points[i] pointData];
    }
    
    [aCoder encodeBytes:data length:size];
    
    free(data);
}

- (nonnull NSString *)description {
    NSMutableString *desc = [NSMutableString string];
    [desc appendFormat:@"%@: {\n", [super description]];
    [desc appendFormat:@"color: %@\n", self.strokeColor];
    [desc appendFormat:@"width: %f\n", self.strokeWidth];
    [desc appendFormat:@"points: %@\n", self.points];
    [desc appendFormat:@"}"];
    
    return desc;
}

- (nonnull instancetype)copyWithZone:(nullable NSZone *)zone {
    PxpTelestrationAction *action = [[PxpTelestrationAction allocWithZone:zone] init];
    action->_strokeColor = _strokeColor;
    action->_strokeWidth = _strokeWidth;
    action->_points = _points;
    
    return action;
}

- (BOOL)isEqual:(id)object {
    PxpTelestrationAction *action = object;
    
    return [action isKindOfClass:[PxpTelestrationAction class]] && [self.strokeColor isEqual:action.strokeColor] && self.strokeWidth == action.strokeWidth && [self.points isEqual:action.points];
}

- (NSTimeInterval)displayTime {
    return self.points.firstObject ? [self.points.firstObject displayTime] : -INFINITY;
}

- (void)addPoint:(nonnull PxpTelestrationPoint *)point {
    NSUInteger i = [self.points indexOfObject:point inSortedRange:NSMakeRange(0, self.points.count) options:NSBinarySearchingInsertionIndex usingComparator:_pxpTelestrationActionSortMethod];
    
    // only insert if the point does not already exists
    if (i == self.points.count || ![self.points[i] isEqual:point]) {
        [_points insertObject:point atIndex:i];
    }
}

- (void)addPoints:(nonnull NSArray *)points {
    for (PxpTelestrationPoint *point in points) {
        [self addPoint:point];
    }
}

- (void)removePoint:(nonnull PxpTelestrationPoint *)point {
    NSUInteger i = [self.points indexOfObject:point inSortedRange:NSMakeRange(0, self.points.count) options:NSBinarySearchingInsertionIndex usingComparator:_pxpTelestrationActionSortMethod];
    
    // only remove if the point already exists
    if (i < self.points.count && [self.points[i] isEqual:point]) {
        [_points removeObjectAtIndex:i];
    }
}

- (void)removePoints:(nonnull NSArray *)points {
    for (PxpTelestrationPoint *point in points) {
        [self removePoint:point];
    }
}

- (void)removeAllPoints {
    [_points removeAllObjects];
}

- (BOOL)containsPoint:(nonnull PxpTelestrationPoint *)point {
    NSUInteger i = [self.points indexOfObject:point inSortedRange:NSMakeRange(0, self.points.count) options:NSBinarySearchingInsertionIndex usingComparator:_pxpTelestrationActionSortMethod];
    
    return i > 0 && i <= self.points.count && [self.points[i - 1] isEqual:point];
}

@end
