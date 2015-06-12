
//
//  Live2BenchViewController.m
//  Live2BenchNative
//
//  Created by DEV on 2013-01-21.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "Live2BenchViewController.h"
#import <UIKit/UIKit.h>
#import "EncoderClasses/EncoderManager.h"
#import "UserCenter.h"
#import "Live2BenchTagUIViewController.h"
#import "L2BVideoBarViewController.h"
#import "L2BFullScreenViewController.h"
#import "LiveButton.h"
#import "Pip.h"
#import "PipViewController.h"
#import "FeedSwitchView.h"
#import "Feed.h"
#import "RJLVideoPlayer.h"
#import "MultiPip.h"
#import "CustomAlertView.h"
#import "ReusableBottomViewController.h"
#import "ListPopoverController.h"
#import "EncoderClasses/EncoderProtocol.h"

#define MEDIA_PLAYER_WIDTH    712
#define MEDIA_PLAYER_HEIGHT   400
#define TOTAL_WIDTH          1024
#define TOTAL_HEIGHT          600
#define LITTLE_ICON_DIMENSIONS 40
#define CONTROL_SPACER_X       20
#define CONTROL_SPACER_Y       50
#define PADDING                 5



@implementation Live2BenchViewController{
    ScreenController                    * _externalControlScreen;       // this is for attacked screens
    EncoderManager                      * _encoderManager;              // where all vids/feeds coming from
    UserCenter                          * _userCenter;                  // any userdata from plists
    NSString                            * _eventType;                   // Sport or medical
    LiveButton                          * _gotoLiveButton;              // live button
    L2BVideoBarViewController           * _videoBarViewController;      // player updated control bar
    Live2BenchTagUIViewController       * _tagButtonController;         // side tags
    L2BFullScreenViewController         * _fullscreenViewController;    // fullscreen class to manage all actions in full
    ReusableBottomViewController        * _theBottomViewController;
    PipViewController                   * _pipController;
    Pip                                 * _pip;
    FeedSwitchView                      * _feedSwitch;
    id                                  tagsReadyObserver;
    Event                               * _currentEvent;
    
    // some old stuff
    UILabel                             * durationTagLabel;
    UIButton                            * multiButton;
    UIPinchGestureRecognizer            * pinchGesture;
    UISwipeGestureRecognizer            * swipeGesture;
    
    UILabel                             *informationLabel;
    ListPopoverController               *_teamPick;
    TeleViewController                  * telestration;
    //TemporaryButton
//    UIButton                            *zoomButton;
//    UIButton                            *unZoomButton;
    
     NSObject <EncoderProtocol>  *eventOnPrimaryEncoder;
    
    BOOL        needDelete;
    
    id <EncoderProtocol>                _observedEncoder;
    
}

// Context
static void * eventTypeContext  = &eventTypeContext;
static void * eventContext      = &eventContext;


@synthesize videoPlaybackFailedAlertView;


#pragma mark - View Controller Methods

