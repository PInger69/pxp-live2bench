
//
//  RicoLive2BenchViewController.m
//  Live2BenchNative
//
//  Created by DEV on 2013-01-21.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "RicoLive2BenchViewController.h"
#import <UIKit/UIKit.h>
#import "LoginOperation.h"


// Singletons
#import "EncoderClasses/EncoderManager.h"
#import "UserCenter.h"

// UI
#import "Live2BenchTagUIViewController.h"
#import "LiveButton.h"
#import "ListPopoverController.h"
#import "ContentViewController.h"

// Encoder Model
#import "EncoderClasses/EncoderProtocol.h"
#import "Feed.h"
#import "TeamPlayer.h"
#import "LeagueTeam.h"

// BottomView
#import "HockeyBottomViewController.h"
#import "SoccerBottomViewController.h"
#import "RugbyBottomViewController.h"
#import "FootballBottomViewController.h"
#import "FootballTrainingBottomViewController.h"
#import "BottomViewControllerProtocol.h"

// VideoPlayer
#import "PxpTelestrationViewController.h"
#import "PxpPlayerViewController.h"
#import "PxpPlayerMultiView.h"
#import "PxpEventContext.h"
#import "PxpVideoBar.h"
#import "PxpL2BFullscreenViewController.h"
#import "PxpListViewFullscreenViewController.h"
#import "PxpPlayer+Tag.h"
#import "UIImage+Blend.h"

#import "EncoderOperation.h"
#import "AnalyzeTabViewController.h"
#import "CustomAlertControllerQueue.h"


#import "RicoPlayer.h"
#import "RicoPlayerControlBar.h"
#import "RicoPlayerViewController.h"
#import "RicoPlayerViewControllerSO.h"
#import "RicoZoomContainer.h"
#import "RicoL2BVideoBar.h"
#import "RicoFullScreenViewController.h"
#import "RicoPlayerPool.h"
#import "RicoBaseFullScreenViewController.h"
#import "RicoPlayerGroupContainer.h"
#import "RicoFullScreenControlBar.h"
#import "ButtonMultiScreen.h"
#import "RicoSourcePickerButtons.h"

#import "FeedMapController.h"
#import "FeedMapDisplay.h"
#import "CameraDetails.h"
#import "UIDrawer.h"

#define MEDIA_PLAYER_X          156
#define MEDIA_PLAYER_Y          100
#define MEDIA_PLAYER_WIDTH      712
#define MEDIA_PLAYER_HEIGHT     400
#define LITTLE_ICON_DIMENSIONS  40
#define PADDING                 5



#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>


@interface RicoLive2BenchViewController () <PxpTelestrationViewControllerDelegate, PxpTimeProvider,RicoBaseFullScreenDelegate,RicoSourcePickerButtonsDelegate, Live2BenchTagUIViewControllerDelegate>

@property (strong, nonatomic, nonnull) PxpTelestrationViewController    * telestrationViewController;
@property (strong, nonatomic, nonnull) NSMutableArray                   * sourceNames;

@property (strong, nonatomic, nonnull) NSString                         * currentSource;
@property (strong, nonatomic, nonnull) RicoPlayer                       * ricoPlayer;
@property (strong, nonatomic, nonnull) RicoPlayerGroupContainer         * ricoZoomGroup;
@property (strong, nonatomic, nonnull) RicoPlayerControlBar             * ricoPlayerControlBar;
@property (strong, nonatomic, nonnull) RicoPlayerViewController         * ricoPlayerViewController;
@property (strong, nonatomic, nonnull) RicoZoomContainer                * ricoZoomContainer;
@property (strong, nonatomic, nonnull) RicoBaseFullScreenViewController * ricoFullScreen;
@property (strong, nonatomic, nonnull) RicoFullScreenControlBar         * ricoFullScreenControlBar;
@property (strong, nonatomic, nonnull) RicoSourcePickerButtons          * sourceButtonPicker;
@property (strong, nonatomic, nonnull) UIDrawer                         * debugDrawer;
@property (strong,nonatomic) UIButton                                   * multiCamButton;
@end


static BOOL wasMulti;



@implementation RicoLive2BenchViewController{
    ScreenController                    * _externalControlScreen;       // this is for attacked screens
    EncoderManager                      * _encoderManager;              // where all vids/feeds coming from
    UserCenter                          * _userCenter;                  // any userdata from plists
    NSString                            * _eventType;                   // Sport or medical
    LiveButton                          * _gotoLiveButton;              // live button
    Live2BenchTagUIViewController       * _tagButtonController;         // side tags
    ListPopoverController               * _teamPick;
    ListPopoverController               * _cameraPick;
    id <EncoderProtocol>                _observedEncoder;
    id <BottomViewControllerProtocol>   _bottomViewController;
    NSArray                             * playerList;                   //TODO Check this
    UILabel                             * informationLabel;
    UISwitch                            * durationSwitch;
    UIImageView                         * _leftArrow;
    UIImageView                         * _rightArrow;
    ContentViewController               * _playerDrawerLeft;
    ContentViewController               * _playerDrawerRight;
    RicoL2BVideoBar                     * _videoBar;
    Tag                                 * _selectedTag;
    BOOL                                _wasPausedBeforeTele;
    UITapGestureRecognizer              * _doubleTapOnGrid;
}

// Context
static void * eventTypeContext  = &eventTypeContext;
static void * eventContext      = &eventContext;

#pragma mark - View Controller Methods

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
    _eventType              = mainappDelegate.encoderManager.currentEventType; // TODO is this redundant
    _userCenter             = mainappDelegate.userCenter;

    self = [super initWithAppDelegate:mainappDelegate];
    if (self) {
        [self setMainSectionTab:NSLocalizedString(@"Live2Bench", nil) imageName:@"live2BenchTab"];
    }
  
    // Observers
    [_encoderManager addObserver:self forKeyPath:NSStringFromSelector(@selector(currentEventType))  options:NSKeyValueObservingOptionNew context:&eventTypeContext];
    [_encoderManager addObserver:self forKeyPath:NSStringFromSelector(@selector(currentEvent))      options:NSKeyValueObservingOptionNew context:&eventContext];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(createTagButtons)              name:NOTIF_SIDE_TAGS_READY_FOR_L2B  object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(addEventObserver:)             name:NOTIF_PRIMARY_ENCODER_CHANGE   object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(tabJustBeingAdded:)            name:NOTIF_TAB_CREATED              object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(clipViewPlayFeedNotification:) name:NOTIF_SET_PLAYER_FEED          object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(clipCancelNotification:)       name:NOTIF_PLAYER_BAR_CANCEL          object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(liveEventStopped:)             name:NOTIF_LIVE_EVENT_STOPPED object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadPlayers)                 name:NOTIF_RELOAD_PLAYERS object:nil];
    
    _sourceNames = [NSMutableArray new];
    return self;
}

