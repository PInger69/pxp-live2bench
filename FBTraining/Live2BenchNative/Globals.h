//
//  Globals.h
//  Live2BenchNative
//
//  Created by dev on 2013-02-20.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
//#import <QuartzCore/QuartzCore.h>
#import "SpinnerView.h"
#import <AVFoundation/AVFoundation.h>
#import "VideoPlayer.h"
#import "AppQueue.h"


#define MEDIA_PLAYER_WIDTH    712
#define MEDIA_PLAYER_HEIGHT   400
@class VideoPlayer;
@class AppQueue;
#import <Foundation/Foundation.h>
@interface Globals : NSObject
{
    //Paths
    NSString *LOCAL_DOCS_PATH;
    NSString *EVENTS_PATH;
    NSString *THUMBNAILS_PATH;
    NSString *VIDEOS_PATH;
    NSString *ACCOUNT_PLIST_PATH;
    
    //State Booleans
    
    //connection state
    BOOL HAS_CLOUD;
    BOOL HAS_MIN;
    BOOL HAS_WIFI;
    BOOL TAG_BTNS_REQ_SENT;
    BOOL WAITING_RESPONSE_FROM_SERVER;
    
    //received items
    BOOL DID_RECV_NEW_CAL_EVENTS;
    BOOL DID_RECV_TAG_NAMES;
    BOOL DID_RECV_GAME_TAGS;
    BOOL DID_RECV_TEAMS;
    BOOL DID_RECV_NEW_TAG;
    
    //app state
    BOOL APP_IS_LAUNCHING;
    BOOL DID_CREATE_NEW_TAG;
    BOOL DID_INIT_L2B_PLAYER;
    BOOL IS_LOGGED_IN;
    BOOL IS_EULA;
    BOOL IS_IN_FIRST_VIEW;
    BOOL IS_IN_BOOKMARK_VIEW;
    BOOL IS_IN_LIST_VIEW;
    BOOL IS_IN_CLIP_VIEW;
    BOOL isBACKFROMSLEEP;
    BOOL MOVIE_PLAYER_IS_PAUSED;
    BOOL STOP_TIMERS_FROM_LOGOUT;
    
    //event state
    BOOL DID_GO_TO_LIVE;
    BOOL DID_RECEIVE_NEW_EVENT;
    BOOL DID_START_NEW_EVENT;
    BOOL FIRST_LOCAL_PLAYBACK;
    //BOOL GET_VIDEO_ID;
   // BOOL IS_EVENT_PLAYBACK;
    BOOL IS_LOCAL_PLAYBACK;
    BOOL IS_PAST_EVENT;
    BOOL LIVE_TIMER_ON;
//    BOOL NEW_EVENT_HAS_STARTED;
    BOOL SWITCH_TO_DIFFERENT_EVENT;
    
    //tag/tag playback state
    BOOL IS_TAG_PLAYBACK;
    BOOL IS_LOOP_MODE;
    BOOL IS_PLAYBACK_TELE;
    //this value will be true if the user starts to draw telestration and it will be false if the user finished drawing or gives up drawing
    BOOL IS_TELE;
    BOOL PLAYBACK_TELE_SUCCESS;
    
    int CURRENT_APP_STATE;
    
    //Encoder Status, setup
    
    NSTimer *ENCODER_STATUS_TIMER;
    NSString *CURRENT_ENC_STATUS;
    NSString *OLD_ENCODER_STATUS;
    NSString *ENCODER_SELECTED_HOME_TEAM;
    NSString *ENCODER_SELECTED_AWAY_TEAM;
    NSString *ENCODER_SELECTED_LEAGUE;
    UIPopoverController *HOME_POP;
    UIPopoverController *AWAY_POP;
    UIPopoverController *LEAGUE_POP;
    
    //Queues
    
    NSMutableArray * TOAST_QUEUE;
    AppQueue *APP_QUEUE;
    NSMutableArray *ARRAY_OF_TAGSET;
    
    //Current event info - mostly same throughout event
    