- (id)init
{
    self = [super init];
    if (self) {
        [self setMainSectionTab:NSLocalizedString(@"Live2Bench",nil) imageName:@"live2BenchTab"];
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
    _externalControlScreen  = mainappDelegate.screenController;
    _encoderManager         = mainappDelegate.encoderManager;
    _eventType              = mainappDelegate.encoderManager.currentEventType;
    _userCenter             = mainappDelegate.userCenter;
    needDelete = true;


    // observers //@"currentEventType"
    [_encoderManager addObserver:self forKeyPath:NSStringFromSelector(@selector(currentEventType))  options:NSKeyValueObservingOptionNew context:&eventTypeContext];
    [_encoderManager addObserver:self forKeyPath:NSStringFromSelector(@selector(currentEvent))      options:NSKeyValueObservingOptionNew context:&eventContext];


    
    self = [super initWithAppDelegate:mainappDelegate];
    if (self) {
        [self setMainSectionTab:NSLocalizedString(@"Live2Bench", nil) imageName:@"live2BenchTab"];
    }
    
    
  
    __block Live2BenchViewController * weakSelf = self;
    tagsReadyObserver = [[NSNotificationCenter defaultCenter]addObserverForName:NOTIF_SIDE_TAGS_READY_FOR_L2B object:nil queue:nil usingBlock:^(NSNotification *note) {
        [weakSelf createTagButtons];
    }];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(addEventObserver:) name:NOTIF_PRIMARY_ENCODER_CHANGE object:nil];
    
    
    //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(gotLiveEvent) name: NOTIF_LIVE_EVENT_FOUND object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(liveEventStopped:) name:NOTIF_LIVE_EVENT_STOPPED object:nil];
    
    //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onEventChange) name:NOTIF_EVENT_CHANGE object:nil];
    
    //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onEventChange) name:NOTIF_COMMAND_VIDEO_PLAYER object:nil];

    //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(oberverForEncoderStatus:)  name:NOTIF_ENCODER_STAT     object:nil];
    
    NSDictionary *theEntireDataDictionary = @{
                                              @"Half":@{@"initializationArray":@[@{@"Name": @"1", @"Value": @"s_00"},
                                                                                 @{@"Name": @"2", @"Value": @"s_01"},
                                                                                 @{@"Name": @"EXTRA", @"Value": @"s_02"},
                                                                                 @{@"Name": @"PS", @"Value": @"s_02"}],
                                                        @"segmentName": @"Half",
                                                        @"segmentQuantity":[NSNumber numberWithInteger:1],
                                                        @"selectedIndex":@[[NSNumber numberWithInt:1]]},
                                              
                                              @" ":@{[NSNumber numberWithInt:0] : @{},
                                                     [NSNumber numberWithInt:1] : @{},
                                                     [NSNumber numberWithInt:2] : @{},
                                                     [NSNumber numberWithInt:3] : @{},
                                                     [NSNumber numberWithInt:4] : @{},
                                                     [NSNumber numberWithInt:5] : @{},},
                                              
                                              @"Zone":@{@"initializationArray":@[@{@"Name": @"OFF.3RD", @"Value": @"s_00"},
                                                                                 @{@"Name": @"MID.3RD", @"Value": @"s_01"},
                                                                                 @{@"Name": @"DEF.3RD", @"Value": @"s_02"},],
                                                        @"segmentName": @"Zone",
                                                        @"segmentQuantity":[NSNumber numberWithInteger:1],
                                                        @"selectedIndex":@[[NSNumber numberWithInt:1]]}
                                              };
    
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"SoccerBottomViewController" ofType:@"plist"];
    NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserverForName:@"BottomViewControllerInit" object:nil queue:nil usingBlock:^(NSNotification *notification)
     {
         void(^initBottomViewController)(NSDictionary *dataDictionary, NSDictionary *plistDictionary);
         initBottomViewController = notification.userInfo[@"Block"];
         initBottomViewController(theEntireDataDictionary, nil );
     }];
    
    
    [center addObserverForName:@"BottomViewControllerInit" object:nil queue:nil usingBlock:^(NSNotification *notification)
     {
         void(^initBottomViewController)(NSDictionary *dataDictionary, NSDictionary *plistDictionary);
         initBottomViewController = notification.userInfo[@"Block"];
         initBottomViewController(nil, plistDictionary);
     }];
    
    [center addObserverForName:NOTIF_EVENT_FEEDS_READY object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self restartPlayer];
        //[self createTagButtons];
    }];
    
    
    
    informationLabel = [[UILabel alloc] initWithFrame:CGRectMake(156, 50, MEDIA_PLAYER_WIDTH, 50)];
    [informationLabel setTextAlignment:NSTextAlignmentRight];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"UpdateInfoLabel" object:nil queue:nil usingBlock:^(NSNotification *note){
        NSString *content = [NSString stringWithFormat:@"%@ - Tagging team: %@", note.userInfo[@"info"], _appDel.userCenter.userPick];
        [informationLabel setText:content];
    }];
    [self.view addSubview:informationLabel];
    
    return self;
}

-(void)addEventObserver:(NSNotification*)note
{
    if (_observedEncoder)    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_EVENT_CHANGE object:_observedEncoder];
    _observedEncoder = (id <EncoderProtocol>) note.object;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(eventChanged:) name:NOTIF_EVENT_CHANGE object:_observedEncoder];

}

-(void)eventChanged:(NSNotification*)note
{
    _currentEvent = [((id <EncoderProtocol>) note.object) event];//[_appDel.encoderManager.primaryEncoder event];
    [_videoBarViewController onEventChanged:_currentEvent];
    [self onEventChange];
    if (_currentEvent.live) {
        [self gotLiveEvent];
    }
}

-(void)liveEventStopped:(NSNotification *)note
{
    if (_currentEvent.live) {
        _currentEvent = nil;
        [self onEventChange];
    }
}

#pragma mark - Swipe Gesture Recognizer methods

