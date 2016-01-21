//
//  RicoZoomContainer.h
//  Live2BenchNative
//
//  Created by dev on 2015-12-03.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RicoZoomContainer : UIScrollView

@property (readonly, nonatomic) CGRect videoRect;

/// Specifies how the video is displayed within a player layer’s bounds.
@property (copy, nonatomic, nonnull) NSString *videoGravity;

/// Specifies whether or not the view displays the zoom level.
@property (assign, nonatomic) BOOL showsZoomLevel;

/// The zoom level of the player.
@property (readonly, assign, nonatomic) CGFloat zoomLevel;

/// Specifies whether or not zoom is enabled.
@property (assign, nonatomic) BOOL zoomEnabled;


@property (strong, nonatomic, nonnull) UIView *view;

-(void)addToContainer:( UIView*_Nonnull)view;


@end