/**
 *
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    informationLabel = [[UILabel alloc] initWithFrame:CGRectMake(MEDIA_PLAYER_X, 50, MEDIA_PLAYER_WIDTH, 50)];
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
    
    
    // Build Telestrations
    self.telestrationViewController                 = [PxpTelestrationViewController new];
    self.telestrationViewController.stillMode       = YES;
    self.telestrationViewController.delegate        = self;
    self.telestrationViewController.view.frame      = CGRectMake(MEDIA_PLAYER_X, MEDIA_PLAYER_Y, MEDIA_PLAYER_WIDTH, MEDIA_PLAYER_HEIGHT);
    self.telestrationViewController.timeProvider    = self;

    
    _gotoLiveButton         = [[LiveButton alloc]initWithFrame:CGRectMake(MEDIA_PLAYER_WIDTH +MEDIA_PLAYER_X+32,PADDING + MEDIA_PLAYER_HEIGHT + 95, 130, LITTLE_ICON_DIMENSIONS)];
    _gotoLiveButton.enabled = NO;
    [_gotoLiveButton addTarget:self action:@selector(goToLive) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_gotoLiveButton]; // redundant?

    _videoBar       = [RicoL2BVideoBar new];
    _videoBar.frame = CGRectMake(MEDIA_PLAYER_X, MEDIA_PLAYER_Y + MEDIA_PLAYER_HEIGHT, MEDIA_PLAYER_WIDTH, 40.0);
    [self.view addSubview:_videoBar];
    
    [_videoBar.backwardSeekButton addTarget:self action:@selector(seekPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_videoBar.forwardSeekButton  addTarget:self action:@selector(seekPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [_videoBar.slomoButton removeTarget:_videoBar action:@selector(slomoAction:)  forControlEvents:UIControlEventTouchUpInside];
    [_videoBar.slomoButton addTarget:self action:@selector(slomoPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [_videoBar.frameForward addTarget:self action:@selector(frameByFrame:) forControlEvents:UIControlEventTouchUpInside];
    [_videoBar.frameBackward addTarget:self action:@selector(frameByFrame:) forControlEvents:UIControlEventTouchUpInside];
    
    // Rico
    self.ricoZoomGroup              = [[RicoPlayerGroupContainer alloc]initWithFrame:CGRectMake(0, 0, MEDIA_PLAYER_WIDTH, MEDIA_PLAYER_HEIGHT)];
    [self.ricoZoomGroup setBackgroundColor:[UIColor blackColor]];
    self.ricoPlayer                 = [[RicoPlayer alloc]initWithFrame:CGRectMake(0, 0, MEDIA_PLAYER_WIDTH, MEDIA_PLAYER_HEIGHT)];

    self.ricoZoomContainer          = [[RicoZoomContainer alloc]initWithFrame:CGRectMake(MEDIA_PLAYER_X, MEDIA_PLAYER_Y, MEDIA_PLAYER_WIDTH, MEDIA_PLAYER_HEIGHT)];
    self.ricoPlayerControlBar       = [[RicoPlayerControlBar alloc]initWithFrame:CGRectMake(MEDIA_PLAYER_X,CGRectGetMaxY(self.ricoZoomContainer.frame)-40, self.ricoZoomContainer.frame.size.width, 40.0)];
    [self.ricoPlayerControlBar.playPauseButton addTarget:self action:@selector(controlBarPlay) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.ricoPlayerViewController   = [RicoPlayerPool instance].defaultController;
    
    
    self.ricoPlayerViewController.playerControlBar  = self.ricoPlayerControlBar;
    self.ricoPlayerControlBar.delegate              = self.ricoPlayerViewController;
    self.ricoZoomContainer.zoomEnabled              = YES;
    [self.ricoPlayerViewController addPlayers:self.ricoPlayer];
    [self.view addSubview:self.ricoZoomContainer];
    
    [self.view addSubview:self.telestrationViewController.view];
    
    [self.ricoZoomGroup addSubview:self.ricoPlayer];
    [self.ricoZoomContainer addToContainer:self.ricoZoomGroup];
    [self.view addSubview:self.ricoPlayerControlBar];

    _videoBar.playerViewController  = _ricoPlayerViewController;
    self.ricoPlayerControlBar.state = RicoPlayerStateNormal;
    
    // build fullScreen
    self.ricoFullScreen = [[RicoBaseFullScreenViewController alloc]initWithView:self.ricoZoomContainer];
    [_videoBar.fullscreenButton addTarget:self action:@selector(onFullScreenButton:) forControlEvents:UIControlEventTouchUpInside];
    

    [self addChildViewController:self.ricoFullScreen];
    [self.view addSubview:self.ricoFullScreen.view];
    
    // adding Controlls to the fullscreen
    
    self.ricoFullScreen.animated = NO;
    self.ricoFullScreen.delegate = self;

    self.ricoFullScreenControlBar = [[RicoFullScreenControlBar alloc]init];
    
    [self.ricoFullScreenControlBar.backwardSeekButton           addTarget: self action:@selector(seekPressed:)        forControlEvents:UIControlEventTouchUpInside];
    [self.ricoFullScreenControlBar.forwardSeekButton            addTarget: self action:@selector(seekPressed:)        forControlEvents:UIControlEventTouchUpInside];
    [self.ricoFullScreenControlBar.slomoButton                  addTarget: self action:@selector(slomoPressed:)       forControlEvents:UIControlEventTouchUpInside];
    [self.ricoFullScreenControlBar.liveButton                   addTarget: self action:@selector(goToLive)            forControlEvents:UIControlEventTouchUpInside];
    [self.ricoFullScreenControlBar.startRangeModifierButton     addTarget: self action:@selector(extendStartAction:)  forControlEvents:UIControlEventTouchUpInside];
    [self.ricoFullScreenControlBar.endRangeModifierButton       addTarget: self action:@selector(extendEndAction:)    forControlEvents:UIControlEventTouchUpInside];
    [self.ricoFullScreenControlBar.frameBackward                addTarget: self action:@selector(frameByFrame:)       forControlEvents:UIControlEventTouchUpInside];
    [self.ricoFullScreenControlBar.frameForward                 addTarget: self action:@selector(frameByFrame:)       forControlEvents:UIControlEventTouchUpInside];
    [self.ricoFullScreenControlBar.controlBar.playPauseButton   addTarget:self action:@selector(controlBarPlay) forControlEvents:UIControlEventTouchUpInside];
    [self.ricoFullScreenControlBar.fullscreenButton             addTarget:self action:@selector(onFullScreenButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.ricoFullScreen.bottomBar                              addSubview:self.ricoFullScreenControlBar];
    
    self.sourceButtonPicker = [[RicoSourcePickerButtons alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    self.sourceButtonPicker.delegate = self;
    [self.view addSubview:self.sourceButtonPicker];
    self.debugDrawer                = [[UIDrawer alloc]initWithFrame:CGRectMake(0, 600, 550, 80)];
    self.debugDrawer.openStyle      = UIDrawerLeft;
    self.debugDrawer.animationTime  = 0.5;
    
    [self.view addSubview:self.debugDrawer];
    self.debugDrawer.isOpen = DEBUG_MODE;
    
    [self.debugDrawer.contentArea addSubview:self.ricoPlayerViewController.debugOutput];
    self.ricoPlayerViewController.debugOutput.frame = CGRectMake(0, 0, 550, 80);

    UIWindow * mainWindow               = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).window;
    self.debugDrawer.frame              = CGRectMake(0, 600, 0, 0);
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(debugDrawerToggle)];
    tapGesture.numberOfTouchesRequired  = 4;

    [mainWindow addGestureRecognizer:tapGesture];
    
    _doubleTapOnGrid = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTapOnQuad:)];
    _doubleTapOnGrid.numberOfTapsRequired = 2;
    [self.ricoZoomGroup addGestureRecognizer:_doubleTapOnGrid];
    [self buildSourceButtons];
    
    self.gameTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(MEDIA_PLAYER_X, MEDIA_PLAYER_Y, 78.0f*2, 17.0f*2)];
    self.gameTimeLabel.text = @"";
    self.gameTimeLabel.alpha = 0.5;
    self.gameTimeLabel.hidden = YES;
    [self.gameTimeLabel setTextAlignment:NSTextAlignmentCenter];
    [self.gameTimeLabel setBackgroundColor:[UIColor blackColor]];
    [self.gameTimeLabel setTextColor:[UIColor whiteColor]];
    [self.gameTimeLabel setFont:[UIFont defaultFontOfSize:20.0f]];
    
    
    
    self.gameStart = [[UIButton alloc]initWithFrame:CGRectMake(0,PADDING + MEDIA_PLAYER_HEIGHT + 95, 130, LITTLE_ICON_DIMENSIONS)];
    [self.gameStart setTitle:@"Mark Game Start " forState:UIControlStateNormal];
    [self.gameStart setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
    self.gameStart.font = [UIFont systemFontOfSize:14.0];
    self.gameStart.layer.borderWidth = 1;
    self.gameStart.layer.borderColor = PRIMARY_APP_COLOR.CGColor;
    [self.gameStart addTarget:self action:@selector(startGameButton:) forControlEvents:UIControlEventTouchUpInside];
    

    [self.view addSubview:self.gameTimeLabel];
    [self.view addSubview:self.gameStart];
}


-(void)startGameButton:(id)sender
{
    UIButton * button = sender;
    
    button.enabled = NO;
    button.alpha = 0.5;
    self.gameTimeLabel.hidden = NO;
    [UserCenter getInstance].isStartLocked = YES;
    
    BOOL found;
    for (id<TagProtocol> cTag in self.currentEvent.tags) {
        if ([cTag type] == TagTypeGameStart) {
            found = YES;
            break;
        }
    }
    
    
    NSTimeInterval currentTime =     CMTimeGetSeconds(self.ricoPlayerViewController.primaryPlayer.currentTime);
    id<EncoderProtocol>  eventEncoder = self.currentEvent.parentEncoder;
    
    
    if (found && self.currentEvent.gameStartTag) {
        
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_DELETE_TAG object:self.currentEvent.gameStartTag];
        self.currentEvent.gameStartTag = nil;
        NSMutableDictionary * userInfo = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                         @"name":@"Game Start",
                                                                                         @"time":[NSString stringWithFormat:@"%f",currentTime],
                                                                                         @"type":[NSNumber numberWithInteger:TagTypeGameStart]
                                                                                         }];

        EncoderOperation * postTagOperation = [[EncoderOperationMakeTag alloc]initEncoder:eventEncoder data:[userInfo copy]];
        [postTagOperation setCompletionBlock:^{
            NSLog(@"Start Time set");
        }];
        [eventEncoder runOperation:postTagOperation];
        
        
    } else {
    
        NSMutableDictionary * userInfo = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                         @"name":@"Game Start",
                                                                                         @"time":[NSString stringWithFormat:@"%f",currentTime],
                                                                                         @"type":[NSNumber numberWithInteger:TagTypeGameStart]
                                                                                         }];
        
        
        EncoderOperation * postTagOperation = [[EncoderOperationMakeTag alloc]initEncoder:eventEncoder data:[userInfo copy]];
        [postTagOperation setCompletionBlock:^{
            NSLog(@"Start Time set");
        }];
        [eventEncoder runOperation:postTagOperation];
//        self.gameStart.enabled = false;
    }
    
    
   
    
}

-(void)updateOnPlayerTick;
{
    if  (self.currentEvent.gameStartTag) {
        float startTime = (float)[self currentTimeInSeconds] - ([self.currentEvent.gameStartTag time]);
        startTime = (startTime < 0)?0:startTime;
        self.gameTimeLabel.text = [NSString stringWithFormat:@"%@",[Utility translateTimeFormat:startTime]];
    }
}

-(void)debugDrawerToggle
{
    if (self.debugDrawer.isOpen) {
        [self.debugDrawer close:YES];
    } else {
        [self.debugDrawer open:YES];
    }
}


-(void)reloadPlayers
{
    
    NSArray         * feeds     = [self.currentEvent.feeds allValues];
    NSUserDefaults  * defaults  = [NSUserDefaults standardUserDefaults];
    NSString        * mode      = [defaults objectForKey:@"mode"];
    
    
    
//    self.ricoPlayerViewController.pl
    
    // just make one player
    if ([mode isEqualToString:@"streamOp"]) {
////        RicoPlayer * justPlayer = [[RicoPlayer alloc]initWithFrame:CGRectMake(0, 0, MEDIA_PLAYER_WIDTH, MEDIA_PLAYER_HEIGHT)];
//        Feed * afeed            = feeds[0];
//        afeed.quality           = 1;
//        [justPlayer loadFeed:afeed];
//        [self.ricoZoomGroup addSubview:justPlayer];
//        [self.ricoPlayerViewController addPlayers:justPlayer];
//        [[RicoPlayerPool instance].pooledPlayers addObject:justPlayer];
        
    } else if ([mode isEqualToString:@"dual"]) {
        
        RicoPlayer * justPlayer1 = [[RicoPlayer alloc]initWithFrame:CGRectMake(0, 0, MEDIA_PLAYER_WIDTH, MEDIA_PLAYER_HEIGHT)];
        Feed * afeed1 = feeds[0];
        
        afeed1.quality = 1;
        
        //        self.ricoPlayer = justPlayer;
        
        [justPlayer1 loadFeed:afeed1];
        
        [self.ricoZoomGroup addSubview:justPlayer1];
        [self.ricoPlayerViewController addPlayers:justPlayer1];
        [[RicoPlayerPool instance].pooledPlayers addObject:justPlayer1];
    } else {
        
        NSString* (^getSource)(NSString*location) = ^NSString*(NSString*location) {
            FeedMapDisplay * display = [[FeedMapController instance].feedMapDisplaysDict objectForKey:location];
            CameraDetails * cam = display.cameraDetails;
            return cam.source;
        };
        
//        NSInteger feedCount = ([feeds count] <4)?4:[feeds count];
        
        for (NSInteger i = 0; i<[feeds count]; i++) {
            RicoPlayer * madePlayer = [self.ricoZoomGroup subviews][i];
            
            Feed * afeed = feeds[i];
            
            Encoder * enc = (Encoder *)_currentEvent.parentEncoder;
            
            // 1 = highQuality  0 = low quality;
            Feed * tempFeed;
            NSString * camName;
            switch (i) {
                case 0:
                    camName             = [enc.cameraResource getCameraNameBy:kQuad1of4];
                    tempFeed            = [enc.cameraResource getFeedByLocation:kQuad1of4 event:_currentEvent];
                    break;
                case 1:
                    camName             = [enc.cameraResource getCameraNameBy:kQuad2of4];
                    tempFeed           = [enc.cameraResource getFeedByLocation:kQuad2of4 event:_currentEvent];
                    break;
                case 2:
                    camName             = [enc.cameraResource getCameraNameBy:kQuad3of4];
                    tempFeed           = [enc.cameraResource getFeedByLocation:kQuad3of4 event:_currentEvent];
                    break;
                case 3:
                    camName             = [enc.cameraResource getCameraNameBy:kQuad4of4];
                    tempFeed           = [enc.cameraResource getFeedByLocation:kQuad4of4 event:_currentEvent];
                    break;
                default:
                    break;
            }
            
            if (tempFeed)afeed = tempFeed;
            
            if ([mode isEqualToString:@"proxy"]) {
                afeed.quality = 0;
                
            } else if ([mode isEqualToString:@"hq"]) {
                afeed.quality = 1;
            }
            [madePlayer loadFeed:afeed];
        }
        
    }
    [self goToLive];
    [self buildSourceButtons];
}


#pragma mark - Source Button delegate method
-(void)onPressButton:(RicoSourcePickerButtons *)picker
{
    [self.ricoZoomContainer setZoomScale:1];
    
    wasMulti = NO;
//    [self changeSourceNonPress:picker.selectedTag];
    NSString * selectedString  = picker.selectedString;
//////////////////////////////////////////////////////////
    
    self.telestrationViewController.showsControls = YES;
    [self.multiCamButton setBackgroundColor:[UIColor lightGrayColor]];
    
    if (self.telestrationViewController.telestration) {
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_PLAYER_BAR_CANCEL object:nil];
    }
    
    
    
    
    
    
    NSString * key;
    if (picker.selectedTag< [_sourceNames count]){
        key = _sourceNames[picker.selectedTag];
        _currentSource = key;
    }
    

    
    
    // just make one player
    if ([[[UserCenter getInstance]l2bMode] isEqualToString:@"streamOp"]) {
        
        RicoPlayer * aplayer = [[self.ricoPlayerViewController.players allValues]firstObject];;
        
        CMTime time = aplayer.currentTime;
        Feed * aFeed = self.currentEvent.feeds[key];
        aFeed.quality = 1;
        [aplayer loadFeed:aFeed];
        
        [aplayer seekToTime:time toleranceBefore:kCMTimePositiveInfinity toleranceAfter:kCMTimePositiveInfinity completionHandler:nil] ;
        
        
        if (aplayer.isPlaying) {
            [aplayer play];
        }
        
        [aplayer refresh];
        
    } else { // Proxy and HD
        NSArray * rPlayers = [self.ricoPlayerViewController.players allValues];
        if ([rPlayers count] == 0) return;
        self.ricoZoomGroup.gridMode = NO;
        
        for (RicoPlayer * player in rPlayers) {
            
//            player.hidden = ([rPlayers count]==1)? NO: YES;
//            [player refresh];
        }
        


        Encoder * enc = (Encoder *)self.currentEvent.parentEncoder;
        CameraResource * camResource = enc.cameraResource;
        NSString* pick;
        
        if (![[[UserCenter getInstance]l2bMode] isEqualToString:@"dual"]){
            switch (picker.selectedTag) {
                case 0:
                    pick = ((Feed *) [camResource getFeedByLocation:kQuad1of4 event:self.currentEvent]).sourceName;
                    break;
                case 1:
                    pick = ((Feed *) [camResource getFeedByLocation:kQuad2of4 event:self.currentEvent]).sourceName;
                    break;
                case 2:
                    pick = ((Feed *) [camResource getFeedByLocation:kQuad3of4 event:self.currentEvent]).sourceName;
                    break;
                case 3:
                    pick = ((Feed *) [camResource getFeedByLocation:kQuad4of4 event:self.currentEvent]).sourceName;
                    break;
                    
                default:
                    break;
            }
        } else {
            pick = _currentSource;
        }
        
        for (RicoPlayer * rp in rPlayers) {
            if ([rp.feed.sourceName isEqualToString:pick]) {
                RicoPlayer * showPlayer = rPlayers[picker.selectedTag];
                showPlayer.hidden = NO;
                [self changeSource:pick];
//                [self.ricoPlayerViewController setPrimaryPlayerByFeedName:showPlayer.feed.sourceName];
            }
        }
        
        
        if (self.currentEvent.local){
            RicoPlayer * aplayer = [rPlayers firstObject];
            aplayer.hidden = NO;
        }
        
    }
    
//////////////////////////////////////////////////////////

    self.ricoPlayerViewController.syncronizePlayers = NO;
    self.ricoZoomContainer.zoomEnabled = !self.ricoZoomContainer.zoomEnabled;
    self.ricoZoomContainer.zoomEnabled = !self.ricoZoomContainer.zoomEnabled;
    [self.ricoPlayerViewController cancelPressed:self.ricoPlayerControlBar];
    
    if (self.ricoPlayerControlBar.state == RicoPlayerStateLive){
        self.ricoPlayerControlBar.state = RicoPlayerStateLive;
    }
}

#pragma mark -

-(void)changeSourceNonPress:(NSInteger)pickedSource
{
        [self.ricoZoomContainer setZoomScale:1];
    // Getting user preferences
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * mode =  [defaults objectForKey:@"mode"];
    
    
    self.telestrationViewController.showsControls = YES;
    [self.multiCamButton setBackgroundColor:[UIColor lightGrayColor]];
    
    if (self.telestrationViewController.telestration) {
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_PLAYER_BAR_CANCEL object:nil];
    }
    
    

    
    
    
    NSString * key;
    if (pickedSource< [_sourceNames count]){
        key = _sourceNames[pickedSource];
        _currentSource = key;
    }
    
    
    Encoder * enc = (Encoder *)self.currentEvent.parentEncoder;
    CameraResource * camResource = enc.cameraResource;
    
    switch (pickedSource) {
        case 0:
            _currentSource = ((Feed *) [camResource getFeedByLocation:kQuad1of4 event:self.currentEvent]).sourceName;
            break;
        case 1:
            _currentSource = ((Feed *) [camResource getFeedByLocation:kQuad2of4 event:self.currentEvent]).sourceName;
            break;
        case 2:
            _currentSource = ((Feed *) [camResource getFeedByLocation:kQuad3of4 event:self.currentEvent]).sourceName;
            break;
        case 3:
            _currentSource = ((Feed *) [camResource getFeedByLocation:kQuad4of4 event:self.currentEvent]).sourceName;
            break;
            
        default:
            break;
    }
    
    
    
    
    // just make one player
    if ([mode isEqualToString:@"streamOp"]) {
        
        RicoPlayer * aplayer = [[self.ricoPlayerViewController.players allValues]firstObject];;
        
        CMTime time = aplayer.currentTime;
        Feed * aFeed = self.currentEvent.feeds[key];
        aFeed.quality = 1;
        [aplayer loadFeed:aFeed];
        
        [aplayer seekToTime:time toleranceBefore:kCMTimePositiveInfinity toleranceAfter:kCMTimePositiveInfinity completionHandler:nil] ;
        
        
        if (aplayer.isPlaying) {
            [aplayer play];
        }
        
        [aplayer refresh];
        
    } else { // Proxy and HD
        NSArray * rPlayers = [self.ricoPlayerViewController.players allValues];
        if ([rPlayers count] == 0) return;
        self.ricoZoomGroup.gridMode = NO;
        
        for (RicoPlayer * player in rPlayers) {
            
            player.hidden = YES;
//            [player refresh];
        }
        RicoPlayer * showPlayer = rPlayers[pickedSource];
        showPlayer.hidden = NO;
        
        [self.ricoPlayerViewController setPrimaryPlayerByFeedName:showPlayer.feed.sourceName];
        
    }

}

-(void)changeSource:(NSString*)sourceName
{
        [self.ricoZoomContainer setZoomScale:1];
    [self.multiCamButton setBackgroundColor:[UIColor lightGrayColor]];
    BOOL wasLive = (self.ricoPlayerControlBar.state == RicoPlayerStateLive);
    
    self.ricoZoomContainer.zoomEnabled = !self.ricoZoomContainer.zoomEnabled;
    self.ricoZoomContainer.zoomEnabled = !self.ricoZoomContainer.zoomEnabled;// this is a quick fix, don't delete
    
    self.sourceButtonPicker.delegate = nil;
    [self.sourceButtonPicker selectButtonByString:sourceName];
    self.sourceButtonPicker.delegate = self;
    
    [self.ricoPlayerViewController cancelPressed:self.ricoPlayerControlBar];
    
    
    NSString * key;
    Encoder * enc = (Encoder *)self.currentEvent.parentEncoder;
    NSString * camloc;
    
    
    switch (self.sourceButtonPicker.selectedTag) {
        case 0:
            camloc = kQuad1of4;
            break;
        case 1:
            camloc = kQuad2of4;
            break;
        case 2:
            camloc = kQuad3of4;
            break;
        case 3:
            camloc = kQuad4of4;
            break;
            
        default:
            break;
    }
    
    
    
    key = [enc.cameraResource getFeedByLocation:camloc event:self.currentEvent].sourceName;
    

    
    
    
    // just make one player
    if ( [[[UserCenter getInstance]l2bMode] isEqualToString:@"streamOp"] ) {
        
        RicoPlayer * aplayer = [[self.ricoPlayerViewController.players allValues]firstObject];;
        
        CMTime time = aplayer.currentTime;
        
        Feed * aFeed = self.currentEvent.feeds[key];
        aFeed.quality = 1;
        if (self.currentSource != sourceName){
            [aplayer loadFeed:aFeed];
        }
        [aplayer seekToTime:time toleranceBefore:kCMTimePositiveInfinity toleranceAfter:kCMTimePositiveInfinity completionHandler:nil] ;
        
        
        if (aplayer.isPlaying) {
            //            [aplayer play];
        }
        [aplayer refresh];
        
    }else { // Proxy and HD
        NSArray * rPlayers = [self.ricoPlayerViewController.players allValues];
        if ([rPlayers count] == 0) return;
        self.ricoZoomGroup.gridMode = NO;
        
        for (RicoPlayer * player in rPlayers) {
            
            player.hidden = YES;
            
            if ([player.feed.sourceName isEqualToString:sourceName]) {
                player.hidden = NO;
                [self.ricoPlayerViewController setPrimaryPlayerByFeedName:player.feed.sourceName];
            }
//            [player refresh];
        }

        
        
        
    }
    
    _currentSource = key;
    
    
    if (wasLive){
        self.ricoPlayerControlBar.state = RicoPlayerStateLive;
    }
}


#pragma mark - Live2BenchTagUIViewControllerDelegate methods

-(void)onFinishBusy:(Live2BenchTagUIViewController *)live2BenchTagUI
{
    durationSwitch.enabled = YES;
}

#pragma mark -


-(void)onPressMultiCamButton:(id)sender
{
        [self.ricoZoomContainer setZoomScale:1];
    wasMulti = YES;
    [self.sourceButtonPicker deselectAll];
    UIButton * multiBut = sender;
    if (multiBut.backgroundColor ==[UIColor lightGrayColor]){
        [multiBut setBackgroundColor:PRIMARY_APP_COLOR];
        self.ricoZoomGroup.gridMode = YES;
        self.ricoPlayerViewController.syncronizePlayers = YES;
        self.telestrationViewController.showsControls = NO;
    } else {
        [multiBut setBackgroundColor:[UIColor lightGrayColor]];
    }
    [self.ricoPlayerViewController cancelPressed:self.ricoPlayerControlBar];
     [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_PLAYER_BAR_CANCEL object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([_bottomViewController respondsToSelector:@selector(update)]) {
        [_bottomViewController update];
    }
    [self.view bringSubviewToFront:_bottomViewController.mainView];
    [self.view bringSubviewToFront:self.ricoZoomContainer];
    [self.view bringSubviewToFront:self.telestrationViewController.view];
    [self.view bringSubviewToFront:self.ricoPlayerControlBar];
    [self.view bringSubviewToFront:_videoBar];
    [self.view bringSubviewToFront:self.ricoFullScreen.view];
    [self.view bringSubviewToFront:self.sourceButtonPicker];
    [self.view bringSubviewToFront:_tagButtonController.leftTray];
    [self.view bringSubviewToFront:_tagButtonController.rightTray];
    

}




-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.ricoPlayerViewController.playerControlBar) {
        self.ricoPlayerControlBar.state = self.ricoPlayerViewController.playerControlBar.state;
    }
    
    self.ricoPlayerViewController.playerControlBar  = self.ricoPlayerControlBar;
    self.ricoPlayerControlBar.delegate              = self.ricoPlayerViewController;
    self.ricoPlayerControlBar.gestureEnabled        = YES;
    self.ricoPlayerViewController.syncronizePlayers = NO;
    
    
    // layout
    
    if ([RicoPlayerPool instance].pooledPlayers) {
        
        for (RicoPlayer * p in [RicoPlayerPool instance].pooledPlayers) {
            p.frame = CGRectMake(0, 0, MEDIA_PLAYER_WIDTH, MEDIA_PLAYER_HEIGHT);
            [p removeFromSuperview];
            [self.ricoZoomGroup addSubview:p];

        }
    }
    [self.view addSubview:self.debugDrawer];

    [self.view addSubview:self.gameTimeLabel];
    [self.view addSubview:self.gameStart];

    self.gameStart.enabled = NO;
    self.gameStart.alpha = 0.5;
    self.gameTimeLabel.hidden = (self.currentEvent.gameStartTag == nil);
    if (self.currentEvent.gameStartTag == nil || ![UserCenter getInstance].isStartLocked){
        
        self.gameStart.enabled = YES;
        self.gameStart.alpha = 1;
    }
    
    

    if (wasMulti) {
        self.ricoZoomGroup.gridMode = YES;
        self.ricoPlayerViewController.syncronizePlayers = YES;
        self.telestrationViewController.showsControls = NO;
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[CustomAlertControllerQueue getInstance].alertQueue removeAllObjects];
    self.ricoFullScreen.fullscreen = NO;
    self.ricoZoomGroup.gridMode = NO;
    
    self.telestrationViewController.telestration = nil;
    
//    if (![_currentSource isEqualToString:@"onlySource"]) { // this is a quick duct tape fix
//        [self changeSource:_currentSource];    
//    }


}

- (void)didReceiveMemoryWarning
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_RECEIVE_MEMORY_WARNING object:self userInfo:nil];
    [super didReceiveMemoryWarning];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_SET_PLAYER_FEED object:nil];
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



-(void)addBottomViewController{
    NSString *sport = [UserCenter getInstance].taggingTeam.league.sport;
    if (_bottomViewController) {
        [_bottomViewController clear];// removes from parent
        _bottomViewController = nil;
    }
    
    
//     new
    Profession * profession = [ProfessionMap getProfession:sport];
    _bottomViewController = [[profession.bottomViewControllerClass alloc]init];
    [self.view insertSubview:_bottomViewController.mainView belowSubview:self.ricoZoomContainer];
    _bottomViewController.currentEvent  = _currentEvent;
    ((AbstractBottomViewController*)_bottomViewController).delegate = self.ricoPlayerViewController;
    if ([_bottomViewController respondsToSelector:@selector(update)]) {
        [_bottomViewController update];
    }
    if ([_bottomViewController respondsToSelector:@selector(postTagsAtBeginning)]) {
         [_bottomViewController postTagsAtBeginning];
    }
    if ([_bottomViewController respondsToSelector:@selector(allToggleOnOpenTags)]) {
           [_bottomViewController allToggleOnOpenTags];
    }
    
    [self switchPressed];
}

-(void)checkIpadVersion{

    
    BOOL result = [Utility isDeviceSupportedMultiCam:[Utility platformString]];
    if (!result && [_currentEvent.feeds allValues].count > 1) {
        _cameraPick = [[ListPopoverController alloc] initWithMessage:NSLocalizedString(@"iPad does not support multiple cameras. You need iPadAir or higher. You can only select one of the cameras. Please select the camera you want:", @"Please select the camera you want to play:") buttonListNames:@[]];
        _cameraPick.messageText.font = [UIFont defaultFontOfSize:14.0f];
        
        NSMutableDictionary *buttonListNames = [[NSMutableDictionary alloc]init];
        for (NSString *feedName in [_currentEvent.feeds allKeys]) {
            if ([feedName isEqualToString:@"s_00"]) {
                [buttonListNames setObject:@"Cam 0" forKey:feedName];
            }else if([feedName isEqualToString:@"s_01"]){
                [buttonListNames setObject:@"Cam 1" forKey:feedName];
            }else{
                [buttonListNames setObject:feedName forKey:feedName];
            }
            
        }
        _cameraPick.listOfButtonNames = buttonListNames.allValues;
        
        __block RicoLive2BenchViewController *weakSelf = self;
        [_cameraPick addOnCompletionBlock:^(NSString *pick){
            
            for (NSString *feedDisplayName in buttonListNames.allValues) {
                if (![feedDisplayName isEqualToString:pick]) {
                    [weakSelf.currentEvent.feeds removeObjectForKey:[[buttonListNames allKeysForObject:feedDisplayName] firstObject]];
                }
            }
            [weakSelf addFeed];

        }];
        [_cameraPick presentPopoverCenteredIn:[UIApplication sharedApplication].keyWindow.rootViewController.view
                                   animated:YES];

    }else{
        [self addFeed];
    }
    
}

-(void)eventChanged:(NSNotification*)note
{
    self.gameTimeLabel.text = @"Game Start";

    if (_teamPick){ // pick teams is up get rid of it safly
        [_teamPick clear];
        [_teamPick dismissPopoverAnimated:NO];
        _teamPick = nil;
    }
    
    if (_cameraPick) {
        [_cameraPick clear];
        [_cameraPick dismissPopoverAnimated:NO];
        _cameraPick = nil;
    }
    
    [_leftArrow removeFromSuperview];
    _leftArrow = nil;
    [_rightArrow removeFromSuperview];
    _rightArrow = nil;
    [_playerDrawerLeft.view removeFromSuperview];
    _playerDrawerLeft = nil;
    [_playerDrawerRight.view removeFromSuperview];
    _playerDrawerRight = nil;
    
    
    Event * nextEvent = [note.object event];
    
    
    if ([nextEvent.name isEqualToString:_currentEvent.name]) {
        [self onEventChange];
        return;
    }
    
    if (_currentEvent != nil) {
        [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_TAG_RECEIVED object:_currentEvent];
        [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_TAG_MODIFIED object:_currentEvent];
        [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_RICO_PLAYER_VIEW_CONTROLLER_UPDATE object:nil];
    }

    if (!_currentEvent.live) {
        [_tagButtonController closeAllOpenTagButtons];
        if ([_bottomViewController respondsToSelector:@selector(closeAllOpenTagButtons)]){
            [_bottomViewController closeAllOpenTagButtons];
        }
    }
    
    if (_currentEvent.live && _appDel.encoderManager.liveEvent == nil) {
        _currentEvent = nil;
        [UserCenter getInstance].taggingTeam = nil;
        [_bottomViewController clear];

    }
    
    if (nextEvent) {
        _currentEvent = nextEvent;//[_appDel.encoderManager.primaryEncoder event];
        [self checkIpadVersion];
        [self turnSwitchOn];
        
        [_tagButtonController allToggleOnOpenTags:_currentEvent];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onTagChanged:) name:NOTIF_TAG_RECEIVED object:_currentEvent];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onTagChanged:) name:NOTIF_TAG_MODIFIED object:_currentEvent];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateOnPlayerTick) name:NOTIF_RICO_PLAYER_VIEW_CONTROLLER_UPDATE object:nil];
        
        
        
    
        [self displayLable];
    }
        _currentEvent = nextEvent;
//    NSOperation * loadOp =     [self.ricoPlayer loadFeed:[_currentEvent.feeds allValues][0]];

        [self onEventChange];
    
    if (_currentEvent) {
        if (_currentEvent.live){
            [self.ricoPlayerViewController live];
            self.ricoFullScreenControlBar.mode = RicoFullScreenModeLive;
            
            
        
        } else {
            [self.ricoPlayerViewController playAtStartWhenReady];
            self.ricoFullScreenControlBar.mode = RicoFullScreenModeEvent;
        }
    }
    self.ricoFullScreen.fullscreen = NO;


        Encoder * enc = (Encoder *)self.currentEvent.parentEncoder;
    EncoderOperation * testOp =  [[EncoderOperationCameraStartTimes alloc]initEncoder:enc data:nil];
    [enc runOperation:testOp];
    
    
    
}


-(void)onTapOnQuad:(id)sender
{
        [self.ricoZoomContainer setZoomScale:1];
    UITapGestureRecognizer * gest = sender;

    RicoPlayerGroupContainer * group =  (RicoPlayerGroupContainer *) gest.view;
    
    if (group.gridMode) {
    
        CGPoint loc = [gest locationInView:group];
        UIView* subview = [group hitTest:loc withEvent:nil];
        
        if ([subview isKindOfClass:[RicoPlayer class]]) {
            RicoPlayer * aPlayer = (RicoPlayer *)subview;
            
            self.telestrationViewController.showsControls = YES;
            NSLog(@"%@",aPlayer.feed.sourceName);
            [self changeSource:aPlayer.feed.sourceName];
            group.gridMode = NO;
            

        }

    } else {
        [self onPressMultiCamButton:self.multiCamButton];
    }
}


-(void)addFeed{
    [_encoderManager.primaryEncoder resetEventAfterRemovingFeed:_currentEvent];
    [_cameraPick clear];
    [_cameraPick dismissPopoverAnimated:NO];
    _cameraPick = nil;
    
    if (_currentEvent.live) {
        [self gotLiveEvent];
    }
    
    _videoBar.event = _currentEvent;
//    _fullscreenViewController.playerViewController.playerView.context = context;
    
    [self addBottomViewController];
    [self addPlayerView];
}

-(void)onTagChanged:(NSNotification *)note
{
    

    
    _bottomViewController.currentEvent = _currentEvent;
    
    if ([_bottomViewController isKindOfClass:[FootballBottomViewController class]]) {
        Tag *tag = [note.userInfo[@"tags"] firstObject];
        if (tag.type == TagTypeNormal || tag.type == TagTypeCloseDuration) {
            
            NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
                SideTagButton *button = evaluatedObject;
                return ([button.titleLabel.text isEqualToString:tag.name]);
            }];
            
            if ([_tagButtonController.tagButtonsLeft filteredArrayUsingPredicate:predicate].count > 0) {
                [_bottomViewController addData:@"left" name:tag.name];
            }else if ([_tagButtonController.tagButtonRight filteredArrayUsingPredicate:predicate].count > 0){
                [_bottomViewController addData:@"right" name:tag.name];

            }
        }
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

-(void)liveEventStopped:(NSNotification*)notification
{
    if (self.currentEvent.live) {
        self.ricoPlayerControlBar.state = RicoPlayerStateDisabled;
    }
    [_appDel.encoderManager declareCurrentEvent:nil];
    

}


// This will have all the code that will init a bottomview controller based of the EventType .... Sport or medical
-(void)onEventTypeChange:(NSString*)aType
{
    _eventType = aType;
}


-(void)onEventChange
{
    self.telestrationViewController.showsControls = YES;
    if (_appDel.encoderManager.liveEvent != nil){
        _gotoLiveButton.enabled = YES;
        [self switchPressed];
    }else if (_currentEvent != nil){
        _gotoLiveButton.enabled = NO;

        [self switchPressed];
    }else if (_currentEvent == nil){
        if (self.telestrationViewController.telestration) {
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_PLAYER_BAR_CANCEL object:nil];
        }
        _gotoLiveButton.enabled = NO;
        [_tagButtonController setButtonState:SideTagButtonModeDisable];
        self.ricoPlayerControlBar.state = RicoPlayerStateDisabled;
        self.telestrationViewController.showsControls = NO;
        [informationLabel setText:@""];
    }
    

    [[RicoPlayerPool instance].pooledPlayers removeAllObjects];


    NSArray * rPlayers = [self.ricoPlayerViewController.players allValues];
    
    for (RicoPlayer * player in rPlayers) {
        [self.ricoPlayerViewController removePlayers:player];
        [player removeFromSuperview];
        [player destroy];

    }
   
    if (!self.currentEvent) {
        return;
    }
    
    NSArray * feeds = [self.currentEvent.feeds allValues];
    

    // Getting user preferences
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * mode =  [defaults objectForKey:@"mode"];

    
    // just make one player
    if ([mode isEqualToString:@"streamOp"]) {
        RicoPlayer * justPlayer = [[RicoPlayer alloc]initWithFrame:CGRectMake(0, 0, MEDIA_PLAYER_WIDTH, MEDIA_PLAYER_HEIGHT)];
        Feed * afeed = feeds[0];

        afeed.quality = 1;

//        self.ricoPlayer = justPlayer;
        
        [justPlayer loadFeed:afeed];

        [self.ricoZoomGroup addSubview:justPlayer];
        [self.ricoPlayerViewController addPlayers:justPlayer];
        [[RicoPlayerPool instance].pooledPlayers addObject:justPlayer];

    
    
    } else if ([mode isEqualToString:@"dual"]){//////////////////////////////////////////////////////////////////
        
        
        NSInteger feedCount = [feeds count];//([feeds count] <4)?4:[feeds count];//
        
        if (feedCount > 2 ) feedCount = 2;
        
        for (NSInteger i = 0; i<feedCount; i++) {
            RicoPlayer * madePlayer = [[RicoPlayer alloc]initWithFrame:CGRectMake(0, 0, MEDIA_PLAYER_WIDTH, MEDIA_PLAYER_HEIGHT)];
            Feed * afeed;
            if ([feeds count] > i){
                afeed = feeds[i];
            }

            [madePlayer loadFeed:afeed];
            if (i)madePlayer.hidden = YES;
            [self.ricoZoomGroup addSubview:madePlayer];
            [self.ricoPlayerViewController addPlayers:madePlayer];
            [[RicoPlayerPool instance].pooledPlayers addObject:madePlayer];
            
        }

        
    } else { ///////////////////////////////////////////////////////////////////////////////////////////////
        
        NSString* (^getSource)(NSString*location) = ^NSString*(NSString*location) {
            FeedMapDisplay * display = [[FeedMapController instance].feedMapDisplaysDict objectForKey:location];
            CameraDetails * cam = display.cameraDetails;
            return cam.source;
        };
        
        
        NSInteger feedCount = [feeds count];//([feeds count] <4)?4:[feeds count];//
        
        for (NSInteger i = 0; i<feedCount; i++) {
            RicoPlayer * madePlayer = [[RicoPlayer alloc]initWithFrame:CGRectMake(0, 0, MEDIA_PLAYER_WIDTH, MEDIA_PLAYER_HEIGHT)];
            Feed * afeed;
            if ([feeds count] > i){
                afeed = feeds[i];
            }
            
            
            Encoder * enc = (Encoder *)_currentEvent.parentEncoder;

            // 1 = highQuality  0 = low quality;
            Feed * tempFeed;
            NSString * camName;
            switch (i) {
                case 0:
                    madePlayer.name     = kQuad1of4;
                    camName             = [enc.cameraResource getCameraNameBy:kQuad1of4];
                    tempFeed            = [enc.cameraResource getFeedByLocation:kQuad1of4 event:_currentEvent];
//                    if (!tempFeed) tempFeed = [enc.cameraResource getFeedByIndex:0 event:_currentEvent];
                    break;
                case 1:
                    madePlayer.name     = kQuad2of4;
                    camName             = [enc.cameraResource getCameraNameBy:kQuad2of4];
                    tempFeed           = [enc.cameraResource getFeedByLocation:kQuad2of4 event:_currentEvent];
//                    if (!tempFeed) tempFeed = [enc.cameraResource getFeedByIndex:1 event:_currentEvent];
                    break;
                case 2:
                    madePlayer.name     = kQuad3of4;
                    camName             = [enc.cameraResource getCameraNameBy:kQuad3of4];
                    tempFeed           = [enc.cameraResource getFeedByLocation:kQuad3of4 event:_currentEvent];
//                    if (!tempFeed) tempFeed = [enc.cameraResource getFeedByIndex:2 event:_currentEvent];
                    break;
                case 3:
                    madePlayer.name     = kQuad4of4;
                    camName             = [enc.cameraResource getCameraNameBy:kQuad4of4];
                    tempFeed           = [enc.cameraResource getFeedByLocation:kQuad4of4 event:_currentEvent];
//                    if (!tempFeed) tempFeed = [enc.cameraResource getFeedByIndex:3 event:_currentEvent];
                    break;
                default:
                    break;
            }

            if (tempFeed)afeed = tempFeed;
            
            if ([mode isEqualToString:@"proxy"]) {
                afeed.quality = 0;
                
            } else if ([mode isEqualToString:@"hq"]) {
                afeed.quality = 1;
            }
            [madePlayer loadFeed:afeed];
            if (i)madePlayer.hidden = YES;
            [self.ricoZoomGroup addSubview:madePlayer];
            [self.ricoPlayerViewController addPlayers:madePlayer];
            [[RicoPlayerPool instance].pooledPlayers addObject:madePlayer];
            
        }

    }
    

    
    [self buildSourceButtons];
}

-(void)buildSourceButtons
{
    
    // clear if made already
    
    if (self.sourceButtonPicker){
        NSInteger indx  = [self.view indexOfAccessibilityElement:self.sourceButtonPicker];
        [self.sourceButtonPicker removeFromSuperview];
        self.sourceButtonPicker.delegate = nil;
        
        self.sourceButtonPicker = [[RicoSourcePickerButtons alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
        self.sourceButtonPicker.delegate = self;
        [self.view addSubview:self.sourceButtonPicker];
    }
    [_sourceNames removeAllObjects];
    
    // build
    [self.sourceButtonPicker setFrame:CGRectMake(155, 62, 300, 30)];
    
    
    CameraResource * camResource = self.currentEvent.cameraResource;
    
    _sourceNames    = [[((Encoder*)_encoderManager.primaryEncoder).event.feeds allKeys]mutableCopy];
    
    
    if ([[[UserCenter getInstance]l2bMode] isEqualToString:L2B_MODE_DUAL]) {
        [_sourceNames sortedArrayUsingSelector:@selector(compare:)];
        NSString *sortOrder = @"AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz_0123456789";
        [_sourceNames sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            char char1 = [(NSString *)obj1 characterAtIndex: 0];
            char char2 = [(NSString *)obj2 characterAtIndex: 0];
            
            int index1;
            for (index1 = 0; index1 < sortOrder.length; index1++)
                if ([sortOrder characterAtIndex: index1] == char1)
                    break;
            
            int index2;
            for (index2 = 0; index2 < sortOrder.length; index2++)
                if ([sortOrder characterAtIndex: index2] == char2)
                    break;
            
            if (index1 < index2)
                return NSOrderedAscending;
            else if (index1 > index2)
                return NSOrderedDescending;
            else
                return [(NSString *)obj1 compare: obj2 options: NSCaseInsensitiveSearch];
        }];
        
        
        if ([_sourceNames count]>2) {
            _sourceNames = [NSMutableArray arrayWithArray:[_sourceNames objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)]]];
        }
        
        
    } else if (![[[UserCenter getInstance]l2bMode] isEqualToString:@"streamOp"]) {
        NSArray * list = @[kQuad1of4,kQuad2of4,kQuad3of4,kQuad4of4];
         [_sourceNames removeAllObjects];
        for (NSInteger i=0;i< [list count]; i++) {
            if (i >= [self.ricoPlayerViewController.players count]) break;
            Feed * feed = [camResource getFeedByLocation:list[i] event:self.currentEvent];
            if (feed)[_sourceNames addObject:feed.sourceName];
        }
    } else {
        [_sourceNames sortedArrayUsingSelector:@selector(compare:)];
        NSString *sortOrder = @"AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz_0123456789";
        [_sourceNames sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            char char1 = [(NSString *)obj1 characterAtIndex: 0];
            char char2 = [(NSString *)obj2 characterAtIndex: 0];
            
            int index1;
            for (index1 = 0; index1 < sortOrder.length; index1++)
                if ([sortOrder characterAtIndex: index1] == char1)
                    break;
            
            int index2;
            for (index2 = 0; index2 < sortOrder.length; index2++)
                if ([sortOrder characterAtIndex: index2] == char2)
                    break;
            
            if (index1 < index2)
                return NSOrderedAscending;
            else if (index1 > index2)
                return NSOrderedDescending;
            else
                return [(NSString *)obj1 compare: obj2 options: NSCaseInsensitiveSearch];
        }];
    }
  
    

    
    
    _currentSource  = [_sourceNames firstObject];
    self.sourceButtonPicker.hidden = ([_sourceNames count]<=1);

    [self.sourceButtonPicker buildButtonsWithString:_sourceNames];
    [self.sourceButtonPicker selectButtonByIndex:0];
    
    if ([_sourceNames count])[self.ricoPlayerViewController setPrimaryPlayerByFeedName:_sourceNames[0]];
    
    
    
    // just make one player and does not
    if (![[[UserCenter getInstance]l2bMode] isEqualToString:@"streamOp"]) {
        if (self.multiCamButton) {
            [self.multiCamButton removeFromSuperview];
        }
        self.multiCamButton = [[ButtonMultiScreen alloc]initWithFrame:CGRectMake(self.sourceButtonPicker.bounds.size.width+8, 0, 40, 30)];
        [self.multiCamButton addTarget:self action:@selector(onPressMultiCamButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.multiCamButton setBackgroundColor:[UIColor lightGrayColor]];
        [self.sourceButtonPicker addSubview:self.multiCamButton];
        [self.sourceButtonPicker setFrame:CGRectMake(self.sourceButtonPicker.frame.origin.x, self.sourceButtonPicker.frame.origin.y, self.sourceButtonPicker.frame.size.width +40, self.sourceButtonPicker.frame.size.height)];
    }

}



-(void)controlBarPlay
{
    if (!_selectedTag || _selectedTag.type == TagTypeTele){
        [self.ricoPlayerViewController cancelPressed:self.ricoPlayerControlBar];
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_PLAYER_BAR_CANCEL object:nil];
    }
}




#pragma mark -
#pragma mark PxpTimeProvider Protocol Methods

- (NSTimeInterval)currentTimeInSeconds
{
    return CMTimeGetSeconds(self.ricoPlayerViewController.primaryPlayer.currentTime);
}

#pragma mark -
#pragma mark PxpTelestrationViewControllerDelegate Protocol Methods

- (void)telestration:(nonnull PxpTelestration *)telestration didStartInViewController:(nonnull PxpTelestrationViewController *)viewController {
    self.telestrationViewController.showsControls = YES;
   _wasPausedBeforeTele = !self.ricoPlayerViewController.isPlaying;
    
    [self.ricoPlayerViewController pause];
//    [self.ricoPlayerViewController seekToTime:self.ricoPlayerViewController.currentTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
//        
//    }];
    telestration.sourceName = self.currentSource;
    self.ricoFullScreenControlBar.controlBar.playPauseButton.paused = YES;
    self.ricoPlayerControlBar.playPauseButton.paused =YES;
    if(self.ricoFullScreen.fullscreen){
        _tagButtonController.leftTray.hidden = YES;
        _tagButtonController.rightTray.hidden = YES;
    }
}

- (void)telestration:(nonnull PxpTelestration *)tele didFinishInViewController:(nonnull PxpTelestrationViewController *)viewController {
    
    _tagButtonController.leftTray.hidden    = NO;
    _tagButtonController.rightTray.hidden   = NO;
    
    if (!_wasPausedBeforeTele){
        [self.ricoPlayerViewController play];
        self.ricoFullScreenControlBar.controlBar.playPauseButton.paused = NO;
        self.ricoPlayerControlBar.playPauseButton.paused =NO;
    }
    
    if (tele.actionStack.count == 0) return ;





    
    NSTimeInterval timeTele = CMTimeGetSeconds([self.ricoPlayerViewController currentTime]) ;//CMTimeGetSeconds([self.ricoPlayerViewController currentTimeFromSourceName:_currentSource]);//

//    tele.sourceName = _currentSource;//self.playerViewController.playerView.activePlayerName;
    NSDictionary * dict = @{
                            @"time":            [NSString stringWithFormat:@"%f",timeTele],
                            @"duration":        @"1",//[NSString stringWithFormat:@"%i",(int)roundf(tele.duration)]
                            @"starttime":       [NSString stringWithFormat:@"%f",timeTele],
                            @"displaytime" :    [NSString stringWithFormat:@"%f",timeTele],
                            @"telestration":    tele.data,
                            @"telesrc":         tele.sourceName
                            };
    
    Encoder * eventEncoder                          = (Encoder *)self.currentEvent.parentEncoder;
    if (!eventEncoder) return;
    EncoderOperation * postTelestationTagOperation  = [[EncoderOperationMakeTelestration alloc]initEncoder:eventEncoder data:dict];
    [eventEncoder runOperation:postTelestationTagOperation];

  
}


#pragma mark -
#pragma mark RicoBaseFullScreen Protocol Methods


-(void)onFullScreenButton:(id)sender
{
    [self.ricoZoomContainer setZoomScale:1];
    [self.ricoFullScreen fullscreenResponseHandler:sender];
//[_videoBar.fullscreenButton addTarget:self.ricoFullScreen action:@selector(fullscreenResponseHandler:) forControlEvents:UIControlEventTouchUpInside];
//    [self.ricoFullScreenControlBar.fullscreenButton             addTarget:self.ricoFullScreen action:@selector(fullscreenResponseHandler:) forControlEvents:UIControlEventTouchUpInside];

}

-(void)onFullScreenShow:(RicoBaseFullScreenViewController*)fullscreenController
{

    self.ricoPlayerViewController.playerControlBar                  = self.ricoFullScreenControlBar.controlBar;
    self.ricoFullScreenControlBar.controlBar.delegate               = self.ricoPlayerViewController;
    self.ricoFullScreenControlBar.controlBar.playPauseButton.paused = self.ricoPlayerControlBar.playPauseButton.paused; // make sure the play pause are the sames state
    
    if (self.telestrationViewController.telestrating){
        _tagButtonController.leftTray.hidden    = YES;
        _tagButtonController.rightTray.hidden   = YES;
    
    }
    

    
    // moving to telestartion to full screen
    
    [self.ricoFullScreen.contentView addSubview:self.telestrationViewController.view];
//    self.telestrationViewController.view.layer.borderWidth = 2;
//    self.telestrationViewController.view.layer.borderColor = [UIColor greenColor].CGColor;
    // temp fix
    
    
    CGRect tempRect = CGRectMake(
                                 self.ricoZoomContainer.frame.origin.x,
                                 self.ricoZoomContainer.frame.origin.y+70,
                                 self.ricoZoomContainer.frame.size.width,
                                 self.ricoZoomContainer.frame.size.height
                                 );
    [self.telestrationViewController.view setFrame:tempRect];
    
    
}

-(void)onFullScreenLeave:(RicoBaseFullScreenViewController*)fullscreenController
{
    
    self.ricoPlayerViewController.playerControlBar      = self.ricoPlayerControlBar;
    self.ricoPlayerControlBar.delegate                  = self.ricoPlayerViewController;
    self.ricoPlayerControlBar.playPauseButton.paused    = self.ricoFullScreenControlBar.controlBar.playPauseButton.paused; // make sure the play pause are the sames state

   

        _tagButtonController.leftTray.hidden    = NO;
        _tagButtonController.rightTray.hidden   = NO;
    
    // moving from telestartion to full screen
    [self.view addSubview:self.telestrationViewController.view];
    

    [self.telestrationViewController.view setFrame:CGRectMake(MEDIA_PLAYER_X, MEDIA_PLAYER_Y, MEDIA_PLAYER_WIDTH, MEDIA_PLAYER_HEIGHT)];
        [self.ricoZoomContainer setZoomScale:1];
}



#pragma mark -
#pragma mark Normal Methods

-(void)gotLiveEvent
{
  
    LeagueTeam *homeTeam = [_currentEvent.teams objectForKey:@"homeTeam"];
    LeagueTeam *awayTeam = [_currentEvent.teams objectForKey:@"visitTeam"];
    NSDictionary *team = @{homeTeam.name:homeTeam,awayTeam.name:awayTeam};
    
//    _teamPick = [[ListPopoverController alloc] initWithMessage:NSLocalizedString(@"Please select the team you want to tag:", @"dev comment - asking user to pick a team") buttonListNames:@[[[team allKeys]firstObject], [[team allKeys]lastObject]]];
   
    _teamPick = [[ListPopoverController alloc] initWithMessage:NSLocalizedString(@"Please select the team you want to tag:", @"dev comment - asking user to pick a team") buttonListNames:@[homeTeam.name, awayTeam.name]];
   
    
    __block RicoLive2BenchViewController *weakSelf = self;
    [_teamPick addOnCompletionBlock:^(NSString *pick){
        
        [UserCenter getInstance].taggingTeam = [team objectForKey:pick];
        [weakSelf displayLable];
        [weakSelf addBottomViewController];
        [weakSelf addPlayerView];
        [[NSNotificationCenter defaultCenter]postNotificationName: NOTIF_SELECT_TAB          object:nil
                                                         userInfo:@{@"tabName":@"Live2Bench"}];
        
        
        NSArray * temp = [weakSelf.currentEvent.tags copy];
        
        for (id<TagProtocol> theTag in temp) {
            if ([UserCenter getInstance].role == 0) {
                continue;
            } else if (![theTag userTeam]) {
                continue;
            } else {
                if (![[theTag userTeam]isEqualToString:[UserCenter getInstance].taggingTeam.name]) {
                    [weakSelf.currentEvent.tags removeObject:theTag];
                }
            }
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_TAG_RECEIVED object:weakSelf.currentEvent];
        
        
    }];
    [_teamPick presentPopoverCenteredIn:[UIApplication sharedApplication].keyWindow.rootViewController.view
                               animated:YES];
    
    


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
    
    _leftArrow = [[UIImageView alloc]initWithImage:[[UIImage imageNamed:@"ortrileft.png"] imageBlendedWithColor:PRIMARY_APP_COLOR]];
    [_leftArrow setContentMode:UIViewContentModeScaleAspectFit];
    [_leftArrow setAlpha:1.0f];
    [self.view addSubview:_leftArrow];
    [_leftArrow setHidden:true];
    
    _playerDrawerLeft = [[ContentViewController alloc] initWithPlayerList:playerList];
    [_playerDrawerLeft.view.layer setBorderColor:PRIMARY_APP_COLOR.CGColor];
    [_playerDrawerLeft.view.layer setBorderWidth:1.0f];
    [_playerDrawerLeft.view setBackgroundColor:[UIColor whiteColor]];
    
    _rightArrow = [[UIImageView alloc]initWithImage:[[UIImage imageNamed:@"ortriright.png"] imageBlendedWithColor:PRIMARY_APP_COLOR]];
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
/**
 *  This sets the video player and all its pip to live
 */