-(void)swipeNoticed: (UISwipeGestureRecognizer *) swipeRecognizer{
    switch (swipeRecognizer.direction) {
        case UISwipeGestureRecognizerDirectionUp:
            if ([UIScreen screens].count > 1) {
                [_externalControlScreen moveVideoToExternalDisplay: self.videoPlayer];
                swipeGesture.direction = UISwipeGestureRecognizerDirectionDown;
            }
            break;
        case UISwipeGestureRecognizerDirectionDown:
            [_externalControlScreen returnVideoToPreviousViewFromExternal];
            swipeGesture.direction = UISwipeGestureRecognizerDirectionUp;
            break;
        default:
            break;
    }
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

/*-(void)removething{
    
    if (needDelete) {
        needDelete = false;
        [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_COMMAND_VIDEO_PLAYER object:nil];
    }
    
}*/

/*-(void)oberverForEncoderStatus:(NSNotification *)note
{
    Encoder * encoder = (Encoder * )note.object;
    switch (encoder.status) {
        case ENCODER_STATUS_READY:
                _encoderManager.masterEncoder.liveEvent = nil;
                [self onEventChange];
            break;
        case ENCODER_STATUS_SHUTDOWN:
                _encoderManager.masterEncoder.liveEvent = nil;
                [self onEventChange];
            break;
        default:
            break;
    }
}*/

-(void)onEventChange
{
    if (_appDel.encoderManager.liveEvent != nil){
        [_videoBarViewController setBarMode:L2B_VIDEO_BAR_MODE_LIVE];
        [_fullscreenViewController setMode:L2B_FULLSCREEN_MODE_LIVE];
        self.videoPlayer.live = YES;
        [_gotoLiveButton isActive:YES];
        _tagButtonController.enabled = YES;
    }
    else if (_currentEvent != nil){
        [_videoBarViewController setBarMode: L2B_VIDEO_BAR_MODE_LIVE];
        [_fullscreenViewController setMode: L2B_FULLSCREEN_MODE_EVENT];
        self.videoPlayer.live = NO;
        [_gotoLiveButton isActive:NO];
        _tagButtonController.enabled = YES;
    }
    else if (_currentEvent == nil){
        [_videoBarViewController setBarMode: L2B_VIDEO_BAR_MODE_DISABLE];
        [_fullscreenViewController setMode: L2B_FULLSCREEN_MODE_DISABLE];
        self.videoPlayer.live = NO;
        [_gotoLiveButton isActive:NO];
        _tagButtonController.enabled = NO;
        [self.videoPlayer clear];
        [informationLabel setText:@""];
    }
    [multiButton setHidden:!([_encoderManager.feeds count]>1)];
}



// when the event changes mod these
/*-(void)onEventChange
{
    eventOnPrimaryEncoder = _encoderManager.primaryEncoder;
    
    if (eventOnPrimaryEncoder == nil) {
        return;
    }
   
    if (eventOnPrimaryEncoder.event.live && _encoderManager.masterEncoder.liveEvent == nil) {
        eventOnPrimaryEncoder.event = nil;
    }
    
    if (_encoderManager.masterEncoder.liveEvent != nil){
        [_videoBarViewController setBarMode:L2B_VIDEO_BAR_MODE_LIVE];
        [_fullscreenViewController setMode:L2B_FULLSCREEN_MODE_LIVE];
        [_gotoLiveButton isActive:YES];
        _tagButtonController.enabled = YES;
    }
    else if (eventOnPrimaryEncoder.event != nil){
        [self removething];
        [_videoBarViewController setBarMode: L2B_VIDEO_BAR_MODE_LIVE];
        [_fullscreenViewController setMode: L2B_FULLSCREEN_MODE_EVENT];
        self.videoPlayer.live = NO;
        [_gotoLiveButton isActive:NO];
        _tagButtonController.enabled = YES;
    }
    else if(_encoderManager.masterEncoder.event != nil){
        [_videoBarViewController setBarMode: L2B_VIDEO_BAR_MODE_LIVE];
        [_fullscreenViewController setMode: L2B_FULLSCREEN_MODE_EVENT];
        self.videoPlayer.live = NO;
        [_gotoLiveButton isActive:NO];
        _tagButtonController.enabled = YES;
    }
    else if (eventOnPrimaryEncoder.event == nil  && _encoderManager.masterEncoder.liveEvent == nil){
        [_videoBarViewController setBarMode: L2B_VIDEO_BAR_MODE_DISABLE];
        [_fullscreenViewController setMode: L2B_FULLSCREEN_MODE_DISABLE];
        self.videoPlayer.live = NO;
        [_gotoLiveButton isActive:NO];
        _tagButtonController.enabled = NO;
        [self.videoPlayer clear];
        [informationLabel setText:@""];
    }
    
    
    [multiButton setHidden:!([_encoderManager.feeds count]>1)];
}*/

-(void)gotLiveEvent
{
        Feed *info = [_currentEvent.feeds allValues] [0];
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_COMMAND_VIDEO_PLAYER object:nil userInfo:@{@"feed":info ,  @"command": [NSNumber numberWithInt:VideoPlayerCommandPlayFeed], @"context":STRING_LIVE2BENCH_CONTEXT}];
    
        _teamPick = [[ListPopoverController alloc] initWithMessage:NSLocalizedString(@"Please select the team you want to tag:", @"dev comment - asking user to pick a team") buttonListNames:@[_currentEvent.rawData[@"homeTeam"], _currentEvent.rawData[@"visitTeam"]]];
    
        [_teamPick addOnCompletionBlock:^(NSString *pick){
            [[NSNotificationCenter defaultCenter]postNotificationName: NOTIF_USER_CENTER_UPDATE  object:nil userInfo:@{@"userPick":pick}];
            [[NSNotificationCenter defaultCenter]postNotificationName: NOTIF_SELECT_TAB          object:nil
                                                             userInfo:@{@"tabName":@"Live2Bench"}];
            
            NSString *info = @"Live";
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateInfoLabel" object:nil userInfo:@{@"info":info}];
        }];
        [_teamPick presentPopoverCenteredIn:[UIApplication sharedApplication].keyWindow.rootViewController.view
                                   animated:YES];
        
        [_pipController pipsAndVideoPlayerToLive:info];
        [_videoBarViewController.tagMarkerController cleanTagMarkers];
        [_videoBarViewController.tagMarkerController createTagMarkers];
    
}

