//
//  PxpEventContext.h
//  PxpPlayer
//
//  Created by Nico Cvitak on 2015-06-29.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import "PxpPlayer.h"

@class Event;

/**
 * @breif A player context used to present an Event.
 * @author Nicholas Cvitak
 */
@interface PxpEventContext : PxpPlayerContext

/// The event to be presented.
@property (strong, nonatomic, nullable) Event *event;

/// Creates a new context with an Event.
+ (nonnull instancetype)contextWithEvent:(nullable Event *)event;

/// Initializes a context with an Event.
- (nonnull instancetype)initWithEvent:(nullable Event *)event;

@end
