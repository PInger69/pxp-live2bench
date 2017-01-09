
//
//  Live2BenchViewController.m
//  Live2BenchNative
//
//  Created by DEV on 2013-01-21.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "Live2BenchViewController.h"
#import <UIKit/UIKit.h>

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

#define MEDIA_PLAYER_WIDTH    712
#define MEDIA_PLAYER_HEIGHT   400
#define LITTLE_ICON_DIMENSIONS 40
#define PADDING                 5


@interface Live2BenchViewController () <PxpTelestrationViewControllerDelegate, PxpTimeProvider>

@property (strong, nonatomic, nonnull) PxpTelestrationViewController    * telestrationViewController;
@property (strong, nonatomic, nonnull) PxpPlayerViewController          * playerViewController;
@property (strong, nonatomic, nonnull) PxpL2BFullscreenViewController   * fullscreenViewController;
@property (strong, nonatomic, nonnull) NSMutableArray                   * sourceButtons;

@end


@implementation Live2BenchViewController{
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
    PxpVideoBar                         * _videoBar;
}

// Context
static void * eventTypeContext  = &eventTypeContext;
static void * eventContext      = &eventContext;

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
    _eventType              = mainappDelegate.encoderManager.currentEventType; // TODO is this redundant
    _userCenter             = mainappDelegate.userCenter;

    self = [super initWithAppDelegate:mainappDelegate];
    if (self) {
        [self setMainSectionTab:NSLocalizedString(@"Live2Bench", nil) imageName:@"live2BenchTab"];
        
        _playerViewController           = [[PxpPlayerViewController alloc] init];

        _fullscreenViewController       = [[PxpL2BFullscreenViewController alloc] initWithPlayerViewController:_playerViewController];
        [_fullscreenViewController.liveButton addTarget:self action:@selector(goToLive) forControlEvents:UIControlEventTouchUpInside];
    }
  
    // Observers
    [_encoderManager addObserver:self forKeyPath:NSStringFromSelector(@selector(currentEventType))  options:NSKeyValueObservingOptionNew context:&eventTypeContext];
    [_encoderManager addObserver:self forKeyPath:NSStringFromSelector(@selector(currentEvent))      options:NSKeyValueObservingOptionNew context:&eventContext];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(createTagButtons)              name:NOTIF_SIDE_TAGS_READY_FOR_L2B  object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(addEventObserver:)             name:NOTIF_PRIMARY_ENCODER_CHANGE   object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(tabJustBeingAdded:)            name:NOTIF_TAB_CREATED              object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(clipViewPlayFeedNotification:) name:NOTIF_SET_PLAYER_FEED          object:nil];
    _sourceButtons = [NSMutableArray new];
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addChildViewController:_playerViewController];
    [self addChildViewController:_fullscreenViewController];
    
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
    
    self.playerViewController.telestrationViewController.delegate = self;
    self.playerViewController.view.frame = CGRectMake(156, 100, MEDIA_PLAYER_WIDTH, MEDIA_PLAYER_HEIGHT);
    [self.view addSubview:self.playerViewController.view];
    
    _gotoLiveButton         = [[LiveButton alloc]initWithFrame:CGRectMake(MEDIA_PLAYER_WIDTH +self.playerViewController.view.frame.origin.x+32,PADDING + self.playerViewController.view.frame.size.height + 95, 130, LITTLE_ICON_DIMENSIONS)];
    _gotoLiveButton.enabled = NO;
    [_gotoLiveButton addTarget:self action:@selector(goToLive) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_gotoLiveButton]; // redundant?

    _videoBar       = [[PxpVideoBar alloc] init];
    _videoBar.frame = CGRectMake(_playerViewController.view.frame.origin.x, _playerViewController.view.frame.origin.y + _playerViewController.view.frame.size.height, _playerViewController.view.frame.size.width, 40.0);
    [self.view addSubview:_videoBar]; // redundant?
    
    [self.view addSubview:_fullscreenViewController.view]; // redundant?
    
    [_videoBar.fullscreenButton addTarget:_fullscreenViewController action:@selector(fullscreenResponseHandler:) forControlEvents:UIControlEventTouchUpInside];
    _videoBar.playerViewController = _playerViewController;
    
    [_playerViewController.fullscreenGestureRecognizer addTarget:_fullscreenViewController action:@selector(fullscreenResponseHandler:)];
    _playerViewController.telestrationViewController.stillMode  = YES;
    _playerViewController.playerView.context                    = _appDel.encoderManager.primaryEncoder.eventContext;
    
    
    
    UIButton * analiyzeButton = [[UIButton alloc]initWithFrame:CGRectMake(10,500, 50, 50)];
    analiyzeButton.layer.borderWidth = 1;
    [analiyzeButton addTarget:self action:@selector(onAnalyze:) forControlEvents:UIControlEventTouchUpInside];
   // if(DEBUG_MODE)[self.view addSubview:analiyzeButton];
    

    [self buildSourceButtons];
    