- (void)goToLive
{
    self.ricoPlayerViewController.slomo                 = NO;
    self.ricoFullScreenControlBar.slomoButton.slomoOn   = NO;
    _videoBar.slomoButton.slomoOn                       = NO;
    
    
//    self.ricoPlayerControlBar.state                     = RicoPlayerStateNormal;
//    self.ricoFullScreenControlBar.controlBar.state      = RicoPlayerStateNormal;
    
    
    
    
    
    
    
    
    PXPLog(@"Pressed Live Button");
    
    [self.ricoPlayerViewController cancelPressed:self.ricoPlayerControlBar];
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_PLAYER_BAR_CANCEL object:nil];
    if (_currentEvent.live) {
        PXPDeviceLog(@"LIVE PRESSED");
        [self.ricoPlayerViewController live];

        return;
    } else {
        PXPDeviceLog(@"LIVE PRESSED changing event...");
    }
    self.ricoPlayerControlBar.state = RicoPlayerStateLive;
    self.ricoFullScreenControlBar.controlBar.state = RicoPlayerStateLive;
    [_appDel.encoderManager declareCurrentEvent:_appDel.encoderManager.liveEvent];
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_TAG_RECEIVED object:_appDel.encoderManager.liveEvent];
    [_tagButtonController closeAllOpenTagButtons];
    
    if ([_bottomViewController respondsToSelector:@selector(closeAllOpenTagButtons)]){
        [_bottomViewController closeAllOpenTagButtons];
    }

    
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
    _tagButtonController.delegate = self;
    [self addChildViewController:_tagButtonController];
    [_tagButtonController didMoveToParentViewController:self];
       
    NSArray * tNames = [_userCenter.tagNames copy]; //self.tagNames;
    [_tagButtonController inputTagData:tNames];

    //Add Actions
    [_tagButtonController addActionToAllTagButtons:@selector(tagButtonSelected:) addTarget:self forControlEvents:UIControlEventTouchUpInside];
    [_tagButtonController addActionToAllTagButtons:@selector(tagButtonSwiped:) addTarget:self forControlEvents:UIControlEventTouchDragOutside];

    if (_currentEvent) {
        if (durationSwitch.on == true ) {
            [_tagButtonController setButtonState:SideTagButtonModeToggle];
        }else if(durationSwitch.on == false){
            [_tagButtonController setButtonState:SideTagButtonModeRegular];
        }
    }

}

