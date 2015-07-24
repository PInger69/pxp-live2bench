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
#import "UserCenter.h"

#import "NCRecordButton.h"

#import "PxpTelestrationViewController.h"
#import "TagNameSelectTableViewController.h"
#import "TeleSelectTableViewController.h"

#import "UIColor+Highlight.h"

#define PADDING                 5
#define LITTLE_ICON_DIMENSIONS 40
#define BAR_HEIGHT 75.0

@interface MedicalViewController () <PxpTelestrationViewControllerDelegate, NCRecordButtonDelegate, TagNameSelectResponder, TagSelectResponder>

@property (copy, nonatomic, nullable) NSString *activeTagName;
@property (copy, nonatomic, nullable) NSString *durationTagID;

@property (strong, nonatomic, nonnull) PxpTelestrationViewController *telestrationViewController;

@property (strong, nonatomic, nonnull) UIView *container;

@property (strong, nonatomic, nonnull) UIView *bottomBar;

@property (readonly, assign, nonatomic) CGFloat tagSelectWidth;
@property (strong, nonatomic, nonnull) UIButton *tagSelectButton;
@property (strong, nonatomic, nonnull) TagNameSelectTableViewController *tagNameSelectController;

@property (readonly, assign, nonatomic) CGFloat teleSelectWidth;
@property (strong, nonatomic, nonnull) UIButton *teleSelectButton;
@property (strong, nonatomic, nonnull) TeleSelectTableViewController *teleSelectController;

@property (strong, nonatomic, nonnull) NCRecordButton *recordButton;
@property (strong, nonatomic, nonnull) SeekButton *backwardSeekButton;
@property (strong, nonatomic, nonnull) SeekButton *forwardSeekButton;
@property (strong, nonatomic, nonnull) Slomo *slomoButton;

@property (strong, nonatomic, nonnull) LiveButton *liveButton;
@property (strong, nonatomic, nonnull) UILabel *durationLabel;

@end