//    UIButton * scrButton = [[UIButton alloc]initWithFrame:CGRectMake(155, 55, 44, 44)];
//    [scrButton addTarget:self action:@selector(onPressSourceButton:) forControlEvents:UIControlEventTouchUpInside];
//    scrButton.tag = 1;
//    [_sourceButtons addObject:scrButton];
//    scrButton.layer.borderWidth = 1;
//    scrButton.layer.cornerRadius = 22;
//    [self.view addSubview:scrButton];
    
}




-(void)onAnalyze:(id)sender
{

    
    NSTimeInterval currentTime = self.playerViewController.playerView.player.currentTimeInSeconds;//self.currentTimeInSeconds;
    NSMutableDictionary * userInfo = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                     @"event"         : (self.currentEvent.live)?LIVE_EVENT:self.currentEvent.name,
                                                                                     @"name":@"Analyze",
                                                                                     @"time":[NSString stringWithFormat:@"%f",currentTime]
                                                                                     }];

    Encoder* enc =   (Encoder*)_encoderManager.primaryEncoder;
    
    if (!_encoderManager.primaryEncoder){
        NSLog(@"Primary encoder lost");
    }
    EncoderOperation * makeTag = [[EncoderOperationMakeTag alloc]initEncoder:enc data:userInfo];
    [makeTag setOnRequestComplete:^(NSData *data ,EncoderOperation* op) {
        Tag * atag= op.userInfo[@"tag"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter]postNotificationName:AnalyzeWillProcessTagNotification object:atag];
        });
        
    }];
    [enc runOperation:makeTag];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([_bottomViewController respondsToSelector:@selector(update)]) {
        [_bottomViewController update];
    }
    [self.view bringSubviewToFront:_bottomViewController.mainView];
    [self.view bringSubviewToFront:_videoBar];
    [self.view bringSubviewToFront:_fullscreenViewController.view];
    [self.view bringSubviewToFront:_tagButtonController.leftTray];
    [self.view bringSubviewToFront:_tagButtonController.rightTray];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_playerViewController viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[CustomAlertControllerQueue getInstance].alertQueue removeAllObjects];
    self.playerViewController.telestrationViewController.telestration = nil;
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
        [_bottomViewController clear];
        _bottomViewController = nil;
    }
    
    
//     new
    Profession * profession = [ProfessionMap getProfession:sport];
    _bottomViewController = [[profession.bottomViewControllerClass alloc]init];
    [self.view insertSubview:_bottomViewController.mainView belowSubview:_fullscreenViewController.view];
    _bottomViewController.currentEvent  = _currentEvent;

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
        
        __block Live2BenchViewController *weakSelf = self;
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
        if ([_bottomViewController respondsToSelector:@selector(closeAllOpenTagButtons)]){
            [_bottomViewController closeAllOpenTagButtons];
        }
    }
    
    if (_currentEvent.live && _appDel.encoderManager.liveEvent == nil) {
        _currentEvent = nil;
        [UserCenter getInstance].taggingTeam = nil;
        [_bottomViewController clear];

    }
    
    if ([((id <EncoderProtocol>) note.object) event]) {
        _currentEvent = [((id <EncoderProtocol>) note.object) event];//[_appDel.encoderManager.primaryEncoder event];
        [self checkIpadVersion];
        [self turnSwitchOn];
        
        [_tagButtonController allToggleOnOpenTags:_currentEvent];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onTagChanged:) name:NOTIF_TAG_RECEIVED object:_currentEvent];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onTagChanged:) name:NOTIF_TAG_MODIFIED object:_currentEvent];
        [self displayLable];
    }
    
    [self onEventChange];
}

