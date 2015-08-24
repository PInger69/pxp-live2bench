//
//  PxpTelestrationAction.h
//  PxpTelestration
//
//  Created by Nico Cvitak on 2015-07-08.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxpTelestrationPoint.h"

/*!
 * @breif The C data structure used to store an action in a binary format.
 * @author Nicholas Cvitak
 */
struct PxpTelestrationActionData {
    struct {
        UInt8 r, g, b, a;
    } color;
    Float32 width;
    UInt32 type;
    UInt32 n_points;
    struct PXPTIFPoint points[]; // defined when allocating
};

/*!
 * @breif The bitmask representing type information of a telestration action.
 * @author Nicholas Cvitak
 */
typedef enum : UInt32 {
    PxpClear = 0,
    PxpDraw = 0x1 << 0,
    PxpLine = 0x1 << 1,
    PxpArrow = 0x1 << 2,
    
} PxpTelestrationActionType;

/*!
 * @breif An object used to contain a single draw action in a telestration.
 * @author Nicholas Cvitak
 */
@interface PxpTelestrationAction : NSObject<NSCoding, NSCopying>

/// The stroke color of the action.
@property (copy, nonatomic, nonnull) UIColor *strokeColor;

/// The stroke width of the action.
@property (assign, nonatomic) CGFloat strokeWidth;

/// The action's type.
@property (assign, nonatomic) PxpTelestrationActionType type;

/// The telestration points drawn by the action sorted by their displayTime. (read-only).
@property (readonly, strong, nonatomic, nonnull) NSArray *points;

/// The displayTime of the action. (read-only).
@property (readonly, assign, nonatomic) NSTimeInterval displayTime;

/// The sort method on the points.
+ (nonnull NSComparator)sortMethod;

/// Initializes a telestration action from a coder.
- (nonnull instancetype)initWithCoder:(nonnull NSCoder *)aDecoder;

/// Creates a new clear action.
+ (nonnull instancetype)clearActionAtTime:(NSTimeInterval)time;

/// Adds a telestration point into the action's sorted array.
- (void)addPoint:(nonnull PxpTelestrationPoint *)point;

/// Adds multiple telestration points into the action's sorted array.
- (void)addPoints:(nonnull NSArray *)points;

/// Removes a telestration point from the action's sorted array.
- (void)removePoint:(nonnull PxpTelestrationPoint *)point;

/// Removes multiple telestration points from the action's sorted array.
- (void)removePoints:(nonnull NSArray *)points;

/// Removes all telestration points from the action's sorted array.
- (void)removeAllPoints;

/// Returns YES if the action contains the point.
- (BOOL)containsPoint:(nonnull PxpTelestrationPoint *)point;

@end