/*-(void)gotLiveEvent
{
    if (_encoderManager.primaryEncoder == nil) {
        _encoderManager.primaryEncoder = _encoderManager.masterEncoder;
    }
    eventOnPrimaryEncoder = _encoderManager.primaryEncoder;
   if (eventOnPrimaryEncoder.event == _encoderManager.masterEncoder.liveEvent) {
        _appDel.encoderManager.primaryEncoder = _appDel.encoderManager.masterEncoder;
        eventOnPrimaryEncoder = _encoderManager.primaryEncoder;
        
        Feed *info = [_appDel.encoderManager.masterEncoder.liveEvent.feeds allValues] [0];
       [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_COMMAND_VIDEO_PLAYER object:nil userInfo:@{@"feed":info ,  @"command": [NSNumber numberWithInt:VideoPlayerCommandPlayFeed], @"context":STRING_LIVE2BENCH_CONTEXT}];
       
        Event *liveEvent = [_appDel.encoderManager getEventByName:_appDel.encoderManager.liveEventName];
        _teamPick = [[ListPopoverController alloc] initWithMessage:NSLocalizedString(@"Please select the team you want to tag:", @"dev comment - asking user to pick a team") buttonListNames:@[liveEvent.rawData[@"homeTeam"], liveEvent.rawData[@"visitTeam"]]];
        [_teamPick addOnCompletionBlock:^(NSString *pick){
            [[NSNotificationCenter defaultCenter]postNotificationName: NOTIF_USER_CENTER_UPDATE  object:nil userInfo:@{@"userPick":pick}];
            [[NSNotificationCenter defaultCenter]postNotificationName: NOTIF_SELECT_TAB          object:nil
                                                             userInfo:@{@"tabName":@"Live2Bench"}];
            
            NSString *info = @"Live";
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateInfoLabel" object:nil userInfo:@{@"info":info}];
        }];
        [_teamPick presentPopoverCenteredIn:[UIApplication sharedApplication].keyWindow.rootViewController.view
                                   animated:YES];
       
       [_pipController pipsAndVideoPlayerToLive:info];
       [_videoBarViewController.tagMarkerController cleanTagMarkers];
       [_videoBarViewController.tagMarkerController createTagMarkers];
   }
    
}*/

#pragma mark -
#pragma mark Gesture

//this method will be triggered if user pinches the video view. Based on the pinch velocity, will enter full screen or back to normal screen
- (void)handlePinchGuesture:(UIGestureRecognizer *)recognizer{
    
    if((pinchGesture.velocity > 0.5 || pinchGesture.velocity < -0.5) && pinchGesture.numberOfTouches == 2){
        if (CGRectContainsPoint(self.view.bounds, [pinchGesture locationInView:self.view]))
        {
            
            if (pinchGesture.scale >1) {
                _fullscreenViewController.enable = YES;
                [_pipController.multi fullScreen];
//                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_FULLSCREEN object:self userInfo:@{@"context":_context,@"animated":[NSNumber numberWithBool:YES]}];
            }else if (pinchGesture.scale < 1){
                [telestration forceCloseTele];
                _fullscreenViewController.enable = NO;
                [_pipController.multi normalScreen];
//                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SMALLSCREEN object:self userInfo:@{@"context":_context,@"animated":[NSNumber numberWithBool:YES]}];
            }
        }
        return;
    }
    
}