-(void)addFeed{
    [_encoderManager.primaryEncoder resetEventAfterRemovingFeed:_currentEvent];
    [_cameraPick clear];
    [_cameraPick dismissPopoverAnimated:NO];
    _cameraPick = nil;
    
    if (_currentEvent.live) {
        [self gotLiveEvent];
    }
    
    PxpPlayerContext *context = _encoderManager.primaryEncoder.eventContext;
    _playerViewController.playerView.context = context;
    _videoBar.event = _currentEvent;
    _fullscreenViewController.playerViewController.playerView.context = context;
    
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


// This will have all the code that will init a bottomview controller based of the EventType .... Sport or medical
-(void)onEventTypeChange:(NSString*)aType
{
    _eventType = aType;
}


-(void)onEventChange
{
    [_fullscreenViewController usingTag:nil];
    
    if (_appDel.encoderManager.liveEvent != nil){
        _gotoLiveButton.enabled = YES;
        _fullscreenViewController.liveButton.enabled = YES;
        [self switchPressed];
    }else if (_currentEvent != nil){
        _gotoLiveButton.enabled = NO;
        _fullscreenViewController.liveButton.enabled = NO;
        [self switchPressed];
    }
    else if (_currentEvent == nil){
        _gotoLiveButton.enabled = NO;
        _fullscreenViewController.liveButton.enabled = NO;
        [_tagButtonController setButtonState:SideTagButtonModeDisable];
        [informationLabel setText:@""];
    }
    
    [self buildSourceButtons];
}

-(void)buildSourceButtons
{
    
    
    
    for (UIButton * b in _sourceButtons) {
        [b removeFromSuperview];
    }
    [_sourceButtons removeAllObjects];
    
    
    
    CGFloat w = 22;
    
    NSInteger c = [((Encoder*)_encoderManager.primaryEncoder).event.feeds count];
    
    
    if (c <=1) return ;
    
    for (NSInteger i =0; i<c; i++) {
        UIButton * scrButton = [[UIButton alloc]initWithFrame:CGRectMake(155+((w+20)*i), 55+(w/2), w+10, w)];
        [scrButton addTarget:self action:@selector(onPressSourceButton:) forControlEvents:UIControlEventTouchUpInside];
        scrButton.tag = i;
        [_sourceButtons addObject:scrButton];
        
        scrButton.layer.cornerRadius = 3;
        if (i) {
            [scrButton setBackgroundColor:[UIColor lightGrayColor]] ;
        } else {
            [scrButton setBackgroundColor:PRIMARY_APP_COLOR] ;
        }
//        
//        CALayer *sublayer = [CALayer layer];
//        sublayer.backgroundColor = [UIColor redColor].CGColor;
//        sublayer.frame = CGRectMake(0,0, w*2, w*2);
//        [scrButton.layer addSublayer:sublayer];
//        
//        
//        CGFloat inset = -1;
//            scrButton.layoutMargins = UIEdgeInsetsMake(inset, inset, inset, inset);
        [self.view addSubview:scrButton];
    }
   

    

}


-(void)onPressSourceButton:(id)sender
{
    for (UIButton * b in _sourceButtons) {
        [b setBackgroundColor:[UIColor lightGrayColor]] ;
    }
    UIButton * button = sender;
    [button setBackgroundColor:PRIMARY_APP_COLOR] ;


    self.playerViewController.playerView.player = self.playerViewController.playerView.context.players[button.tag];
//    self.playerViewController
}

#pragma mark -
#pragma mark PxpTimeProvider Protocol Methods

- (NSTimeInterval)currentTimeInSeconds {
    return self.playerViewController.playerView.player.currentTimeInSeconds;
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
    
    _leftArrow = [[UIImageView alloc]initWithImage:[[UIImage imageNamed:@"ortrileft"] imageBlendedWithColor:PRIMARY_APP_COLOR]];
    [_leftArrow setContentMode:UIViewContentModeScaleAspectFit];
    [_leftArrow setAlpha:1.0f];
    [self.view addSubview:_leftArrow];
    [_leftArrow setHidden:true];
    
    _playerDrawerLeft = [[ContentViewController alloc] initWithPlayerList:playerList];
    [_playerDrawerLeft.view.layer setBorderColor:PRIMARY_APP_COLOR.CGColor];
    [_playerDrawerLeft.view.layer setBorderWidth:1.0f];
    [_playerDrawerLeft.view setBackgroundColor:[UIColor whiteColor]];
    
    _rightArrow = [[UIImageView alloc]initWithImage:[[UIImage imageNamed:@"ortriright"] imageBlendedWithColor:PRIMARY_APP_COLOR]];
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
    PXPLog(@"Pressed Live Button");

    if (_currentEvent.live) {

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
    
    NSTimeInterval currentTime = self.playerViewController.playerView.player.currentTimeInSeconds;//self.currentTimeInSeconds;
    
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
        if (tag.type == TagTypeOpenDuration) {
            [durationSwitch setOn:YES];
            [self switchPressed];
            return;
        }
    }
    

    
}

-(void) onAppTerminate:(NSNotification *)note{
    if(!_currentEvent.live){
        [_tagButtonController closeAllOpenTagButtons];
        [_bottomViewController closeAllOpenTagButtons];
    }
}

#pragma mark Told to play clip from differetnt tab
- (void)clipViewPlayFeedNotification:(NSNotification *)note {
    if ([note.userInfo[@"context"] isEqualToString: STRING_LIVE2BENCH_CONTEXT]) {
        Feed *feed              = note.userInfo[@"feed"];
        Tag *tag                = note.userInfo[@"tag"];
        PxpTelestration *tele   = tag.telestration;
        
        [self.playerViewController.playerView switchToContextPlayerNamed:feed.sourceName];
        
        if ([self.playerViewController.playerView isKindOfClass:[PxpPlayerMultiView class]]){
            [((PxpPlayerMultiView*)self.playerViewController.playerView).companionView enablePip:NO];
        }
        
        self.playerViewController.telestrationViewController.telestration = !feed.sourceName || tele.sourceName == feed.sourceName || [tele.sourceName isEqualToString:feed.sourceName] ? tele : nil;
        self.playerViewController.playerView.player.tag = tag;
        
        [self.fullscreenViewController usingTag:tag];
        
    }
}

- (void)telestration:(nonnull PxpTelestration *)telestration didStartInViewController:(nonnull PxpTelestrationViewController *)viewController {

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
    

}


@end

