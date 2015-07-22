//
//  PxpTelestration.h
//  PxpTelestration
//
//  Created by Nico Cvitak on 2015-07-08.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PxpTelestrationAction.h"

/*!
 * @breif An object used to contain a single telestration.
 * @author Nicholas Cvitak
 */
@interface PxpTelestration : NSObject<NSCoding>

/// The size of the telestration. (read-only)
@property (readonly, assign, nonatomic) CGSize size;

/// The actions pushed onto the telestration. (read-only)
@property (readonly, strong, nonatomic, nonnull) NSArray *actionStack;

/// The string data representation of the telestration. (read-only).
@property (readonly, strong, nonatomic, nonnull) NSString *data;

/// The time where the first action takes place.
@property (readonly, assign, nonatomic) NSTimeInterval startTime;

/// The amount of time between the first draw point, and last draw point in the telestration.
@property (readonly, assign, nonatomic) NSTimeInterval duration;

/// The time that is represented by the thumbnail.
@property (readonly, assign, nonatomic) NSTimeInterval thumbnailTime;

/// The thumbnail image of the telestration.
@property (readonly, strong, nonatomic, nonnull) UIImage *thumbnail;

/// Creates a telestration from a string data representation.
+ (nonnull instancetype)telestrationFromData:(nonnull NSString *)data;

/// Initializes a telestration with a specified size.
- (nonnull instancetype)initWithSize:(CGSize)size;

/// Initializes a telestration with a specified size, and actions.
- (nonnull instancetype)initWithSize:(CGSize)size actions:(nonnull NSArray *)actions;

/// Initializes a telestration with a decoder.
- (nonnull instancetype)initWithCoder:(nonnull NSCoder *)aDecoder;

/// Pushes an action on to the telestration's action stack.
- (void)pushAction:(nonnull PxpTelestrationAction *)action;

/// Pops an action off of the telestration's action stack.
- (nullable PxpTelestrationAction *)popAction;

/// Returns the actions in the action stack that take place before the given time.
- (nonnull NSArray *)actionStackForTime:(NSTimeInterval)time;

@end
