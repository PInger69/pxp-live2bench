//
//  InjuryViewController.m
//  Live2BenchNative
//
//  Created by 漠川 阮 on 15/4/2.
//  Copyright (c) 2015年 DEV. All rights reserved.
//

#import "InjuryViewController.h"

#import <UIKit/UIKit.h>
#import "EncoderManager.h"
#import "UserCenter.h"
#import "RJLVideoPlayer.h"
#import "LiveButton.h"
#import "FeedSwitchView.h"
//#import "L2BFullScreenViewController.h"
#import "L2BVideoBarViewController.h"
#import "BorderButton.h"


#define MEDIA_PLAYER_WIDTH    712
#define MEDIA_PLAYER_HEIGHT   400
#define PADDING                 5
#define LITTLE_ICON_DIMENSIONS 40


@interface InjuryViewController ()

@property (strong, nonatomic) TeleViewController *teleViewController;

@property (strong, nonatomic) Slomo *slomoButton;
@property (strong, nonatomic) EncoderManager *encoderManager;
@property (strong, nonatomic) NSString *eventType;
@property (strong, nonatomic) UserCenter *userCenter;
@property (strong, nonatomic) LiveButton *gotoLiveButton;
@property (strong, nonatomic) FeedSwitchView *feedSwitch;

@property (strong, nonatomic) SeekButton         * seekForward;
@property (strong, nonatomic) SeekButton         * seekBackward;
@property (strong, nonatomic) CustomButton       * teleButton;

@property (strong, nonatomic) BorderButton        * saveTeleButton;
@property (strong, nonatomic) BorderButton        * clearTeleButton;

@property (strong, nonatomic) UIButton        *startButton;
@property (strong, nonatomic) UIButton        *stopButton;

@property (strong, nonatomic) NSString *timeString;
@property (assign, nonatomic) CFTimeInterval startTime;

@property (strong, nonatomic) NSTimer             *recordingTimer;

@end

@implementation InjuryViewController

static void * eventTypeContext  = &eventTypeContext;
static void * eventContext      = &eventContext;

-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
    //[self performSelector:@selector(delayed) withObject:self afterDelay:1.0];
    
    
    if (!self.videoPlayer.feed && _encoderManager.currentEvent != nil) {
        [self.videoPlayer playFeed:_feedSwitch.primaryFeed];
    }
    
    //    [currentEventTitle setNeedsDisplay];
    
    
    // maybe this should be part of the videoplayer
    if(![self.view.subviews containsObject:self.videoPlayer.view])
    {
        [self.view addSubview:self.videoPlayer.view];
        [self.videoPlayer play];
        [self setupView];
    }
}

