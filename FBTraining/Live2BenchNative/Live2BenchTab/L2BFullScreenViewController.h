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

#import "FullScreenViewController.h"
#import "VideoPlayer.h"
#import "Slomo.h"
#import "SeekButton.h"
#import "CustomButton.h"
#import "LiveButton.h"
#import "BorderButton.h"

@interface L2BFullScreenViewController : FullScreenViewController




@property (nonatomic,assign) int    mode;


@property (weak,  nonatomic) VideoPlayer   * player;
@property (strong,nonatomic) SeekButton    * seekForward;
@property (strong,nonatomic) SeekButton    * seekBackward;
@property (strong,nonatomic) Slomo         * slomo;
@property (strong,nonatomic) CustomButton  * teleButton;
@property (strong,nonatomic) LiveButton    * liveButton;
@property (strong,nonatomic) NSString      * context;
@property (assign,nonatomic) BOOL          enable;
@property (strong,nonatomic) UILabel       * tagEventName;
@property (strong,nonatomic) BorderButton  * continuePlay;

@end
