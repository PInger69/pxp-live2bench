
//
//  Live2BenchViewController.m
//  Live2BenchNative
//
//  Created by DEV on 2013-01-21.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "Live2BenchViewController.h"
#import <UIKit/UIKit.h>
#import "VideoPlayerFreezeTimer.h"
#import "EncoderClasses/EncoderManager.h"
#import "LiveButton.h"
#import "UserCenter.h"
#import "BottomViewControllerBase.h"
#import "Live2BenchTagUIViewController.h"
#import "L2BVideoBarViewController.h"
#import "L2BFullScreenViewController.h"

#define MEDIA_PLAYER_WIDTH    712
#define MEDIA_PLAYER_HEIGHT   400
#define TOTAL_WIDTH          1024
#define TOTAL_HEIGHT          600
#define LITTLE_ICON_DIMENSIONS 40
#define CONTROL_SPACER_X       20
#define CONTROL_SPACER_Y       50
#define PADDING                 5



@interface Live2BenchViewController ()

@end

@implementation Live2BenchViewController{
    BorderButton *viewTeleButton;
    BorderButton *viewTeleButtoninFullScreen;
    UIImageView *playbackRateBackGuide;
    UIImageView *playbackRateForwardGuide;
    UILabel *playbackRateBackLabel;
    UILabel *playbackRateForwardLabel;
    BOOL isViewTeleButtonSelected;
    NSMutableArray *tagButtonsArray;
    //if createTagMarkers is called, this value will be true
    BOOL isCreatingAllTagMarkers;
    BOOL isModifyingPlaybackRate;
    BOOL isFrameByFrame;
    float playbackRateRadius;
    float frameByFrameInterval;
    
    
    Globals                             * globals;
    
    // New class
    ScreenController                    * _externalControlScreen;       // this is for attacked screens
    EncoderManager                      * _encoderManager;              // where all vids/feeds coming from
    UserCenter                          * _userCenter;                  // any userdata from plists
    NSString                            * _eventType;                   // Sport or medical
    LiveButton                          * _liveButton;                  // live button
    // player with pip and feed select                                  // updated player
    L2BVideoBarViewController           * _videoBarViewController;       // player updated control bar
    Live2BenchTagUIViewController       * _tagButtonController;         // side tags
    BottomViewControllerBase            * _bottomViewControllerBase;    // base bottomview controller ALL Sports interchangeable
    L2BFullScreenViewController         * _fullscreenViewController;     // fullscreen class to manage all actions in full
    // Telestration                                                     // telestration might be added to full screen class
    void                                * eventTypeContext;             // to see when sport changes in encoderManager
}

// Player
@synthesize videoPlayer;

// Bottom view
@synthesize hockeyBottomViewController  =_bottomViewController;
@synthesize soccerBottomViewController  =_soccerBottomViewController;
@synthesize footballBottomViewController;
@synthesize footballTrainingBottomViewController;

@synthesize overlayItems                =_overlayItems;
@synthesize tagNames                    =_tagNames;
@synthesize overlayLeftViewController   =_overlayLeftViewController;
@synthesize overlayRightViewController  =_overlayRightViewController;
@synthesize swipedOutButton             = _swipedOutButton;



@synthesize tagMarker;
//@synthesize tagSetView;//888
//@synthesize tagEventName;//888
@synthesize playbackRateBackButton;
@synthesize playbackRateForwardButton;
//@synthesize currentSeekBackButton;
//@synthesize currentSeekForwardButton;
@synthesize teleViewController=_teleViewController;
@synthesize teleButton;
@synthesize currentEventName =_currentEventName;
@synthesize currentPlayingEventMarker=_currentPlayingEventMarker;
@synthesize accountInfo;
@synthesize startRangeModifierButton,endRangeModifierButton;
@synthesize leftSideButtons=_leftSideButtons;
@synthesize rightSideButtons=_rightSideButtons;
@synthesize playerCollectionViewController;
@synthesize footballTrainingCollectionViewController;
@synthesize continuePlayButton,timeLabel,fullscreenOverlayCreated,currentPlayBackTime;
@synthesize videoPlaybackFailedAlertView;

@synthesize poorSignalCounter;
@synthesize switchToLiveEvent;
@synthesize spinnerViewCounter;
@synthesize spinnerView;
//@synthesize seekBackControlView;
//@synthesize seekForwardControlView;


@synthesize tagMarkerLeadObjDict;
@synthesize updateTagmarkerCounter;
@synthesize durationTagLabel;
@synthesize durationTagSwitch;
@synthesize openedDurationTagButtons;
@synthesize isDurationTagEnabled;
@synthesize playerEncoderStatusLabel;
@synthesize loopTagObserver;


// FULL SCREEN
//@synthesize seekBackControlViewinFullScreen;
//@synthesize seekForwardControlViewinFullScreen;
@synthesize enterFullScreen;




// TELE
@synthesize saveTeleButton;
@synthesize clearTeleButton;

int loginIndex = 0; //indicate it is the first time go to first view or not
int tagsinQueueInOfflineMode = 0;
BOOL delaySlowMo = YES;

// Context
static void * eventTypeContext = &eventTypeContext;

#pragma mark - View Controller Methods

- (id)init
{
    self = [super init];
    if (self) {
        [self setMainSectionTab:@"Live2Bench" imageName:@"live2BenchTab"];

        // Is this dead? this is getting init 2 times??
        self.title                      = NSLocalizedString(@"First", @"First");
        self.tabBarItem.image           = [UIImage imageNamed:@"first"];
        self.hidesBottomBarWhenPushed   = YES;
        self.didInitLayout              = FALSE;

    }
    
    return self;
}

/**
 *  New init method
 *
 *  @param mainappDelegate
 *
 *  @return
 */
-(id)initWithAppDelegate:(AppDelegate *)mainappDelegate
{
    self = [super initWithAppDelegate:mainappDelegate];
    if (self) {
        [self setMainSectionTab:NSLocalizedString(@"Live2Bench", nil) imageName:@"live2BenchTab"];
    }
    _externalControlScreen  = _appDel.screenController;
    _encoderManager         = _appDel.encoderManager;
    _eventType              = _encoderManager.currentEventType;
    _userCenter             = _appDel.userCenter;
    
    // observers //@"currentEventType"
    [_encoderManager addObserver:self forKeyPath:NSStringFromSelector(@selector(currentEventType)) options:NSKeyValueObservingOptionNew context:eventTypeContext];
    return self;
    
}


#pragma mark - Observers and Observer Methods

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == eventTypeContext){ // This checks to see if the encoder manager has changed Events Types like Sport or Medical
        [self onEventTypeChange: [change objectForKey:@"new"]];
    }

}


// This will have all the code that will init a bottomview controller based of the EventType .... Sport or medical
-(void)onEventTypeChange:(NSString*)aType
{
    _eventType = aType;

}
#pragma mark -


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    // DEPRICATED
    self.leftSideButtons = [[UIView alloc] initWithFrame:CGRectMake(0, 80.0f, 124.0f, self.view.bounds.size.height - 355.0f)];
    self.leftSideButtons.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
    //    [self.view addSubview:self.leftSideButtons];
    
    self.rightSideButtons = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - self.leftSideButtons.bounds.size.width, self.leftSideButtons.frame.origin.y, self.leftSideButtons.bounds.size.width, self.leftSideButtons.bounds.size.height)];
    self.rightSideButtons.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    //    [self.view addSubview:self.rightSideButtons];
    // DEPRICATED END
    
    //label to show current event title
    currentEventTitle                   = [[UILabel alloc] initWithFrame:CGRectMake(156.0f, 71.0f, MEDIA_PLAYER_WIDTH, 21.0f)];
    currentEventTitle.textAlignment     = NSTextAlignmentRight;
    currentEventTitle.textColor         = [UIColor darkGrayColor];
    currentEventTitle.font              = [UIFont fontWithName:@"trebuchet" size:17.0f];
    currentEventTitle.backgroundColor   = [UIColor clearColor];
    currentEventTitle.autoresizingMask  = UIViewAutoresizingFlexibleRightMargin;
    
    currentEventTitle.layer.borderWidth = 1;
    [self.view addSubview:currentEventTitle];
    
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFullScreenOverlay)          name:@"Entering FullScreen" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFullScreenOverlay)          name:@"Exiting FullScreen" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(continuePlay)                     name:NOTIF_DESTROY_TELE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrubbingDestroyLoopMode)         name:@"scrubbingDestroyLoopMode" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseUpdatePlayerDurationTimer)   name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeUpdatePlayerDurationTimer)  name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateEventInformation)           name:@"EventInformationUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateEventInformation)           name:@"SportInformationUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeLiveSpinner)                name:@"removeLiveSpinner" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToLive)                         name:@"GoToLive" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeDurationTag:)                name:@"precloseDurationTagReceived" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendTagInformationToServer)       name:@"sendNextTag" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(highlightDurationTag)             name:@"highlightDurationTag" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeUpdatePlayerDurationTimer)  name:@"resetAvplayer" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNewTele)                       name:@"getnewtele" object:Nil];
    
    //video url changed
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeCurrentTimeObserver)        name:@"setvideourl" object:nil];
    
    
    globals                     = [Globals instance];
    uController                 = [[UtilitiesController alloc] init];
    
    //fullscreenOverlayCreated: used to check whether the fullscreen overlay buttons have been created or not; By default, it is false
    fullscreenOverlayCreated    = FALSE;

    //initially, the playback rate is 1
    globals.PLAYBACK_SPEED      = 1.0f;
    
    //get all the event tag buttons' names
    [self populateTagNames];
    
    //create all the event tag buttons
    [self createTagButtons];
    
    
    if (![_eventType isEqualToString:@""]) {
        //initial bottom view and player collection view
        [self updateEventInformation];
    }else{
        //tagsetview's frame is based on playercollection view, so need to initilize it first
        [self intialPlayerCollectionView];
    }
    //Start the sync me timeronly if there is event playing
    if (![globals.EVENT_NAME isEqualToString:@""]) {
       [uController restartSyncMeTimer];
    }

    
    
    //start the encoder status timer
    [uController startEncoderStatusTimer];
    


   
    
    // side tags
    _tagButtonController = [[Live2BenchTagUIViewController alloc]initWithView:self.view];
    [self addChildViewController:_tagButtonController];
    [_tagButtonController didMoveToParentViewController:self];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    delaySlowMo                 = YES;
    //spinnerViewCounter: used to time out spinner view
    //if the video player is not playing properly, add spinnerView and increase spinnerViewCounter
    //if spinnerViewCounter > 10, remove the spinner view
    spinnerViewCounter          = 0;
    //switchToLiveEvent: if the avplayer switches to live event from an old event, this variable will be set to TRUE
    //If it is true, the tagmarkers from old event will be removed and new ones from live event will be created
    switchToLiveEvent           = FALSE;
    
    globals.IS_IN_FIRST_VIEW    = TRUE;
    globals.IS_IN_LIST_VIEW     = FALSE;
    globals.IS_IN_BOOKMARK_VIEW = FALSE;
    globals.IS_IN_CLIP_VIEW     = FALSE;
    //pause the videoplayer and also stop the update slider timer in list view 
    [globals.VIDEO_PLAYER_LIST_VIEW pause];
    
    //will enter live2bench view, start playing video
    if (globals.CURRENT_PLAYBACK_EVENT && ![globals.CURRENT_PLAYBACK_EVENT isEqualToString:@""]) {
        [videoPlayer play];
        if (!videoPlayer.timeObserver) {
            [videoPlayer addPlayerItemTimeObserver];
        }

    }
    //make sure no duplicated timer is fired
    [updateCurrentEventInfoTimer invalidate];
    updateCurrentEventInfoTimer =nil;
    updateCurrentEventInfoTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(updateCurrentEventInfo)
                                   userInfo:nil
                                    repeats:YES];
    
    //update the event tag buttons if the user has made any change after opening the app
    if(globals.HAS_CLOUD)
    {
        [uController sync2Cloud];
    }
    
    //display the event name on the top right of the videoplayer
    [currentEventTitle setText:globals.HUMAN_READABLE_EVENT_NAME];
    [currentEventTitle setNeedsDisplay];
    
    
    // maybe this should be part of the videoplayer
     if(![self.view.subviews containsObject:self.videoPlayer.view])
     {
         //initial recordbutton and videoplayer
         recordButton = [[UIImageView alloc] initWithFrame:CGRectMake(MEDIA_PLAYER_WIDTH - 32, 0, 32, 32)];
         [recordButton setContentMode:UIViewContentModeScaleAspectFit];
         [recordButton setAlpha:0.0];
         [recordButton setHidden:TRUE];
         recordButton.opaque = NO;

         UIBezierPath *        myFirstShape = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(5, 5, 20, 20)];

         CAShapeLayer* shapeLayer;
         shapeLayer = [[CAShapeLayer alloc] initWithLayer:recordButton.layer];
         shapeLayer.lineWidth = 1.0;
         shapeLayer.fillColor = [UIColor greenColor].CGColor;
         
         [recordButton.layer addSublayer:shapeLayer];
         
         shapeLayer.path = myFirstShape.CGPath;

         self.videoPlayer = globals.VIDEO_PLAYER_LIVE2BENCH;
         self.videoPlayer.antiFreeze.enable = YES;   //RICHARD
         [self.videoPlayer.view setFrame:CGRectMake((self.view.bounds.size.width - MEDIA_PLAYER_WIDTH)/2, 100.0f, MEDIA_PLAYER_WIDTH, MEDIA_PLAYER_HEIGHT)];

         [self.view addSubview:self.videoPlayer.view];
         [self.videoPlayer.view addSubview:recordButton];

        [videoPlayer play];

         
         //add swipe gesture: swipe left: seek back ; swipe right: seek forward
         UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(detectSwipe:)];
         [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
         [self.videoPlayer.view addGestureRecognizer:recognizer];
         
         recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(detectSwipe:)];
         [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
         [self.videoPlayer.view addGestureRecognizer:recognizer];
         
     }
    [self.videoPlayer.view setUserInteractionEnabled:TRUE];
     [self createTagButtons]; // temp place
    //if we just started a new event, seek to live automatically
    if(globals.DID_START_NEW_EVENT)
    {
        if ((int)[[[videoPlayer avPlayer]currentItem]status] != 1) {
            globals.CURRENT_PLAYBACK_EVENT = [NSString stringWithFormat:@"%@/events/live/video/list.m3u8",globals.URL];
            NSURL *videoURL = [NSURL URLWithString:globals.CURRENT_PLAYBACK_EVENT];
            //AVPlayer *myPlayer = [AVPlayer playerWithURL:videoURL];
            
            [globals.VIDEO_PLAYER_LIST_VIEW setVideoURL:videoURL];
            [globals.VIDEO_PLAYER_LIST_VIEW setPlayerWithURL:videoURL];
            [globals.VIDEO_PLAYER_LIST_VIEW pause];
            
            [videoPlayer setVideoURL:videoURL];
            [videoPlayer setPlayerWithURL:videoURL];
            [videoPlayer play];

            globals.VIDEO_PLAYBACK_FAILED = FALSE;
            globals.PLAYABLE_DURATION = -1;
        }
                
        if ([globals.EVENT_NAME isEqualToString:@"live"]) {
            if (globals.PLAYBACK_SPEED > 0) {
                videoPlayer.avPlayer.rate = globals.PLAYBACK_SPEED;
            }else{
                [videoPlayer play];
                
            }

        }
        //start new event, go to live
        [_liveButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        globals.DID_START_NEW_EVENT=FALSE;
    }

    //1.first time open the app, initialize all the buttons; 2.when received memory warning, all the UIview will be deleted, so when back to live2bench view, we need to reinitialize all the buttons
    if(!self.didInitLayout || globals.DID_RECEIVE_MEMORY_WARNING)
    {
        [self initialiseLayout];
        [self updateEventInformation];
        globals.DID_RECEIVE_MEMORY_WARNING = FALSE;
    }
    
    [self.view bringSubviewToFront:self.playerCollectionViewController.view];
    [self.view bringSubviewToFront:recordButton];
    
    //playback old event
    if( globals.IS_PAST_EVENT)
    {
        globals.DID_GO_TO_LIVE = FALSE;
    }
    
    //1.when playing live event, if encoder status is not live or paused or player status is not "readytoplay"; 2. there is no event playing: disable all tag buttons
    if((((![globals.CURRENT_ENC_STATUS isEqualToString:encStateLive] && ![globals.CURRENT_ENC_STATUS isEqualToString:encStatePaused])|| (int)[[[videoPlayer avPlayer]currentItem]status] == AVPlayerItemStatusFailed || (int)[[[videoPlayer avPlayer]currentItem]status] == AVPlayerItemStatusUnknown) && ([globals.EVENT_NAME isEqualToString:@"live"]|| [globals.EVENT_NAME isEqualToString:@""])))
    {
        [self.leftSideButtons setUserInteractionEnabled:FALSE];
        [self.leftSideButtons setAlpha:0.6f];
        [self.rightSideButtons setUserInteractionEnabled:FALSE];
        [self.rightSideButtons setAlpha:0.6f];

//        [currentSeekBackButton setHidden:TRUE];
//        [currentSeekForwardButton setHidden:TRUE];
        
        [startRangeModifierButton setHidden:TRUE];
        [endRangeModifierButton setHidden:TRUE];

        
        if([_eventType isEqualToString:@"hockey"]){
            [self.hockeyBottomViewController.view setUserInteractionEnabled:FALSE];
            [self.hockeyBottomViewController.view setAlpha:0.6];
        }else if ([_eventType isEqualToString:@"soccer"] || [_eventType isEqualToString:@"rugby"]){
            [self.soccerBottomViewController.zoneLabel setUserInteractionEnabled:FALSE];
            [self.soccerBottomViewController.zoneLabel setAlpha:0.6];
            [self.soccerBottomViewController.zoneSegmentedControl setUserInteractionEnabled:FALSE];
            [self.soccerBottomViewController.zoneSegmentedControl setAlpha:0.6];
            [self.soccerBottomViewController.halfLabel setUserInteractionEnabled:FALSE];
            [self.soccerBottomViewController.halfLabel setAlpha:0.6];
            [self.soccerBottomViewController.periodSegmentedControl setUserInteractionEnabled:FALSE];
            [self.soccerBottomViewController.periodSegmentedControl setAlpha:0.6];
        }else if([_eventType isEqualToString:@"football"]) {
            [self.footballBottomViewController.view setUserInteractionEnabled:FALSE];
            [self.footballBottomViewController.view setAlpha:0.6];
        }else if([_eventType isEqualToString:@"football training"]) {
            [self.footballTrainingBottomViewController.view setUserInteractionEnabled:FALSE];
            [self.footballTrainingBottomViewController.view setAlpha:0.6];
        }

    }else{
        [self.leftSideButtons setUserInteractionEnabled:TRUE];
        [self.leftSideButtons setAlpha:1.0f];
        [self.rightSideButtons setUserInteractionEnabled:true];
        [self.rightSideButtons setAlpha:1.0f];
        /*
        if (!globals.IS_LOOP_MODE) {
            [currentSeekBackButton setHidden:FALSE];
            [currentSeekForwardButton setHidden:FALSE];
        }
       */
    }
    
    //if current encoder status is "live", enable live button; otherwise, disable it
    if ([globals.CURRENT_ENC_STATUS isEqualToString:encStateLive] || [globals.CURRENT_ENC_STATUS isEqualToString:encStatePaused]) {
        _liveButton.enabled = YES;
//        [liveButtoninFullScreen setEnabled:TRUE];
    }else{
         _liveButton.enabled = NO;
//        [liveButtoninFullScreen setEnabled:FALSE];
    }

    [videoPlayer play];
    
    //clean old tag marker views
//    [self cleanTagMarkers];//888
    
    [_videoBarViewController.tagMarkerController cleanTagMarkers];
    
    
    
    //reset counter variable
    updateTagmarkerCounter = 0;
    //init tag marker lead dictionary
    if (!tagMarkerLeadObjDict) {
        tagMarkerLeadObjDict = [[NSMutableDictionary alloc]init];
    }
    //recreate tagmarkers
//    [self createTagMarkers];//888
    [_videoBarViewController.tagMarkerController createTagMarkers];

    //when selecting a thumbnail in clip view, globals.IS_TAG_PLAYBACK will be set to true, then come to live2bench view, the method "setCurrentPlayingTag" will be called
    if(globals.IS_TAG_PLAYBACK)
    {
        [self setCurrentPlayingTag:globals.CURRENT_PLAYBACK_TAG];
        globals.IS_TAG_PLAYBACK=FALSE;
    }
    
    if (!globals.IS_LOOP_MODE) {
        //if live event, seek to live
        if (videoPlayer.duration >0 && [globals.EVENT_NAME isEqualToString:@"live"] && globals.DID_GO_TO_LIVE) {
            [videoPlayer goToLive];
            [_liveButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        }else if(![globals.EVENT_NAME isEqualToString:@"live"] && globals.FIRST_LOCAL_PLAYBACK){
            //if first time play back old event, start from time 0.1sec;If set from time 0 sec, the video won't start play
            [videoPlayer setTime:0.1];
            [videoPlayer prepareToPlay];
            [videoPlayer play];

        }
    }
    

    //used to alert the video palying back successfully or not
    poorSignalCounter = 0;
    
    //hide seek back&forward control views
//    [seekBackControlView setHidden:TRUE];
//    [seekForwardControlView setHidden:TRUE];
//    [seekBackControlViewinFullScreen setHidden:TRUE];
//    [seekForwardControlViewinFullScreen setHidden:TRUE];
    
    //update seek back&forward buttons
    /*
    if (globals.CURRENT_SEEK_BACK_ACTION == @selector(seekBackQuarterSecond:)) {
        [currentSeekBackButton setImage:[UIImage imageNamed:@"seekbackquartersec.png"] forState:UIControlStateNormal];
    }else if(globals.CURRENT_SEEK_BACK_ACTION == @selector(seekBackOneSecond:)){
        [currentSeekBackButton setImage:[UIImage imageNamed:@"seekbackonesec.png"] forState:UIControlStateNormal];
    }else {
        [currentSeekBackButton setImage:[UIImage imageNamed:@"seekbackfivesecs.png"] forState:UIControlStateNormal];
        globals.CURRENT_SEEK_BACK_ACTION = @selector(seekBackFiveSeconds:);
    }
    [currentSeekBackButton addTarget:self action:globals.CURRENT_SEEK_BACK_ACTION forControlEvents:UIControlEventTouchUpInside];
    
    if (globals.CURRENT_SEEK_FORWARD_ACTION == @selector(seekForwardQuarterSecond:)) {
        [currentSeekForwardButton setImage:[UIImage imageNamed:@"seekforwardquartersec.png"] forState:UIControlStateNormal];
    }else if(globals.CURRENT_SEEK_FORWARD_ACTION == @selector(seekForwardOneSecond:)){
        [currentSeekForwardButton setImage:[UIImage imageNamed:@"seekforwardonesec.png"] forState:UIControlStateNormal];
    }else {
        [currentSeekForwardButton setImage:[UIImage imageNamed:@"seekforwardfivesecs.png"] forState:UIControlStateNormal];
        globals.CURRENT_SEEK_FORWARD_ACTION = @selector(seekForwardFiveSeconds:);
    }
    [currentSeekForwardButton addTarget:self action:globals.CURRENT_SEEK_FORWARD_ACTION forControlEvents:UIControlEventTouchUpInside];
    */
     
    if (globals.UNCLOSED_EVENT || [_eventType isEqualToString:@"football training"]) {
        [self highlightDurationTag];
    }
    
  

    // Richard
    
    _videoBarViewController = [[L2BVideoBarViewController alloc]initWithVideoPlayer:videoPlayer];
    [_videoBarViewController.startRangeModifierButton addTarget:self action:@selector(startRangeBeenModified:) forControlEvents:UIControlEventTouchUpInside];
    [_videoBarViewController.endRangeModifierButton addTarget:self action:@selector(endRangeBeenModified:) forControlEvents:UIControlEventTouchUpInside];
    
    _fullscreenViewController = [[L2BFullScreenViewController alloc]initWithVideoPlayer:videoPlayer];
    _fullscreenViewController.context = @"Live2Bench Tab";
    [self.view addSubview:_fullscreenViewController.view];
    videoPlayer.context = _fullscreenViewController.context;
}



-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.view addSubview:_videoBarViewController.view];
    [_videoBarViewController viewDidAppear:animated];

}
//update full screen buttons when enter fullscreen or exit fullscreen
-(void)updateFullScreenOverlay
{
    if (videoPlayer.isFullScreen && !fullscreenOverlayCreated) {
        enterFullScreen = TRUE;
        //enter full screen
        [self willEnterFullscreen];
        if ( telestrationOverlay) {
            //set the frame size of the telestration overlay to match the thumbnail image
            [telestrationOverlay setFrame:CGRectMake(0, videoPlayer.view.bounds.origin.y + 15, videoPlayer.view.bounds.size.width, videoPlayer.view.bounds.size.height - 15)];
            [telestrationOverlay setContentMode:UIViewContentModeScaleAspectFit];
        }
        
        [recordButton setFrame:CGRectMake(videoPlayer.view.frame.size.width-35,55, 32, 32)];
        [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:recordButton];
        
        fullscreenOverlayCreated = TRUE;
        
    }else if(!videoPlayer.isFullScreen && fullscreenOverlayCreated){
        //exit full screen
        enterFullScreen = FALSE;
        //if telestration in the fullscreen, remove it and destroy loop mode
        if (telestrationOverlay) {
            [telestrationOverlay removeFromSuperview];
            telestrationOverlay = nil;
            [self destroyThumbLoop];
            [videoPlayer play];

        }
        [self willExitFullscreen];
        //[self didExitFullscreen];
        
        //"bringSubviewToFront" is needed; otherwise all the following subviews could not be visible
//        [self.view bringSubviewToFront:self.leftSideButtons];
//        [self.view bringSubviewToFront:self.rightSideButtons];
        if (self.hockeyBottomViewController) {
            [self.view bringSubviewToFront:self.hockeyBottomViewController.view];
        }else if(self.soccerBottomViewController){
            [self.view bringSubviewToFront:self.soccerBottomViewController.view];
        }else if(self.footballBottomViewController){
            [self.view bringSubviewToFront:self.footballBottomViewController.view];
        }else if(self.footballTrainingBottomViewController){
            [self.view bringSubviewToFront:self.footballTrainingBottomViewController.view];
        }
        [self.view bringSubviewToFront:_liveButton];
        [self.view bringSubviewToFront:continuePlayButton];
        [self.view addSubview:videoPlayer.view];
        [self.view bringSubviewToFront:self.playerCollectionViewController.view];

        fullscreenOverlayCreated = FALSE;
        [recordButton setFrame: CGRectMake(MEDIA_PLAYER_WIDTH - 32.0f, 0.0f, 32.0f, 32.0f)];
        [self.videoPlayer.view addSubview:recordButton];
        [self.videoPlayer.view bringSubviewToFront:recordButton];

        /*
        [self.view bringSubviewToFront:seekBackControlView];
        [self.view bringSubviewToFront:seekForwardControlView];
        [seekBackControlView setHidden:TRUE];
        [seekForwardControlView setHidden:TRUE];
        [seekBackControlViewinFullScreen setHidden:TRUE];
        [seekForwardControlViewinFullScreen setHidden:TRUE];
       
        if (globals.CURRENT_SEEK_BACK_ACTION == @selector(seekBackQuarterSecond:)) {
            [currentSeekBackButton setImage:[UIImage imageNamed:@"seekbackquartersec.png"] forState:UIControlStateNormal];
        }else if(globals.CURRENT_SEEK_BACK_ACTION == @selector(seekBackOneSecond:)){
            [currentSeekBackButton setImage:[UIImage imageNamed:@"seekbackonesec.png"] forState:UIControlStateNormal];
        }else {
            [currentSeekBackButton setImage:[UIImage imageNamed:@"seekbackfivesecs.png"] forState:UIControlStateNormal];
            globals.CURRENT_SEEK_BACK_ACTION = @selector(seekBackFiveSeconds:);
        }
        [currentSeekBackButton addTarget:self action:globals.CURRENT_SEEK_BACK_ACTION forControlEvents:UIControlEventTouchUpInside];
        
        if (globals.CURRENT_SEEK_FORWARD_ACTION == @selector(seekForwardQuarterSecond:)) {
            [currentSeekForwardButton setImage:[UIImage imageNamed:@"seekforwardquartersec.png"] forState:UIControlStateNormal];
        }else if(globals.CURRENT_SEEK_FORWARD_ACTION == @selector(seekForwardOneSecond:)){
            [currentSeekForwardButton setImage:[UIImage imageNamed:@"seekforwardonesec.png"] forState:UIControlStateNormal];
        }else {
            [currentSeekForwardButton setImage:[UIImage imageNamed:@"seekforwardfivesecs.png"] forState:UIControlStateNormal];
            globals.CURRENT_SEEK_FORWARD_ACTION = @selector(seekForwardFiveSeconds:);
        }
        [currentSeekForwardButton addTarget:self action:globals.CURRENT_SEEK_FORWARD_ACTION forControlEvents:UIControlEventTouchUpInside];
        */
        
        
        //if the user opens a duration tag in fullscreen mode, when back to normal mode, we need to highlight the button with the selected event name
        if (swipedOutButton && isDurationTagEnabled && swipedOutButton.selected){
            
            for(CustomButton *button in tagButtonsArray){
                if (([button.titleLabel.text isEqual:swipedOutButton.titleLabel.text] && [button.accessibilityValue isEqual:swipedOutButton.accessibilityValue]) || [globals.UNCLOSED_EVENT isEqualToString:button.titleLabel.text]) {
                    button.selected = TRUE;
                    swipedOutButton = button;
                }
            }
        }
    }
    
    [self.view bringSubviewToFront: self.leftSideButtons];
    [self.view bringSubviewToFront:self.rightSideButtons];
}

- (void)removeLiveSpinner
{
    [spinnerView removeSpinner];
    
}