- (void)setupView {
    _seekForward                = [self _makeSeekButton:SEEK_DIRECTION_RIGHT targetVideoPlayer:self.videoPlayer];
    _seekBackward               = [self _makeSeekButton:SEEK_DIRECTION_LEFT targetVideoPlayer:self.videoPlayer];
    [self.view addSubview:_seekForward];
    [self.view addSubview:_seekBackward];
    
    self.slomoButton = [self makeSlomo];
    [self.view addSubview:self.slomoButton];
    
    _gotoLiveButton = [[LiveButton alloc]initWithFrame:CGRectMake((1024 - 130) / 2,PADDING + self.videoPlayer.view.frame.size.height + 95, 130, LITTLE_ICON_DIMENSIONS)];
    [_gotoLiveButton addTarget:self action:@selector(goToLive) forControlEvents:UIControlEventTouchUpInside];
    [_gotoLiveButton setFrame:CGRectMake((1024 - 130) / 2, 700, 130, LITTLE_ICON_DIMENSIONS)];
    _gotoLiveButton.enabled = NO;
    [self.view addSubview:_gotoLiveButton];
    
    self.teleButton = [self _makeTeleButton];
    [self.view addSubview:self.teleButton];
    
    _saveTeleButton             = [self _makeTeleSaveButton];
    _clearTeleButton            = [self _makeTeleClearButton];
    [self.view addSubview:_saveTeleButton];
    _saveTeleButton.hidden = YES;
    [self.view addSubview:_clearTeleButton];
    _clearTeleButton.hidden = YES;
    
    self.startButton = [self makeStartButton];
    [self.view addSubview:self.startButton];
    self.startButton.hidden = NO;
    
    self.stopButton = [self makeStopButton];
    [self.view addSubview:self.stopButton];
    self.stopButton.hidden = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect screenBounds;
    screenBounds = CGRectMake(0, 0, 1024, 768);
    self.videoPlayer = [[RJLVideoPlayer alloc] initWithFrame:screenBounds];
    self.videoPlayer.view.frame                              = screenBounds;
    self.videoPlayer.view.bounds                             = screenBounds;
    self.videoPlayer.playBackView.frame                       = screenBounds;
    self.videoPlayer.playBackView.bounds                      = screenBounds;
    
    NSDictionary *fullScreenFramesParts = @{
                                            @"light" : [NSValue valueWithCGRect:CGRectMake(screenBounds.size.width-32,
                                                                                           60,
                                                                                           self.videoPlayer.liveIndicatorLight.frame.size.width,
                                                                                           self.videoPlayer.liveIndicatorLight.frame.size.height)],
                                            
                                            @"bar"   : [NSValue valueWithCGRect:CGRectMake(0,
                                                                                           640,
                                                                                           screenBounds.size.width,
                                                                                           self.videoPlayer.videoControlBar.frame.size.height)],
                                            @"slide" : [NSValue valueWithCGRect:CGRectMake(0,
                                                                                           0,
                                                                                           screenBounds.size.width-200,
                                                                                           self.videoPlayer.videoControlBar.timeSlider.frame.size.height)]
                                            };
    
    
    self.videoPlayer.liveIndicatorLight.frame                = [((NSValue *)[fullScreenFramesParts objectForKey:@"light"]) CGRectValue];
    self.videoPlayer.videoControlBar.frame               = [((NSValue *)[fullScreenFramesParts objectForKey:@"bar"]) CGRectValue];
    self.videoPlayer.videoControlBar.timeSlider.frame    = [((NSValue *)[fullScreenFramesParts objectForKey:@"slide"]) CGRectValue];
    
    
    self.videoPlayer.playerContext      = STRING_INJURY_CONTEXT;
    
    _feedSwitch     = [[FeedSwitchView alloc]initWithFrame:CGRectMake(156+100, 59, 64, 38) encoderManager:_encoderManager];
    
   //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(masterLost:)               name:NOTIF_ENCODER_MASTER_HAS_FALLEN object:nil];
    
}



-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_ENCODER_COUNT_CHANGE object:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_ENCODER_FEED_HAVE_CHANGED object:nil];
    [self onEventChange];
    
    [self.seekForward  setFrame:CGRectMake(self.view.frame.size.width - (100 +self.seekForward.frame.size.width),
                                           self.seekForward.frame.origin.y,
                                           self.seekForward.frame.size.width,
                                           self.seekForward.frame.size.height)];
    
    [self.seekBackward  setFrame:CGRectMake(100,
                                            self.seekBackward.frame.origin.y,
                                            self.seekBackward.frame.size.width,
                                            self.seekBackward.frame.size.height)];
    
    [self.slomoButton setFrame:CGRectMake(190,
                                          self.slomoButton.frame.origin.y,
                                          self.slomoButton.frame.size.width,
                                          self.slomoButton.frame.size.height)];
    
    
    
    // adjust control bar size and position
    
    [super viewDidAppear:animated];
    
}

