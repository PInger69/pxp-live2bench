
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

#import "PxpTelestrationViewController.h"
#import "HockeyBottomViewController.h"
#import "SoccerBottomViewController.h"
#import "RugbyBottomViewController.h"
#import "FootballBottomViewController.h"
#import "FootballTrainingBottomViewController.h"
#import "PxpVideoPlayerProtocol.h"
#import "RJLVideoPlayer.h"
#import "LeagueTeam.h"
#import "BottomViewControllerProtocol.h"
#import "TeamPlayer.h"
#import "ContentViewController.h"

#import "PxpPlayerViewController.h"
#import "PxpPlayerMultiView.h"
#import "PxpEventContext.h"
#import "PxpVideoBar.h"
#import "PxpL2BFullscreenViewController.h"
#import "PxpListViewFullscreenViewController.h"
#import "PxpPlayer+Tag.h"

#define MEDIA_PLAYER_WIDTH    712
#define MEDIA_PLAYER_HEIGHT   400
#define TOTAL_WIDTH          1024
#define TOTAL_HEIGHT          600
#define LITTLE_ICON_DIMENSIONS 40
#define CONTROL_SPACER_X       20
#define CONTROL_SPACER_Y       50
#define PADDING                 5


@interface Live2BenchViewController () <PxpTelestrationViewControllerDelegate, PxpTimeProvider>

@property (strong, nonatomic, nonnull) PxpTelestrationViewController *telestrationViewController;
@property (strong, nonatomic, nonnull) PxpPlayerViewController *playerViewController;
@property (strong, nonatomic, nonnull) PxpL2BFullscreenViewController *fullscreenViewController;

@end


@implementation Live2BenchViewController{
    ScreenController                    * _externalControlScreen;       // this is for attacked screens
    EncoderManager                      * _encoderManager;              // where all vids/feeds coming from
    UserCenter                          * _userCenter;                  // any userdata from plists
    NSString                            * _eventType;                   // Sport or medical
    LiveButton                          * _gotoLiveButton;              // live button
    Live2BenchTagUIViewController       * _tagButtonController;         // side tags
    //ReusableBottomViewController        * _theBottomViewController;
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
    UISwipeGestureRecognizer            * swipeLeftGesture;
    UISwipeGestureRecognizer            * swipeRightGesture;
    UITapGestureRecognizer              * tapGesture;
    
    UILabel                             *informationLabel;
    ListPopoverController               *_teamPick;
    TeleViewController                  * telestration;
    //TemporaryButton
//    UIButton                            *zoomButton;
//    UIButton                            *unZoomButton;
    
     NSObject <EncoderProtocol>  *eventOnPrimaryEncoder;
    
    BOOL        needDelete;
    
    id <EncoderProtocol>                _observedEncoder;
    
    UISwitch                            *durationSwitch;
    
    id <BottomViewControllerProtocol>   _bottomViewController;
    NSArray *playerList;
    NSArray *pickedPlayer;
    
    ContentViewController *_playerDrawerLeft;
    UIImageView *_leftArrow;
    
    ContentViewController *_playerDrawerRight;
    UIImageView *_rightArrow;
    
    PxpVideoBar *_videoBar;
    
    CustomAlertView *eventStopped;
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

    eventStopped = [[CustomAlertView alloc]initWithTitle:@"Event Stopped" message:@"Live Event is stopped" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    
    // observers //@"currentEventType"
    [_encoderManager addObserver:self forKeyPath:NSStringFromSelector(@selector(currentEventType))  options:NSKeyValueObservingOptionNew context:&eventTypeContext];
    [_encoderManager addObserver:self forKeyPath:NSStringFromSelector(@selector(currentEvent))      options:NSKeyValueObservingOptionNew context:&eventContext];


    
    self = [super initWithAppDelegate:mainappDelegate];
    if (self) {
        [self setMainSectionTab:NSLocalizedString(@"Live2Bench", nil) imageName:@"live2BenchTab"];
        
        _playerViewController = [[PxpPlayerViewController alloc] init];
        _fullscreenViewController = [[PxpL2BFullscreenViewController alloc] initWithPlayerViewController:_playerViewController];
        
        _videoBar = [[PxpVideoBar alloc] init];
        
        [self addChildViewController:_playerViewController];
        [self addChildViewController:_fullscreenViewController];
    }
    
    _telestrationViewController = [[PxpTelestrationViewController alloc] init];
  
    __block Live2BenchViewController * weakSelf = self;
    tagsReadyObserver = [[NSNotificationCenter defaultCenter]addObserverForName:NOTIF_SIDE_TAGS_READY_FOR_L2B object:nil queue:nil usingBlock:^(NSNotification *note) {
        [weakSelf createTagButtons];
    }];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(addEventObserver:) name:NOTIF_PRIMARY_ENCODER_CHANGE object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onEventChange) name:NOTIF_LIVE_EVENT_FOUND object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(tabJustBeingAdded:) name:NOTIF_TAB_CREATED object:nil];
    
    //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(gotLiveEvent) name: NOTIF_LIVE_EVENT_FOUND object:nil];
    
    //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onEventChange) name:NOTIF_LIVE_EVENT_STOPPED object:nil];
    
    //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onEventChange) name:NOTIF_EVENT_CHANGE object:nil];
    
    //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onEventChange) name:NOTIF_COMMAND_VIDEO_PLAYER object:nil];

    //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(oberverForEncoderStatus:)  name:NOTIF_ENCODER_STAT     object:nil];
    
    /*
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
     */
    
    
    //NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"SoccerBottomViewController" ofType:@"plist"];
    //NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    /*[center addObserverForName:@"BottomViewControllerInit" object:nil queue:nil usingBlock:^(NSNotification *notification)
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
     }];*/
    
    [center addObserverForName:NOTIF_EVENT_FEEDS_READY object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self restartPlayer];
        //[self createTagButtons];
    }];
    
    informationLabel = [[UILabel alloc] initWithFrame:CGRectMake(156, 50, MEDIA_PLAYER_WIDTH, 50)];
    [informationLabel setTextAlignment:NSTextAlignmentRight];
    [self.view addSubview:informationLabel];
    
    
    durationSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(80, 60, 100, 30)];
    [durationSwitch setOnTintColor:PRIMARY_APP_COLOR];
    [durationSwitch setTintColor:PRIMARY_APP_COLOR];
    [durationSwitch setThumbTintColor:[UIColor grayColor]];
    [durationSwitch setOn:NO];
    [durationSwitch addTarget:self action:@selector(switchPressed) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:durationSwitch];
    UILabel *durationLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 60, 125, 30)];
    [durationLabel setText:@"Duration"];
    [self.view addSubview:durationLabel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clipViewPlayFeedNotification:) name:NOTIF_SET_PLAYER_FEED object:nil];
    
    return self;
}