///we are going to update the global variable every second if the stored value is less then the current duration.
-(void)updateCurrentEventInfo
{
    
    if(globals.STOP_TIMERS_FROM_LOGOUT)
    {
        return;
    }

    //send new tag information to the server
    if (globals.ARRAY_OF_TAGSET.count >0) {
        [self sendTagInformationToServer];
    }
    
    if(!globals.IS_PAST_EVENT)
    {
        CGFloat duration = videoPlayer.duration;
        NSDate* startDate = [NSDate dateWithTimeIntervalSinceNow:-1*duration];
        globals.eventStartDate = startDate;
    }
    
    //if the live event is not properly playing or not event playing ,gray the all the tag buttons
    if(((![globals.CURRENT_ENC_STATUS isEqualToString:encStateLive] && ![globals.CURRENT_ENC_STATUS isEqualToString:encStatePaused]) || (int)[[[videoPlayer avPlayer]currentItem]status] == AVPlayerItemStatusFailed || (int)[[[videoPlayer avPlayer]currentItem]status] == AVPlayerItemStatusUnknown) && ([globals.EVENT_NAME isEqualToString:@"live"]|| [globals.EVENT_NAME isEqualToString:@""]))
    {
        
        //if the current event is live and just started, give video player 40 seconds to prepare for playing, else 10 seconds;
        //if after the errorCount time, the event is still not playing properly, will show the error alert view
        int errorCount;
        if(globals.DID_START_NEW_EVENT){
            errorCount = 40;
        }else{
            errorCount = 10;
        }

        if (![globals.EVENT_NAME isEqualToString:@""] && !globals.VIDEO_PLAYBACK_FAILED) {
            //show spinner view if live event not playing properly in 10s
            [spinnerView removeSpinner];
            spinnerView = nil;
            if (spinnerViewCounter < errorCount) {
                spinnerView = [SpinnerView loadSpinnerIntoView:[[[UIApplication sharedApplication]windows]objectAtIndex:0 ]];
            }else{
                //if the video player not playing properly for more than 10s, remove spinner view
                if (spinnerView) {
                    [spinnerView removeSpinner];
                    spinnerView = nil;
                }

            }
            spinnerViewCounter++;
        }else{
            //if live event stopped or video playback failed alert view pop up, remove the spinner view
            if (spinnerView) {
                [spinnerView removeSpinner];
                spinnerView = nil;
            }
            spinnerViewCounter = 0;
        }
        
        
//        if (spinnerViewCounter >= errorCount - 1) {
//            if (spinnerView) {
//                [spinnerView removeSpinner];
//                spinnerView = nil;
//            }
//        }
        
        //***********************************TODO: if the wifi connection of the ipad lost, handle the case*********************************//
        //if the live event stopped, check if the wifi still there
        if(([globals.CURRENT_ENC_STATUS isEqualToString:encStateStopped]||[globals.CURRENT_ENC_STATUS isEqualToString:@""]) && [globals.EVENT_NAME isEqualToString: @"live"] && globals.HAS_WIFI){
            //if the wifi is turned off
            globals.HAS_WIFI = [uController hasConnectivity];
            if (!globals.HAS_WIFI) {
                [spinnerView removeSpinner];
                spinnerView = nil;
                spinnerViewCounter = 0;
                CustomAlertView *alert = [[CustomAlertView alloc]
                                      initWithTitle: @"myplayXplay"
                                      message: @"No wifi available."
                                      delegate: nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
                [alert show];
//                [globals.ARRAY_OF_POPUP_ALERT_VIEWS addObject:alert];
            }
        }
        
        //if lose wifi in live event, keep checking is wifi reconnected
        if ([globals.EVENT_NAME isEqualToString:@"live"] && !globals.HAS_WIFI) {
            globals.HAS_WIFI = [uController hasConnectivity];
            if (globals.HAS_WIFI) {
                //if wifi comes back, remove all the request in the app_queue
                [globals.APP_QUEUE.queue removeAllObjects];
            }
        }
        
        NSString *playerStatus;
        if ((int)[[[videoPlayer avPlayer]currentItem]status] == 0) {
            
            //playerStatus = @"avplayerUnknown";
            if (![globals.CURRENT_PLAYBACK_EVENT isEqualToString:@""]) {
                poorSignalCounter++;
            }
            
            //if the video is not playing properly in 60 secs, remove the spinnerView and pop up a alert that video playback failed
            if (!videoPlaybackFailedAlertView && [globals.CURRENT_ENC_STATUS isEqualToString:encStateLive] && poorSignalCounter > 9 && !globals.VIDEO_PLAYBACK_FAILED) {
                //reset video player every 10 seconds for 6 times
                if (poorSignalCounter > 0 && poorSignalCounter%10 == 0) {
                    
//                    //for testing
//                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"myplayXplay" message:[NSString stringWithFormat:@"reset video player in live2bench view, status unknown; poorSignalCounter: %d",poorSignalCounter] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                    [alert show];

                    [videoPlayer resetAvplayer];
                    //go to live after 3 seconds delay
                    [videoPlayer performSelector:@selector(goToLive) withObject:nil afterDelay:5];
                }else if(poorSignalCounter > 60){
                    //if the video is not playing properly in 50 secs, remove the spinnerView and pop up a alert that video playback failed
                    globals.VIDEO_PLAYBACK_FAILED = TRUE;
                    if (spinnerView) {
                        [spinnerView removeSpinner];
                        spinnerView = nil;
                    }
                    videoPlaybackFailedAlertView = [[UIAlertView alloc]initWithTitle:@"myplayXplay" message:@"Video play back error. Please check the network condition and hardware connection." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [videoPlaybackFailedAlertView show];
//                    [globals.ARRAY_OF_POPUP_ALERT_VIEWS addObject:videoPlaybackFailedAlertView];
                    //if the video playback failed, set the video url to @"", donot continue to try to reset the url
                    NSURL *videoURL = [NSURL URLWithString:@""];
                    //AVPlayer *myPlayer = [AVPlayer playerWithURL:videoURL];
                    
                    [globals.VIDEO_PLAYER_LIST_VIEW setVideoURL:videoURL];
                    [globals.VIDEO_PLAYER_LIST_VIEW setPlayerWithURL:videoURL];
                    
                    [globals.VIDEO_PLAYER_LIVE2BENCH setVideoURL:videoURL];
                    [globals.VIDEO_PLAYER_LIVE2BENCH setPlayerWithURL:videoURL];
                    

                }
            }
            
        }else if((int)[[[videoPlayer avPlayer] currentItem] status] == 1){
            poorSignalCounter = 0;
            //playerStatus = @"avplayerReadyToPlay";
           
        }else if((int)[[[videoPlayer avPlayer]currentItem]status] == 2){
            poorSignalCounter = 0;
                globals.VIDEO_PLAYBACK_FAILED = TRUE;
                if (spinnerView) {
                    [spinnerView removeSpinner];
                    spinnerView = nil;
                }

            
        }

        
        [self.leftSideButtons setUserInteractionEnabled:FALSE];
        [self.leftSideButtons setAlpha:0.6];
        
        [self.rightSideButtons setUserInteractionEnabled:FALSE];
        [self.rightSideButtons setAlpha:0.6];
        
        [self.overlayLeftViewController.view setUserInteractionEnabled:FALSE];
        [self.overlayRightViewController.view setUserInteractionEnabled:FALSE];
        if (!isModifyingPlaybackRate) {
            [self.overlayLeftViewController.view setAlpha:0.6];
            [self.overlayRightViewController.view setAlpha:0.6];
        }
        
        [recordButton setHidden:TRUE];
//        [liveButtoninFullScreen setEnabled:FALSE];
  /*
        [currentSeekBackButton setHidden:TRUE];
        [currentSeekForwardButton setHidden:TRUE];
    */
        [startRangeModifierButton setHidden:TRUE];
        [endRangeModifierButton setHidden:TRUE];
        
        if([_eventType isEqualToString:@"hockey"]){
            [self.hockeyBottomViewController.view setUserInteractionEnabled:FALSE];
            [self.hockeyBottomViewController.view setAlpha:0.6];
        }else if ([_eventType isEqualToString:@"soccer"] || [_eventType isEqualToString:@"rugby"]){
            [self.soccerBottomViewController.zoneLabel setUserInteractionEnabled:FALSE];
            [self.soccerBottomViewController.zoneLabel setAlpha:0.6];
            [self.soccerBottomViewController.zoneSegmentedControl setUserInteractionEnabled:FALSE];
            [self.soccerBottomViewController.zoneSegmentedControl setAlpha:0.6];
            [self.soccerBottomViewController.halfLabel setUserInteractionEnabled:FALSE];
            [self.soccerBottomViewController.halfLabel setAlpha:0.6];
            [self.soccerBottomViewController.periodSegmentedControl setUserInteractionEnabled:FALSE];
            [self.soccerBottomViewController.periodSegmentedControl setAlpha:0.6];
        }else if([_eventType isEqualToString:@"football"]) {
            [self.footballBottomViewController.view setUserInteractionEnabled:FALSE];
            [self.footballBottomViewController.view setAlpha:0.6];
        }else if([_eventType isEqualToString:@"football training"]) {
            [self.footballTrainingBottomViewController.view setUserInteractionEnabled:FALSE];
            [self.footballTrainingBottomViewController.view setAlpha:0.6];
        }
        
    }else{

        
        if (spinnerView) {
            [spinnerView removeSpinner];
    
            spinnerView = nil;
        }
        
        /*
        if (!globals.IS_LOOP_MODE) {
            [currentSeekBackButton setHidden:FALSE];
            [currentSeekForwardButton setHidden:FALSE];
        }
        */
        
        [self.leftSideButtons setUserInteractionEnabled:TRUE];
        [self.leftSideButtons setAlpha:1.0];
        
        [self.rightSideButtons setUserInteractionEnabled:TRUE];
        [self.rightSideButtons setAlpha:1.0];
        
        [self.overlayLeftViewController.view setUserInteractionEnabled:TRUE];
        [self.overlayRightViewController.view setUserInteractionEnabled:TRUE];
        if (!isModifyingPlaybackRate) {
            [self.overlayLeftViewController.view setAlpha:1.0];
            [self.overlayRightViewController.view setAlpha:1.0];
        }
        
        if(![globals.CURRENT_ENC_STATUS isEqualToString:encStateLive]) // if it isn't a live game playing right now then we don't want to show the record button
        {
            [recordButton setHidden:TRUE];
        }else{
            [recordButton setHidden:FALSE];
        }
        
            if([_eventType isEqualToString:@"hockey"]){
                [self.hockeyBottomViewController.view setUserInteractionEnabled:TRUE];
                [self.hockeyBottomViewController.view setAlpha:1.0];
            }else if ([_eventType isEqualToString:@"soccer"] || [_eventType isEqualToString:@"rugby"]){
                [self.soccerBottomViewController.zoneLabel setUserInteractionEnabled:TRUE];
                [self.soccerBottomViewController.zoneLabel setAlpha:1.0];
                [self.soccerBottomViewController.zoneSegmentedControl setUserInteractionEnabled:TRUE];
                [self.soccerBottomViewController.zoneSegmentedControl setAlpha:1.0];
                [self.soccerBottomViewController.halfLabel setUserInteractionEnabled:TRUE];
                [self.soccerBottomViewController.halfLabel setAlpha:1.0];
                [self.soccerBottomViewController.periodSegmentedControl setUserInteractionEnabled:TRUE];
                [self.soccerBottomViewController.periodSegmentedControl setAlpha:1.0];
            }else if([_eventType isEqualToString:@"football"]) {
                [self.footballBottomViewController.view setUserInteractionEnabled:TRUE];
                [self.footballBottomViewController.view setAlpha:1.0];
            }else if([_eventType isEqualToString:@"football training"]) {
                [self.footballTrainingBottomViewController.view setUserInteractionEnabled:TRUE];
                [self.footballTrainingBottomViewController.view setAlpha:1.0];
            }
        }
        
    
        [self.view setUserInteractionEnabled:TRUE];
    
    //enable live button if the current encoder status is @"live", otherwise disable it
    if ([globals.CURRENT_ENC_STATUS isEqualToString:encStateLive] || [globals.CURRENT_ENC_STATUS isEqualToString:encStatePaused]) {
        _liveButton.enabled = YES;
//        [liveButtoninFullScreen setEnabled:TRUE];
    }else{
         _liveButton.enabled = NO;
//        [liveButtoninFullScreen setEnabled:FALSE];
    }
    
    if ([globals.CURRENT_PLAYBACK_EVENT isEqualToString:@""]){ 
        //if no event playing, leave the bottom view blank
        [self.hockeyBottomViewController.view setHidden:TRUE];
        [self.soccerBottomViewController.view setHidden:TRUE];
    }else{
        //show record button if playing live game
        if ([globals.EVENT_NAME isEqualToString:@"live"]){
            recordButton.alpha = 1.0f;
            [UIImageView animateWithDuration:0.5f
                                       delay:0.0
                                     options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse
                                  animations:^{
                                      recordButton.alpha = 0.0f;
                                  }
                                  completion:^(BOOL finished){
                                  }];
            [self.hockeyBottomViewController.view setHidden:FALSE];
            [self.soccerBottomViewController.view setHidden:FALSE];
        }
        
    }
    //if we just started a new event, reset video url and  seek to live automatically
    if(globals.DID_START_NEW_EVENT && globals.DID_RECV_GAME_TAGS)
    {
        if ((int)[[[videoPlayer avPlayer]currentItem]status] != 1) {
            globals.CURRENT_PLAYBACK_EVENT = [NSString stringWithFormat:@"%@/events/live/video/list.m3u8",globals.URL];
            NSURL *videoURL = [NSURL URLWithString:globals.CURRENT_PLAYBACK_EVENT];
            //AVPlayer *myPlayer = [AVPlayer playerWithURL:videoURL];
            
            [globals.VIDEO_PLAYER_LIST_VIEW setVideoURL:videoURL];
            [globals.VIDEO_PLAYER_LIST_VIEW setPlayerWithURL:videoURL];
            [globals.VIDEO_PLAYER_LIST_VIEW pause];
            
            [videoPlayer setVideoURL:videoURL];
            [videoPlayer setPlayerWithURL:videoURL];
            [videoPlayer play];

            globals.VIDEO_PLAYBACK_FAILED = FALSE;
            globals.PLAYABLE_DURATION = -1;
            //tagMarkerLoopCounter = 20;
        }
        globals.DID_START_NEW_EVENT=FALSE;
        globals.DID_RECV_GAME_TAGS = FALSE;
        [_liveButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    globals.GLOBAL_PLAYED_DURATION = videoPlayer.duration;
    
    //create tagmarkers for the new tags get from syncme callback
    if(globals.NEW_TAGS_FROM_SYNC.count>0)
    {
        NSString *color;
       // NSString *startTime;
        float tagTime;
        NSString *tagName;
        UIColor *tagColour;
        
        NSMutableDictionary *UIColourDict;
        for(NSMutableDictionary *oneTag in globals.NEW_TAGS_FROM_SYNC){
            if ([oneTag objectForKey:@"time"] && [[oneTag objectForKey:@"type"]integerValue]!=3 && [[oneTag objectForKey:@"type"]integerValue]!=8 && [[oneTag objectForKey:@"type"]integerValue]!=18 && [[oneTag objectForKey:@"type"]integerValue]!=22 && !([[oneTag objectForKey:@"type"]integerValue]&1)) {
                color = [oneTag objectForKey:@"colour"];
                if ([UIColourDict count] == 0){
                    tagColour = [uController colorWithHexString:color];
                    UIColourDict = [NSMutableDictionary dictionaryWithObject:tagColour forKey:color];
                } else {
                    if (![UIColourDict objectForKey:color]){
                        tagColour = [uController colorWithHexString:color];
                        [UIColourDict setObject:tagColour forKey:color];
                    }
                }
                
                tagColour = [UIColourDict objectForKey:color];
                //startTime = [oneTag objectForKey:@"starttime"];
                //tagName = [oneTag objectForKey:@"name"];
                tagTime = [[oneTag objectForKey:@"time"] floatValue];
                [self markTagAtTime:tagTime colour:tagColour tagID:[NSString stringWithFormat:@"%@",[oneTag objectForKey:@"id"]]];
                //[self markTag:tagTime name:tagName colour:tagColour tagID: [[oneTag objectForKey:@"id"] doubleValue]];
            }
        }
        globals.NEW_TAGS_FROM_SYNC=nil;
    }
    //playback old event
    if (![globals.EVENT_NAME isEqualToString:@"live"] && globals.FIRST_LOCAL_PLAYBACK) {
        [videoPlayer play];
        globals.FIRST_LOCAL_PLAYBACK=FALSE;
    }
    
    //current playback time 
    currentPlayBackTime = CMTimeGetSeconds(videoPlayer.avPlayer.currentTime);
    
    //if get tagnames from sync2cloudcallback, update tag buttons 
    if(globals.DID_RECV_TAG_NAMES)
    {
        globals.TAG_BTNS_REQ_SENT=FALSE;
        [self populateTagNames];
//        [self createTagButtons];//888
        [_videoBarViewController.tagMarkerController createTagMarkers];
    }
    [self.view setNeedsDisplay];
    
    /*
    if (tagMarkerLeadObjDict.count < 1 ) {
        //if just start playing back an old event, the duration of the video might be 0. In this case no tag markers will be created.
        //Here, we check if there is no tag markers but there is tags for the current event, call the createTagMarkers method to generate all the tag markers
        if (globals.CURRENT_EVENT_THUMBNAILS.count > 0) {
            [self cleanTagMarkers];
            [self createTagMarkers];
        }
        
    }else{
        updateTagmarkerCounter++;
        //if the user stays in the live2bench view for more than half a minute, recreate of all the lead tagmarker views;
        //else just update the positions of the tagmarkers;
        if (updateTagmarkerCounter > 30) {
            //clean tag markers
            [self cleanTagMarkers];
            //recreate tag markers
            [self createTagMarkers];
            updateTagmarkerCounter = 0;
        }else{
            //update tagmarker position
            float liveTime = MAX(globals.PLAYABLE_DURATION, videoPlayer.duration);
            
            if (liveTime > 0) {
                NSArray *tempArr = [tagMarkerLeadObjDict allKeys];
                //update the lead tagmarkers according to the current video duration
                for(NSString *leadXValue in tempArr){
                    NSMutableDictionary *leadDict = [[tagMarkerLeadObjDict objectForKey:leadXValue] mutableCopy];
                    float newXValue = [self xValueForTime:[[leadDict objectForKey:@"leadTime"]doubleValue] atLiveTime:liveTime];
                    if(newXValue > self.tagSetView.frame.size.width)
                    {
                        newXValue = self.tagSetView.frame.size.width;
                    }
                    TagMarker *lead = [leadDict objectForKey:@"lead"];
                    lead.xValue = newXValue;
                    CGRect oldLeadMarkerFrame = lead.markerView.frame;
                    [lead.markerView setFrame:CGRectMake(newXValue, oldLeadMarkerFrame.origin.y, oldLeadMarkerFrame.size.width, oldLeadMarkerFrame.size.height)];
                    
                    //if the xValue changed, update the lead tagmarker dictionary: tagMarkerLeadObjDict
                    if ([leadXValue floatValue] != newXValue) {
                        [tagMarkerLeadObjDict removeObjectForKey:leadXValue];
                        [tagMarkerLeadObjDict setObject:leadDict forKey:[NSString stringWithFormat:@"%f",newXValue]];
                    }
                }
            }
       
        }
    }
  *///888
    //if a tag is playing currently, update the position of the currentPlayingEventMarker(small orange triangle) according to the lead tagmarker's position
    if (globals.IS_LOOP_MODE) {
        
        //NOTE: [NSString stringWithFormat:@"%@",[globals.CURRENT_PLAYBACK_TAG objectForKey:@"id"]] is very important for a key value of a dictionary, otherwise currentPlayingTagMarker will be nil value
                TagMarker *currentPlayingTagMarker = [globals.TAG_MARKER_OBJ_DICT objectForKey:[NSString stringWithFormat:@"%@",[globals.CURRENT_PLAYBACK_TAG objectForKey:@"id"]]];
                CGRect oldFrame = self.currentPlayingEventMarker.frame;
                [self.currentPlayingEventMarker setFrame:CGRectMake(currentPlayingTagMarker.leadTag.xValue -7, oldFrame.origin.y,oldFrame.size.width, oldFrame.size.height)];
                self.currentPlayingEventMarker.hidden = FALSE;
//                break;
//            }
//        }
    }
  
    // Richard
    [_videoBarViewController update];
    
    
}

/*
//clean all the old tag markers
-(void)cleanTagMarkers{
    
//    for(UIView *markerView in self.tagSetView.subviews){
//        if ([markerView.accessibilityLabel isEqualToString:@"marker"]) {
//            [markerView removeFromSuperview];
//        }
//    }
    
    [globals.TAG_MARKER_OBJ_DICT removeAllObjects];
    [tagMarkerLeadObjDict removeAllObjects];
    
}
*///888


/*
//create tag markers for all the tags
-(void)createTagMarkers
{
    isCreatingAllTagMarkers = TRUE;
        
    NSString *color;
    float tagTime;
    NSMutableDictionary *UIColourDict;
    UIColor *tagColour;
    for(NSMutableDictionary *oneTag in [globals.CURRENT_EVENT_THUMBNAILS allValues]){
        //if the tag was deleted(type == 3) or type == 8 , don't create marker
        if ([oneTag objectForKey:@"time"] && [[oneTag objectForKey:@"type"]integerValue]!=3 && [[oneTag objectForKey:@"type"]integerValue]!=8 && [[oneTag objectForKey:@"type"]integerValue]!=18 && [[oneTag objectForKey:@"type"]integerValue]!=22 && !([[oneTag objectForKey:@"type"]integerValue]&1)) {
            color = [oneTag objectForKey:@"colour"];
            
            if ([UIColourDict count] == 0){
                tagColour = [uController colorWithHexString:color];
                UIColourDict = [NSMutableDictionary dictionaryWithObject:tagColour forKey:color];
            } else {
                if (![UIColourDict objectForKey:color]){
                    tagColour = [uController colorWithHexString:color];
                    [UIColourDict setObject:tagColour forKey:color];
                }
            }
            
            tagColour = [UIColourDict objectForKey:color];
            tagTime = [[oneTag objectForKey:@"time"] floatValue];
        
            //create tag marker for this tag
            [self markTagAtTime:tagTime colour:tagColour tagID:[NSString stringWithFormat:@"%@",[oneTag objectForKey:@"id"]]];
        }
    }

    //NSLog(@"tagMarkerLeadObjDict: %@, videoplayer.duration: %f",tagMarkerLeadObjDict,videoPlayer.duration);
    //go through all the tag marker leads and create all the tag maker views
    [self createAllTagmarkerViews];

}
*///888
 
/*
//create tag marker views for all the tags
-(void)createAllTagmarkerViews{
    //NSLog(@"create all tag marker views!");
    //create the tag marker view for each lead tagmarker in the dictionary: tagMarkerLeadObjDict
    for(NSMutableDictionary *leadDict in [tagMarkerLeadObjDict allValues]){
        //NSLog(@"creating tagmarker view for lead tag!!!!!!!");
        TagMarker *mark = [leadDict objectForKey:@"lead"];
        if (mark.markerView) {
            [mark.markerView removeFromSuperview];
            mark.markerView = nil;
        }
        mark.markerView = [[UIView alloc]initWithFrame:CGRectMake(mark.xValue, 0.0f, 5.0f, 40.0f)];
        [mark.markerView setAccessibilityLabel:@"marker"];
        //mark.marker.frame = CGRectMake(mark.xValue, 0.0f, 5.0f, 40.0f);
//        [self.tagSetView insertSubview:mark.markerView belowSubview:self.tagEventName];
        int numMarks = [[leadDict objectForKey:@"colorArr"]count];
        NSArray *tempColorArr = [leadDict objectForKey:@"colorArr"];
        //create subviews according to the color array saved in the lead dictionary
        if (numMarks != 1){
            for (int i = 0; i < numMarks; i++)
            {
                UIView *colorView = [[UIView alloc]initWithFrame:CGRectMake(0, i*(40.0f/numMarks), 5.0f, 40.0f/numMarks)];
                [colorView setBackgroundColor:[tempColorArr objectAtIndex:i]];
                [mark.markerView addSubview:colorView];
            }
        }else{
            [mark.markerView setBackgroundColor:mark.color];
        }
    }

    isCreatingAllTagMarkers = FALSE;
}
*///888

//looping tag
- (void)handleThumbnailLoop
{
    if(globals.STOP_TIMERS_FROM_LOGOUT)
    {
        return;
    }
    
    if (isnan([videoPlayer currentTimeInSeconds]))
    {
        return;
        
    }else{
        
        //play telestration
        if (globals.IS_PLAYBACK_TELE) {
            
            if ([globals.CURRENT_PLAYBACK_EVENT rangeOfString:@".m3u8"].location != NSNotFound || globals.IS_LOCAL_PLAYBACK) {
                
                [videoPlayer pause];
                
                if (telestrationOverlay) {
                    
                    [videoPlayer.avPlayer seekToTime:CMTimeMakeWithSeconds(globals.HOME_START_TIME, 1.0) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
                    
                    [videoPlayer pause];
                    
                }else{
                    
                    //set the frame size of the telestration overlay to match the thumbnail image
                    
                    telestrationOverlay=[[UIImageView alloc]initWithFrame:CGRectMake(videoPlayer.view.frame.origin.x, videoPlayer.view.frame.origin.y+ 6,videoPlayer.view.frame.size.width, videoPlayer.playerFrame.size.height)];
                    
                    [telestrationOverlay setClipsToBounds:TRUE];
                    
                    [telestrationOverlay setBackgroundColor:[UIColor clearColor]];
                    
                    [telestrationOverlay setContentMode:UIViewContentModeScaleAspectFill];
                    
                    NSString *teleImageName = [[globals.CURRENT_PLAYBACK_TAG objectForKey:@"teleurl"] lastPathComponent];
                    
                    NSString *tUrl = [globals.THUMBNAILS_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",teleImageName]];
                    
                    telestrationOverlay.image = [[UIImage alloc] initWithContentsOfFile:tUrl];
                    
                    [videoPlayer.view  addSubview:telestrationOverlay];
                    
                    if (isViewTeleButtonSelected) {
                        isViewTeleButtonSelected = FALSE;
                        //set the frame size of the telestration overlay to match the thumbnail image
                        [telestrationOverlay setFrame:CGRectMake(0, videoPlayer.view.bounds.origin.y+10, videoPlayer.view.bounds.size.width, videoPlayer.view.bounds.size.height)];
                        [telestrationOverlay setContentMode:UIViewContentModeScaleAspectFit];

                    }
                  
                }
            }else{
                
                //TODO: playing telestration off with mp4 format
                
                if (telestrationOverlay) {
                    
                    [videoPlayer.avPlayer seekToTime:CMTimeMakeWithSeconds(globals.HOME_START_TIME, 1.0) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
                        
                    [videoPlayer pause];
                        
                    }];
                    
                }else{
                    
                    //set the frame size of the telestration overlay to match the thumbnail image
                    
                    telestrationOverlay=[[UIImageView alloc]initWithFrame:CGRectMake(videoPlayer.view.frame.origin.x, videoPlayer.view.frame.origin.y+ 6,videoPlayer.view.frame.size.width, videoPlayer.playerFrame.size.height)];
                    
                    [telestrationOverlay setClipsToBounds:TRUE];
                    
                    [telestrationOverlay setBackgroundColor:[UIColor clearColor]];
                    
                    [telestrationOverlay setContentMode:UIViewContentModeScaleAspectFill];
                    
                    NSString *teleImageName = [[globals.CURRENT_PLAYBACK_TAG objectForKey:@"teleurl"] lastPathComponent];
                    
                    NSString *tUrl = [globals.THUMBNAILS_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",teleImageName]];
                    
                    telestrationOverlay.image = [[UIImage alloc] initWithContentsOfFile:tUrl];
                    
                    [videoPlayer.view  addSubview:telestrationOverlay];
                    
                }
            }
        }else if(!globals.IS_PLAYBACK_TELE){
            //play normal tags
            if (self.videoPlayer.currentTimeInSeconds >= globals.HOME_END_TIME || (self.videoPlayer.currentTimeInSeconds <= globals.HOME_START_TIME -1)){ //&& !self.videoPlayer.isLoopMode)) {
                [self.videoPlayer.avPlayer seekToTime:CMTimeMakeWithSeconds(globals.HOME_START_TIME, 1.0)];
                [self.videoPlayer setTime:globals.HOME_START_TIME];
                sleep(1);
                [self.videoPlayer prepareToPlay];
                [self.videoPlayer play];
//                self.videoPlayer.isLoopMode = TRUE;
                
            }
            if(self.videoPlayer.avPlayer.rate > 0)
            {
                [self.videoPlayer play];

            }
        
        }
    }
}

//destroy thumbnail looping
- (void)destroyThumbLoop
{
    //remove the observer for looping tag
    if (loopTagObserver) {
        [videoPlayer.avPlayer removeTimeObserver:loopTagObserver];
        loopTagObserver = nil;
    }
    
    
    
    globals.IS_PLAYBACK_TELE = FALSE;
    globals.IS_TAG_PLAYBACK = FALSE;
//    [self.tagEventName setHidden:TRUE];//888
    [self.currentPlayingEventMarker setHidden:TRUE];
    [self.startRangeModifierButton setHidden:TRUE];
    [self.endRangeModifierButton setHidden:TRUE];
//    [self.currentSeekBackButton setHidden:FALSE];
//    [self.currentSeekForwardButton setHidden:FALSE];
//    [slowMoButtoninFullScreen setHidden:FALSE];
    [self.continuePlayButton setHidden:TRUE];
    //remove the telestration overlay
    if(telestrationOverlay)
    {
        [telestrationOverlay removeFromSuperview];
        telestrationOverlay = nil;
    }
    //if is in fullscreen, remove buttons for loop mode and create buttons for normal mode
    if (videoPlayer.isFullScreen && globals.IS_LOOP_MODE) {
        [startRangeModifierButtoninFullScreen setHidden:TRUE];
        [endRangeModifierButtoninFullScreen setHidden:TRUE];
/*TO DELETE        [continuePlayButtoninFullScreen setHidden:TRUE];*/
        [self removeFullScreenOverlayButtonsinLoopMode];
        [self createFullScreenOverlayButtons];
    }
    
    globals.IS_LOOP_MODE = FALSE;
}


-(void)viewWillDisappear:(BOOL)animated
{
     globals.IS_IN_FIRST_VIEW = FALSE;
    //will leaving live2bench view,pause video
    if (globals.CURRENT_PLAYBACK_EVENT && ![globals.CURRENT_PLAYBACK_EVENT isEqualToString:@""]) {
        [videoPlayer pause];
        if (videoPlayer.timeObserver) [videoPlayer removePlayerItemTimeObserver];
    }
    //if navigating to other view while video player is still in fullscreen mode, call the exit fullscreen method
    if (videoPlayer.isFullScreen) {
         [videoPlayer exitFullScreen];
    }

    //if was viewing telestartion, remove it
    if (telestrationOverlay) {
        [telestrationOverlay removeFromSuperview];
        telestrationOverlay = nil;
    }
    //destroy looping mode
    [self destroyThumbLoop];
    
    //hide playercollectionview and the left/right arrows
    [leftArrow setAlpha:0.0f];
    [rightArrow setAlpha:0.0f];
    [self.playerCollectionViewController.view setAlpha:0.0f];
    [self.footballTrainingCollectionViewController.view setAlpha:0.0f];
    
    globals.DID_RECV_GAME_TAGS=FALSE;
    
    //if the player seeks to live, the globals.RETAINEDPLAYBACKTIME is set to zero; otherwise globals.RETAINEDPLAYBACKTIME is set to current playback time
    if (globals.DID_GO_TO_LIVE) {
        globals.RETAINEDPLAYBACKTIME = 0.0;
    }else{
        globals.RETAINEDPLAYBACKTIME = currentPlayBackTime;
    }
    //when leave live2bench view, stop the updateplayertimer
    [updateCurrentEventInfoTimer invalidate];
    updateCurrentEventInfoTimer = nil;
    
    
    //if current event is downloaded and not exist in the current encoder, save all the tags in local plist file
    if(!globals.HAS_MIN || (globals.HAS_MIN && !globals.eventExistsOnServer)){
       [uController writeTagsToPlist];
    }
//    [globals.ARRAY_OF_POPUP_ALERT_VIEWS removeAllObjects];
    [CustomAlertView removeAll];
    
    /*
    //clean tag markers
    [self cleanTagMarkers];
     *///888
    [_videoBarViewController.tagMarkerController cleanTagMarkers];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//    [globals.ARRAY_OF_POPUP_ALERT_VIEWS removeObject:alertView];
    [CustomAlertView removeAlert:alertView];
}



//snap to live
- (void)goToLive
{
    globals.IS_TELE=FALSE;
    
    globals.eventExistsOnServer = TRUE;
    globals.DID_GO_TO_LIVE = TRUE;
    globals.IS_PLAYBACK_TELE = FALSE;
    
//    check if already playing a live game
    if([globals.EVENT_NAME isEqualToString:@"live"]){
         globals.IS_LOCAL_PLAYBACK = FALSE;
        //go to live, destroy the loop mode
        [self destroyThumbLoop];
        globals.IS_LOOP_MODE = FALSE;
        [videoPlayer goToLive];

        [[NSNotificationCenter defaultCenter ]postNotificationName:@"RestartUpdate" object:nil];
        
       //[self createTagMarkers];

    }else{
        //switchToLiveEvent is set to TRUE. It is used to recreate tagmarkers for the current live event
        switchToLiveEvent = TRUE;
        // if was not playing a live game, show spinner view while reseting everything
        [spinnerView removeSpinner];
        spinnerView = nil;
        spinnerView = [SpinnerView loadSpinnerIntoView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
        //empty the app_queue for the new event
        [globals.APP_QUEUE.queue removeAllObjects];
        globals.WAITING_RESPONSE_FROM_SERVER = FALSE;
        globals.SWITCH_TO_DIFFERENT_EVENT = TRUE;
        videoPlayer.videoURL = nil;
        if (globals.DID_START_NEW_EVENT) {
            globals.DID_START_NEW_EVENT = FALSE;
        }
        //used to update the positions of tag markers
        //tagMarkerLoopCounter = 20;
        //reset event name
        globals.EVENT_NAME = @"live";
        globals.HUMAN_READABLE_EVENT_NAME=@"Live";
        globals.CURRENT_PLAYBACK_EVENT = [NSString stringWithFormat:@"%@/events/live/video/list.m3u8",globals.URL];
        globals.IS_LOCAL_PLAYBACK = FALSE;
        //send request to get all game tags for current live event
        [uController getAllGameTags];
        //reset avplayer
        NSURL *videoURL = [NSURL URLWithString:globals.CURRENT_PLAYBACK_EVENT];
        [self.videoPlayer setVideoURL:videoURL];
        //AVPlayer *myPlayer = [AVPlayer playerWithURL:videoURL];
       
        //set the avplayer for list view
        //[globals.VIDEO_PLAYER_LIST_VIEW setVideoURL:videoURL];
        [globals.VIDEO_PLAYER_LIST_VIEW setPlayerWithURL:videoURL];
        [globals.VIDEO_PLAYER_LIST_VIEW pause];
        
        [videoPlayer setPlayerWithURL:videoURL];
        [videoPlayer prepareToPlay];
        [videoPlayer play];

        globals.VIDEO_PLAYBACK_FAILED = FALSE;
        globals.PLAYABLE_DURATION = -1;

        [currentEventTitle setText:globals.HUMAN_READABLE_EVENT_NAME];
        [currentEventTitle setNeedsDisplay];
        
        globals.THUMBNAILS_PATH = [[globals.EVENTS_PATH stringByAppendingPathComponent:globals.EVENT_NAME] stringByAppendingPathComponent:@"thumbnails"];
        globals.VIDEOS_PATH = [[globals.EVENTS_PATH stringByAppendingPathComponent:globals.EVENT_NAME] stringByAppendingPathComponent:@"videos"];
              
        //Press live, reenable all the control buttons
        [self.leftSideButtons setUserInteractionEnabled:TRUE];
        [self.leftSideButtons setAlpha:1.0f];
        [self.rightSideButtons setUserInteractionEnabled:true];
        [self.rightSideButtons setAlpha:1.0f];
        if([_eventType isEqualToString:@"hockey"]){
            [self.hockeyBottomViewController.view setUserInteractionEnabled:TRUE];
            [self.hockeyBottomViewController.view setAlpha:1.0];
        }else if ([_eventType isEqualToString:@"soccer"] || [_eventType isEqualToString:@"rugby"]){
            [self.soccerBottomViewController.zoneLabel setUserInteractionEnabled:TRUE];
            [self.soccerBottomViewController.zoneLabel setAlpha:1.0];
            [self.soccerBottomViewController.zoneSegmentedControl setUserInteractionEnabled:TRUE];
            [self.soccerBottomViewController.zoneSegmentedControl setAlpha:1.0];
            [self.soccerBottomViewController.halfLabel setUserInteractionEnabled:TRUE];
            [self.soccerBottomViewController.halfLabel setAlpha:1.0];
            [self.soccerBottomViewController.periodSegmentedControl setUserInteractionEnabled:TRUE];
            [self.soccerBottomViewController.periodSegmentedControl setAlpha:1.0];
        }
/*TO DELETE
        [liveButtoninFullScreen setAlpha:1.0];
        [liveButtoninFullScreen setUserInteractionEnabled:TRUE];
 

        [continuePlayButtoninFullScreen setAlpha:1.0];
        [continuePlayButtoninFullScreen  setUserInteractionEnabled:TRUE];
    */
        [teleButton setUserInteractionEnabled:TRUE];
        [teleButton setAlpha:1.0];
        [self.overlayLeftViewController.view setUserInteractionEnabled:TRUE];
        [self.overlayRightViewController.view setUserInteractionEnabled:TRUE];
        if (!isModifyingPlaybackRate) {
            [self.overlayLeftViewController.view setAlpha:1.0];
            [self.overlayRightViewController.view setAlpha:1.0];
        }
        
        [videoPlayer goToLive];
        //clear all the objects for the old event
        if ([globals.TAGGED_ATTS_DICT count])[globals.TAGGED_ATTS_DICT removeAllObjects];
        if ([globals.TAGGED_ATTS_DICT_SHIFT count])[globals.TAGGED_ATTS_DICT_SHIFT removeAllObjects];
        if ([globals.ARRAY_OF_COLOURS count])[globals.ARRAY_OF_COLOURS removeAllObjects];
        //[tagTimesColoured removeAllObjects];
       
        /*
        //clean tag markers
        [self cleanTagMarkers];
        
        *///888
        
        [globals.THUMBS_WERE_SELECTED_CLIPVIEW removeAllObjects];
        [globals.THUMBS_WERE_SELECTED_LISTVIEW removeAllObjects];
        globals.THUMB_WAS_SELECTED_CLIPVIEW = nil;
        globals.THUMB_WAS_SELECTED_LISTVIEW = nil;
    }
   
}

//this method will be called, is switch to live event from old event
-(void)switchToLive
{
    //clean tag markers
//    [self cleanTagMarkers]; //888
    
    //destroy loop mode
    [self destroyThumbLoop];
    globals.IS_LOOP_MODE = FALSE;
    [videoPlayer play];

    globals.DID_RECV_GAME_TAGS=FALSE;
    //create all new tagmarkers
//    [self createTagMarkers];//888
    [_videoBarViewController.tagMarkerController cleanTagMarkers];
    [_videoBarViewController.tagMarkerController createTagMarkers];
}
-(void)detectSwipe:(UISwipeGestureRecognizer *)gestureRecognizer{
    switch (gestureRecognizer.direction) {
        case UISwipeGestureRecognizerDirectionLeft:
            
            if (!enterFullScreen) {
//                 [currentSeekBackButton sendActionsForControlEvents:UIControlEventTouchUpInside];
            }else{
//                 [currentSeekBackButtoninFullScreen sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
            break;
        case UISwipeGestureRecognizerDirectionRight:
            if (!enterFullScreen) {
//                [currentSeekForwardButton sendActionsForControlEvents:UIControlEventTouchUpInside];
            }else{
//                [currentSeekForwardButtoninFullScreen sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
            break;
        default:
            break;
    }
}

//press the cell for more than 2 seconds, pop up the details of the tag and the event
- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    /*
    if ([gestureRecognizer.view isEqual:currentSeekBackButton]) {
         seekBackControlView.hidden = FALSE;
    }else if ([gestureRecognizer.view isEqual:currentSeekForwardButton]){
        seekForwardControlView.hidden = FALSE;
    }else if([gestureRecognizer.view isEqual:currentSeekBackButtoninFullScreen]){
        seekBackControlViewinFullScreen.hidden = FALSE;
    }else if([gestureRecognizer.view isEqual:currentSeekForwardButtoninFullScreen]){
        seekForwardControlViewinFullScreen.hidden = FALSE;
    }
     */
}

/*
-(void)swipeOutSeekControlView:(CustomButton*)button{
    if ([button isEqual:currentSeekBackButton]) {
        seekBackControlView.hidden = FALSE;
    }else if ([button isEqual:currentSeekForwardButton]){
        seekForwardControlView.hidden = FALSE;
    }else if([button isEqual:currentSeekBackButtoninFullScreen]){
        seekBackControlViewinFullScreen.hidden = FALSE;
    }else if([button isEqual:currentSeekForwardButtoninFullScreen]){
        seekForwardControlViewinFullScreen.hidden = FALSE;
    }

}
*/
 
/*
-(void)hideSeekControlView:(id)sender{
    
    seekBackControlView.hidden = TRUE;
    seekForwardControlView.hidden = TRUE;
    seekBackControlViewinFullScreen.hidden = TRUE;
    seekForwardControlViewinFullScreen.hidden = TRUE;

}
*/
#pragma mark - SEEK OLD START
/*
//scrub backwards by 0.25 second
-(void)seekBackQuarterSecond:(id)sender{
     CustomButton *button = (CustomButton*)sender;
    
    if (globals.CURRENT_SEEK_BACK_ACTION != @selector(seekBackQuarterSecond:)) {
        if ( ![button.accessibilityLabel isEqual:@"fullscreen"]) {
            [currentSeekBackButton removeTarget:self action:globals.CURRENT_SEEK_BACK_ACTION forControlEvents:UIControlEventTouchUpInside];
            [currentSeekBackButton setImage:[UIImage imageNamed:@"seekbackquartersec.png"] forState:UIControlStateNormal];
            [currentSeekBackButton addTarget:self action:@selector(seekBackQuarterSecond:) forControlEvents:UIControlEventTouchUpInside];
            globals.CURRENT_SEEK_BACK_ACTION = @selector(seekBackQuarterSecond:);
            
            [currentSeekForwardButton removeTarget:self action:globals.CURRENT_SEEK_FORWARD_ACTION forControlEvents:UIControlEventTouchUpInside];
            [currentSeekForwardButton setImage:[UIImage imageNamed:@"seekforwardquartersec.png"] forState:UIControlStateNormal];
            [currentSeekForwardButton addTarget:self action:@selector(seekForwardQuarterSecond:) forControlEvents:UIControlEventTouchUpInside];
            globals.CURRENT_SEEK_FORWARD_ACTION = @selector(seekForwardQuarterSecond:);
        }else{
            [currentSeekBackButtoninFullScreen removeTarget:self action:globals.CURRENT_SEEK_BACK_ACTION forControlEvents:UIControlEventTouchUpInside];
            [currentSeekBackButtoninFullScreen setImage:[UIImage imageNamed:@"seekbackquarterseclarge.png"] forState:UIControlStateNormal];
            [currentSeekBackButtoninFullScreen addTarget:self action:@selector(seekBackQuarterSecond:) forControlEvents:UIControlEventTouchUpInside];
            globals.CURRENT_SEEK_BACK_ACTION = @selector(seekBackQuarterSecond:);
            
            [currentSeekForwardButtoninFullScreen removeTarget:self action:globals.CURRENT_SEEK_FORWARD_ACTION forControlEvents:UIControlEventTouchUpInside];
            [currentSeekForwardButtoninFullScreen setImage:[UIImage imageNamed:@"seekforwardquarterseclarge.png"] forState:UIControlStateNormal];
            [currentSeekForwardButtoninFullScreen addTarget:self action:@selector(seekForwardQuarterSecond:) forControlEvents:UIControlEventTouchUpInside];
            globals.CURRENT_SEEK_FORWARD_ACTION = @selector(seekForwardQuarterSecond:);
        }
       
    }
    
    seekBackControlView.hidden = TRUE;
    seekForwardControlView.hidden = TRUE;
    seekBackControlViewinFullScreen.hidden = TRUE;
    seekForwardControlViewinFullScreen.hidden = TRUE;
    
    double currentTime = [videoPlayer currentTimeInSeconds];
    
    if (globals.IS_LOOP_MODE){
        //In loop mode
        //if (currentTime-5) is smaller than the tag's start time, just seek to the tag's start time;
        //else seek back 5 secs
        if(currentTime-0.25 <= globals.HOME_START_TIME-1.0) {
            [videoPlayer setTime: globals.HOME_START_TIME];
        }else{
            [videoPlayer seekBack:0.25];
        }
    }else{
        //In normal mode
        //if (currentTime-5) smaller or equal to 0, seek to zero
        //else seek back 5 secs
        if (currentTime-0.25 > 0) {
            [videoPlayer seekBack:0.25];
        }else{
            [videoPlayer setTime:0];
        }
        
    }

}

//scrub backwards by 1 second
-(void)seekBackOneSecond:(id)sender{
    CustomButton *button = (CustomButton*)sender;
    if (globals.CURRENT_SEEK_BACK_ACTION != @selector(seekBackOneSecond:)) {
        if ( ![button.accessibilityLabel isEqual:@"fullscreen"]) {
            [currentSeekBackButton removeTarget:self action:globals.CURRENT_SEEK_BACK_ACTION forControlEvents:UIControlEventTouchUpInside];
            [currentSeekBackButton setImage:[UIImage imageNamed:@"seekbackonesec.png"] forState:UIControlStateNormal];
            [currentSeekBackButton addTarget:self action:@selector(seekBackOneSecond:) forControlEvents:UIControlEventTouchUpInside];
            globals.CURRENT_SEEK_BACK_ACTION = @selector(seekBackOneSecond:);
            
            [currentSeekForwardButton removeTarget:self action:globals.CURRENT_SEEK_FORWARD_ACTION forControlEvents:UIControlEventTouchUpInside];
            [currentSeekForwardButton setImage:[UIImage imageNamed:@"seekforwardonesec.png"] forState:UIControlStateNormal];
            [currentSeekForwardButton addTarget:self action:@selector(seekForwardOneSecond:) forControlEvents:UIControlEventTouchUpInside];
            globals.CURRENT_SEEK_FORWARD_ACTION = @selector(seekForwardOneSecond:);
        }else{
            [currentSeekBackButtoninFullScreen removeTarget:self action:globals.CURRENT_SEEK_BACK_ACTION forControlEvents:UIControlEventTouchUpInside];
            [currentSeekBackButtoninFullScreen setImage:[UIImage imageNamed:@"seekbackoneseclarge.png"] forState:UIControlStateNormal];
            [currentSeekBackButtoninFullScreen addTarget:self action:@selector(seekBackOneSecond:) forControlEvents:UIControlEventTouchUpInside];
            globals.CURRENT_SEEK_BACK_ACTION = @selector(seekBackOneSecond:);
            
            [currentSeekForwardButtoninFullScreen removeTarget:self action:globals.CURRENT_SEEK_FORWARD_ACTION forControlEvents:UIControlEventTouchUpInside];
            [currentSeekForwardButtoninFullScreen setImage:[UIImage imageNamed:@"seekforwardoneseclarge.png"] forState:UIControlStateNormal];
            [currentSeekForwardButtoninFullScreen addTarget:self action:@selector(seekForwardOneSecond:) forControlEvents:UIControlEventTouchUpInside];
            globals.CURRENT_SEEK_FORWARD_ACTION = @selector(seekForwardOneSecond:);
        }
    }
    seekBackControlView.hidden = TRUE;
    seekForwardControlView.hidden = TRUE;
    seekBackControlViewinFullScreen.hidden = TRUE;
    seekForwardControlViewinFullScreen.hidden = TRUE;
    
    double currentTime = [videoPlayer currentTimeInSeconds];
    
    if (globals.IS_LOOP_MODE){
        //In loop mode
        //if (currentTime-5) is smaller than the tag's start time, just seek to the tag's start time;
        //else seek back 5 secs
        if(currentTime-1 <= globals.HOME_START_TIME-1.0) {
            [videoPlayer setTime: globals.HOME_START_TIME];
        }else{
            [videoPlayer seekBack:1.0];
        }
    }else{
        //In normal mode
        //if (currentTime-5) smaller or equal to 0, seek to zero
        //else seek back 5 secs
        if (currentTime-1 > 0) {
            [videoPlayer seekBack:1.0];
        }else{
            [videoPlayer setTime:0];
        }
        
    }

}

//scrub backwards by 5 seconds
- (void)seekBackFiveSeconds:(id)sender
{
    CustomButton *button = (CustomButton*)sender;
    
    if (globals.CURRENT_SEEK_BACK_ACTION != @selector(seekBackFiveSeconds:)) {
         if ( ![button.accessibilityLabel isEqual:@"fullscreen"]) {
             [currentSeekBackButton removeTarget:self action:globals.CURRENT_SEEK_BACK_ACTION forControlEvents:UIControlEventTouchUpInside];
             [currentSeekBackButton setImage:[UIImage imageNamed:@"seekbackfivesecs.png"] forState:UIControlStateNormal];
             [currentSeekBackButton addTarget:self action:@selector(seekBackFiveSeconds:) forControlEvents:UIControlEventTouchUpInside];
             globals.CURRENT_SEEK_BACK_ACTION = @selector(seekBackFiveSeconds:);
             
             [currentSeekForwardButton removeTarget:self action:globals.CURRENT_SEEK_FORWARD_ACTION forControlEvents:UIControlEventTouchUpInside];
             [currentSeekForwardButton setImage:[UIImage imageNamed:@"seekforwardfivesecs.png"] forState:UIControlStateNormal];
             [currentSeekForwardButton addTarget:self action:@selector(seekForwardFiveSeconds:) forControlEvents:UIControlEventTouchUpInside];
             globals.CURRENT_SEEK_FORWARD_ACTION = @selector(seekForwardFiveSeconds:);

         }else{
             [currentSeekBackButtoninFullScreen removeTarget:self action:globals.CURRENT_SEEK_BACK_ACTION forControlEvents:UIControlEventTouchUpInside];
             [currentSeekBackButtoninFullScreen setImage:[UIImage imageNamed:@"seekbackfivesecslarge.png"] forState:UIControlStateNormal];
             [currentSeekBackButtoninFullScreen addTarget:self action:@selector(seekBackFiveSeconds:) forControlEvents:UIControlEventTouchUpInside];
             globals.CURRENT_SEEK_BACK_ACTION = @selector(seekBackFiveSeconds:);
             
             [currentSeekForwardButtoninFullScreen removeTarget:self action:globals.CURRENT_SEEK_FORWARD_ACTION forControlEvents:UIControlEventTouchUpInside];
             [currentSeekForwardButtoninFullScreen setImage:[UIImage imageNamed:@"seekforwardfivesecslarge.png"] forState:UIControlStateNormal];
             [currentSeekForwardButtoninFullScreen addTarget:self action:@selector(seekForwardFiveSeconds:) forControlEvents:UIControlEventTouchUpInside];
             globals.CURRENT_SEEK_FORWARD_ACTION = @selector(seekForwardFiveSeconds:);
         }
    }

    seekBackControlView.hidden = TRUE;
    seekForwardControlView.hidden = TRUE;
    seekBackControlViewinFullScreen.hidden = TRUE;
    seekForwardControlViewinFullScreen.hidden = TRUE;
    
    double currentTime = [videoPlayer currentTimeInSeconds];
    
    if (globals.IS_LOOP_MODE){
        //In loop mode
        //if (currentTime-5) is smaller than the tag's start time, just seek to the tag's start time;
        //else seek back 5 secs
        if(currentTime-5 <= globals.HOME_START_TIME-1.0) {
            [videoPlayer setTime: globals.HOME_START_TIME];
        }else{
            [videoPlayer seekBack:5.0];
        }
    }else{
        //In normal mode
        //if (currentTime-5) smaller or equal to 0, seek to zero
        //else seek back 5 secs
        if (currentTime-5 > 0) {
            [videoPlayer seekBack:5.0];
        }else{
            [videoPlayer setTime:0];
        }
        
    }
}

//scrub backwards by 0.25 second
-(void)seekForwardQuarterSecond:(id)sender{
    
    CustomButton *button = (CustomButton*)sender;
    if (globals.CURRENT_SEEK_FORWARD_ACTION != @selector(seekForwardQuarterSecond:)) {
        if ( ![button.accessibilityLabel isEqual:@"fullscreen"]) {
            [currentSeekForwardButton removeTarget:self action:globals.CURRENT_SEEK_FORWARD_ACTION forControlEvents:UIControlEventTouchUpInside];
            [currentSeekForwardButton setImage:[UIImage imageNamed:@"seekforwardquartersec.png"] forState:UIControlStateNormal];
            [currentSeekForwardButton addTarget:self action:@selector(seekForwardQuarterSecond:) forControlEvents:UIControlEventTouchUpInside];
            globals.CURRENT_SEEK_FORWARD_ACTION = @selector(seekForwardQuarterSecond:);
            
            [currentSeekBackButton removeTarget:self action:globals.CURRENT_SEEK_BACK_ACTION forControlEvents:UIControlEventTouchUpInside];
            [currentSeekBackButton setImage:[UIImage imageNamed:@"seekbackquartersec.png"] forState:UIControlStateNormal];
            [currentSeekBackButton addTarget:self action:@selector(seekBackQuarterSecond:) forControlEvents:UIControlEventTouchUpInside];
            globals.CURRENT_SEEK_BACK_ACTION = @selector(seekBackQuarterSecond:);

        }else{
            [currentSeekForwardButtoninFullScreen removeTarget:self action:globals.CURRENT_SEEK_FORWARD_ACTION forControlEvents:UIControlEventTouchUpInside];
            [currentSeekForwardButtoninFullScreen setImage:[UIImage imageNamed:@"seekforwardquarterseclarge.png"] forState:UIControlStateNormal];
            [currentSeekForwardButtoninFullScreen addTarget:self action:@selector(seekForwardQuarterSecond:) forControlEvents:UIControlEventTouchUpInside];
            globals.CURRENT_SEEK_FORWARD_ACTION = @selector(seekForwardQuarterSecond:);
            
            [currentSeekBackButtoninFullScreen removeTarget:self action:globals.CURRENT_SEEK_BACK_ACTION forControlEvents:UIControlEventTouchUpInside];
            [currentSeekBackButtoninFullScreen setImage:[UIImage imageNamed:@"seekbackquarterseclarge.png"] forState:UIControlStateNormal];
            [currentSeekBackButtoninFullScreen addTarget:self action:@selector(seekBackQuarterSecond:) forControlEvents:UIControlEventTouchUpInside];
            globals.CURRENT_SEEK_BACK_ACTION = @selector(seekBackQuarterSecond:);

        }
        
    }

    seekBackControlView.hidden = TRUE;
    seekForwardControlView.hidden = TRUE;
    seekBackControlViewinFullScreen.hidden = TRUE;
    seekForwardControlViewinFullScreen.hidden = TRUE;
    
    double currentTime = [videoPlayer currentTimeInSeconds];
    if (globals.IS_LOOP_MODE){
        //In loop mode
        //if (currentTime+0.25) is greater than the tag's end time, just seek to the tag's end time;
        //else seek forward 0.25 sec
        if(currentTime+0.25 >=globals.HOME_END_TIME) {
            [videoPlayer setTime: globals.HOME_START_TIME];
        }else{
            [videoPlayer seekForward:0.25];
        }
    }else{
        //In normal mode
        //if (currentTime+0.25) greater or equal to the seekable duration,go to live
        //else seek forward 0.25 sec
        if (currentTime+0.25 < videoPlayer.duration) {
            [videoPlayer seekForward:0.25];
        }else{
            [videoPlayer goToLive];
        }
        
        
    }
    
}

//scrub backwards by 1 second
-(void)seekForwardOneSecond:(id)sender{
    
    CustomButton *button = (CustomButton*)sender;
    
    if (globals.CURRENT_SEEK_FORWARD_ACTION != @selector(seekForwardOneSecond:)) {
        if ( ![button.accessibilityLabel isEqual:@"fullscreen"]) {
            [currentSeekForwardButton removeTarget:self action:globals.CURRENT_SEEK_FORWARD_ACTION forControlEvents:UIControlEventTouchUpInside];
            [currentSeekForwardButton setImage:[UIImage imageNamed:@"seekforwardonesec.png"] forState:UIControlStateNormal];
            [currentSeekForwardButton addTarget:self action:@selector(seekForwardOneSecond:) forControlEvents:UIControlEventTouchUpInside];
            globals.CURRENT_SEEK_FORWARD_ACTION = @selector(seekForwardOneSecond:);
            
            [currentSeekBackButton removeTarget:self action:globals.CURRENT_SEEK_BACK_ACTION forControlEvents:UIControlEventTouchUpInside];
            [currentSeekBackButton setImage:[UIImage imageNamed:@"seekbackonesec.png"] forState:UIControlStateNormal];
            [currentSeekBackButton addTarget:self action:@selector(seekBackOneSecond:) forControlEvents:UIControlEventTouchUpInside];
            globals.CURRENT_SEEK_BACK_ACTION = @selector(seekBackOneSecond:);

        }else{
            [currentSeekForwardButtoninFullScreen removeTarget:self action:globals.CURRENT_SEEK_FORWARD_ACTION forControlEvents:UIControlEventTouchUpInside];
            [currentSeekForwardButtoninFullScreen setImage:[UIImage imageNamed:@"seekforwardoneseclarge.png"] forState:UIControlStateNormal];
            [currentSeekForwardButtoninFullScreen addTarget:self action:@selector(seekForwardOneSecond:) forControlEvents:UIControlEventTouchUpInside];
            globals.CURRENT_SEEK_FORWARD_ACTION = @selector(seekForwardOneSecond:);
            
            [currentSeekBackButtoninFullScreen removeTarget:self action:globals.CURRENT_SEEK_BACK_ACTION forControlEvents:UIControlEventTouchUpInside];
            [currentSeekBackButtoninFullScreen setImage:[UIImage imageNamed:@"seekbackoneseclarge.png"] forState:UIControlStateNormal];
            [currentSeekBackButtoninFullScreen addTarget:self action:@selector(seekBackOneSecond:) forControlEvents:UIControlEventTouchUpInside];
            globals.CURRENT_SEEK_BACK_ACTION = @selector(seekBackOneSecond:);
        }
    }

    
    seekBackControlView.hidden = TRUE;
    seekForwardControlView.hidden = TRUE;
    seekBackControlViewinFullScreen.hidden = TRUE;
    seekForwardControlViewinFullScreen.hidden = TRUE;
    
    double currentTime = [videoPlayer currentTimeInSeconds];
    if (globals.IS_LOOP_MODE){
        //In loop mode
        //if (currentTime+1) is greater than the tag's end time, just seek to the tag's end time;
        //else seek forward 1 sec
        if(currentTime+1 >=globals.HOME_END_TIME) {
            [videoPlayer setTime: globals.HOME_START_TIME];
        }else{
            [videoPlayer seekForward:1.0];
        }
    }else{
        //In normal mode
        //if (currentTime+1) greater or equal to the seekable duration,go to live
        //else seek forward 1 sec
        if (currentTime+1 < videoPlayer.duration) {
            [videoPlayer seekForward:1.0];
        }else{
            [videoPlayer goToLive];
        }
        
        
    }

}


//scrub forward by 5 seconds
- (void)seekForwardFiveSeconds:(id)sender
{
    CustomButton *button = (CustomButton*)sender;
    
    if (globals.CURRENT_SEEK_FORWARD_ACTION != @selector(seekForwardFiveSeconds:)) {
        if ( ![button.accessibilityLabel isEqual:@"fullscreen"]) {
            [currentSeekForwardButton removeTarget:self action:globals.CURRENT_SEEK_FORWARD_ACTION forControlEvents:UIControlEventTouchUpInside];
            [currentSeekForwardButton setImage:[UIImage imageNamed:@"seekforwardfivesecs.png"] forState:UIControlStateNormal];
            [currentSeekForwardButton addTarget:self action:@selector(seekForwardFiveSeconds:) forControlEvents:UIControlEventTouchUpInside];
            globals.CURRENT_SEEK_FORWARD_ACTION = @selector(seekForwardFiveSeconds:);
            
            [currentSeekBackButton removeTarget:self action:globals.CURRENT_SEEK_BACK_ACTION forControlEvents:UIControlEventTouchUpInside];
            [currentSeekBackButton setImage:[UIImage imageNamed:@"seekbackfivesecs.png"] forState:UIControlStateNormal];
            [currentSeekBackButton addTarget:self action:@selector(seekBackFiveSeconds:) forControlEvents:UIControlEventTouchUpInside];
            globals.CURRENT_SEEK_BACK_ACTION = @selector(seekBackFiveSeconds:);
            
        }else{
            [currentSeekForwardButtoninFullScreen removeTarget:self action:globals.CURRENT_SEEK_FORWARD_ACTION forControlEvents:UIControlEventTouchUpInside];
            [currentSeekForwardButtoninFullScreen setImage:[UIImage imageNamed:@"seekforwardfivesecslarge.png"] forState:UIControlStateNormal];
            [currentSeekForwardButtoninFullScreen addTarget:self action:@selector(seekForwardFiveSeconds:) forControlEvents:UIControlEventTouchUpInside];
            globals.CURRENT_SEEK_FORWARD_ACTION = @selector(seekForwardFiveSeconds:);
            
            [currentSeekBackButtoninFullScreen removeTarget:self action:globals.CURRENT_SEEK_BACK_ACTION forControlEvents:UIControlEventTouchUpInside];
            [currentSeekBackButtoninFullScreen setImage:[UIImage imageNamed:@"seekbackfivesecslarge.png"] forState:UIControlStateNormal];
            [currentSeekBackButtoninFullScreen addTarget:self action:@selector(seekBackFiveSeconds:) forControlEvents:UIControlEventTouchUpInside];
            globals.CURRENT_SEEK_BACK_ACTION = @selector(seekBackFiveSeconds:);
        }
    }
    seekBackControlView.hidden = TRUE;
    seekForwardControlView.hidden = TRUE;
    seekBackControlViewinFullScreen.hidden = TRUE;
    seekForwardControlViewinFullScreen.hidden = TRUE;
    
    double currentTime = [videoPlayer currentTimeInSeconds];
    if (globals.IS_LOOP_MODE){
        //In loop mode
        //if (currentTime+5) is greater than the tag's end time, just seek to the tag's end time;
        //else seek forward 5 secs
        if(currentTime+5 >=globals.HOME_END_TIME) {
            [videoPlayer setTime: globals.HOME_START_TIME];
        }else{
            [videoPlayer seekForward:5.0];
        }
    }else{
        //In normal mode
        //if (currentTime+5) greater or equal to the seekable duration,go to live
        //else seek forward 5 secs
        if (currentTime+5 < videoPlayer.duration) {
            [videoPlayer seekForward:5.0];
        }else{
            [videoPlayer goToLive];
        }
            
        
    }
}
*///888
#pragma mark - SEEK OLD END


//get all the tagnames from TagButtons.plist file
// DEPRICATED Recieved from encoder manager
- (void)populateTagNames
{
    NSString *tagFilePath = [globals.LOCAL_DOCS_PATH stringByAppendingPathComponent:@"TagButtons.plist"];
    self.tagNames = [[NSMutableArray alloc] initWithContentsOfFile:tagFilePath];
}


//create all the tag buttons according to all the tagnames
- (void)createTagButtons
{
    NSArray * tNames = [_userCenter.tagNames copy]; //self.tagNames;
    

    [_tagButtonController inputTagData:tNames];
    
    //Add Actions
    [_tagButtonController addActionToAllTagButtons:@selector(tagButtonSelected:) addTarget:self forControlEvents:UIControlEventTouchUpInside];
    if ([_eventType isEqualToString:SPORT_FOOTBALL_TRAINING]) {
        [_tagButtonController addActionToAllTagButtons:@selector(showFootballTrainingCollection:) addTarget:self forControlEvents:UIControlEventTouchDragOutside];
    } else {
        [_tagButtonController addActionToAllTagButtons:@selector(showPlayerCollection:) addTarget:self forControlEvents:UIControlEventTouchDragOutside];
    }
    
    // is it swiped out?
//    if ((isDurationTagEnabled && swipedOutButton.selected && ([[dict objectForKey:@"name"] isEqual:swipedOutButton.titleLabel.text] || [[dict objectForKey:@"period"] isEqual:swipedOutButton.titleLabel.text]) && [[dict objectForKey:@"side"] isEqual:swipedOutButton.accessibilityValue]) || [globals.UNCLOSED_EVENT isEqualToString:[dict objectForKey:@"name"]]) {
//        button.selected = TRUE;
//        swipedOutButton = button;
//    }
    
    // are the buttons use able
    
    // ugly if... fix it
    if([globals.EVENT_NAME isEqualToString:@""] ||
       ([globals.EVENT_NAME isEqualToString:@"live"] && (![globals.CURRENT_ENC_STATUS isEqualToString:encStateLive] && ![globals.CURRENT_ENC_STATUS isEqualToString:encStatePaused]))||
       (int)[[[videoPlayer avPlayer]currentItem]status] == AVPlayerItemStatusFailed ||
       (int)[[[videoPlayer avPlayer]currentItem]status] == AVPlayerItemStatusUnknown) {
        
        _tagButtonController.enabled    = NO;
        _liveButton.enabled             = NO;
    }else{
        _tagButtonController.enabled    = YES;
        _liveButton.enabled             = YES;
        
    }
    
    return;
        ////////////////////////////////////////////////////////// OLD    ////////////////////////////////////////////////////////// OLD    ////////////////////////////////////////////////////////// OLD
    ////////////////////////////////////////////////////////// OLD    ////////////////////////////////////////////////////////// OLD    ////////////////////////////////////////////////////////// OLD
    /*
    if (tagButtonsArray) {
        [tagButtonsArray removeAllObjects];
    }else{
        tagButtonsArray = [[NSMutableArray alloc]init];
    }
    
    
    //counter for left and right side
    int count=1;
    int countL = 0;
    int countR = 0;
    float buttonStep = (YES==YES)?32:40; // The buttons height is 30
    float buttonHeight = 30;
    //draw buttons for tagnames
   if(self.leftSideButtons.subviews.count>0)
   {
       for (UIView *tempView in self.leftSideButtons.subviews)
       {
           [tempView removeFromSuperview];
       }
       
   }
    
    if(self.rightSideButtons.subviews.count>0)
    {
    
        for (UIView *tempView in self.rightSideButtons.subviews)
        {
            [tempView removeFromSuperview];
        }
       
        
    }
 
    for(NSDictionary *dict in tNames)
    {
        
        BOOL maxForSideReached = FALSE;
        BorderButton *button = [BorderButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:[dict objectForKey:@"name"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(tagButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
        if ([_eventType isEqualToString:SPORT_FOOTBALL_TRAINING]) {
            [button addTarget:self action:@selector(showFootballTrainingCollection:) forControlEvents:UIControlEventTouchDragOutside];
        } else {
            [button addTarget:self action:@selector(showPlayerCollection:) forControlEvents:UIControlEventTouchDragOutside];
        }
        [button setTag:count];
        //NSLog(@"button was selected's side: %@",buttonWasSelected.accessibilityValue);
        //if back from other view, highlight the button which was selected for duration tag
        if ((isDurationTagEnabled && swipedOutButton.selected && ([[dict objectForKey:@"name"] isEqual:swipedOutButton.titleLabel.text] || [[dict objectForKey:@"period"] isEqual:swipedOutButton.titleLabel.text]) && [[dict objectForKey:@"side"] isEqual:swipedOutButton.accessibilityValue]) || [globals.UNCLOSED_EVENT isEqualToString:[dict objectForKey:@"name"]]) {
            button.selected = TRUE;
            swipedOutButton = button;
        }
        
        //left and right sides have different settings
        if([[dict objectForKey:@"side"] isEqualToString:@"left"])
        {
            if (![globals.LEFT_TAG_BUTTONS_NAME containsObject:[dict objectForKey:@"name"]]) {
                [globals.LEFT_TAG_BUTTONS_NAME addObject:[dict objectForKey:@"name"]];
            }
            [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
            [button setFrame:CGRectMake(0, (countL*buttonStep)+20, self.leftSideButtons.bounds.size.width, buttonHeight) ];
            countL++;
            if (countL > MAX_NUM_TAG_BUTTONS) {
                maxForSideReached = TRUE;
            } else {
                //[button.layer setShadowOffset:CGSizeMake(-1, 1)];
                [button setAccessibilityValue:@"left"];
                [self.leftSideButtons addSubview:button];
            }
        }else{
            if (![globals.RIGHT_TAG_BUTTONS_NAME containsObject:[dict objectForKey:@"name"]]) {
                [globals.RIGHT_TAG_BUTTONS_NAME addObject:[dict objectForKey:@"name"]];
            }
            [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            [button setFrame:CGRectMake(self.rightSideButtons.frame.size.width-self.rightSideButtons.bounds.size.width, (countR*buttonStep)+20, self.rightSideButtons.bounds.size.width, buttonHeight) ];
            countR++;
            if (countR > MAX_NUM_TAG_BUTTONS) {
                maxForSideReached = TRUE;
            } else {
                //[button.layer setShadowOffset:CGSizeMake(1, 1)];
                [button setAccessibilityValue:@"right"];
                [self.rightSideButtons addSubview:button];
            }
        }
        count++;
        if (!maxForSideReached) {
            [tagButtonsArray addObject:button];
        }
    }

    //if there is no event playing or the live event is not playing properly or paused, disable all the tag buttons
    if([globals.EVENT_NAME isEqualToString:@""] || ([globals.EVENT_NAME isEqualToString:@"live"] && (![globals.CURRENT_ENC_STATUS isEqualToString:encStateLive] && ![globals.CURRENT_ENC_STATUS isEqualToString:encStatePaused]))|| (int)[[[videoPlayer avPlayer]currentItem]status] == AVPlayerItemStatusFailed || (int)[[[videoPlayer avPlayer]currentItem]status] == AVPlayerItemStatusUnknown)
    {
        [self.leftSideButtons setUserInteractionEnabled:FALSE];
        [self.leftSideButtons setAlpha:0.6f];
        [self.rightSideButtons setUserInteractionEnabled:FALSE];
        [self.rightSideButtons setAlpha:0.6f];
//        [liveButton setAlpha:0.6f];
         _liveButton.enabled = NO;
    }else{
        [self.leftSideButtons setUserInteractionEnabled:TRUE];
        [self.leftSideButtons setAlpha:1.0f];
        [self.rightSideButtons setUserInteractionEnabled:TRUE];
        [self.rightSideButtons setAlpha:1.0f];
//        [liveButton setAlpha:1.0f];
         _liveButton.enabled = YES;

    }
    *///888
}

//create the player collection view which contains buttons with player numbers
//when swiping the tag buttons, the player collection view will show up
-(void)intialPlayerCollectionView
{
    
    if (self.playerCollectionViewController) {
        [self.playerCollectionViewController.view removeFromSuperview];
        self.playerCollectionViewController = nil;
    }
    
    self.playerCollectionViewController = [[PlayerCollectionViewController alloc] init];
    [self.playerCollectionViewController.view.layer setBorderColor: [UIColor colorWithRed:242/255.0f green:135/255.0f blue:40/255.0f alpha:1.0f].CGColor];
    [self.playerCollectionViewController.view.layer setBorderWidth:1.0];
    [self.playerCollectionViewController.view setAlpha:0.0f];
    [self.view addSubview:self.playerCollectionViewController.view];
    
    leftArrow =[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"lefttriangle.png"]];
    [leftArrow setAlpha:0.0f];
    [self.playerCollectionViewController.view addSubview:leftArrow];
    
    rightArrow =[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"righttriangle.png"]];
    [rightArrow setAlpha:0.0f];
    [self.playerCollectionViewController.view addSubview:rightArrow];
    

}

-(void)initialFootballTrainingCollectionView
{
    
    if (self.footballTrainingCollectionViewController) {
        [self.footballTrainingCollectionViewController.view removeFromSuperview];
        self.footballTrainingCollectionViewController = nil;
    }
    
    self.footballTrainingCollectionViewController = [[FootballTrainingCollectionViewController alloc] init];
    [self.footballTrainingCollectionViewController.view.layer setBorderColor: [UIColor colorWithRed:242/255.0f green:135/255.0f blue:40/255.0f alpha:1.0f].CGColor];
    [self.footballTrainingCollectionViewController.view.layer setBorderWidth:1.0];
    [self.footballTrainingCollectionViewController.view setAlpha:0.0f];
    [self.view addSubview:self.footballTrainingCollectionViewController.view];
    
    leftArrow =[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"lefttriangle.png"]];
    [leftArrow setAlpha:0.0f];
    [self.footballTrainingCollectionViewController.view addSubview:leftArrow];
    
    rightArrow =[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"righttriangle.png"]];
    [rightArrow setAlpha:0.0f];
    [self.footballTrainingCollectionViewController.view addSubview:rightArrow];
    
    
}

//when swipe the tag buttons, this method will be called
-(void)showPlayerCollection:(id)sender
{
    globals.UNCLOSED_EVENT = nil;
    
    CustomButton *selectedTagButton = (CustomButton *)sender;
    tagTimeWhenSwipe = [NSString stringWithFormat:@"%f",CMTimeGetSeconds(videoPlayer.avPlayer.currentTime)];
    if ( swipedOutButton) {
        [self.playerCollectionViewController clearCellSelections];
    }
    if ([selectedTagButton.accessibilityValue isEqualToString:@"left"]) {
        [leftArrow setFrame:CGRectMake(-15,10, 15, 25)];
        [leftArrow setAlpha:1.0f];
        [self.playerCollectionViewController.view setFrame:CGRectMake(selectedTagButton.frame.origin.x+selectedTagButton.frame.size.width +25,43+selectedTagButton.frame.origin.y+selectedTagButton.frame.size.height,320 ,130)];
        if ([self.playerCollectionViewController.accessibilityValue isEqualToString:@"right"]) {
            [rightArrow setAlpha:0.0f];
        }
        [self.playerCollectionViewController setAccessibilityValue:@"left"];
    }else{
        [self.playerCollectionViewController.view setFrame:CGRectMake(self.view.frame.size.width - selectedTagButton.frame.size.width-345,43+selectedTagButton.frame.origin.y+selectedTagButton.frame.size.height,320 ,130)];
        [rightArrow setFrame:CGRectMake(self.playerCollectionViewController.view.frame.size.width, 10, 15, 25)];
        [rightArrow setAlpha:1.0f];
        if ([self.playerCollectionViewController.accessibilityValue isEqualToString:@"left"]) {
            [leftArrow setAlpha:0.0f];
        }
        [self.playerCollectionViewController setAccessibilityValue:@"right"];
    }
    [self.playerCollectionViewController.view setAlpha:1.0f];
    
    NSMutableDictionary *dict;
    
    //create a normal tag with event name: button.titleLabel.text
    NSString *tagTime = [NSString stringWithFormat:@"%f",CMTimeGetSeconds(videoPlayer.avPlayer.currentTime)];
    
    if (![tagTime isEqualToString:@"nan"]) {

        //if "duration tag" enabled, send duration tagset request to the server
        if(isDurationTagEnabled)
        {
            if (!globals.HAS_MIN|| (globals.HAS_MIN && !globals.eventExistsOnServer)){
                
                NSUInteger dTotalSeconds = [tagTime floatValue];
                NSUInteger dHours = floor(dTotalSeconds / 3600);
                NSUInteger dMinutes = floor(dTotalSeconds % 3600 / 60);
                NSUInteger dSeconds = floor(dTotalSeconds % 3600 % 60);
                NSString *displayTime = [NSString stringWithFormat:@"%01i:%02i:%02i",dHours, dMinutes, dSeconds];
                
                dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:globals.EVENT_NAME,@"event",selectedTagButton.titleLabel.text,@"name",[globals.ACCOUNT_INFO objectForKey:@"tagColour"],@"colour",[globals.ACCOUNT_INFO objectForKey:@"hid"],@"user",tagTime,@"time", displayTime, @"displaytime",tagTime, @"starttime", @"20", @"duration", [@"temp_" stringByAppendingString:tagTime] ,@"id",@"0", @"type",  @"", @"comment", @"0", @"rating", @"0", @"coachpick", @"0", @"bookmark", @"0", @"deleted", @"0",@"edited",@"1", @"local",nil];

               if (![selectedTagButton isEqual:swipedOutButton] && swipedOutButton.selected) {
                   [swipedOutButton sendActionsForControlEvents:UIControlEventTouchUpInside];
                }
                selectedTagButton.selected = TRUE;
                
                [globals.OPENED_DURATION_TAGS setObject:dict forKey:selectedTagButton.titleLabel.text];

            }else{
                dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:globals.EVENT_NAME,@"event",selectedTagButton.titleLabel.text,@"name",[globals.ACCOUNT_INFO objectForKey:@"tagColour"],@"colour",[globals.ACCOUNT_INFO objectForKey:@"hid"],@"user",tagTime,@"time", nil];
                if (dict) {
                    if (!selectedTagButton.selected) {
                        [dict setObject:@"99" forKey:@"type"];
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_DURATION_TAG object:self userInfo:dict];
                        //send device information to the server
                        NSString *UUID = [[[UIDevice currentDevice] identifierForVendor]UUIDString];
                        [dict setObject:UUID forKey:@"deviceid"];

                        if (swipedOutButton.selected) {
                            swipedOutButton.selected = FALSE;
                        }else if([_eventType isEqualToString:@"soccer"] || [_eventType isEqualToString:@"rugby"]){
                            [self.soccerBottomViewController deSelectTagButton];
                        }
                        if ([_eventType isEqualToString:SPORT_FOOTBALL_TRAINING]) {
                            NSString * catName = [NSString stringWithFormat:@"%@",selectedTagButton.titleLabel.text];
                            [dict setObject:catName forKey:@"name"];
                            [dict setObject:catName forKey:@"period"];
                            
                        }
                        selectedTagButton.selected = TRUE;
                        
                        [globals.ARRAY_OF_TAGSET addObject:dict];
                    }
                    
                }
            }
        }
    }

    swipedOutButton = selectedTagButton;
}

- (void)showFootballTrainingCollection:(id)sender
{
    globals.UNCLOSED_EVENT = nil;
    
    CustomButton *selectedTagButton = (CustomButton *)sender;
    tagTimeWhenSwipe = [NSString stringWithFormat:@"%f",CMTimeGetSeconds(videoPlayer.avPlayer.currentTime)];
    if (swipedOutButton) {
        [self.footballTrainingCollectionViewController clearSelections];
    }
    if ([selectedTagButton.accessibilityValue isEqualToString:@"left"]) {
        [leftArrow setFrame:CGRectMake(-15,10, 15, 25)];
        [leftArrow setAlpha:1.0f];
        [self.footballTrainingCollectionViewController.view setFrame:CGRectMake(selectedTagButton.frame.origin.x+selectedTagButton.frame.size.width +25,43+selectedTagButton.frame.origin.y+selectedTagButton.frame.size.height,320 ,130)];
        if ([self.footballTrainingCollectionViewController.accessibilityValue isEqualToString:@"right"]) {
            [rightArrow setAlpha:0.0f];
        }
        [self.footballTrainingCollectionViewController setAccessibilityValue:@"left"];
    }else{
        [self.footballTrainingCollectionViewController.view setFrame:CGRectMake(self.view.frame.size.width - selectedTagButton.frame.size.width-345,43+selectedTagButton.frame.origin.y+selectedTagButton.frame.size.height,320 ,130)];
        [rightArrow setFrame:CGRectMake(self.footballTrainingCollectionViewController.view.frame.size.width, 10, 15, 25)];
        [rightArrow setAlpha:1.0f];
        if ([self.footballTrainingCollectionViewController.accessibilityValue isEqualToString:@"left"]) {
            [leftArrow setAlpha:0.0f];
        }
        [self.footballTrainingCollectionViewController setAccessibilityValue:@"right"];
    }
    [self.footballTrainingCollectionViewController.view setAlpha:1.0f];
    [self.view bringSubviewToFront:self.footballTrainingCollectionViewController.view];
    for (NSDictionary *dict in self.tagNames) {
        if ([[dict objectForKey:@"name"] isEqualToString:selectedTagButton.titleLabel.text]) {
            self.footballTrainingCollectionViewController.subtagsArray = [NSMutableArray arrayWithArray:[dict objectForKey:@"subtags"]];
            break;
        }
    }
    self.footballTrainingCollectionViewController.playersArray = self.footballTrainingBottomViewController.currentGroupPlayers;
    if (![swipedOutButton isEqual:selectedTagButton]) {
        [self tagButtonSelected:selectedTagButton];
        swipedOutButton = selectedTagButton;
    }
//    NSMutableDictionary *dict;
//    
//    //create a normal tag with event name: button.titleLabel.text
//    NSString *tagTime = [NSString stringWithFormat:@"%f",CMTimeGetSeconds(videoPlayer.avPlayer.currentTime)];
//    
//    if (![tagTime isEqualToString:@"nan"]) {
//        
//        //if "duration tag" enabled, send duration tagset request to the server
//        if(isDurationTagEnabled)
//        {
//            if (!globals.HAS_MIN|| (globals.HAS_MIN && !globals.eventExistsOnServer)){
//                
//                NSUInteger dTotalSeconds = [tagTime floatValue];
//                NSUInteger dHours = floor(dTotalSeconds / 3600);
//                NSUInteger dMinutes = floor(dTotalSeconds % 3600 / 60);
//                NSUInteger dSeconds = floor(dTotalSeconds % 3600 % 60);
//                NSString *displayTime = [NSString stringWithFormat:@"%01i:%02i:%02i",dHours, dMinutes, dSeconds];
//                
//                dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:globals.EVENT_NAME,@"event",selectedTagButton.titleLabel.text,@"name",selectedTagButton.titleLabel.text,@"period",[globals.ACCOUNT_INFO objectForKey:@"tagColour"],@"colour",[globals.ACCOUNT_INFO objectForKey:@"hid"],@"user",tagTime,@"time", displayTime, @"displaytime",tagTime, @"starttime", @"20", @"duration", [@"temp_" stringByAppendingString:tagTime] ,@"id",@"0", @"type",  @"", @"comment", @"0", @"rating", @"0", @"coachpick", @"0", @"bookmark", @"0", @"deleted", @"0",@"edited",@"1", @"local",nil];
//                
//                if (![selectedTagButton isEqual:swipedOutButton] && swipedOutButton.selected) {
//                    [swipedOutButton sendActionsForControlEvents:UIControlEventTouchUpInside];
//                }
//                selectedTagButton.selected = TRUE;
//                
//                [globals.OPENED_DURATION_TAGS setObject:dict forKey:selectedTagButton.titleLabel.text];
//                
//            }else{
//                dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:globals.EVENT_NAME,@"event",selectedTagButton.titleLabel.text,@"name",selectedTagButton.titleLabel.text,@"period",[globals.ACCOUNT_INFO objectForKey:@"tagColour"],@"colour",[globals.ACCOUNT_INFO objectForKey:@"hid"],@"user",tagTime,@"time", nil];
//                if (dict) {
//                    if (!selectedTagButton.selected) {
//                        [dict setObject:@"99" forKey:@"type"];
//                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_DURATION_TAG object:self userInfo:dict];
//                        //send device information to the server
//                        NSString *UUID = [[[UIDevice currentDevice] identifierForVendor]UUIDString];
//                        [dict setObject:UUID forKey:@"deviceid"];
//                        
//                        if (swipedOutButton.selected) {
//                            swipedOutButton.selected = FALSE;
//                        }else if([_eventType isEqualToString:@"soccer"] || [_eventType isEqualToString:@"rugby"]){
//                            [self.soccerBottomViewController deSelectTagButton];
//                        } else if ([_eventType isEqualToString:SPORT_FOOTBALL_TRAINING]) {
//                            
//                            NSString * catName = [NSString stringWithFormat:@"%@",selectedTagButton.titleLabel.text];
//                            [dict setObject:catName forKey:@"name"];
//                            [dict setObject:catName forKey:@"period"];
//                            
//                        }
//                        selectedTagButton.selected = TRUE;
//                        
//                        [globals.ARRAY_OF_TAGSET addObject:dict];
//                    }
//                    
//                }
//            }
//        }
//    }
//
}

//if touch any other place in the tablet, make the player collection view invisible
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];    
    CGPoint touchLocation = [touch locationInView:self.view];
   

    if (touchLocation.x >0 && touchLocation.x < swipedOutButton.frame.origin.x + swipedOutButton.frame.size.width && touchLocation.y >swipedOutButton.frame.origin.y && touchLocation.y < swipedOutButton.frame.origin.y + swipedOutButton.frame.size.height ) {
    }else{
        [leftArrow setAlpha:0.0f];
        [rightArrow setAlpha:0.0f];
        [self.playerCollectionViewController.view setAlpha:0.0f];
        [self.footballTrainingCollectionViewController.view setAlpha:0.0f];
    }
}


