//
//  RicoFullScreenControlBar.h
//  Live2BenchNative
//
//  Created by dev on 2016-02-08.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SeekButton.h"
#import "PxpBorderButton.h"
#import "Slomo.h"
#import "PxpFullscreenButton.h"
#import "PxpFullscreenResponder.h"
#import "RicoPlayerViewController.h"
#import "RicoPlayerControlBar.h"
#import "PxpRangeModifierButton.h"
#import "PxpBorderLabel.h"
#import "LiveButton.h"
#import "PxpBorderButton.h"


typedef NS_OPTIONS (NSInteger,RicoFullScreenModes){
    
    RicoFullScreenModeDisable,
    RicoFullScreenModeLive,
    RicoFullScreenModeClip,
    RicoFullScreenModeBookmark,
    RicoFullScreenModeTeleStill,
    RicoFullScreenModeTeleAnimated,
    RicoFullScreenModeDemo,
    RicoFullScreenModeList,
    RicoFullScreenModeListNonTag,
    RicoFullScreenModeEvent
};


@interface RicoFullScreenControlBar : UIView
/// The backward seek button.

@property (nonatomic,assign) RicoFullScreenModes  mode;


@property (readonly, strong, nonatomic, nonnull) SeekButton *backwardSeekButton;

/// The forward seek button.
@property (readonly, strong, nonatomic, nonnull) SeekButton *forwardSeekButton;

/// The slomo button.
@property (readonly, strong, nonatomic, nonnull) Slomo *slomoButton;

/// The fullscreen button.
@property (readonly, strong, nonatomic, nonnull) PxpFullscreenButton *fullscreenButton;


@property (strong,nonatomic, nonnull) RicoPlayerControlBar  * controlBar;

@property (readonly, strong, nonatomic, nonnull) LiveButton *liveButton;
@property (readonly, strong, nonatomic, nonnull) PxpRangeModifierButton *startRangeModifierButton;
@property (readonly, strong, nonatomic, nonnull) PxpRangeModifierButton *endRangeModifierButton;
@property (readonly, strong, nonatomic, nonnull) PxpBorderLabel *currentTagLabel;
@property (readonly, strong, nonatomic, nonnull) PxpBorderButton *previousTagButton;
@property (readonly, strong, nonatomic, nonnull) PxpBorderButton *nextTagButton;





@end