    NSMutableDictionary *CURRENT_EVENT_THUMBNAILS;
    NSMutableArray *THUMBNAIL_COUNT_REF_ARRAY; //only used once, do we need to keep this?
    NSString *EVENT_NAME;
    NSString * WHICH_SPORT;
    NSMutableArray *PLAYING_TEAMS_HIDS;
    NSMutableDictionary *GLOBAL_TEAM_PLAYERS;
    NSArray *ARRAY_OF_POSS_PLAYERS; //HOW MANY POSSIBLE PLAYERS WE CAN HAVE
    NSMutableArray *ARRAY_OF_HOCKEY_PLAYERS; //the following are for filters
    NSMutableArray *ARRAY_OF_SOCCER_PLAYERS;
    NSArray *ARRAY_OF_ZONES_HOCKEY;
    NSMutableArray *ARRAY_OF_PERIODS;
    NSMutableArray *ARRAY_OF_COLOURS;
    NSMutableArray *ARRAY_OF_ZONES;
    NSMutableArray *ARRAY_OF_STRENGTH;
    NSMutableArray *ARRAY_OF_LINES;
    NSMutableArray *TYPES_OF_TAGS;
    NSMutableDictionary *TAG_MARKER_OBJ_DICT; //apparently for toasts
    NSMutableDictionary *OFFLINE_DURATION_TAGS; //CONTAINS LINES, DURATION, PERIODS, ZONES, STRENGTH, ETC;
    
    //Info within event - changes regularly
    
    int CURRENT_F_LINE;
    int CURRENT_D_LINE;
    NSMutableArray *ARRAY_OF_SELECTED_LINE_PLAYERS;
    int CURRENT_PERIOD;
    NSMutableString *CURRENT_STRENGTH;
    NSMutableString *CURRENT_ZONE;
    NSMutableDictionary *TAG_MARKER_ITEMS; //for toasts
    NSMutableArray *NEW_TAGS;
    NSMutableDictionary *DURATION_TAGS_TIME;
    NSMutableDictionary *DURATION_TYPE_TIMES;

    //VideoPlayers
    
    VideoPlayer *GLOBAL_VIDEOPLAYER;
    VideoPlayer *VIDEO_PLAYER_LIVE2BENCH;
    VideoPlayer *VIDEO_PLAYER_LIST_VIEW;
    VideoPlayer *VIDEO_PLAYER__BOOKMARK;
    
    //VideoInfo
    
    NSString *CURRENT_PLAYBACK_EVENT;
    NSString *CURRENT_PLAYBACK_EVENT_BACKUP;
    double HOME_START_TIME;
    double HOME_HOME_END_TIME;
    double RETAINEDPLAYBACKTIME;
    float PAUSED_DURATION;
    float PLAYBACK_SPEED;
    float GLOBAL_PLAYED_DURATION;
    float TELE_TIME;
    float PLAYABLE_DURATION;
    
    //Playback tag information
    
    NSDictionary *CURRENT_PLAYBACK_TAG;
    NSString *CURRENT_PLAYING_TAG_NAME;
    double CURRENT_PLAYING_TAG_POSITION;
    
    //Bookmark
    
    NSMutableDictionary *BOOKMARK_TAGS;
    NSMutableArray *BOOKMARK_QUEUE;
    //NSMutableArray *BOOKMARK_QUEUE_KEYS;
    NSMutableArray *BOOKMARK_QUEUE_FAILED;
    NSString *BOOKMARK_PATH;
    NSString *BOOKMARK_TAGS_PATH;
    NSString *BOOKMARK_QUEUE_PATH;
    NSMutableArray *BOOKMARK_OPPONENTS;
    NSMutableArray *BOOKMARK_DATES;
    
    //Calendar/Events 
    
    NSMutableDictionary *ALL_EVENTS_DICT;
    NSString *HUMAN_READABLE_EVENT_NAME;
    NSMutableDictionary *ALL_TEAMS; //contains teams and their metadata
    NSMutableDictionary *ALL_LEAGUES;
    NSMutableArray *TEAM_SETUP;
    NSArray *NEW_EVENTS_FROM_SYNC;
    