@implementation MedicalViewController {
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
        _currentEvent = _encoderManager.primaryEncoder.event;
        
        _tagNameSelectController = [[TagNameSelectTableViewController alloc] init];
        _teleSelectController = [[TeleSelectTableViewController alloc] init];
        
        _container = [[UIView alloc] initWithFrame:CGRectMake(0.0, 55.0, 1024.0, 768.0 - 55.0)];
        
        
        _bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0.0, 768.0 - 55.0 - BAR_HEIGHT, 1024.0, BAR_HEIGHT)];
        
        _recordButton = [[NCRecordButton alloc] init];
        
        const CGFloat seekButtonOffest = 512.0 * (1.0 - PHI_INV);
        const CGFloat seekButtonWidth = 45.0;
        const CGFloat seekButtonHeight = 75.0;
        CGPoint backwardPoint = CGPointMake(seekButtonOffest, 768.0 - seekButtonHeight);
        CGPoint forwardPoint = CGPointMake(1024.0 - seekButtonOffest - seekButtonWidth, 768.0 - seekButtonHeight);
        
        _tagSelectWidth = seekButtonOffest;
        
        _backwardSeekButton = [SeekButton makeFullScreenBackwardAt:backwardPoint];
        _forwardSeekButton = [SeekButton makeFullScreenForwardAt:forwardPoint];
        
        [_backwardSeekButton onPressSeekPerformSelector:@selector(seekButtonAction:) addTarget:self];
        [_forwardSeekButton onPressSeekPerformSelector:@selector(seekButtonAction:) addTarget:self];
        
        _tagSelectButton = [[UIButton alloc] initWithFrame:CGRectMake(15.0, 0.0, seekButtonOffest - 30.0, BAR_HEIGHT)];
        [_tagSelectButton addTarget:self action:@selector(tagSelectButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        _slomoButton = [[Slomo alloc] initWithFrame:CGRectMake(seekButtonOffest + 60.0, 0.0, BAR_HEIGHT, BAR_HEIGHT)];
        [_slomoButton addTarget:self action:@selector(slomoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        _teleSelectWidth = 512 * PHI_INV;
        _teleSelectButton = [[UIButton alloc] init];
        [_teleSelectButton addTarget:self action:@selector(teleSelectButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        const CGFloat labelWidth = 512.0 - seekButtonOffest - 60.0;
        const CGFloat liveButtonWidth = 130.0, liveButtonHeight = 40.0;
        const CGFloat liveButtonX = seekButtonOffest + 60.0 + BAR_HEIGHT + 15.0;
        const CGFloat liveButtonY = (BAR_HEIGHT - liveButtonHeight) / 2.0;
        
        _durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(512.0, 0.0, labelWidth, BAR_HEIGHT)];
        _liveButton = [[LiveButton alloc] initWithFrame:CGRectMake(liveButtonX,liveButtonY, liveButtonWidth, liveButtonHeight)];
        [_liveButton addTarget:self action:@selector(liveButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        CGFloat playerWidth = 1024.0, playerHeight = playerWidth / (16.0 / 9.0);
        CGFloat playerY = self.container.bounds.size.height - playerHeight - BAR_HEIGHT;
        
        self.videoPlayer = [[RJLVideoPlayer alloc] initWithFrame:CGRectMake(0.0, playerY, playerWidth, playerHeight)];
        
        CGRect screenBounds = CGRectMake(0, 0, 1024, 768);
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
        
        [self.container addSubview:self.videoPlayer.view];
        
        [self addChildViewController:_telestrationViewController];
        [self addChildViewController:_tagNameSelectController];
        [self addChildViewController:_teleSelectController];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(addEventObserver:) name:NOTIF_PRIMARY_ENCODER_CHANGE object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onEventChange) name:NOTIF_LIVE_EVENT_FOUND object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sideTagsReady:) name:NOTIF_SIDE_TAGS_READY_FOR_L2B object:nil];
        
        [self.view addSubview:self.container];
        
        _teleSelectController.event = _currentEvent;
    }
        
    
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_SIDE_TAGS_READY_FOR_L2B object:nil];
}

- (void)setActiveTagName:(nullable NSString *)activeTagName {
    _activeTagName = activeTagName;
    
    [self.tagSelectButton setTitle:activeTagName forState:UIControlStateNormal];
    
    if (self.recordButton.enabled && !activeTagName) {
        self.recordButton.enabled = NO;
    }
}

- (void)sideTagsReady:(NSNotification *)note {
    NSArray *tagDescriptors = _appDel.userCenter.tagNames;
    
    // find the first valid tag name.
    NSString *newActiveTagName = nil;
    for (NSDictionary *tagDescriptor in tagDescriptors) {
        NSString *tagName = tagDescriptor[@"name"];
        if (tagName.length > 0 && ![tagName hasPrefix:@"-"]) {
            newActiveTagName = tagName;
            break;
        }
    }
    
    if (self.activeTagName) {
        for (NSDictionary *tagDescriptor in tagDescriptors) {
            if ([tagDescriptor[@"name"] isEqualToString:self.activeTagName]) {
                newActiveTagName = self.activeTagName;
            }
        }
    }
    
    self.activeTagName = newActiveTagName;
    self.tagNameSelectController.tagDescriptors = tagDescriptors;
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
    
    self.teleSelectController.event = _currentEvent;
    
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
    self.videoPlayer.slowmo = NO;
    self.slomoButton.slomoOn = NO;
}


- (void)viewDidLoad {
    // Do any additional setup after loading the view.
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    self.bottomBar.backgroundColor = [UIColor blackColor];
    
    const CGFloat playerHeight = self.container.bounds.size.width / (16.0 / 9.0);
    const CGFloat teleSelectY = self.container.bounds.size.height - BAR_HEIGHT - playerHeight;
    
    self.telestrationViewController.view.frame = self.videoPlayer.view.bounds;
    self.telestrationViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // we need the control bar to be first responder.
    [self.videoPlayer.view insertSubview:self.telestrationViewController.view belowSubview:self.videoPlayer.videoControlBar];
    
    self.telestrationViewController.timeProvider = self.videoPlayer;
    self.telestrationViewController.delegate = self;
    self.telestrationViewController.showsClearButton = YES;
    self.telestrationViewController.showsControls = YES;
    
    self.tagSelectButton.titleLabel.font = [UIFont systemFontOfSize:BAR_HEIGHT * PHI_INV];
    self.tagSelectButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.tagSelectButton setTitle:@"" forState:UIControlStateNormal];
    [self.tagSelectButton setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
    [self.tagSelectButton setTitleColor:PRIMARY_APP_COLOR.highlightedColor forState:UIControlStateHighlighted];
    [self.tagSelectButton setTitleColor:PRIMARY_APP_COLOR.highlightedColor forState:UIControlStateSelected];
    [self.tagSelectButton setTitleColor:PRIMARY_APP_COLOR.highlightedColor forState:UIControlStateDisabled];
    
    self.teleSelectButton.frame = CGRectMake(self.container.bounds.size.width - self.teleSelectWidth, 0.0, self.teleSelectWidth, teleSelectY);
    
    self.teleSelectButton.titleLabel.font = [UIFont systemFontOfSize:self.teleSelectButton.frame.size.height * 0.45];
    self.teleSelectButton.titleLabel.adjustsFontSizeToFitWidth = NO;
    [self.teleSelectButton setTitle:@"|✎     Telestrations     ✎|" forState:UIControlStateNormal];
    [self.teleSelectButton setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
    [self.teleSelectButton setTitleColor:PRIMARY_APP_COLOR.highlightedColor forState:UIControlStateHighlighted];
    [self.teleSelectButton setTitleColor:PRIMARY_APP_COLOR.highlightedColor forState:UIControlStateSelected];
    [self.teleSelectButton setTitleColor:PRIMARY_APP_COLOR.highlightedColor forState:UIControlStateDisabled];
    
    self.tagNameSelectController.tagNameSelectResponder = self;
    self.teleSelectController.tagSelectResponder = self;
    
    self.recordButton.frame = CGRectMake(self.bottomBar.bounds.size.width - self.bottomBar.bounds.size.height, 0.0, self.bottomBar.bounds.size.height, self.bottomBar.bounds.size.height);
    self.recordButton.delegate = self;
    self.recordButton.timeProvider = self.videoPlayer;
    self.recordButton.displaysTime = NO;
    
    self.durationLabel.font = [UIFont systemFontOfSize:BAR_HEIGHT * PHI_INV];
    self.durationLabel.textColor = [UIColor lightGrayColor];
    self.durationLabel.text = @"00:00:00";
    self.durationLabel.textAlignment = NSTextAlignmentCenter;
    self.durationLabel.adjustsFontSizeToFitWidth = YES;
    
    [self.container addSubview:self.bottomBar];
    [self.bottomBar addSubview:self.tagSelectButton];
    [self.bottomBar addSubview:self.recordButton];
    [self.bottomBar addSubview:self.slomoButton];
    [self.bottomBar addSubview:self.liveButton];
    [self.bottomBar addSubview:self.durationLabel];
    [self.view addSubview:self.backwardSeekButton];
    [self.view addSubview:self.forwardSeekButton];
    
    [self.container addSubview:self.tagNameSelectController.view];
    [self.container addSubview:self.teleSelectController.view];
    [self.container addSubview:self.teleSelectButton];
    
    
    
    [self setShowsTagSelectMenu:NO animated:NO];
    [self setShowsTeleSelectMenu:NO animated:NO];
    
    self.recordButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    //self.backwardSeekButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    //self.forwardSeekButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    //self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.slomoButton.slomoOn = self.videoPlayer.slowmo;
    [self.view bringSubviewToFront:self.backwardSeekButton];
    [self.view bringSubviewToFront:self.forwardSeekButton];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.telestrationViewController.telestration = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSTimeInterval)currentTime {
    return CMTimeGetSeconds(self.videoPlayer.avPlayer.currentTime);;
}

- (void)telestration:(nonnull PxpTelestration *)telestration didStartInViewController:(nonnull PxpTelestrationViewController *)viewController {
    
    [self teleStarted];
}

- (void)telestration:(nonnull PxpTelestration *)telestration didFinishInViewController:(nonnull PxpTelestrationViewController *)viewController {
    
    if (telestration.actionStack.count) {
        
        NSTimeInterval clearTime = MAX(self.videoPlayer.currentTimeInSeconds, telestration.startTime + telestration.duration + 1.0);
        [telestration pushAction:[PxpTelestrationAction clearActionAtTime:clearTime]];
        
        telestration.sourceName = self.videoPlayer.feed.sourceName;
        telestration.isStill = NO;
        
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_CREATE_TELE_TAG object:self userInfo:@{
                                                                                                               @"time": [NSString stringWithFormat:@"%f",telestration.startTime],
                                                                                                               @"duration": [NSString stringWithFormat:@"%i",(int)roundf(telestration.duration)],
                                                                                                               @"starttime": [NSString stringWithFormat:@"%f",telestration.startTime],
                                                                                                               @"displaytime" : [NSString stringWithFormat:@"%f",telestration.startTime],
                                                                                                               @"telestration" : telestration.data,
                                                                                                }];
        
    }
    
    viewController.telestration = nil;
    
    [self teleEnded];
}

#pragma mark - Button Actions

- (void)seekButtonAction:(SeekButton *)button {
    [self.videoPlayer seekBy:button.speed];
}

- (void)slomoButtonAction:(Slomo *)slomo {
    self.videoPlayer.slowmo = !self.videoPlayer.slowmo;
    slomo.slomoOn = self.videoPlayer.slowmo;
}

- (void)liveButtonAction:(LiveButton *)liveButton {
    [self goToLive];
}

- (void)tagSelectButtonAction:(UIButton *)tagSelectButton {
    [self setShowsTagSelectMenu:!self.tagSelectButton.selected animated:YES];
}

- (void)teleSelectButtonAction:(UIButton *)teleSelectButton {
    [self setShowsTeleSelectMenu:!self.teleSelectButton.selected animated:YES];
}

#pragma mark - Record Button Delegate

- (void)recordingDidStartInRecordButton:(nonnull NCRecordButton *)recordButton {
    NSTimeInterval time = self.videoPlayer.currentTimeInSeconds;
    
    self.durationTagID = [Tag makeDurationID];
    if (self.durationTagID && self.activeTagName) {
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_TAG_POSTED object:self userInfo:@{
                                                                                                          @"name":self.activeTagName,
                                                                                                          @"time":[NSString stringWithFormat:@"%f", time],
                                                                                                          @"type":[NSNumber numberWithInteger:TagTypeOpenDuration],
                                                                                                          @"dtagid": self.durationTagID
                                                                                                          }];
    }
    
    
    [self recordingStarted];
}

