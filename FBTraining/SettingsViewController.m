//
//  SettingsViewController.m
//  Live2BenchNative
//
//  Created by DEV on 2013-03-08.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "SettingsViewController.h"
#import "EncoderManager.h"
#import "Encoder.h"
#import "EncoderStatusMonitor.h"
#import "TablePopoverController.h"
#import "UserCenter.h"
#import "ListPopoverController.h"
#import "LeagueTeam.h"
#import "League.h"

@interface SettingsViewController ()

typedef enum {
    SVSignalSearching = 0,
    SVSignalShowing = 1,
    SVSignalNotFound = 2
} SVSignalStatus;


// This is for the button controll states
typedef NS_OPTIONS(NSInteger, EventButtonControlStates) {
    START_HIDDEN    = 1<<1,
    START_ENABLE    = 1<<2,
    STOP_HIDDEN     = 1<<3,
    STOP_ENABLE     = 1<<4,
    PAUSE_HIDDEN    = 1<<5,
    PAUSE_ENABLE    = 1<<6,
    RESUME_HIDDEN   = 1<<7,
    RESUME_ENABLE   = 1<<8,
    SHUTDOWN_HIDDEN = 1<<9,
    SHUTDOWN_ENABLE = 1<<10,
    
    HOME_ENABLE     = 1<<11,
    AWAY_ENABLE     = 1<<12,
    LEAGUE_ENABLE   = 1<<13,
    
    EventButtonControlStatesShutdown    = STOP_HIDDEN | PAUSE_HIDDEN | RESUME_HIDDEN |SHUTDOWN_ENABLE,
    EventButtonControlStatesDisabled    = STOP_HIDDEN | PAUSE_HIDDEN | RESUME_HIDDEN,
    EventButtonControlStatesReady       = STOP_HIDDEN | PAUSE_HIDDEN | RESUME_HIDDEN |SHUTDOWN_ENABLE | START_ENABLE | HOME_ENABLE | AWAY_ENABLE | LEAGUE_ENABLE,
    EventButtonControlStatesStart       = STOP_ENABLE | PAUSE_HIDDEN | RESUME_HIDDEN | SHUTDOWN_HIDDEN,
    EventButtonControlStatesLive        = STOP_ENABLE | PAUSE_ENABLE | START_HIDDEN | SHUTDOWN_HIDDEN | RESUME_HIDDEN,
    EventButtonControlStatesPause       = RESUME_ENABLE | STOP_ENABLE | START_HIDDEN | PAUSE_HIDDEN | SHUTDOWN_HIDDEN,
    EventButtonControlStatesStopping    = STOP_HIDDEN | PAUSE_HIDDEN | RESUME_HIDDEN | SHUTDOWN_ENABLE,
    BUTTON_STATE                        = START_HIDDEN | STOP_HIDDEN | PAUSE_HIDDEN | RESUME_HIDDEN | SHUTDOWN_HIDDEN
};
//typedef enum  {
//
//}EventButtonControlStates;


@property (strong, nonatomic, nonnull) CustomAlertView *pauseAlertView;
@property (strong, nonatomic, nonnull) CustomAlertView *stopAlertView;
@property (strong, nonatomic, nonnull) CustomAlertView *shutdownAlertView;
@property (strong, nonatomic, nonnull) CustomAlertView *startAlertView;
@property (strong, nonatomic, nonnull) CustomAlertView *noTeamAlertView;

#define DEFAULT_LEAGUE @"League"
#define DEFAULT_HOME_TEAM @"Home Team"
#define DEFAULT_AWAY_TEAM @"Away Team"

@end

@implementation SettingsViewController{
    
    UILabel                 * _encStateLabel;
    int                     encStateCounter;
    BOOL                    encoderAvailable;
    BOOL                    dismissEnabled;
    
    //Richard
    AppDelegate            * _appDel;
    EncoderManager         * encoderManager;
    NSObject <EncoderProtocol> *   masterEncoder;
    UserCenter             * userCenter;
    TablePopoverController * homeTeamPick;
    TablePopoverController * visitTeamPick;
    TablePopoverController * _leaguePick;
    NSArray                * teamNames;
    NSArray                * leagueNames;
    //    id                     observerForFoundMaster;
    id                     observerForLostMaster;
    UITapGestureRecognizer *tapBehindGesture;
    
    NSString                * _homeTeam;
    NSString                * _awayTeam;
    NSString                * _leagueName;
    
    NSArray * (^grabNames)(NSDictionary * input);
    
    //ListPopoverController   * askUser;
    
}

static void *masterContext;
@synthesize logoutButton,appVersionLabel,timerCounter,spinnerTimer,encHomeButton;
@synthesize waitEncoderResponseCounter;

NSTimer *signalTimer;
UIPopoverController *signalPop;
SVSignalStatus signalStatus;

-(id)initWithAppDelegate:(AppDelegate*)appDel
{
    self = [super init];
    if (self) {
        _appDel                 = appDel;
        dismissEnabled          = YES;
        encoderManager          = appDel.encoderManager;
        userCenter              = appDel.userCenter;
        masterContext           = &masterContext;
        homeTeamPick            = [[TablePopoverController alloc]init];
        visitTeamPick           = [[TablePopoverController alloc]init];
        _leaguePick              = [[TablePopoverController alloc]init];
        
        encoderHomeText         = [CustomLabel labelWithStyle:CLStyleOrange];
        encoderHomeText.text    = @"Encoder is not available.";
        
//        __block SettingsViewController * weakSelf = self;
        __block UILabel * weakStateLable    =  _encStateLabel;
        __block UILabel * weakHomeLable     =  encoderHomeText;
        __block NSObject <EncoderProtocol> * weakMasterEncoder =  masterEncoder;
        
        [_encStateLabel setHidden:YES];
        // observers
        //        observerForFoundMaster = [[NSNotificationCenter defaultCenter]addObserverForName:NOTIF_ENCODER_MASTER_FOUND object:nil queue:nil usingBlock:^(NSNotification *note) {
        //            masterEncoder = encoderManager.masterEncoder;
        //            encoderHomeText.text = @"Encoder Home";
        //            [encStateLabel setHidden:NO];
        //            [masterEncoder addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:&masterContext];
        //        }];
        
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onMasterFound:) name:NOTIF_ENCODER_MASTER_FOUND object:nil];

        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showInformation) name:NOTIF_LIVE_EVENT_FOUND object:nil];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeStatusString:) name:NOTIF_STATUS_LABEL_CHANGED object:nil];
        
        
        observerForLostMaster = [[NSNotificationCenter defaultCenter]addObserverForName:NOTIF_ENCODER_MASTER_HAS_FALLEN object:nil queue:nil usingBlock:^(NSNotification *note) {
            if (weakMasterEncoder != nil){
                weakHomeLable.text = @"Encoder is not available.";
                [weakStateLable setHidden:YES];
                
                
               
            }
            weakHomeLable.text = @"Encoder is not available.";
        }];
        
        
        _leagueName              = DEFAULT_LEAGUE;
        _homeTeam            = DEFAULT_HOME_TEAM;
        _awayTeam            = DEFAULT_AWAY_TEAM;
        
        
        self.pauseAlertView = [[CustomAlertView alloc] initWithTitle:NSLocalizedString(@"Pause Event", nil) message:NSLocalizedString(@"Are you sure you want to pause the event?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Yes", nil) otherButtonTitles:NSLocalizedString(@"Cancel", nil), nil];
        self.pauseAlertView.type = AlertIndecisive;
        
        self.stopAlertView = [[CustomAlertView alloc] initWithTitle:NSLocalizedString(@"Stop Event", nil) message:NSLocalizedString(@"Are you sure you want to stop the event?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Yes", nil) otherButtonTitles:NSLocalizedString(@"Cancel", nil), nil];
        self.stopAlertView.type = AlertIndecisive;
        
        self.shutdownAlertView = [[CustomAlertView alloc] initWithTitle:NSLocalizedString(@"Shutdown Encoder", nil) message:NSLocalizedString(@"Are you sure you want to shutdown the encoder?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Yes", nil) otherButtonTitles:NSLocalizedString(@"Cancel", nil), nil];
        self.shutdownAlertView.type = AlertIndecisive;
        
        self.startAlertView = [[CustomAlertView alloc]initWithTitle:NSLocalizedString(@"myplayXplay", nil) message:@"Please select Home team, Away team and League to start the encoder" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];

        self.noTeamAlertView = [[CustomAlertView alloc]initWithTitle:NSLocalizedString(@"No Team", nil) message:NSLocalizedString(@"There is no team for this league", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
    }
    return self;
}

