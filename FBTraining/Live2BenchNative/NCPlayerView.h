//
//  NCPlayerView.h
//  iOS Workspace
//
//  Created by Nico Cvitak on 2015-05-26.
//  Copyright (c) 2015 Nicholas Cvitak. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NCPlayer.h"

@interface NCPlayerView : UIView

@property (assign, nonatomic) UIBlurEffectStyle effectStyle;
@property (strong, nonatomic, nullable) NCPlayer *player;
@property (readonly, nonatomic, nonnull) AVPlayerLayer *layer;
@property (nonatomic) BOOL showsControlBar;
@property (assign, nonatomic) BOOL enabled;

@end