-(id)initWithAppDelegate:(AppDelegate *)mainappDelegate
{
    //_externalControlScreen  = mainappDelegate.screenController;
    _encoderManager         = mainappDelegate.encoderManager;
    _eventType              = mainappDelegate.encoderManager.currentEventType;
    _userCenter             = mainappDelegate.userCenter;
    
    [_encoderManager addObserver:self forKeyPath:NSStringFromSelector(@selector(currentEvent))      options:NSKeyValueObservingOptionNew context:&eventContext];
    
    
    self = [super initWithAppDelegate:mainappDelegate];
    if (self) {
        [self setMainSectionTab:NSLocalizedString(@"Injury", nil) imageName:@"live2BenchTab"];
        //self.teleViewController = [[TeleViewController alloc] initWithController:self];
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(gotLiveEvent) name:NOTIF_MASTER_HAS_LIVE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NOTIF_EVENT_FEEDS_READY object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self.videoPlayer playFeed:_feedSwitch.primaryFeed];
    }];
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &eventTypeContext){ // This checks to see if the encoder manager has changed Events Types like Sport or Medical
        //[self onEventTypeChange: [change objectForKey:@"new"]];
    } else if (context == &eventContext){
        [self onEventChange];
    }
}

-(void)onEventChange
{
    
    if ([_encoderManager.currentEvent isEqualToString:@"None"]){
        self.videoPlayer.live   = NO;
        _gotoLiveButton.enabled = NO;
        //_tagButtonController.enabled = NO;
        
    } else if ([_encoderManager.currentEvent isEqualToString:_encoderManager.liveEventName]){      // LIVE
        self.videoPlayer.live   = YES;
        _gotoLiveButton.enabled = YES;
        //_tagButtonController.enabled = YES;
        if (!self.videoPlayer.feed) {
            [self.videoPlayer playFeed:_feedSwitch.primaryFeed];
            [self.videoPlayer play];
        }
        
    } else if (_encoderManager.currentEvent == nil) { // CLIPs and playing back old events
        self.videoPlayer.live   = NO;
        _gotoLiveButton.enabled = NO; // TODO
        //_tagButtonController.enabled = NO;
    } else { // CLIPs and playing back old events
        self.videoPlayer.live   = NO;
        _gotoLiveButton.enabled = YES; // TODO
    }
    
    //[multiButton setHidden:!([_encoderManager.feeds count]>1)];
    
}

-(void)gotLiveEvent
{
    self.videoPlayer.live   = YES;
    _gotoLiveButton.enabled = YES;
    
}

- (void)goToLive
{
    [self.videoPlayer gotolive];
}

#pragma mark Bottom Buttons

