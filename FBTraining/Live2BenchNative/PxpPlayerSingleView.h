//
//  PxpPlayerSingleView.h
//  PxpPlayer
//
//  Created by Nico Cvitak on 2015-06-10.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "PxpPlayerView.h"

/**
 * @breif A view capable of displaying the contents of a single PxpPlayer object.
 * @author Nicholas Cvitak
 */
@interface PxpPlayerSingleView : PxpPlayerView

/// The current size and position of the video image as displayed within the receiver's bounds. (read-only)
@property (readonly, nonatomic) CGRect videoRect;

/// Specifies how the video is displayed within a player layer’s bounds.
@property (copy, nonatomic, nonnull) NSString *videoGravity;

/// Specifies whether or not the view displays the player's name.
@property (assign, nonatomic) BOOL showsName;

/// Specifies whether or not the view displays the zoom level.
@property (assign, nonatomic) BOOL showsZoomLevel;

/// The zoom level of the player.
@property (readonly, assign, nonatomic) CGFloat zoomLevel;

/// Specifies whether or not zoom is enabled.
@property (assign, nonatomic) BOOL zoomEnabled;

@end