- (void)setupView
{
    
    [self.view setFrame:CGRectMake(0, 0, 350.0f, 768.0f)];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.delegate = self;
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:scrollView];
    
    wifi = [[UILabel alloc]initWithFrame:CGRectMake(20.0f, 86.0f, 300.0f, 23.0f)];
    wifi.text =[NSString stringWithFormat: @"%@: %@", NSLocalizedString(@"Wi-Fi", nil), [Utility myWifiName] ];
    [scrollView addSubview:wifi];
    
    CustomLabel *encoderControlsLabel = [CustomLabel labelWithStyle:CLStyleBlackHeader];
    encoderControlsLabel.frame = CGRectMake(20.0f, 20.0f, 200.0f, 23.0f);
    encoderControlsLabel.text = NSLocalizedString(@"Encoder Controls", nil);
    //    [scrollView addSubview:encoderControlsLabel];
    //
    //    CustomLabel *versionLabel = [CustomLabel labelWithStyle:CLStyleBlack];
    //    versionLabel.frame = CGRectMake(self.view.bounds.size.width - 125.0f, encoderControlsLabel.frame.origin.y + 6.0f, 63.0f, 17.0f);
    //    versionLabel.text = @"Version:";
    //    versionLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    //    [scrollView addSubview:versionLabel];
    
    //    appVersionLabel = [CustomLabel labelWithStyle:CLStyleGrey];
    //    appVersionLabel.frame = CGRectMake(CGRectGetMaxX(versionLabel.frame), versionLabel.frame.origin.y, 55.0f, versionLabel.frame.size.height);
    //    appVersionLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    //    [scrollView addSubview:appVersionLabel];
    
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(15.0f, CGRectGetMaxY(encoderControlsLabel.frame) + 5.0f, self.view.bounds.size.width - 30.0f, 1.0f)];
    line1.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    line1.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f];
    //    [scrollView addSubview:line1];
    
    
    selectLeagueContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(line1.frame) + 70.0f, self.view.bounds.size.width, 55.0f)];
    selectLeagueContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [scrollView addSubview:selectLeagueContainer];
    
    selectHomeContainer = [[UIView alloc] initWithFrame:CGRectMake(selectLeagueContainer.frame.origin.x, CGRectGetMaxY(selectLeagueContainer.frame), selectLeagueContainer.bounds.size.width, selectLeagueContainer.bounds.size.height)];
    selectHomeContainer.autoresizingMask = selectLeagueContainer.autoresizingMask;
    [scrollView addSubview:selectHomeContainer];
    
    selectAwayContainer = [[UIView alloc] initWithFrame:CGRectMake(selectLeagueContainer.frame.origin.x, CGRectGetMaxY(selectHomeContainer.frame), selectLeagueContainer.bounds.size.width, selectLeagueContainer.bounds.size.height)];
    selectAwayContainer.autoresizingMask = selectLeagueContainer.autoresizingMask;
    [scrollView addSubview:selectAwayContainer];
    
    firstEncButton = [[UIView alloc] initWithFrame:CGRectMake(80.0f, CGRectGetMaxY(selectAwayContainer.frame) + 80.0f, 150.0f, 150.0f)];
    firstEncButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [scrollView addSubview:firstEncButton];
    
    secondEncButton = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 80.0f - 150.0f, firstEncButton.frame.origin.y, 150.0f, 150.0f)];
    secondEncButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    [scrollView addSubview:secondEncButton];
    
    encoderHomeLabel = [[UIView alloc] initWithFrame:CGRectMake(16.0f, CGRectGetMaxY(line1.frame), 380.0f, 35.0f)];
    encoderHomeLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [scrollView addSubview:encoderHomeLabel];
    
    CustomLabel *signalStrengthLabel = [CustomLabel labelWithStyle:CLStyleOrange];
    signalStrengthLabel.frame = CGRectMake(self.view.bounds.size.width - 150.0f, encoderHomeLabel.frame.origin.y, 70.0f, 55.0f);
    signalStrengthLabel.textAlignment = NSTextAlignmentRight;
    signalStrengthLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    signalStrengthLabel.text = @"Signal:";
    //    [scrollView addSubview:signalStrengthLabel];
    
    UIView *signalStrengthBG = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(signalStrengthLabel.frame) + 5.0f, CGRectGetMaxY(line1.frame) + 6.0f, 31.0f, 28.0f)];
    signalStrengthBG.backgroundColor = [UIColor colorWithRed:(202.0f/255.0f) green:(100.0f/255.0f) blue:0.0f alpha:1.0f];
    signalStrengthBG.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    //    [scrollView addSubview:signalStrengthBG];
    
    //Width of this frame represents the strength of the signal
    signalStrengthView = [[UIView alloc] initWithFrame:CGRectMake(signalStrengthBG.frame.origin.x + 1.0f, signalStrengthBG.frame.origin.y, 0.0f, signalStrengthBG.bounds.size.height)];
    signalStrengthView.backgroundColor = PRIMARY_APP_COLOR;
    signalStrengthView.autoresizingMask = signalStrengthBG.autoresizingMask;
    signalStatus = SVSignalShowing;
    //    [scrollView addSubview:signalStrengthView];
    
    signalStrengthOverlay = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"signalStrength"]];
    signalStrengthOverlay.frame = signalStrengthBG.frame;
    signalStrengthOverlay.autoresizingMask = signalStrengthBG.autoresizingMask;
    //    [scrollView addSubview:signalStrengthOverlay];
    
    UIButton *signalPopoverButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [signalPopoverButton addTarget:self action:@selector(showSignalPopover:) forControlEvents:UIControlEventTouchUpInside];
    [signalPopoverButton setImage:[UIImage imageNamed:@"detailDisclosure"] forState:UIControlStateNormal];
    signalPopoverButton.frame = CGRectMake(self.view.bounds.size.width - 35.0f, signalStrengthOverlay.frame.origin.y, 28.0f, 28.0f);
    signalPopoverButton.autoresizingMask = signalStrengthBG.autoresizingMask;
    //    [scrollView addSubview:signalPopoverButton];
    
    //    CustomLabel *generalLabel = [CustomLabel labelWithStyle:CLStyleBlackHeader];
    //    generalLabel.frame = CGRectMake(20.0f, self.view.frame.size.height - 150.0f, 100.0f, 23.0f);
    //    generalLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
    //    generalLabel.text = @"General";
    //    [scrollView addSubview:generalLabel];
    //
    //    viewEulaContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(generalLabel.frame), self.view.bounds.size.width, 85.0f)];
    //    viewEulaContainer.backgroundColor = [UIColor clearColor];
    //    viewEulaContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    //
    //    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(15.0f, 5.0f, viewEulaContainer.bounds.size.width - 30.0f, 1.0f)];
    //    line2.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    //    line2.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f];
    //    [viewEulaContainer addSubview:line2];
    //    [scrollView addSubview: viewEulaContainer];
    //
    //    doNotShowContainer = [[UIView alloc] initWithFrame:CGRectMake(generalLabel.frame.origin.x, CGRectGetMaxY(viewEulaContainer.frame) + 14.0f, self.view.bounds.size.width - 2*generalLabel.frame.origin.x, 59.0f)];
    //    doNotShowContainer.backgroundColor = [UIColor clearColor];
    //    doNotShowContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    //    [scrollView addSubview:doNotShowContainer];
    //
    //    CustomLabel *userLabel = [CustomLabel labelWithStyle:CLStyleBlack];
    //    userLabel.text = @"User:";
    //    userLabel.frame = CGRectMake(15.0f, CGRectGetMaxY(self.view.frame) - 45.0f, 45.0f, 30.0f);
    //    userLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    //    [self.view addSubview:userLabel];
    //
    //    userName = [CustomLabel labelWithStyle:CLStyleGrey];
    //    userName.frame = CGRectMake(CGRectGetMaxX(userLabel.frame), userLabel.frame.origin.y, 207.0f, 30.0f);
    //    userName.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    //    [self.view addSubview:userName];
    //
    //    logoutButton = [BorderlessButton buttonWithType:UIButtonTypeSystem];
    //    [logoutButton setTitle:@"Logout" forState:UIControlStateNormal];
    //    logoutButton.frame = CGRectMake(self.view.frame.size.width - 90.0f, userLabel.frame.origin.y, 75.0f, 30.0f);
    //    logoutButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    //    [logoutButton addTarget:self action:@selector(appLogOut:) forControlEvents:UIControlEventTouchUpInside];
    //    [self.view addSubview:logoutButton];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //init subviews
    [self setupView];
    

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateForStatus) name:@"updatedEncoderStatus" object:nil];

    [appVersionLabel setText:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];

    [self initialiseLayout];

}