-(NSArray*)playerList{
    NSArray *players = [[UserCenter getInstance].taggingTeam.players allValues];
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for (TeamPlayer *player in players) {
        [array addObject:player.jersey];
    }
    return [array copy];
}

-(void)addPlayerView{
    
    if (![UserCenter getInstance].taggingTeam) {
        return;
    }
    
    playerList = [self playerList];

    _leftArrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ortrileft.png"]];
    [_leftArrow setContentMode:UIViewContentModeScaleAspectFit];
    [_leftArrow setAlpha:1.0f];
    [self.view addSubview:_leftArrow];
    [_leftArrow setHidden:true];
    
    _playerDrawerLeft = [[ContentViewController alloc] initWithPlayerList:playerList];
    [_playerDrawerLeft.view.layer setBorderColor:PRIMARY_APP_COLOR.CGColor];
    [_playerDrawerLeft.view.layer setBorderWidth:1.0f];
    [_playerDrawerLeft.view setBackgroundColor:[UIColor whiteColor]];
    
    _rightArrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ortriright.png"]];
    [_rightArrow setContentMode:UIViewContentModeScaleAspectFit];
    [_rightArrow setAlpha:1.0f];
    [self.view addSubview:_rightArrow];
    [_rightArrow setHidden:true];
    
    _playerDrawerRight = [[ContentViewController alloc] initWithPlayerList:playerList];
    [_playerDrawerRight.view setBackgroundColor:[UIColor clearColor]];
    [_playerDrawerRight.view.layer setBorderColor:PRIMARY_APP_COLOR.CGColor];
    [_playerDrawerRight.view.layer setBorderWidth:1.0f];
    [_playerDrawerRight.view setBackgroundColor:[UIColor whiteColor]];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_SET_PLAYER_FEED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_CLIP_CANCELED object:self.videoPlayer];
}

#pragma mark- Encoder Observers

-(void)tabJustBeingAdded:(NSNotification*)note{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_TAB_CREATED object:nil];
    _observedEncoder = _appDel.encoderManager.masterEncoder;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(eventChanged:) name:NOTIF_EVENT_CHANGE object:_observedEncoder];
    _currentEvent = [_appDel.encoderManager.primaryEncoder event];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onTagChanged:) name:NOTIF_TAG_RECEIVED object:_currentEvent];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onTagChanged:) name:NOTIF_TAG_MODIFIED object:_currentEvent];
    [self createTagButtons];
    [self turnSwitchOn];
    [_feedSwitch watchCurrentEvent:_currentEvent];
    [_tagButtonController allToggleOnOpenTags:_currentEvent];
    [self displayLable];
    [self addBottomViewController];
    [self addPlayerView];
    if (_currentEvent.live) {
        [self gotLiveEvent];
    }
    [self onEventChange];
}

-(void)addEventObserver:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_TAB_CREATED object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_EVENT_CHANGE object:_observedEncoder];
    
    if (note.object == nil) {
        _observedEncoder = nil;
        return;
    }
    
    _observedEncoder = (id <EncoderProtocol>) note.object;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(eventChanged:) name:NOTIF_EVENT_CHANGE object:_observedEncoder];
}

