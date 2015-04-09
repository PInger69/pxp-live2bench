
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
    
    // some old stuff
    TTSwitch                            * durationTagSwitch;
    UILabel                             * durationTagLabel;
    UIButton                            * multiButton;
    UIPinchGestureRecognizer            * pinchGesture;
    UISwipeGestureRecognizer            * swipeGesture;
    
    
    //TemporaryButton
//    UIButton                            *zoomButton;
//    UIButton                            *unZoomButton;
    
    
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
        [self setMainSectionTab:@"Live2Bench" imageName:@"live2BenchTab"];
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
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(gotLiveEvent) name:NOTIF_MASTER_HAS_LIVE object:nil];

    
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
    
    // BOTTOM VIEW CONTROLLER CODE!
    // TO DO:
    
    
    
    
    return self;
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

// when the event changes mod these
-(void)onEventChange
{

    if ([_encoderManager.currentEvent isEqualToString:@"None"]){
        [_videoBarViewController setBarMode:L2B_VIDEO_BAR_MODE_DISABLE];
        self.videoPlayer.live   = NO;
        [_gotoLiveButton isActive:NO];
        _tagButtonController.enabled = NO;

    } else if ([_encoderManager.currentEvent isEqualToString:_encoderManager.liveEventName]){      // LIVE
        [_videoBarViewController setBarMode:L2B_VIDEO_BAR_MODE_LIVE];
        self.videoPlayer.live   = YES;
        [_gotoLiveButton isActive:YES];
        _tagButtonController.enabled = YES;
        if (!self.videoPlayer.feed) {
            [self.videoPlayer playFeed:_feedSwitch.primaryFeed];
            [self.videoPlayer play];
        }
        
    } else if (_encoderManager.currentEvent == nil) { // CLIPs and playing back old events
        [_videoBarViewController setBarMode:L2B_VIDEO_BAR_MODE_DISABLE];
        self.videoPlayer.live   = NO;
        [_gotoLiveButton isActive:NO]; // TODO
        _tagButtonController.enabled = NO;
    } else { // CLIPs and playing back old events
        [_videoBarViewController setBarMode:L2B_VIDEO_BAR_MODE_CLIP];
        self.videoPlayer.live   = NO;
        [_gotoLiveButton isActive:YES]; // TODO
        _tagButtonController.enabled = YES;
    }
    
    [multiButton setHidden:!([_encoderManager.feeds count]>1)];
    
}

-(void)gotLiveEvent
{
    [_videoBarViewController setBarMode:L2B_VIDEO_BAR_MODE_LIVE];
    self.videoPlayer.live   = YES;
    [_gotoLiveButton isActive:YES];
    _tagButtonController.enabled = YES;
}

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
                _fullscreenViewController.enable = NO;
                [_pipController.multi normalScreen];
//                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SMALLSCREEN object:self userInfo:@{@"context":_context,@"animated":[NSNumber numberWithBool:YES]}];
            }
        }
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
    [self createTagButtons];

    
    
    
    self.videoPlayer = [[RJLVideoPlayer alloc] initWithFrame:CGRectMake(156, 100, MEDIA_PLAYER_WIDTH, MEDIA_PLAYER_HEIGHT)];
    pinchGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinchGuesture:)];
    [self.view addGestureRecognizer:pinchGesture];
    
    swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeNoticed:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionUp;
    swipeGesture.numberOfTouchesRequired = 3;
    [self.videoPlayer.view addGestureRecognizer: swipeGesture];
    [[((RJLVideoPlayer *)self.videoPlayer).zoomManager panGestureRecognizer] requireGestureRecognizerToFail: swipeGesture];
    
    
    // side tags
    _tagButtonController = [[Live2BenchTagUIViewController alloc]initWithView:self.view];
    [self addChildViewController:_tagButtonController];
    [_tagButtonController didMoveToParentViewController:self];
    
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
    [_fullscreenViewController.teleButton       addTarget:self action:@selector(initTele:)      forControlEvents:UIControlEventTouchUpInside];
    

    self.videoPlayer.playerContext      = STRING_LIVE2BENCH_CONTEXT;
    
    [_fullscreenViewController setMode: L2B_FULLSCREEN_MODE_DEMO];
    // so get buttons are connected to full screen
    _tagButtonController.fullScreenViewController = _fullscreenViewController;

    _pip            = [[Pip alloc]initWithFrame:CGRectMake(50, 50, 200, 150)];
    _pip.isDragAble  = YES;
    _pip.hidden      = YES;
    _pip.muted       = YES;
    _pip.dragBounds  = self.videoPlayer.view.frame;
    [self.videoPlayer.view addSubview:_pip];
    
    _feedSwitch     = [[FeedSwitchView alloc]initWithFrame:CGRectMake(156+100, 59, 100, 38) encoderManager:_encoderManager];
    
    _pipController  = [[PipViewController alloc]initWithVideoPlayer:self.videoPlayer f:_feedSwitch encoderManager:_encoderManager];
    _pipController.context = STRING_LIVE2BENCH_CONTEXT;
    
    [_pipController addPip:_pip];
    [_pipController viewDidLoad];
    [self.view addSubview:_feedSwitch];
    [_feedSwitch setHidden:!([_encoderManager.feeds count]>1)];
    
    // multi button
    multiButton =[[UIButton alloc]initWithFrame:CGRectMake(156, 59, 100, 38)];
    [multiButton setTitle:@"Multi" forState:UIControlStateNormal];
    [multiButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [multiButton addTarget:_pipController action:@selector(onButtonPressMulti:) forControlEvents:UIControlEventTouchUpInside];
    multiButton.layer.borderWidth = 1;
    [self.view addSubview:multiButton];
    [multiButton setHidden:!([_encoderManager.feeds count]>1)];
    
    _gotoLiveButton = [[LiveButton alloc]initWithFrame:CGRectMake(MEDIA_PLAYER_WIDTH +self.videoPlayer.view.frame.origin.x+32,PADDING + self.videoPlayer.view.frame.size.height + 95, 130, LITTLE_ICON_DIMENSIONS)];
    [_gotoLiveButton addTarget:self action:@selector(goToLive) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_gotoLiveButton];
        [_gotoLiveButton isActive:NO];
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(masterLost:)               name:NOTIF_ENCODER_MASTER_HAS_FALLEN object:nil];
    
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

