//
//  PxpClipContext.h
//  PxpPlayer
//
//  Created by Nico Cvitak on 2015-07-02.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import "PxpPlayer.h"

@class Clip;

/**
 * @breif A player context used to present a Clip.
 * @author Nicholas Cvitak
 */
@interface PxpClipContext : PxpPlayerContext

/// The Clip to be presented.
@property (strong, nonatomic, nullable) Clip *clip;

/// Creates a new context with a clip.
+ (nonnull instancetype)contextWithClip:(nullable Clip *)clip;

/// Initializes a context with a clip.
- (nonnull instancetype)initWithClip:(nullable Clip *)clip;

@end