    //connection/account info
    
    NSMutableDictionary *ACCOUNT_INFO;
    NSArray *ACCOUNT_FIELDS;
    NSString *URL;
    int CONNECTION_ERROR_CODE;
    double BIT_RATE;
    NSMutableArray *BIT_RATE_SAMPLES;
    
    //misc
    
    NSArray *CUSTOM_TAB_ITEMS; //names of the tabs at the top
    UIView *WHITE_BACKGROUND;
    NSTimer *INIT_SPINNERTIMER;
    SpinnerView *SPINNERVIEW;
    NSTimer *SYNC_ME_TIMER;
    
    //for football information
    int CURRENT_QUARTER_FB;
    int CURRENT_O_DOWN_FB;
    int CURRENT_O_ACTION_FB;
    int CURRENT_O_DISTANCE_FB;
    int CURRENT_O_PLAY_NUMBER_FB;
    int CURRENT_D_DOWN_FB;
    int CURRENT_D_ACTION_FB;
    int CURRENT_D_DISTANCE_FB;
    int CURRENT_D_PLAY_NUMBER_FB;
    int CURRENT_O_SERIES_NUMBER_FB;
    int CURRENT_D_SERIES_NUMBER_FB;
    NSString *CURRENT_STATE_FB;
    NSDictionary *CURRENT_DOWN_TAGID;
    NSMutableArray *playCallOppArray;
    NSMutableArray *playCallArray;
    NSString *CURRENT_TYPE_FB;
    NSMutableDictionary *LINE_PERIOD_STRENGTH_DICT;
    NSString *LOG_PATH;
    NSMutableDictionary *LOG_INFO;
    BOOL VIDEO_PLAYBACK_FAILED;
    BOOL WAITING_CHOOSE_TEAM_PLAYERS;
    BOOL WAITING_GAME_TAGS_RESPONSE;
    NSMutableArray *ARRAY_OF_POPUP_ALERT_VIEWS;//array of alert views which have showed; The reason of using this variable is because if there is a alertview, adding team players selection popup view to the rootview will crash
                                               //so we need to dimiss all the alertview before adding the popup view (TODO: find a better way to do this)

    
    SEL CURRENT_SEEK_BACK_ACTION; //current seek back action i.e. seek back 0.25sec/1 sec/5 secs
    SEL CURRENT_SEEK_FORWARD_ACTION; //current seek forward action i.e. seek forward 0.25sec/1 sec/5 secs
    
    NSMutableArray *LEFT_TAG_BUTTONS_NAME;
    NSMutableArray *RIGHT_TAG_BUTTONS_NAME;
    
    NSMutableArray *THUMBS_WERE_SELECTED_CLIPVIEW;//array of tags which have been reviewed in clip view;
    NSMutableArray *THUMBS_WERE_SELECTED_LISTVIEW;//array of tags which have been reviewed in list view;
    id THUMB_WAS_SELECTED_CLIPVIEW;//the id of the tag which was view last time in clip view
    id THUMB_WAS_SELECTED_LISTVIEW;//the id of the tag which was view last time in list view
    NSMutableArray *TAGS_WERE_SELECTED_BMVIEW;//array of tags which have been reviewed in bookmark view;
    int TAG_WAS_SELECTED_BMVIEW;//the id of the tag which was view last time in bookmark view
    
};
// methods
+ (Globals *)instance; // <-- important, notice the +

//paths

@property (nonatomic,strong) NSString *EVENTS_PATH;
@property (nonatomic,strong) NSString *THUMBNAILS_PATH;
@property (nonatomic,strong) NSString *VIDEOS_PATH;
@property (nonatomic,strong) NSString *ACCOUNT_PLIST_PATH;
@property (nonatomic,strong) NSString *TAGS_PLIST_PATH;
@property (nonatomic,strong) NSString *LOCAL_DOCS_PATH;