// This is used in the bottom view controllers
//the method will be called to get the current time when send tagset request from the bottom view (ex:changing period)
-(NSString *)getCurrentTimeforNewTag
{
    return [ NSString stringWithFormat:@"%f",(videoPlayer.currentTimeInSeconds - videoPlayer.startTime)];
}

//tag button is hit, send the instance to the queue object
// connect to EM to send Nofit
-(void)tagButtonSelected:(id)sender
{
    globals.UNCLOSED_EVENT = nil;
    
    if ([_eventType isEqualToString:@""]) {
        [leftArrow setAlpha:0.0f];
        [rightArrow setAlpha:0.0f];
        [self.playerCollectionViewController.view setAlpha:0.0f];
        [self.footballTrainingCollectionViewController.view setAlpha:0.0f];
        return;
    }
    globals.DID_CREATE_NEW_TAG=TRUE; // Dead code
    CustomButton *button = (CustomButton*)sender;
    
    NSMutableDictionary *dict;
    
    //get the right tag time; If the video player's current start time is not zero, minus the offset
    NSString *tagTime = [NSString stringWithFormat:@"%f",videoPlayer.currentTimeInSeconds - videoPlayer.startTime];
    //NSLog(@"********************************tagTime****************************** : %@",tagTime);
    if (![tagTime isEqualToString:@"nan"]) {
        //For local tags
        if (!globals.HAS_MIN|| (globals.HAS_MIN && !globals.eventExistsOnServer)){
            //dictionary which is generated when a duration tag is closed
            NSMutableDictionary *closeDurationDict;
            
            NSUInteger dTotalSeconds = [tagTime floatValue];
            NSUInteger dHours = floor(dTotalSeconds / 3600);
            NSUInteger dMinutes = floor(dTotalSeconds % 3600 / 60);
            NSUInteger dSeconds = floor(dTotalSeconds % 3600 % 60);
            NSString *displayTime = [NSString stringWithFormat:@"%01i:%02i:%02i",dHours, dMinutes, dSeconds];

            //no more than 20 tags in the tag queue; otherwise the app will become very slow
            if (tagsinQueueInOfflineMode <=20){
                tagsinQueueInOfflineMode++;
               
                if(![button isEqual:swipedOutButton] ||self.playerCollectionViewController.view.alpha == 0){
                     //If no players are selected for tag
                    if (!isDurationTagEnabled ) {
                         dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:globals.EVENT_NAME,@"event",
                                 button.titleLabel.text,@"name",
                                 [globals.ACCOUNT_INFO objectForKey:@"tagColour"],@"colour",
                                 [globals.ACCOUNT_INFO objectForKey:@"hid"],@"user",
                                 tagTime,@"time",
                                 displayTime, @"displaytime",
                                 [NSString stringWithFormat:@"%f",[tagTime floatValue] - 10.0], @"starttime",
                                 @"20", @"duration",
                                 [@"temp_" stringByAppendingString:tagTime] ,@"id",
                                 @"0", @"type",
                                 @"", @"comment",
                                 @"0", @"rating",
                                 @"0", @"coachpick",
                                 @"0", @"bookmark",
                                 @"0", @"deleted",
                                 @"0",@"edited",
                                 @"1", @"local",nil];
                        
                    }else if (isDurationTagEnabled && !button.selected){
                         dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:globals.EVENT_NAME,@"event",
                                 button.titleLabel.text,@"name",
                                 [globals.ACCOUNT_INFO objectForKey:@"tagColour"],@"colour",
                                 [globals.ACCOUNT_INFO objectForKey:@"hid"],@"user",
                                 tagTime,@"time",
                                 displayTime, @"displaytime",
                                 tagTime, @"starttime",
                                 @"20", @"duration",
                                 [@"temp_" stringByAppendingString:tagTime] ,@"id",
                                 @"0", @"type",
                                 @"", @"comment",
                                 @"0", @"rating",
                                 @"0", @"coachpick",
                                 @"0", @"bookmark",
                                 @"0", @"deleted",
                                 @"0",@"edited",
                                 @"1", @"local",nil];
                    }
                   
                        
                    //if duration-tag control enabled, create new duration tag or close an old duration tag
                    if (isDurationTagEnabled && !button.selected) {
                        
                        if (swipedOutButton.selected) {
                            swipedOutButton.selected = FALSE;
                            //close the previous duration tag
                            if (globals.OPENED_DURATION_TAGS && [[globals.OPENED_DURATION_TAGS allKeys]containsObject:swipedOutButton.titleLabel.text]) {
                                closeDurationDict = [[globals.OPENED_DURATION_TAGS objectForKey:swipedOutButton.titleLabel.text]mutableCopy];
                                int durationNumber =(int)([tagTime floatValue] - [[[globals.OPENED_DURATION_TAGS objectForKey:swipedOutButton.titleLabel.text] objectForKey:@"time"] floatValue]);
                                NSString *duration;
                                if (durationNumber >= 0) {
                                    duration = [NSString stringWithFormat:@"%d",durationNumber];
                                }else{
                                    durationNumber = -durationNumber;
                                    duration = [NSString stringWithFormat:@"%d",durationNumber];
                                    [closeDurationDict setObject:displayTime forKey:@"displaytime"];
                                    [closeDurationDict setObject:tagTime forKey:@"time"];
                                    [closeDurationDict setObject:tagTime forKey:@"starttime"];
                                }
                               
                                [closeDurationDict setObject:duration forKey:@"duration"];
                                [globals.OPENED_DURATION_TAGS removeObjectForKey:swipedOutButton.titleLabel.text];
                            }
                        }else if([_eventType isEqualToString:@"soccer"] || [_eventType isEqualToString:@"rugby"]){
                            [self.soccerBottomViewController deSelectTagButton];
                        }
                        button.selected = TRUE;
                        
                        if (dict) {
                            [globals.OPENED_DURATION_TAGS setObject:dict forKey:button.titleLabel.text];
                        }
                       
                        
                    }else if (isDurationTagEnabled && button.selected){
                        //close this duration tag
                        if (globals.OPENED_DURATION_TAGS && [[globals.OPENED_DURATION_TAGS allKeys]containsObject:swipedOutButton.titleLabel.text]) {
                            closeDurationDict = [[globals.OPENED_DURATION_TAGS objectForKey:swipedOutButton.titleLabel.text]mutableCopy];
                            int durationNumber =(int)([tagTime floatValue] - [[[globals.OPENED_DURATION_TAGS objectForKey:swipedOutButton.titleLabel.text] objectForKey:@"time"] floatValue]);
                            NSString *duration;
                            if (durationNumber >= 0) {
                                duration = [NSString stringWithFormat:@"%d",durationNumber];
                            }else{
                                durationNumber = -durationNumber;
                                duration = [NSString stringWithFormat:@"%d",durationNumber];
                                [closeDurationDict setObject:displayTime forKey:@"displaytime"];
                                [closeDurationDict setObject:tagTime forKey:@"time"];
                                [closeDurationDict setObject:tagTime forKey:@"starttime"];
                            }
                            [closeDurationDict setObject:duration forKey:@"duration"];
                            [globals.OPENED_DURATION_TAGS removeObjectForKey:swipedOutButton.titleLabel.text];
                        }

                        button.selected = FALSE;
                    }
                    
                }
                else
                {
                    NSMutableDictionary *selectedData = [[self.playerCollectionViewController getAllSelectedPlayers] mutableCopy];
                    NSMutableArray *selectedPlayers = [selectedData objectForKey:@"players"];
                    
                    //If players are selected for hockey
                    if([_eventType isEqualToString:@"hockey"])
                    {
                        NSString *selectedZone = [selectedData objectForKey:@"zone"];
                        
                        if ((!selectedPlayers || selectedPlayers.count < 1) && ![selectedZone isEqualToString:@""]) {
                            
                            //if no player selected, has zone selected
                              dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:selectedZone,@"zone",
                                      globals.EVENT_NAME,@"event",
                                      button.titleLabel.text,@"name",
                                      [globals.ACCOUNT_INFO objectForKey:@"tagColour"],@"colour",
                                      [globals.ACCOUNT_INFO objectForKey:@"hid"],@"user",
                                      tagTime,@"time",
                                      tagTime, @"time",
                                      displayTime, @"displaytime",
                                      [NSString stringWithFormat:@"%f",[tagTime floatValue] - 10.0], @"starttime",
                                      @"20", @"duration",
                                      [@"temp_" stringByAppendingString:tagTime] ,@"id",
                                      @"0", @"type",
                                      @"", @"comment",
                                      @"0", @"rating",
                                      @"0", @"coachpick",
                                      @"0", @"bookmark",
                                      @"0", @"deleted",
                                      @"0",@"edited",
                                      @"1", @"local", nil];
                            
                        }else if([selectedZone isEqualToString:@""] && selectedPlayers.count > 0){
                            
                            //if no zone selected, has player selected
                             dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:selectedPlayers,@"player",
                                     globals.EVENT_NAME,@"event",
                                     button.titleLabel.text,@"name",
                                     [globals.ACCOUNT_INFO objectForKey:@"tagColour"],@"colour",
                                     [globals.ACCOUNT_INFO objectForKey:@"hid"],@"user",
                                     tagTime,@"time",
                                     tagTime, @"time",
                                     displayTime, @"displaytime",
                                     [NSString stringWithFormat:@"%f",[tagTime floatValue] - 10.0], @"starttime",
                                     @"20", @"duration",
                                     [@"temp_" stringByAppendingString:tagTime] ,@"id",
                                     @"0", @"type",  @"", @"comment", @"0", @"rating", @"0", @"coachpick", @"0", @"bookmark", @"0", @"deleted", @"0",@"edited", @"1", @"local", nil];
                            
                        }else if((!selectedPlayers || selectedPlayers.count < 1) && [selectedZone isEqualToString:@""]){
                            
                            //if no player nor zone selected
                              dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:globals.EVENT_NAME,@"event",
                                      button.titleLabel.text,@"name",
                                      [globals.ACCOUNT_INFO objectForKey:@"tagColour"],@"colour",
                                      [globals.ACCOUNT_INFO objectForKey:@"hid"],@"user",
                                      tagTime,@"time",
                                      tagTime, @"time",
                                      displayTime, @"displaytime",
                                      [NSString stringWithFormat:@"%f",[tagTime floatValue] - 10.0], @"starttime",
                                      @"20", @"duration",
                                      [@"temp_" stringByAppendingString:tagTime] ,@"id",
                                      @"0", @"type",
                                      @"", @"comment",
                                      @"0", @"rating",
                                      @"0", @"coachpick",
                                      @"0", @"bookmark",
                                      @"0", @"deleted",
                                      @"0",@"edited",
                                      @"1", @"local", nil];
                            
                        }else{
                            
                            //if both player and zone are selected
                              dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:selectedPlayers,@"player",selectedZone,@"zone", globals.EVENT_NAME,@"event",button.titleLabel.text,@"name",[globals.ACCOUNT_INFO objectForKey:@"tagColour"],@"colour",[globals.ACCOUNT_INFO objectForKey:@"hid"],@"user",tagTime,@"time", tagTime, @"time", displayTime, @"displaytime",[NSString stringWithFormat:@"%f",[tagTime floatValue] - 10.0], @"starttime", @"20", @"duration", [@"temp_" stringByAppendingString:tagTime] ,@"id",@"0", @"type",  @"", @"comment", @"0", @"rating", @"0", @"coachpick", @"0", @"bookmark", @"0", @"deleted", @"0",@"edited", @"1", @"local", nil];
                        }
                      
                        
                    }
                    //If players are selected fro soccer/rugby/football
                    else if ([_eventType isEqualToString:@"soccer"] || [_eventType isEqualToString:@"rugby"]|| [_eventType isEqualToString:@"football"])
                    {
                        
                        if ((!selectedPlayers || selectedPlayers.count < 1)) {
                            //if no player selected
                            dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys: globals.EVENT_NAME,@"event",button.titleLabel.text,@"name",[globals.ACCOUNT_INFO objectForKey:@"tagColour"],@"colour",[globals.ACCOUNT_INFO objectForKey:@"hid"],@"user",tagTime,@"time", tagTime, @"time", displayTime, @"displaytime",[NSString stringWithFormat:@"%f",[tagTime floatValue] - 10.0], @"starttime", @"20", @"duration", [@"temp_" stringByAppendingString:tagTime] ,@"id",@"0", @"type",  @"", @"comment", @"0", @"rating", @"0", @"coachpick", @"0", @"bookmark", @"0", @"deleted",[globals.THUMBNAILS_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",[@"temp_" stringByAppendingString:tagTime]]] ,@"url",@"0",@"edited", @"1", @"local", nil];
                        }else{
                            //if player selected
                           dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:selectedPlayers,@"player", globals.EVENT_NAME,@"event",button.titleLabel.text,@"name",[globals.ACCOUNT_INFO objectForKey:@"tagColour"],@"colour",[globals.ACCOUNT_INFO objectForKey:@"hid"],@"user",tagTime,@"time", displayTime, @"displaytime",[NSString stringWithFormat:@"%f",[tagTime floatValue] - 10.0], @"starttime", @"20", @"duration", [@"temp_" stringByAppendingString:tagTime] ,@"id",@"0", @"type",  @"", @"comment", @"0", @"rating", @"0", @"coachpick", @"0", @"bookmark", @"0", @"deleted",[globals.THUMBNAILS_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",[@"temp_" stringByAppendingString:tagTime]]] ,@"url",@"0",@"edited", @"1", @"local", nil];
                        }
                        
                    }
                    
                    //if duration-tag control enabled, create new duration tag or close an old duration tag
                    if (isDurationTagEnabled && !button.selected) {
                        
                        if (swipedOutButton.selected) {
                            swipedOutButton.selected = FALSE;
                            //close the previous duration tag
                            if (globals.OPENED_DURATION_TAGS && [[globals.OPENED_DURATION_TAGS allKeys]containsObject:swipedOutButton.titleLabel.text]) {
                                closeDurationDict = [[globals.OPENED_DURATION_TAGS objectForKey:swipedOutButton.titleLabel.text]mutableCopy];
                                int durationNumber =(int)([tagTime floatValue] - [[[globals.OPENED_DURATION_TAGS objectForKey:swipedOutButton.titleLabel.text] objectForKey:@"time"] floatValue]);
                                NSString *duration;
                                if (durationNumber >= 0) {
                                    duration = [NSString stringWithFormat:@"%d",durationNumber];
                                }else{
                                    durationNumber = -durationNumber;
                                    duration = [NSString stringWithFormat:@"%d",durationNumber];
                                    [closeDurationDict setObject:displayTime forKey:@"displaytime"];
                                    [closeDurationDict setObject:tagTime forKey:@"time"];
                                    [closeDurationDict setObject:tagTime forKey:@"starttime"];
                                }
                               
                                [closeDurationDict setObject:duration forKey:@"duration"];
                                [globals.OPENED_DURATION_TAGS removeObjectForKey:swipedOutButton.titleLabel.text];
                            }
                        }else if([_eventType isEqualToString:@"soccer"] || [_eventType isEqualToString:@"rugby"]){
                            [self.soccerBottomViewController deSelectTagButton];
                        }
                        button.selected = TRUE;
                        
                        [dict setObject:tagTime forKey:@"starttime"];
                        if (dict) {
                             [globals.OPENED_DURATION_TAGS setObject:dict forKey:button.titleLabel.text];
                        }
                       
                        
                    }else if (isDurationTagEnabled && button.selected){
                        //close this duration tag
                        if (globals.OPENED_DURATION_TAGS && [[globals.OPENED_DURATION_TAGS allKeys]containsObject:swipedOutButton.titleLabel.text]) {
                            closeDurationDict = [[globals.OPENED_DURATION_TAGS objectForKey:swipedOutButton.titleLabel.text]mutableCopy];
                            int durationNumber =(int)([tagTime floatValue] - [[[globals.OPENED_DURATION_TAGS objectForKey:swipedOutButton.titleLabel.text] objectForKey:@"time"] floatValue]);
                            NSString *duration;
                            if (durationNumber >= 0) {
                                duration = [NSString stringWithFormat:@"%d",durationNumber];
                            }else{
                                durationNumber = -durationNumber;
                                duration = [NSString stringWithFormat:@"%d",durationNumber];
                                [closeDurationDict setObject:displayTime forKey:@"displaytime"];
                                [closeDurationDict setObject:tagTime forKey:@"time"];
                                [closeDurationDict setObject:tagTime forKey:@"starttime"];
                            }

                            [closeDurationDict setObject:duration forKey:@"duration"];
                            if ([dict objectForKey:@"player"]) {
                                [closeDurationDict setObject:[dict objectForKey:@"player"] forKey:@"player"];
                            }
                            if ([dict objectForKey:@"zone"]) {
                                [closeDurationDict setObject:[dict objectForKey:@"zone"] forKey:@"zone"];
                            }
                            [globals.OPENED_DURATION_TAGS removeObjectForKey:swipedOutButton.titleLabel.text];
                        }

                        button.selected = FALSE;
                    }

                }
                
                
                if (isDurationTagEnabled && closeDurationDict) {
                    //if one duration tag closed, generate the thumbnail and add it to the globals tags dictionary
                    dict = closeDurationDict;
                }else if (isDurationTagEnabled && !closeDurationDict){
                    swipedOutButton = button;
                    //hide the playercollectionview and the arrows
                    [leftArrow setAlpha:0.0f];
                    [rightArrow setAlpha:0.0f];
                    [self.playerCollectionViewController.view setAlpha:0.0f];
                    [self.footballTrainingCollectionViewController.view setAlpha:0.0f];
                    //if no duration tag closed, return
                    return;
                }
                
                NSString *filePath = [[globals.EVENTS_PATH stringByAppendingPathComponent:globals.EVENT_NAME] stringByAppendingPathComponent:@"Thumbnails.plist"];
                NSString *imageName = [NSString stringWithFormat:@"%@.jpg",[dict objectForKey:@"id"]];
                NSString *imagePath = [globals.THUMBNAILS_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",imageName]];
                
                if (dict) {
                    //save tag information in global dictionary
                    [globals.CURRENT_EVENT_THUMBNAILS setObject:dict forKey:[NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]]];
                    
                }
                
                [dict setObject:imagePath forKey:@"url"];
                //create tagmarker
                [self markTagAtTime:[tagTime floatValue] colour:[uController colorWithHexString:[globals.ACCOUNT_INFO objectForKey:@"tagColour"]] tagID:[NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]]];
                //[self markTag:[tagTime floatValue] name:button.titleLabel.text colour:[uController colorWithHexString:[globals.ACCOUNT_INFO objectForKey:@"tagColour"]] tagID: [[@"temp_" stringByAppendingString:tagTime] doubleValue]];
                //save the thumbnail image in local storage. This is running in the background thread
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                                         (unsigned long)NULL), ^(void) {
                    BOOL isDir;
                    if(![[NSFileManager defaultManager] fileExistsAtPath:globals.THUMBNAILS_PATH isDirectory:&isDir])
                    {
                        [[NSFileManager defaultManager] createDirectoryAtPath:globals.THUMBNAILS_PATH withIntermediateDirectories:YES attributes:nil error:NULL];
                    }
                    
                    //create thumbnail using avfoundation and save it in the local dir
                    NSURL *videoURL = videoPlayer.videoURL;
                    AVAsset *asset = [AVAsset assetWithURL:videoURL];
                    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
                    [imageGenerator setMaximumSize:CGSizeMake(190, 106)];
                    [imageGenerator setApertureMode:AVAssetImageGeneratorApertureModeProductionAperture];
                    //CMTime time = [[dict objectForKey:@"cmtime"] CMTimeValue];//CMTimeMake(30, 1);
                    CMTime time = CMTimeMakeWithSeconds([[dict objectForKey:@"time"] floatValue], 1);
                    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
                    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
                    CGImageRelease(imageRef);
                    
                    NSData *imageData = UIImageJPEGRepresentation(thumbnail, 0.5);
                    if(![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir])
                    {
                        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
                    }
                    //add image to directory
                    [imageData writeToFile:imagePath atomically:YES ];
                    tagsinQueueInOfflineMode--;
                    
                });
            }
        }
        else {
            //Normal tags
            
            //No players selected
            if(![button isEqual:swipedOutButton] ||self.playerCollectionViewController.view.alpha == 0)
            {
               // NSLog(@"################### NO PLAYER SELECTED!!!!!!#####################");
                dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:globals.EVENT_NAME,@"event",
                        button.titleLabel.text,@"name",
                        [globals.ACCOUNT_INFO objectForKey:@"tagColour"],@"colour",
                        [globals.ACCOUNT_INFO objectForKey:@"hid"],@"user",
                        tagTime,@"time", nil];
                if (dict) {
                    
                    //if duration-tag control enabled, create new duration tag or close an old duration tag
                    if (isDurationTagEnabled && !button.selected) {
                        [dict setObject:@"99" forKey:@"type"];
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_DURATION_TAG object:self userInfo:dict];
                        //send device information to the server
                        NSString *UUID = [[[UIDevice currentDevice] identifierForVendor]UUIDString];
                        [dict setObject:UUID forKey:@"deviceid"];
                        if (swipedOutButton.selected) {
                            swipedOutButton.selected = FALSE;
                        }else if([_eventType isEqualToString:@"soccer"] || [_eventType isEqualToString:@"rugby"]){
                            [self.soccerBottomViewController deSelectTagButton];
                        }
                        if ([_eventType isEqualToString:SPORT_FOOTBALL_TRAINING]) {
                            NSString * catName = [NSString stringWithFormat:@"%@",button.titleLabel.text];
                            [dict setObject:catName forKey:@"name"];
                            [dict setObject:catName forKey:@"period"];
                            
                        }
                        button.selected = TRUE;
                        [globals.ARRAY_OF_TAGSET addObject:dict];
                    }else if (isDurationTagEnabled && button.selected){
                        if (globals.OPENED_DURATION_TAGS && [[globals.OPENED_DURATION_TAGS allKeys] containsObject:button.titleLabel.text]) {
                            
                            [dict setObject:@"100" forKey:@"type"];
                            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_DURATION_TAG object:self userInfo:dict];
                            //send device information to the server
                            NSString *UUID = [[[UIDevice currentDevice] identifierForVendor]UUIDString];
                            [dict setObject:UUID forKey:@"deviceid"];

                            id tagId = [globals.OPENED_DURATION_TAGS objectForKey:button.titleLabel.text];
                            [dict setObject:tagId forKey:@"id"];
                            [globals.OPENED_DURATION_TAGS removeObjectForKey:button.titleLabel.text];
                            
                            
                            
                            
                            if ([_eventType isEqualToString:SPORT_FOOTBALL_TRAINING]) {
                                
                                NSString * catName = [NSString stringWithFormat:@"%@",button.titleLabel.text];
                                [dict setObject:catName forKey:@"name"];
                                [dict setObject:catName forKey:@"period"];
                                
                            }
                            
                            
                            
                            
                            
                            
                            [globals.ARRAY_OF_TAGSET addObject:dict];
                        }else{
                            [dict setObject:@"100" forKey:@"type"];
                            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_DURATION_TAG object:self userInfo:dict];
                            //send device information to the server
                            NSString *UUID = [[[UIDevice currentDevice] identifierForVendor]UUIDString];
                            [dict setObject:UUID forKey:@"deviceid"];

                            [globals.PRECLOSED_DURATION_TAGS setObject:dict forKey:button.titleLabel.text];
                        }
                        
                        button.selected = FALSE;
                      

                    }else{
                        [globals.ARRAY_OF_TAGSET addObject:dict];
                    }
                   

                }
                    
            }
            else
            {
                //create a tag with players with event name:button.titleLabel.text
                if(![tagTimeWhenSwipe isEqualToString:@"nan"]){
                    NSMutableDictionary *selectedData = [[self.playerCollectionViewController getAllSelectedPlayers] mutableCopy];
                    NSMutableArray *selectedPlayers = [selectedData objectForKey:@"players"];
                    //NSLog(@"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$   selectedPlayers %@, selectedData: %@",selectedPlayers,selectedData);
                    NSMutableDictionary *dict;
                    
                    if ([_eventType isEqualToString:@"hockey"]) {
                        //Players selection for hockey
                        NSString *selectedZone = [selectedData objectForKey:@"zone"];
                        if ((!selectedPlayers || selectedPlayers.count < 1) && ![selectedZone isEqualToString:@""]) {
                            
                            //if no player selected, has zone selected
                            dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:selectedZone,@"zone",
                                    globals.EVENT_NAME,@"event",
                                    button.titleLabel.text,@"name",
                                    [globals.ACCOUNT_INFO objectForKey:@"tagColour"],@"colour",
                                    [globals.ACCOUNT_INFO objectForKey:@"hid"],@"user",tagTimeWhenSwipe,@"time", nil];
                        
                        }else if([selectedZone isEqualToString:@""] && selectedPlayers.count > 0){
                            
                            //if no zone selected, has player selected
                            dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:selectedPlayers,@"player",globals.EVENT_NAME,@"event",button.titleLabel.text,@"name",[globals.ACCOUNT_INFO objectForKey:@"tagColour"],@"colour",[globals.ACCOUNT_INFO objectForKey:@"hid"],@"user",tagTimeWhenSwipe,@"time", nil];
                       
                        }else if((!selectedPlayers || selectedPlayers.count < 1) && [selectedZone isEqualToString:@""]){
                            
                            //if no player nor zone selected
                            dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:globals.EVENT_NAME,@"event",button.titleLabel.text,@"name",[globals.ACCOUNT_INFO objectForKey:@"tagColour"],@"colour",[globals.ACCOUNT_INFO objectForKey:@"hid"],@"user",tagTimeWhenSwipe,@"time", nil];
                            
                        }else{
                            
                            //if both player and zone are selected
                            dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:selectedPlayers,@"player",selectedZone,@"zone",globals.EVENT_NAME,@"event",button.titleLabel.text,@"name",[globals.ACCOUNT_INFO objectForKey:@"tagColour"],@"colour",[globals.ACCOUNT_INFO objectForKey:@"hid"],@"user",tagTimeWhenSwipe,@"time", nil];
                        }
                    }else if ([_eventType isEqualToString:@"soccer"] || [_eventType isEqualToString:@"rugby"]|| [_eventType isEqualToString:@"football"]){
                        //Players selection for soccer/rugby/football
                        
                        if ((!selectedPlayers || selectedPlayers.count < 1)) {
                            //if no player selected
                            dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:globals.EVENT_NAME,@"event",
                                    button.titleLabel.text,@"name",
                                    [globals.ACCOUNT_INFO objectForKey:@"tagColour"],@"colour",
                                    [globals.ACCOUNT_INFO objectForKey:@"hid"],@"user",
                                    tagTimeWhenSwipe,@"time", nil];
                        }else{
                            //if player selected
                            dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:selectedPlayers,@"player",
                                    globals.EVENT_NAME,@"event",
                                    button.titleLabel.text,@"name",
                                    [globals.ACCOUNT_INFO objectForKey:@"tagColour"],@"colour",
                                    [globals.ACCOUNT_INFO objectForKey:@"hid"],@"user",
                                    tagTimeWhenSwipe,@"time", nil];
                        }
                        
                    }
                    //added the new tag dictionary into the array of tag dictionaries; And then the tagset request will be sent one per sec
                    if (dict) {
                        
                         //if duration-tag control enabled, create new duration tag or close an old duration tag
                        if (isDurationTagEnabled && !button.selected) {
                            [dict setObject:@"99" forKey:@"type"];
                            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_DURATION_TAG object:self userInfo:dict];
                            //send device information to the server
                            NSString *UUID = [[[UIDevice currentDevice] identifierForVendor]UUIDString];
                            [dict setObject:UUID forKey:@"deviceid"];

                            if (swipedOutButton.selected) {
                                swipedOutButton.selected = FALSE;
                            }else if([_eventType isEqualToString:@"soccer"] || [_eventType isEqualToString:@"rugby"]){
                                [self.soccerBottomViewController deSelectTagButton];
                            }
                            if ([_eventType isEqualToString:SPORT_FOOTBALL_TRAINING]) {
                                
                                NSString * catName = [NSString stringWithFormat:@"%@",button.titleLabel.text];
                                [dict setObject:catName forKey:@"name"];
                                [dict setObject:catName forKey:@"period"];
                                
                            }
                            button.selected = TRUE;
                            [globals.ARRAY_OF_TAGSET addObject:dict];
                        }else if (isDurationTagEnabled && button.selected){
                            if (globals.OPENED_DURATION_TAGS && [[globals.OPENED_DURATION_TAGS allKeys] containsObject:button.titleLabel.text]) {
                                [dict setObject:@"100" forKey:@"type"];
                                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_DURATION_TAG object:self userInfo:dict];
                                //send device information to the server
                                NSString *UUID = [[[UIDevice currentDevice] identifierForVendor]UUIDString];
                                [dict setObject:UUID forKey:@"deviceid"];

                                id tagId = [globals.OPENED_DURATION_TAGS objectForKey:button.titleLabel.text];
                                [dict setObject:tagId forKey:@"id"];
                                [globals.OPENED_DURATION_TAGS removeObjectForKey:button.titleLabel.text];
                                
                                [globals.ARRAY_OF_TAGSET addObject:dict];
                            }else{
                                [dict setObject:@"100" forKey:@"type"];
                                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_DURATION_TAG object:self userInfo:dict];
                                //send device information to the server
                                NSString *UUID = [[[UIDevice currentDevice] identifierForVendor]UUIDString];
                                [dict setObject:UUID forKey:@"deviceid"];

                                [globals.PRECLOSED_DURATION_TAGS setObject:dict forKey:button.titleLabel.text];
                            }
                            
                            button.selected = FALSE;
                           
                        }else{
                            [globals.ARRAY_OF_TAGSET addObject:dict];
                        }


                        
                    }

                }
            }
        }
    }
    
    

    swipedOutButton = button;
    //hide the playercollectionview and the arrows
    [leftArrow setAlpha:0.0f];
    [rightArrow setAlpha:0.0f];
    [self.playerCollectionViewController.view setAlpha:0.0f];
    [self.footballTrainingCollectionViewController.view setAlpha:0.0f];
    
}

