
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

#import "Pip.h"
#import "PipViewController.h"
#import "FeedSwitchView.h"
#import "Feed.h"

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
    LiveButton                          * _gotoLiveButton;                  // live button
    // player with pip and feed select                                  // updated player
    L2BVideoBarViewController           * _videoBarViewController;       // player updated control bar
    Live2BenchTagUIViewController       * _tagButtonController;         // side tags
    BottomViewControllerBase            * _bottomViewControllerBase;    // base bottomview controller ALL Sports interchangeable
    L2BFullScreenViewController         * _fullscreenViewController;     // fullscreen class to manage all actions in full
    // Telestration                                                     // telestration might be added to full screen class
    void                                * eventTypeContext;             // to see when sport changes in encoderManager
    
    PipViewController                   * _pipController;
    Pip                                 * _pip;
    FeedSwitchView                      * _feedSwitch;
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
@synthesize playbackRateBackButton;
@synthesize playbackRateForwardButton;
@synthesize teleViewController=_teleViewController;
@synthesize teleButton;
@synthesize currentEventName =_currentEventName;
@synthesize currentPlayingEventMarker=_currentPlayingEventMarker;
@synthesize accountInfo;
//@synthesize startRangeModifierButton,endRangeModifierButton;
@synthesize leftSideButtons=_leftSideButtons;
@synthesize rightSideButtons=_rightSideButtons;
@synthesize playerCollectionViewController;
@synthesize footballTrainingCollectionViewController;
@synthesize continuePlayButton,fullscreenOverlayCreated,currentPlayBackTime;
@synthesize videoPlaybackFailedAlertView;
@synthesize poorSignalCounter;
@synthesize switchToLiveEvent;
@synthesize spinnerViewCounter;
@synthesize spinnerView;
@synthesize tagMarkerLeadObjDict;
@synthesize updateTagmarkerCounter;
@synthesize durationTagLabel;
@synthesize durationTagSwitch;
@synthesize openedDurationTagButtons;
@synthesize isDurationTagEnabled;
@synthesize playerEncoderStatusLabel;
@synthesize loopTagObserver;


// FULL SCREEN
@synthesize enterFullScreen;



int loginIndex = 0; //indicate it is the first time go to first view or not
int tagsinQueueInOfflineMode = 0;


// Context
static void * eventTypeContext  = &eventTypeContext;
static void * eventContext      = &eventContext;

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
    [_encoderManager addObserver:self forKeyPath:NSStringFromSelector(@selector(currentEventType))  options:NSKeyValueObservingOptionNew context:&eventTypeContext];
    [_encoderManager addObserver:self forKeyPath:NSStringFromSelector(@selector(currentEvent))      options:NSKeyValueObservingOptionNew context:&eventContext];
    return self;
    
}


#pragma mark - Observers and Observer Methods

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &eventTypeContext){ // This checks to see if the encoder manager has changed Events Types like Sport or Medical
        [self onEventTypeChange: [change objectForKey:@"new"]];
    } else if (context == &eventContext){
        [self onEventChange];
    }

}


// This will have all the code that will init a bottomview controller based of the EventType .... Sport or medical
-(void)onEventTypeChange:(NSString*)aType
{
    _eventType = aType;

}