- (void)recordingDidFinishInRecordButton:(nonnull NCRecordButton *)recordButton withDuration:(NSTimeInterval)duration {
    
    NSTimeInterval endTime = self.videoPlayer.currentTimeInSeconds;
    
    if (self.durationTagID) {
        Tag *tag = [Tag getOpenTagByDurationId:self.durationTagID];
        
        if (tag) {
            NSMutableDictionary * tagData   = [NSMutableDictionary dictionaryWithDictionary:[tag makeTagData]];
            
            [tagData setValue:[NSString stringWithFormat:@"%f", endTime] forKey:@"closetime"];
            [tagData setValue:[NSNumber numberWithInteger:TagTypeCloseDuration] forKey:@"type"];
            [tagData setValue:self.durationTagID forKey:@"dtagid"];
            
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MODIFY_TAG object:nil userInfo:tagData];
        }
    }
    
    self.durationTagID = nil;
    [self recordingEnded];
}

- (void)recordingDidTerminateInRecordButton:(nonnull NCRecordButton *)recordButton {
    
    if (self.durationTagID) {
        Tag *tag = [Tag getOpenTagByDurationId:self.durationTagID];
        if (tag) {
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_DELETE_TAG object:tag];
        }
    }
    
    self.durationTagID = nil;
    [self recordingEnded];
}

