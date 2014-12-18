#import "Globals.h"
@implementation Globals
static Globals *_instance = nil;  // <-- important

+(Globals *)instance
{
	// skip everything
	if(_instance) return _instance;
    
	// Singleton
	@synchronized([Globals class]) 
	{
		if(!_instance)
        {
			_instance = [[self alloc] init];
            
            _instance.APP_IS_LAUNCHING = TRUE;
            _instance.DID_START_NEW_EVENT=FALSE;
            _instance.ENCODER_SELECTED_LEAGUE= @"League";
            _instance.ALL_LEAGUES = [[NSMutableDictionary alloc]init];
            _instance.ENCODER_SELECTED_AWAY_TEAM = @"Away Team";
            _instance.ENCODER_SELECTED_HOME_TEAM = @"Home Team";
            _instance.DID_RECV_TEAMS = FALSE;
            _instance.TEAM_SETUP=[[NSMutableArray alloc]init];
            _instance.ALL_TEAMS = [[NSMutableDictionary alloc]init];
            _instance.THUMBNAIL_COUNT_REF_ARRAY= [[NSMutableArray alloc]init];
            _instance.HUMAN_READABLE_EVENT_NAME=[[NSString alloc] init];
            _instance.eventStartDate = nil;
            _instance.ALL_EVENTS_DICT = [[NSMutableDictionary alloc]init];
            _instance.HAS_MIN =FALSE;
            _instance.HAS_CLOUD=FALSE;
            _instance.DID_RECV_NEW_CAL_EVENTS = FALSE;
            _instance.FIRST_LOCAL_PLAYBACK=FALSE;
            _instance.IS_LOCAL_PLAYBACK=FALSE;
            _instance.IS_TELE = FALSE;
            _instance.TOAST_QUEUE=[[NSMutableArray alloc]init];
            _instance.SHOW_TOASTS=TRUE;
            _instance.DID_RECV_TAG_NAMES=FALSE;
            _instance.DID_RECV_GAME_TAGS=FALSE;
            _instance.DID_RECV_NEW_TAG=FALSE;
            _instance.HOME_START_TIME = -1;
            _instance.HOME_END_TIME=-1;
            _instance.IS_TAG_PLAYBACK=FALSE;
            //_instance.IS_EVENT_PLAYBACK = FALSE;
            _instance.DID_INIT_L2B_PLAYER=FALSE;
            _instance.DID_CREATE_NEW_TAG  = FALSE;
            _instance.CURRENT_PLAYING_TAG_POSITION = 0.0;
            _instance.TAG_MARKER_OBJ_DICT= [[NSMutableDictionary alloc] init];
            _instance.TYPES_OF_TAGS = [[NSMutableArray alloc]init];
            _instance.DID_RECEIVE_NEW_EVENT = FALSE;
            _instance.NEW_EVENTS_FROM_SYNC = [[NSArray alloc]init];
            _instance.EVENTS_ON_SERVER = [[NSArray alloc] init];
           
            
            _instance.WHICH_SPORT =@"hockey";//@"soccer";//
            _instance.ARRAY_OF_ZONES=[[NSMutableArray alloc]initWithObjects:@"OFF.3RD",@"MID.3RD",@"DEF.3RD", nil];
            _instance.STOP_TIMERS_FROM_LOGOUT = FALSE;
            _instance.CURRENT_EVENT_THUMBNAILS=[[ NSMutableDictionary  alloc] init];
            _instance.BOOKMARK_TAGS = [[NSMutableDictionary alloc]init];
            _instance.BOOKMARK_QUEUE = [[NSMutableArray alloc]init];
            _instance.BOOKMARK_QUEUE_FAILED = [[NSMutableArray alloc]init];
            _instance.CURRENT_F_LINE = -1;
            _instance.CURRENT_D_LINE = -1;
            _instance.CURRENT_PERIOD = -1;
            _instance.CURRENT_STRENGTH = nil;
            _instance.MOVIE_PLAYER_IS_PAUSED = FALSE;
            _instance.PLAYBACK_SPEED = 1.0f;
            _instance.URL = @"";
            _instance.BIT_RATE = 0.0;
            _instance.BIT_RATE_SAMPLES = [[NSMutableArray alloc] init];
            _instance.DID_FINISH_RECEIVE_BOOKMARK_VIDEO = TRUE;
            _instance.NUMBER_OF_BOOKMARK_TAG_TO_PROCESS = 0;
            _instance.NUMBER_OF_BOOKMARK_TAG_RECEIVED = 0;
            _instance.RECEIVED_ONE_BOOKMARK_VIDEO = FALSE;
            _instance.IS_PLAYBACK_TELE = FALSE;
            _instance.CURRENT_PLAYBACK_EVENT = [NSString stringWithFormat:@"%@/events/live/video/list.m3u8",_instance.URL];
            _instance.OFFLINE_DURATION_TAGS = [[NSMutableDictionary alloc] init];

            _instance.BOOKMARK_OPPONENTS=[[NSMutableArray alloc]init];
            _instance.BOOKMARK_DATES=[[NSMutableArray alloc]init];
            _instance.CURRENT_PLAYBACK_EVENT = @"";
            _instance.CURRENT_PLAYBACK_EVENT_BACKUP = @"";
            _instance.ARRAY_OF_HOCKEY_PLAYERS =[[NSMutableArray alloc]init];//WithObjects:@"2",@"3",@"5",@"8",@"1",@"4",@"7",@"55",@"6",@"9",@"33",@"53",@"10",@"13",@"44",@"14",@"32",@"67",@"84",@"66",nil] ;
            _instance.ARRAY_OF_LINES = [[NSMutableArray alloc]initWithObjects:@"L1",@"L2",@"L3",@"L4", nil];
            _instance.ARRAY_OF_COLOURS = [[NSMutableArray alloc]init];
            //initialise global movie player
            //arbitrary frame, url`
            _instance.ARRAY_OF_SOCCER_PLAYERS = [[NSMutableArray alloc]init];//WithObjects:@"42",@"11",@"62",@"18",@"17",@"7",@"8",@"21",@"14",@"32",@"16",@"10",@"3",@"33",@"4",@"13",@"42",@"11",@"62",@"18",@"17",@"7",@"8",@"21",@"14",@"32",@"16",@"10",@"3",@"33",@"4",@"13", nil];
            _instance.ARRAY_OF_PERIODS = [[NSMutableArray alloc]init];
            _instance.ARRAY_OF_STRENGTH = [[NSMutableArray alloc]initWithObjects:@"3",@"4",@"5",@"6", nil];
            _instance.ARRAY_OF_SELECTED_LINE_PLAYERS = [[NSMutableArray alloc]init];
            _instance.ARRAY_OF_POSS_PLAYERS = [[NSArray alloc] initWithObjects:@"3",@"4",@"5",@"6", nil];
            _instance.HAS_WIFI=FALSE;
            //_instance.IS_EVENT_PLAYBACK =FALSE;
            _instance.ARRAY_OF_ZONES_HOCKEY = [[NSArray alloc]initWithObjects:@"OZ",@"NZ",@"DZ", nil];
            _instance.LIVE_TIMER_ON = TRUE;
          

            _instance.WHITE_BACKGROUND = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1024.0f, 768.0f)];
            [_instance.WHITE_BACKGROUND setBackgroundColor:[UIColor whiteColor]];

            _instance.TAGGED_ATTS_DICT = [[NSMutableDictionary alloc]init ];
            _instance.TAGGED_ATTS_DICT_SHIFT = [[NSMutableDictionary alloc]init ];

            _instance.GLOBAL_PLAYED_DURATION = 0;
            
            _instance.RETAINEDPLAYBACKTIME = -1;
            _instance.VIDEO_PLAYER_LIVE2BENCH = [[VideoPlayer alloc] init];
            [_instance.VIDEO_PLAYER_LIVE2BENCH initializeVideoPlayerWithFrame:CGRectMake(156, 100, MEDIA_PLAYER_WIDTH, MEDIA_PLAYER_HEIGHT)];
            _instance.VIDEO_PLAYER_LIST_VIEW = [[VideoPlayer alloc] init];
            //[_instance.VIDEO_PLAYER_LIST_VIEW initializePlayer:CGRectMake(501, 330, 520, 340)];
            [_instance.VIDEO_PLAYER_LIST_VIEW initializeVideoPlayerWithFrame:CGRectMake(2, 114, 530, 340)];
            
            _instance.APP_QUEUE = [[AppQueue alloc]init];
            _instance.DID_GO_TO_LIVE = TRUE;
            _instance.PLAYABLE_DURATION = -1;
            _instance.DID_START_NEW_EVENT = FALSE;
            _instance.ARRAY_OF_TAGSET = [[NSMutableArray alloc]init];
            
            _instance.CURRENT_QUARTER_FB = -1;
            _instance.CURRENT_STATE_FB = @"";
            _instance.VIDEO_PLAYBACK_FAILED = FALSE;

            _instance.CURRENT_QUARTER_FB = -1;
            _instance.CURRENT_O_DOWN_FB = -1;
            _instance.VIDEO_PLAYBACK_FAILED = FALSE;
            _instance.CURRENT_DOWN_TAGID = nil;
            _instance.CURRENT_O_SERIES_NUMBER_FB = 0;
            _instance.CURRENT_D_SERIES_NUMBER_FB = 0;
            
            //by default, the variable set to true
            _instance.eventExistsOnServer = TRUE;
            
            _instance.spinnerViewCounter = 0;
            _instance.ALL_LOCAL_TAGS_REQUEST_QUEUE = [[NSMutableArray alloc]init];
            _instance.NUMBER_OF_LOCAL_TAGS_UPDATED = 0;
            _instance.NUMBER_OF_ALL_LOCAL_TAGS = 0;
            _instance.WAITING_CHOOSE_TEAM_PLAYERS = FALSE;
            _instance.WAITING_GAME_TAGS_RESPONSE = FALSE;
            _instance.ARRAY_OF_POPUP_ALERT_VIEWS = [[NSMutableArray alloc]init];
            _instance.playCallOppArray = [[NSMutableArray alloc] init];
            _instance.playCallArray = [[NSMutableArray alloc] init];
            _instance.LEFT_TAG_BUTTONS_NAME = [[NSMutableArray alloc] init];
            _instance.RIGHT_TAG_BUTTONS_NAME = [[NSMutableArray alloc] init];
            
            _instance.DURATION_TAGS_TIME = [[NSMutableDictionary alloc] init];
            _instance.DURATION_TYPE_TIMES=[[NSMutableDictionary alloc] init];
            
            _instance.THUMBS_WERE_SELECTED_CLIPVIEW = [[NSMutableArray alloc]init];
            _instance.THUMBS_WERE_SELECTED_LISTVIEW = [[NSMutableArray alloc]init];
            _instance.TAGS_WERE_SELECTED_BMVIEW = [[NSMutableArray alloc]init];
            _instance.OPENED_DURATION_TAGS = [[NSMutableDictionary alloc]init];
            _instance.PRECLOSED_DURATION_TAGS = [[NSMutableDictionary alloc]init];
            _instance.IS_TAG_TYPES_UPDATED = FALSE;
            
            _instance.DOWNLOADED_THUMBNAILS_SET = [[NSMutableArray alloc]init];
            
            _instance.eventDuration = 0.0f;
        }
        
		return _instance;
	}
    
	return nil;
}