#pragma mark -
#pragma mark Normal Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    ReusableBottomViewController *bottomViewController = [[ReusableBottomViewController alloc] init];
    [self.view addSubview:bottomViewController.view];
    _theBottomViewController = bottomViewController;

    //label to show current event title
    currentEventTitle                   = [[UILabel alloc] initWithFrame:CGRectMake(156.0f, 71.0f, MEDIA_PLAYER_WIDTH, 21.0f)];
    currentEventTitle.textAlignment     = NSTextAlignmentRight;
    currentEventTitle.textColor         = [UIColor darkGrayColor];
    currentEventTitle.font              = [UIFont fontWithName:@"trebuchet" size:17.0f];
    currentEventTitle.backgroundColor   = [UIColor clearColor];
    currentEventTitle.autoresizingMask  = UIViewAutoresizingFlexibleRightMargin;

    [self.view addSubview:currentEventTitle];
    
    //create all the event tag buttons
    //[self createTagButtons];

    //__block Live2BenchViewController * weakSelf = self;
    //tagsReadyObserver =
    /*[[NSNotificationCenter defaultCenter]addObserverForName:NOTIF_SIDE_TAGS_READY_FOR_L2B object:nil queue:nil usingBlock:^(NSNotification *note) {
        [weakSelf createTagButtons];
    }];*/
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:NOTIF_EVENT_FEEDS_READY object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self restartPlayer];
        //[self createTagButtons];
    }];
    
    
    self.videoPlayer = [[RJLVideoPlayer alloc] initWithFrame:CGRectMake(156, 100, MEDIA_PLAYER_WIDTH, MEDIA_PLAYER_HEIGHT)];
    telestration = [[TeleViewController alloc]initWithController:self.videoPlayer];
    telestration.delegate = self;

    
    pinchGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinchGuesture:)];
    [self.view addGestureRecognizer:pinchGesture];
    
    swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeNoticed:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionUp;
    swipeGesture.numberOfTouchesRequired = 3;
    [self.videoPlayer.view addGestureRecognizer: swipeGesture];
    [[((RJLVideoPlayer *)self.videoPlayer).zoomManager panGestureRecognizer] requireGestureRecognizerToFail: swipeGesture];
    
    
    
    
    // Richard
    
    _videoBarViewController = [[L2BVideoBarViewController alloc]initWithVideoPlayer:self.videoPlayer];
    [_videoBarViewController setBarMode:L2B_VIDEO_BAR_MODE_DISABLE];
    [_videoBarViewController.startRangeModifierButton   addTarget:self action:@selector(startRangeBeenModified:) forControlEvents:UIControlEventTouchUpInside];
    [_videoBarViewController.endRangeModifierButton     addTarget:self action:@selector(endRangeBeenModified:) forControlEvents:UIControlEventTouchUpInside];
    //_videoBarViewController.tagMarkerController.arrayOfAllTags =
    [self.view addSubview:_videoBarViewController.view];

    _fullscreenViewController = [[L2BFullScreenViewController alloc]initWithVideoPlayer:self.videoPlayer];
    _fullscreenViewController.context = STRING_LIVE2BENCH_CONTEXT;
    [_fullscreenViewController.continuePlay     addTarget:self action:@selector(continuePlay)   forControlEvents:UIControlEventTouchUpInside];
    [_fullscreenViewController.liveButton       addTarget:self action:@selector(goToLive)       forControlEvents:UIControlEventTouchUpInside];
//    [_fullscreenViewController.teleButton       addTarget:self action:@selector(initTele:)      forControlEvents:UIControlEventTouchUpInside];
    _fullscreenViewController.teleViewController =telestration;

    self.videoPlayer.playerContext = STRING_LIVE2BENCH_CONTEXT;
    
    //[_fullscreenViewController setMode: L2B_FULLSCREEN_MODE_DEMO];
    // so get buttons are connected to full screen
   

    _pip            = [[Pip alloc]initWithFrame:CGRectMake(50, 50, 200, 150)];
    _pip.isDragAble  = YES;
    _pip.hidden      = YES;
    _pip.muted       = YES;
    _pip.dragBounds  = self.videoPlayer.view.frame;
    [self.videoPlayer.view addSubview:_pip];
    
    _feedSwitch     = [[FeedSwitchView alloc]initWithFrame:CGRectMake(156+100, 59, 100, 38) encoderManager:_encoderManager];
    
    _pipController  = [[PipViewController alloc]initWithVideoPlayer:self.videoPlayer f:_feedSwitch encoderManager:_encoderManager];
    _pipController.context = STRING_LIVE2BENCH_CONTEXT;
    _pipController.videoControlBar = _videoBarViewController;
    [_pipController addPip:_pip];
    [_pipController viewDidLoad];
    [self.view addSubview:_feedSwitch];
    
    // multi button
    multiButton =[[UIButton alloc]initWithFrame:CGRectMake(156, 59, 100, 38)];
    [multiButton setTitle:NSLocalizedString(@"Multi",nil) forState:UIControlStateNormal];
    [multiButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [multiButton addTarget:_pipController action:@selector(onButtonPressMulti:) forControlEvents:UIControlEventTouchUpInside];
    multiButton.layer.borderWidth = 1;
    [self.view addSubview:multiButton];
    [multiButton setHidden:!([_encoderManager.feeds count]>1)];
    
    _gotoLiveButton = [[LiveButton alloc]initWithFrame:CGRectMake(MEDIA_PLAYER_WIDTH +self.videoPlayer.view.frame.origin.x+32,PADDING + self.videoPlayer.view.frame.size.height + 95, 130, LITTLE_ICON_DIMENSIONS)];
    [_gotoLiveButton addTarget:self action:@selector(goToLive) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_gotoLiveButton];
        [_gotoLiveButton isActive:NO];
   //  [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(masterLost:)               name:NOTIF_ENCODER_MASTER_HAS_FALLEN object:nil];
    
    
    ((RJLVideoPlayer *)self.videoPlayer).zoomManager.viewsToAvoid = _pipController.pips;
    
    
//    zoomButton = [[UIButton alloc]initWithFrame:CGRectMake(50, 600, 100, 50)];
//    [zoomButton addTarget:self action:@selector(zoomPressed) forControlEvents:UIControlEventTouchUpInside];
//    zoomButton.backgroundColor = [UIColor redColor];
//    [self.view addSubview: zoomButton];
//    
//    unZoomButton = [[UIButton alloc]initWithFrame:CGRectMake(250, 600, 100, 50)];
//    [unZoomButton addTarget:self action:@selector(unZoomPressed) forControlEvents:UIControlEventTouchUpInside];
//    unZoomButton.backgroundColor = [UIColor blueColor];
//    [self.view addSubview: unZoomButton];
}

