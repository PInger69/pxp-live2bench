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

// Version check tools
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)



//BEN AND SAGAR STUFF BEGINNING
#define NOTIF_SET_PLAYER_FEED_IN_LIST_VIEW  @"setPlayerFeedInListView"
#define STRING_LISTVIEW_CONTEXT             @"ListView Tab"
#define STRING_MYCLIP_CONTEXT               @"MyClip Tab"
#define NOTIF_LIST_VIEW_CONTROLLER_FEED     @"ListViewControllerFeed"
#define NOTIF_REQUEST_CALENDAR_DATA         @"RequestCalendarData"
#define NOTIF_EVENT_CHANGE                  @"NOTIF_EVENT_CHANGE"
#define NOTIF_REQUEST_MYCLIP_DATA           @"MyClipDataRequest"
#define NOTIF_SET_PLAYER_FEED_IN_MYCLIP     @"setPlayerFeedInMyClip"
// BEN AND SAGAR STUFF END
#define NOTIF_LOGOUT_USER                   @"NOTIF_LOGOUT_USER"
#define NOTIF_POST_ON_EXTERNAL_SCREEN       @"NOTIF_POST_ON_EXTERNAL_SCREEN"
#define NOTIF_TAG_POSTED                    @"postedTag"    

//TypeDef for ToastObserver
typedef NS_OPTIONS (NSInteger, toastType) {
    ARFileDownloadComplete = 1<<1,
    ARSynchronizedTags = 1<<2,
    ARTagCreated = 1<<3,
};
//End

// Common Classes
static float APP_WIDTH      = 0;
static float APP_HEIGHT     = 0;


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
 *  URLS
 */


/**
 *  Graphics Commons
 */
#define PRIMARY_APP_COLOR   [UIColor orangeColor]
#define SECONDARY_APP_COLOR [UIColor orangeColor]
#define TERTIARY_APP_COLOR  [UIColor orangeColor]

#define DEBUG_MODE                          0

//#if DEBUG_MODE == 0
//#define DebugLog(...)
//#elif DEBUG_MODE == 1
//#define DebugLog(...) NSLog(__VA_ARGS__)
//#endif





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
#define NOTIF_APST_CHANGE                   @"apstStateChange" // Depricated
#define NOTIF_USER_INFO_RETRIEVED           @"userInfoAdded"

#define NOTIF_SELECT_TAB                    @"selectTab"   // userInfo:@{@"tabName":@"Live2Bench"}
#define NOTIF_USER_LOGGED_OUT               @"userLoggedout" // {@"success":<bool>}
//#define NOTIF_LOGOUT_USER                   @"NOTIF_LOGOUT_USER" // this is watched by the encoder manager





// User Center
#define NOTIF_SIDE_TAGS_READY_FOR_L2B       @"tagsReadyForLive2Bench"
#define NOTIF_CREDENTIALS_TO_VERIFY         @"verifyCredentials"        // userInfo:@{@"user":<user name or email>,@"password":<password>}
#define NOTIF_CREDENTIALS_VERIFY_RESULT     @"verifyCredentialsResults" // userInfo:@{@"success":[NSNumber numberWithBool:<yes or no>]}


#define NOTIF_USER_CENTER_DATA_REQUEST      @"NOTIF_USER_CENTER_DATA_REQUEST"
#define NOTIF_UC_REQUEST_USER_INFO          @"requestUserInfo"          // userInfo:@{@"type"<type> ,  @"block":<block>}

// Request Types
#define UC_REQUEST_EVENT_HIDS               @"UC_REQUEST_EVENT_HIDS"   //@"block":(void(^)(NSArray*pooled))onCompleteGet
#define UC_REQUEST_USER_INFO                @"UC_REQUEST_USER_INFO"     //@"block":(void(^)(NSDictionary*pooled))onCompleteGet