-(Slomo*)makeSlomo
{
    Slomo *  btn = [[Slomo alloc]initWithFrame:CGRectMake(190, 700, 65, 50)];
    [btn addTarget:self action:  @selector(toggleSlowmo:) forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}



-(void)toggleSlowmo:(id)sender
{
    
    self.videoPlayer.slowmo = !self.videoPlayer.slowmo;
    ((Slomo*)sender).slomoOn = self.videoPlayer.slowmo;
}


-(SeekButton*)_makeSeekButton:(Direction)dir targetVideoPlayer:(UIViewController <PxpVideoPlayerProtocol>*)vp
{
    SeekButton  * btn;
    switch ( dir ) {
        case SEEK_DIRECTION_LEFT:
            btn = [SeekButton makeFullScreenBackwardAt:CGPointMake(0, 700-10)];
            break;
            
        default: ///SEEK_DIRECTION_RIGHT
            btn = [SeekButton makeFullScreenForwardAt:CGPointMake(0, 700-10)];
            break;
    }
    [btn onPressSeekPerformSelector: @selector(seekWithSeekerButton:) addTarget:vp];
    return btn;
}

-(CustomButton *)_makeTeleButton
{
    CustomButton * btn       = [CustomButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:          CGRectMake(1024-5.0f-64.0f, 550, 64.0f, 64.0f)];
    [btn setContentMode:    UIViewContentModeScaleAspectFill];
    [btn setImage:          [UIImage imageNamed:@"teleButton"] forState:UIControlStateNormal];
    [btn setImage:          [UIImage imageNamed:@"teleButtonSelect"] forState:UIControlStateHighlighted];
    
    [btn addTarget:self action:@selector(teleButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

-(void)teleButtonPressed{
    [self.videoPlayer pause];
    [self setStateWhenTele];
    [self.teleViewController startTelestration];
}

-(BorderButton *)_makeTeleSaveButton
{
    BorderButton * btn       = [[BorderButton alloc]init];
    btn = [BorderButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(377.0f, 700.0f, 123.0f, 33.0f)];
    [btn setTitle:NSLocalizedString(@"Save",nil) forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(_saveButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

-(BorderButton *)_makeTeleClearButton
{
    BorderButton * btn       = [[BorderButton alloc]init];
    btn = [BorderButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(500, 700.0f,123.0f, 33.0f)];
    [btn setTitle:NSLocalizedString(@"Close",nil) forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(_clearButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (UIButton *)makeStartButton {
   // UIButton *btn = [[BorderButton alloc] init];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(1024 - 75, 690,70.0f, 70.0f)];
    //[btn setTitle:@"Start Recording" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(startButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [btn setBackgroundImage:[self readyToRecordButtonWithSize:CGSizeMake(65, 65)] forState:UIControlStateNormal];
    self.timeString = @"00:00:00";
    return btn;
}

- (void)startButtonClicked {
    [self setStateWhenRecording];
    [self.videoPlayer.videoControlBar setEnable:NO];
    self.videoPlayer.liveIndicatorLight.tintColor = [UIColor redColor];
    [self.videoPlayer.liveIndicatorLight setHidden:NO];
    //self.startTime = [[NSCalendar currentCalendar] components:NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:[NSDate date]];
    self.startTime = CACurrentMediaTime();
    self.recordingTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateRecodingTime) userInfo:nil repeats:YES];
}

- (void)updateRecodingTime {
    CFTimeInterval recodingTime = CACurrentMediaTime() - self.startTime;
    NSInteger second = 00;
    NSInteger minute = 00;
    NSInteger hour = 00;
    second = (int)recodingTime;
    if (second >= 60 && second < 3600) {
        minute = second / 60;
        second = second % 60;
    } else if (second >= 3600){
        hour = second / 3600;
        minute = second % 3600 / 60;
        second = minute % 60;
    }
    
    self.timeString = [NSString stringWithFormat:@"%02ld:%02ld", (long)minute, (long)second];
    [self.stopButton setTitle:[NSString stringWithFormat:@"%@", self.timeString] forState:UIControlStateNormal];
    
}

- (void)stopButtonClicked {
    self.recordingTimer = nil;
    self.videoPlayer.liveIndicatorLight.tintColor = [UIColor greenColor];
    [self.videoPlayer.liveIndicatorLight setHidden: self.videoPlayer.live?NO:YES];
    [self.videoPlayer.videoControlBar setEnable:YES];
    [self setStateWhenRecording];
    self.timeString = @"00:00:00";
    [self.stopButton setTitle:[NSString stringWithFormat:@"%@", self.timeString] forState:UIControlStateNormal];
}

- (void)setStateWhenRecording {
    self.startButton.hidden = !self.startButton.hidden;
    self.stopButton.hidden = !self.stopButton.hidden;
    self.gotoLiveButton.hidden = !self.gotoLiveButton.hidden;
    self.teleButton.enabled = !self.teleButton.enabled;
    self.seekForward.enabled = !self.seekForward.enabled;
    self.seekBackward.enabled = !self.seekBackward.enabled;
    self.slomoButton.enabled = !self.slomoButton.enabled;
}

- (UIButton *)makeStopButton {
//    BorderButton *btn = [[BorderButton alloc] init];
//    btn = [BorderButton buttonWithType:UIButtonTypeCustom];
//    [btn setFrame:CGRectMake(700, 700.0f,135.0f, 40.0f)];
//    [btn setTitle:[NSString stringWithFormat:@"Stop - %@", self.timeString] forState:UIControlStateNormal];
//    [btn addTarget:self action:@selector(stopButtonClicked) forControlEvents:UIControlEventTouchUpInside];
//    return btn;
    
    // UIButton *btn = [[BorderButton alloc] init];
    self.timeString = @"00:00";
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(1024 - 75, 690,70.0f, 70.0f)];
    [btn setTitle:[NSString stringWithFormat:@"%@", self.timeString] forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [btn.titleLabel setTextAlignment: NSTextAlignmentCenter];
    [btn addTarget:self action:@selector(stopButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [btn setBackgroundImage:[self recordingButtonWithSize:CGSizeMake(65, 65)] forState:UIControlStateNormal];
    return btn;
}

-(void)_saveButtonClicked
{
    //[[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SAVE_TELE object:nil];
    [self.videoPlayer play];
    [self.teleViewController saveTeles];
    
    [self setStateWhenTele];
}

//clear button clicked, send notification to the teleview controller
-(void)_clearButtonClicked
{
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_CLEAR_TELE object:nil];
    [self.teleViewController forceCloseTele];
    [self.videoPlayer play];
    
    [self setStateWhenTele];
}

- (void)setStateWhenTele {
    self.gotoLiveButton.hidden = !self.gotoLiveButton.hidden;
    self.teleButton.hidden = !self.teleButton.hidden;
    self.slomoButton.hidden = !self.slomoButton.hidden;
    self.startButton.hidden = !self.startButton.hidden;
    self.saveTeleButton.hidden = !self.saveTeleButton.hidden;
    self.clearTeleButton.hidden = !self.clearTeleButton.hidden;
}


-(UIImage *)readyToRecordButtonWithSize: (CGSize) buttonSize{
    UIGraphicsBeginImageContextWithOptions(buttonSize, NO, [UIScreen mainScreen].scale);

    UIBezierPath *whiteCirclePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(buttonSize.width/2, buttonSize.height/2) radius: (buttonSize.width/2 - 5) startAngle:0 endAngle: 2 *M_PI clockwise:NO];
    whiteCirclePath.lineWidth = (buttonSize.width / 10) /2 ;
    
    [[UIColor whiteColor] setStroke];
    [whiteCirclePath stroke];
    
    UIBezierPath *innerRedCircle = [UIBezierPath bezierPathWithArcCenter:CGPointMake(buttonSize.width/2, buttonSize.height/2) radius: (buttonSize.width/2 - whiteCirclePath.lineWidth - 5 ) startAngle:0 endAngle: 2 *M_PI clockwise:NO];
    
    [[UIColor redColor] setFill];
    
    [innerRedCircle fill];

    
    UIImage *recordButtonImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return recordButtonImage;
}

-(UIImage *)recordingButtonWithSize: (CGSize) buttonSize{
    UIGraphicsBeginImageContextWithOptions(buttonSize, NO, [UIScreen mainScreen].scale);
    
    UIBezierPath *whiteCirclePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(buttonSize.width/2, buttonSize.height/2) radius: (buttonSize.width/2 - 5) startAngle:0 endAngle: 2 *M_PI clockwise:NO];
    whiteCirclePath.lineWidth = (buttonSize.width / 10) /2 ;
    
    [[UIColor whiteColor] setStroke];
    [whiteCirclePath stroke];
    
    //UIBezierPath *innerRedCircle = [UIBezierPath bezierPathWithArcCenter:CGPointMake(buttonSize.width/2, buttonSize.height/2) radius: (buttonSize.width/2 - whiteCirclePath.lineWidth - 5 ) startAngle:0 endAngle: 2 *M_PI clockwise:NO];
    
    CGRect innerSquareFrame = CGRectMake(buttonSize.width* 0.149096 + whiteCirclePath.lineWidth/2, buttonSize.height* 0.149096 + whiteCirclePath.lineWidth/2, buttonSize.width - 2 * (buttonSize.width* 0.149096 + whiteCirclePath.lineWidth/2), buttonSize.height - 2 *( buttonSize.width* 0.149096+ whiteCirclePath.lineWidth/2));
    UIBezierPath *innerSquarePath = [UIBezierPath bezierPathWithRoundedRect:innerSquareFrame cornerRadius:buttonSize.width / 10 + whiteCirclePath.lineWidth + 2];
    
    [[UIColor redColor] setFill];
    
    [innerSquarePath fill];
    
    
    UIImage *recordButtonImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return recordButtonImage;
}


@end

