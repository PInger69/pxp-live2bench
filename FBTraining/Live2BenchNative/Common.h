//
//  Common.h
//  Live2BenchNative
//
//  Created by DEV on 5/9/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//
#import "Utility.h"
#ifndef Live2BenchNative_Common_h
#define Live2BenchNative_Common_h


// Common Classes



//encoder state

//mac is just turned on
static NSString *encStateInitializing = @"initializing";
//mac is checking the camera
static NSString *encStateLoadingCamera = @"loading camera";
//no camera is detected
static NSString *encStateNoCamera = @"no camera";
//camera is founded and ready for starting new event
static NSString *encStateReady = @"ready";
//starting a new event (start button is pressed in the app settings view)
static NSString *encStateStarting = @"starting";
//new event started (ready to play properly)
static NSString *encStateLive = @"live";
//live event paused (pause button is pressed in the app settings view)
static NSString *encStatePaused = @"paused";
//stopping a live event when in this state, the user could not start new event;
//when the live event completely stopped, the encoder state will change to "ready", and then the user could start new live event
static NSString *encStateStopping = @"stopping";
//shutting down the mac, but the mac is not completely shut down
static NSString *encStateShuttingDown = @"shutting down";


//CODE FOR ENCODER STATE

static NSInteger STAT_UNKNOWN        = 0;
static NSInteger STAT_INIT           = 1<<0;
static NSInteger STAT_CAM_LOADING    = 1<<1;
static NSInteger STAT_READY          = 1<<2;
static NSInteger STAT_LIVE           = 1<<3;
static NSInteger STAT_SHUTDOWN       = 1<<4;
static NSInteger STAT_PAUSED         = 1<<5;
static NSInteger STAT_STOP           = 1<<6;
static NSInteger STAT_START          = 1<<7;
static NSInteger STAT_NOCAM          = 1<<8;

/**
 *  old server encoder status response
 */
//when the live event stopped
static NSString *encStateStopped = @"stopped";
//camera is not detected
static NSString *encStateCameraDisconnected = @"camera disconnected";
//pro recorder is not detected
static NSString *encStateProrecorderDisconnected = @"pro recoder disconnected";
//if camera/prorecorder was disconnected during live event and then reconnected
static NSString *encStateStreamingOk = @"streaming ok";
//BM tries to get video info
static NSString *encStatePrepareToStream = @"preparing to stream";



/**
 *  Graphics Commons
 */
#define PRIMARY_APP_COLOR [UIColor orangeColor]



/**
 *  Notifications
 */
#define NOTIF_UPDATE_MEMORY                 @"update memory"
#define NOTIF_RECEIVE_MEMORY_WARNING        @"receive memory warning"
#define NOTIF_SUBTAG_SELECTED       		@"subtag selected"
#define NOTIF_PLAYERS_SELECTED       		@"players selected"
#define NOTIF_PLAYERS_MODIFIED      		@"players modified"
#define NOTIF_DURATION_TAG          		@"duration tag"
#define NOTIF_UPDATED_THUMBNAILS    		@"updated event thumbnails"
#define NOTIF_FILTER_CHANGE                 @"filter change"
#define NOTIF_DESTROY_TELE                  @"destroyTele"
#define NOTIF_PLAYER_RESTART_UPDATE         @"RestartUpdate"
#define NOTIF_PLAYER_EXITING_FULL_SCREEN    @"Exiting FullScreen"
#define NOTIF_SWITCH_MAIN_TAB               @"main tab switch"
#define NOTIF_APST_CHANGE                   @"apstStateChange"
#define NOTIF_USER_INFO_RETRIEVED           @"userInfoAdded"

#define NOTIF_SELECT_TAB                    @"selectTab"   // userInfo:@{@"tabName":@"Live2Bench"}

// Encoder
#define NOTIF_TAG_NAMES_FROM_CLOUD          @"tagNamesFromCloud"
#define NOTIF_MOTION_ALARM                  @"motionAlarm"
#define NOTIF_USER_CENTER_UPDATE            @"updateUserCenterData"
#define NOTIF_MASTER_COMMAND                @"masterEncoderCommand"
#define NOTIF_LIVE_EVENT_STOPPED            @"liveStopped"  
#define NOTIF_LIVE_EVENT_STARTED            @"liveStarted"
#define NOTIF_LIVE_EVENT_PAUSED             @"livePaused"
#define NOTIF_LIVE_EVENT_RESUMED            @"liveResumed"
#define NOTIF_CLIPVIEW_TAG_RECEIVED         @"clipViewTagReceived"

#define NOTIF_ENCODER_STAT                  @"encoderStatusMonitor"


// VideoPlayer
#define NOTIF_FULLSCREEN                    @"fullScreen"
#define NOTIF_SMALLSCREEN                   @"smallScreen"
#define NOTIF_SAVE_TELE                     @"Save Tele"
#define NOTIF_CLEAR_TELE                    @"Clear Tele"
#define NOTIF_COMMAND_VIDEO_PLAYER          @"videoPlayer Commands" // userInfo:@{@"context":<videoplayer context, if omited then all are commanded> ,  @"command": <typedef NS_OPTIONS in VideoPlayer> }

// PipViewController
#define NOTIF_SET_PLAYER_FEED               @"setPlayerFeed"   // userInfo:@{@"time":<float>,  @"feed": <NSString>,  @"state":<playerState> }

/**
 *  Sports
 */

#define SPORT_HOCKEY                @"hockey"
#define SPORT_FOOTBALL              @"football"
#define SPORT_FOOTBALL_TRAINING     @"football training"
#define SPORT_SOCCER                @"soccer"
#define SPORT_BASKETBALL            @"basketball"
#define SPORT_LACROSSE              @"lacrosse"
#define SPORT_RUGBY                 @"rugby"
#define SPORT_MEDICAL               @"medical"
#define SPORT_BLANK                 @""



/**
 *  Limit Constants
 */

#define MAX_NUM_TAG_BUTTONS     12

#endif