-(void)viewDidAppear:(BOOL)animated
{
    
    
    [super viewDidAppear:animated];
    
    if(!tapBehindGesture) {
        tapBehindGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBehindDetected:)];
        tapBehindGesture.delegate = self;
        [tapBehindGesture setNumberOfTapsRequired:1];
        [tapBehindGesture setCancelsTouchesInView:NO]; //So the user can still interact with controls in the modal view
    }
    
    [self.view.window addGestureRecognizer:tapBehindGesture];
    
}


-(void)viewWillAppear:(BOOL)animated
{
    wifi.text =[NSString stringWithFormat: @"%@: %@", NSLocalizedString(@"Wi-Fi", nil), [Utility myWifiName] ];
    [super viewWillAppear:animated];
    
    [self setButtonImagesAndLabels];
    
    signalTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateSignalStrength) userInfo:nil repeats:YES];
    [signalTimer fire];
    
    // block
    grabNames = ^NSArray *(NSDictionary *input) {
        NSMutableArray  * collection    = [[NSMutableArray alloc]init];
        NSArray         * keys          = [input allKeys];
        for (NSString * item in keys) {
            League *itemLeague = [input objectForKey:item];
            NSString * name = itemLeague.name;
            //NSString    * nam  = [[input objectForKey:item] objectForKey:@"name"];
            [collection addObject:name];
        }

        return [[NSSet setWithArray:collection]allObjects];
    };
    // block end
    
    //teamNames   = grabNames(encoderManager.masterEncoder.teams);
    //leagueNames = grabNames(encoderManager.masterEncoder.league);
    
    
}


/*
 Deselects all buttons and stops timer
 
 */
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [signalTimer invalidate];
    signalTimer = nil;
    
    selectHomeTeam.selected     = NO;
    selectAwayTeam.selected     = NO;
    selectLeague.selected       = NO;
    
}



- (void)tapBehindDetected:(UITapGestureRecognizer *)sender
{
    
    
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        UIView *rootView = self.view.window.rootViewController.view;
        CGPoint location = [sender locationInView:rootView];
        if (![self.view pointInside:[self.view convertPoint:location fromView:rootView] withEvent:nil]) {
            [self dismiss];
        }
        
    }
}



/**
 *  Dissmisses this view
 *  This method should be used by the tap behind method or the automatically on success
 */
-(void)dismiss
{
    if (dismissEnabled){
        [self dismissViewControllerAnimated:YES completion:nil];
        [self.view.window removeGestureRecognizer:tapBehindGesture];
    }
}

#pragma mark - Observers

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &masterContext){
        //[[change objectForKey:@"new"]integerValue]
        [self masterEncoderStatusObserver:(Encoder*)object];
    }

    
    if ([keyPath isEqualToString:@"isAlive"]) {
        Encoder * enc = (Encoder *)object;
        [enc removeObserver:self forKeyPath:@"status" context:&masterContext];
        [enc removeObserver:self forKeyPath:@"isAlive" context:nil];
    }
    
}