-(void)deSelectTagButton{
    if (swipedOutButton.selected) {
        swipedOutButton.selected = FALSE;
    }
}

//after receiving the new duration tag id, send the tagmod request to the server to close the duration tag
-(void)closeDurationTag:(NSNotification *)notification {
    
    NSString *tagName = notification.object;
    id tagId = [globals.OPENED_DURATION_TAGS objectForKey:tagName];
    NSMutableDictionary *dict = [globals.PRECLOSED_DURATION_TAGS objectForKey:tagName];
    [dict setObject:tagId forKey:@"id"];
    [globals.ARRAY_OF_TAGSET addObject:dict];
}


//send the tagset request to the server
// TODO make Nofit to encodermanager
-(void)sendTagInformationToServer{
    if (globals.ARRAY_OF_TAGSET.count < 1) {
        return;
    }
    NSDictionary *dict = [globals.ARRAY_OF_TAGSET objectAtIndex:0];
    [globals.ARRAY_OF_TAGSET removeObjectAtIndex:0];
    NSError *error;
    NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
    NSString *unencodedName = [dict objectForKey:@"name"];
    NSString *encodedName = [Utility encodeSpecialCharacters:unencodedName];
    [mutableDict removeObjectForKey:@"name"];
    [mutableDict setObject:encodedName forKey:@"name"];
    //current absolute time in seconds
    double currentSystemTime = CACurrentMediaTime();
    [mutableDict setObject:[NSString stringWithFormat:@"%f",currentSystemTime] forKey:@"requesttime"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mutableDict options:0 error:&error];
    NSString *jsonString;
    if (! jsonData) {

    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    NSString *url;
    if ([dict objectForKey:@"type"] && [[dict objectForKey:@"type"] isEqualToString:@"100"]) {
        //close duration tag
        url = [NSString stringWithFormat:@"%@/min/ajax/tagmod/%@",globals.URL,jsonString];
    }else{
        //create new tags
        url = [NSString stringWithFormat:@"%@/min/ajax/tagset/%@",globals.URL,jsonString];
    }
//    
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"myplayXplay" message:[NSString stringWithFormat:@"Selected players: %@",[dict objectForKey:@"player"]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//    [alert show];
//    
//    //NSLog(@"sendTagInformationToServer  url: %@, dict : %@",url,dict);
    //NSLog(@"live2bench view sendTagInformationToServer url %@",url);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        
        NSURLConnection *connection = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
        //NSLog(@"Live2bench view sends request.");
        dispatch_async(dispatch_get_main_queue(), ^{
            //update UI here
        });
    });
    

}


