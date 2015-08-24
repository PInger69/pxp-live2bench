//
//  PxpTelestrationPoint.m
//  PxpTelestration
//
//  Created by Nico Cvitak on 2015-07-08.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import "PxpTelestrationPoint.h"

@implementation PxpTelestrationPoint

@synthesize pointData = _pointData;

- (nonnull instancetype)initWithPointData:(PXPTIFPoint)pointData {
    self = [super init];
    if (self) {
        _pointData = pointData;
    }
    return self;
}

- (nonnull instancetype)initWithPosition:(CGPoint)position displayTime:(NSTimeInterval)displayTime {
    PXPTIFPoint data = {
        .time = displayTime,
        .position = {
            .x = position.x,
            .y = position.y,
        },
    };
    return [self initWithPointData:data];
}

- (nonnull instancetype)init {
    return [self initWithPosition:CGPointZero displayTime:0.0];
}

- (nonnull instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        NSUInteger len;
        PXPTIFPoint *data = [aDecoder decodeBytesWithReturnedLength:&len];
        
        if (len >= sizeof(PXPTIFPoint)) {
            _pointData = *data;
        } else {
            _pointData.time = 0.0;
            _pointData.position.x = 0;
            _pointData.position.y = 0;
        }
        
        free(data);
    }
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeBytes:&_pointData length:sizeof(PXPTIFPoint)];
}

- (nonnull instancetype)copyWithZone:(nullable NSZone *)zone {
    return [[PxpTelestrationPoint allocWithZone:zone] initWithPointData:self.pointData];
}

- (BOOL)isEqual:(id)object {
    PxpTelestrationPoint *point = (PxpTelestrationPoint *)object;
    return [object isKindOfClass:[PxpTelestrationPoint class]] && self.displayTime == point.displayTime && CGPointEqualToPoint(self.position, point.position);
}

- (nonnull NSString *)description {
    return [NSString stringWithFormat:@"(%g, %g) @ %g", self.position.x, self.position.y, self.displayTime];
}

- (NSTimeInterval)displayTime {
    return self.pointData.time;
}

- (CGPoint)position {
    return CGPointMake(self.pointData.position.x, self.pointData.position.y);
}

@end
