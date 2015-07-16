//
//  PxpTelestrationPoint.h
//  PxpTelestration
//
//  Created by Nico Cvitak on 2015-07-08.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import <UIKit/UIKit.h>

struct PxpTelestrationPointData {
    Float64 time;
    struct {
        UInt32 x, y;
    } position;
};

/*!
 * @breif An object used to represent a draw point in a telestration, along with the time that it should be presented.
 * @author Nicholas Cvitak
 */
@interface PxpTelestrationPoint : NSObject<NSCoding, NSCopying>

/// The time that the point should be displayed in an animation.
@property (readonly, assign, nonatomic) NSTimeInterval displayTime;

/// The normalized position of the point.
@property (readonly, assign, nonatomic) CGPoint position;

/// The data structure representation of the point;
@property (readonly, assign, nonatomic) struct PxpTelestrationPointData pointData;

/// Initializes a point with it's C data structure.
- (nonnull instancetype)initWithPointData:(struct PxpTelestrationPointData)pointData;

/// Initializes a point with a position and display time.
- (nonnull instancetype)initWithPosition:(CGPoint)position displayTime:(NSTimeInterval)displayTime;

/// Initializes a point from a coder.
- (nonnull instancetype)initWithCoder:(nonnull NSCoder *)aDecoder;

@end