/*
 *--------------------
 *After updating to iOS7.1, avplayer might gives us negative video start time(this value randomly changes while the video plays) and video's current time is also based on this start time.
 *For example: Start time is -2 sec and current time is 50 sec which could be mapped to start time is 0 sec, the current time value is 52 sec or start time is -3 sec current time is 49 sec;
 *When user pauses the video, get the current tele time and the current video's start time.
 *After finishing telestartion, send the tag information dictionary to the server and the tag time in the dictionary will be: (tele time) - (start time), which is "52" in our example;
 *The time sent to the server is always based on start time is 0;
 *When reviewing the telestration, the avplayer will seek to is right tele time base on the video's new start time which is (tag time) + (new start time).
 *--------------------
 */
//create telestration screen
-(void)initTele:(id)sender
{
    //pause the video
    [videoPlayer pause];
    CMTime currentCMTime = videoPlayer.avPlayer.currentTime;
   // NSLog(@"init Tele currentime 1: %lld,CMTimeGetSeconds(currentCMTime): %f",currentCMTime.value,CMTimeGetSeconds(currentCMTime));
    globals.TELE_TIME = (float)[self roundValue:CMTimeGetSeconds(currentCMTime)];
    //when show the telestration screen, hide all the buttons in full screen and only diaplay save button and clear button for telestration
    [self hideFullScreenOverlayButtons];
   
    //resize the video player
    videoPlayer.playerFrame = CGRectMake(0, 0, 748, 1024);
    
     //if the mp4 file is played right now
    if ([globals.CURRENT_PLAYBACK_EVENT rangeOfString:@".mp4"].location != NSNotFound) {
        
        UIView *rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
        
        saveTeleButton = [BorderButton buttonWithType:UIButtonTypeCustom];
        [saveTeleButton setFrame:CGRectMake(377.0f, 700.0f, 123.0f, 33.0f)];
        [saveTeleButton setTitle:@"Save" forState:UIControlStateNormal];
        [saveTeleButton addTarget:self action:@selector(saveButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [rootView addSubview:saveTeleButton];
        
        clearTeleButton = [BorderButton buttonWithType:UIButtonTypeCustom];
        [clearTeleButton setFrame:CGRectMake(CGRectGetMaxX(saveTeleButton.frame) + 15.0f, saveTeleButton.frame.origin.y, saveTeleButton.frame.size.width, saveTeleButton.frame.size.height)];
        [clearTeleButton setTitle:@"Close" forState:UIControlStateNormal];
        [clearTeleButton addTarget:self action:@selector(clearButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [rootView addSubview:clearTeleButton];
        
        
        //add televiewcontroller
        self.teleViewController= [[TeleViewController alloc] initWithController:self];
        [self.teleViewController.view setFrame:CGRectMake(0, 55, self.view.frame.size.width,self.view.frame.size.width * 9/16 + 10)];
        self.teleViewController.clearButton = clearTeleButton;
        [teleButton setHidden:TRUE];
        [rootView addSubview:self.teleViewController.view];
        
        [rootView bringSubviewToFront:saveTeleButton];
        [rootView bringSubviewToFront:clearTeleButton];

        
        NSURL *videoURL = globals.VIDEO_PLAYER_LIVE2BENCH.videoURL;
        AVAsset *asset = [AVAsset assetWithURL:videoURL];
        AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
        imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
        imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
        [imageGenerator setMaximumSize:CGSizeMake(self.view.frame.size.width,self.view.frame.size.width * 9/16)];
        //CMTime time = CMTimeMake([[dict objectForKey:@"time"]floatValue],1);//CMTimeMake(30, 1);
        ////////NSLog(@"%f", [[dict objectForKey:@"time"]floatValue]);
        CGImageRef imageRef = [imageGenerator copyCGImageAtTime:currentCMTime actualTime:&currentCMTime error:NULL];
        UIImage *currentImage = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        
        self.teleViewController.currentImage = currentImage;//[self imageWithImage:currentImage convertToSize:CGSizeMake(self.view.frame.size.width,self.view.frame.size.width * 9/16)];//currentImage;
        self.teleViewController.thumbImageView = [[UIImageView alloc] initWithImage:currentImage];//[UIImage imageNamed:@"test.jpg"]];
        [self.teleViewController.thumbImageView setFrame:CGRectMake(0, 40, self.teleViewController.view.bounds.size.width, self.teleViewController.view.bounds.size.height)];//CGRectMake(0, -10, 1024,768)];
        [self.teleViewController.thumbImageView setBackgroundColor:[UIColor blackColor]];
        [self.teleViewController.view insertSubview:self.teleViewController.thumbImageView atIndex:0];

    }else{
        //if the mp4 video file not exist
        
        //add televiewcontroller
        self.teleViewController= [[TeleViewController alloc] initWithController:self];
        
        globals.TELE_TIME = [videoPlayer currentTimeInSeconds];
        self.teleViewController.offsetTime = videoPlayer.startTime;
        [self.teleViewController.view setFrame:CGRectMake(0, 10, 1024, 768)];
        [self.teleButton setHidden:TRUE];
        [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.teleViewController.view];
       
    }
    
}

//save button clicked, send notification to the teleview controller
-(void)saveButtonClicked{
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"Save Tele" object:nil];
}

//clear button clicked, send notification to the teleview controller
-(void)clearButtonClicked{
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"Clear Tele" object:nil];
}

-(int)roundValue:(float)numberToRound{
    numberToRound = numberToRound;
    if (videoPlayer.duration - numberToRound < 2) {
        return (int)numberToRound;
    }
    
    return  (int)(numberToRound + 0.5);
    
}

//init all the control buttons for live2bench view
- (void)initialiseLayout
{
    //initalize overlay items
    self.overlayItems = [[NSMutableArray alloc] init];
    
/*
    //tagSetView is the tagMaker bar under video view, but marking area is x:[126,595]
    if(!self.tagSetView){
       self.tagSetView = [[UIView alloc]init];
    }
    [self.tagSetView setFrame:CGRectMake(videoPlayer.view.frame.origin.x,videoPlayer.view.frame.size.height+videoPlayer.view.frame.origin.y, videoPlayer.view.frame.size.width+1, 40)];
 //   [self.tagSetView setBackgroundColor:[UIColor colorWithWhite:0.9f alpha:1.0f]];
    [self.tagSetView setUserInteractionEnabled:TRUE];
    [self.tagSetView setClipsToBounds:FALSE];
    [self.view insertSubview:self.tagSetView belowSubview:self.playerCollectionViewController.view];
 
    
    self.tagEventName = [[UILabel alloc] initWithFrame:CGRectMake((self.tagSetView.frame.size.width/2)-75, 1, 150, self.tagSetView.frame.size.height-2)];
    [self.tagEventName setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.9f]];
    self.tagEventName.layer.borderColor = PRIMARY_APP_COLOR.CGColor;
    self.tagEventName.layer.borderWidth = 1;
    [self.tagEventName setTextColor:PRIMARY_APP_COLOR];
    [self.tagEventName setText:@"Event Name"];
    [self.tagEventName setTextAlignment:NSTextAlignmentCenter];
    [self.tagEventName setAlpha:1.0f];
    [self.tagEventName setHidden:TRUE]; //the label won't show up in live mode
    [self.tagSetView addSubview:self.tagEventName];
 
    //add little orange triangle to show user which tag they are playing
    self.currentPlayingEventMarker = [[UIView alloc]initWithFrame:CGRectMake(self.tagSetView.frame.size.width/2, self.tagSetView.frame.size.height, 20, 20)];
    [self.currentPlayingEventMarker setBackgroundColor:[UIColor clearColor]];
    UIImageView *markerImage = [[UIImageView alloc]initWithFrame:self.currentPlayingEventMarker.bounds];
    [markerImage setImage:[UIImage imageNamed:@"ortri.png"]];
    [self.currentPlayingEventMarker addSubview:markerImage];
    [self.currentPlayingEventMarker setHidden:TRUE];
    [self.tagSetView addSubview:self.currentPlayingEventMarker];


    
    //add go back five seconds button
    currentSeekBackButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    [currentSeekBackButton setFrame:CGRectMake(tagSetView.frame.origin.x,PADDING + videoPlayer.view.frame.size.height + 98, LITTLE_ICON_DIMENSIONS, LITTLE_ICON_DIMENSIONS-5)];
    [currentSeekBackButton setContentMode:UIViewContentModeScaleAspectFill];
    UIImage *backButtonImage;
    if (globals.CURRENT_SEEK_BACK_ACTION == @selector(seekBackQuarterSecond:)) {
        backButtonImage = [UIImage imageNamed:@"seekbackquartersec.png"];
    }else if (globals.CURRENT_SEEK_BACK_ACTION == @selector(seekBackOneSecond:)){
        backButtonImage = [UIImage imageNamed:@"seekbackonesec.png"];
    }else{
        backButtonImage = [UIImage imageNamed:@"seekbackfivesecs.png"];
        globals.CURRENT_SEEK_BACK_ACTION = @selector(seekBackFiveSeconds:);
    }
    [currentSeekBackButton setImage:backButtonImage forState:UIControlStateNormal];
    [currentSeekBackButton addTarget:self action:globals.CURRENT_SEEK_BACK_ACTION forControlEvents:UIControlEventTouchUpInside];
    //[currentSeekBackButton addTarget:self action:@selector(swipeOutSeekControlView:) forControlEvents:UIControlEventTouchDragInside];
    [self.view insertSubview:currentSeekBackButton aboveSubview:tagSetView];
    
 
    
    
    //hide them for current build 1.1.7
    UILongPressGestureRecognizer *seekBackLongpressgesture = [[UILongPressGestureRecognizer alloc]
                                                      initWithTarget:self action:@selector(handleLongPress:)];
    seekBackLongpressgesture.minimumPressDuration = 0.5; //seconds
    seekBackLongpressgesture.delegate = self;
    [currentSeekBackButton addGestureRecognizer:seekBackLongpressgesture];
    
    //uiview contains three seek back modes: go back 5s, 1s, 0.25s
    seekBackControlView = [[UIView alloc]initWithFrame:CGRectMake(tagSetView.frame.origin.x, currentSeekBackButton.frame.origin.y - 160,LITTLE_ICON_DIMENSIONS,4.5*currentSeekBackButton.frame.size.height)];
    [seekBackControlView setBackgroundColor:[UIColor colorWithRed:(195/255.0) green:(207/255.0) blue:(216/255.0) alpha:0.3]];
    seekBackControlView.hidden = TRUE;
    [self.view insertSubview:seekBackControlView aboveSubview:self.videoPlayer.view];
 
    //go back 0.25s
    CustomButton *backQuarterSecButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    [backQuarterSecButton setFrame:CGRectMake(0, 10, LITTLE_ICON_DIMENSIONS, LITTLE_ICON_DIMENSIONS)];
    [backQuarterSecButton setContentMode:UIViewContentModeScaleAspectFill];
    [backQuarterSecButton setImage:[UIImage imageNamed:@"seekbackquartersec.png"] forState:UIControlStateNormal];
    [backQuarterSecButton addTarget:self action:@selector(seekBackQuarterSecond:) forControlEvents:UIControlEventTouchUpInside];
    [backQuarterSecButton addTarget:self action:@selector(hideSeekControlView:) forControlEvents:UIControlEventTouchDragInside];
    [seekBackControlView addSubview:backQuarterSecButton];
    
    //go back 1 s
    CustomButton *backOneSecButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    [backOneSecButton setFrame:CGRectMake(0, backQuarterSecButton.frame.origin.y + backQuarterSecButton.frame.size.height + 10, LITTLE_ICON_DIMENSIONS, LITTLE_ICON_DIMENSIONS)];
    [backOneSecButton setContentMode:UIViewContentModeScaleAspectFill];
    [backOneSecButton setImage:[UIImage imageNamed:@"seekbackonesec.png"] forState:UIControlStateNormal];
    [backOneSecButton addTarget:self action:@selector(seekBackOneSecond:) forControlEvents:UIControlEventTouchUpInside];
    [backOneSecButton addTarget:self action:@selector(hideSeekControlView:) forControlEvents:UIControlEventTouchDragInside];
    [seekBackControlView addSubview:backOneSecButton];
    
    //go back 5 s
    CustomButton *backFiveSecsButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    [backFiveSecsButton setFrame:CGRectMake(0, backOneSecButton.frame.origin.y + backOneSecButton.frame.size.height + 10, LITTLE_ICON_DIMENSIONS, LITTLE_ICON_DIMENSIONS)];
    [backFiveSecsButton setContentMode:UIViewContentModeScaleAspectFill];
    [backFiveSecsButton setImage:[UIImage imageNamed:@"seekbackfivesecs.png"] forState:UIControlStateNormal];
    [backFiveSecsButton addTarget:self action:@selector(seekBackFiveSeconds:) forControlEvents:UIControlEventTouchUpInside];
    [backFiveSecsButton addTarget:self action:@selector(hideSeekControlView:) forControlEvents:UIControlEventTouchDragInside];
    [seekBackControlView addSubview:backFiveSecsButton];
    
 
    //add go forward 5 seconds button
    currentSeekForwardButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    [currentSeekForwardButton setFrame:CGRectMake(MEDIA_PLAYER_WIDTH + 115,PADDING + videoPlayer.view.frame.size.height + 98, LITTLE_ICON_DIMENSIONS, LITTLE_ICON_DIMENSIONS-5)];
    [currentSeekForwardButton setContentMode:UIViewContentModeScaleAspectFill];
    UIImage *forwardButtonImage;
    if (globals.CURRENT_SEEK_BACK_ACTION == @selector(seekBackQuarterSecond:)) {
        forwardButtonImage = [UIImage imageNamed:@"seekforwardquartersec.png"];
        globals.CURRENT_SEEK_FORWARD_ACTION = @selector(seekForwardQuarterSecond:);
    }else if (globals.CURRENT_SEEK_BACK_ACTION == @selector(seekBackOneSecond:)){
        forwardButtonImage = [UIImage imageNamed:@"seekforwardonesec.png"];
        globals.CURRENT_SEEK_FORWARD_ACTION = @selector(seekForwardOneSecond:);
    }else{
        forwardButtonImage = [UIImage imageNamed:@"seekforwardfivesecs.png"];
        globals.CURRENT_SEEK_FORWARD_ACTION = @selector(seekForwardFiveSeconds:);
    }

    [currentSeekForwardButton setImage:forwardButtonImage forState:UIControlStateNormal];
    [currentSeekForwardButton addTarget:self action:globals.CURRENT_SEEK_FORWARD_ACTION forControlEvents:UIControlEventTouchUpInside];
    //[currentSeekForwardButton addTarget:self action:@selector(swipeOutSeekControlView:) forControlEvents:UIControlEventTouchDragInside];
    [self.view insertSubview:currentSeekForwardButton aboveSubview:tagSetView];
    //hide them for current build 1.1.7
    UILongPressGestureRecognizer *seekForwardLongpressgesture = [[UILongPressGestureRecognizer alloc]
                                                      initWithTarget:self action:@selector(handleLongPress:)];
    seekForwardLongpressgesture.minimumPressDuration = 0.5; //seconds
    seekForwardLongpressgesture.delegate = self;
    [currentSeekForwardButton addGestureRecognizer:seekForwardLongpressgesture];
 
    
    //uiview contains three seek back modes: go back 5s, 1s, 0.25s
    seekForwardControlView = [[UIView alloc]initWithFrame:CGRectMake(tagSetView.frame.origin.x + tagSetView.frame.size.width - LITTLE_ICON_DIMENSIONS , seekBackControlView.frame.origin.y,seekBackControlView.frame.size.width,seekBackControlView.frame.size.height)];
    [seekForwardControlView setBackgroundColor:[UIColor colorWithRed:(195/255.0) green:(207/255.0) blue:(216/255.0) alpha:0.3]];
    seekForwardControlView.hidden = TRUE;
    [self.view insertSubview:seekForwardControlView aboveSubview:self.videoPlayer.view];
    
    //go back 0.25s
    CustomButton *forwardQuarterSecButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    [forwardQuarterSecButton setFrame:CGRectMake(0, 10, LITTLE_ICON_DIMENSIONS, LITTLE_ICON_DIMENSIONS)];
    [forwardQuarterSecButton setContentMode:UIViewContentModeScaleAspectFill];
    [forwardQuarterSecButton setImage:[UIImage imageNamed:@"seekforwardquartersec.png"] forState:UIControlStateNormal];
    [forwardQuarterSecButton addTarget:self action:@selector(seekForwardQuarterSecond:) forControlEvents:UIControlEventTouchUpInside];
    [forwardQuarterSecButton addTarget:self action:@selector(hideSeekControlView:) forControlEvents:UIControlEventTouchDragInside];
    [seekForwardControlView addSubview:forwardQuarterSecButton];
    
    //go back 1 s
    CustomButton *forwardOneSecButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    [forwardOneSecButton setFrame:CGRectMake(0, backQuarterSecButton.frame.origin.y + backQuarterSecButton.frame.size.height + 10, LITTLE_ICON_DIMENSIONS, LITTLE_ICON_DIMENSIONS)];
    [forwardOneSecButton setContentMode:UIViewContentModeScaleAspectFill];
    [forwardOneSecButton setImage:[UIImage imageNamed:@"seekforwardonesec.png"] forState:UIControlStateNormal];
    [forwardOneSecButton addTarget:self action:@selector(seekForwardOneSecond:) forControlEvents:UIControlEventTouchUpInside];
    [forwardOneSecButton addTarget:self action:@selector(hideSeekControlView:) forControlEvents:UIControlEventTouchDragInside];
    [seekForwardControlView addSubview:forwardOneSecButton];
    
    //go back 5 s
    CustomButton *forwardFiveSecsButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    [forwardFiveSecsButton setFrame:CGRectMake(0, backOneSecButton.frame.origin.y + backOneSecButton.frame.size.height + 10, LITTLE_ICON_DIMENSIONS, LITTLE_ICON_DIMENSIONS)];
    [forwardFiveSecsButton setContentMode:UIViewContentModeScaleAspectFill];
    [forwardFiveSecsButton setImage:[UIImage imageNamed:@"seekforwardfivesecs.png"] forState:UIControlStateNormal];
    [forwardFiveSecsButton addTarget:self action:@selector(seekForwardFiveSeconds:) forControlEvents:UIControlEventTouchUpInside];
    [forwardFiveSecsButton addTarget:self action:@selector(hideSeekControlView:) forControlEvents:UIControlEventTouchDragInside];
    [seekForwardControlView addSubview:forwardFiveSecsButton];
   
    [slowMoButton addTarget:self action:@selector(slowMoController:) forControlEvents:UIControlEventTouchUpInside];

    [self.view insertSubview:slowMoButton aboveSubview:tagSetView];
     *///888
    
    
    
    UILongPressGestureRecognizer *modifiedTagDurationByStartTimeLongpressgesture = [[UILongPressGestureRecognizer alloc]
                                                                                  initWithTarget:self action:@selector(changeDurationModifierButtonIcon:)];
    modifiedTagDurationByStartTimeLongpressgesture.minimumPressDuration = 0.5; //seconds
    modifiedTagDurationByStartTimeLongpressgesture.delegate = self;
    [_videoBarViewController.startRangeModifierButton addGestureRecognizer:modifiedTagDurationByStartTimeLongpressgesture];

    
    UILongPressGestureRecognizer *modifiedTagDurationByEndTimeLongpressgesture = [[UILongPressGestureRecognizer alloc]
                                                                                initWithTarget:self action:@selector(changeDurationModifierButtonIcon:)];
    modifiedTagDurationByEndTimeLongpressgesture.minimumPressDuration = 0.5; //seconds
    modifiedTagDurationByEndTimeLongpressgesture.delegate = self;
    [_videoBarViewController.endRangeModifierButton addGestureRecognizer:modifiedTagDurationByEndTimeLongpressgesture];

    
    
    
    _liveButton = [[LiveButton alloc]initWithFrame:CGRectMake(MEDIA_PLAYER_WIDTH +videoPlayer.view.frame.origin.x+32,PADDING + videoPlayer.view.frame.size.height + 95, 130, LITTLE_ICON_DIMENSIONS)];
    [_liveButton addTarget:self action:@selector(goToLive) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:_liveButton aboveSubview:_videoBarViewController.view];
    
    //add continue play button
    continuePlayButton = [BorderButton buttonWithType:UIButtonTypeCustom];
    [continuePlayButton setFrame:CGRectMake(0,PADDING + videoPlayer.view.frame.size.height + 100, 130, LITTLE_ICON_DIMENSIONS-10)];
    [continuePlayButton setContentMode:UIViewContentModeScaleAspectFill];
    [continuePlayButton setBackgroundImage:[UIImage imageNamed:@"continue_unselected.png"] forState:UIControlStateNormal];
    [continuePlayButton setBackgroundImage:[UIImage imageNamed:@"continue.png"] forState:UIControlStateSelected];
    [continuePlayButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [continuePlayButton setTitle:@"Continue" forState:UIControlStateNormal];
    [continuePlayButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [continuePlayButton setContentEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
    [continuePlayButton addTarget:self action:@selector(continuePlay) forControlEvents:UIControlEventTouchUpInside];
    [continuePlayButton setHidden:TRUE];
    //need to be modified later
    [self.view insertSubview:continuePlayButton aboveSubview:_videoBarViewController.view];

    
    
    
    self.didInitLayout = TRUE;
    
    
    //init button to view telestration
    viewTeleButton = [BorderButton buttonWithType:UIButtonTypeCustom];
    [viewTeleButton setFrame:CGRectMake(self.rightSideButtons.frame.origin.x,currentEventTitle.frame.origin.y -10, 130, LITTLE_ICON_DIMENSIONS - 5)];
    [viewTeleButton setTitle:@"View Tele" forState:UIControlStateNormal];
    [viewTeleButton addTarget:self action:@selector(viewTele:) forControlEvents:UIControlEventTouchUpInside];
    //viewtelebutton only for medical use
    //[self.view addSubview:viewTeleButton];
    if (!globals.LATEST_TELE) {
        viewTeleButton.hidden = TRUE;
    }
}

//view the latest telestration
-(void)viewTele:(BorderButton*)button{
    button.hidden = TRUE;
    viewTeleButton.hidden = TRUE;
    viewTeleButtoninFullScreen.hidden = TRUE;
    isViewTeleButtonSelected = TRUE;
    globals.IS_PLAYBACK_TELE = YES;
    globals.CURRENT_PLAYBACK_TAG = globals.LATEST_TELE;
    [self setCurrentPlayingTag:globals.LATEST_TELE];
    if (!videoPlayer.isFullScreen) {
        [videoPlayer enterFullscreen];
    }else{
        [self updateViewforTele];
    }
    globals.LATEST_TELE = nil;
}
//when receive new telestration from the server, show the view tele button if it is hidden; or flash the tele button if it is not hidden
-(void)getNewTele{
    viewTeleButton.hidden = FALSE;
    viewTeleButtoninFullScreen.hidden = FALSE;
    
    [UIView animateWithDuration:0.3
                     animations:^{[viewTeleButton setBackgroundColor:[UIColor orangeColor]];[viewTeleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];[viewTeleButtoninFullScreen setBackgroundColor:[UIColor orangeColor]];[viewTeleButtoninFullScreen setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];}
                     completion:^(BOOL finished){[viewTeleButton setBackgroundColor:[UIColor clearColor]];[viewTeleButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];[viewTeleButtoninFullScreen setBackgroundColor:[UIColor clearColor]];[viewTeleButtoninFullScreen setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];}];
}

//if press the view tele button in fullscreen, will update the fullscreen subviews
-(void)updateViewforTele{
    
//    if ( telestrationOverlay) {
//        //set the frame size of the telestration overlay to match the thumbnail image
//        [telestrationOverlay setFrame:CGRectMake(0, videoPlayer.view.bounds.origin.y+10, videoPlayer.view.bounds.size.width, videoPlayer.view.bounds.size.height)];
//        [telestrationOverlay setContentMode:UIViewContentModeScaleAspectFit];
//    }
    //remove subviews which were created before
    for(UIView *view in self.overlayItems)
    {
        [UIView animateWithDuration:0.2
                         animations:^{view.alpha = 0.0;}
                         completion:^(BOOL finished){ [view removeFromSuperview]; }];
        [view removeFromSuperview];
    }

    [self removeFullScreenOverlayButtonsinLoopMode];
    [self willEnterFullscreen];
}

//control for enabling/disabling "duration tag"
-(void)switchValueChanged{
    if (durationTagSwitch.on) {
        isDurationTagEnabled = TRUE;
    }else{
        if (swipedOutButton.selected) {
            [swipedOutButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        }else if (self.soccerBottomViewController.playerbuttonWasSelected.selected){
            [self.soccerBottomViewController.playerbuttonWasSelected sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
        isDurationTagEnabled = FALSE;
    }
    globals.UNCLOSED_EVENT = nil;
}


//this method will be called, when get response from getallgametags request
-(void)updateEventInformation{
    ////////NSLog(@"updateeventinformation globals.TEAM_SETUP: %@",globals.TEAM_SETUP);
    //update the event title 
    //display the event name on the top right of the videoplayer
    [currentEventTitle setText:globals.HUMAN_READABLE_EVENT_NAME];
    [currentEventTitle setNeedsDisplay];
    
    //update playercollectionview
    if ([_eventType isEqualToString:SPORT_FOOTBALL_TRAINING]) {
        [self initialFootballTrainingCollectionView];
    } else {
        [self intialPlayerCollectionView];
    }
    //update bottomview
   // [self initialBottomView:_eventType];
    //update tagmarkers
    if (switchToLiveEvent && globals.DID_RECV_GAME_TAGS) {
        [self switchToLive];
        switchToLiveEvent = FALSE;
    }
}

//create bottom views according to which sport is playing
-(void)initialBottomView:(NSString*)sport
{
    //if there is a duration tag from other event not closed(then the tag button is in selected mode), deselect the tag button
    if (isDurationTagEnabled && swipedOutButton.selected) {
        swipedOutButton.selected = FALSE;
        swipedOutButton = nil;
    }
    isDurationTagEnabled = ([sport isEqualToString:@""])?YES:NO; // Richard
    
    //delete the duration tag label and switch in case the next playing event is a different sport
    [durationTagLabel removeFromSuperview];
    [durationTagSwitch removeFromSuperview];
    durationTagLabel = nil;
    durationTagSwitch = nil;
    
    //always remove the old one, create a new one.
    if (self.hockeyBottomViewController){
        [[NSNotificationCenter defaultCenter]removeObserver:self.hockeyBottomViewController name:@"EventInformationUpdated" object:nil];
        [[NSNotificationCenter defaultCenter]removeObserver:self.hockeyBottomViewController name:@"UpdateBottomViewControInfo" object:nil];
        [self.hockeyBottomViewController.view removeFromSuperview];
        self.hockeyBottomViewController = nil;
    }else if (self.soccerBottomViewController) {
        [[NSNotificationCenter defaultCenter]removeObserver:self.soccerBottomViewController name:@"EventInformationUpdated" object:nil];
        [[NSNotificationCenter defaultCenter]removeObserver:self.soccerBottomViewController name:@"UpdateSoccerBottomViewControInfo" object:nil];
        [self.soccerBottomViewController.view removeFromSuperview];
        self.soccerBottomViewController = nil;
    }else if(self.footballBottomViewController) {
        [[NSNotificationCenter defaultCenter]removeObserver:self.footballBottomViewController name:@"EventInformationUpdated" object:nil];
        [[NSNotificationCenter defaultCenter]removeObserver:self.footballBottomViewController name:@"UpdateFBBottomViewControInfo" object:nil];
        
        [self.footballBottomViewController.view removeFromSuperview];
        self.footballBottomViewController = nil;
    }else if(self.footballTrainingBottomViewController) {
        [[NSNotificationCenter defaultCenter]removeObserver:self.footballBottomViewController name:@"EventInformationUpdated" object:nil];
        [[NSNotificationCenter defaultCenter]removeObserver:self.footballBottomViewController name:@"UpdateFBBottomViewControInfo" object:nil];
        
        [self.footballTrainingBottomViewController.view removeFromSuperview];
        self.footballTrainingBottomViewController = nil;
    }

    if (FALSE){ // Forces football training. remove this and the "else" before the next if statement
        NSLog(@"BOTTOM VIEW BEING FORCED TO FOOTBALL TRAINING, REMOVE THIS BEFORE PUSHING");
        self.footballTrainingBottomViewController=[[FootballTrainingBottomViewController alloc] initWithController:self];
        [self.footballTrainingBottomViewController.view setFrame:CGRectMake(0, 548, TOTAL_WIDTH, 250)];
        [self.view insertSubview:self.footballTrainingBottomViewController.view belowSubview:self.footballTrainingCollectionViewController.view];
        
        if (![globals.CURRENT_PLAYBACK_EVENT isEqualToString:@""]) {
            [self.footballTrainingBottomViewController.view setHidden:FALSE];
        }else{
            //if no event playing, leave the bottom view blank
            [self.footballTrainingBottomViewController.view setHidden:TRUE];
        }
        
        
    }
    
    //If stop and (not going to live2bench)start new live event with the same sport as before in setting view,the buttons selected in bottom view in the old event will stay here
    else if([sport isEqualToString:@"hockey"])
    {
        //create bottom cont
        self.hockeyBottomViewController=[[HockeyBottomViewController alloc] initWithController:self];
        [self.hockeyBottomViewController.view setFrame:CGRectMake(0, 548, TOTAL_WIDTH, 250)];
        //[self.view addSubview:self.bottomViewController.view];
        [self.view insertSubview:self.hockeyBottomViewController.view belowSubview:self.playerCollectionViewController.view];
        
        if(((![globals.CURRENT_ENC_STATUS isEqualToString:encStateLive] || (int)[[[videoPlayer avPlayer]currentItem]status] == AVPlayerItemStatusFailed || (int)[[[videoPlayer avPlayer]currentItem]status] == AVPlayerItemStatusUnknown) && ([globals.EVENT_NAME isEqualToString:@"live"]|| [globals.EVENT_NAME isEqualToString:@""]))|| [globals.CURRENT_PLAYBACK_EVENT isEqualToString:@""]){
            [self.hockeyBottomViewController.view setUserInteractionEnabled:FALSE];
            [self.hockeyBottomViewController.view setAlpha:0.6];
            
        }else{
            [self.hockeyBottomViewController.view setUserInteractionEnabled:TRUE];
            [self.hockeyBottomViewController.view setAlpha:1.0];
        }
        
        if (![globals.CURRENT_PLAYBACK_EVENT isEqualToString:@""]) {
            [self.hockeyBottomViewController.view setHidden:FALSE];
        }else{
            //if no event playing, leave the bottom view blank
            [self.hockeyBottomViewController.view setHidden:TRUE];
        }
       
        
    }else if ([[sport lowercaseString] isEqualToString:@"soccer"] || [[sport lowercaseString] isEqualToString:@"rugby"]|| [_eventType isEqualToString:@"basketball"])// for soccer and ruby
    {
        //create bottom cont
        self.soccerBottomViewController=[[SoccerBottomViewController alloc] initWithController:self];
        [self.soccerBottomViewController.view setFrame:CGRectMake(0, 548, TOTAL_WIDTH, 250)];
        //[self.view addSubview:self.soccerBottomViewController.view];
        [self.view insertSubview:self.soccerBottomViewController.view belowSubview:self.playerCollectionViewController.view];
        
        if(((![globals.CURRENT_ENC_STATUS isEqualToString:encStateLive] || (int)[[[videoPlayer avPlayer]currentItem]status] == AVPlayerItemStatusFailed || (int)[[[videoPlayer avPlayer]currentItem]status] == AVPlayerItemStatusUnknown) && ([globals.EVENT_NAME isEqualToString:@"live"]|| [globals.EVENT_NAME isEqualToString:@""]))|| [globals.CURRENT_PLAYBACK_EVENT isEqualToString:@""]){
            [self.soccerBottomViewController.zoneLabel setUserInteractionEnabled:FALSE];
            [self.soccerBottomViewController.zoneLabel setAlpha:0.6];
            [self.soccerBottomViewController.zoneSegmentedControl setUserInteractionEnabled:FALSE];
            [self.soccerBottomViewController.zoneSegmentedControl setAlpha:0.6];
            [self.soccerBottomViewController.halfLabel setUserInteractionEnabled:FALSE];
            [self.soccerBottomViewController.halfLabel setAlpha:0.6];
            [self.soccerBottomViewController.periodSegmentedControl setUserInteractionEnabled:FALSE];
            [self.soccerBottomViewController.periodSegmentedControl setAlpha:0.6];
        }else{
            [self.soccerBottomViewController.zoneLabel setUserInteractionEnabled:TRUE];
            [self.soccerBottomViewController.zoneLabel setAlpha:1.0];
            [self.soccerBottomViewController.zoneSegmentedControl setUserInteractionEnabled:TRUE];
            [self.soccerBottomViewController.zoneSegmentedControl setAlpha:1.0];
            [self.soccerBottomViewController.halfLabel setUserInteractionEnabled:TRUE];
            [self.soccerBottomViewController.halfLabel setAlpha:1.0];
            [self.soccerBottomViewController.periodSegmentedControl setUserInteractionEnabled:TRUE];
            [self.soccerBottomViewController.periodSegmentedControl setAlpha:1.0];
        }
        
        if (![globals.CURRENT_PLAYBACK_EVENT isEqualToString:@""]) {
            [self.soccerBottomViewController.view setHidden:FALSE];
        }else{
            //if no event playing, leave the bottom view blank
            [self.soccerBottomViewController.view setHidden:TRUE];
        }
        
        
    }else if([_eventType isEqual:@"football"]){
        self.footballBottomViewController=[[FootballBottomViewController alloc] initWithController:self];
        [self.footballBottomViewController.view setFrame:CGRectMake(0, 548, TOTAL_WIDTH, 250)];
        [self.view insertSubview:self.footballBottomViewController.view belowSubview:self.playerCollectionViewController.view];
        
        if (![globals.CURRENT_PLAYBACK_EVENT isEqualToString:@""]) {
            [self.footballBottomViewController.view setHidden:FALSE];
        }else{
            //if no event playing, leave the bottom view blank
            [self.footballBottomViewController.view setHidden:TRUE];
        }

    } else if ([_eventType isEqual:SPORT_FOOTBALL_TRAINING]){
        self.footballTrainingBottomViewController=[[FootballTrainingBottomViewController alloc] initWithController:self];
        [self.footballTrainingBottomViewController.view setFrame:CGRectMake(0, 548, TOTAL_WIDTH, 250)];
        [self.view insertSubview:self.footballTrainingBottomViewController.view belowSubview:self.footballTrainingCollectionViewController.view];
        
        if (![globals.CURRENT_PLAYBACK_EVENT isEqualToString:@""]) {
            [self.footballTrainingBottomViewController.view setHidden:FALSE];
        }else{
            //if no event playing, leave the bottom view blank
            [self.footballTrainingBottomViewController.view setHidden:TRUE];
        }
        

    } else {
        NSLog(@"Unrecognized sport %@",_eventType);
    }
    
    if ([_eventType isEqual:@"hockey"] || [_eventType isEqual:@"football"] || [_eventType isEqualToString:@"football training"]) {
        //label for "duration tag"
        durationTagLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 60, 90, 28)];
        [durationTagLabel setText:@"Dur/Event"];
        [durationTagLabel setFont:[UIFont defaultFontOfSize:17.0f]];
        
        //switch which used to enable duration tag
        durationTagSwitch = [[TTSwitch alloc] initWithFrame:CGRectMake( CGRectGetMaxX(durationTagLabel.frame), durationTagLabel.frame.origin.y,durationTagLabel.frame.size.width-10, durationTagLabel.frame.size.height)];
        durationTagSwitch.trackImage = [UIImage imageNamed:@"switch_track"];
        durationTagSwitch.thumbImage = [UIImage imageNamed:@"switch_thumb"];
        durationTagSwitch.trackMaskImage = [UIImage imageNamed:@"square-switch-mask"];
        durationTagSwitch.thumbMaskImage = nil; // Set this to nil to override the UIAppearance setting
        durationTagSwitch.thumbInsetX = 1;
        [durationTagSwitch addTarget:self action:@selector(switchValueChanged) forControlEvents:UIControlEventValueChanged];
        durationTagSwitch.on = FALSE;

        [self.view addSubview:durationTagLabel];
        [self.view addSubview:durationTagSwitch];

       
    }else if ([[sport lowercaseString] isEqualToString:@"soccer"] || [[sport lowercaseString] isEqualToString:@"rugby"]|| [_eventType isEqualToString:@"basketball"]){
        
        float durationTagLabelX = 0;
        if ([[sport lowercaseString] isEqualToString:@"soccer"]) {
            durationTagLabelX = 27;
        }else if([[sport lowercaseString] isEqualToString:@"rugby"]){
            durationTagLabelX = 322;
        }

        
        //label for "duration tag"
        durationTagLabel = [[UILabel alloc]initWithFrame:CGRectMake(durationTagLabelX, 23, 90, 28)];
        [durationTagLabel setText:@"Dur/Event"];
        [durationTagLabel setFont:[UIFont defaultFontOfSize:17.0f]];
        
        //switch which used to enable duration tag
        durationTagSwitch = [[TTSwitch alloc] initWithFrame:CGRectMake(durationTagLabelX, CGRectGetMaxY(durationTagLabel.frame),durationTagLabel.frame.size.width-10, durationTagLabel.frame.size.height)];
        durationTagSwitch.trackImage = [UIImage imageNamed:@"switch_track"];
        durationTagSwitch.thumbImage = [UIImage imageNamed:@"switch_thumb"];
        durationTagSwitch.trackMaskImage = [UIImage imageNamed:@"square-switch-mask"];
        durationTagSwitch.thumbMaskImage = nil; // Set this to nil to override the UIAppearance setting
        [durationTagSwitch addTarget:self action:@selector(switchValueChanged) forControlEvents:UIControlEventValueChanged];
        durationTagSwitch.on = FALSE;
        [self.soccerBottomViewController.view addSubview:durationTagLabel];
        [self.soccerBottomViewController.view addSubview:durationTagSwitch];
 
    }
    
}

//This method will be called when continue play button is pressed.
//The loop mode will be destroyed, and video player will continue to play
-(void)continuePlay{
    [self destroyThumbLoop];
    [videoPlayer play];
    globals.IS_LOOP_MODE = FALSE;
    globals.IS_PLAYBACK_TELE = FALSE;
}

//playing a thumbnail which is selected in clip view, 
-(void)setCurrentPlayingTag:(NSDictionary*)tag
{
    //set globals.DID_GO_TO_LIVE to false
    globals.DID_GO_TO_LIVE = FALSE;
    //set globals.RETAINEDPLAYBACKTIME to zer
    globals.RETAINEDPLAYBACKTIME = 0.0;
    //display continue play button
    [self.continuePlayButton setHidden:FALSE];
    //init the variable: currentPlayingTag
    currentPlayingTag = [tag mutableCopy];
    //set tagEventName label text to be the current tag name
    [self setCurrentEventName:[tag objectForKey:@"name"]];
//    [self.tagEventName setHidden:FALSE];
//    [self.tagEventName setText:self.currentEventName];
    
    [_videoBarViewController setTagName:self.currentEventName];
    
    //display the buttons which used to seek back/forward 5 secs
/*
    [self.currentSeekBackButton setHidden:TRUE];
    [self.currentSeekForwardButton setHidden:TRUE];
  *///888
     globals.IS_LOOP_MODE = TRUE;
    //NSLog(@"****************************************************current playing tag: %@",tag);
    
    //telestration type = 4
    if([[tag objectForKey:@"type"] intValue]==4)
    {
        //pause video
        [videoPlayer pause];
        
        [self.startRangeModifierButton setHidden:TRUE];
        [self.endRangeModifierButton setHidden:TRUE];
//        [slowMoButton setHidden:TRUE];//888
        globals.IS_PLAYBACK_TELE = TRUE;
        
        //NSLog(@"starttime %f, globals.HOME_START_TIME %f",videoPlayer.startTime, globals.HOME_START_TIME);
        globals.HOME_START_TIME=[[tag objectForKey:@"time"] doubleValue]+ videoPlayer.startTime;
        globals.HOME_END_TIME=globals.HOME_START_TIME;
       
        //if there is tele overlay from previous tele tag, remove it
        if(telestrationOverlay)
        {
            [telestrationOverlay removeFromSuperview];
            telestrationOverlay = nil;
        }
        //get the current time scale
        int timeScale = self.videoPlayer.avPlayer.currentTime.timescale;//[[tag objectForKey:@"timescale"]integerValue];
        if(timeScale <= 0){
            timeScale = 600;
        }
        videoPlayer.avPlayer.currentItem.seekingWaitsForVideoCompositionRendering = YES;
        //NSLog(@"Play tele ---------------- starttime %f, globals.HOME_START_TIME %f timeScale %d",videoPlayer.startTime, globals.HOME_START_TIME ,timeScale);
        [videoPlayer.avPlayer seekToTime:CMTimeMakeWithSeconds(globals.HOME_START_TIME, timeScale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero ];// completionHandler:^(BOOL finished) {
        //show telestration
        [self playBackTele];

        return;
    }else{
        
        [self.startRangeModifierButton setHidden:FALSE];
        [self.endRangeModifierButton setHidden:FALSE];
//        [slowMoButton setHidden:FALSE];//888
        globals.IS_PLAYBACK_TELE = FALSE;
        
        //get the tag's start time
        globals.HOME_START_TIME=[[tag objectForKey:@"starttime"] floatValue] + videoPlayer.startTime;
        //get the tag's end time
        globals.HOME_END_TIME= globals.HOME_START_TIME + [[tag objectForKey:@"duration"] floatValue] ;
        
        //if start time is negative, seek to time 0.1 sec
        if (globals.HOME_START_TIME < 0) {
            globals.HOME_START_TIME = 0.1;
        }

        //if the tag's end time is greater than the current seekable duration; make it equal to the current seekable duration
        if (globals.HOME_END_TIME>videoPlayer.durationInSeconds){
            globals.HOME_END_TIME=videoPlayer.durationInSeconds;
        }
        
//        if (globals.PLAYBACK_SPEED > 0) {
//            //videoPlayer.avPlayer.rate = globals.PLAYBACK_SPEED;
//             [self.videoPlayer setRate:globals.PLAYBACK_SPEED];
//        }else{
            [videoPlayer play];
            
//        }

       //remove the old observer before add the new one
        if (loopTagObserver) {
            [videoPlayer.avPlayer removeTimeObserver:loopTagObserver];
            loopTagObserver = nil;
        }
        
        //start playing tag from tag start time
        [videoPlayer.avPlayer seekToTime:CMTimeMakeWithSeconds(globals.HOME_START_TIME, 600) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero ];// completionHandler:^(BOOL finished) {
        /*
         * Use addBoundaryTimeObserverForTimes: to loop the tag instread of timer;
         * When avplayer plays to the tag end time, the block will be invoked and will call loopTag method
         */
        
        NSArray *times = [NSArray arrayWithObjects:[NSValue valueWithCMTime:CMTimeMakeWithSeconds(globals.HOME_END_TIME, 600)], nil];
        __weak Live2BenchViewController *l2bController = self;
        //set queue: NULL will use the default queue which is the main queue
        loopTagObserver = [videoPlayer.avPlayer addBoundaryTimeObserverForTimes:times queue:NULL usingBlock:^{
            // if the video plays to the tag end time, seek back to the start time for looping
            [l2bController loopTag];
            
        }];

         [[NSNotificationCenter defaultCenter ]postNotificationName:@"RestartUpdate" object:nil];
    }
    
   
    
}

-(void)playBackTele{
   
    if ([globals.CURRENT_PLAYBACK_EVENT rangeOfString:@".m3u8"].location != NSNotFound) {
        
        [videoPlayer pause];
        
        //set the frame size of the telestration overlay to match the thumbnail image
        
//<<<<<<< Updated upstream
        telestrationOverlay=[[UIImageView alloc]initWithFrame:CGRectMake(videoPlayer.view.frame.origin.x, videoPlayer.view.frame.origin.y,videoPlayer.view.frame.size.width, videoPlayer.playerFrame.size.height)];
//=======
//        telestrationOverlay=[[UIImageView alloc]initWithFrame:CGRectMake(videoPlayer.view.frame.origin.x, videoPlayer.view.frame.origin.y+6,videoPlayer.view.frame.size.width, videoPlayer.playerFrame.size.height)];
//>>>>>>> Stashed changes
//        
        [telestrationOverlay setClipsToBounds:TRUE];
        
        [telestrationOverlay setBackgroundColor:[UIColor clearColor]];
        
       // [telestrationOverlay setContentMode:UIViewContentModeScaleAspectFill];
        
        NSString *teleImageName = [[globals.CURRENT_PLAYBACK_TAG objectForKey:@"teleurl"] lastPathComponent];
        
        NSString *tUrl = [globals.THUMBNAILS_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",teleImageName]];
        
        telestrationOverlay.image = [[UIImage alloc] initWithContentsOfFile:tUrl];
        
        [videoPlayer.view  addSubview:telestrationOverlay];
        
        if (isViewTeleButtonSelected) {
            isViewTeleButtonSelected = FALSE;
            //set the frame size of the telestration overlay to match the thumbnail image
            [telestrationOverlay setFrame:CGRectMake(0, videoPlayer.view.bounds.origin.y+10, videoPlayer.view.bounds.size.width, videoPlayer.view.bounds.size.height)];
            [telestrationOverlay setContentMode:UIViewContentModeScaleAspectFit];
            
        }
        
        //  }
    }else{
        
//        //TODO: playing telestration off with mp4 format
//        
//        if (telestrationOverlay) {
//            
//            [videoPlayer.avPlayer seekToTime:CMTimeMakeWithSeconds(globals.HOME_START_TIME, 600) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
//                
//                [videoPlayer pause];
//                
//            }];
//            
//        }else{
        
            //set the frame size of the telestration overlay to match the thumbnail image
            
            telestrationOverlay=[[UIImageView alloc]initWithFrame:CGRectMake(videoPlayer.view.frame.origin.x, videoPlayer.view.frame.origin.y,videoPlayer.view.frame.size.width, videoPlayer.playerFrame.size.height)];
            
            [telestrationOverlay setClipsToBounds:TRUE];
            
            [telestrationOverlay setBackgroundColor:[UIColor blackColor]];
            
            [telestrationOverlay setContentMode:UIViewContentModeScaleAspectFill];
            
            NSString *teleImageName = [[globals.CURRENT_PLAYBACK_TAG objectForKey:@"teleurl"] lastPathComponent];
            
            NSString *tUrl = [globals.THUMBNAILS_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",teleImageName]];
            
            telestrationOverlay.image = [[UIImage alloc] initWithContentsOfFile:tUrl];
            
            [videoPlayer.view  addSubview:telestrationOverlay];
            
//        }
    }
}
//when playing back tag, if the tag end time is crossed, go back to the tag start time
-(void)loopTag{
    //NSLog(@"loop tag!");
    [videoPlayer.avPlayer seekToTime:CMTimeMakeWithSeconds(globals.HOME_START_TIME, 600)];// completionHandler:^(BOOL finished) {
}

//uilongpressgestureRecongnizer is a continous event recognizer.
/*
 The gesture begins (UIGestureRecognizerStateBegan) when the number of allowable fingers (numberOfTouchesRequired) have been pressed for the specified period (minimumPressDuration) and the touches do not move beyond the allowable range of movement (allowableMovement).
 The gesture recognizer transitions to the Change state whenever a finger moves, and it ends (UIGestureRecognizerStateEnded) when any of the fingers are lifted.
 */
-(void)changeDurationModifierButtonIcon:(UILongPressGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        //NSLog(@"begain");
        CustomButton *button = (CustomButton*)gestureRecognizer.view;
        if ([button isEqual:startRangeModifierButton] || [button isEqual:startRangeModifierButtoninFullScreen]) {
            if ([button.accessibilityValue isEqualToString:@"extend"]) {
                [button setImage:[UIImage imageNamed:@"subtractstartsec"] forState:UIControlStateNormal];
                [button setAccessibilityValue:@"subtract"];
            }else{
                [button setImage:[UIImage imageNamed:@"extendstartsec.png"] forState:UIControlStateNormal];
                [button setAccessibilityValue:@"extend"];
            }
            
        }else{
            if ([button.accessibilityValue isEqualToString:@"extend"]) {
                [button setImage:[UIImage imageNamed:@"subtractendsec"] forState:UIControlStateNormal];
                [button setAccessibilityValue:@"subtract"];
            }else{
                [button setImage:[UIImage imageNamed:@"extendendsec.png"] forState:UIControlStateNormal];
                [button setAccessibilityValue:@"extend"];
            }
        }
        
    }else if(gestureRecognizer.state == UIGestureRecognizerStateChanged){
        //NSLog(@"changed");
    }else if(gestureRecognizer.state == UIGestureRecognizerStateEnded){
        //NSLog(@"ended");
    }
}


//this method will be called when startRangeModifierButton is press
//The current tag duration will extend 5 secs;
//new start time  = old start time - 5
//new duration = old duration + 5
-(void)startRangeBeenModified:(CustomButton*)button{
    
    float newStartTime = 0;

    float endTime = [[currentPlayingTag objectForKey:@"starttime"]floatValue] + [[currentPlayingTag objectForKey:@"duration"]floatValue];
    
    //NSLog(@"Old start time: %f, old end time: %f, old duration: %f",[[currentPlayingTag objectForKey:@"starttime"]floatValue],endTime,[[currentPlayingTag objectForKey:@"duration"]floatValue]);
    if ([button.accessibilityValue isEqualToString:@"extend"]) {
        
        //extend the duration 5 seconds by decreasing the start time 5 seconds
        newStartTime = [[currentPlayingTag objectForKey:@"starttime"]floatValue] -5;
        //if the new start time is smaller than 0, set it to 0
        if (newStartTime <0) {
            newStartTime = 0;
        }
        
        //NSLog(@"Extend tag duration from start time!!!");
    }else{
        //subtract the duration 5 seconds by increasing the start time 5 seconds
        newStartTime = [[currentPlayingTag objectForKey:@"starttime"]floatValue] + 5;
        
        //if the start time is greater than the endtime, it will cause a problem for tag looping. So set it to endtime minus one
        if (newStartTime > endTime) {
            newStartTime = endTime -1;
        }
        //NSLog(@"Subtract tag duration from start time!!!");
    }
    
    //set the new duration to tag end time minus new start time
    int newDuration = endTime - newStartTime;
   
    //NSLog(@"NEW start time: %f, NEw end time: %f, New duration: %d",newStartTime,endTime,newDuration);
    
    globals.HOME_START_TIME = newStartTime;
    globals.HOME_END_TIME = endTime;
    NSString *startTime = [NSString stringWithFormat:@"%f",newStartTime];
    NSString *duration = [NSString stringWithFormat:@"%d",newDuration];
    NSString *tagId = [currentPlayingTag objectForKey:@"id"];
    [currentPlayingTag setValue:startTime forKey:@"starttime"];
    [currentPlayingTag setValue:duration forKey:@"duration"];
    
    [globals.CURRENT_EVENT_THUMBNAILS setObject:currentPlayingTag forKey:[NSString stringWithFormat:@"%@",[currentPlayingTag objectForKey:@"id"]]];
    
    accountInfo = [[NSMutableDictionary alloc] initWithContentsOfFile: globals.ACCOUNT_PLIST_PATH];
    userId = [accountInfo objectForKey:@"hid"];
    //current absolute time in seconds
    double currentSystemTime = CACurrentMediaTime();
    
   if (!globals.HAS_MIN|| (globals.HAS_MIN && !globals.eventExistsOnServer))
    {
    //if no encoder available or the current playing event is not in the current encoder, save the tag information locally
        
        NSMutableDictionary *dict = [globals.CURRENT_EVENT_THUMBNAILS objectForKey: [NSString stringWithFormat:@"%@", [currentPlayingTag objectForKey:@"id"]]];
        [dict setObject:@"1" forKey:@"edited"];
        [dict setObject: duration forKey:@"duration"];
        [dict setObject:startTime forKey:@"starttime"];
        currentPlayingTag = dict;
    } else {
    //if encoder available and the current playing event is in the current encoder, send the tag information to the server
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:startTime, @"starttime",duration,@"duration",globals.EVENT_NAME,@"event",userId,@"user",tagId,@"id", [NSString stringWithFormat:@"%f",currentSystemTime],@"requesttime",nil];
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
        NSString *jsonString;
        if (! jsonData) {
            
        } else {
            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        
        NSString *url = [NSString stringWithFormat:@"%@/min/ajax/tagmod/%@",globals.URL,jsonString];
        
        // NSLog(@"startRangeBeenModified; url: %@",url);
        NSArray *objects = [[NSArray alloc]initWithObjects:[NSValue valueWithPointer:nil],self, nil];
        NSArray *keys = [[NSArray alloc]initWithObjects:@"callback",@"controller", nil];
        NSDictionary *instObj = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        [globals.APP_QUEUE enqueue:url dict:instObj];
    }
    //set the video player's current time to the new start time and pause it
    [self.videoPlayer setTime: globals.HOME_START_TIME];
    [self.videoPlayer pause];
}

//this method will be called when endRangeModifierButton is press
//The current tag duration will extend 5 secs;
//new end time  = old end time + 5
//new duration = old duration + 5
-(void)endRangeBeenModified:(CustomButton*)button{
    
    int newDuration = 0;
    float startTime = [[currentPlayingTag objectForKey:@"starttime"]floatValue];
    float endTime = startTime + [[currentPlayingTag objectForKey:@"duration"]floatValue];
    
    //NSLog(@"Old start time: %f, old end time: %f, old duration: %f",startTime,endTime,[[currentPlayingTag objectForKey:@"duration"]floatValue]);
    
    if ([button.accessibilityValue isEqualToString:@"extend"]) {
        //increase end time by 5 seconds
        endTime = endTime + 5;
        //if new end time is greater the duration of video, set it to the video's duration
        if (endTime > self.videoPlayer.durationInSeconds) {
            endTime = self.videoPlayer.duration;
        }
    
        //NSLog(@"Extend tag duration from end time!!!");
    }else{
        //subtract end time by 5 seconds
        endTime = endTime - 5;
        //if the new end time is smaller than the start time,it will cause a problem for tag looping. So set it to start time plus one.
        if (endTime < startTime) {
            endTime = startTime + 1;
        }
        //NSLog(@"Subtract tag duration from end time!!!");
    }
    //get the new duration
    newDuration = endTime - startTime;
    
    //NSLog(@"NEW start time: %f, NEw end time: %f, New duration: %d",startTime,endTime,newDuration);
    
    NSString *duration = [NSString stringWithFormat:@"%d",newDuration];
    [currentPlayingTag setValue:duration forKey:@"duration"];
    globals.HOME_START_TIME= startTime;
    globals.HOME_END_TIME = endTime;
   
    NSString *tagId = [currentPlayingTag objectForKey:@"id"];

    [globals.CURRENT_EVENT_THUMBNAILS setObject:currentPlayingTag forKey:[NSString stringWithFormat:@"%@",[currentPlayingTag objectForKey:@"id"]]];
    
    NSString *path = [globals.LOCAL_DOCS_PATH stringByAppendingPathComponent:@"accountInformation.plist"];
    accountInfo = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    userId = [accountInfo objectForKey:@"hid"];
    //current absolute time in seconds
    double currentSystemTime = CACurrentMediaTime();
    
    if (!globals.HAS_MIN|| (globals.HAS_MIN && !globals.eventExistsOnServer))
    {
        //if no encoder available or the current playing event is not in the current encoder, save the tag information locally
        
        NSMutableDictionary *dict = [globals.CURRENT_EVENT_THUMBNAILS objectForKey: [NSString stringWithFormat:@"%@", [currentPlayingTag objectForKey:@"id"]]];
        [dict setObject:@"1" forKey:@"edited"];
        [dict setObject: duration forKey:@"duration"];
        currentPlayingTag = dict;
    } else {
        //if encoder available and the current playing event is in the current encoder, send the tag information to the server
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:duration,@"duration",globals.EVENT_NAME,@"event",userId,@"user",tagId,@"id", [NSString stringWithFormat:@"%f",currentSystemTime],@"requesttime",nil];
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
        NSString *jsonString;
        if (! jsonData) {
            
        } else {
            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        
        NSString *url = [NSString stringWithFormat:@"%@/min/ajax/tagmod/%@",globals.URL,jsonString];
        
        //NSLog(@"addFiveSecInLoopEnd; url: %@",url);
        NSArray *objects = [[NSArray alloc]initWithObjects:[NSValue valueWithPointer:nil],self, nil];
        NSArray *keys = [[NSArray alloc]initWithObjects:@"callback",@"controller", nil];
        NSDictionary *instObj = [NSDictionary dictionaryWithObjects:objects forKeys:keys];       
        [globals.APP_QUEUE enqueue:url dict:instObj];
        
    }
    
    //the loop end time changed, so we need to update the looptagobserver
    
    //remove the old observer before add the new one
    if (loopTagObserver) {
        [videoPlayer.avPlayer removeTimeObserver:loopTagObserver];
        loopTagObserver = nil;
    }
    
    /*
     * Use addBoundaryTimeObserverForTimes: to loop the tag instread of timer;
     * When avplayer plays to the tag end time, the block will be invoked and will call loopTag method;
     *
     * When the user tries to extend/subtract the tag duration by adding/reducing 5 seconds to the tag end time, the video will be paused at the new tag end time(globals.HOME_END_TIME).
     * And it will also start playing from the new tag end time(globals.HOME_END_TIME) if the user presses the video player's play button. 
     * In this case, if we set the boundary timer observer for time globals.HOME_END_TIME, the time observer block may never be triggered. 
     * So we set the boundary time observer for time (globals.HOME_END_TIME + 1), when the video resumes playing from globals.HOME_END_TIME, after one seconds the block
     * will be triggered and loopTag will be called. Then the tag starts looping.
     *
     */
    
    NSArray *times = [NSArray arrayWithObjects:[NSValue valueWithCMTime:CMTimeMakeWithSeconds(globals.HOME_END_TIME + 1, 600)], nil];
    __weak Live2BenchViewController *l2bController = self;
    //set queue: NULL will use the default queue which is the main queue
    loopTagObserver = [videoPlayer.avPlayer addBoundaryTimeObserverForTimes:times queue:NULL usingBlock:^{
        // if the video plays to the tag end time, seek back to the start time for looping
        [l2bController loopTag];
        
    }];

    [self.videoPlayer setTime: globals.HOME_END_TIME];
    [self.videoPlayer pause];
}

//This method will be called if the slowMoButton is press
//This control will change the current playing speed
-(void)slowMoController:(id)sender
{
    //[videoPlayer.avPlayer play];
    CustomButton *button = (CustomButton *)sender;
    //set the playback rate appropriately (if it was 1, set it to slow mo)
    globals.PLAYBACK_SPEED = (globals.PLAYBACK_SPEED==1.0f)?0.5f:1.0f;
    [self.videoPlayer play];
    //set the image of the slow mo button as well
    NSString *buttonName = (globals.PLAYBACK_SPEED ==1.0f)?@"normalsp.png":@"slowmo.png";
    [button setImage:[UIImage imageNamed:buttonName] forState:UIControlStateNormal];
}

-(void)playbackRateButtonDown:(id)sender{
    isModifyingPlaybackRate = YES;
    if ([sender tag] == 0) {
        [UIView animateWithDuration:0.3f animations:^{
            [playbackRateBackGuide setAlpha:1.0f];
            [self.overlayLeftViewController.view setAlpha:0.0f];
            [playbackRateBackLabel setAlpha:1.0f];
        }];
        [self startFrameByFrameScrollingAtInterval:0.5f goingForward:NO];
    } else if ([sender tag] == 1){
        [UIView animateWithDuration:0.3f animations:^{
            [playbackRateForwardGuide setAlpha:1.0f];
            [self.overlayRightViewController.view setAlpha:0.0f];
            [playbackRateForwardLabel setAlpha:1.0f];
        }];
        [self startFrameByFrameScrollingAtInterval:0.5f goingForward:YES];
    }
    [videoPlayer pause];
}

-(void)playbackRateButtonUp:(id)sender{
    /*
     isModifyingPlaybackRate = NO;
    isFrameByFrame = NO;
    if ([sender tag] == 0) {
        [UIView animateWithDuration:0.3f animations:^{
            [playbackRateBackGuide setAlpha:0.0f];
            [self.overlayLeftViewController.view setAlpha:1.0f];
            [playbackRateBackButton setFrame:CGRectMake(165, 585, 70.0f, 70.0f)];
            [playbackRateBackLabel setFrame:CGRectMake(CGRectGetMaxX(playbackRateBackButton.frame), playbackRateBackButton.frame.origin.y, playbackRateBackLabel.bounds.size.width, playbackRateBackLabel.bounds.size.height)];
            [playbackRateBackLabel setAlpha:0.0f];
        }];
    } else if ([sender tag] == 1){
        [UIView animateWithDuration:0.3f animations:^{
            [playbackRateForwardGuide setAlpha:0.0f];
            [self.overlayRightViewController.view setAlpha:1.0f];
            [playbackRateForwardButton setFrame:CGRectMake(playbackRateBackButton.superview.bounds.size.width - playbackRateBackButton.frame.origin.x - playbackRateBackButton.bounds.size.width, playbackRateBackButton.frame.origin.y, playbackRateBackButton.bounds.size.width, playbackRateBackButton.bounds.size.height)];
            [playbackRateForwardLabel setFrame:CGRectMake(playbackRateForwardButton.frame.origin.x - playbackRateForwardLabel.bounds.size.width, playbackRateForwardButton.frame.origin.y, playbackRateForwardLabel.bounds.size.width, playbackRateForwardLabel.bounds.size.height)];
            [playbackRateForwardLabel setAlpha:0.0f];

        }];
    }
    [videoPlayer pause];
     */
    
    if ([sender isSelected]) {
        [sender setSelected:NO];
        globals.PLAYBACK_SPEED = 0.0f;
        [videoPlayer.avPlayer setRate:globals.PLAYBACK_SPEED];
    } else {
        if ([sender tag] == 0) {
            globals.PLAYBACK_SPEED = -2.0f;
        } else {
            globals.PLAYBACK_SPEED = 2.0f;
        }
        [sender setSelected:YES];
        [videoPlayer.avPlayer setRate:globals.PLAYBACK_SPEED];
    }
}

-(void)playbackRateButtonDrag:(id)sender forEvent:(UIEvent*)event{
    UIButton* button = sender;
    UITouch *touch = [[event touchesForView:button] anyObject];
    CGPoint touchPoint = [touch locationInView:button.superview];
    CGPoint buttonPosition = [self coordForPosition:touchPoint onGuide:[button tag]];
    [button setCenter:buttonPosition];
    if ([button tag] == 0) {
        [playbackRateBackLabel setFrame:CGRectMake(CGRectGetMaxX(button.frame), button.frame.origin.y, playbackRateBackLabel.bounds.size.width, playbackRateBackLabel.bounds.size.height)];
        if (isFrameByFrame) {
            [playbackRateBackLabel setText:[NSString stringWithFormat:@"-%.0ffps",1/frameByFrameInterval]];
        } else {
            [playbackRateBackLabel setText:[NSString stringWithFormat:@"%.2fx",globals.PLAYBACK_SPEED]];
        }
    } else if ([button tag] == 1){
        [playbackRateForwardLabel setFrame:CGRectMake(button.frame.origin.x - playbackRateForwardLabel.bounds.size.width, button.frame.origin.y, playbackRateForwardLabel.bounds.size.width, playbackRateForwardLabel.bounds.size.height)];
        if (isFrameByFrame) {
            [playbackRateForwardLabel setText:[NSString stringWithFormat:@"%.0ffps",1/frameByFrameInterval]];
        } else {
            [playbackRateForwardLabel setText:[NSString stringWithFormat:@"%.2fx",globals.PLAYBACK_SPEED]];
        }
    }
    if (videoPlayer.avPlayer.rate != globals.PLAYBACK_SPEED) {
        videoPlayer.avPlayer.rate = globals.PLAYBACK_SPEED;
    }
}

-(CGPoint)coordForPosition:(CGPoint)point onGuide:(int)tag{
    float yPos = 0.0f;
    float xPos = 0.0f;
    CGPoint guidePivot;
    float theta = 0.0f;
    float degrees = 0.0f;
    playbackRateRadius = 118.0f + playbackRateBackButton.bounds.size.width/2;
    if (tag == 0){
        guidePivot = CGPointMake(playbackRateBackGuide.frame.origin.x + 30.0f, CGRectGetMaxY(playbackRateBackGuide.frame) - 25.0f);
        theta = atan2f(point.y - guidePivot.y, point.x - guidePivot.x);
        if (theta*180/M_PI < -87){
            theta = -87*M_PI/180;
        } else if (theta*180/M_PI > -3){
            theta = -3*M_PI/180;
        }
        degrees = -(theta*180.0f/M_PI);
        float degRange = 84.0f;
        float increment = degRange/6;
        
        if (degrees <= 3){
            [self startFrameByFrameScrollingAtInterval:0.5f goingForward:FALSE];
        } else if (degrees > 3 && degrees < increment*2){
            [self startFrameByFrameScrollingAtInterval:0.2f goingForward:FALSE];
        } else {
            isFrameByFrame = NO;
            if (degrees >= increment*2 && degrees < increment*3){
                globals.PLAYBACK_SPEED = 0.25f;
            } else if (degrees >= increment*3 && degrees < increment*4){
                globals.PLAYBACK_SPEED = 0.5f;
            } else if (degrees >= increment*4 && degrees < increment*5){
                globals.PLAYBACK_SPEED = 1.0f;
            } else if (degrees >= increment*5 && degrees < (increment*6 - 1)){
                globals.PLAYBACK_SPEED = 2.0f;
            } else if (degrees >= (increment*6 - 3)){
                globals.PLAYBACK_SPEED = 4.0f;
            }
        }
        globals.PLAYBACK_SPEED = -globals.PLAYBACK_SPEED;
        
        yPos = sinf(theta)*playbackRateRadius;
        xPos = cosf(theta)*playbackRateRadius;
        yPos += guidePivot.y;
        xPos += guidePivot.x;
    } else if (tag == 1){
        guidePivot = CGPointMake(CGRectGetMaxX(playbackRateForwardGuide.frame) - 30.0f, CGRectGetMaxY(playbackRateForwardGuide.frame) - 25.0f);
        theta = atan2f(point.y - guidePivot.y, guidePivot.x - point.x);
        if (theta*180/M_PI < -87){
            theta = -87*M_PI/180;
        } else if (theta*180/M_PI > -3){
            theta = -3*M_PI/180;
        }
        degrees = -(theta*180.0f/M_PI);
        float degRange = 84.0f;
        float increment = degRange/6;
        
        if (degrees <= 3){
            [self startFrameByFrameScrollingAtInterval:0.5f goingForward:TRUE];
        } else if (degrees > 3 && degrees < increment*2){
            [self startFrameByFrameScrollingAtInterval:0.2f goingForward:TRUE];
        } else {
            isFrameByFrame = NO;
            if (degrees >= increment*2 && degrees < increment*3){
                globals.PLAYBACK_SPEED = 0.25f;
            } else if (degrees >= increment*3 && degrees < increment*4){
                globals.PLAYBACK_SPEED = 0.5f;
            } else if (degrees >= increment*4 && degrees < increment*5){
                globals.PLAYBACK_SPEED = 1.0f;
            } else if (degrees >= increment*5 && degrees < (increment*6 - 1)){
                globals.PLAYBACK_SPEED = 2.0f;
            } else if (degrees >= (increment*6 - 3)){
                globals.PLAYBACK_SPEED = 4.0f;
            }
        }
        
        yPos = sinf(theta)*playbackRateRadius;
        xPos = cosf(theta)*playbackRateRadius;
        yPos += guidePivot.y;
        xPos -= guidePivot.x;
        xPos = -xPos;
    }
    return CGPointMake(xPos, yPos);
}

- (void)startFrameByFrameScrollingAtInterval:(float)interval goingForward:(BOOL)forward{
    frameByFrameInterval = interval;
    if (isFrameByFrame) {
        return;
    } else {
        isFrameByFrame = YES;
    }
    if (forward){
        [self frameByFrameForward];
    } else {
        [self frameByFrameBackward];
    }

}
- (void)frameByFrameForward{
    if (isFrameByFrame) {
        [videoPlayer.avPlayer.currentItem stepByCount:1];
        [NSTimer scheduledTimerWithTimeInterval:frameByFrameInterval target:self selector:@selector(frameByFrameForward) userInfo:nil repeats:NO];
    }
}
- (void)frameByFrameBackward{
    if (isFrameByFrame) {
        [videoPlayer.avPlayer.currentItem stepByCount:-1];
        [NSTimer scheduledTimerWithTimeInterval:frameByFrameInterval target:self selector:@selector(frameByFrameBackward) userInfo:nil repeats:NO];
    }
}

/*
//adjust tagmarkers according to x pixel difference of all the tag markers and colours
//@tagMarkerLeadObjDict: is a dictionary of dictionaries. The key value is the lead tagmarker's xValue, the object value is a dictionary
//which contains an object:lead tagmarker and array of different colours of all the tag markers which follow the lead tagmarker
- (void)adjustTagFrames:(float)xValue color:(UIColor *)color tMarker:(TagMarker *)tMarker {
    
    if (!tagMarkerLeadObjDict) {
        tagMarkerLeadObjDict = [[NSMutableDictionary alloc]init];
    }
    NSMutableDictionary *markerDict;
    for(NSString *leadXValue in [tagMarkerLeadObjDict allKeys]){
        //if the pixel difference of tMarker's xValue and the leadXValue is smaller or equal to 7, tMarker will follow the current lead tagmarker
        if (fabs([leadXValue floatValue] - xValue) <= 7) {
            tMarker.leadTag = [[tagMarkerLeadObjDict objectForKey:leadXValue] objectForKey:@"lead"];
            if (![[[tagMarkerLeadObjDict objectForKey:leadXValue] objectForKey:@"colorArr"] containsObject:color]) {
                [[[tagMarkerLeadObjDict objectForKey:leadXValue] objectForKey:@"colorArr"] addObject:color];
            }
            //get the lead marker for current tag
            markerDict = [tagMarkerLeadObjDict objectForKey:leadXValue];
            break;
        }
    }
    
    //if tMarker is not close to any of the existing lead tagmarkers, set itself as its lead tagmarker and added it the "tagMarkerLeadObjDict" dictionary
    if (!tMarker.leadTag) {
        tMarker.leadTag = tMarker;
        markerDict = [[NSMutableDictionary alloc]init];
        [markerDict setObject:[[NSMutableArray alloc]initWithObjects:color, nil] forKey:@"colorArr"];
        //TagMarker *lead = tMarker;
        [markerDict setObject:tMarker forKey:@"lead"];
        [markerDict setObject:[NSString stringWithFormat:@"%f",tMarker.tagTime] forKey:@"leadTime"];
        [tagMarkerLeadObjDict setObject:markerDict forKey:[NSString stringWithFormat:@"%f",tMarker.xValue]];
    }
    
    //If the createTagMarkers method is called, just return. Will create all the tag marker views after pass all the tags to tagMarkerLeadObjDict.
    if (isCreatingAllTagMarkers) {
        return;
    }
    
    //create the tag marker view for each lead tagmarker in the dictionary: tagMarkerLeadObjDict
    //for(NSMutableDictionary *leadDict in [tagMarkerLeadObjDict allValues]){
    
    
    //NSLog(@"Create tag marker for a new tag!");
    //create the tagmarker view for the current new generated tag
    TagMarker *mark = [markerDict objectForKey:@"lead"];

    [mark.markerView setFrame:CGRectMake(mark.xValue, 0.0f, 5.0f, 40.0f)];
    [mark.markerView setAccessibilityLabel:@"marker"];
    //mark.marker.frame = CGRectMake(mark.xValue, 0.0f, 5.0f, 40.0f);
    [self.tagSetView insertSubview:mark.markerView belowSubview:self.tagEventName];
    int numMarks = [[markerDict objectForKey:@"colorArr"]count];
    NSArray *tempColorArr = [markerDict objectForKey:@"colorArr"];
    //create subviews according to the color array saved in the lead dictionary
     if (numMarks != 1){
        
        //add new subviews for the marker view according to the colour
        for (int i = 0; i < numMarks; i++)
        {
            UIView *colorView = [[UIView alloc]initWithFrame:CGRectMake(0, i*(40.0f/numMarks), 5.0f, 40.0f/numMarks)];
            [colorView setBackgroundColor:[tempColorArr objectAtIndex:i]];
            [mark.markerView addSubview:colorView];
        }
    }else{
        [mark.markerView setBackgroundColor:mark.color];
    }
    
    
}
*///888


/*
//generate TagMarker object when we receive a new tag from syncme callback
-(TagMarker*)markTagAtTime:(float)time colour:(UIColor*)color tagID:(NSString*)tagID{
    double liveTime = MAX(globals.PLAYABLE_DURATION, self.videoPlayer.duration);
    
    //NSLog(@"videoPlayer: %@,self.videoPlayer.duration: %f, globals.PLAYABLE_DURATION: %f, time: %f",videoPlayer,self.videoPlayer.duration,globals.PLAYABLE_DURATION,time);
    if(liveTime < 1 || time > liveTime){
        return nil;
    }
    float xValue = [self xValueForTime:time atLiveTime:liveTime];
    //make sure the marker is in the right range
    if(xValue > 596.f)
    {
        xValue= 596.f;
    }
    
    TagMarker *tMarker = [[TagMarker alloc] initWithXValue:xValue tagColour:color tagTime:time tagId:tagID];//initWithXValue:xValue name:name time:time tagId:tagID];

    tMarker.markerView = [[UIView alloc] init];
    //tMarker.marker.backgroundColor = color;
    //[tMarker.marker setAccessibilityIdentifier:@"tagMarker"];

    [globals.TAG_MARKER_OBJ_DICT setObject:tMarker forKey:tagID];
    [self adjustTagFrames:xValue color:color tMarker:tMarker];
   
    return tMarker;
}
*///888

/*
- (double)xValueForTime:(double)time atLiveTime:(double)liveTime{
    return (time/liveTime)*470 + 126.0f;
}
*///888




//This method will be called when the user pinch the player view to fullscreen
-(void)willEnterFullscreen
{
//    CGRect tempFrame = self.leftSideButtons.frame;
//
//    //if x value of leftsidebuttons view is 0, that means it was in normal view; otherwise it is already in fullscreen view, then do not shift the left-side-buttons view and right-side-buttons view again
//    if (self.leftSideButtons.frame.origin.x == 0) {
//        
//        //shift left side buttons view outside of the screen to hide it
//        //animateleft
//        [UIView animateWithDuration:0.3
//                         animations:^{[self.leftSideButtons setFrame:CGRectMake(tempFrame.origin.x-tempFrame.size.width, tempFrame.origin.y, tempFrame.size.width, tempFrame.size.height)];}
//                         completion:^(BOOL finished){}];
//        
//        //shift right side buttons view outside of the screen to hide it
//        tempFrame = self.rightSideButtons.frame;
//        //animatelright
//        [UIView animateWithDuration:0.3
//                         animations:^{[self.rightSideButtons setFrame:CGRectMake(tempFrame.origin.x+tempFrame.size.width, tempFrame.origin.y, tempFrame.size.width, tempFrame.size.height)];}
//                         completion:^(BOOL finished){}];
//
//    }
//       
///going to bring the tabbar controller to the front now, we want to have access to it at all times, including fullscreen mode
    UIView *fullScreenView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    
    //iterate through all the views in teh fullscreen (the tabs are there, just hidden away
    for(id tBar in fullScreenView.subviews)
    {
        //if the view is a subclass of type tabbarbutton, then we will bring it to the front
        if([tBar isKindOfClass:[TabBarButton class]])
        {
            [fullScreenView bringSubviewToFront:tBar];
        }
    }

    
    /*
    if(globals.PLAYBACK_SPEED == 1.0f)
    {
        [slowMoButtoninFullScreen setImage:[UIImage imageNamed:@"normalsp.png"] forState:UIControlStateNormal];
    }else{
        [slowMoButtoninFullScreen setImage:[UIImage imageNamed:@"slowmo.png"] forState:UIControlStateNormal];
    }
    */
    if(globals.IS_IN_LIST_VIEW  == FALSE && globals.IS_IN_BOOKMARK_VIEW ==FALSE){
        if(globals.IS_LOOP_MODE == FALSE){
            [self createFullScreenOverlayButtons];
        }else{
            [self createFullScreenOverlayButtonsinLoopMode];
            if ([[currentPlayingTag objectForKey:@"name"] isEqualToString:@"telestration"]) {
                //IS_VIEW_TELE = TRUE;
                [startRangeModifierButtoninFullScreen setHidden:TRUE];
                [endRangeModifierButtoninFullScreen setHidden:TRUE];
//                [slowMoButtoninFullScreen setHidden:TRUE];
//                [currentSeekBackButtoninFullScreen setHidden:TRUE];
//                [currentSeekForwardButtoninFullScreen setHidden:TRUE];
//                [seekBackControlView setHidden:TRUE];
//                [seekForwardControlView setHidden:TRUE];
                globals.IS_PLAYBACK_TELE = TRUE;
            }else{
                [startRangeModifierButtoninFullScreen setHidden:FALSE];
                [endRangeModifierButtoninFullScreen setHidden:FALSE];
//                [slowMoButtoninFullScreen setHidden:FALSE];
//                [currentSeekBackButtoninFullScreen setHidden:FALSE];
//                [currentSeekForwardButtoninFullScreen setHidden:FALSE];
//                [seekBackControlView setHidden:FALSE];
//                [seekForwardControlView setHidden:FALSE];
                globals.IS_PLAYBACK_TELE = FALSE;
            }
        }
    }
 
}

//This method will be called when the user pinch the player view to exit fullscreen
-(void)willExitFullscreen
{
   //remove all subview in fullscreen which were created for non-loop mode
    for(UIView *view in self.overlayItems)
    {
            [UIView animateWithDuration:0.2
                         animations:^{view.alpha = 0.0;}
                         completion:^(BOOL finished){ [view removeFromSuperview]; }];
        [view removeFromSuperview];
    }
//    //shift left side buttons back to original position in normal screen
//    CGRect tempFrame = self.leftSideButtons.frame;
//    //animateleft
//    [UIView animateWithDuration:0.3
//                     animations:^{[self.leftSideButtons setFrame:CGRectMake(tempFrame.origin.x+tempFrame.size.width, tempFrame.origin.y, tempFrame.size.width, tempFrame.size.height)];}
//                     completion:^(BOOL finished){}];
//    //shift right side buttons back to original position in normal screen
//    tempFrame = self.rightSideButtons.frame;
//    //animateright
//    [UIView animateWithDuration:0.3
//                     animations:^{[self.rightSideButtons setFrame:CGRectMake(tempFrame.origin.x-tempFrame.size.width, tempFrame.origin.y, tempFrame.size.width, tempFrame.size.height)];}
//                     completion:^(BOOL finished){}];

    
    //if was in loop mode, remove all the control buttons in fullscreen
    if(globals.IS_LOOP_MODE){
        [self removeFullScreenOverlayButtonsinLoopMode];
        
        //Set the startRangeModifierButton's icon according to the startRangeModifierButtoninFullScreen's accessibilityValue
        //Make sure when switching between fullscreen and normal screen,the buttons' icons and controls are synced
        NSString *accesibilityString = startRangeModifierButtoninFullScreen.accessibilityValue;
        NSString *imageName;
        if ([accesibilityString isEqualToString:@"extend"]) {
            imageName = @"extendstartsec";
        }else{
            imageName = @"subtractstartsec";
        }
        [startRangeModifierButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [startRangeModifierButton setAccessibilityValue:accesibilityString];
        
        //set the endRangeModifierButton's icon according to the endRangeModifierButtoninFullScreen's accessibilityValue
        //Make sure when switching between fullscreen and normal screen,the buttons' icons and controls are synced
        accesibilityString = endRangeModifierButtoninFullScreen.accessibilityValue;
        if ([accesibilityString isEqualToString:@"extend"]) {
            imageName = @"extendendsec";
        }else{
            imageName = @"subtractendsec";
        }
        [endRangeModifierButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [endRangeModifierButton setAccessibilityValue:accesibilityString];


    }
    /*
    if(globals.PLAYBACK_SPEED == 1.0f)
    {
        [slowMoButton setImage:[UIImage imageNamed:@"normalsp.png"] forState:UIControlStateNormal];
    }else{
        [slowMoButton setImage:[UIImage imageNamed:@"slowmo.png"] forState:UIControlStateNormal];
    }
    *///888
}

-(void)createFullScreenOverlayButtonsinLoopMode
{
    
    //5s duration extension button
    startRangeModifierButtoninFullScreen = [CustomButton buttonWithType:UIButtonTypeCustom];
    [startRangeModifierButtoninFullScreen setContentMode:UIViewContentModeScaleAspectFill];
    [startRangeModifierButtoninFullScreen setTag:0];
    NSString *accesibilityString = startRangeModifierButton.accessibilityValue;
    NSString *imageName;
    if ([accesibilityString isEqualToString:@"extend"]) {
        imageName = @"extendstartsec";
    }else{
        imageName = @"subtractstartsec";
    }
    [startRangeModifierButtoninFullScreen setImage:[UIImage imageNamed: imageName] forState:UIControlStateNormal];
    [startRangeModifierButtoninFullScreen addTarget:self action:@selector(startRangeBeenModified:) forControlEvents:UIControlEventTouchUpInside];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    startRangeModifierButtoninFullScreen.frame = CGRectMake(2*CONTROL_SPACER_X-20,screenRect.size.width - 2*CONTROL_SPACER_Y+25 ,65 ,65);
    [startRangeModifierButtoninFullScreen setAccessibilityValue:accesibilityString];
    
    //added long press gesture to switch icons between extension icon and substraction icon
    UILongPressGestureRecognizer *modifiedTagDurationByStartTimeLongpressgesture = [[UILongPressGestureRecognizer alloc]
                                                                                  initWithTarget:self action:@selector(changeDurationModifierButtonIcon:)];
    modifiedTagDurationByStartTimeLongpressgesture.minimumPressDuration = 0.5; //seconds
    modifiedTagDurationByStartTimeLongpressgesture.delegate = self;
    [startRangeModifierButtoninFullScreen addGestureRecognizer:modifiedTagDurationByStartTimeLongpressgesture];
    
    //5s duration extension button
    endRangeModifierButtoninFullScreen= [CustomButton buttonWithType:UIButtonTypeCustom];
    [endRangeModifierButtoninFullScreen setContentMode:UIViewContentModeScaleAspectFill];
    [endRangeModifierButtoninFullScreen setTag:1];
    
    accesibilityString = endRangeModifierButton.accessibilityValue;
    if ([accesibilityString isEqualToString:@"extend"]) {
        imageName = @"extendendsec";
    }else{
        imageName = @"subtractendsec";
    }

    [endRangeModifierButtoninFullScreen setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [endRangeModifierButtoninFullScreen addTarget:self action:@selector(endRangeBeenModified:) forControlEvents:UIControlEventTouchUpInside];
    endRangeModifierButtoninFullScreen.frame = CGRectMake(screenRect.size.height-(2*CONTROL_SPACER_X)-45,screenRect.size.width -2*CONTROL_SPACER_Y+25,65 ,65);
    [endRangeModifierButtoninFullScreen setAccessibilityValue:accesibilityString];
    
    //added long press gesture to switch icons between extension icon and substraction icon
    UILongPressGestureRecognizer *modifiedTagDurationByEndTimeLongpressgesture = [[UILongPressGestureRecognizer alloc]
                                                                                initWithTarget:self action:@selector(changeDurationModifierButtonIcon:)];
    modifiedTagDurationByEndTimeLongpressgesture.minimumPressDuration = 0.5; //seconds
    modifiedTagDurationByEndTimeLongpressgesture.delegate = self;
    [endRangeModifierButtoninFullScreen addGestureRecognizer:modifiedTagDurationByEndTimeLongpressgesture];
    
    //uilabel display current playing tag's name
    /*TO DELETE
    tagEventNameinFullScreen =[[UILabel alloc]init];
    [tagEventNameinFullScreen setBackgroundColor:[UIColor clearColor]];
    tagEventNameinFullScreen.layer.borderWidth = 1;
    tagEventNameinFullScreen.layer.borderColor = [UIColor orangeColor].CGColor;
    [tagEventNameinFullScreen setTextColor:[UIColor orangeColor]];
    [tagEventNameinFullScreen setText:self.currentEventName];
    [tagEventNameinFullScreen setFont:[UIFont boldFontOfSize:20.f]];
    [tagEventNameinFullScreen setTextAlignment:NSTextAlignmentCenter];
    tagEventNameinFullScreen.alpha = 1.0f;
    tagEventNameinFullScreen.frame = CGRectMake(screenRect.size.height/2.0-80,screenRect.size.width- CONTROL_SPACER_Y-20,165 ,50);
    */
    
    /*TO DELETE
    //add go to live button
    liveButtoninFullScreen = [BorderButton buttonWithType:UIButtonTypeCustom];
    [liveButtoninFullScreen setFrame:CGRectMake(screenRect.size.height/2.0+150,screenRect.size.width- CONTROL_SPACER_Y-10, LITTLE_ICON_DIMENSIONS + 90, LITTLE_ICON_DIMENSIONS-10)];
    [liveButtoninFullScreen setContentMode:UIViewContentModeScaleAspectFill];
    [liveButtoninFullScreen setBackgroundImage:[UIImage imageNamed:@"gotolive"] forState:UIControlStateNormal];
    [liveButtoninFullScreen setBackgroundImage:[UIImage imageNamed:@"gotoliveSelect"] forState:UIControlStateHighlighted];
    [liveButtoninFullScreen setTitle:@"Live" forState:UIControlStateNormal];
    //[liveButtoninFullScreen changeBackgroundColor:[UIColor whiteColor] :0.8];
    [liveButtoninFullScreen addTarget:self action:@selector(goToLive) forControlEvents:UIControlEventTouchUpInside];

    
    
    //add continue play button
    continuePlayButtoninFullScreen = [[BorderButton alloc]init];
    continuePlayButtoninFullScreen = [BorderButton buttonWithType:UIButtonTypeCustom];
    [continuePlayButtoninFullScreen setFrame:CGRectMake(screenRect.size.height/2.0-250,screenRect.size.width- CONTROL_SPACER_Y-10, LITTLE_ICON_DIMENSIONS + 90, LITTLE_ICON_DIMENSIONS-10)];
    [continuePlayButtoninFullScreen setContentMode:UIViewContentModeScaleAspectFill];
    [continuePlayButtoninFullScreen setBackgroundImage:[UIImage imageNamed:@"continue_unselected.png"] forState:UIControlStateNormal];
    [continuePlayButtoninFullScreen setBackgroundImage:[UIImage imageNamed:@"continue.png"] forState:UIControlStateSelected];
    [continuePlayButtoninFullScreen setTitle:@"Continue" forState:UIControlStateNormal];
    [continuePlayButtoninFullScreen setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [continuePlayButtoninFullScreen setContentEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
    [continuePlayButtoninFullScreen setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [continuePlayButtoninFullScreen setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [continuePlayButtoninFullScreen addTarget:self action:@selector(continuePlay) forControlEvents:UIControlEventTouchUpInside];
    
    
     */
    //for testing. Telestartion
    timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(CONTROL_SPACER_X-35,TOTAL_WIDTH/4.0 - 150, LITTLE_ICON_DIMENSIONS + 90, LITTLE_ICON_DIMENSIONS-10)];
    [timeLabel setText:[NSString stringWithFormat:@"%f",[videoPlayer currentTimeInSeconds]]];
    [timeLabel setBackgroundColor:[UIColor orangeColor]];
    [timeLabel setFont:[UIFont boldSystemFontOfSize:20.f]];
    [timeLabel setTextAlignment:NSTextAlignmentCenter];

  /*TO DELETE
    //seek back five seconds button
    currentSeekBackButtoninFullScreen = [CustomButton buttonWithType:UIButtonTypeCustom];
    [currentSeekBackButtoninFullScreen setFrame:CGRectMake(2*CONTROL_SPACER_X+60,screenRect.size.width - 2*CONTROL_SPACER_Y+25 ,65 ,65)];
    [currentSeekBackButtoninFullScreen setContentMode:UIViewContentModeScaleAspectFill];
    [currentSeekBackButtoninFullScreen setAccessibilityLabel:@"fullscreen"];
    UIImage *backButtonImage;
    if (globals.CURRENT_SEEK_BACK_ACTION == @selector(seekBackQuarterSecond:)) {
        backButtonImage = [UIImage imageNamed:@"seekbackquarterseclarge.png"];
    }else if (globals.CURRENT_SEEK_BACK_ACTION == @selector(seekBackOneSecond:)){
        backButtonImage = [UIImage imageNamed:@"seekbackoneseclarge.png"];
    }else{
        backButtonImage = [UIImage imageNamed:@"seekbackfivesecslarge.png"];
        globals.CURRENT_SEEK_BACK_ACTION = @selector(seekBackFiveSeconds:);
    }

    [currentSeekBackButtoninFullScreen setImage:backButtonImage forState:UIControlStateNormal];
    [currentSeekBackButtoninFullScreen addTarget:self action:globals.CURRENT_SEEK_BACK_ACTION forControlEvents:UIControlEventTouchUpInside];
    //[currentSeekBackButtoninFullScreen addTarget:self action:@selector(swipeOutSeekControlView:) forControlEvents:UIControlEventTouchDragInside];
    [currentSeekBackButton removeTarget:self action:globals.CURRENT_SEEK_BACK_ACTION forControlEvents:UIControlEventTouchUpInside];
    UILongPressGestureRecognizer *seekBackLongpressgesture = [[UILongPressGestureRecognizer alloc]
                                                              initWithTarget:self action:@selector(handleLongPress:)];
    seekBackLongpressgesture.minimumPressDuration = 0.5; //seconds
    seekBackLongpressgesture.delegate = self;
    [currentSeekBackButtoninFullScreen addGestureRecognizer:seekBackLongpressgesture];
    
    //uiview contains three seek back modes: go back 5s, 1s, 0.25s
    seekBackControlViewinFullScreen = [[UIView alloc]initWithFrame:CGRectMake(currentSeekBackButtoninFullScreen.frame.origin.x , 460,currentSeekBackButtoninFullScreen.frame.size.width +6,3.5*currentSeekBackButtoninFullScreen.frame.size.height)];
    [seekBackControlViewinFullScreen setBackgroundColor:[UIColor colorWithRed:(195/255.0) green:(207/255.0) blue:(216/255.0) alpha:0.1]];
    seekBackControlViewinFullScreen.hidden = TRUE;
    
    //go back 0.25s
    CustomButton *backQuarterSecButtoninFullScreen = [CustomButton buttonWithType:UIButtonTypeCustom];
    [backQuarterSecButtoninFullScreen setFrame:CGRectMake(0, 10, currentSeekBackButtoninFullScreen.frame.size.width, currentSeekBackButtoninFullScreen.frame.size.height)];
    [backQuarterSecButtoninFullScreen setContentMode:UIViewContentModeScaleAspectFill];
    [backQuarterSecButtoninFullScreen setAccessibilityLabel:@"fullscreen"];
    [backQuarterSecButtoninFullScreen setImage:[UIImage imageNamed:@"seekbackquarterseclarge.png"] forState:UIControlStateNormal];
    [backQuarterSecButtoninFullScreen addTarget:self action:@selector(seekBackQuarterSecond:) forControlEvents:UIControlEventTouchUpInside];
    [backQuarterSecButtoninFullScreen addTarget:self action:@selector(hideSeekControlView:) forControlEvents:UIControlEventTouchDragInside];
    [seekBackControlViewinFullScreen addSubview:backQuarterSecButtoninFullScreen];
   
    //go back 1 s
    CustomButton *backOneSecButtoninFullScreen = [CustomButton buttonWithType:UIButtonTypeCustom];
    [backOneSecButtoninFullScreen setFrame:CGRectMake(0, backQuarterSecButtoninFullScreen.frame.origin.y + backQuarterSecButtoninFullScreen.frame.size.height + 10, currentSeekBackButtoninFullScreen.frame.size.width, currentSeekBackButtoninFullScreen.frame.size.height)];
    [backOneSecButtoninFullScreen setContentMode:UIViewContentModeScaleAspectFill];
    [backOneSecButtoninFullScreen setAccessibilityLabel:@"fullscreen"];
    [backOneSecButtoninFullScreen setImage:[UIImage imageNamed:@"seekbackoneseclarge.png"] forState:UIControlStateNormal];
    [backOneSecButtoninFullScreen addTarget:self action:@selector(seekBackOneSecond:) forControlEvents:UIControlEventTouchUpInside];
     [backOneSecButtoninFullScreen addTarget:self action:@selector(hideSeekControlView:) forControlEvents:UIControlEventTouchDragInside];
    [seekBackControlViewinFullScreen addSubview:backOneSecButtoninFullScreen];
    
    //go back 5 s
    CustomButton *backFiveSecsButtoninFullScreen = [CustomButton buttonWithType:UIButtonTypeCustom];
    [backFiveSecsButtoninFullScreen setFrame:CGRectMake(0, backOneSecButtoninFullScreen.frame.origin.y + backOneSecButtoninFullScreen.frame.size.height + 10, currentSeekBackButtoninFullScreen.frame.size.width, currentSeekBackButtoninFullScreen.frame.size.height)];
    [backFiveSecsButtoninFullScreen setContentMode:UIViewContentModeScaleAspectFill];
    [backFiveSecsButtoninFullScreen setAccessibilityLabel:@"fullscreen"];
    [backFiveSecsButtoninFullScreen setImage:[UIImage imageNamed:@"seekbackfivesecslarge.png"] forState:UIControlStateNormal];
    [backFiveSecsButtoninFullScreen addTarget:self action:@selector(seekBackFiveSeconds:) forControlEvents:UIControlEventTouchUpInside];
    [backFiveSecsButtoninFullScreen addTarget:self action:@selector(hideSeekControlView:) forControlEvents:UIControlEventTouchDragInside];
    [seekBackControlViewinFullScreen addSubview:backFiveSecsButtoninFullScreen];

 
    //seek forward 5 seconds button
    currentSeekForwardButtoninFullScreen = [CustomButton buttonWithType:UIButtonTypeCustom];
    [currentSeekForwardButtoninFullScreen setFrame:CGRectMake(screenRect.size.height-(2*CONTROL_SPACER_X)-125,screenRect.size.width -2*CONTROL_SPACER_Y+25,65 ,65)];
    [currentSeekForwardButtoninFullScreen setContentMode:UIViewContentModeScaleAspectFill];
    [currentSeekForwardButtoninFullScreen setAccessibilityLabel:@"fullscreen"];
    UIImage *forwardButtonImage;
    if (globals.CURRENT_SEEK_FORWARD_ACTION == @selector(seekForwardQuarterSecond:)) {
        forwardButtonImage = [UIImage imageNamed:@"seekforwardquarterseclarge.png"];
    }else if (globals.CURRENT_SEEK_FORWARD_ACTION == @selector(seekForwardOneSecond:)){
        forwardButtonImage = [UIImage imageNamed:@"seekforwardoneseclarge.png"];
    }else{
        forwardButtonImage = [UIImage imageNamed:@"seekforwardfivesecslarge.png"];
        globals.CURRENT_SEEK_FORWARD_ACTION = @selector(seekForwardFiveSeconds:);
    }

    
    
    [currentSeekForwardButtoninFullScreen setImage:forwardButtonImage forState:UIControlStateNormal];
    [currentSeekForwardButtoninFullScreen addTarget:self action:globals.CURRENT_SEEK_FORWARD_ACTION forControlEvents:UIControlEventTouchUpInside];
    //[currentSeekForwardButtoninFullScreen addTarget:self action:@selector(swipeOutSeekControlView:) forControlEvents:UIControlEventTouchDragInside];
    [currentSeekForwardButton removeTarget:self action:globals.CURRENT_SEEK_FORWARD_ACTION forControlEvents:UIControlEventTouchUpInside];
    UILongPressGestureRecognizer *seekForwardLongpressgesture = [[UILongPressGestureRecognizer alloc]
                                                              initWithTarget:self action:@selector(handleLongPress:)];
    seekForwardLongpressgesture.minimumPressDuration = 0.5; //seconds
    seekForwardLongpressgesture.delegate = self;
    [currentSeekForwardButtoninFullScreen addGestureRecognizer:seekForwardLongpressgesture];
    
    //uiview contains three seek back modes: go forward 5s, 1s, 0.25s
    seekForwardControlViewinFullScreen = [[UIView alloc]initWithFrame:CGRectMake(currentSeekForwardButtoninFullScreen.frame.origin.x , 460,currentSeekBackButtoninFullScreen.frame.size.width +6,3.5*currentSeekBackButtoninFullScreen.frame.size.height)];
    [seekForwardControlViewinFullScreen setBackgroundColor:[UIColor colorWithRed:(195/255.0) green:(207/255.0) blue:(216/255.0) alpha:0.1]];
    seekForwardControlViewinFullScreen.hidden = TRUE;
   
    //go back 0.25s
    CustomButton *forwardQuarterSecButtoninFullScreen = [CustomButton buttonWithType:UIButtonTypeCustom];
    [forwardQuarterSecButtoninFullScreen setFrame:CGRectMake(0, 10, currentSeekBackButtoninFullScreen.frame.size.width, currentSeekBackButtoninFullScreen.frame.size.height)];
    [forwardQuarterSecButtoninFullScreen setContentMode:UIViewContentModeScaleAspectFill];
    [forwardQuarterSecButtoninFullScreen setAccessibilityLabel:@"fullscreen"];
    [forwardQuarterSecButtoninFullScreen setImage:[UIImage imageNamed:@"seekforwardquarterseclarge.png"] forState:UIControlStateNormal];
    [forwardQuarterSecButtoninFullScreen addTarget:self action:@selector(seekForwardQuarterSecond:) forControlEvents:UIControlEventTouchUpInside];
     [forwardQuarterSecButtoninFullScreen addTarget:self action:@selector(hideSeekControlView:) forControlEvents:UIControlEventTouchDragInside];
    [seekForwardControlViewinFullScreen addSubview:forwardQuarterSecButtoninFullScreen];
    
    //go back 1 s
    CustomButton *forwardOneSecButtoninFullScreen = [CustomButton buttonWithType:UIButtonTypeCustom];
    [forwardOneSecButtoninFullScreen setFrame:CGRectMake(0, forwardQuarterSecButtoninFullScreen.frame.origin.y + forwardQuarterSecButtoninFullScreen.frame.size.height + 10, currentSeekBackButtoninFullScreen.frame.size.width, currentSeekBackButtoninFullScreen.frame.size.height)];
    [forwardOneSecButtoninFullScreen setContentMode:UIViewContentModeScaleAspectFill];
    [forwardOneSecButtoninFullScreen setAccessibilityLabel:@"fullscreen"];
    [forwardOneSecButtoninFullScreen setImage:[UIImage imageNamed:@"seekforwardoneseclarge.png"] forState:UIControlStateNormal];
    [forwardOneSecButtoninFullScreen addTarget:self action:@selector(seekForwardOneSecond:) forControlEvents:UIControlEventTouchUpInside];
    [forwardOneSecButtoninFullScreen addTarget:self action:@selector(hideSeekControlView:) forControlEvents:UIControlEventTouchDragInside];
    [seekForwardControlViewinFullScreen addSubview:forwardOneSecButtoninFullScreen];
    
    //go back 5 s
    CustomButton *forwardFiveSecsButtoninFullScreen = [CustomButton buttonWithType:UIButtonTypeCustom];
    [forwardFiveSecsButtoninFullScreen setFrame:CGRectMake(0, forwardOneSecButtoninFullScreen.frame.origin.y + forwardOneSecButtoninFullScreen.frame.size.height + 10, currentSeekBackButtoninFullScreen.frame.size.width, currentSeekBackButtoninFullScreen.frame.size.height)];
    [forwardFiveSecsButtoninFullScreen setContentMode:UIViewContentModeScaleAspectFill];
    [forwardFiveSecsButtoninFullScreen setAccessibilityLabel:@"fullscreen"];
    [forwardFiveSecsButtoninFullScreen setImage:[UIImage imageNamed:@"seekforwardfivesecslarge.png"] forState:UIControlStateNormal];
    [forwardFiveSecsButtoninFullScreen addTarget:self action:@selector(seekForwardFiveSeconds:) forControlEvents:UIControlEventTouchUpInside];
     [forwardFiveSecsButtoninFullScreen addTarget:self action:@selector(hideSeekControlView:) forControlEvents:UIControlEventTouchDragInside];
    [seekForwardControlViewinFullScreen addSubview:forwardFiveSecsButtoninFullScreen];

    
    //slow mode button in fullscreen
    slowMoButtoninFullScreen =  [CustomButton buttonWithType:UIButtonTypeCustom];
    [slowMoButtoninFullScreen setFrame:CGRectMake(7*CONTROL_SPACER_X+50,screenRect.size.width- 2*CONTROL_SPACER_Y +30 ,65 ,50)];
    [slowMoButtoninFullScreen setContentMode:UIViewContentModeScaleAspectFill];
    if(globals.PLAYBACK_SPEED == 1.0f)
    {
        [slowMoButtoninFullScreen setImage:[UIImage imageNamed:@"normalsp.png"] forState:UIControlStateNormal];

    }else {
        [slowMoButtoninFullScreen setImage:[UIImage imageNamed:@"slowmo.png"] forState:UIControlStateNormal];

    }
    [slowMoButtoninFullScreen addTarget:self action:@selector(slowMoController:) forControlEvents:UIControlEventTouchUpInside];
 */
    //init button to view telestration
    viewTeleButtoninFullScreen = [BorderButton buttonWithType:UIButtonTypeCustom];
    [viewTeleButtoninFullScreen setFrame:CGRectMake(900,60, 130, LITTLE_ICON_DIMENSIONS)];
    //[liveButton setBackgroundImage:[UIImage imageNamed:@"gotolive"] forState:UIControlStateNormal];
    //[liveButton setBackgroundImage:[UIImage imageNamed:@"gotoliveSelect"] forState:UIControlStateHighlighted];
    [viewTeleButtoninFullScreen setTitle:@"View Tele" forState:UIControlStateNormal];
    [viewTeleButtoninFullScreen addTarget:self action:@selector(viewTele:) forControlEvents:UIControlEventTouchUpInside];
    if (!globals.LATEST_TELE || [[globals.CURRENT_PLAYBACK_TAG objectForKey:@"type"]intValue] == 4) {
        viewTeleButtoninFullScreen.hidden = TRUE;
    }
    
    [self.overlayItems addObject:startRangeModifierButtoninFullScreen];
    [self.overlayItems addObject:endRangeModifierButtoninFullScreen];
   
  /*TO DELETE
    [self.overlayItems addObject:tagEventNameinFullScreen];
    [self.overlayItems addObject:slowMoButtoninFullScreen];
    [self.overlayItems addObject:liveButtoninFullScreen];

    [self.overlayItems addObject:continuePlayButtoninFullScreen];
*/
    [self.overlayItems addObject:viewTeleButtoninFullScreen];
    
    UIView *fullScreenView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    [fullScreenView  addSubview:startRangeModifierButtoninFullScreen];
    [fullScreenView  addSubview:endRangeModifierButtoninFullScreen];
 /*TO DELETE
    [fullScreenView  addSubview:tagEventNameinFullScreen];
    [fullScreenView  addSubview:slowMoButtoninFullScreen];
    [fullScreenView  addSubview:currentSeekBackButtoninFullScreen];
    [fullScreenView  addSubview:currentSeekForwardButtoninFullScreen];
    [fullScreenView addSubview:continuePlayButtoninFullScreen];
    [fullScreenView addSubview:liveButtoninFullScreen];
    [fullScreenView addSubview:seekBackControlViewinFullScreen];
    [fullScreenView addSubview:seekForwardControlViewinFullScreen];
     //viewtelebutton only for medical use
    //[fullScreenView addSubview:viewTeleButtoninFullScreen];

    if(![globals.CURRENT_ENC_STATUS isEqualToString: encStateLive])
    {
        [liveButtoninFullScreen setAlpha:0.6];
        [liveButtoninFullScreen setUserInteractionEnabled:FALSE];
        
    }else{
        [liveButtoninFullScreen setAlpha:1.0];
        [liveButtoninFullScreen setUserInteractionEnabled:TRUE];
    }
*/
    //show telestration button if current playing tag is not telestration tag
    if ([[currentPlayingTag objectForKey:@"type"] intValue] != 4){
        [self showTeleButton];
        
        //when it is local playback
        if ([globals.CURRENT_PLAYBACK_EVENT rangeOfString:@"mp4"].location != NSNotFound) {
            [self showPlaybackRateControls];
        }
       
    }
}

//when exit fullscreen, remove all buttons in fullscreen
-(void)removeFullScreenOverlayButtonsinLoopMode{
    [startRangeModifierButtoninFullScreen removeFromSuperview];
    [endRangeModifierButtoninFullScreen removeFromSuperview];


    [viewTeleButtoninFullScreen removeFromSuperview];
    
    /*TO DELETE
         [continuePlayButtoninFullScreen removeFromSuperview];
    [tagEventNameinFullScreen removeFromSuperview];
    [slowMoButtoninFullScreen removeFromSuperview];
    [liveButtoninFullScreen removeFromSuperview];
    [currentSeekBackButtoninFullScreen removeFromSuperview];
    [currentSeekForwardButtoninFullScreen removeFromSuperview];
    [seekBackControlViewinFullScreen removeFromSuperview];
    [seekForwardControlViewinFullScreen removeFromSuperview];
*/
}

//The method will be called when telestration button is pressed
//hide all the fullscreen control buttons
-(void)hideFullScreenOverlayButtons{
    if (globals.IS_LOOP_MODE) {
        [startRangeModifierButtoninFullScreen setAlpha:0.0];
        [endRangeModifierButtoninFullScreen setAlpha:0.0];
     /*TO DELETE   [tagEventNameinFullScreen setAlpha:0.0];
        [continuePlayButtoninFullScreen setAlpha:0.0];*/
    }
    
    [playbackRateBackButton setHidden:TRUE];
    [playbackRateBackLabel setHidden:TRUE];
    [playbackRateBackGuide setHidden:TRUE];
    [playbackRateForwardButton setHidden:TRUE];
    [playbackRateForwardLabel setHidden:TRUE];
    [playbackRateForwardGuide setHidden:TRUE];
    [viewTeleButtoninFullScreen setHidden:TRUE];
/*TO DELETE
    [slowMoButtoninFullScreen setAlpha:0.0];
    [liveButtoninFullScreen setAlpha:0.0];
    [currentSeekBackButtoninFullScreen setAlpha:0.0];
    [currentSeekForwardButtoninFullScreen setAlpha:0.0];
    [seekForwardControlViewinFullScreen setHidden:TRUE];
    [seekBackControlViewinFullScreen setHidden:TRUE];
*/
}

//The method will be called when the save/clear button is pressed
//save button and clear button for telestration will be removed
//show all the fullscreen control buttons
-(void)showFullScreenOverlayButtons{
    
    if (globals.IS_LOOP_MODE) {
        [startRangeModifierButtoninFullScreen setAlpha:1.0];
        [endRangeModifierButtoninFullScreen setAlpha:1.0];
/*TO DELETE        [tagEventNameinFullScreen setAlpha:1.0];
        [continuePlayButtoninFullScreen setAlpha:1.0];
 */
    }
    
    [playbackRateBackButton setHidden:FALSE];
    [playbackRateBackLabel setHidden:FALSE];
    [playbackRateBackGuide setHidden:FALSE];
    [playbackRateForwardButton setHidden:FALSE];
    [playbackRateForwardLabel setHidden:FALSE];
    [playbackRateForwardGuide setHidden:FALSE];
    [teleButton setHidden:FALSE];
    [teleButton setAlpha:1.0];
    [teleButton setUserInteractionEnabled:TRUE];
    [viewTeleButtoninFullScreen setHidden:FALSE];
    /*TO DELETE
       [slowMoButtoninFullScreen setAlpha:1.0];
    [liveButtoninFullScreen setAlpha:1.0];
    [currentSeekBackButtoninFullScreen setAlpha:1.0];
    [currentSeekForwardButtoninFullScreen setAlpha:1.0];
    
*/
    
}

//When enter full screen, create all fullscreen control buttons
-(void)createFullScreenOverlayButtons{
    
    //create left and right event buttons
    [self createOverlayTags];
    
    /*TO DELETE
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    //seek back five seconds button
    currentSeekBackButtoninFullScreen = [CustomButton buttonWithType:UIButtonTypeCustom];
    [currentSeekBackButtoninFullScreen setFrame:CGRectMake(3*CONTROL_SPACER_X + 5,screenRect.size.width -2*CONTROL_SPACER_Y+25 ,65 ,65)];
    [currentSeekBackButtoninFullScreen setContentMode:UIViewContentModeScaleAspectFill];
    [currentSeekBackButtoninFullScreen setAccessibilityLabel:@"fullscreen"];
    UIImage *backButtonImage;
    if (globals.CURRENT_SEEK_BACK_ACTION == @selector(seekBackQuarterSecond:)) {
        backButtonImage = [UIImage imageNamed:@"seekbackquarterseclarge.png"];
    }else if (globals.CURRENT_SEEK_BACK_ACTION == @selector(seekBackOneSecond:)){
        backButtonImage = [UIImage imageNamed:@"seekbackoneseclarge.png"];
    }else{
        backButtonImage = [UIImage imageNamed:@"seekbackfivesecslarge.png"];
        globals.CURRENT_SEEK_BACK_ACTION = @selector(seekBackFiveSeconds:);
    }
 
    [currentSeekBackButtoninFullScreen setImage:backButtonImage forState:UIControlStateNormal];
    [currentSeekBackButtoninFullScreen addTarget:self action:globals.CURRENT_SEEK_BACK_ACTION forControlEvents:UIControlEventTouchUpInside];
    //[currentSeekBackButtoninFullScreen addTarget:self action:@selector(swipeOutSeekControlView:) forControlEvents:UIControlEventTouchDragInside];
    [currentSeekBackButton removeTarget:self action:globals.CURRENT_SEEK_BACK_ACTION forControlEvents:UIControlEventTouchUpInside];
    UILongPressGestureRecognizer *seekBackLongpressgesture = [[UILongPressGestureRecognizer alloc]
                                                              initWithTarget:self action:@selector(handleLongPress:)];
    seekBackLongpressgesture.minimumPressDuration = 0.5; //seconds
    seekBackLongpressgesture.delegate = self;
    [currentSeekBackButtoninFullScreen addGestureRecognizer:seekBackLongpressgesture];
    
    //uiview contains three seek back modes: go back 5s, 1s, 0.25s
    seekBackControlViewinFullScreen = [[UIView alloc]initWithFrame:CGRectMake(currentSeekBackButtoninFullScreen.frame.origin.x , 460,currentSeekBackButtoninFullScreen.frame.size.width +6,3.5*currentSeekBackButtoninFullScreen.frame.size.height)];
    [seekBackControlViewinFullScreen setBackgroundColor:[UIColor colorWithRed:(195/255.0) green:(207/255.0) blue:(216/255.0) alpha:0.1]];
    seekBackControlViewinFullScreen.hidden = TRUE;
    
    //go back 0.25s
    CustomButton *backQuarterSecButtoninFullScreen = [CustomButton buttonWithType:UIButtonTypeCustom];
    [backQuarterSecButtoninFullScreen setFrame:CGRectMake(0, 10, currentSeekBackButtoninFullScreen.frame.size.width, currentSeekBackButtoninFullScreen.frame.size.height)];
    [backQuarterSecButtoninFullScreen setContentMode:UIViewContentModeScaleAspectFill];
    [backQuarterSecButtoninFullScreen setAccessibilityLabel:@"fullscreen"];
    [backQuarterSecButtoninFullScreen setImage:[UIImage imageNamed:@"seekbackquarterseclarge.png"] forState:UIControlStateNormal];
    [backQuarterSecButtoninFullScreen addTarget:self action:@selector(seekBackQuarterSecond:) forControlEvents:UIControlEventTouchUpInside];
    [backQuarterSecButtoninFullScreen addTarget:self action:@selector(hideSeekControlView:) forControlEvents:UIControlEventTouchDragInside];
    [seekBackControlViewinFullScreen addSubview:backQuarterSecButtoninFullScreen];
    
    //go back 1 s
    CustomButton *backOneSecButtoninFullScreen = [CustomButton buttonWithType:UIButtonTypeCustom];
    [backOneSecButtoninFullScreen setFrame:CGRectMake(0, backQuarterSecButtoninFullScreen.frame.origin.y + backQuarterSecButtoninFullScreen.frame.size.height + 10, currentSeekBackButtoninFullScreen.frame.size.width, currentSeekBackButtoninFullScreen.frame.size.height)];
    [backOneSecButtoninFullScreen setContentMode:UIViewContentModeScaleAspectFill];
    [backOneSecButtoninFullScreen setAccessibilityLabel:@"fullscreen"];
    [backOneSecButtoninFullScreen setImage:[UIImage imageNamed:@"seekbackoneseclarge.png"] forState:UIControlStateNormal];
    [backOneSecButtoninFullScreen addTarget:self action:@selector(seekBackOneSecond:) forControlEvents:UIControlEventTouchUpInside];
    [backOneSecButtoninFullScreen addTarget:self action:@selector(hideSeekControlView:) forControlEvents:UIControlEventTouchDragInside];
    [seekBackControlViewinFullScreen addSubview:backOneSecButtoninFullScreen];
    
    //go back 5 s
    CustomButton *backFiveSecsButtoninFullScreen = [CustomButton buttonWithType:UIButtonTypeCustom];
    [backFiveSecsButtoninFullScreen setFrame:CGRectMake(0, backOneSecButtoninFullScreen.frame.origin.y + backOneSecButtoninFullScreen.frame.size.height + 10, currentSeekBackButtoninFullScreen.frame.size.width, currentSeekBackButtoninFullScreen.frame.size.height)];
    [backFiveSecsButtoninFullScreen setContentMode:UIViewContentModeScaleAspectFill];
    [backFiveSecsButtoninFullScreen setAccessibilityLabel:@"fullscreen"];
    [backFiveSecsButtoninFullScreen setImage:[UIImage imageNamed:@"seekbackfivesecslarge.png"] forState:UIControlStateNormal];
    [backFiveSecsButtoninFullScreen addTarget:self action:@selector(seekBackFiveSeconds:) forControlEvents:UIControlEventTouchUpInside];
    [backFiveSecsButtoninFullScreen addTarget:self action:@selector(hideSeekControlView:) forControlEvents:UIControlEventTouchDragInside];
    [seekBackControlViewinFullScreen addSubview:backFiveSecsButtoninFullScreen];
    
    
    //seek forward 5 seconds button
    currentSeekForwardButtoninFullScreen = [CustomButton buttonWithType:UIButtonTypeCustom];
    [currentSeekForwardButtoninFullScreen setFrame:CGRectMake(screenRect.size.height-(3*CONTROL_SPACER_X)-80,screenRect.size.width -2*CONTROL_SPACER_Y+25,65 ,65)];
    [currentSeekForwardButtoninFullScreen setContentMode:UIViewContentModeScaleAspectFill];
    [currentSeekForwardButtoninFullScreen setAccessibilityLabel:@"fullscreen"];
    UIImage *forwardButtonImage;
    if (globals.CURRENT_SEEK_FORWARD_ACTION == @selector(seekForwardQuarterSecond:)) {
        forwardButtonImage = [UIImage imageNamed:@"seekforwardquarterseclarge.png"];
    }else if (globals.CURRENT_SEEK_FORWARD_ACTION == @selector(seekForwardOneSecond:)){
        forwardButtonImage = [UIImage imageNamed:@"seekforwardoneseclarge.png"];
    }else{
        forwardButtonImage = [UIImage imageNamed:@"seekforwardfivesecslarge.png"];
        globals.CURRENT_SEEK_FORWARD_ACTION = @selector(seekForwardFiveSeconds:);
    }
    
    [currentSeekForwardButtoninFullScreen setImage:forwardButtonImage forState:UIControlStateNormal];
    [currentSeekForwardButtoninFullScreen addTarget:self action:globals.CURRENT_SEEK_FORWARD_ACTION forControlEvents:UIControlEventTouchUpInside];
    //[currentSeekForwardButtoninFullScreen addTarget:self action:@selector(swipeOutSeekControlView:) forControlEvents:UIControlEventTouchDragInside];
    [currentSeekForwardButton removeTarget:self action:globals.CURRENT_SEEK_FORWARD_ACTION forControlEvents:UIControlEventTouchUpInside];
    UILongPressGestureRecognizer *seekForwardLongpressgesture = [[UILongPressGestureRecognizer alloc]
                                                                 initWithTarget:self action:@selector(handleLongPress:)];
    seekForwardLongpressgesture.minimumPressDuration = 0.5; //seconds
    seekForwardLongpressgesture.delegate = self;
    [currentSeekForwardButtoninFullScreen addGestureRecognizer:seekForwardLongpressgesture];
    
    //uiview contains three seek back modes: go forward 5s, 1s, 0.25s
    seekForwardControlViewinFullScreen = [[UIView alloc]initWithFrame:CGRectMake(currentSeekForwardButtoninFullScreen.frame.origin.x , 460,currentSeekBackButtoninFullScreen.frame.size.width +6,3.5*currentSeekBackButtoninFullScreen.frame.size.height)];
    [seekForwardControlViewinFullScreen setBackgroundColor:[UIColor colorWithRed:(195/255.0) green:(207/255.0) blue:(216/255.0) alpha:0.1]];
    seekForwardControlViewinFullScreen.hidden = TRUE;

    //go back 0.25s
    CustomButton *forwardQuarterSecButtoninFullScreen = [CustomButton buttonWithType:UIButtonTypeCustom];
    [forwardQuarterSecButtoninFullScreen setFrame:CGRectMake(0, 10, currentSeekBackButtoninFullScreen.frame.size.width, currentSeekBackButtoninFullScreen.frame.size.height)];
    [forwardQuarterSecButtoninFullScreen setContentMode:UIViewContentModeScaleAspectFill];
    [forwardQuarterSecButtoninFullScreen setAccessibilityLabel:@"fullscreen"];
    [forwardQuarterSecButtoninFullScreen setImage:[UIImage imageNamed:@"seekforwardquarterseclarge.png"] forState:UIControlStateNormal];
    [forwardQuarterSecButtoninFullScreen addTarget:self action:@selector(seekForwardQuarterSecond:) forControlEvents:UIControlEventTouchUpInside];
    [forwardQuarterSecButtoninFullScreen addTarget:self action:@selector(hideSeekControlView:) forControlEvents:UIControlEventTouchDragInside];
    [seekForwardControlViewinFullScreen addSubview:forwardQuarterSecButtoninFullScreen];
    
    //go back 1 s
    CustomButton *forwardOneSecButtoninFullScreen = [CustomButton buttonWithType:UIButtonTypeCustom];
    [forwardOneSecButtoninFullScreen setFrame:CGRectMake(0, forwardQuarterSecButtoninFullScreen.frame.origin.y + forwardQuarterSecButtoninFullScreen.frame.size.height + 10, currentSeekBackButtoninFullScreen.frame.size.width, currentSeekBackButtoninFullScreen.frame.size.height)];
    [forwardOneSecButtoninFullScreen setContentMode:UIViewContentModeScaleAspectFill];
    [forwardOneSecButtoninFullScreen setAccessibilityLabel:@"fullscreen"];
    [forwardOneSecButtoninFullScreen setImage:[UIImage imageNamed:@"seekforwardoneseclarge.png"] forState:UIControlStateNormal];
    [forwardOneSecButtoninFullScreen addTarget:self action:@selector(seekForwardOneSecond:) forControlEvents:UIControlEventTouchUpInside];
    [forwardOneSecButtoninFullScreen addTarget:self action:@selector(hideSeekControlView:) forControlEvents:UIControlEventTouchDragInside];
    [seekForwardControlViewinFullScreen addSubview:forwardOneSecButtoninFullScreen];
    
    //go back 5 s
    CustomButton *forwardFiveSecsButtoninFullScreen = [CustomButton buttonWithType:UIButtonTypeCustom];
    [forwardFiveSecsButtoninFullScreen setFrame:CGRectMake(0, forwardOneSecButtoninFullScreen.frame.origin.y + forwardOneSecButtoninFullScreen.frame.size.height + 10, currentSeekBackButtoninFullScreen.frame.size.width, currentSeekBackButtoninFullScreen.frame.size.height)];
    [forwardFiveSecsButtoninFullScreen setContentMode:UIViewContentModeScaleAspectFill];
    [forwardFiveSecsButtoninFullScreen setAccessibilityLabel:@"fullscreen"];
    [forwardFiveSecsButtoninFullScreen setImage:[UIImage imageNamed:@"seekforwardfivesecslarge.png"] forState:UIControlStateNormal];
    [forwardFiveSecsButtoninFullScreen addTarget:self action:@selector(seekForwardFiveSeconds:) forControlEvents:UIControlEventTouchUpInside];
    [forwardFiveSecsButtoninFullScreen addTarget:self action:@selector(hideSeekControlView:) forControlEvents:UIControlEventTouchDragInside];
    [seekForwardControlViewinFullScreen addSubview:forwardFiveSecsButtoninFullScreen];
    
    
    
    //slow motion button
    slowMoButtoninFullScreen =  [CustomButton buttonWithType:UIButtonTypeCustom];
    [slowMoButtoninFullScreen setFrame:CGRectMake(8*CONTROL_SPACER_X,screenRect.size.width- 2*CONTROL_SPACER_Y +35 ,65 ,50)];
    [slowMoButtoninFullScreen setContentMode:UIViewContentModeScaleAspectFill];
    if(globals.PLAYBACK_SPEED == 1.0f)
    {
        [slowMoButtoninFullScreen setImage:[UIImage imageNamed:@"normalsp.png"] forState:UIControlStateNormal];
        
    }else{
        [slowMoButtoninFullScreen setImage:[UIImage imageNamed:@"slowmo.png"] forState:UIControlStateNormal];
        
    }
    [slowMoButtoninFullScreen addTarget:self action:@selector(slowMoController:) forControlEvents:UIControlEventTouchUpInside];
    
    //add go to live button
    liveButtoninFullScreen = [BorderButton buttonWithType:UIButtonTypeCustom];
    [liveButtoninFullScreen setFrame:CGRectMake(screenRect.size.height/2.0+200,screenRect.size.width- CONTROL_SPACER_Y-10, LITTLE_ICON_DIMENSIONS + 90, LITTLE_ICON_DIMENSIONS-10)];
    [liveButtoninFullScreen setContentMode:UIViewContentModeScaleAspectFit];
    [liveButtoninFullScreen setBackgroundImage:[UIImage imageNamed:@"gotolive"] forState:UIControlStateNormal];
    [liveButtoninFullScreen setBackgroundImage:[UIImage imageNamed:@"gotoliveSelect"] forState:UIControlStateHighlighted];
    [liveButtoninFullScreen setTitle:@"Live" forState:UIControlStateNormal];
    //[liveButtoninFullScreen changeBackgroundColor:[UIColor whiteColor] :0.8];
    [liveButtoninFullScreen addTarget:self action:@selector(goToLive) forControlEvents:UIControlEventTouchUpInside];
          */
    //for testing
    timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(CONTROL_SPACER_X -50,CONTROL_SPACER_Y + 150,165 ,50)];
    [timeLabel setText:[NSString stringWithFormat:@"%f",[videoPlayer currentTimeInSeconds]]];
    [timeLabel setBackgroundColor:[UIColor orangeColor]];
    [timeLabel setFont:[UIFont boldSystemFontOfSize:20.f]];
    [timeLabel setTextAlignment:NSTextAlignmentCenter];
        
    if ( (int)[[[videoPlayer avPlayer]currentItem]status] == AVPlayerItemStatusFailed || (int)[[[videoPlayer avPlayer]currentItem]status] == AVPlayerItemStatusUnknown || [globals.EVENT_NAME isEqualToString:@""] )
    {
        if (![globals.CURRENT_ENC_STATUS isEqualToString:encStateLive]){
    /*TO DELETE    [liveButtoninFullScreen setAlpha:0.6];
        [liveButtoninFullScreen setUserInteractionEnabled:FALSE];*/
        }
        /*TO DELETE  [continuePlayButtoninFullScreen setAlpha:0.6];
        [continuePlayButtoninFullScreen  setUserInteractionEnabled:FALSE];*/
        [teleButton setUserInteractionEnabled:FALSE];
        [teleButton setAlpha:0.6];
    }else{
        if ([globals.CURRENT_ENC_STATUS isEqualToString:encStateLive]){
     /*TO DELETE      [liveButtoninFullScreen setAlpha:1.0];
        [liveButtoninFullScreen setUserInteractionEnabled:TRUE];*/
        }else{
       /*TO DELETE      [liveButtoninFullScreen setAlpha:0.6];
            [liveButtoninFullScreen setUserInteractionEnabled:FALSE];*/

        }
     /*TO DELETE   [continuePlayButtoninFullScreen setAlpha:1.0];
        [continuePlayButtoninFullScreen  setUserInteractionEnabled:TRUE];*/
        [teleButton setUserInteractionEnabled:TRUE];
        [teleButton setAlpha:1.0];
    }
    
    //init button to view telestration
    viewTeleButtoninFullScreen = [BorderButton buttonWithType:UIButtonTypeCustom];
    [viewTeleButtoninFullScreen setFrame:CGRectMake(900,60, 130, LITTLE_ICON_DIMENSIONS)];
    //[liveButton setBackgroundImage:[UIImage imageNamed:@"gotolive"] forState:UIControlStateNormal];
    //[liveButton setBackgroundImage:[UIImage imageNamed:@"gotoliveSelect"] forState:UIControlStateHighlighted];
    [viewTeleButtoninFullScreen setTitle:@"View Tele" forState:UIControlStateNormal];
    [viewTeleButtoninFullScreen addTarget:self action:@selector(viewTele:) forControlEvents:UIControlEventTouchUpInside];
    if (!globals.LATEST_TELE || [[globals.CURRENT_PLAYBACK_TAG objectForKey:@"type"]intValue] == 4) {
        viewTeleButtoninFullScreen.hidden = TRUE;
    }
    
 /*TO DELETE     [self.overlayItems addObject:currentSeekBackButtoninFullScreen];
    [self.overlayItems addObject:currentSeekForwardButtoninFullScreen];
    [self.overlayItems addObject:slowMoButtoninFullScreen];
    [self.overlayItems addObject:liveButtoninFullScreen];
    [self.overlayItems addObject:seekForwardControlViewinFullScreen];
    [self.overlayItems addObject:seekBackControlViewinFullScreen];*/
    
    [self.overlayItems addObject:viewTeleButtoninFullScreen];
     /*TO DELETE    
    UIView *newParentView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    [newParentView addSubview: currentSeekBackButtoninFullScreen];
    [newParentView addSubview:currentSeekForwardButtoninFullScreen];
    [newParentView addSubview:slowMoButtoninFullScreen];
    [newParentView addSubview: liveButtoninFullScreen];
    [newParentView addSubview:seekForwardControlViewinFullScreen];
    [newParentView addSubview:seekBackControlViewinFullScreen];*/
     //viewtelebutton only for medical use
    //[newParentView addSubview:viewTeleButtoninFullScreen];
}

//create fullscreen left and right event buttons
-(void)createOverlayTags;
{
    //initialise buttons on the left side of fullscreen
    self.overlayLeftViewController=[[OverlayViewController alloc]initWithSide:@"left"];
    [self.overlayLeftViewController.view setFrame:CGRectMake(-self.leftSideButtons.frame.size.width, self.leftSideButtons.frame.origin.y + 20.0f, self.leftSideButtons.frame.size.width,self.leftSideButtons.frame.size.height )];
    
    //buttons on right side of the fullscreen
    self.overlayRightViewController=[[OverlayViewController alloc]initWithSide:@"right"];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    [self.overlayRightViewController.view setFrame:CGRectMake(screenRect.size.height, self.rightSideButtons.frame.origin.y + 20.0f, self.leftSideButtons.frame.size.width,self.leftSideButtons.frame.size.height )];
    
    int count=1;
    int countL = 0;
    int countR = 0;
    
    //get tagbuttons and add them to the fullscreen view
    for(NSDictionary *dict in self.tagNames)
    {
        BorderButton *button = [BorderButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:[dict objectForKey:@"name"] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [button setContentEdgeInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
        [button addTarget:self action:@selector(tagButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
        [button setTag:count];
        //if the user opens a duration tag in normal mode, when going to fullscreen mode, we need to highlight the button with the selected event name
        
        if ((isDurationTagEnabled && swipedOutButton.selected && [[dict objectForKey:@"name"] isEqual:swipedOutButton.titleLabel.text] && [[dict objectForKey:@"side"] isEqual:swipedOutButton.accessibilityValue]) || [globals.UNCLOSED_EVENT isEqualToString:[dict objectForKey:@"name"]]) {
            swipedOutButton.selected = FALSE;
            button.selected = TRUE;
            swipedOutButton = button;
        }

        if([[dict objectForKey:@"side"] isEqualToString:@"left"])
        {
            [button setFrame:CGRectMake(0, (countL*32)+20, self.overlayLeftViewController.view.frame.size.width, 30)];
            [button setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
            [button setContentEdgeInsets:UIEdgeInsetsMake(3, 3+self.leftSideButtons.frame.size.width/2, 3, 3)];
            [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
            countL++;
            [self.overlayLeftViewController.view addSubview:button];
            [button setAccessibilityValue:@"left"];
        }else{
            [button setFrame:CGRectMake(self.rightSideButtons.frame.size.width-self.overlayLeftViewController.view.frame.size.width, (countR*32)+20, self.overlayLeftViewController.view.frame.size.width, 30) ];
            [button setContentEdgeInsets:UIEdgeInsetsMake(3, 3, 3, 3+self.leftSideButtons.frame.size.width/2)];
            [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            countR++;
            [self.overlayRightViewController.view addSubview:button];
            [button setAccessibilityValue:@"right"];
        }
        count ++;
    }
    
    //when 1. there is no wifi; 2. play back a downloaded event 3.there is no live event or old event playing,gray the all the tag buttons
    if(((![globals.CURRENT_ENC_STATUS isEqualToString:encStateLive] ||(int)[[[videoPlayer avPlayer]currentItem]status] == AVPlayerItemStatusFailed || (int)[[[videoPlayer avPlayer]currentItem]status] == AVPlayerItemStatusUnknown )&& ([globals.EVENT_NAME isEqualToString:@"live"] || [globals.EVENT_NAME isEqualToString:@""])) || [globals.CURRENT_PLAYBACK_EVENT isEqualToString:@""])
    {
        [self.overlayLeftViewController.view setUserInteractionEnabled:FALSE];
        [self.overlayRightViewController.view setUserInteractionEnabled:FALSE];
        if (!isModifyingPlaybackRate) {
            [self.overlayLeftViewController.view setAlpha:0.6];
            [self.overlayRightViewController.view setAlpha:0.6];
        }
    }else{
        [self.overlayLeftViewController.view setUserInteractionEnabled:TRUE];
        [self.overlayRightViewController.view setUserInteractionEnabled:TRUE];
        if (!isModifyingPlaybackRate) {
            [self.overlayLeftViewController.view setAlpha:1.0];
            [self.overlayRightViewController.view setAlpha:1.0];
        }
        
    }
    
    [self.overlayItems addObject:self.overlayLeftViewController.view];
    [self.overlayItems addObject:self.overlayRightViewController.view];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.overlayLeftViewController.view];
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.overlayRightViewController.view];
    
    CGRect tempFrame = self.overlayLeftViewController.view.frame;
    
    //animation to slide the buttons out and then in again a little bit on the full screen window
    [UIView animateWithDuration:0.3
                     animations:^{[self.overlayLeftViewController.view setFrame:CGRectMake(tempFrame.origin.x+self.leftSideButtons.frame.size.width/2, tempFrame.origin.y, tempFrame.size.width, tempFrame.size.height)];}
                     completion:^(BOOL finished){}];
    
    tempFrame = self.overlayRightViewController.view.frame;
    //animateleft
    [UIView animateWithDuration:0.3
                     animations:^{[self.overlayRightViewController.view setFrame:CGRectMake(tempFrame.origin.x-self.leftSideButtons.frame.size.width/2, tempFrame.origin.y, tempFrame.size.width, tempFrame.size.height)];}
                     completion:^(BOOL finished){}];
    
  
    [self showTeleButton];
    
    //when it is local playback
    if ([globals.CURRENT_PLAYBACK_EVENT rangeOfString:@"mp4"].location != NSNotFound) {
        [self showPlaybackRateControls];
    }


    
}

//show telestration button
-(void)showTeleButton
{
    if (teleButton) {
        [teleButton removeFromSuperview];
        teleButton = nil;
    }
    teleButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    [teleButton setFrame:CGRectMake(949.0f, 585.0f, 64.0f, 64.0f)];
    [teleButton setContentMode:UIViewContentModeScaleAspectFill];
    [teleButton setImage:[UIImage imageNamed:@"teleButton"] forState:UIControlStateNormal];
    [teleButton setImage:[UIImage imageNamed:@"teleButtonSelect"] forState:UIControlStateHighlighted];
    [teleButton addTarget:self action:@selector(initTele:) forControlEvents:UIControlEventTouchUpInside];
    [self.overlayItems addObject:teleButton];
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:teleButton];
}

-(void)showPlaybackRateControls
{
    if (globals.CURRENT_PLAYBACK_EVENT && globals.CURRENT_PLAYBACK_EVENT.length > 4) {
        if (!globals.IS_LOCAL_PLAYBACK && [[globals.CURRENT_PLAYBACK_EVENT substringWithRange:NSMakeRange(globals.CURRENT_PLAYBACK_EVENT.length - 4, 3)] isEqualToString:@"mp4"]) {
            NSLog(@"Is not local playback, but is an mp4");
        } else if (globals.IS_LOCAL_PLAYBACK && ![[globals.CURRENT_PLAYBACK_EVENT substringWithRange:NSMakeRange(globals.CURRENT_PLAYBACK_EVENT.length - 4, 3)] isEqualToString:@"mp4"]) {
            NSLog(@"Is local playback, but is not an mp4");
        }
    }
    if (!globals.IS_LOCAL_PLAYBACK) {
        return;
    }
    if (playbackRateBackButton){
        [playbackRateBackButton removeFromSuperview];
        playbackRateBackButton = nil;
        [playbackRateBackGuide removeFromSuperview];
        playbackRateBackGuide = nil;
        [playbackRateBackLabel removeFromSuperview];
        playbackRateBackLabel = nil;
    }
    if (playbackRateForwardButton){
        [playbackRateForwardButton removeFromSuperview];
        playbackRateForwardButton = nil;
        [playbackRateForwardGuide removeFromSuperview];
        playbackRateForwardGuide = nil;
        [playbackRateForwardLabel removeFromSuperview];
        playbackRateForwardLabel = nil;
    }
    
    //Playback rate controls
    playbackRateBackButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    [playbackRateBackButton setFrame:CGRectMake(165, 585, 70.0f, 70.0f)];
    [playbackRateBackButton setContentMode:UIViewContentModeScaleAspectFit];
    [playbackRateBackButton setTag:0];
    [playbackRateBackButton setImage:[UIImage imageNamed:@"playbackRateButtonBack"] forState:UIControlStateNormal];
    [playbackRateBackButton setImage:[UIImage imageNamed:@"playbackRateButtonBackSelected"] forState:UIControlStateHighlighted];
    [playbackRateBackButton setImage:[UIImage imageNamed:@"playbackRateButtonBackSelected"] forState:UIControlStateSelected];
    [playbackRateBackButton addTarget:self action:@selector(playbackRateButtonUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.overlayItems addObject:playbackRateBackButton];
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:playbackRateBackButton];
    
    playbackRateBackGuide = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"playbackRateTrackBack"]];
    [playbackRateBackGuide setFrame:CGRectMake(playbackRateBackButton.frame.origin.x - 148, playbackRateBackButton.frame.origin.y - 146, playbackRateBackGuide.bounds.size.width, playbackRateBackGuide.bounds.size.height)];
    [playbackRateBackGuide setContentMode:UIViewContentModeScaleAspectFit];
    [playbackRateBackGuide setAlpha:0.0f];
 
    playbackRateBackLabel = [CustomLabel labelWithStyle:CLStyleWhite];
    [playbackRateBackLabel setFrame:CGRectMake(CGRectGetMaxX(playbackRateBackButton.frame), playbackRateBackButton.frame.origin.y, 60.0f, 30.0f)];
    [playbackRateBackLabel setText:@"-2x"];
    [playbackRateBackLabel setTextAlignment:NSTextAlignmentCenter];
    [playbackRateBackLabel.layer setCornerRadius:4.0f];
    [playbackRateBackLabel setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.2f]];
    [playbackRateBackLabel setAlpha:0.0f];
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:playbackRateBackLabel];
    
    playbackRateForwardButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    [playbackRateForwardButton setFrame:CGRectMake(playbackRateBackButton.superview.bounds.size.width - playbackRateBackButton.frame.origin.x - playbackRateBackButton.bounds.size.width, playbackRateBackButton.frame.origin.y, playbackRateBackButton.bounds.size.width, playbackRateBackButton.bounds.size.height)];
    [playbackRateForwardButton setContentMode:UIViewContentModeScaleAspectFit];
    [playbackRateForwardButton setTag:1];
    [playbackRateForwardButton setImage:[UIImage imageNamed:@"playbackRateButtonForward"] forState:UIControlStateNormal];
    [playbackRateForwardButton setImage:[UIImage imageNamed:@"playbackRateButtonForwardSelected"] forState:UIControlStateHighlighted];
    [playbackRateForwardButton setImage:[UIImage imageNamed:@"playbackRateButtonForwardSelected"] forState:UIControlStateSelected];
    [playbackRateForwardButton addTarget:self action:@selector(playbackRateButtonUp:) forControlEvents:UIControlEventTouchUpInside];

    [self.overlayItems addObject:playbackRateForwardButton];
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:playbackRateForwardButton];
    
    playbackRateForwardGuide = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"playbackRateTrackForward"]];
    [playbackRateForwardGuide setFrame:CGRectMake(playbackRateForwardButton.superview.bounds.size.width - playbackRateBackGuide.bounds.size.width - (playbackRateBackButton.frame.origin.x - 148), playbackRateBackGuide.frame.origin.y, playbackRateBackGuide.bounds.size.width, playbackRateBackGuide.bounds.size.height)];
    [playbackRateForwardGuide setContentMode:UIViewContentModeScaleAspectFit];
    [playbackRateForwardGuide setAlpha:0.0f];

    playbackRateForwardLabel = [CustomLabel labelWithStyle:CLStyleWhite];
    [playbackRateForwardLabel setFrame:CGRectMake(playbackRateForwardButton.frame.origin.x - playbackRateBackLabel.bounds.size.width, playbackRateForwardButton.frame.origin.y, playbackRateBackLabel.bounds.size.width, playbackRateBackLabel.bounds.size.height)];
    [playbackRateForwardLabel setText:@"2x"];
    [playbackRateForwardLabel setTextAlignment:NSTextAlignmentCenter];
    [playbackRateForwardLabel.layer setCornerRadius:4.0f];
    [playbackRateForwardLabel setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.2f]];
    [playbackRateForwardLabel setAlpha:0.0f];
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:playbackRateForwardLabel];
}

//when scrubbing the slider, need to remove telestration
-(void)scrubbingDestroyLoopMode
{
    
    if(telestrationOverlay)
    {
        [self continuePlay];
    }
    [self destroyThumbLoop];
    globals.IS_LOOP_MODE = FALSE;
}

//if the device is locked, stop the updateplayeration timer
-(void)pauseUpdatePlayerDurationTimer
{
   
    if (globals.IS_IN_FIRST_VIEW) {
        globals.PLAYABLE_DURATION = videoPlayer.duration;
        [updateCurrentEventInfoTimer invalidate];
        updateCurrentEventInfoTimer = nil;
        
        if (globals.IS_LOOP_MODE) {
            [self destroyThumbLoop];
        }
    }
}

//if the device is back to active, restart the updateplayerduaration timer
-(void)resumeUpdatePlayerDurationTimer
{
  
    if (globals.IS_IN_FIRST_VIEW) {
        if (!updateCurrentEventInfoTimer) {
            updateCurrentEventInfoTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                 target:self
                                                               selector:@selector(updateCurrentEventInfo)
                                                               userInfo:nil
                                                                repeats:YES];
        }
        [self updateCurrentEventInfo];
    }
    
    //if the device locks when there is live event playing,reset the player when the device becomes active, otherwise we will have black screen

    if ([globals.EVENT_NAME isEqualToString:@"live"]) {
        globals.CURRENT_PLAYBACK_EVENT = [NSString stringWithFormat:@"%@/events/live/video/list.m3u8",globals.URL];
        [self goToLive];
    }
    
//    //for testing
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"myplayXplay" message:@"reset video player in live2bench view" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//    [alert show];
    
    
    NSURL *videoURL = [NSURL URLWithString:globals.CURRENT_PLAYBACK_EVENT];
    //AVPlayer *myPlayer = [AVPlayer playerWithURL:videoURL];
    globals.isBACKFROMSLEEP = TRUE;
    [globals.VIDEO_PLAYER_LIST_VIEW setVideoURL:videoURL];
    [globals.VIDEO_PLAYER_LIST_VIEW setPlayerWithURL:videoURL];
    
    [videoPlayer setVideoURL:videoURL];
    [videoPlayer setPlayerWithURL:videoURL];
    //videoPlayer = globals.VIDEO_PLAYER_LIVE2BENCH;

    
    globals.VIDEO_PLAYBACK_FAILED = FALSE;
    if (globals.IS_IN_FIRST_VIEW) {
        [globals.VIDEO_PLAYER_LIST_VIEW pause];
        if(globals.IS_TELE){
            globals.RETAINEDPLAYBACKTIME = globals.TELE_TIME;
            CMTime teleTime = CMTimeMakeWithSeconds(globals.RETAINEDPLAYBACKTIME, 1);
            [videoPlayer.avPlayer seekToTime:teleTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
            [videoPlayer pause];
        }else{
            globals.RETAINEDPLAYBACKTIME =  currentPlayBackTime;
            CMTime teleTime = CMTimeMakeWithSeconds(globals.RETAINEDPLAYBACKTIME, 1);
            [videoPlayer.avPlayer seekToTime:teleTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
            if (globals.PLAYBACK_SPEED == 0) {
                 [videoPlayer pause];
            }else{
                [videoPlayer play];
            }

            
            //go to live after 3 seconds delay
            [videoPlayer performSelector:@selector(goToLive) withObject:nil afterDelay:5];
        }
     
    }else if(globals.IS_IN_LIST_VIEW){
        [videoPlayer pause];
        if(globals.IS_TELE){
            globals.RETAINEDPLAYBACKTIME = globals.TELE_TIME;
            CMTime teleTime = CMTimeMakeWithSeconds(globals.RETAINEDPLAYBACKTIME, 1);
            [globals.VIDEO_PLAYER_LIST_VIEW.avPlayer seekToTime:teleTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
            [globals.VIDEO_PLAYER_LIST_VIEW pause];
        }else{
            globals.RETAINEDPLAYBACKTIME =  currentPlayBackTime;
            
            if (globals.PLAYBACK_SPEED == 0) {
                [globals.VIDEO_PLAYER_LIST_VIEW pause];

            }else{
                [globals.VIDEO_PLAYER_LIST_VIEW play];
            }

        }
    }
    
}

-(void)highlightDurationTag
{
    durationTagSwitch.on = TRUE;
    isDurationTagEnabled = TRUE;
    [self createTagButtons];
}

-(void)removeCurrentTimeObserver
{
    if (loopTagObserver) {
        loopTagObserver = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_RECEIVE_MEMORY_WARNING object:self userInfo:nil];
    [super didReceiveMemoryWarning];
}

@end