/**
 *  This is run when the Main Encoder is removed
 *
 *  @param note
 */
-(void)masterLost:(NSNotification*)note
{
    if (_encoderManager.primaryEncoder != _encoderManager.masterEncoder) return;
    
    if (_encoderManager.liveEventName == nil  && _encoderManager.currentEvent == nil){
        [self restartPlayer];
        CustomAlertView * alert = [[CustomAlertView alloc]initWithTitle:@"Encoder Status" message:@"Encoder connection lost" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [[alert alertType:AlertAll] show];
        
        [multiButton setHidden:!([_encoderManager.feeds count]>1)];
    }
}


-(void)viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:animated];


    
    if (!self.videoPlayer.feed && _encoderManager.currentEvent != nil) {
     [self.videoPlayer playFeed:_feedSwitch.primaryFeed];
    }

//    [currentEventTitle setNeedsDisplay];
    
    
    // maybe this should be part of the videoplayer
     if( !(self.videoPlayer.view.superview == self.view) )
     {
         [self.videoPlayer.view setFrame:CGRectMake((self.view.bounds.size.width - MEDIA_PLAYER_WIDTH)/2, 100.0f, MEDIA_PLAYER_WIDTH, MEDIA_PLAYER_HEIGHT)];
         [self.view addSubview:self.videoPlayer.view];
         [_videoBarViewController viewDidAppear:animated];
         
         [self.videoPlayer play];
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
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_ENCODER_COUNT_CHANGE object:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_ENCODER_FEED_HAVE_CHANGED object:nil];
    [self onEventChange];

}

-(void)viewWillDisappear:(BOOL)animated
{
    [CustomAlertView removeAll];
    [_videoBarViewController.tagMarkerController cleanTagMarkers];
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SMALLSCREEN object:self userInfo:@{@"context":self.videoPlayer.playerContext,@"animated":[NSNumber numberWithBool:NO]}];
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
    [_pipController pipsAndVideoPlayerToLive];
    [_videoBarViewController.tagMarkerController cleanTagMarkers];
    [_videoBarViewController.tagMarkerController createTagMarkers];
}

/**
 *  This creates the side tag buttons from the userCenter
 */
- (void)createTagButtons
{
    NSArray * tNames = [_userCenter.tagNames copy]; //self.tagNames;
    [_tagButtonController inputTagData:tNames];
    
    //Add Actions
    [_tagButtonController addActionToAllTagButtons:@selector(tagButtonSelected:) addTarget:self forControlEvents:UIControlEventTouchUpInside];
//    if ([_eventType isEqualToString:SPORT_FOOTBALL_TRAINING]) {
//        [_tagButtonController addActionToAllTagButtons:@selector(showFootballTrainingCollection:) addTarget:self forControlEvents:UIControlEventTouchDragOutside];
//    } else {
//        [_tagButtonController addActionToAllTagButtons:@selector(showPlayerCollection:) addTarget:self forControlEvents:UIControlEventTouchDragOutside];
//    }
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
    [self.videoPlayer.view removeFromSuperview];
    self.videoPlayer                        = nil;
    self.videoPlayer                        = [[RJLVideoPlayer alloc] initWithFrame:CGRectMake(156, 100, MEDIA_PLAYER_WIDTH, MEDIA_PLAYER_HEIGHT)];
    self.videoPlayer.playerContext          = STRING_LIVE2BENCH_CONTEXT;
    _videoBarViewController.videoPlayer     = self.videoPlayer;
    _pipController.videoPlayer              = self.videoPlayer;
    _fullscreenViewController.player        = self.videoPlayer;

    [self.videoPlayer.view addSubview:_pip];
    [self.view addSubview:self.videoPlayer.view];
}


- (void)didReceiveMemoryWarning
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_RECEIVE_MEMORY_WARNING object:self userInfo:nil];
    [super didReceiveMemoryWarning];
}

@end