-(void)displayLable{
    NSString *content;
    
    LeagueTeam *homeTeam = [_currentEvent.teams objectForKey:@"homeTeam"];
    LeagueTeam *visitTeam = [_currentEvent.teams objectForKey:@"visitTeam"];
    
    if (_currentEvent.live) {
        if ([UserCenter getInstance].taggingTeam.name && ([[UserCenter getInstance].taggingTeam.name isEqualToString:homeTeam.name] || [[UserCenter getInstance].taggingTeam.name isEqualToString:visitTeam.name])) {
            content = [NSString stringWithFormat:@"Live - Tagging team: %@", [UserCenter getInstance].taggingTeam.name];
        }
        else{
            content = @"Live - Tagging team:";
        }
    }
    else{
         content = [NSString stringWithFormat:@"%@ - Tagging team: %@", _currentEvent.date, [UserCenter getInstance].taggingTeam.name];
    }
    [informationLabel setText:content];
}

-(void)clear{
    [informationLabel setText:@""];
}

-(void)addBottomViewController{
    NSString *sport = [UserCenter getInstance].taggingTeam.league.sport;
    if (_bottomViewController) {
        [_bottomViewController clear];
        _bottomViewController = nil;
    }
    
    if ([sport isEqualToString:SPORT_HOCKEY] && !_bottomViewController && _currentEvent) {
        _bottomViewController = [[HockeyBottomViewController alloc]init];
        [self.view insertSubview:_bottomViewController.mainView belowSubview:_fullscreenViewController.view];
        _bottomViewController.currentEvent = _currentEvent;
        [_bottomViewController update];
        [_bottomViewController postTagsAtBeginning];
        
    }else if ([sport isEqualToString:SPORT_SOCCER] && !_bottomViewController && _currentEvent){
        _bottomViewController = [[SoccerBottomViewController alloc]init];
        [self.view insertSubview:_bottomViewController.mainView belowSubview:_fullscreenViewController.view];
        _bottomViewController.currentEvent = _currentEvent;
        [_bottomViewController update];
        [_bottomViewController postTagsAtBeginning];
        [self switchPressed];
        [_bottomViewController allToggleOnOpenTags];
    }else if ([sport isEqualToString:SPORT_RUGBY] && !_bottomViewController && _currentEvent){
        _bottomViewController = [[RugbyBottomViewController alloc]init];
        [self.view insertSubview:_bottomViewController.mainView belowSubview:_fullscreenViewController.view];
        _bottomViewController.currentEvent = _currentEvent;
        [_bottomViewController update];
        [_bottomViewController postTagsAtBeginning];
        [self switchPressed];
        [_bottomViewController allToggleOnOpenTags];
    }else if ([sport isEqualToString:SPORT_FOOTBALL] && !_bottomViewController && _currentEvent){
        _bottomViewController = [[FootballBottomViewController alloc]init];
        [self.view insertSubview:_bottomViewController.mainView belowSubview:_fullscreenViewController.view];
        _bottomViewController.currentEvent = _currentEvent;
    }
}

-(void)checkIpadVersion{
    BOOL result = [Utility isDeviceSupportedMultiCam:[Utility platformString]];
    if (!result && [_currentEvent.feeds allValues].count > 1) {
        CustomAlertView *alert = [[CustomAlertView alloc]initWithTitle:@"Multiple Cameras not Supported" message:@"iPad does not support multiple cameras. You need iPadAir or higher." delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [alert showView];
    }
    
}

-(void)eventChanged:(NSNotification*)note
{
    if (_teamPick){ // pick teams is up get rid of it safly
        [_teamPick clear];
        [_teamPick dismissPopoverAnimated:NO];
        _teamPick = nil;
    }
    
    if ([[note.object event].name isEqualToString:_currentEvent.name]) {
        [self onEventChange];
        return;
    }
    
    if (_currentEvent != nil) {
        [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_TAG_RECEIVED object:_currentEvent];
        [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_TAG_MODIFIED object:_currentEvent];
    }

    if (!_currentEvent.live) {
        [_tagButtonController closeAllOpenTagButtons];
        [_bottomViewController closeAllOpenTagButtons];
    }
    
    if (_currentEvent.live && _appDel.encoderManager.liveEvent == nil) {
        _currentEvent = nil;
        //[self addBottomViewController];
        [UserCenter getInstance].taggingTeam = nil;
        [eventStopped showView];

    }
    
    if ([((id <EncoderProtocol>) note.object) event]) {
        _currentEvent = [((id <EncoderProtocol>) note.object) event];//[_appDel.encoderManager.primaryEncoder event];
        [self turnSwitchOn];
        [_feedSwitch watchCurrentEvent:_currentEvent];
        [_tagButtonController allToggleOnOpenTags:_currentEvent];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onTagChanged:) name:NOTIF_TAG_RECEIVED object:_currentEvent];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onTagChanged:) name:NOTIF_TAG_MODIFIED object:_currentEvent];
        [self displayLable];
        
        if (_currentEvent.live) {
            [self gotLiveEvent];
        }
        
        [self addBottomViewController];
        [self addPlayerView];
        [self checkIpadVersion];
        
    }
    
    [self onEventChange];
}

