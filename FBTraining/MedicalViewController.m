//
//  MedicalViewController.m
//  Live2BenchNative
//
//  Created by dev on 2015-07-14.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "EncoderManager.h"
#import "MedicalViewController.h"
#import "RJLVideoPlayer.h"
#import "Slomo.h"
#import "LiveButton.h"
#import "SeekButton.h"
#import "BorderButton.h"
#import "Event.h"

#import "PxpTelestrationViewController.h"

#define PADDING                 5
#define LITTLE_ICON_DIMENSIONS 40

@interface MedicalViewController () <PxpTimeProvider>

@property (strong, nonatomic, nonnull) PxpTelestrationViewController *telestrationViewController;

@end

@implementation MedicalViewController{
    LiveButton                          *gotoLiveButton;
    UIButton                            *startButton;
    UIButton                            *stopButton;
    NSString                            *timeString;
    float                               startTime;
    NSTimer                             *recordingTimer;
    NSArray                             *activeElements;
    id <EncoderProtocol>                _observedEncoder;
    Event                               * _currentEvent;
    EncoderManager                      * _encoderManager;
}

@synthesize mode = _mode;

-(id)initWithAppDelegate:(AppDelegate *)mainappDelegate
{
    self = [super initWithAppDelegate:mainappDelegate];
    
    if (self) {
        [self setMainSectionTab:NSLocalizedString(@"Medical", nil) imageName:@"live2BenchTab"];
        
        _telestrationViewController = [[PxpTelestrationViewController alloc] init];
        _encoderManager         = mainappDelegate.encoderManager;
        
        CGRect screenBounds;
        
        CGFloat playerWidth = 1024.0, playerHeight = playerWidth / (16.0 / 9.0);
        CGFloat playerY = (768.0 - playerHeight + 55.0) / 2.0;
        
        self.videoPlayer = [[RJLVideoPlayer alloc] initWithFrame:CGRectMake(0.0, playerY, playerWidth, playerHeight)];
        
        screenBounds = CGRectMake(0, 0, 1024, 768);
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
        [self.view addSubview:self.videoPlayer.view];
        
        gotoLiveButton = [self makeLive];
        [self.view addSubview:gotoLiveButton];
        
        startButton = [self makeStartButton];
        [self.view addSubview:startButton];
        
        stopButton = [self makeStopButton];
        [self.view addSubview:stopButton];
        
        activeElements = @[gotoLiveButton,startButton,stopButton];
        [self revealThese:@[]];
        
        //self.telestrationViewController.telestration = [[PxpTelestration alloc] init];
        [self addChildViewController:_telestrationViewController];
        
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(addEventObserver:) name:NOTIF_PRIMARY_ENCODER_CHANGE object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onEventChange) name:NOTIF_LIVE_EVENT_FOUND object:nil];
        
        
    }
        
    
    
    return self;
}

-(void)addEventObserver:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_EVENT_CHANGE object:_observedEncoder];
    
    if (note.object == nil) {
        _observedEncoder = nil;
        return;
    }
    
    _observedEncoder = (id <EncoderProtocol>) note.object;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(eventChanged:) name:NOTIF_EVENT_CHANGE object:_observedEncoder];
}

-(void)eventChanged:(NSNotification*)note
{
    if ([[note.object event].name isEqualToString:_currentEvent.name]) {
        [self onEventChange];
        return;
    }
    
    if (_currentEvent.live && _encoderManager.liveEvent) {
        _currentEvent = nil;
        
    } else{
        _currentEvent = [((id <EncoderProtocol>) note.object) event];//[_appDel.encoderManager.primaryEncoder event];
        [self.videoPlayer playFeed:[[_currentEvent.feeds allValues] firstObject]];
        if (_currentEvent.live) {
            [self.videoPlayer gotolive];
        }
    }
    
    [self onEventChange];
}

-(void)onEventChange
{
    if (_appDel.encoderManager.liveEvent != nil){
        [self setMode:MedicalScreenLive];
    }else if (_currentEvent != nil){
        [self setMode:MedicalScreenRegular];
    }
    else if (_currentEvent == nil){
        [self setMode:MedicaScreenDisable];
        [self.videoPlayer clear];
    }
}

-(void)setMode:(MedicalScreenModes)mode
{
    if (_mode == mode) return;
    _mode = mode;
    
    switch (_mode) {
        case MedicaScreenDisable :
            [self revealThese:@[]];
            break;
        case MedicalScreenRegular :
            [self revealThese:@[startButton]];
            break;
        case MedicalScreenLive:
            [self revealThese:@[gotoLiveButton,startButton]];
            break;
        default:
            break;
    }
}



#pragma mark Button Helper Methods
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

- (void)updateRecodingTime {
    float time = CMTimeGetSeconds(self.videoPlayer.avPlayer.currentTime);
    NSInteger second = 00;
    NSInteger minute = 00;
    NSInteger hour = 00;
    second = time;
    if (second >= 60 && second < 3600) {
        minute = second / 60;
        second = second % 60;
    } else if (second >= 3600){
        hour = second / 3600;
        minute = second % 3600 / 60;
        second = second - (minute*60+hour*60*60);
    }
    
    timeString = [NSString stringWithFormat:@"%01ld:%02ld:%02ld", (long)hour ,(long)minute, (long)second];
    [stopButton setTitle:[NSString stringWithFormat:@"%@", timeString] forState:UIControlStateNormal];
}

