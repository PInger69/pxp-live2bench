//
//  PxpTimeProvider.h
//  PxpTelestration
//
//  Created by Nico Cvitak on 2015-07-15.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * @breif A protocol for any object that has a time associated with it.
 * @author Nicholas Cvitak
 */
@protocol PxpTimeProvider

/// The currentTime of the object in seconds. (read-only)
@property (readonly, assign, nonatomic) NSTimeInterval currentTime;

@end