- (void)recordingTimeDidUpdateInRecordButton:(nonnull NCRecordButton *)recordButton {
    self.durationLabel.text = recordButton.recordingTimeString;
}

#pragma mark - TagNameSelectResponder

- (void)didSelectTagName:(nonnull NSString *)tagName {
    self.activeTagName = tagName;
    [self setShowsTagSelectMenu:NO animated:YES];
}

#pragma mark -TagSelectResponder

- (void)didSelectTag:(nonnull Tag *)tag source:(nonnull NSString *)source {
    Feed *feed = tag.event.feeds[source] ? tag.event.feeds[source] : tag.event.feeds.allValues.firstObject;
    self.telestrationViewController.telestration = tag.telestration;
    
    if (tag.telestration.isStill) {
        [self.videoPlayer cancelClip];
        [self.videoPlayer pause];
        [self.videoPlayer seekToInSec:tag.telestration.thumbnailTime];
    } else {
        [self.videoPlayer playClipWithFeed:feed andTimeRange:CMTimeRangeMake(CMTimeMake(tag.startTime, 1), CMTimeMake(tag.duration, 1))];
    }
    
    [self setShowsTeleSelectMenu:NO animated:YES];
}

#pragma mark - Private Methods

- (void)recordingStarted {
    self.teleSelectButton.enabled = NO;
    self.tagSelectButton.enabled = NO;
    self.forwardSeekButton.enabled = NO;
    self.backwardSeekButton.enabled = NO;
    self.liveButton.enabled = NO;
    self.videoPlayer.videoControlBar.enable = NO;
    self.telestrationViewController.showsControls = NO;
    
    [self setShowsTagSelectMenu:NO animated:YES];
    [self setShowsTeleSelectMenu:NO animated:YES];
    
    self.durationLabel.textColor = [UIColor whiteColor];
    
    [self.videoPlayer cancelClip];
}