@synthesize DID_START_NEW_EVENT;
@synthesize LEAGUE_POP;
@synthesize AWAY_POP;
@synthesize HOME_POP;
@synthesize ENCODER_SELECTED_LEAGUE;
@synthesize ALL_LEAGUES;
@synthesize ENCODER_SELECTED_AWAY_TEAM;
@synthesize ENCODER_SELECTED_HOME_TEAM;
@synthesize PLAYING_TEAMS_HIDS;
@synthesize DID_RECV_TEAMS;
@synthesize TEAM_SETUP;
@synthesize ALL_TEAMS;
@synthesize THUMBNAIL_COUNT_REF_ARRAY;
@synthesize DOWNLOADED_THUMBNAILS_SET;
@synthesize HUMAN_READABLE_EVENT_NAME;
@synthesize ALL_EVENTS_DICT;
@synthesize HAS_MIN;
@synthesize HAS_CLOUD;
@synthesize DID_RECV_NEW_CAL_EVENTS;
@synthesize CURRENT_APP_STATE;
@synthesize FIRST_LOCAL_PLAYBACK;
@synthesize IS_LOCAL_PLAYBACK;
@synthesize INIT_SPINNERTIMER;
@synthesize SPINNERVIEW;
@synthesize BOOKMARK_DATES;
@synthesize BOOKMARK_OPPONENTS;
@synthesize CURRENT_ENC_STATUS;
@synthesize TOAST_QUEUE;
@synthesize SHOW_TOASTS;
@synthesize ARRAY_OF_POSS_PLAYERS;
@synthesize WHITE_BACKGROUND;
@synthesize IS_PAST_EVENT;
@synthesize CURRENT_ZONE;
@synthesize GLOBAL_TEAM_PLAYERS;
@synthesize STOP_TIMERS_FROM_LOGOUT;
@synthesize ARRAY_OF_HOCKEY_PLAYERS;
@synthesize ARRAY_OF_SELECTED_LINE_PLAYERS;
@synthesize CURRENT_EVENT_THUMBNAILS;
@synthesize EVENT_NAME;
@synthesize EVENTS_PATH;
@synthesize THUMBNAILS_PATH;
@synthesize VIDEOS_PATH;
@synthesize ARRAY_OF_SOCCER_PLAYERS;
@synthesize WHICH_SPORT;
@synthesize ARRAY_OF_ZONES;
@synthesize IS_TELE;
@synthesize ARRAY_OF_COLOURS;
@synthesize ARRAY_OF_PERIODS;
@synthesize DID_RECEIVE_NEW_EVENT;
@synthesize NEW_EVENTS_FROM_SYNC;
@synthesize APP_IS_LAUNCHING;
@synthesize EVENTS_ON_SERVER;

