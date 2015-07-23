//
//  RJLVideoPlayer.h
//  Live2BenchNative
//
//  Created by dev on 2015-01-28.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVPlayerItem.h>

#import "Feed.h"
#import "LiveLight.h"
#import "VideoControlBarSlider.h"
#import "RJLVideoPlayerPlaybackView.h"
#import "PxpVideoPlayerProtocol.h"
#import "VideoZoomManager.h"
#import "ClipControlBarSlider.h"


#define PLAYER_TICK @"tick"


//typedef NS_OPTIONS (NSInteger,PlayerStatus){
//    RJLPS_Offline      = 0,
//    RJLPS_Live         = 1<<0,
//    RJLPS_Play         = 1<<1,
//    RJLPS_Stop         = 1<<2,
//    RJLPS_Paused       = 1<<3,
//    RJLPS_Seeking      = 1<<4,
//    RJLPS_Scrubbing    = 1<<5,
//    RJLPS_Slomo        = 1<<6,
//    RJLPS_Error        = 1<<7,
//    RJLPS_Mute         = 1<<8,
//    RJLPS_Looping      = 1<<9
//};

/*   NOTE
 *--------------------
 *After updating to iOS7.1, avplayer might gives us negative video start time(this value randomly changes while the video plays) and video's current time is also based on this start time.
 *For example: Start time is -2 sec and current time is 50 sec which could be mapped to start time is 0 sec, the current time value is 52 sec or start time is -3 sec current time is 49 sec;
 *When user pauses the video, get the current tele time and the current video's start time.
 *After finishing telestartion, send the tag information dictionary to the server and the tag time in the dictionary will be: (tele time) - (start time), which is "52" in our example;
 *The time sent to the server is always based on start time is 0;
 *When reviewing the telestration, the avplayer will seek to is right tele time base on the video's new start time which is (tag time) + (new start time).
 *--------------------
 */

@interface RJLVideoPlayer : UIViewController <PxpVideoPlayerProtocol>
{
    BOOL seekToZeroBeforePlay;
}


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
@property (nonatomic,assign)    BOOL
isAlive;


// Graphic
@property (nonatomic,strong)     LiveLight         * liveIndicatorLight;
@property (nonatomic,strong)     VideoControlBarSlider      * videoControlBar;
@property (nonatomic,strong)     ClipControlBarSlider       * clipControlBar;
@property (nonatomic,copy)       NSURL                      *URL;
@property (nonatomic,assign)     float                      fps;

@property (nonatomic,assign)     BOOL                       isInClipMode;


@property (nonatomic, strong)    VideoZoomManager       *zoomManager;


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

@end