- (void)recordingEnded {
    self.teleSelectButton.enabled = YES;
    self.tagSelectButton.enabled = YES;
    self.forwardSeekButton.enabled = YES;
    self.backwardSeekButton.enabled = YES;
    self.liveButton.enabled = _currentEvent.live;
    self.videoPlayer.videoControlBar.enable = YES;
    self.telestrationViewController.showsControls = YES;
    
    self.durationLabel.textColor = [UIColor lightGrayColor];
}

- (void)teleStarted {
    self.recordButton.enabled = NO;
    
    self.teleSelectButton.enabled = NO;
    self.tagSelectButton.enabled = NO;
    self.liveButton.enabled = NO;
    [self setShowsTagSelectMenu:NO animated:YES];
    [self setShowsTeleSelectMenu:NO animated:YES];
    
    [self.videoPlayer cancelClip];
}

- (void)teleEnded {
    self.recordButton.enabled = YES;
    
    self.teleSelectButton.enabled = YES;
    self.tagSelectButton.enabled = YES;
    self.liveButton.enabled = _currentEvent.live;
}

- (void)setShowsTagSelectMenu:(BOOL)showsTagSelectMenu animated:(BOOL)animated {
    if (showsTagSelectMenu) {
        
        if (animated) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.2];
        }
        
        self.tagNameSelectController.view.frame = CGRectMake(0.0, 0.0, self.tagSelectWidth, self.container.bounds.size.height - BAR_HEIGHT);
        
        if (animated) {
            [UIView commitAnimations];
        }
        
        [self setShowsTeleSelectMenu:NO animated:animated];
    } else {
        
        if (animated) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.2];
        }
        
        self.tagNameSelectController.view.frame = CGRectMake(0.0, self.container.bounds.size.height - BAR_HEIGHT, self.tagSelectWidth, 0.0);
        
        if (animated) {
            [UIView commitAnimations];
        }
    }
    
    self.tagSelectButton.selected = showsTagSelectMenu;
}

- (void)setShowsTeleSelectMenu:(BOOL)showsTeleSelectMenu animated:(BOOL)animated {
    
    const CGFloat halfWidth = self.container.bounds.size.width / 2.0;
    const CGFloat playerHeight = self.container.bounds.size.width / (16.0 / 9.0);
    const CGFloat teleSelectY = self.container.bounds.size.height - BAR_HEIGHT - playerHeight;
    
    if (showsTeleSelectMenu) {
        
        if (animated) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.2];
        }
        
        self.teleSelectController.view.frame = CGRectMake(halfWidth + halfWidth * (1.0 - PHI_INV), teleSelectY, halfWidth * PHI_INV, self.container.bounds.size.height - BAR_HEIGHT - teleSelectY);
        
        if (animated) {
            [UIView commitAnimations];
        }
        
        [self setShowsTagSelectMenu:NO animated:animated];
    } else {
        
        if (animated) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.2];
        }
        
        self.teleSelectController.view.frame = CGRectMake(halfWidth + halfWidth * (1.0 - PHI_INV), teleSelectY, halfWidth * PHI_INV, 0.0);
        
        if (animated) {
            [UIView commitAnimations];
        }
    }
    
    self.teleSelectButton.selected = showsTeleSelectMenu;
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