-(void)masterEncoderStatusObserver:(id<EncoderProtocol>)master
{
    EncoderStatus status    = master.status;
    NSString * stringStatus = master.statusAsString;
    switch (status) {
            
        case ENCODER_STATUS_INIT :
            if (DEBUG_MODE)  NSLog(@"ENCODER_STATUS_INIT");
        case ENCODER_STATUS_UNKNOWN :
            if (DEBUG_MODE)  NSLog(@"ENCODER_STATUS_UNKNOWN");
            [self eventControlsState:EventButtonControlStatesDisabled];
        case ENCODER_STATUS_CAM_LOADING :
            if (DEBUG_MODE)  NSLog(@"ENCODER_STATUS_CAM_LOADING");
            [self eventControlsState:EventButtonControlStatesDisabled];
            break;
        case ENCODER_STATUS_READY :
            if (DEBUG_MODE)  NSLog(@"ENCODER_STATUS_READY");
            [self eventControlsState:EventButtonControlStatesReady];
            break;
        case ENCODER_STATUS_LIVE :
            if (DEBUG_MODE)   NSLog(@"ENCODER_STATUS_LIVE");
            [self eventControlsState:EventButtonControlStatesLive];
            break;
        case ENCODER_STATUS_SHUTDOWN :
            if (DEBUG_MODE)  NSLog(@"ENCODER_STATUS_SHUTDOWN");
            [self eventControlsState:EventButtonControlStatesDisabled];
            break;
        case ENCODER_STATUS_PAUSED :
            if (DEBUG_MODE)   NSLog(@"ENCODER_STATUS_PAUSED");
            [self eventControlsState:EventButtonControlStatesPause];
            break;
        case ENCODER_STATUS_STOP :
            if (DEBUG_MODE)  NSLog(@"ENCODER_STATUS_STOPPING");
            [self eventControlsState:EventButtonControlStatesStopping];
            break;
        case ENCODER_STATUS_START :
            if (DEBUG_MODE)  NSLog(@"ENCODER_STATUS_START");
            [self eventControlsState:EventButtonControlStatesStart];
            break;
        case ENCODER_STATUS_NOCAM :
            if (DEBUG_MODE)   NSLog(@"ENCODER_STATUS_NOCAM");
            [self eventControlsState:EventButtonControlStatesShutdown];
            break;
        case ENCODER_STATUS_LOCAL :
            if (DEBUG_MODE)  NSLog(@"ENCODER_STATUS_LOCAL");
            [self eventControlsState:EventButtonControlStatesDisabled];
            break;
            
        default:
            break;
    }
    

    if ([stringStatus isEqualToString:@"stopped"]) stringStatus= @"ready"; // This is just to make the display more user friendly
    if ([stringStatus length] == 0) {
        stringStatus = @"No Encoder";
    }
    [_encStateLabel setText:[NSString stringWithFormat:@"( %@ )",stringStatus]];
}

-(void)changeStatusString:(NSNotification*)note{
    if (note.userInfo) {
        [_encStateLabel setText:[NSString stringWithFormat:@"( %@ )", note.userInfo[@"text"]]];
    }else{
        [_encStateLabel setText:@"( ready )"];
        [pauseButton setHidden:true];
        [startButton setHidden:false];
        [startButton setEnabled:true];
        [startButton setAlpha:1.0];
        [stopButton setHidden:true];
        [shutdownButton setHidden:false];
        [shutdownButton setEnabled:true];
        [shutdownButton setAlpha:1.0];
        [selectHomeTeam setTitle:DEFAULT_HOME_TEAM forState:UIControlStateNormal];
        [selectHomeTeam setUserInteractionEnabled:true];
        [selectHomeTeam setAlpha:1.0];
        [selectAwayTeam setTitle:DEFAULT_AWAY_TEAM forState:UIControlStateNormal];
        [selectAwayTeam setUserInteractionEnabled:true];
        [selectAwayTeam setAlpha:1.0];
        [selectLeague setTitle:DEFAULT_LEAGUE forState:UIControlStateNormal];
        [selectLeague setUserInteractionEnabled:true];
        [selectLeague setAlpha:1.0];
    }
    
}

-(void)onMasterFound:(NSNotification*)note
{
    masterEncoder = encoderManager.masterEncoder;
    encoderHomeText.text = @"Encoder Home";
    [_encStateLabel setHidden:NO];
    [encoderHomeText setAlpha:1];
    [masterEncoder addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:&masterContext];
    [masterEncoder addObserver:self forKeyPath:@"isAlive" options:NSKeyValueObservingOptionNew context:nil];
    [self masterEncoderStatusObserver:masterEncoder];// run it once just to display status
    // block
//    NSArray * (^grabNames)(NSDictionary * input) = ^NSArray * (NSDictionary * input) {
//        NSMutableArray  * collection    = [[NSMutableArray alloc]init];
//        NSArray         * keys          = [input allKeys];
//        for (NSString * item in keys) {
//            NSString    * nam  = [[input objectForKey:item] objectForKey:@"name"];
//            [collection addObject:nam];
//        }
//        return [collection copy];
//    };
    // block end
    
//  teamNames   = grabNames(encoderManager.masterEncoder.teams);
//  leagueNames = grabNames(encoderManager.masterEncoder.league);
}



#pragma mark -
#pragma mark Encoder Controls


- (void)startEnc:(id)sender
{
    
    NSString * buttonTitle = ((UIButton*)sender).titleLabel.text;
    
    NSString *ahomeTeam=[selectHomeTeam.titleLabel.text isEqualToString:DEFAULT_HOME_TEAM] ? nil : selectHomeTeam.titleLabel.text;
    NSString *aawayTeam=[selectAwayTeam.titleLabel.text isEqualToString:DEFAULT_AWAY_TEAM] ? nil : selectAwayTeam.titleLabel.text;
    NSString *aleague=[selectLeague.titleLabel.text isEqualToString:DEFAULT_LEAGUE] ? nil : selectLeague.titleLabel.text;
    
    if(!(ahomeTeam && aawayTeam && aleague))//only allow user to start enc if they have selected all three, home team, away team, league
    {
        if (masterEncoder.status == ENCODER_STATUS_READY || masterEncoder.status == ENCODER_STATUS_STOP)
            //        if([globals.CURRENT_ENC_STATUS isEqualToString:encStateReady] || [globals.CURRENT_ENC_STATUS isEqualToString:encStateStopped])
        {
            /*CustomAlertView *alert = [[CustomAlertView alloc]
                                      initWithTitle: @"myplayXplay"
                                      message: @"Please select Home team, Away team and League to start the encoder"
                                      delegate: self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];*/
            [self.startAlertView showView];
            //[alert showView];
            //            [globals.ARRAY_OF_POPUP_ALERT_VIEWS addObject:alert];
            return;
        }
    }
    
    if ([buttonTitle isEqualToString:@"Start"]) {
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MASTER_COMMAND object:self userInfo:@{@"start"  : [NSNumber numberWithBool:YES],
                                                                                                              @"homeTeam"   : ahomeTeam,
                                                                                                              @"awayTeam"   : aawayTeam,
                                                                                                              @"league" : aleague
                                                                                                              }];
        [self eventControlsState:EventButtonControlStatesStart];
    } else { // resume video
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MASTER_COMMAND object:self userInfo:@{@"resume"  : [NSNumber numberWithBool:YES]}];
    }
    
}


- (void)shutdownEnc:(id)sender {
    if(![self.shutdownAlertView display]) {
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MASTER_COMMAND object:self userInfo:@{@"shutdown"  : [NSNumber numberWithBool:YES]}];
    }
}

- (void)pauseEnc:(id)sender {
    [self.pauseAlertView display];
    if(![self.pauseAlertView display]) {
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MASTER_COMMAND object:self userInfo:@{@"pause"  : [NSNumber numberWithBool:YES]}];
    }
}