//-(void) zoomPressed{
//    [_externalControlScreen returnVideoToPreviousViewFromExternal];
//    //RJLVideoPlayer *videoPlayer = (RJLVideoPlayer *)self.videoPlayer;
//    //[videoPlayer zoomIntoView: CGRectMake(20, 30, 300, 300)];
//}
//
//-(void) unZoomPressed{
//    [_externalControlScreen moveVideoToExternalDisplay: self.videoPlayer];
////    RJLVideoPlayer *videoPlayer = (RJLVideoPlayer *)self.videoPlayer;
////    [videoPlayer zoomIntoView: CGRectMake(0, 0, MEDIA_PLAYER_WIDTH, MEDIA_PLAYER_HEIGHT)];
//}




-(void)onOpenTeleView:(TeleViewController *)tvc
{
    [self.videoPlayer pause];
    self.videoPlayer.videoControlBar.hidden = YES;
    [_fullscreenViewController setMode:L2BFullScreenModeTele];
}


-(void)onCloseTeleView:(TeleViewController *)tvc
{

    
    [self.videoPlayer play];
    self.videoPlayer.videoControlBar.hidden = NO;
    [_fullscreenViewController setMode:_fullscreenViewController.prevMode];
    
}

/**
 *  This is run when the Main Encoder is removed
 *
 *  @param note
 */
/*-(void)masterLost:(NSNotification*)note
{
    if (_encoderManager.primaryEncoder != _encoderManager.masterEncoder) return;
    
    

    if (_encoderManager.liveEventName == nil  && _encoderManager.currentEvent == nil){
        [self restartPlayer];
        CustomAlertView * alert = [[CustomAlertView alloc]initWithTitle:NSLocalizedString(@"Encoder Status",nil) message:NSLocalizedString(@"Encoder connection lost",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ok",nil) otherButtonTitles:nil, nil];
        [[alert alertType:AlertAll] show];
        
        [multiButton setHidden:!([_encoderManager.feeds count]>1)];
    }
}*/


-(void)viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:animated];

  
    _tagButtonController.fullScreenViewController = _fullscreenViewController;
    
    if (!self.videoPlayer.feed && _encoderManager.currentEvent != nil) {
     [self.videoPlayer playFeed:_feedSwitch.primaryFeed];
    }

//    [currentEventTitle setNeedsDisplay];
    
    
    // maybe this should be part of the videoplayer
     if(!(self.videoPlayer.view.superview == self.view))
     {
         [self.videoPlayer.view setFrame:CGRectMake((self.view.bounds.size.width - MEDIA_PLAYER_WIDTH)/2, 100.0f, MEDIA_PLAYER_WIDTH, MEDIA_PLAYER_HEIGHT)];
         [self.view addSubview:self.videoPlayer.view];
         [_videoBarViewController viewDidAppear:animated];
         
         //[self.videoPlayer play];
         [self.view addSubview:_fullscreenViewController.view];
//         //add swipe gesture: swipe left: seek back ; swipe right: seek forward
//         UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(detectSwipe:)];
//         [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
////         [self.videoPlayer.view addGestureRecognizer:recognizer];
//         
//         recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(detectSwipe:)];
//         [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
////         [self.videoPlayer.view addGestureRecognizer:recognizer];
         
     }

    //[self createTagButtons]; // temp place

    [_videoBarViewController.tagMarkerController cleanTagMarkers];
    [_videoBarViewController.tagMarkerController createTagMarkers];
    
    // just to update UI
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_ENCODER_COUNT_CHANGE object:nil];
    //[[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_ENCODER_FEED_HAVE_CHANGED object:nil];
    self.videoPlayer.mute = NO;

}