//connection 
@property (nonatomic) BOOL HAS_MIN;
@property (nonatomic) BOOL HAS_CLOUD;
@property (nonatomic) BOOL HAS_WIFI;
@property (nonatomic) BOOL WAITING_RESPONSE_FROM_SERVER;
@property (nonatomic) int CONNECTION_ERROR_CODE;
@property (nonatomic) double BIT_RATE;
@property (nonatomic, strong) NSMutableArray* BIT_RATE_SAMPLES;
@property (nonatomic,strong) NSString *URL;

//received information
@property (nonatomic) BOOL DID_RECV_TEAMS;
@property (nonatomic) BOOL DID_RECV_NEW_CAL_EVENTS;
@property (nonatomic) BOOL DID_RECV_TAG_NAMES;
@property (nonatomic) BOOL DID_RECV_GAME_TAGS;
@property (nonatomic) BOOL DID_RECEIVE_NEW_EVENT;
@property (nonatomic) BOOL TAG_BTNS_REQ_SENT;
@property (nonatomic) BOOL DID_RECV_NEW_TAG;
@property (nonatomic,strong) NSMutableArray *THUMBNAIL_COUNT_REF_ARRAY;
@property (atomic,strong) NSMutableArray *DOWNLOADED_THUMBNAILS_SET;
@property (nonatomic)BOOL FINISHED_LOADING_THUMBNAIL_IMAGES;
@property (nonatomic,strong) NSMutableArray *NEW_TAGS;
@property (nonatomic,strong) NSArray *EVENTS_ON_SERVER;
@property (nonatomic,strong) NSMutableDictionary *DURATION_TAGS_TIME;
@property (nonatomic,strong) NSMutableDictionary *DURATION_TYPE_TIMES;

//app state
@property (nonatomic) BOOL APP_IS_LAUNCHING;
@property (nonatomic) BOOL DID_START_NEW_EVENT;
@property (nonatomic) BOOL SHOW_TOASTS;
@property (nonatomic) BOOL IS_IN_FIRST_VIEW;
@property (nonatomic) BOOL IS_LOGGED_IN;
@property (nonatomic) BOOL IS_EULA;
@property (nonatomic) BOOL IS_IN_BOOKMARK_VIEW;
@property (nonatomic) BOOL IS_IN_LIST_VIEW;
@property (nonatomic) BOOL IS_IN_CLIP_VIEW;
@property (nonatomic) BOOL isBACKFROMSLEEP;
@property (nonatomic) BOOL FIRST_LOCAL_PLAYBACK;
@property (nonatomic) BOOL IS_LOCAL_PLAYBACK;
@property (nonatomic) BOOL STOP_TIMERS_FROM_LOGOUT;
@property (nonatomic) BOOL SWITCH_TO_DIFFERENT_EVENT;
@property (nonatomic) BOOL DID_GO_TO_LIVE;
@property (nonatomic) BOOL LIVE_TIMER_ON;
@property BOOL DID_INIT_L2B_PLAYER;

@property (nonatomic) int CURRENT_APP_STATE;

//events
@property (nonatomic,strong) NSMutableDictionary *ALL_LEAGUES;
@property (nonatomic,strong) NSMutableArray *PLAYING_TEAMS_HIDS;
@property (nonatomic,strong) NSMutableArray *TEAM_SETUP;
@property (nonatomic,strong) NSMutableDictionary *ALL_TEAMS;
@property (nonatomic,strong) NSString *HUMAN_READABLE_EVENT_NAME;
@property (nonatomic,strong) NSMutableDictionary *ALL_EVENTS_DICT;
@property (nonatomic) BOOL IS_PAST_EVENT;

//filters
@property (nonatomic,strong) NSMutableDictionary *TAGGED_ATTS_DICT;
@property (nonatomic,strong) NSMutableDictionary *TAGGED_ATTS_BOOKMARK;
@property (nonatomic,strong) NSMutableDictionary *TAGGED_ATTS_DICT_SHIFT;