// when the event changes mod these
-(void)onEventChange
{

    if ([_encoderManager.currentEvent isEqualToString:@"None"]){
        [_videoBarViewController setBarMode:L2B_VIDEO_BAR_MODE_DISABLE];
        self.videoPlayer.live   = NO;
        [_gotoLiveButton isActive:NO];

    } else if ([_encoderManager.currentEvent isEqualToString:_encoderManager.liveEventName]){      // LIVE
        [_videoBarViewController setBarMode:L2B_VIDEO_BAR_MODE_LIVE];
        self.videoPlayer.live   = YES;
          [_gotoLiveButton isActive:YES];

    } else { // CLIP
        [_videoBarViewController setBarMode:L2B_VIDEO_BAR_MODE_CLIP];
        self.videoPlayer.live   = NO;
        [_gotoLiveButton isActive:YES];

    }
    
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

    [self.view addSubview:currentEventTitle];
    

    
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
    

//         self.videoPlayer = globals.VIDEO_PLAYER_LIVE2BENCH;
    self.videoPlayer = [[VideoPlayer alloc] init];
    [self.videoPlayer initializeVideoPlayerWithFrame:CGRectMake(156, 100, MEDIA_PLAYER_WIDTH, MEDIA_PLAYER_HEIGHT)];
    
    // side tags
    _tagButtonController = [[Live2BenchTagUIViewController alloc]initWithView:self.view];
    [self addChildViewController:_tagButtonController];
    [_tagButtonController didMoveToParentViewController:self];
    
    
    // Richard
    
    _videoBarViewController = [[L2BVideoBarViewController alloc]initWithVideoPlayer:videoPlayer];
    [_videoBarViewController.startRangeModifierButton   addTarget:self action:@selector(startRangeBeenModified:) forControlEvents:UIControlEventTouchUpInside];
    [_videoBarViewController.endRangeModifierButton     addTarget:self action:@selector(endRangeBeenModified:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_videoBarViewController.view];

    _fullscreenViewController = [[L2BFullScreenViewController alloc]initWithVideoPlayer:videoPlayer];
    _fullscreenViewController.context = @"Live2Bench Tab";
    [_fullscreenViewController.continuePlay     addTarget:self action:@selector(continuePlay)   forControlEvents:UIControlEventTouchUpInside];
    [_fullscreenViewController.liveButton       addTarget:self action:@selector(goToLive)       forControlEvents:UIControlEventTouchUpInside];
    [_fullscreenViewController.teleButton       addTarget:self action:@selector(initTele:)      forControlEvents:UIControlEventTouchUpInside];
    

    videoPlayer.context = _fullscreenViewController.context;
    [_fullscreenViewController setMode: L2B_FULLSCREEN_MODE_DEMO];
    // so get buttons are connected to full screen
    _tagButtonController.fullScreenViewController = _fullscreenViewController;
    
    
    _pip            = [[Pip alloc]initWithFrame:CGRectMake(50, 50, 200, 150)];
    _pip.isDragAble  = YES;
    _pip.hidden      = YES;
    _pip.dragBounds  = videoPlayer.playerLayer.frame;
    [videoPlayer.view addSubview:_pip];
    _feedSwitch     = [[FeedSwitchView alloc]initWithFrame:CGRectMake(100, 600, 100, 100) encoderManager:_encoderManager];
    
    _pipController  = [[PipViewController alloc]initWithVideoPlayer:videoPlayer f:_feedSwitch encoderManager:_encoderManager];
    [_pipController addPip:_pip];
    [_pipController viewDidLoad];
    [self.view addSubview:_feedSwitch];
    
}

-(void)viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:animated];
    _encoderManager.currentEvent = _encoderManager.liveEventName;
    [videoPlayer playFeed:_feedSwitch.primaryFeed];
    
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
    updateCurrentEventInfoTimer = nil;
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