-(void)tagButtonSwiped:(id)sender{
     SideTagButton *button = sender;

    if ([button.accessibilityValue isEqualToString:@"left"] && _leftArrow.hidden && [_playerDrawerLeft.playerList count]) {
        [self.view addSubview:_playerDrawerLeft.view];
        [_leftArrow setFrame:CGRectMake(button.center.x+button.frame.size.width/2, button.center.y+button.frame.size.height/2+77, 15, 15)];
        [_playerDrawerLeft assignFrame:CGRectMake(_leftArrow.center.x+_leftArrow.frame.size.width/2, button.center.y+button.frame.size.height/2+69, 300, 110)];
        [_leftArrow setHidden:false];
    }else if ([button.accessibilityValue isEqualToString:@"right"] && _rightArrow.hidden && [_playerDrawerRight.playerList count]){
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

    NSTimeInterval currentTime =     CMTimeGetSeconds(self.ricoPlayerViewController.primaryPlayer.currentTime);
    
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
                                                                                         @"time":[NSString stringWithFormat:@"%f",currentTime],
                                                                                         @"type":[NSNumber numberWithInteger:TagTypeNormal]
                                                                                         }];
        if (_bottomViewController && [_bottomViewController respondsToSelector:@selector(currentPeriod)]) {
            [userInfo setObject:[_bottomViewController currentPeriod] forKey:@"period"];
        }
        
        if (players.count > 0) {
            [userInfo setObject:players forKey:@"players"];
        }
        
        id<EncoderProtocol>  eventEncoder = self.currentEvent.parentEncoder;
        EncoderOperation * postTagOperation = [[EncoderOperationMakeTag alloc]initEncoder:eventEncoder data:[userInfo copy]];
        [postTagOperation setCompletionBlock:^{
            NSLog(@"made done");
        }];
               [eventEncoder runOperation:postTagOperation];
        
        
        
