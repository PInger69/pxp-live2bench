//
//  RicoBookmarkPlayerController.h
//  Live2BenchNative
//
//  Created by dev on 2016-05-17.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Clip.h"
#import "RicoPlayer.h"
#import "RicoPlayerControlBar.h"
#import "RicoPlayerViewController.h"
#import "RicoZoomContainer.h"

#import "RicoBaseFullScreenViewController.h"
#import "RicoFullScreenControlBar.h"
#import "RicoPlayerGroupContainer.h"

#define BOOKMARK_PLAYER_CONTROLLER_CHANGE @"BOOKMARK_PLAYER_CONTROLLER_CHANGE"


@interface RicoBookmarkPlayerController : NSObject

@property (strong, nonatomic, nonnull) RicoBaseFullScreenViewController *fullscreenViewController;
@property (strong, nonatomic) RicoPlayerViewController    * ricoPlayerController;


@property (nonatomic,strong) UIView * view;
- (instancetype _Nonnull)initWithFrame:(CGRect)frame;
-(void)playClip:( Clip* _Nonnull )clip;
-(void)clear;


@end
