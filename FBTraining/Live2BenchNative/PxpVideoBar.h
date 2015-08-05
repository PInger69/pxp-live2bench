//
//  PxpVideoBar.h
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-07-29.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "PxpPlayer.h"
#import "SeekButton.h"
#import "Slomo.h"
#import "PxpFullscreenButton.h"
#import "Event.h"

IB_DESIGNABLE
@interface PxpVideoBar : UIView

@property (weak, nonatomic, nullable) PxpPlayer *player;
@property (weak, nonatomic, nullable) Event *event;

@property (strong, nonatomic, nullable) Tag *selectedTag;

@property (readonly, strong, nonatomic, nonnull) SeekButton *backwardSeekButton;
@property (readonly, strong, nonatomic, nonnull) SeekButton *forwardSeekButton;

@property (readonly, strong, nonatomic, nonnull) Slomo *slomoButton;
@property (readonly, strong, nonatomic, nonnull) PxpFullscreenButton *fullscreenButton;

@end