//         self.videoPlayer = globals.VIDEO_PLAYER_LIVE2BENCH;
         self.videoPlayer.antiFreeze.enable = YES;   //RICHARD
         [self.videoPlayer.view setFrame:CGRectMake((self.view.bounds.size.width - MEDIA_PLAYER_WIDTH)/2, 100.0f, MEDIA_PLAYER_WIDTH, MEDIA_PLAYER_HEIGHT)];

         [self.view addSubview:self.videoPlayer.view];
        [_videoBarViewController viewDidAppear:animated];
         
        [videoPlayer play];

         
         //add swipe gesture: swipe left: seek back ; swipe right: seek forward
         UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(detectSwipe:)];
         [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
//         [self.videoPlayer.view addGestureRecognizer:recognizer];
         
         recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(detectSwipe:)];
         [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
//         [self.videoPlayer.view addGestureRecognizer:recognizer];
         
     }
    [self.videoPlayer.view setUserInteractionEnabled:TRUE];
     [self createTagButtons]; // temp place
   
    //1.first time open the app, initialize all the buttons; 2.when received memory warning, all the UIview will be deleted, so when back to live2bench view, we need to reinitialize all the buttons
    if(!self.didInitLayout)
    {
        [self initialiseLayout];
        [self updateEventInformation];

    }
    
    [self.view bringSubviewToFront:self.playerCollectionViewController.view];
    

    //1.when playing live event, if encoder status is not live or paused or player status is not "readytoplay"; 2. there is no event playing: disable all tag buttons
    if((((![globals.CURRENT_ENC_STATUS isEqualToString:encStateLive] && ![globals.CURRENT_ENC_STATUS isEqualToString:encStatePaused])|| (int)[[[videoPlayer avPlayer]currentItem]status] == AVPlayerItemStatusFailed || (int)[[[videoPlayer avPlayer]currentItem]status] == AVPlayerItemStatusUnknown) && ([globals.EVENT_NAME isEqualToString:@"live"]|| [globals.EVENT_NAME isEqualToString:@""])))
    {
        [self.leftSideButtons setUserInteractionEnabled:FALSE];
        [self.leftSideButtons setAlpha:0.6f];
        [self.rightSideButtons setUserInteractionEnabled:FALSE];
        [self.rightSideButtons setAlpha:0.6f];
        
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

    if (globals.UNCLOSED_EVENT || [_eventType isEqualToString:@"football training"]) {
        [self highlightDurationTag];
    }
    
  


    
}



