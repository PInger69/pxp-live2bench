//
//  L2BFullScreenViewController.h
//  Live2BenchNative
//
//  Created by dev on 2014-12-17.
//  Copyright (c) 2014 DEV. All rights reserved.
//


#define L2B_FULLSCREEN_MODE_DISABLE  0
#define L2B_FULLSCREEN_MODE_LIVE     1
#define L2B_FULLSCREEN_MODE_CLIP     2
#define L2B_FULLSCREEN_MODE_TELE     3
#define L2B_FULLSCREEN_MODE_DEMO     4
#define L2B_FULLSCREEN_MODE_EVENT    5

#import "FullScreenViewController.h"
#import "TeleViewController.h"
#import "Slomo.h"
#import "SeekButton.h"
#import "CustomButton.h"
#import "LiveButton.h"
#import "BorderButton.h"

#import "PxpVideoPlayerProtocol.h"

@interface L2BFullScreenViewController : FullScreenViewController




@property (nonatomic,assign) int                mode;



@property (strong,nonatomic) SeekButton         * seekForward;
@property (strong,nonatomic) SeekButton         * seekBackward;
@property (strong,nonatomic) Slomo              * slomo;
@property (strong,nonatomic) CustomButton       * teleButton;
@property (strong,nonatomic) LiveButton         * liveButton;
@property (strong,nonatomic) UILabel            * tagEventName;
@property (strong,nonatomic) BorderButton       * continuePlay;
@property (strong,nonatomic) CustomButton       * startRangeModifierButton;         //extends duration button (old start time - 5)
@property (strong,nonatomic) CustomButton       * endRangeModifierButton;           //extends duration button (old end time + 5)

@property (strong,nonatomic) BorderButton       * saveTeleButton;
@property (strong,nonatomic) BorderButton       * clearTeleButton;
@property (strong,nonatomic) TeleViewController * teleViewController;
@end
