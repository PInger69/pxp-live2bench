//
//  PxpTelestrationPoint.h
//  PxpTelestration
//
//  Created by Nico Cvitak on 2015-07-08.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxpTelestrationInterchangeFormat.h"

/*!
 * @breif An object used to represent a draw point in a telestration, along with the time that it should be presented.
 * @author Nicholas Cvitak
 */
@interface PxpTelestrationPoint : NSObject<NSCoding, NSCopying>
{
    @public
    PXPTIFPoint _pointData;
}

/// The time that the point should be displayed in an animation. (read-only)
@property (readonly, assign, nonatomic) NSTimeInterval displayTime;

/// The normalized position of the point. (read-only)
@property (readonly, assign, nonatomic) CGPoint position;

/// The data structure representation of the point. (read-only)
@property (readonly, assign, nonatomic) PXPTIFPoint pointData;

/// Initializes a point with it's C data structure.
- (nonnull instancetype)initWithPointData:(PXPTIFPoint)pointData;

/// Initializes a point with a position and display time.
- (nonnull instancetype)initWithPosition:(CGPoint)position displayTime:(NSTimeInterval)displayTime;

/// Initializes a point from a decoder.
- (nonnull instancetype)initWithCoder:(nonnull NSCoder *)aDecoder;

@end
