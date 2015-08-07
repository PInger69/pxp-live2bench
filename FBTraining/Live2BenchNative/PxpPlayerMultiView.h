//
//  PxpPlayerMultiView.h
//  PxpPlayer
//
//  Created by Nico Cvitak on 2015-06-29.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxpPlayer.h"
#import "PxpPlayerGridView.h"
#import "PxpPlayerPipCompanionView.h"

/**
 * @breif The standard view for viewing multiple sources in the player's context using a grid view and a companion view.
 * @author Nicholas Cvitak
 */
@interface PxpPlayerMultiView : PxpPlayerView

@property (readonly, strong, nonatomic, nonnull) PxpPlayerGridView *gridView;
@property (readonly, nonatomic, nonnull) PxpPlayerPipCompanionView *companionView;

@end