// Encoder
#define NOTIF_TAG_NAMES_FROM_CLOUD          @"tagNamesFromCloud"
#define NOTIF_MOTION_ALARM                  @"motionAlarm"
#define NOTIF_USER_CENTER_UPDATE            @"updateUserCenterData"
#define NOTIF_MASTER_COMMAND                @"masterEncoderCommand"
#define NOTIF_LIVE_EVENT_STOPPED            @"liveStopped"  
#define NOTIF_LIVE_EVENT_STARTED            @"liveStarted"
#define NOTIF_LIVE_EVENT_PAUSED             @"livePaused"
#define NOTIF_LIVE_EVENT_RESUMED            @"liveResumed"
#define NOTIF_CLIPVIEW_TAG_RECEIVED         @"clipViewTagReceived" // returnds NSDict


#define NOTIF_ENCODER_STAT                  @"encoderStatusMonitor"
#define NOTIF_MASTER_HAS_LIVE               @"masterHasLive"

#define NOTIF_EM_FOUND_MASTER               @"NOTIF_EM_FOUND_MASTER"


// Encoder Manager
#define NOTIF_EM_CHANGE_EVENT               @"NOTIF_EM_CHANGE_EVENT"            // userInfo:@{@"name"<NSString>}
#define NOTIF_EVENT_LOADED                  @"NOTIF_EVENT_LOADED"               // this will be observed so we can ask the user to pick a team.
#define NOTIF_EM_DOWNLOAD_CLIP              @"NOTIF_EM_DOWNLOAD_CLIP"           // userInfo:// the clip data


#define NOTIF_ENCODER_MNG_DATA_REQUEST      @"NOTIF_ENCODER_MNG_DATA_REQUEST"   // userInfo:@{@"type"<type> ,  @"block":<block>}
// Request Types
#define EM_REQUEST_TAG_DATA_FOR_EVENT       @"EM_REQUEST_TAG_DATA_FOR_EVENT"    // add to user info  @"eventName":<NSString> , @"block":(void(^)(NSDictionary*all))onCompleteGet
#define EM_REQUEST_TEAM_DATA                @"EM_REQUEST_TEAM_DATA"             //@"block":(void(^)(NSArray*pooled))onCompleteGet
#define EM_REQUEST_ALL_EVENT_DATA           @"EM_REQUEST_ALL_EVENT_DATA"

// VideoPlayer
#define NOTIF_FULLSCREEN                    @"fullScreen"
#define NOTIF_SMALLSCREEN                   @"smallScreen"
#define NOTIF_SAVE_TELE                     @"Save Tele"
#define NOTIF_CLEAR_TELE                    @"Clear Tele"
#define NOTIF_COMMAND_VIDEO_PLAYER          @"videoPlayer Commands" // userInfo:@{@"context":<videoplayer context, if omited then all are commanded> ,  @"command": <typedef NS_OPTIONS in VideoPlayer> }
#define NOTIF_START_SCRUB                   @"startScrubbing"
#define NOTIF_FINISH_SCRUB                  @"finishedScrubbing"
#define NOTIF_CURRENT_TIME_REQUEST          @"currentTimeRequest"

typedef NS_OPTIONS(NSInteger, VideoPlayerCommand) {
    VideoPlayerCommandStop      = 1<<1,
    VideoPlayerCommandPlay      = 1<<2,
    VideoPlayerCommandPause     = 1<<3,
    VideoPlayerCommandMute      = 1<<4,
    VideoPlayerCommandUnmute    = 1<<5,
    VideoPlayerCommandPlayFeed  = 1<<6,
    VideoPlayerCommandLive      = 1<<7,
    VideoPlayerCommandLooping   = 1<<8,
    VideoPlayerCommandNoLooping = 1<<9,
    VideoPlayerCommandSlowmo    = 1<<10,
    VideoPlayerCommandNoSlomo   = 1<<11
};





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
 *  Tab String Context
 */

#define STRING_LIVE2BENCH_CONTEXT  @"Live2Bench Tab"


/**
 *  Limit Constants
 */

#define MAX_NUM_TAG_BUTTONS     12

#endif