//        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_TAG_POSTED object:self userInfo:[userInfo copy]];
        
    } else if (button.mode == SideTagButtonModeToggle && !button.isOpen) {

        durationSwitch.enabled = NO;


        button.isBusy = YES;
        [_tagButtonController onEventChange:_currentEvent];

        button.isOpen = YES;
        
        button.durationView.timeLabel.text = [Utility translateTimeFormat:0];
        button.durationView.startTime = currentTime;
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
        
        Encoder * eventEncoder = (Encoder *)self.currentEvent.parentEncoder;
        EncoderOperation * postTagOperation = [[EncoderOperationMakeTag alloc]initEncoder:eventEncoder data:[userInfo copy]];
        [eventEncoder runOperation:postTagOperation];
        
               
       

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
        

        NSMutableDictionary * tagData   = [NSMutableDictionary dictionaryWithDictionary:[tagToBeClosed makeTagData]];
        
        [tagData setValue:[NSString stringWithFormat:@"%f",currentTime] forKey:@"closetime"];
        [tagData setValue:[NSNumber numberWithInteger:TagTypeCloseDuration] forKey:@"type"];
        [tagData setValue:button.durationID forKey:@"dtagid"];
        [tagData removeObjectForKey:@"duration"];
        
        
        tagToBeClosed.type = TagTypeCloseDuration;
        tagToBeClosed.closeTime = currentTime;
        tagToBeClosed.duration = (int)(tagToBeClosed.closeTime - tagToBeClosed.startTime);
//        tagToBeClosed.durationID = button.durationID;

        Encoder * eventEncoder = (Encoder *)self.currentEvent.parentEncoder;
        EncoderOperation * closeTagOperation = [[EncoderOperationCloseTag alloc]initEncoder:eventEncoder tag:tagToBeClosed];
        
        if ([[UserCenter getInstance].tagsFlaggedForAutoDownload containsObject:tagToBeClosed.name]) {
            //TODO: add download operation
//            EncoderOperation * mp4Request = [EncoderOperationMakeMP4fromTag alloc]initEncoder:eventEncoder data:<#(NSDictionary *)#>
            
        }
        
        
        [eventEncoder runOperation:closeTagOperation];

        button.isOpen = NO;
    }
    

    
}