-(void)viewWillDisappear:(BOOL)animated
{
    [CustomAlertView removeAll];
    [_videoBarViewController.tagMarkerController cleanTagMarkers];
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SMALLSCREEN object:self userInfo:@{@"context":self.videoPlayer.playerContext,@"animated":[NSNumber numberWithBool:NO]}];
    self.videoPlayer.mute = YES;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//    [globals.ARRAY_OF_POPUP_ALERT_VIEWS removeObject:alertView];
    [CustomAlertView removeAlert:alertView];
}

/**
 *  This sets the video player and all its pip to live
 */

- (void)goToLive
{
    if (_currentEvent.live) {
        Feed *info = [_currentEvent.feeds allValues] [0];
        [_pipController pipsAndVideoPlayerToLive:info];
        [_videoBarViewController.tagMarkerController cleanTagMarkers];
        [_videoBarViewController.tagMarkerController createTagMarkers];
        return;
    }
    
    [_appDel.encoderManager declareCurrentEvent:_appDel.encoderManager.liveEvent];
    
}

/*- (void)goToLive
{
    Feed *info = [_appDel.encoderManager.masterEncoder.liveEvent.feeds allValues] [0];
    if (_appDel.encoderManager.liveEventName == nil) {
        NSLog(@"NO LIVE EVENT");
        return;
    }

    if ([_encoderManager.primaryEncoder event] != _encoderManager.masterEncoder.liveEvent) {
        _encoderManager.primaryEncoder = _encoderManager.masterEncoder;
        _encoderManager.primaryEncoder.event = _encoderManager.masterEncoder.liveEvent;
        Event *liveEvent = [_appDel.encoderManager getEventByName:_appDel.encoderManager.liveEventName];
        
        //info = [_appDel.encoderManager.masterEncoder.liveEvent.feeds allValues] [0];
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_COMMAND_VIDEO_PLAYER object:nil userInfo:@{@"feed":info ,  @"command": [NSNumber numberWithInt:VideoPlayerCommandPlayFeed], @"context":STRING_LIVE2BENCH_CONTEXT}];
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_TAGS_ARE_READY object:nil];
        _teamPick = [[ListPopoverController alloc] initWithMessage:NSLocalizedString(@"Please select the team you want to tag:", @"dev comment - asking user to pick a team") buttonListNames:@[liveEvent.rawData[@"homeTeam"], liveEvent.rawData[@"visitTeam"]]];
        [_teamPick addOnCompletionBlock:^(NSString *pick){
            [[NSNotificationCenter defaultCenter]postNotificationName: NOTIF_USER_CENTER_UPDATE  object:nil userInfo:@{@"userPick":pick}];
            NSString *info = @"Live";
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateInfoLabel" object:nil userInfo:@{@"info":info}];
        }];
        [_teamPick presentPopoverCenteredIn:[UIApplication sharedApplication].keyWindow.rootViewController.view
                                   animated:YES];
        }
     [_videoBarViewController setBarMode:L2B_VIDEO_BAR_MODE_LIVE];
    [_pipController pipsAndVideoPlayerToLive:info];
    [_videoBarViewController.tagMarkerController cleanTagMarkers];
    [_videoBarViewController.tagMarkerController createTagMarkers];

}*/

/**
 *  This creates the side tag buttons from the userCenter
 */
- (void)createTagButtons
{
    [_tagButtonController clear];
    [_tagButtonController.view removeFromSuperview];
    // side tags
    _tagButtonController = [[Live2BenchTagUIViewController alloc]initWithView:self.view];
    [self addChildViewController:_tagButtonController];
    [_tagButtonController didMoveToParentViewController:self];
    _tagButtonController.enabled = NO;
    
    NSArray * tNames = [_userCenter.tagNames copy]; //self.tagNames;
    [_tagButtonController inputTagData:tNames];
    
    //Add Actions
    [_tagButtonController addActionToAllTagButtons:@selector(tagButtonSelected:) addTarget:self forControlEvents:UIControlEventTouchUpInside];
//    if ([_eventType isEqualToString:SPORT_FOOTBALL_TRAINING]) {
//        [_tagButtonController addActionToAllTagButtons:@selector(showFootballTrainingCollection:) addTarget:self forControlEvents:UIControlEventTouchDragOutside];
//    } else {
//        [_tagButtonController addActionToAllTagButtons:@selector(showPlayerCollection:) addTarget:self forControlEvents:UIControlEventTouchDragOutside];
//    }
    _tagButtonController.fullScreenViewController = _fullscreenViewController;
}


//tag button is hit, send the instance to the queue object
// connect to EM to send Nofit
/**
 *  This collects the information of the tapped tab button as then sends the data up to the encoder manager
 *
 *  @param sender Tag button
 */
