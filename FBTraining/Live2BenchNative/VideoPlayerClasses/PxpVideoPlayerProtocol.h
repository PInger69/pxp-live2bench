//
//  PxpVideoPlayerProtocol.h
//  Live2BenchNative
//
//  Created by dev on 2015-02-04.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "PxpVideoPlayerProtocol.h"
#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVPlayerItem.h>

#import "Feed.h"


#import "VideoControlBarSlider.h"
#import "ClipControlBarSlider.h"
#import "RJLVideoPlayerPlaybackView.h"
#import "LiveLight.h"

#import "PxpTimeProvider.h"

typedef NS_OPTIONS (NSInteger,PlayerStatus){
    RJLPS_Offline      = 0,
    RJLPS_Live         = 1<<0,
    RJLPS_Play         = 1<<1,
    RJLPS_Stop         = 1<<2,
    RJLPS_Paused       = 1<<3,
    RJLPS_Seeking      = 1<<4,
    RJLPS_Scrubbing    = 1<<5,
    RJLPS_Slomo        = 1<<6,
    RJLPS_Error        = 1<<7,
    RJLPS_Mute         = 1<<8,
    RJLPS_Thawing      = 1<<9,
    RJLPS_Looping      = 1<<10
};

#define PLAYER_WILL_RESET   @"playerWillReset"
#define PLAYER_DID_RESET    @"playerDidReset"


@protocol PxpVideoPlayerProtocol <NSObject, PxpTimeProvider>


@property (nonatomic,strong)    NSString                    * playerContext;          //let you tell the difference between other active video players
@property (readwrite, strong, setter=setPlayer:, getter=player)	AVPlayer                    * avPlayer;
@property (nonatomic,strong)	AVPlayerItem                * playerItem;
@property (nonatomic,strong)	RJLVideoPlayerPlaybackView  * playBackView;      //layer for avplayer to display video images
@property (nonatomic,strong)    Feed                        * feed;
@property (nonatomic,assign)    PlayerStatus                status;             // use bitwise to find the status
@property (nonatomic,assign)    BOOL                        looping;
@property (nonatomic,assign)    BOOL                        slowmo;
@property (nonatomic,assign)    BOOL                        mute;
@property (nonatomic,assign)    BOOL                        live;
@property (nonatomic,assign)    CMTimeRange                 range;
@property (nonatomic,strong)    LiveLight                   * liveIndicatorLight;
@property (nonatomic,strong)    VideoControlBarSlider       * videoControlBar;
@property (nonatomic,strong)     ClipControlBarSlider       * clipControlBar;
@property (nonatomic,copy)      NSURL                       *URL;

@property (nonatomic,assign)    BOOL                isAlive;

-(instancetype)initWithFrame:(CGRect)frame;

-(void)gotolive;
-(void)play;
-(void)pause;
-(void)clear;
-(void)seekToInSec:(float)seekTime;
-(void)seekBy: (float)secValue;
-(void)seekWithSeekerButton:(id)sender;
-(void)playFeed:(Feed*)aFeed;
-(void)playFeed:(Feed*)aFeed withRange:(CMTimeRange)aRange;
-(void)playClipWithFeed: (Feed*)aFeed andTimeRange:(CMTimeRange)aRange;
-(Float64)durationInSeconds;
-(Float64)currentTimeInSeconds;

@end