-(void) switchPressed
{
    if (durationSwitch.on == true &&_currentEvent) {
        [_tagButtonController setButtonState:SideTagButtonModeToggle];
        if([_bottomViewController respondsToSelector:@selector(setIsDurationVariable:)]){
            [_bottomViewController setIsDurationVariable:SideTagButtonModeToggle];
        }
    }else if(durationSwitch.on == false &&_currentEvent){
        [_tagButtonController setButtonState:SideTagButtonModeRegular];
        if([_bottomViewController respondsToSelector:@selector(setIsDurationVariable:)]){
            [_bottomViewController setIsDurationVariable:SideTagButtonModeRegular];
        }
    }
}

-(void) turnSwitchOn
{
    for (Tag *tag in _currentEvent.tags) {
        if (tag.type == TagTypeOpenDuration && [tag.deviceID isEqualToString:[[[UIDevice currentDevice] identifierForVendor]UUIDString]] ) {
            [durationSwitch setOn:YES];
            [self switchPressed];
            return;
        }
    }
    

    
}


#pragma mark _ PLAY CLIP FROM CLIP VIEW
- (void)clipViewPlayFeedNotification:(NSNotification *)note {
    
    // clear clip if one was playing
    self.ricoFullScreenControlBar.mode  = RicoFullScreenModeEvent;

    self.ricoPlayerControlBar.state     = RicoPlayerStateNormal;
    _selectedTag = nil;
    
    
    
    if ([note.userInfo[@"context"] isEqualToString: STRING_LIVE2BENCH_CONTEXT]) {
        Feed *feed                  = note.userInfo[@"feed"];
        _selectedTag                = note.userInfo[@"tag"];
        
        
        
        NSString * sourceName = (feed.sourceName)?feed.sourceName:@"onlySource";
        
        [self.sourceButtonPicker selectButtonByString:sourceName];
        [self.ricoPlayerViewController playTag:_selectedTag];
        
        
        self.ricoFullScreenControlBar.mode                      = RicoFullScreenModeClip;
        self.ricoFullScreenControlBar.currentTagLabel.text      = _selectedTag.name;
        self.ricoFullScreenControlBar.controlBar.range          = self.ricoPlayerControlBar.range;

        PxpTelestration *tele                                   = _selectedTag.telestration;
        if (tele) {
            self.ricoPlayerControlBar.state = RicoPlayerStateTelestrationStill;
            self.ricoFullScreenControlBar.controlBar.state = RicoPlayerStateTelestrationStill;
            [self.ricoPlayerViewController pause];
        }
        self.telestrationViewController.telestration = !feed.sourceName || tele.sourceName == feed.sourceName || [tele.sourceName isEqualToString:feed.sourceName] ? tele : nil;
    }
}