-(void)tagButtonSelected:(id)sender
{
    CustomButton *button = (CustomButton*)sender;
    
    float currentTime = CMTimeGetSeconds(self.videoPlayer.playerItem.currentTime);// start time minus? //videoPlayer.vie - videoPlayer.startTime
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_TAG_POSTED object:self userInfo:@{
                                                                                                      @"name":button.titleLabel.text,
                                                                                                      @"time":[NSString stringWithFormat:@"%f",currentTime]
                                                                                                      }];
}



-(void)restartPlayer
{
    
//    [self.videoPlayer.view removeFromSuperview];
//    self.videoPlayer                        = nil;
//    self.videoPlayer                        = [[RJLVideoPlayer alloc] initWithFrame:CGRectMake(156, 100, MEDIA_PLAYER_WIDTH, MEDIA_PLAYER_HEIGHT)];
//    self.videoPlayer.playerContext          = STRING_LIVE2BENCH_CONTEXT;
//
//    _pip            = [[Pip alloc]initWithFrame:CGRectMake(50, 50, 200, 150)];
//    _pip.isDragAble  = YES;
//    _pip.hidden      = YES;
//    _pip.muted       = YES;
//    _pip.dragBounds  = self.videoPlayer.view.frame;
//    [self.videoPlayer.view addSubview:_pip];
//    
//    _feedSwitch     = [[FeedSwitchView alloc]initWithFrame:CGRectMake(156+100, 59, 100, 38) encoderManager:_encoderManager];
//    
//    _pipController  = [[PipViewController alloc]initWithVideoPlayer:self.videoPlayer f:_feedSwitch encoderManager:_encoderManager];
//    _pipController.context = STRING_LIVE2BENCH_CONTEXT;
//    
//    [_pipController addPip:_pip];
//    [_pipController viewDidLoad];
//    [self.view addSubview:_feedSwitch];
//
//    
//    _videoBarViewController.videoPlayer     = self.videoPlayer;
//    _pipController.videoPlayer              = self.videoPlayer;
//    _fullscreenViewController.player        = self.videoPlayer;
//
//    [self.videoPlayer.view addSubview:_pip];
//    [self.view addSubview:self.videoPlayer.view];
//    

      //[self.videoPlayer playFeed:_feedSwitch.primaryFeed];
   // [self.videoPlayer playFeed:_feedSwitch.primaryFeed];

//    [self.videoPlayer play];
//    
//    swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeNoticed:)];
//    swipeGesture.direction = UISwipeGestureRecognizerDirectionUp;
//    swipeGesture.numberOfTouchesRequired = 3;
//    [self.videoPlayer.view addGestureRecognizer: swipeGesture];
//    [[((RJLVideoPlayer *)self.videoPlayer).zoomManager panGestureRecognizer] requireGestureRecognizerToFail: swipeGesture];
//    
//    
//    
//    
//    // Richard
//    
//    _videoBarViewController = [[L2BVideoBarViewController alloc]initWithVideoPlayer:self.videoPlayer];
//    [_videoBarViewController setBarMode:L2B_VIDEO_BAR_MODE_DISABLE];
//    [_videoBarViewController.startRangeModifierButton   addTarget:self action:@selector(startRangeBeenModified:) forControlEvents:UIControlEventTouchUpInside];
//    [_videoBarViewController.endRangeModifierButton     addTarget:self action:@selector(endRangeBeenModified:) forControlEvents:UIControlEventTouchUpInside];
//    //_videoBarViewController.tagMarkerController.arrayOfAllTags =
//    [self.view addSubview:_videoBarViewController.view];
//    
////    _fullscreenViewController = [[L2BFullScreenViewController alloc]initWithVideoPlayer:self.videoPlayer];
////    _fullscreenViewController.context = STRING_LIVE2BENCH_CONTEXT;
////   [_fullscreenViewController.continuePlay     addTarget:self action:@selector(continuePlay)   forControlEvents:UIControlEventTouchUpInside];
////   [_fullscreenViewController.liveButton       addTarget:self action:@selector(goToLive)       forControlEvents:UIControlEventTouchUpInside];
//    [_fullscreenViewController.teleButton       addTarget:self action:@selector(initTele:)      forControlEvents:UIControlEventTouchUpInside];
//    
//    
//    //self.videoPlayer.playerContext = STRING_LIVE2BENCH_CONTEXT;
//    
//    [_fullscreenViewController setMode: L2B_FULLSCREEN_MODE_DEMO];
////   // so get buttons are connected to full screen
//    _tagButtonController.fullScreenViewController = _fullscreenViewController;

}


- (void)didReceiveMemoryWarning
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_RECEIVE_MEMORY_WARNING object:self userInfo:nil];
    [super didReceiveMemoryWarning];
}

@end