//current event
@property (nonatomic,strong) NSString *EVENT_NAME;
@property (nonatomic,strong) NSDate*   eventStartDate;
@property (nonatomic,strong) NSMutableArray *ARRAY_OF_SOCCER_PLAYERS;
@property (nonatomic,strong) NSString *WHICH_SPORT;
@property (nonatomic,strong) NSArray *ARRAY_OF_POSS_PLAYERS;
@property (nonatomic,strong) NSArray *ARRAY_OF_ZONES_HOCKEY;
@property (nonatomic,strong) NSMutableArray *ARRAY_OF_ZONES;
@property (nonatomic,strong) NSMutableArray *ARRAY_OF_COLOURS;
@property (nonatomic,strong) NSMutableArray *ARRAY_OF_STRENGTH;
@property (nonatomic,strong) NSMutableArray *ARRAY_OF_LINES;
@property (nonatomic,strong) NSMutableArray *ARRAY_OF_HOCKEY_PLAYERS;
@property (nonatomic,strong) NSMutableArray *ARRAY_OF_SELECTED_LINE_PLAYERS;
@property (nonatomic,strong) NSMutableArray *ARRAY_OF_PERIODS;
@property (nonatomic,strong) NSMutableArray *TYPES_OF_TAGS;
@property (nonatomic,strong) NSMutableDictionary *CURRENT_EVENT_THUMBNAILS;
@property (nonatomic,strong) NSMutableDictionary *TAG_MARKER_OBJ_DICT;
@property (nonatomic,strong) NSMutableDictionary *GLOBAL_TEAM_PLAYERS;
@property (nonatomic) BOOL eventExistsOnServer;

//current state
@property (nonatomic) int CURRENT_F_LINE;
@property (nonatomic) int CURRENT_D_LINE;
@property (nonatomic) int CURRENT_PERIOD;
@property (nonatomic,strong) NSMutableString *CURRENT_STRENGTH;
@property (nonatomic,strong) NSMutableString *CURRENT_ZONE;

//tagging/ tag playback
@property (nonatomic) double CURRENT_PLAYING_TAG_POSITION;
@property (nonatomic,strong)  NSString *CURRENT_PLAYING_TAG_NAME;
@property (nonatomic) BOOL DID_CREATE_NEW_TAG;
@property (nonatomic,strong) NSDictionary *CURRENT_PLAYBACK_TAG;
@property (nonatomic) float TELE_TIME;
@property (nonatomic,strong) NSMutableDictionary *OFFLINE_DURATION_TAGS;

//video players
@property (nonatomic,strong) VideoPlayer *GLOBAL_VIDEOPLAYER;
@property (nonatomic,strong) VideoPlayer *VIDEO_PLAYER_LIVE2BENCH;
@property (nonatomic,strong) VideoPlayer *VIDEO_PLAYER_LIST_VIEW;
@property (nonatomic,strong) VideoPlayer *VIDEO_PLAYER_BOOKMARK;

//video player info
@property (nonatomic,strong) NSString *CURRENT_PLAYBACK_EVENT;
@property (nonatomic,strong) NSString *CURRENT_PLAYBACK_EVENT_BACKUP;
@property (nonatomic) float PAUSED_DURATION;
@property (nonatomic) double HOME_END_TIME;
@property (nonatomic) double HOME_START_TIME;
@property (nonatomic) BOOL IS_TELE;
@property (nonatomic) BOOL IS_PLAYBACK_TELE;
@property (nonatomic) BOOL IS_LOOP_MODE;
@property (nonatomic) BOOL IS_TAG_PLAYBACK;
@property (nonatomic) BOOL START_TAG_PLAYBACK;
//@property (nonatomic) BOOL IS_EVENT_PLAYBACK;
@property (nonatomic) BOOL MOVIE_PLAYER_IS_PAUSED;
@property (nonatomic) BOOL PLAYBACK_TELE_SUCCESS;
@property (nonatomic) float GLOBAL_PLAYED_DURATION;
@property (nonatomic) double RETAINEDPLAYBACKTIME;
@property (nonatomic) float PLAYBACK_SPEED;
@property (nonatomic) float PLAYABLE_DURATION;