@synthesize CURRENT_F_LINE;
@synthesize CURRENT_D_LINE;
@synthesize CURRENT_PERIOD;
@synthesize CURRENT_STRENGTH;
@synthesize TAGGED_ATTS_DICT;
@synthesize TAGGED_ATTS_DICT_SHIFT;
@synthesize TAGGED_ATTS_BOOKMARK;

@synthesize HAS_WIFI;
@synthesize TYPES_OF_TAGS;
@synthesize TAG_MARKER_OBJ_DICT;
@synthesize CURRENT_PLAYING_TAG_NAME;
@synthesize CURRENT_PLAYING_TAG_POSITION;
@synthesize DID_CREATE_NEW_TAG;
@synthesize GLOBAL_VIDEOPLAYER;
@synthesize NEW_TAGS;
@synthesize DID_INIT_L2B_PLAYER;
@synthesize CURRENT_PLAYBACK_TAG;
@synthesize CURRENT_PLAYBACK_EVENT;
@synthesize CURRENT_PLAYBACK_EVENT_BACKUP;
@synthesize IS_TAG_PLAYBACK;
@synthesize START_TAG_PLAYBACK;
//@synthesize IS_EVENT_PLAYBACK;
@synthesize PAUSED_DURATION;
@synthesize HOME_END_TIME;
@synthesize HOME_START_TIME;
@synthesize DID_RECV_NEW_TAG;
@synthesize TAG_BTNS_REQ_SENT;
@synthesize TAG_MARKER_ITEMS;
@synthesize CUSTOM_TAB_ITEMS;
@synthesize LOCAL_DOCS_PATH;
@synthesize IS_LOGGED_IN;
@synthesize IS_EULA;
@synthesize ACCOUNT_INFO;
@synthesize ACCOUNT_FIELDS;
@synthesize ACCOUNT_PLIST_PATH;
@synthesize DID_RECV_GAME_TAGS;
@synthesize DID_RECV_TAG_NAMES;
@synthesize IS_LOOP_MODE;
@synthesize IS_IN_LIST_VIEW;
@synthesize IS_IN_CLIP_VIEW;
@synthesize MOVIE_PLAYER_IS_PAUSED;
@synthesize PLAYBACK_SPEED;
@synthesize URL;
@synthesize BIT_RATE;
@synthesize BIT_RATE_SAMPLES;
@synthesize ARRAY_OF_STRENGTH;
@synthesize ARRAY_OF_LINES;
@synthesize BOOKMARK_TAGS;
@synthesize BOOKMARK_QUEUE;
@synthesize BOOKMARK_QUEUE_FAILED;
@synthesize BOOKMARK_PATH;
@synthesize BOOKMARK_TAGS_PATH;
@synthesize BOOKMARK_QUEUE_PATH;
@synthesize BOOKMARK_VIDEO_PATH;
@synthesize DID_FINISH_RECEIVE_BOOKMARK_VIDEO;
@synthesize NUMBER_OF_BOOKMARK_TAG_TO_PROCESS;
@synthesize NUMBER_OF_BOOKMARK_TAG_RECEIVED;
@synthesize RECEIVED_ONE_BOOKMARK_VIDEO;
@synthesize IS_IN_BOOKMARK_VIEW;
@synthesize IS_PLAYBACK_TELE;
@synthesize CONNECTION_ERROR_CODE;
@synthesize PLAYBACK_TELE_SUCCESS;
@synthesize GLOBAL_PLAYED_DURATION;
@synthesize LIVE_TIMER_ON;
@synthesize RETAINEDPLAYBACKTIME;
@synthesize VIDEO_PLAYER_LIVE2BENCH;
@synthesize VIDEO_PLAYER_LIST_VIEW;
@synthesize VIDEO_PLAYER_BOOKMARK;
@synthesize APP_QUEUE;
@synthesize DID_GO_TO_LIVE;
@synthesize TELE_TIME;
@synthesize WAITING_RESPONSE_FROM_SERVER;
@synthesize SWITCH_TO_DIFFERENT_EVENT;
@synthesize FINISHED_LOADING_THUMBNAIL_IMAGES;
@synthesize PLAYABLE_DURATION;
@synthesize isBACKFROMSLEEP;
@synthesize OLD_ENCODER_STATUS;
@synthesize SYNC_ME_TIMER;
@synthesize ENCODER_STATUS_TIMER;
@synthesize ARRAY_OF_TAGSET;
@synthesize IS_IN_FIRST_VIEW;