-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self onEventChange];
//    [_videoBarViewController viewDidAppear:animated];
   // [_fullscreenViewController viewDidAppear:animated];
    [self.view addSubview:_fullscreenViewController.view];
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
        
        if ((int)[[[videoPlayer avPlayer]currentItem]status] == 0) {
            
            //playerStatus = @"avplayerUnknown";
            if (![globals.CURRENT_PLAYBACK_EVENT isEqualToString:@""]) {
                poorSignalCounter++;
            }
            
            //if the video is not playing properly in 60 secs, remove the spinnerView and pop up a alert that video playback failed
            if (!videoPlaybackFailedAlertView && [globals.CURRENT_ENC_STATUS isEqualToString:encStateLive] && poorSignalCounter > 9 && !globals.VIDEO_PLAYBACK_FAILED) {
                //reset video player every 10 seconds for 6 times
                if (poorSignalCounter > 0 && poorSignalCounter%10 == 0) {
                    
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
                    
                    [self.videoPlayer setVideoURL:videoURL];
                    [self.videoPlayer setPlayerWithURL:videoURL];
                    

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
//        _liveButton.enabled = YES;
                [_liveButton isActive:YES];
    }else{
//         _liveButton.enabled = NO;
                [_liveButton isActive:NO];
    }
    
    if ([globals.CURRENT_PLAYBACK_EVENT isEqualToString:@""]){ 
        //if no event playing, leave the bottom view blank
        [self.hockeyBottomViewController.view setHidden:TRUE];
        [self.soccerBottomViewController.view setHidden:TRUE];
    }else{
        //show record button if playing live game
        if ([globals.EVENT_NAME isEqualToString:@"live"]){
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
        float tagTime;
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
                tagTime = [[oneTag objectForKey:@"time"] floatValue];
//                [self markTagAtTime:tagTime colour:tagColour tagID:[NSString stringWithFormat:@"%@",[oneTag objectForKey:@"id"]]];
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

    //if a tag is playing currently, update the position of the currentPlayingEventMarker(small orange triangle) according to the lead tagmarker's position
    if (globals.IS_LOOP_MODE) {
        
        //NOTE: [NSString stringWithFormat:@"%@",[globals.CURRENT_PLAYBACK_TAG objectForKey:@"id"]] is very important for a key value of a dictionary, otherwise currentPlayingTagMarker will be nil value
        TagMarker *currentPlayingTagMarker = [globals.TAG_MARKER_OBJ_DICT objectForKey:[NSString stringWithFormat:@"%@",[globals.CURRENT_PLAYBACK_TAG objectForKey:@"id"]]];
        CGRect oldFrame = self.currentPlayingEventMarker.frame;
        [self.currentPlayingEventMarker setFrame:CGRectMake(currentPlayingTagMarker.leadTag.xValue -7, oldFrame.origin.y,oldFrame.size.width, oldFrame.size.height)];
        self.currentPlayingEventMarker.hidden = FALSE;

    }
  
    // Richard
    [_videoBarViewController update];
    
    
}

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
    [self.currentPlayingEventMarker setHidden:TRUE];
    [self.continuePlayButton setHidden:TRUE];
    //remove the telestration overlay
    if(telestrationOverlay)
    {
        [telestrationOverlay removeFromSuperview];
        telestrationOverlay = nil;
    }
    //if is in fullscreen, remove buttons for loop mode and create buttons for normal mode
    if (videoPlayer.isFullScreen && globals.IS_LOOP_MODE) {
        [self removeFullScreenOverlayButtonsinLoopMode];
        [self createFullScreenOverlayButtons];
    }
    
    globals.IS_LOOP_MODE = FALSE;
}


-(void)viewWillDisappear:(BOOL)animated
{
   
    // If current event is not live... pause it
    
    //will leaving live2bench view,pause video
    if (globals.CURRENT_PLAYBACK_EVENT && ![globals.CURRENT_PLAYBACK_EVENT isEqualToString:@""]) {
        [videoPlayer pause];
        if (videoPlayer.timeObserver) [videoPlayer removePlayerItemTimeObserver];
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
    
    
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SMALLSCREEN object:self userInfo:@{@"context":videoPlayer.context,@"animated":[NSNumber numberWithBool:NO]}];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//    [globals.ARRAY_OF_POPUP_ALERT_VIEWS removeObject:alertView];
    [CustomAlertView removeAlert:alertView];
}



/**
 *  This is run when the Live button is pressed
 */
- (void)goToLive
{
    // Richard
//    [videoPlayer goToLive];
    [_pipController pipsAndVideoPlayerToLive];// ALLL TO LIVE
    
    return;
    
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
    

    
    // ugly if... fix it
    if([globals.EVENT_NAME isEqualToString:@""] ||
       ([globals.EVENT_NAME isEqualToString:@"live"] && (![globals.CURRENT_ENC_STATUS isEqualToString:encStateLive] && ![globals.CURRENT_ENC_STATUS isEqualToString:encStatePaused]))||
       (int)[[[videoPlayer avPlayer]currentItem]status] == AVPlayerItemStatusFailed ||
       (int)[[[videoPlayer avPlayer]currentItem]status] == AVPlayerItemStatusUnknown) {
        
       _tagButtonController.enabled    = YES;
//        _liveButton.enabled             = NO;
                [_liveButton isActive:NO];
    }else{
        _tagButtonController.enabled    = YES;
//        _liveButton.enabled             = YES;
                [_liveButton isActive:YES];
        
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
    
    
    
    CustomButton *button = (CustomButton*)sender;
    
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_TAG_POSTED object:self userInfo:@{
                                                                                                      @"name":button.titleLabel.text,
                                                                                                      @"time":[NSString stringWithFormat:@"%f",videoPlayer.currentTimeInSeconds - videoPlayer.startTime]
                                                                                                      }];
    
    
    return;
    
// The rest of the code is for reference
    
    
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
//                [self markTagAtTime:[tagTime floatValue] colour:[uController colorWithHexString:[globals.ACCOUNT_INFO objectForKey:@"tagColour"]] tagID:[NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]]];
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
        

        
        
        //add televiewcontroller
        self.teleViewController= [[TeleViewController alloc] initWithController:self];
        [self.teleViewController.view setFrame:CGRectMake(0, 55, self.view.frame.size.width,self.view.frame.size.width * 9/16 + 10)];
//        self.teleViewController.clearButton = clearTeleButton;
        [teleButton setHidden:TRUE];
        [rootView addSubview:self.teleViewController.view];


        
        NSURL *videoURL = self.videoPlayer.videoURL;
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
//    [self.view insertSubview:_liveButton aboveSubview:_videoBarViewController.view];
    
    
    _gotoLiveButton = [[LiveButton alloc]initWithFrame:CGRectMake(MEDIA_PLAYER_WIDTH +videoPlayer.view.frame.origin.x+32,PADDING + videoPlayer.view.frame.size.height + 95, 130, LITTLE_ICON_DIMENSIONS)];
    [_gotoLiveButton addTarget:self action:@selector(goToLive) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:_gotoLiveButton aboveSubview:_videoBarViewController.view];
    

    
    
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
    
    [_videoBarViewController setTagName:self.currentEventName];
    _fullscreenViewController.tagEventName.text = self.currentEventName;

     globals.IS_LOOP_MODE = TRUE;
    
    //telestration type = 4
    if([[tag objectForKey:@"type"] intValue]==4)
    {
        //pause video
        [videoPlayer pause];
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
       [videoPlayer play];
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
   
    /* WHAT DOES THIS DO?
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
     *?
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

//This method will be called when the user pinch the player view to fullscreen
-(void)willEnterFullscreen
{

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

    if(globals.IS_IN_LIST_VIEW  == FALSE && globals.IS_IN_BOOKMARK_VIEW ==FALSE){
        if(globals.IS_LOOP_MODE == FALSE){
            [self createFullScreenOverlayButtons];
        }else{
            [self createFullScreenOverlayButtonsinLoopMode];
            if ([[currentPlayingTag objectForKey:@"name"] isEqualToString:@"telestration"]) {
                //IS_VIEW_TELE = TRUE;
                globals.IS_PLAYBACK_TELE = TRUE;
            }else{
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

    //if was in loop mode, remove all the control buttons in fullscreen
    if(globals.IS_LOOP_MODE){
        [self removeFullScreenOverlayButtonsinLoopMode];
        
        //Set the startRangeModifierButton's icon according to the startRangeModifierButtoninFullScreen's accessibilityValue
        //Make sure when switching between fullscreen and normal screen,the buttons' icons and controls are synced
//        NSString *accesibilityString = startRangeModifierButtoninFullScreen.accessibilityValue;
//        NSString *imageName;
//        if ([accesibilityString isEqualToString:@"extend"]) {
//            imageName = @"extendstartsec";
//        }else{
//            imageName = @"subtractstartsec";
//        }
//        [startRangeModifierButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
//        [startRangeModifierButton setAccessibilityValue:accesibilityString];
//        
//        //set the endRangeModifierButton's icon according to the endRangeModifierButtoninFullScreen's accessibilityValue
//        //Make sure when switching between fullscreen and normal screen,the buttons' icons and controls are synced
//        accesibilityString = endRangeModifierButtoninFullScreen.accessibilityValue;
//        if ([accesibilityString isEqualToString:@"extend"]) {
//            imageName = @"extendendsec";
//        }else{
//            imageName = @"subtractendsec";
//        }
//        [endRangeModifierButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
//        [endRangeModifierButton setAccessibilityValue:accesibilityString];

    }
}

-(void)createFullScreenOverlayButtonsinLoopMode
{
    
//    //5s duration extension button
//    startRangeModifierButtoninFullScreen = [CustomButton buttonWithType:UIButtonTypeCustom];
//    [startRangeModifierButtoninFullScreen setContentMode:UIViewContentModeScaleAspectFill];
//    [startRangeModifierButtoninFullScreen setTag:0];
//    NSString *accesibilityString = startRangeModifierButton.accessibilityValue;
//    NSString *imageName;
//    if ([accesibilityString isEqualToString:@"extend"]) {
//        imageName = @"extendstartsec";
//    }else{
//        imageName = @"subtractstartsec";
//    }
//    [startRangeModifierButtoninFullScreen setImage:[UIImage imageNamed: imageName] forState:UIControlStateNormal];
//    [startRangeModifierButtoninFullScreen addTarget:self action:@selector(startRangeBeenModified:) forControlEvents:UIControlEventTouchUpInside];
//    CGRect screenRect = [[UIScreen mainScreen] bounds];
//    startRangeModifierButtoninFullScreen.frame = CGRectMake(2*CONTROL_SPACER_X-20,screenRect.size.width - 2*CONTROL_SPACER_Y+25 ,65 ,65);
//    [startRangeModifierButtoninFullScreen setAccessibilityValue:accesibilityString];
//    
//    //added long press gesture to switch icons between extension icon and substraction icon
//    UILongPressGestureRecognizer *modifiedTagDurationByStartTimeLongpressgesture = [[UILongPressGestureRecognizer alloc]
//                                                                                  initWithTarget:self action:@selector(changeDurationModifierButtonIcon:)];
//    modifiedTagDurationByStartTimeLongpressgesture.minimumPressDuration = 0.5; //seconds
//    modifiedTagDurationByStartTimeLongpressgesture.delegate = self;
//    [startRangeModifierButtoninFullScreen addGestureRecognizer:modifiedTagDurationByStartTimeLongpressgesture];
//    
//    //5s duration extension button
//    endRangeModifierButtoninFullScreen= [CustomButton buttonWithType:UIButtonTypeCustom];
//    [endRangeModifierButtoninFullScreen setContentMode:UIViewContentModeScaleAspectFill];
//    [endRangeModifierButtoninFullScreen setTag:1];
//    
//    accesibilityString = endRangeModifierButton.accessibilityValue;
//    if ([accesibilityString isEqualToString:@"extend"]) {
//        imageName = @"extendendsec";
//    }else{
//        imageName = @"subtractendsec";
//    }
//
//    [endRangeModifierButtoninFullScreen setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
//    [endRangeModifierButtoninFullScreen addTarget:self action:@selector(endRangeBeenModified:) forControlEvents:UIControlEventTouchUpInside];
//    endRangeModifierButtoninFullScreen.frame = CGRectMake(screenRect.size.height-(2*CONTROL_SPACER_X)-45,screenRect.size.width -2*CONTROL_SPACER_Y+25,65 ,65);
//    [endRangeModifierButtoninFullScreen setAccessibilityValue:accesibilityString];
//    
    //added long press gesture to switch icons between extension icon and substraction icon
    UILongPressGestureRecognizer *modifiedTagDurationByEndTimeLongpressgesture = [[UILongPressGestureRecognizer alloc]
                                                                                initWithTarget:self action:@selector(changeDurationModifierButtonIcon:)];
    modifiedTagDurationByEndTimeLongpressgesture.minimumPressDuration = 0.5; //seconds
    modifiedTagDurationByEndTimeLongpressgesture.delegate = self;
   // [endRangeModifierButtoninFullScreen addGestureRecognizer:modifiedTagDurationByEndTimeLongpressgesture];
    
    //for testing. Telestartion
  
//    timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(CONTROL_SPACER_X-35,TOTAL_WIDTH/4.0 - 150, LITTLE_ICON_DIMENSIONS + 90, LITTLE_ICON_DIMENSIONS-10)];
//    [timeLabel setText:[NSString stringWithFormat:@"%f",[videoPlayer currentTimeInSeconds]]];
//    [timeLabel setBackgroundColor:[UIColor orangeColor]];
//    [timeLabel setFont:[UIFont boldSystemFontOfSize:20.f]];
//    [timeLabel setTextAlignment:NSTextAlignmentCenter];
  
    //init button to view telestration
    viewTeleButtoninFullScreen = [BorderButton buttonWithType:UIButtonTypeCustom];
    [viewTeleButtoninFullScreen setFrame:CGRectMake(900,60, 130, LITTLE_ICON_DIMENSIONS)];
    [viewTeleButtoninFullScreen setTitle:@"View Tele" forState:UIControlStateNormal];
    [viewTeleButtoninFullScreen addTarget:self action:@selector(viewTele:) forControlEvents:UIControlEventTouchUpInside];
    if (!globals.LATEST_TELE || [[globals.CURRENT_PLAYBACK_TAG objectForKey:@"type"]intValue] == 4) {
        viewTeleButtoninFullScreen.hidden = TRUE;
    }
    
//    [self.overlayItems addObject:startRangeModifierButtoninFullScreen];
//    [self.overlayItems addObject:endRangeModifierButtoninFullScreen];
    [self.overlayItems addObject:viewTeleButtoninFullScreen];
    
    UIView *fullScreenView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
//    [fullScreenView  addSubview:startRangeModifierButtoninFullScreen];
//    [fullScreenView  addSubview:endRangeModifierButtoninFullScreen];
 
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
//    [startRangeModifierButtoninFullScreen removeFromSuperview];
//    [endRangeModifierButtoninFullScreen removeFromSuperview];
    [viewTeleButtoninFullScreen removeFromSuperview];
}

//The method will be called when telestration button is pressed
//hide all the fullscreen control buttons
-(void)hideFullScreenOverlayButtons{
    if (globals.IS_LOOP_MODE) {
//        [startRangeModifierButtoninFullScreen setAlpha:0.0];
//        [endRangeModifierButtoninFullScreen setAlpha:0.0];
     
    }
    
    [playbackRateBackButton setHidden:TRUE];
    [playbackRateBackLabel setHidden:TRUE];
    [playbackRateBackGuide setHidden:TRUE];
    [playbackRateForwardButton setHidden:TRUE];
    [playbackRateForwardLabel setHidden:TRUE];
    [playbackRateForwardGuide setHidden:TRUE];
    [viewTeleButtoninFullScreen setHidden:TRUE];

}

//The method will be called when the save/clear button is pressed
//save button and clear button for telestration will be removed
//show all the fullscreen control buttons
-(void)showFullScreenOverlayButtons{
    
    if (globals.IS_LOOP_MODE) {
//        [startRangeModifierButtoninFullScreen setAlpha:1.0];
//        [endRangeModifierButtoninFullScreen setAlpha:1.0];

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
    
    
}

//When enter full screen, create all fullscreen control buttons
-(void)createFullScreenOverlayButtons{
    
    //create left and right event buttons
    [self createOverlayTags];
    
    
    //for testing
//    timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(CONTROL_SPACER_X -50,CONTROL_SPACER_Y + 150,165 ,50)];
//    [timeLabel setText:[NSString stringWithFormat:@"%f",[videoPlayer currentTimeInSeconds]]];
//    [timeLabel setBackgroundColor:[UIColor orangeColor]];
//    [timeLabel setFont:[UIFont boldSystemFontOfSize:20.f]];
//    [timeLabel setTextAlignment:NSTextAlignmentCenter];
    
    if ( (int)[[[videoPlayer avPlayer]currentItem]status] == AVPlayerItemStatusFailed || (int)[[[videoPlayer avPlayer]currentItem]status] == AVPlayerItemStatusUnknown || [globals.EVENT_NAME isEqualToString:@""] )
    {
        if (![globals.CURRENT_ENC_STATUS isEqualToString:encStateLive]){
    
        }
        
        [teleButton setUserInteractionEnabled:FALSE];
        [teleButton setAlpha:0.6];
    }else{
        if ([globals.CURRENT_ENC_STATUS isEqualToString:encStateLive]){
     
        }else{
       

        }
     
        [teleButton setUserInteractionEnabled:TRUE];
        [teleButton setAlpha:1.0];
    }
    
    //init button to view telestration
    viewTeleButtoninFullScreen = [BorderButton buttonWithType:UIButtonTypeCustom];
    [viewTeleButtoninFullScreen setFrame:CGRectMake(900,60, 130, LITTLE_ICON_DIMENSIONS)];
    [viewTeleButtoninFullScreen setTitle:@"View Tele" forState:UIControlStateNormal];
    [viewTeleButtoninFullScreen addTarget:self action:@selector(viewTele:) forControlEvents:UIControlEventTouchUpInside];
    if (!globals.LATEST_TELE || [[globals.CURRENT_PLAYBACK_TAG objectForKey:@"type"]intValue] == 4) {
        viewTeleButtoninFullScreen.hidden = TRUE;
    }
    
 
    
    [self.overlayItems addObject:viewTeleButtoninFullScreen];

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