//misc
@property (nonatomic,strong) NSMutableDictionary *TAG_MARKER_ITEMS;
@property (nonatomic,strong) NSArray *CUSTOM_TAB_ITEMS;
@property (nonatomic,strong) NSMutableDictionary *ACCOUNT_INFO;
@property (nonatomic,strong) NSArray *ACCOUNT_FIELDS;
@property (nonatomic,strong) UIView *WHITE_BACKGROUND;
@property (nonatomic,strong) AppQueue *APP_QUEUE;
@property (nonatomic,strong) NSTimer *SYNC_ME_TIMER;
@property (nonatomic,strong) NSMutableArray *ARRAY_OF_TAGSET;
@property (nonatomic,strong) NSTimer *INIT_SPINNERTIMER;
@property (nonatomic,strong) SpinnerView *SPINNERVIEW;
@property (strong,nonatomic) NSMutableArray *TOAST_QUEUE;
@property (nonatomic,strong) NSArray *NEW_EVENTS_FROM_SYNC;

//encoder
@property (nonatomic,strong) NSTimer *ENCODER_STATUS_TIMER;
@property (nonatomic,strong) NSString *CURRENT_ENC_STATUS;
@property (nonatomic,strong) NSString *OLD_ENCODER_STATUS;
@property (nonatomic,strong) UIPopoverController *LEAGUE_POP;
@property (nonatomic,strong) UIPopoverController *HOME_POP;
@property (nonatomic,strong) UIPopoverController *AWAY_POP;
@property (nonatomic,strong) NSString *ENCODER_SELECTED_LEAGUE;
@property (nonatomic,strong) NSString *ENCODER_SELECTED_HOME_TEAM;
@property (nonatomic,strong) NSString *ENCODER_SELECTED_AWAY_TEAM;

//bookmark
@property (nonatomic,strong) NSMutableDictionary *BOOKMARK_TAGS;
@property (nonatomic,strong) NSMutableArray *BOOKMARK_QUEUE;
//@property (nonatomic,strong) NSMutableArray *BOOKMARK_QUEUE_KEYS;
@property (nonatomic,strong) NSMutableArray *BOOKMARK_QUEUE_FAILED;
@property (nonatomic,strong) NSString *BOOKMARK_PATH;
@property (nonatomic,strong) NSString *BOOKMARK_TAGS_PATH;
@property (nonatomic,strong) NSString *BOOKMARK_QUEUE_PATH;
@property (nonatomic,strong) NSString *BOOKMARK_VIDEO_PATH;
@property (nonatomic) BOOL DID_FINISH_RECEIVE_BOOKMARK_VIDEO;
@property (nonatomic) BOOL RECEIVED_ONE_BOOKMARK_VIDEO;
@property (nonatomic) int NUMBER_OF_BOOKMARK_TAG_TO_PROCESS;
@property (nonatomic) int NUMBER_OF_BOOKMARK_TAG_RECEIVED;
@property (nonatomic,strong) NSMutableArray * BOOKMARK_OPPONENTS;
@property (nonatomic, strong) NSMutableArray *BOOKMARK_DATES;

@property (nonatomic) int CURRENT_QUARTER_FB;
@property (nonatomic) int CURRENT_O_DOWN_FB;
@property (nonatomic) int CURRENT_O_ACTION_FB;
@property (nonatomic) int CURRENT_O_DISTANCE_FB;
@property (nonatomic) int CURRENT_O_PLAY_NUMBER_FB;
@property (nonatomic) int CURRENT_D_DOWN_FB;
@property (nonatomic) int CURRENT_D_ACTION_FB;
@property (nonatomic) int CURRENT_D_DISTANCE_FB;
@property (nonatomic) int CURRENT_D_PLAY_NUMBER_FB;
@property (nonatomic) int CURRENT_O_SERIES_NUMBER_FB;
@property (nonatomic) int CURRENT_D_SERIES_NUMBER_FB;
@property (nonatomic,strong) NSString *CURRENT_STATE_FB;
@property (nonatomic,strong) NSMutableDictionary *LINE_PERIOD_STRENGTH_DICT;
@property (nonatomic,strong) NSString *LOG_PATH;
@property (nonatomic,strong) NSMutableDictionary *LOG_INFO;