-(void)onTagChanged:(NSNotification *)note
{
    _bottomViewController.currentEvent = _currentEvent;
}

-(void)liveEventStopped:(NSNotification *)note
{
    if (_currentEvent.live) {
        [_appDel.encoderManager declareCurrentEvent:nil];
    }else{
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

-(void)swipeLeftNoticed:(UISwipeGestureRecognizer *)swipeLeftRecognizer{
    [self.videoPlayer seekBy:_videoBar.backwardSeekButton.speed];
}

-(void)swipeRightNoticed:(UISwipeGestureRecognizer *)swipeRightRecognizer{
    [self.videoPlayer seekBy:_videoBar.forwardSeekButton.speed];
}

#pragma mark - Tap Gesture Recognizer methods

-(void)tapNoticed:(UITapGestureRecognizer *) tapRecognizer{
    if (!self.videoPlayer.videoControlBar.hidden){
        [self.videoPlayer.videoControlBar setHidden:true];
    }else{
        [self.videoPlayer.videoControlBar setHidden:false];
    }
}

#pragma mark - Observers and Observer Methods

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &eventTypeContext){ // This checks to see if the encoder manager has changed Events Types like Sport or Medical
        [self onEventTypeChange: [change objectForKey:@"new"]];
    } else if (context == &eventContext){
        //[self onEventChange];
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
        //self.videoPlayer.live = YES;
        _gotoLiveButton.enabled = YES;
        _fullscreenViewController.liveButton.enabled = YES;
        [self switchPressed];
        //[_tagButtonController setButtonState:SideTagButtonModeRegular];
        //_tagButtonController.enabled = YES;
    }else if (_currentEvent != nil){
        self.videoPlayer.live = NO;
        _gotoLiveButton.enabled = NO;
        _fullscreenViewController.liveButton.enabled = NO;
        //[_tagButtonController setButtonState:SideTagButtonModeRegular];
        [self switchPressed];
        //_tagButtonController.enabled = YES;
    }
    else if (_currentEvent == nil){
        self.videoPlayer.live = NO;
        _gotoLiveButton.enabled = NO;
        _fullscreenViewController.liveButton.enabled = NO;
        [_tagButtonController setButtonState:SideTagButtonModeDisable];
        //[self switchPressed];
        //_tagButtonController.enabled = NO;
        [self.videoPlayer clear];
        [informationLabel setText:@""];
    }
    [multiButton setHidden:!([_currentEvent.feeds count]>1)];
    
    PxpPlayerContext *context = _encoderManager.primaryEncoder.eventContext;
    //PxpPlayerContext *context = [PxpEventContext contextWithEvent:_currentEvent];
    _playerViewController.playerView.context = context;
    _videoBar.event = _currentEvent;
    _fullscreenViewController.playerViewController.playerView.context = context;
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
        _gotoLiveButton.enabled = YES;
        _tagButtonController.enabled = YES;
    }
    else if (eventOnPrimaryEncoder.event != nil){
        [self removething];
        [_videoBarViewController setBarMode: L2B_VIDEO_BAR_MODE_LIVE];
        [_fullscreenViewController setMode: L2B_FULLSCREEN_MODE_EVENT];
        self.videoPlayer.live = NO;
        _gotoLiveButton.enabled = NO;
        _tagButtonController.enabled = YES;
    }
    else if(_encoderManager.masterEncoder.event != nil){
        [_videoBarViewController setBarMode: L2B_VIDEO_BAR_MODE_LIVE];
        [_fullscreenViewController setMode: L2B_FULLSCREEN_MODE_EVENT];
        self.videoPlayer.live = NO;
        _gotoLiveButton.enabled = NO;
        _tagButtonController.enabled = YES;
    }
    else if (eventOnPrimaryEncoder.event == nil  && _encoderManager.masterEncoder.liveEvent == nil){
        [_videoBarViewController setBarMode: L2B_VIDEO_BAR_MODE_DISABLE];
        [_fullscreenViewController setMode: L2B_FULLSCREEN_MODE_DISABLE];
        self.videoPlayer.live = NO;
        _gotoLiveButton.enabled = NO;
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
    
    LeagueTeam *homeTeam = [_currentEvent.teams objectForKey:@"homeTeam"];
    LeagueTeam *awayTeam = [_currentEvent.teams objectForKey:@"visitTeam"];
    NSDictionary *team = @{homeTeam.name:homeTeam,awayTeam.name:awayTeam};
    
    _teamPick = [[ListPopoverController alloc] initWithMessage:NSLocalizedString(@"Please select the team you want to tag:", @"dev comment - asking user to pick a team") buttonListNames:@[[[team allKeys]firstObject], [[team allKeys]lastObject]]];
    
    __block Live2BenchViewController *weakSelf = self;
    [_teamPick addOnCompletionBlock:^(NSString *pick){
        
        [UserCenter getInstance].taggingTeam = [team objectForKey:pick];
        [weakSelf displayLable];
        [weakSelf addBottomViewController];
        [weakSelf addPlayerView];
        [[NSNotificationCenter defaultCenter]postNotificationName: NOTIF_SELECT_TAB          object:nil
                                                         userInfo:@{@"tabName":@"Live2Bench"}];
    }];
    [_teamPick presentPopoverCenteredIn:[UIApplication sharedApplication].keyWindow.rootViewController.view
                               animated:YES];
    
    self.videoPlayer.live = YES;
    [_pipController pipsAndVideoPlayerToLive:info];
}