@synthesize LINE_PERIOD_STRENGTH_DICT;
@synthesize LOG_PATH;
@synthesize LOG_INFO;

@synthesize VIDEO_PLAYBACK_FAILED;
@synthesize CURRENT_DOWN_TAGID;
@synthesize CURRENT_O_SERIES_NUMBER_FB;
@synthesize CURRENT_D_SERIES_NUMBER_FB;
@synthesize DID_RECEIVE_MEMORY_WARNING;
@synthesize eventExistsOnServer;
@synthesize LOCAL_MODIFIED_EVENTS;
//@synthesize EVENTS_ON_SERVER;
@synthesize spinnerViewCounter;
@synthesize NEW_TAGS_FROM_SYNC;
@synthesize ALL_LOCAL_TAGS_REQUEST_QUEUE;
@synthesize NUMBER_OF_LOCAL_TAGS_UPDATED;
@synthesize NUMBER_OF_ALL_LOCAL_TAGS;
@synthesize WAITING_CHOOSE_TEAM_PLAYERS;
@synthesize WAITING_GAME_TAGS_RESPONSE;
@synthesize ARRAY_OF_POPUP_ALERT_VIEWS;
@synthesize CURRENT_SEEK_BACK_ACTION;
@synthesize CURRENT_SEEK_FORWARD_ACTION;
@synthesize CURRENT_TYPE_FB;
@synthesize playCallArray;
@synthesize playCallOppArray;
@synthesize LEFT_TAG_BUTTONS_NAME;
@synthesize RIGHT_TAG_BUTTONS_NAME;
@synthesize THUMBS_WERE_SELECTED_CLIPVIEW;
@synthesize THUMBS_WERE_SELECTED_LISTVIEW;
@synthesize THUMB_WAS_SELECTED_CLIPVIEW;
@synthesize THUMB_WAS_SELECTED_LISTVIEW;
@synthesize TAGS_WERE_SELECTED_BMVIEW;
@synthesize TAG_WAS_SELECTED_BMVIEW;
@synthesize DOWNLOADED_EVENTS_PLIST;
@synthesize OPENED_DURATION_TAGS;
@synthesize PRECLOSED_DURATION_TAGS;
@synthesize IS_TAG_TYPES_UPDATED;
@synthesize TAGS_DOWNLOADED_FROM_SERVER;
@synthesize BOOKMARK_TAGS_UNFINISHED;
@synthesize UNCLOSED_EVENT;
@synthesize LATEST_TELE;
@end