@property (nonatomic)BOOL VIDEO_PLAYBACK_FAILED;
@property (nonatomic,strong) NSDictionary *CURRENT_DOWN_TAGID;
@property (nonatomic)BOOL DID_RECEIVE_MEMORY_WARNING;
//@property (nonatomic) BOOL eventExistsOnServer;
@property (nonatomic,strong)NSMutableArray *LOCAL_MODIFIED_EVENTS;
//@property (nonatomic,strong) NSMutableArray *EVENTS_ON_SERVER;
@property (nonatomic)int spinnerViewCounter;
@property (nonatomic,strong) NSMutableArray *NEW_TAGS_FROM_SYNC;
@property (nonatomic,strong) NSMutableArray *ALL_LOCAL_TAGS_REQUEST_QUEUE;
@property (nonatomic)int NUMBER_OF_LOCAL_TAGS_UPDATED;
@property (nonatomic)int NUMBER_OF_ALL_LOCAL_TAGS;
@property (nonatomic)BOOL WAITING_CHOOSE_TEAM_PLAYERS;
@property (nonatomic)BOOL WAITING_GAME_TAGS_RESPONSE;//this variable will be set to true if there is encoder and getgametags request is sent;will be set to false if did receive game tags
@property (nonatomic, strong)NSMutableArray *ARRAY_OF_POPUP_ALERT_VIEWS;
@property (nonatomic)SEL CURRENT_SEEK_BACK_ACTION;
@property (nonatomic)SEL CURRENT_SEEK_FORWARD_ACTION;
//Football

@property (nonatomic,strong) NSMutableArray *playCallOppArray;
@property (nonatomic,strong) NSMutableArray *playCallArray;
@property (nonatomic,strong) NSString *CURRENT_TYPE_FB;
@property (nonatomic,strong) NSMutableArray *LEFT_TAG_BUTTONS_NAME;
@property (nonatomic,strong) NSMutableArray *RIGHT_TAG_BUTTONS_NAME;

@property (nonatomic,strong) NSMutableArray *THUMBS_WERE_SELECTED_CLIPVIEW;
@property (nonatomic,strong) NSMutableArray *THUMBS_WERE_SELECTED_LISTVIEW;
@property (nonatomic,strong) id THUMB_WAS_SELECTED_CLIPVIEW;
@property (nonatomic,strong) id THUMB_WAS_SELECTED_LISTVIEW;
@property (nonatomic,strong) NSMutableArray *TAGS_WERE_SELECTED_BMVIEW;
@property (nonatomic) int TAG_WAS_SELECTED_BMVIEW;
@property (nonatomic,strong) NSString *DOWNLOADED_EVENTS_PLIST;
//dictionary of odd-type duration tags, with key value is tag name and object value is tag id
@property (nonatomic,strong) NSMutableDictionary *OPENED_DURATION_TAGS;
//dictionary of tags which are closed before get odd-type tags back from the server, with key value is tag name and object is tag info dictionary;
//this dictinary will be used to send tagmod request after receiving odd-type tags from the server
@property (nonatomic,strong) NSMutableDictionary *PRECLOSED_DURATION_TAGS;

//this value is true, if new tags coming when the user is viewing clip view/list view
@property (nonatomic)BOOL IS_TAG_TYPES_UPDATED;

//array of downloaded tags from server, but these tags have not been recreated yet
@property (nonatomic,strong)NSMutableArray *TAGS_DOWNLOADED_FROM_SERVER;
//array of tags which were not successfully downloaded before
@property (nonatomic,strong)NSMutableArray *BOOKMARK_TAGS_UNFINISHED;
//the duration tag which was opened before the app exited
@property (nonatomic,strong)NSString *UNCLOSED_EVENT;
//the latest telestration tag
@property(nonatomic,strong)NSDictionary *LATEST_TELE;

//For statsViewController
@property (nonatomic, assign)CGFloat eventDuration;

@end