#pragma mark -
#pragma mark Gesture

//this method will be triggered if user pinches the video view. Based on the pinch velocity, will enter full screen or back to normal screen
- (void)handlePinchGuesture:(UIGestureRecognizer *)recognizer{
    
    if((pinchGesture.velocity > 0.5 || pinchGesture.velocity < -0.5) && pinchGesture.numberOfTouches == 2){
        if (CGRectContainsPoint(self.view.bounds, [pinchGesture locationInView:self.view]))
        {
            
            if (pinchGesture.scale >1) {
                [_bottomViewController.mainView setHidden:true];
                [_tagButtonController setButtonColor:true];
                [_pipController.multi fullScreen];
//                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_FULLSCREEN object:self userInfo:@{@"context":_context,@"animated":[NSNumber numberWithBool:YES]}];
            }else if (pinchGesture.scale < 1){
                [telestration forceCloseTele];
                [_bottomViewController.mainView setHidden:false];
                [_tagButtonController setButtonColor:false];
                [_pipController.multi normalScreen];
                [_tagButtonController _fullScreen];
                //[[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SMALLSCREEN object:self userInfo:@{@"context":STRING_LIVE2BENCH_CONTEXT,@"animated":[NSNumber numberWithBool:YES]}];
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
    //ReusableBottomViewController *bottomViewController = [[ReusableBottomViewController alloc] init];
    //[self.view addSubview:bottomViewController.view];
    //_theBottomViewController = bottomViewController;

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
    [[NSNotificationCenter defaultCenter]addObserverForName:NOTIF_SIDE_TAGS_READY_FOR_L2B object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self createTagButtons];
    }];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:NOTIF_EVENT_FEEDS_READY object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self restartPlayer];
        //[self createTagButtons];
    }];
    
    
    //! self.videoPlayer = [[RJLVideoPlayer alloc] initWithFrame:CGRectMake(156, 100, MEDIA_PLAYER_WIDTH, MEDIA_PLAYER_HEIGHT)];
    //bottomViewController.videoPlayer = self.videoPlayer;
    /*! Disabled For Demo
    telestration = [[TeleViewController alloc]initWithController:self.videoPlayer];
    telestration.delegate = self;
     */

    self.telestrationViewController.view.frame = self.videoPlayer.view.bounds;
    
    // we need the control bar to be first responder.
    [self.videoPlayer.view insertSubview:self.telestrationViewController.view belowSubview:self.videoPlayer.videoControlBar];
    
    self.telestrationViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.playerViewController.telestrationViewController.delegate = self;
    
    //pinchGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinchGuesture:)];
    //[self.view addGestureRecognizer:pinchGesture];
    
    swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeNoticed:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionUp;
    swipeGesture.numberOfTouchesRequired = 3;
    [self.videoPlayer.view addGestureRecognizer: swipeGesture];
    [[((RJLVideoPlayer *)self.videoPlayer).zoomManager panGestureRecognizer] requireGestureRecognizerToFail: swipeGesture];
    
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapNoticed:)];
    [self.videoPlayer.view addGestureRecognizer:tapGesture];
    
    swipeLeftGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeLeftNoticed:)];
    swipeLeftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.videoPlayer.view addGestureRecognizer:swipeLeftGesture];
    
    swipeRightGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRightNoticed:)];
    swipeRightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.videoPlayer.view addGestureRecognizer:swipeRightGesture];
    
    // Richard
    
    //!_videoBarViewController = [[L2BVideoBarViewController alloc]initWithVideoPlayer:self.videoPlayer];
    //_videoBarViewController.tagMarkerController.arrayOfAllTags =
    //![self.view addSubview:_videoBarViewController.view];

    //!_fullscreenViewController = [[L2BFullScreenViewController alloc]initWithVideoPlayer:self.videoPlayer];
    //_fullscreenViewController.context = STRING_LIVE2BENCH_CONTEXT;
    //[_fullscreenViewController.continuePlay     addTarget:self action:@selector(continuePlay)   forControlEvents:UIControlEventTouchUpInside];
    //[_fullscreenViewController.liveButton       addTarget:self action:@selector(goToLive)       forControlEvents:UIControlEventTouchUpInside];