- (void)stopEnc:(id)sender {
    if(![self.stopAlertView display]) {
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MASTER_COMMAND object:self userInfo:@{@"stop"  : [NSNumber numberWithBool:YES]}];
    }
}


#pragma mark -


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_RECEIVE_MEMORY_WARNING object:self];
}

-(void)updateSignalStrength {
    //    if (!globals.HAS_MIN || globals.BIT_RATE == 0) {
    //        signalStatus = SVSignalNotFound;
    //        signalStrengthView.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
    //        [signalStrengthOverlay setImage:[UIImage imageNamed:@"signalStrength"]];
    //        //1px whitespace on overlay
    //        float maxWidth = signalStrengthOverlay.bounds.size.width - 2.0f;
    //        CGRect tempRect = signalStrengthView.frame;
    //        tempRect.size.width = maxWidth;
    //        signalStrengthView.frame = tempRect;
    //
    //    } else if (globals.BIT_RATE > 0){
    //        signalStatus = SVSignalShowing;
    //        double strength = globals.BIT_RATE/1000;
    //        if (strength > 1.0)
    //            strength = 1.0;
    //        signalStrengthView.backgroundColor = PRIMARY_APP_COLOR;
    //        [signalStrengthOverlay setImage:[UIImage imageNamed:@"signalStrength"]];
    //        //1px whitespace on overlay
    //        float maxWidth = signalStrengthOverlay.bounds.size.width - 2.0f;
    //        float signalWidth = strength*maxWidth;
    //        CGRect tempRect = signalStrengthView.frame;
    //        tempRect.size.width = signalWidth;
    //        signalStrengthView.frame = tempRect;
    //    } else if (globals.BIT_RATE < 0) {
    //        if (signalStatus != SVSignalSearching){
    //            NSURL *url = [[NSBundle mainBundle] URLForResource:@"signalStrength" withExtension:@"gif"];
    //            [signalStrengthOverlay setImage:[UIImage animatedImageWithAnimatedGIFURL:url]];
    //            signalStatus = SVSignalSearching;
    //        }
    //    }
}