-(void)clipCancelNotification:(NSNotification *)note {
    if (self.ricoPlayerControlBar.state == RicoPlayerStateTelestrationStill) {
        [self.ricoPlayerViewController play];
    
    }
    self.ricoFullScreenControlBar.mode = RicoFullScreenModeEvent;
    self.ricoFullScreenControlBar.controlBar.range = kCMTimeRangeInvalid;
    self.ricoPlayerControlBar.state = RicoPlayerStateNormal;
    self.ricoPlayerControlBar.range = kCMTimeRangeInvalid;

    _selectedTag = nil;
    self.telestrationViewController.telestration = nil;
}





#pragma mark - tempButton press methods

-(void)startGame:(id)sender
{
    NSLog(@"%s",__FUNCTION__);

}


- (void)seekPressed:(SeekButton *)sender {
    
    if (self.telestrationViewController.telestration) {
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_PLAYER_BAR_CANCEL object:nil];
    }
    
    CMTime  sTime = CMTimeMakeWithSeconds(sender.speed, NSEC_PER_SEC);
    CMTime  cTime = self.ricoPlayerViewController.primaryPlayer.currentTime;

    
    // This is changes the scrub bar to
    if (self.ricoFullScreenControlBar.controlBar.state == RicoPlayerStateLive){
        self.ricoFullScreenControlBar.controlBar.state = self.ricoPlayerControlBar.state = RicoPlayerStateNormal;
    }
    
    if (self.currentEvent.local) {
        if (sender.speed < 0.25 && sender.speed > -0.25) {
            [self.ricoPlayerViewController pause];
            self.ricoPlayerViewController.playerControlBar.playPauseButton.paused = YES;
            [self.ricoPlayerViewController stepByCount:(sender.speed>0)?1:-1];
            
        } else if (sender.speed < 1 && sender.speed > -1) {
            [self.ricoPlayerViewController seekToTime:CMTimeAdd(cTime, sTime) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:nil];
            
        } else if (sender.speed < 5 && sender.speed > -5) {
            [self.ricoPlayerViewController seekToTime:CMTimeAdd(cTime, sTime) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:nil];
            
        } else {
            [self.ricoPlayerViewController seekToTime:CMTimeAdd(cTime, sTime) toleranceBefore:kCMTimePositiveInfinity toleranceAfter:kCMTimePositiveInfinity completionHandler:nil];
        }
        
    } else {
    
        [self.ricoPlayerViewController seekToTime:CMTimeAdd(cTime, sTime) toleranceBefore:kCMTimePositiveInfinity toleranceAfter:kCMTimePositiveInfinity completionHandler:nil];
    }
}