//    [_fullscreenViewController.teleButton       addTarget:self action:@selector(initTele:)      forControlEvents:UIControlEventTouchUpInside];
    //_fullscreenViewController.teleViewController =telestration;
    //_tagButtonController.fullScreenViewController = _fullscreenViewController;

    self.videoPlayer.playerContext = STRING_LIVE2BENCH_CONTEXT;
    
    //[_fullscreenViewController setMode: L2B_FULLSCREEN_MODE_DEMO];
    // so get buttons are connected to full screen
   

    _pip            = [[Pip alloc]initWithFrame:CGRectMake(50, 50, 200, 150)];
    _pip.isDragAble  = YES;
    _pip.hidden      = YES;
    _pip.muted       = YES;
    _pip.dragBounds  = self.videoPlayer.view.frame;
    [self.videoPlayer.view addSubview:_pip];
    
    _feedSwitch     = [[FeedSwitchView alloc]initWithFrame:CGRectMake(156+100, 59, 64, 38)];
    
    //!_pipController  = [[PipViewController alloc]initWithVideoPlayer:self.videoPlayer f:_feedSwitch encoderManager:_encoderManager];
    _pipController.context = STRING_LIVE2BENCH_CONTEXT;
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
    
    self.playerViewController.view.frame = CGRectMake(156, 100, MEDIA_PLAYER_WIDTH, MEDIA_PLAYER_HEIGHT);
    [self.view addSubview:self.playerViewController.view];
    
    _gotoLiveButton = [[LiveButton alloc]initWithFrame:CGRectMake(MEDIA_PLAYER_WIDTH +self.playerViewController.view.frame.origin.x+32,PADDING + self.playerViewController.view.frame.size.height + 95, 130, LITTLE_ICON_DIMENSIONS)];
    [_gotoLiveButton addTarget:self action:@selector(goToLive) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_gotoLiveButton];
    _gotoLiveButton.enabled = NO;
   //  [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(masterLost:)               name:NOTIF_ENCODER_MASTER_HAS_FALLEN object:nil];
    
    _videoBar.frame = CGRectMake(_playerViewController.view.frame.origin.x, _playerViewController.view.frame.origin.y + _playerViewController.view.frame.size.height, _playerViewController.view.frame.size.width, 40.0);
    [self.view addSubview:_videoBar];
    
    [self.view addSubview:_fullscreenViewController.view];
    
    [_videoBar.fullscreenButton addTarget:_fullscreenViewController action:@selector(fullscreenResponseHandler:) forControlEvents:UIControlEventTouchUpInside];
    [_playerViewController.fullscreenGestureRecognizer addTarget:_fullscreenViewController action:@selector(fullscreenResponseHandler:)];
    
    _playerViewController.telestrationViewController.stillMode = YES;
    _videoBar.playerViewController = _playerViewController;
}

-(void)onOpenTeleView:(TeleViewController *)tvc
{
    [self.videoPlayer pause];
    self.videoPlayer.videoControlBar.hidden = YES;
    //[_fullscreenViewController setMode:L2BFullScreenModeTele];
}


-(void)onCloseTeleView:(TeleViewController *)tvc
{

    
    [self.videoPlayer play];
    self.videoPlayer.videoControlBar.hidden = NO;
    //[_fullscreenViewController setMode:_fullscreenViewController.prevMode];
    
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

  
    //_tagButtonController.fullScreenViewController = _fullscreenViewController;
    
    if (!self.videoPlayer.feed && _encoderManager.currentEvent != nil) {
     [self.videoPlayer playFeed:_feedSwitch.primaryFeed];
    }
    
    

//    [currentEventTitle setNeedsDisplay];
    
    
    // maybe this should be part of the videoplayer
     if(!(self.videoPlayer.view.superview == self.view))
     {
         [self.videoPlayer.view setFrame:CGRectMake((self.view.bounds.size.width - MEDIA_PLAYER_WIDTH)/2, 100.0f, MEDIA_PLAYER_WIDTH, MEDIA_PLAYER_HEIGHT)];
         [self.view addSubview:self.videoPlayer.view];
         
         //[self.videoPlayer play];
         //[self.view addSubview:_fullscreenViewController.view];
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
    
    
    //!_bottomViewController.videoPlayer = ((id <PxpVideoPlayerProtocol>)self.videoPlayer).avPlayer;
    [_bottomViewController update];
    // just to update UI
    
    [self.view bringSubviewToFront:_bottomViewController.mainView];
    [self.view bringSubviewToFront:_videoBar];
    [self.view bringSubviewToFront:_fullscreenViewController.view];
    [self.view bringSubviewToFront:_tagButtonController.leftTray];
    [self.view bringSubviewToFront:_tagButtonController.rightTray];
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
    [super viewWillDisappear:animated];
    
    [CustomAlertView removeAll];
    //[[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SMALLSCREEN object:self userInfo:@{@"context":self.videoPlayer.playerContext,@"animated":[NSNumber numberWithBool:NO]}];
    self.videoPlayer.mute = YES;
    self.playerViewController.telestrationViewController.telestration = nil;
}

-(void)alertView:(CustomAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//    [globals.ARRAY_OF_POPUP_ALERT_VIEWS removeObject:alertView];
    [alertView viewFinished];
    [CustomAlertView removeAlert:alertView];
}

/**
 *  This sets the video player and all its pip to live
 */

- (void)goToLive
{
    PXPLog(@"Pressed Live Button");
    self.videoPlayer.live = YES;
    if (_currentEvent.live) {
        [_pipController pipsAndVideoPlayerToLive:self.videoPlayer.feed];
        
        [self.playerViewController.playerView.player goToLive];
        
        return;
    }
    
    [_appDel.encoderManager declareCurrentEvent:_appDel.encoderManager.liveEvent];
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_TAG_RECEIVED object:_appDel.encoderManager.liveEvent];

}



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
    
    //_tagButtonController.enabled = NO;
    
    NSArray * tNames = [_userCenter.tagNames copy]; //self.tagNames;
    [_tagButtonController inputTagData:tNames];
    //[_tagButtonController setButtonState:SIDETAGBUTTON_MODE_DISABLE];
    
    //Add Actions
    [_tagButtonController addActionToAllTagButtons:@selector(tagButtonSelected:) addTarget:self forControlEvents:UIControlEventTouchUpInside];
    [_tagButtonController addActionToAllTagButtons:@selector(tagButtonSwiped:) addTarget:self forControlEvents:UIControlEventTouchDragOutside];