-(void)showSignalPopover:(id)sender {
    //    UIButton *popButton = (UIButton*)sender;
    //
    //    signalPop = [[UIPopoverController alloc] initWithContentViewController:[[SignalStrengthViewController alloc] init]];
    //    [signalPop setDelegate:self];
    //    [signalPop setPopoverContentSize:CGSizeMake(300.0f, 200.0f)];
    //    [signalPop presentPopoverFromRect:popButton.frame inView:scrollView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

-(void)pickHome:(id)sender
{
    
    if ([_leagueName isEqualToString:DEFAULT_LEAGUE]){
        teamNames   = grabNames(encoderManager.masterEncoder.encoderTeams);
    } else {
        /*NSDictionary * tempDict1 = [encoderManager.masterEncoder.encoderLeagues copy];
        NSArray * myList1        = [[tempDict1 allValues] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",league ]];
        League *l = myList1[0];
        NSString * leagueHID     = l.hid;
        //NSString * leagueHID     = myList1[0][@"hid"];
        
        NSDictionary * tempDict = [encoderManager.masterEncoder.encoderTeams copy];
        
        NSArray * myList = [[tempDict allValues] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"league == %@",leagueHID ]];

        NSMutableArray  * collection    = [[NSMutableArray alloc]init];

        for (NSDictionary * item in myList) {
            NSString    * nam  = [item objectForKey:@"name"];
            [collection addObject:nam];
        }*/
        
        League *currentLeague = [encoderManager.masterEncoder.encoderLeagues objectForKey:_leagueName];
        NSArray *teamsCollection = [currentLeague.teams allValues];
        NSMutableArray *teamsNameCollection = [[NSMutableArray alloc]init];
        for (LeagueTeam * team in teamsCollection) {
            NSString    * teamName  = team.name;
            [teamsNameCollection addObject:teamName];
        }
        teamNames = [[NSSet setWithArray:teamsNameCollection]allObjects];

        
        //teamNames   = [[NSSet setWithArray:collection]allObjects];
    }
    if (teamNames) {
        UIButton *popButton = (UIButton*)sender;
        //popButton.selected  = YES;
        [homeTeamPick populateWith:teamNames];
        __block SettingsViewController * weakSelf = self;
        [homeTeamPick addOnCompletionBlock:^(NSString *pick) {
            [popButton setTitle:pick forState:UIControlStateNormal];
            //popButton.selected = NO;
            weakSelf -> _awayTeam = pick;
        }];
        
        [homeTeamPick presentPopoverFromRect:popButton.frame inView:selectHomeContainer permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
}

-(void)pickAway:(id)sender
{
    if ([_leagueName isEqualToString:DEFAULT_LEAGUE]){
        teamNames   = grabNames(encoderManager.masterEncoder.encoderTeams);
    } else {
        /*NSDictionary * tempDict1 = [encoderManager.masterEncoder.encoderLeagues copy];
        NSArray * myList1        = [[tempDict1 allValues] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",league ]];
        League *l = myList1[0];
        NSString * leagueHID     = l.hid;
        //NSString * leagueHID     = myList1[0][@"hid"];
        
        NSDictionary * tempDict = [encoderManager.masterEncoder.encoderTeams copy];
        
        NSArray * myList = [[tempDict allValues] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"league == %@",leagueHID ]];
        
        NSMutableArray  * collection    = [[NSMutableArray alloc]init];
        
        for (NSDictionary * item in myList) {
            NSString    * nam  = [item objectForKey:@"name"];
            [collection addObject:nam];
        }*/
        
        League *currentLeague = [encoderManager.masterEncoder.encoderLeagues objectForKey:_leagueName];
        NSArray *teamsCollection = [currentLeague.teams allValues];
        NSMutableArray *teamsNameCollection = [[NSMutableArray alloc]init];
        for (LeagueTeam * team in teamsCollection) {
            NSString    * teamName  = team.name;
            [teamsNameCollection addObject:teamName];
        }
        teamNames = [[NSSet setWithArray:teamsNameCollection]allObjects];

        
        //teamNames   = [[NSSet setWithArray:collection]allObjects];
    }
    
    if (teamNames) {
        UIButton *popButton = (UIButton*)sender;
        //popButton.selected = YES;
        [visitTeamPick populateWith:teamNames];
        __block SettingsViewController * weakSelf = self;
        [visitTeamPick addOnCompletionBlock:^(NSString *pick) {
            [popButton setTitle:pick forState:UIControlStateNormal];
            //popButton.selected = NO;
            weakSelf -> _awayTeam = pick;
        }];
        
        [visitTeamPick presentPopoverFromRect:popButton.frame inView:selectAwayContainer permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
}

-(void)pickLeague:(id)sender
{
    leagueNames = grabNames(encoderManager.masterEncoder.encoderLeagues);
    if (leagueNames) {
        UIButton *popButton = (UIButton*)sender;
        //popButton.selected = YES;
        __block SettingsViewController * weakSelf = self;
        [_leaguePick populateWith:leagueNames];
        [_leaguePick addOnCompletionBlock:^(NSString *pick) {
            [popButton setTitle:pick forState:UIControlStateNormal];
            //popButton.selected = NO;
            weakSelf -> _leagueName = pick;
            [weakSelf checkUserSelection];
        }];
        
        [_leaguePick presentPopoverFromRect:popButton.frame inView:selectLeagueContainer permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    

}

-(void)checkUserSelection
{
    League *league = [encoderManager.masterEncoder.encoderLeagues objectForKey:_leagueName];
    if ([league.teams allValues].count == 0) {
        [self.noTeamAlertView showView];
    }

    
    //League *league = [encoderManager.masterEncoder.encoderLeagues objectForKey:_leagueName];
    //NSString *leagueHid = league.hid;
    
    //NSString * leagueHid = [[[encoderManager.masterEncoder.encoderLeagues copy] allValues] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",league ]][0][@"hid"];
    
    //NSArray * teamsDataList =[[encoderManager.masterEncoder.encoderTeams copy] allValues];
    
    //NSArray * filter1 = [teamsDataList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",homeTeamPick.userPick ]];
    //NSArray * filter2 = [teamsDataList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",visitTeamPick.userPick ]];
    //NSString * homeTeamLeagueHid = ([filter1 count])?filter1[0][@"league"]:@"";
    //NSString * awayTeamLeagueHid = ([filter2 count])?filter1[0][@"league"]:@"";
    
    //if (![homeTeamLeagueHid isEqualToString:leagueHid]) {
        //homeTeamPick.userPick = DEFAULT_HOME_TEAM;
        [selectHomeTeam  setTitle:DEFAULT_HOME_TEAM forState:UIControlStateNormal];
    //}
    
    
    // (![awayTeamLeagueHid isEqualToString:leagueHid]) {
        //visitTeamPick.userPick = DEFAULT_AWAY_TEAM;
        [selectAwayTeam setTitle:DEFAULT_AWAY_TEAM forState:UIControlStateNormal];

    //}
}

-(void)initialiseLayout
{
    selectHomeTeam = [DropdownButton buttonWithType:UIButtonTypeCustom];
    
    [selectHomeTeam setFrame:CGRectMake(0.0f, 0.0f, selectHomeContainer.bounds.size.width, selectHomeContainer.bounds.size.height)];
    selectHomeTeam.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [selectHomeTeam setTitle:_homeTeam forState:UIControlStateNormal];
    [selectHomeTeam setTag:0];
    [selectHomeTeam addTarget:self action:@selector(pickHome:) forControlEvents:UIControlEventTouchUpInside];
    [selectHomeContainer addSubview:selectHomeTeam];
    
    selectAwayTeam = [DropdownButton buttonWithType:UIButtonTypeCustom];
    
    [selectAwayTeam setFrame:CGRectMake(0.0f, 0.0f, selectAwayContainer.bounds.size.width, selectAwayContainer.bounds.size.height)];
    selectAwayTeam.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [selectAwayTeam setTitle:_awayTeam forState:UIControlStateNormal];
    [selectAwayTeam setTag:1];
    [selectAwayTeam addTarget:self action:@selector(pickAway:) forControlEvents:UIControlEventTouchUpInside];
    [selectAwayContainer addSubview:selectAwayTeam];
    
    selectLeague = [DropdownButton buttonWithType:UIButtonTypeCustom];
    
    [selectLeague setFrame:CGRectMake(0.0f, 0.0f, selectLeagueContainer.bounds.size.width, selectLeagueContainer.bounds.size.height)];
    selectLeague.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [selectLeague setTitle:_leagueName forState:UIControlStateNormal];
    [selectLeague setTag:2];
    [selectLeague addTarget:self action:@selector(pickLeague:) forControlEvents:UIControlEventTouchUpInside];
    [selectLeagueContainer addSubview:selectLeague];
    
    startButton = [BorderlessButton buttonWithType:UIButtonTypeCustom];
    
    [startButton setTitle:@"Start" forState:UIControlStateNormal];
    [startButton setTitleColor:[UIColor colorWithRed:57.0f/255.0f green:181.0f/255.0f blue:74.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [startButton setBackgroundImage:[UIImage imageNamed:@"GreenSettingsButton"] forState:UIControlStateNormal];
    [startButton setBackgroundImage:[UIImage imageNamed:@"GreenSettingsButtonSelect"] forState:UIControlStateHighlighted];
    [startButton setFrame:firstEncButton.bounds];
    startButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [startButton addTarget:self action:@selector(startEnc:) forControlEvents:UIControlEventTouchUpInside];
    [firstEncButton addSubview:startButton];
    
    resumeButton = [BorderlessButton buttonWithType:UIButtonTypeCustom];
    [resumeButton setTitle:@"Resume" forState:UIControlStateNormal];
    [resumeButton setTitleColor:[UIColor colorWithRed:57.0f/255.0f green:181.0f/255.0f blue:74.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [resumeButton setBackgroundImage:[UIImage imageNamed:@"GreenSettingsButton"] forState:UIControlStateNormal];
    [resumeButton setBackgroundImage:[UIImage imageNamed:@"GreenSettingsButtonSelect"] forState:UIControlStateHighlighted];
    [resumeButton setFrame: startButton.frame];
    resumeButton.autoresizingMask = startButton.autoresizingMask;
    [resumeButton addTarget:self action:@selector(startEnc:) forControlEvents:UIControlEventTouchUpInside];
    [firstEncButton addSubview:resumeButton];
    
    pauseButton = [BorderlessButton buttonWithType:UIButtonTypeCustom];
    [pauseButton setTitleColor:[UIColor colorWithRed:0.0f/255.0f green:113.0f/255.0f blue:188.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [pauseButton setBackgroundImage:[UIImage imageNamed:@"BlueSettingsButton"] forState:UIControlStateNormal];
    [pauseButton setBackgroundImage:[UIImage imageNamed:@"BlueSettingsButtonSelect"] forState:UIControlStateHighlighted];
    [pauseButton setFrame: startButton.frame];
    pauseButton.autoresizingMask = startButton.autoresizingMask;
    [pauseButton setTitle:@"Pause" forState:UIControlStateNormal];
    [pauseButton addTarget:self action:@selector(pauseEnc:) forControlEvents:UIControlEventTouchUpInside];
    [firstEncButton addSubview:pauseButton];
    
    shutdownButton = [BorderlessButton buttonWithType:UIButtonTypeCustom];
    [shutdownButton setTitleColor:[UIColor colorWithRed:0.0f/255.0f green:113.0f/255.0f blue:188.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [shutdownButton setBackgroundImage:[UIImage imageNamed:@"BlueSettingsButton"] forState:UIControlStateNormal];
    [shutdownButton setBackgroundImage:[UIImage imageNamed:@"BlueSettingsButtonSelect"] forState:UIControlStateHighlighted];
    [shutdownButton setFrame:secondEncButton.bounds];
    shutdownButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [shutdownButton setTitle:@"Shutdown" forState:UIControlStateNormal];
    [shutdownButton addTarget:self action:@selector(shutdownEnc:) forControlEvents:UIControlEventTouchUpInside];
    [secondEncButton addSubview:shutdownButton];
    
    stopButton = [BorderlessButton buttonWithType:UIButtonTypeCustom];
    
    [stopButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [stopButton setBackgroundImage:[UIImage imageNamed:@"RedSettingsButton"] forState:UIControlStateNormal];
    [stopButton setBackgroundImage:[UIImage imageNamed:@"RedSettingsButtonSelect"] forState:UIControlStateHighlighted];
    [stopButton setFrame: shutdownButton.frame];
    stopButton.autoresizingMask = shutdownButton.autoresizingMask;
    [stopButton setTitle:@"Stop" forState:UIControlStateNormal];
    [stopButton addTarget:self action:@selector(stopEnc:) forControlEvents:UIControlEventTouchUpInside];
    [secondEncButton addSubview:stopButton];
    
    //    BorderlessButton *viewLicenseButton = [BorderlessButton buttonWithType:UIButtonTypeSystem];
    //    [viewLicenseButton setFrame:CGRectMake(0.0f, 5.0f, 140, 45)];
    //    [viewLicenseButton setTitle:@"View EULA" forState:UIControlStateNormal];
    //    [viewLicenseButton addTarget:self action:@selector(viewLicense:) forControlEvents:UIControlEventTouchUpInside];
    //    [viewEulaContainer addSubview:viewLicenseButton];
    //
    //    BorderlessButton *accountsButton = [BorderlessButton buttonWithType:UIButtonTypeSystem];
    //    [accountsButton setFrame:CGRectMake(-5.0f, 35.0f, 140, 45)];
    //    [accountsButton setTitle:@"Accounts" forState:UIControlStateNormal];
    //    [accountsButton addTarget:self action:@selector(showAccountView:) forControlEvents:UIControlEventTouchUpInside];
    //    [viewEulaContainer addSubview:accountsButton];
    
    encHomeButton = [BorderlessButton buttonWithType:UIButtonTypeSystem];
    [encHomeButton setFrame:CGRectMake(0.0f, 5.0f, 140, 45)];
    [encHomeButton setTitle:@"Encoder Home" forState:UIControlStateNormal];
    [encHomeButton setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
    [encHomeButton addTarget:self action:@selector(openEncoderHomeInSafari:) forControlEvents:UIControlEventTouchUpInside];
    [encHomeButton setUserInteractionEnabled:YES];
    
    //encoder state label
    _encStateLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(encHomeButton.frame), 10, encoderHomeLabel.frame.size.width - encHomeButton.frame.size.width , encoderHomeLabel.frame.size.height)];
    [encoderHomeLabel addSubview:_encStateLabel];
    
    [doNotShowContainer setHidden:TRUE];
    [self updateForStatus];
    
    if (masterEncoder){
        [self masterEncoderStatusObserver:masterEncoder];
    } else {
        [self eventControlsState:EventButtonControlStatesDisabled];
    }
}

- (void)updateForStatus
{
    [self setButtonImagesAndLabels];
}


//show the accounts view
-(void)showAccountView:(id)sender
{
    //    if(scrollView.contentSize.width <= self.view.frame.size.width)
    //    {
    //        [scrollView setContentSize:CGSizeMake(scrollView.bounds.size.width*2, scrollView.bounds.size.height)];
    //    }
    //    [scrollView setScrollEnabled:TRUE];
    //    if(!dropBoxLabel)
    //    {
    //        backToGeneral = [UIButton buttonWithType:UIButtonTypeCustom];
    //        [backToGeneral setFrame:CGRectMake(scrollView.bounds.size.width, 15,150 ,30  )];
    //        [backToGeneral setImage:[UIImage imageNamed:@"dropdownleft"] forState:UIControlStateNormal];
    //        [backToGeneral setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
    //        [backToGeneral addTarget:self action:@selector(backToGeneralView:) forControlEvents:UIControlEventTouchUpInside];
    //        [backToGeneral setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 20.0, 0.0, 0.0)];
    //        [backToGeneral setTitle:@"Accounts" forState:UIControlStateNormal];
    //        backToGeneral.titleLabel.font=[UIFont systemFontOfSize:18.0];
    //        [scrollView addSubview:backToGeneral];
    //
    //        dropboxContainer = [[UIView alloc] initWithFrame:CGRectMake(scrollView.bounds.size.width, backToGeneral.frame.origin.y+40, scrollView.bounds.size.width, 40)];
    //        [dropboxContainer.layer setBorderColor:[[Utility colorWithHexString:@"#575757"] CGColor]];
    //        [dropboxContainer.layer setBorderWidth:1.2f];
    //
    //        dropBoxLabel = [BorderlessButton buttonWithType:UIButtonTypeCustom];
    //        [dropBoxLabel setFrame:CGRectMake(10, 5, 300, 40)];
    //
    //        if([[DBSession sharedSession] isLinked])
    //        {
    //            [restClient loadAccountInfo];
    //        }
    //        dropBoxLabel.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    //        dropBoxLabel.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    //        [dropBoxLabel setTitle:@"DropBox" forState:UIControlStateNormal];
    //        [dropboxContainer addSubview:dropBoxLabel];
    //
    //
    //        dropboxLogout = [BorderlessButton buttonWithType:UIButtonTypeCustom];
    //        [dropboxLogout setFrame:CGRectMake(self.view.frame.size.width-80, 0, 70, dropBoxLabel.frame.size.height)];
    //        NSString *logoutTitle = [[DBSession sharedSession] isLinked] ? @"Unlink":@"Link";
    //        [dropboxLogout setTitle:logoutTitle forState:UIControlStateNormal];
    //        [dropboxLogout addTarget:self action:@selector(logoutDropbox:) forControlEvents:UIControlEventTouchUpInside];
    //        [dropboxLogout setTitleColor:[Utility colorWithHexString:@"#575757"] forState:UIControlStateNormal];
    //
    //        [dropboxContainer addSubview:dropboxLogout];
    //        fbAndEmailNote =[[UILabel alloc] initWithFrame:CGRectMake(dropboxContainer.frame.origin.x+5, dropboxContainer.frame.origin.y+40, dropboxContainer.frame.size.width, 80)];
    //        [fbAndEmailNote setBackgroundColor:[UIColor clearColor]];
    //        [fbAndEmailNote setNumberOfLines:2];
    //        [fbAndEmailNote setLineBreakMode:NSLineBreakByWordWrapping];
    //        [fbAndEmailNote setTextColor:[Utility colorWithHexString:@"#575757"]];
    //        [fbAndEmailNote setText:@"Note: Login settings for Facebook and Email are available in your iPad's settings app."];
    //
    //        [scrollView addSubview:fbAndEmailNote];
    //        [scrollView addSubview:dropboxContainer];
    //    }
    //    [scrollView scrollRectToVisible:dropboxContainer.frame animated:TRUE];
    //    [scrollView setScrollEnabled:FALSE];
    
}

-(UIModalPresentationStyle)modalPresentationStyle{
    return UIModalPresentationFormSheet;
}

//scroll back to the general settings view
- (void)backToGeneralView:(id)sender
{
    [scrollView setScrollEnabled:TRUE];
    
    [scrollView scrollRectToVisible:encHomeButton.frame animated:TRUE];
    [scrollView setScrollEnabled:FALSE];
    
    [dropBoxLabel removeFromSuperview];
    dropBoxLabel=nil;
    
    [dropboxContainer removeFromSuperview];
    dropboxContainer =nil;
    
    [accountTitle removeFromSuperview];
    accountTitle=nil;
    [backToGeneral removeFromSuperview];
    backToGeneral=nil;
    
    
    
}

- (void)switchSelected:(id)sender{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSString* handleLogoPagePath = [documentsDirectory stringByAppendingPathComponent:@"handleLogoPage.plist"];
    UISwitch *notShowAgainSwitch = (UISwitch *)sender;
    if (![fileManager fileExistsAtPath: handleLogoPagePath])
    {
        handleLogoPagePath = [documentsDirectory stringByAppendingPathComponent: [NSString stringWithFormat: @"handleLogoPage.plist"] ];
    }
    NSMutableDictionary *data = [[NSMutableDictionary alloc]init];
    if([fileManager fileExistsAtPath:handleLogoPagePath]){
        [fileManager removeItemAtPath:handleLogoPagePath error:NULL];
    }
    if(notShowAgainSwitch.isOn){
        [data setObject:@"on" forKey:@"notShowLogoPage"];
        //notShowLogoPage = @"on";
        
    }else{
        [data setObject:@"off" forKey:@"notShowLogoPage"];
        
    }
    [data writeToFile:handleLogoPagePath atomically:YES];
    
}


//-(void)viewLicense:(id)sender{
//    EulaModalViewController *eulaViewController=[[EulaModalViewController   alloc]init];
//    [self presentViewController:eulaViewController animated:YES completion:nil];
//
//}

-(void)setButtonImagesAndLabels
{
    
    
    [userName setText:userCenter.customerEmail];
    
    
    if (![Utility hasWiFi]) {
        encoderHomeText.text = @"Encoder is not available.";
        [encHomeButton setTitle:@"Encoder is not available" forState:UIControlStateSelected];
        [_encStateLabel setText:@""];
        [encHomeButton removeFromSuperview];
        [encHomeButton setUserInteractionEnabled:NO];
        [encoderHomeLabel addSubview:encoderHomeText];
        
        //        encHomeButton.alpha = 0;
    }else{
        
        [encoderHomeText removeFromSuperview];
        [encoderHomeLabel addSubview:encHomeButton];
        [encHomeButton setUserInteractionEnabled:YES];
        
        //        encHomeButton.alpha = 1;
    }
}

-(void)openEncoderHomeInSafari:(id)sender
{
    if (encoderManager.masterEncoder.ipAddress){
        NSString * urlPath = [NSString stringWithFormat:@"http://%@/min",encoderManager.masterEncoder.ipAddress];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: urlPath]];
    }
}

-(void)alertView:(CustomAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [alertView viewFinished];
    if (buttonIndex == 0) {
        if (alertView == self.pauseAlertView) {
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MASTER_COMMAND object:self userInfo:@{@"pause"  : [NSNumber numberWithBool:YES]}];
            //[self.pauseAlertView viewFinished];
        } else if (alertView == self.stopAlertView) {
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MASTER_COMMAND object:self userInfo:@{@"stop"  : [NSNumber numberWithBool:YES]}];
            //[self.stopAlertView viewFinished];
        } else if (alertView == self.shutdownAlertView) {
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MASTER_COMMAND object:self userInfo:@{@"shutdown"  : [NSNumber numberWithBool:YES]}];
            //[self.shutdownAlertView viewFinished];
        } else if (alertView == self.startAlertView){
            //[self.startAlertView viewFinished];
        }
    }
}


-(void) showInformation
{
    if (encoderManager.currentEventData) {
        [selectHomeTeam setTitle:encoderManager.currentEventData[@"homeTeam"] forState:UIControlStateNormal];
        [selectAwayTeam setTitle:encoderManager.currentEventData[@"visitTeam"] forState:UIControlStateNormal];
        [selectLeague setTitle:encoderManager.currentEventData[@"league"] forState:UIControlStateNormal];
    }
}



-(void)eventControlsState:(EventButtonControlStates)state
{
    
    [startButton setHidden:      (state & START_HIDDEN)!=0];
    [startButton setEnabled:     (state & START_ENABLE)!=0];
    [startButton setAlpha:       ( state & START_ENABLE )?1.0f:0.6f];
    
    [stopButton setHidden:       (state & STOP_HIDDEN)!=0];
    [stopButton setEnabled:      (state & STOP_ENABLE)!=0];
    [stopButton setAlpha:        (state & STOP_ENABLE)?1.0f:0.6f];
    
    [pauseButton setHidden:      (state & PAUSE_HIDDEN)!=0];
    [pauseButton setEnabled:     (state & PAUSE_ENABLE)!=0];
    [pauseButton setAlpha:       (state & PAUSE_ENABLE)?1.0f:0.6f];
    
    [resumeButton setHidden:     (state & RESUME_HIDDEN)!=0];
    [resumeButton setEnabled:    (state & RESUME_ENABLE)!=0];
    [resumeButton setAlpha:      (state & RESUME_ENABLE)?1.0f:0.6f];
    
    [shutdownButton setHidden:   (state & SHUTDOWN_HIDDEN)!=0];
    [shutdownButton setEnabled:  (state & SHUTDOWN_ENABLE)!=0];
    [shutdownButton setAlpha:    (state & SHUTDOWN_ENABLE)?1.0f:0.6f];
    
    [selectHomeTeam setAlpha:   (state & HOME_ENABLE)?1.0f:0.6f];
    [selectHomeTeam setUserInteractionEnabled:(state & HOME_ENABLE)!=0];//
    
    [selectAwayTeam setAlpha:   (state & AWAY_ENABLE)?1.0f:0.6f];
    [selectAwayTeam setUserInteractionEnabled:(state & AWAY_ENABLE)!=0];//
    
    [selectLeague setAlpha:     (state & LEAGUE_ENABLE)?1.0f:0.6f];;
    [selectLeague setUserInteractionEnabled:(state & LEAGUE_ENABLE)!=0];//
    

    /*if (encoderManager.currentEventData && state == EventButtonControlStatesLive) {
        [selectHomeTeam setTitle:encoderManager.currentEventData[@"homeTeam"] forState:UIControlStateNormal];
        [selectAwayTeam setTitle:encoderManager.currentEventData[@"visitTeam"] forState:UIControlStateNormal];
        [selectLeague setTitle:encoderManager.currentEventData[@"league"] forState:UIControlStateNormal];
    }*/
    
    if (state == EventButtonControlStatesReady) {
        [selectHomeTeam setTitle:DEFAULT_HOME_TEAM forState:UIControlStateNormal];
        [selectAwayTeam setTitle:DEFAULT_AWAY_TEAM forState:UIControlStateNormal];
        [selectLeague setTitle:DEFAULT_LEAGUE forState:UIControlStateNormal];
    }

}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer
{
    return YES;
}



@end