- (void)slomoPressed:(Slomo *)slomo {
    if (self.telestrationViewController.telestration) {
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_PLAYER_BAR_CANCEL object:nil];
    }
  
    BOOL toggle = !slomo.slomoOn;

    self.ricoFullScreenControlBar.slomoButton.slomoOn   = toggle;
    _videoBar.slomoButton.slomoOn                       = toggle;
    
    self.ricoPlayerControlBar.state                     = RicoPlayerStateNormal;
    self.ricoFullScreenControlBar.controlBar.state      = RicoPlayerStateNormal;

    self.ricoFullScreenControlBar.slomoButton.slomoOn   = slomo.slomoOn;
    self.ricoPlayerViewController.slomo                 = slomo.slomoOn;

}


- (void)extendStartAction:(UIButton *)button {
    if (_selectedTag) {
        if ([[LocalMediaManager getInstance]getClipByTag:_selectedTag scrKey:nil]){
            Clip * clipToSeverFromEvent = [[LocalMediaManager getInstance]getClipByTag:_selectedTag scrKey:nil];
            [[LocalMediaManager getInstance] breakTagLink:clipToSeverFromEvent];
        }
        
        
        float newStartTime = 0;
        float endTime = _selectedTag.startTime + _selectedTag.duration;
        
        //extend the duration by decreasing the start time 5 seconds
        newStartTime = _selectedTag.startTime - 5;
        //if the new start time is smaller than 0, set it to 0
        if (newStartTime <0) {
            newStartTime = 0;
        }
        
        //set the new duration to tag end time minus new start time
        int newDuration = endTime - newStartTime;
        
        _selectedTag.startTime = newStartTime;
        
        if (newDuration > _selectedTag.duration) {
            _selectedTag.duration = newDuration;
//            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MODIFY_TAG object:_selectedTag];
            
            Encoder * eventEncoder = (Encoder *)self.currentEvent.parentEncoder;
            EncoderOperation * modTagOperation = [[EncoderOperationModTag alloc]initEncoder:eventEncoder tag:_selectedTag];
            [eventEncoder runOperation:modTagOperation];

            
        }
        
        
        NSArray * list = [self.ricoPlayerViewController.players allValues];
        RicoPlayer * p = (RicoPlayer *)[list firstObject];
        CMTimeRange range = p.range;
        CMTime t1 = CMTimeMake(5, range.start.timescale);

        
        range.start     = CMTimeAdd(range.start,    t1);

        
        range = CMTimeRangeMake( CMTimeAdd(range.start,    CMTimeMake(-5,1))  , CMTimeAdd(range.duration, CMTimeMake(5,1)));
        
        
        for (RicoPlayer * player in list) {
            [player setRange:range];
        }
        
        self.ricoPlayerControlBar.range                 = range;
        [self.ricoPlayerControlBar update:range.start duration:range.duration];
        self.ricoFullScreenControlBar.controlBar.range  = range;
        [self.ricoFullScreenControlBar.controlBar update:range.start duration:range.duration];
    }
}

- (void)extendEndAction:(UIButton *)button {
    if (_selectedTag) {
        if ([[LocalMediaManager getInstance]getClipByTag:_selectedTag scrKey:nil]){
            Clip * clipToSeverFromEvent = [[LocalMediaManager getInstance]getClipByTag:_selectedTag scrKey:nil];
            [[LocalMediaManager getInstance] breakTagLink:clipToSeverFromEvent];
        }
        
        float startTime = _selectedTag.startTime;
        
        float endTime = startTime + _selectedTag.duration;
        
        //increase end time by 5 seconds
        endTime = endTime + 5;
        //if new end time is greater the duration of video, set it to the video's duration
        
        RicoPlayer * mainPlayer =         self.ricoPlayerViewController.primaryPlayer;

        if (endTime > CMTimeGetSeconds(mainPlayer.duration)) {
            endTime = CMTimeGetSeconds(mainPlayer.duration);
        }
        
        //get the new duration
        int newDuration = newDuration = endTime - startTime;
        if (newDuration > _selectedTag.duration) {
            _selectedTag.duration = newDuration;
//            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MODIFY_TAG object:_selectedTag];
            Encoder * eventEncoder = (Encoder *)self.currentEvent.parentEncoder;
            EncoderOperation * modTagOperation = [[EncoderOperationModTag alloc]initEncoder:eventEncoder tag:_selectedTag];
            [eventEncoder runOperation:modTagOperation];
        }
        
        
        
        NSArray * list = [self.ricoPlayerViewController.players allValues];
        CMTimeRange range = mainPlayer.range;
        CMTime t1 = CMTimeMake(5, 1);

        range = CMTimeRangeMake(range.start, CMTimeAdd(range.duration, t1));
        
        for (RicoPlayer * player in list) {
            [player setRange:range];
        }
        

        self.ricoPlayerControlBar.range                 = range;
        [self.ricoPlayerControlBar update:range.start duration:range.duration];
        self.ricoFullScreenControlBar.controlBar.range  = range;
        [self.ricoFullScreenControlBar.controlBar update:range.start duration:range.duration];
    }
    
    
    
}


-(void)frameByFrame:(id)sender{
    
    if (self.telestrationViewController.telestration) {
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_PLAYER_BAR_CANCEL object:nil];
    }
    
    float speed = ([((UIButton*)sender).titleLabel.text isEqualToString:@"FB"] )?-1.10:1.10;
    [self.ricoPlayerViewController stepByCount:speed];
    
//    [self.ricoPlayerViewController pause];
//    self.ricoPlayerViewController.playerControlBar.playPauseButton.paused = YES;
//    float speed = ([((UIButton*)sender).titleLabel.text isEqualToString:@"FB"] )?-0.10:0.10;
//    
//    CMTime  sTime = CMTimeMakeWithSeconds(speed, NSEC_PER_SEC);
//    CMTime  cTime = self.ricoPlayerViewController.primaryPlayer.currentTime;
////    self.ricoFullScreenControlBar.controlBar.state = self.ricoPlayerControlBar.state = RicoPlayerStateNormal;
//    
//    if (self.currentEvent.local) {
//        [self.ricoPlayerViewController pause];
//        [self.ricoPlayerViewController stepByCount:(speed>0)?1:-1];
//    } else {
//        [self.ricoPlayerViewController seekToTime:CMTimeAdd(cTime, sTime) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:nil];
//    }
//
    
    
}


@end