//    if ([_eventType isEqualToString:SPORT_FOOTBALL_TRAINING]) {
//        [_tagButtonController addActionToAllTagButtons:@selector(showFootballTrainingCollection:) addTarget:self forControlEvents:UIControlEventTouchDragOutside];
//    } else {
//        [_tagButtonController addActionToAllTagButtons:@selector(showPlayerCollection:) addTarget:self forControlEvents:UIControlEventTouchDragOutside];
//    }
    //_tagButtonController.fullScreenViewController = _fullscreenViewController;
    [self viewWillAppear:true];
}

-(void)tagButtonSwiped:(id)sender{
     SideTagButton *button = sender;

    if ([button.accessibilityValue isEqualToString:@"left"]) {
        [self.view addSubview:_playerDrawerLeft.view];
        [_leftArrow setFrame:CGRectMake(button.center.x+button.frame.size.width/2, button.center.y+button.frame.size.height/2+77, 15, 15)];
        [_playerDrawerLeft assignFrame:CGRectMake(_leftArrow.center.x+_leftArrow.frame.size.width/2, button.center.y+button.frame.size.height/2+69, 300, 110)];
        [_leftArrow setHidden:false];
    }else if ([button.accessibilityValue isEqualToString:@"right"]){
        [self.view addSubview:_playerDrawerRight.view];
        [_rightArrow setFrame:CGRectMake(self.view.bounds.size.width-(button.center.x+button.frame.size.width/2+14), button.center.y+button.frame.size.height/2+77,15 , 15)];
        [_playerDrawerRight assignFrame:CGRectMake(self.view.bounds.size.width-button.frame.size.width-_rightArrow.frame.size.width-299, button.center.y+button.frame.size.height/2+69, 300, 110)];
        [_rightArrow setHidden:false];
    }
    
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
    SideTagButton *button = (SideTagButton*)sender;
    
    //!float currentTime = CMTimeGetSeconds(self.videoPlayer.playerItem.currentTime);// start time minus? //videoPlayer.vie - videoPlayer.startTime
    NSTimeInterval currentTime = self.currentTimeInSeconds;
    
    NSArray *players;
    if (_playerDrawerLeft.view.superview == self.view) {
        players = [_playerDrawerLeft getSelectedPlayers];
        [_playerDrawerLeft.view removeFromSuperview];
        [_playerDrawerLeft unHighlightAllButtons];
        [_leftArrow setHidden:true];
    }else if (_playerDrawerRight.view.superview == self.view){
        players = [_playerDrawerRight getSelectedPlayers];
        [_playerDrawerRight.view removeFromSuperview];
        [_playerDrawerRight unHighlightAllButtons];
        [_rightArrow setHidden:true];
    }
    

    if (button.mode == SideTagButtonModeRegular) {
        
        NSMutableDictionary * userInfo = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                         @"name":button.titleLabel.text,
                                                                                         @"time":[NSString stringWithFormat:@"%f",currentTime]
                                                                                         }];
        if (_bottomViewController && [_bottomViewController respondsToSelector:@selector(currentPeriod)]) {
            [userInfo setObject:[_bottomViewController currentPeriod] forKey:@"period"];
        }
        
        if (players.count > 0) {
            [userInfo setObject:players forKey:@"players"];
        }
        
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_TAG_POSTED object:self userInfo:[userInfo copy]];
        
    } else if (button.mode == SideTagButtonModeToggle && !button.isOpen) {
        [_tagButtonController disEnableButton];
        [_tagButtonController onEventChange:_currentEvent];
        //[_tagButtonController unHighlightButton:button];
        button.isOpen = YES;
        // Open Duration Tag
        
        NSMutableDictionary * userInfo = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                         @"name":button.titleLabel.text,
                                                                                         @"time":[NSString stringWithFormat:@"%f",currentTime],
                                                                                         @"type":[NSNumber numberWithInteger:TagTypeOpenDuration],
                                                                                         @"dtagid": button.durationID
                                                                                         }];
        if (_bottomViewController && [_bottomViewController respondsToSelector:@selector(currentPeriod)]) {
            [userInfo setObject:[_bottomViewController currentPeriod] forKey:@"period"];
        }
        if (players.count > 0) {
            [userInfo setObject:players forKey:@"players"];
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_TAG_POSTED object:self userInfo:userInfo];
    } else if (button.mode == SideTagButtonModeToggle && button.isOpen) {
        [_tagButtonController onEventChange:nil];
        // Close Duration Tag
        
        // Collect and mod tag data for close tag
        
        Tag * tagToBeClosed;
        if ([Tag getOpenTagByDurationId:button.durationID]) {
            tagToBeClosed = [Tag getOpenTagByDurationId:button.durationID];
        }else{
            for (Tag *tag in _currentEvent.tags) {
                if ([tag.name isEqualToString:button.titleLabel.text] && tag.type == TagTypeOpenDuration) {
                    tagToBeClosed = tag;
                }
            }
        }
        
        //tagToBeClosed             = [Tag getOpenTagByDurationId:button.durationID];
        NSMutableDictionary * tagData   = [NSMutableDictionary dictionaryWithDictionary:[tagToBeClosed makeTagData]];
        
        [tagData setValue:[NSString stringWithFormat:@"%f",currentTime] forKey:@"closetime"];
        [tagData setValue:[NSNumber numberWithInteger:TagTypeCloseDuration] forKey:@"type"];
        [tagData setValue:button.durationID forKey:@"dtagid"];
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MODIFY_TAG object:nil userInfo:tagData];
        
        button.isOpen = NO;
    }
    

    
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