-(UIImage *)recordingButtonWithSize: (CGSize) buttonSize{
    UIGraphicsBeginImageContextWithOptions(buttonSize, NO, [UIScreen mainScreen].scale);
    
    UIBezierPath *whiteCirclePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(buttonSize.width/2, buttonSize.height/2) radius: (buttonSize.width/2 - 5) startAngle:0 endAngle: 2 *M_PI clockwise:NO];
    whiteCirclePath.lineWidth = (buttonSize.width / 10) /2 ;
    
    [[UIColor whiteColor] setStroke];
    [whiteCirclePath stroke];
    
    CGRect innerSquareFrame = CGRectMake(buttonSize.width* 0.149096 + whiteCirclePath.lineWidth/2, buttonSize.height* 0.149096 + whiteCirclePath.lineWidth/2, buttonSize.width - 2 * (buttonSize.width* 0.149096 + whiteCirclePath.lineWidth/2), buttonSize.height - 2 *( buttonSize.width* 0.149096+ whiteCirclePath.lineWidth/2));
    UIBezierPath *innerSquarePath = [UIBezierPath bezierPathWithRoundedRect:innerSquareFrame cornerRadius:buttonSize.width / 10 + whiteCirclePath.lineWidth + 2];
    
    [[UIColor redColor] setFill];
    
    [innerSquarePath fill];
    
    
    UIImage *recordButtonImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return recordButtonImage;
}




#pragma mark Make Buttons


-(LiveButton*)makeLive
{
    LiveButton * btn = [[LiveButton alloc]initWithFrame:CGRectMake(450,700, 130, LITTLE_ICON_DIMENSIONS)];
    [btn addTarget:self action:@selector(goToLive) forControlEvents:UIControlEventTouchUpInside];
   
    return btn;
}

- (UIButton *)makeStartButton {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(1024 - 75, 690,70.0f, 70.0f)];
    [btn addTarget:self action:@selector(startButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [btn setBackgroundImage:[self readyToRecordButtonWithSize:CGSizeMake(65, 65)] forState:UIControlStateNormal];
    //timeString = @"00:00:00";
    startButton.hidden = true;
    stopButton.hidden = false;
    return btn;
}

- (UIButton *)makeStopButton {
    //timeString = @"00:00";
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(1024 - 75, 690,70.0f, 70.0f)];
    [btn setTitle:[NSString stringWithFormat:@"%@", timeString] forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [btn.titleLabel setTextAlignment: NSTextAlignmentCenter];
    [btn addTarget:self action:@selector(stopButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [btn setBackgroundImage:[self recordingButtonWithSize:CGSizeMake(65, 65)] forState:UIControlStateNormal];
    startButton.hidden = false;
    stopButton.hidden = true;
    return btn;
}




#pragma mark Buttons' Method

- (void)goToLive
{
    _currentEvent = _encoderManager.liveEvent;
    if (![self.videoPlayer.feed isEqual:[[_currentEvent.feeds allValues] firstObject] ]) {
        [self.videoPlayer clear];
    }
    
    if (![self.videoPlayer.feed isEqual:[[_currentEvent.feeds allValues] firstObject]]) {
        [self.videoPlayer playFeed:[[_currentEvent.feeds allValues]firstObject]];
    }else{
        [self.videoPlayer playFeed:self.videoPlayer.feed];
    }
    [self.videoPlayer gotolive];
}

- (void)startButtonClicked {
    [self.videoPlayer.videoControlBar setEnable:NO];
    self.videoPlayer.liveIndicatorLight.tintColor = [UIColor redColor];
    [self.videoPlayer.liveIndicatorLight setHidden:NO];
    [self updateRecodingTime];
    startTime = CMTimeGetSeconds(self.videoPlayer.avPlayer.currentTime);
    recordingTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateRecodingTime) userInfo:nil repeats:YES];
    startButton.hidden = true;
    stopButton.hidden = false;
    
    self.telestrationViewController.telestration = [[PxpTelestration alloc] init];
}

- (void)stopButtonClicked {
    recordingTimer = nil;
    self.videoPlayer.liveIndicatorLight.tintColor = [UIColor greenColor];
    [self.videoPlayer.liveIndicatorLight setHidden: self.videoPlayer.live?NO:YES];
    [self.videoPlayer.videoControlBar setEnable:YES];
    float duration = CMTimeGetSeconds(self.videoPlayer.avPlayer.currentTime) - startTime;
    [stopButton setTitle:[NSString stringWithFormat:@"%@", timeString] forState:UIControlStateNormal];
    startButton.hidden = false;
    stopButton.hidden = true;
    
    if (self.telestrationViewController.telestration) {
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_CREATE_TELE_TAG object:self userInfo:@{
                                                                                                          @"time": [NSString stringWithFormat:@"%f",startTime],
                                                                                                          @"duration": [NSString stringWithFormat:@"%i",(int)roundf(duration)],
                                                                                                          @"telestration" : self.telestrationViewController.telestration.data
                                                                                                          }];
    }
    
    self.telestrationViewController.telestration = nil;
}


-(void)revealThese:(NSArray*)list
{
    for (UIView * v in activeElements) {
        [v setHidden:YES];
    }
    for (UIView * v in list) {
        [v setHidden:NO];
    }
}


- (void)viewDidLoad {
    // Do any additional setup after loading the view.
    [super viewDidLoad];
    
    NSLog(@"%@", [NSValue valueWithCGRect:self.view.frame]);
    self.telestrationViewController.view.frame = CGRectMake(0.0, 0.0, self.videoPlayer.view.bounds.size.width, self.videoPlayer.view.bounds.size.height - 44.0f);
    self.telestrationViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.videoPlayer.view addSubview:self.telestrationViewController.view];
    self.telestrationViewController.timeProvider = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSTimeInterval)currentTime {
    return CMTimeGetSeconds(self.videoPlayer.avPlayer.currentTime);;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
