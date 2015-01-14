//
//  VideoPlayer.h
//  Live2BenchNative
//
//  Created by DEV on 4/8/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVPlayerItem.h>
#import "Globals.h"
#import "OBSlider.h"
#import "VideoControlBarSlider.h"
#import "ExternalScreenButton.h"
#import "Feed.h"
#import "LiveIndicatorLight.h"

#define NOTIF_READY_TO_PLAY  @"readyToPlay"

@class VideoPlayerFreezeTimer;
typedef enum playerStatus{
    PS_Offline  = 0,
    PS_Live     = 1,
    PS_Play     = 2,
    PS_Paused   = 3,
    PS_Seeking  = 4,
    PS_Slomo    = 5,
    PS_Error    = 6,
    PS_Stop     = 7
}playerStatus;



typedef NS_OPTIONS(NSInteger, VideoPlayerCommand) {
    VideoPlayerCommandStop = 1<<1,
    VideoPlayerCommandPlay = 1<<2,
    VideoPlayerCommandMute = 1<<3,
    VideoPlayerCommandUnmute = 1<<4

};

@interface VideoPlayer : UIViewController

//property of avplayer
@property(nonatomic,strong)     VideoPlayerFreezeTimer *antiFreeze;
@property(nonatomic,strong)	    AVPlayer            * avPlayer;
@property(nonatomic,strong)	    AVPlayerLayer       * playerLayer;		    //layer for avplayer to display video images
@property(nonatomic,strong)	    UIImageView         * teleBigView;		    //for display telestration for list view and bookmark view
@property(nonatomic,strong)	    NSURL               * videoURL;		        //the video url which is playing in the avplayer
@property(nonatomic,strong)		NSTimer             * checkSeekTimer;		
@property(nonatomic,strong)	    id                  timeObserver;		    //time observer for updating current time and video duration
@property(nonatomic,assign)	    CGRect              playerFrame;		    //frame size of the video player
@property(nonatomic,assign)	    Float64             duration;		        //current video duration
@property(nonatomic,assign)	    Float64             startTime;		        //start time of the video; This value is needed if video's start time is negative
@property(nonatomic,assign)	    BOOL                isFullScreen;		    //if video player is in fullscreen mode, this value is TRUE
@property(nonatomic,assign) 	BOOL 				isSlowmo;
@property(nonatomic,assign) 	BOOL 				live;
@property(nonatomic,assign) 	BOOL 				isSeeking;
@property(nonatomic,assign)     playerStatus        status;
@property(nonatomic,strong)	    VideoControlBarSlider  * richVideoControlBar;
@property(nonatomic,strong)     Feed                * feed;
@property(nonatomic,strong)     NSString            * context;
@property(nonatomic,strong)     LiveIndicatorLight  * liveIndicatorLight;
@property(nonatomic,assign)     float               rate;

/**
 *  initialize video player with the given frame
 *
 *  @param frame size of player
 */
-(void)initializeVideoPlayerWithFrame:(CGRect)frame;

/**
 *  method used to add periodic time observer which is used to update current time, duration and slider value
 */
- (void)addPlayerItemTimeObserver;

/**
 *  method used to remove periodic time observer which will be called when video playback stopps or user navigates to other views
 */
-(void)removePlayerItemTimeObserver;

/**
 *This method returns video's current duration in seconds
 */
-(Float64)durationInSeconds;

/**
 *pause video for buffering
 */
-(void)prepareToPlay;

/**
 *play video control
 */
-(void)play;

/**
 *pause video control
 */
-(void)pause;

/**
 *force the video to go to live. This is mostly used in the Live2Bench on the live button
 */
-(void)goToLive;

/**
 *This method returns video's current time in second. This is mostly used byt BottomViewcontrollers
 */
-(Float64)currentTimeInSeconds;

/**
 *this method will be called when user pinches video view to go to fullscreen
 */
-(void)enterFullscreen;

/**
 *this method will be called when user pinches video view to go back to normal view
 */
-(void)exitFullScreen;

/**
 * DEPRECATED!
 * this method will be called if user swiped the video view with direction to the left, video will seek back X seconds. X is the value of secValue
 *
 */
-(void)seekBack: (float)secValue;

/**
 * DEPRECATED!
 *this method will be called if user swiped the video view with direction to the right video will seek forward X seconds. X is the value of secValue
 */
-(void)seekForward: (float)secValue;

/**
 *avplayer will seek to the required time and slider's value will be set to the the proper position
 */
-(void)setTime:(Float64)timeInSeconds;

/**
 *if the video play back failed, reset the avplayer
 */
-(void)resetAvplayer;

/**
 *set avplayer with video url
 */
-(void)setPlayerWithURL:(NSURL*)url;

/**
 *playback telestration
 */
-(void)playTele;

/**
 *  This method will be called by the new buttons because they use a positive or negative number // Richard
 *
 *  @param secValue seconds forward or backward. you can use negative numbers to go back
 */
-(void)seekBy: (float)secValue;

/**
 *  This lets you set the slow motion of the video
 *
 *  @return if on or off
 */
-(BOOL)toggleSlowmo;

/**
 *  This is to be used directly with the new custom seeker buttons
 *
 *  @param sender seeker Buttons
 */
-(void)seekWithSeekerButton:(id)sender;


-(void)enterFullscreenOn:(UIView *)parentView;

/**
 *  Reset the AVPlayerLayer
 */
-(void)resetAVplayerLayer;

-(void)seekToTheTime:(float)seekTime;
-(BOOL)seekTo:(float)seekTime;

-(void)playFeed:(Feed*)feed;
-(void)delayedSeekToTheTime:(float)seekTime;
@end