-(void) switchPressed
{
    if (durationSwitch.on == true &&_currentEvent) {
        [_tagButtonController setButtonState:SideTagButtonModeToggle];
        [_bottomViewController setIsDurationVariable:SideTagButtonModeToggle];
    }else if(durationSwitch.on == false &&_currentEvent){
        [_tagButtonController setButtonState:SideTagButtonModeRegular];
        [_bottomViewController setIsDurationVariable:SideTagButtonModeRegular];
    }
}

-(void) turnSwitchOn
{
    for (Tag *tag in _currentEvent.tags) {
        if (tag.type == TagTypeOpenDuration) {
            [durationSwitch setOn:YES];
            [self switchPressed];
            return;
        }
    }
    

    
}

-(void) onAppTerminate:(NSNotification *)note{
    [_tagButtonController closeAllOpenTagButtons];
    [_bottomViewController closeAllOpenTagButtons];
}

- (void)didReceiveMemoryWarning
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_RECEIVE_MEMORY_WARNING object:self userInfo:nil];
    [super didReceiveMemoryWarning];
}

- (void)clipViewPlayFeedNotification:(NSNotification *)note {
    if ([note.userInfo[@"context"] isEqualToString: STRING_LIVE2BENCH_CONTEXT]) {
        Feed *feed = note.userInfo[@"feed"];
        Tag *tag = note.userInfo[@"tag"];
        PxpTelestration *tele = tag.telestration;
        
        [self.playerViewController.playerView switchToContextPlayerNamed:feed.sourceName];
        
        self.playerViewController.playerView.player.tag = tag;
        self.playerViewController.telestrationViewController.telestration = !feed.sourceName || tele.sourceName == feed.sourceName || [tele.sourceName isEqualToString:feed.sourceName] ? tele : nil;
        
        
    }
}

- (void)telestration:(nonnull PxpTelestration *)telestration didStartInViewController:(nonnull PxpTelestrationViewController *)viewController {
    self.videoPlayer.videoControlBar.enable = NO;
    [self.videoPlayer pause];
}

- (void)telestration:(nonnull PxpTelestration *)tele didFinishInViewController:(nonnull PxpTelestrationViewController *)viewController {
    
    if (tele.actionStack.count) {
        tele.sourceName = self.playerViewController.playerView.activePlayerName;
        
        
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_CREATE_TELE_TAG object:self userInfo:@{
                                                                                                               @"time": [NSString stringWithFormat:@"%f",tele.startTime],
                                                                                                               @"duration": [NSString stringWithFormat:@"%i",(int)roundf(tele.duration)],
                                                                                                               @"starttime": [NSString stringWithFormat:@"%f",tele.startTime],
                                                                                                               @"displaytime" : [NSString stringWithFormat:@"%f",tele.startTime],
                                                                                                               @"telestration" : tele.data,
                                                                                                               }];
    }
    
    self.videoPlayer.videoControlBar.enable = YES;
}

- (NSTimeInterval)currentTimeInSeconds {
    return self.playerViewController.playerView.player.currentTimeInSeconds;
}

/*
- (void)setVideoPlayer:(UIViewController<PxpVideoPlayerProtocol> *)videoPlayer {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_CLIP_CANCELED object:videoPlayer];
    
    _videoPlayer = videoPlayer;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clipCanceledHandler:) name:NOTIF_CLIP_CANCELED object:videoPlayer];
}
*/

- (void)clipCanceledHandler:(NSNotification *)note {
    self.telestrationViewController.telestration = nil;
}

@end

