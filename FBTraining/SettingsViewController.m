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



@end

@implementation SettingsViewController{

    UILabel                 * encStateLabel;
    int                     encStateCounter;
    BOOL                    encoderAvailable;
    BOOL                    dismissEnabled;
    
    //Richard
    AppDelegate            * _appDel;
    EncoderManager         * encoderManager;
    Encoder                * masterEncoder;
    UserCenter             * userCenter;
    TablePopoverController * homeTeamPick;
    TablePopoverController * visitTeamPick;
    TablePopoverController * LeaguePick;
    NSArray                * teamNames;
    NSArray                * leagueNames;
//    id                     observerForFoundMaster;
    id                     observerForLostMaster;
    UITapGestureRecognizer *tapBehindGesture;
    
    NSString                * homeTeam;
    NSString                * awayTeam;
    NSString                * league;
    
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
        LeaguePick              = [[TablePopoverController alloc]init];

        encoderHomeText         = [CustomLabel labelWithStyle:CLStyleOrange];
        encoderHomeText.text    = @"Encoder is not available.";
        
        __block SettingsViewController * weakSelf = self;
        __block UILabel * weakStateLable    =  encStateLabel;
        __block UILabel * weakHomeLable     =  encoderHomeText;
        __block Encoder * weakMasterEncoder =  masterEncoder;
        
        [encStateLabel setHidden:YES];
        // observers
//        observerForFoundMaster = [[NSNotificationCenter defaultCenter]addObserverForName:NOTIF_ENCODER_MASTER_FOUND object:nil queue:nil usingBlock:^(NSNotification *note) {
//            masterEncoder = encoderManager.masterEncoder;
//            encoderHomeText.text = @"Encoder Home";
//            [encStateLabel setHidden:NO];
//            [masterEncoder addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:&masterContext];
//        }];
        
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onMasterFound:) name:NOTIF_ENCODER_MASTER_FOUND object:nil];
        
        
        
        
        observerForLostMaster = [[NSNotificationCenter defaultCenter]addObserverForName:NOTIF_ENCODER_MASTER_HAS_FALLEN object:nil queue:nil usingBlock:^(NSNotification *note) {
            if (weakMasterEncoder != nil){
                weakHomeLable.text = @"Encoder is not available.";
                [weakStateLable setHidden:YES];
                
                
                [weakMasterEncoder removeObserver:self forKeyPath:@"status" context:&masterContext];
            }
        }];

        
        homeTeam            = @"Home Team";
        awayTeam            = @"Away Team";
        league              = @"League";
        
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
    
    CustomLabel *encoderControlsLabel = [CustomLabel labelWithStyle:CLStyleBlackHeader];
    encoderControlsLabel.frame = CGRectMake(20.0f, 20.0f, 200.0f, 23.0f);
    encoderControlsLabel.text = @"Encoder Controls";
    [scrollView addSubview:encoderControlsLabel];
    
    CustomLabel *versionLabel = [CustomLabel labelWithStyle:CLStyleBlack];
    versionLabel.frame = CGRectMake(self.view.bounds.size.width - 125.0f, encoderControlsLabel.frame.origin.y + 6.0f, 63.0f, 17.0f);
    versionLabel.text = @"Version:";
    versionLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    [scrollView addSubview:versionLabel];
    
    appVersionLabel = [CustomLabel labelWithStyle:CLStyleGrey];
    appVersionLabel.frame = CGRectMake(CGRectGetMaxX(versionLabel.frame), versionLabel.frame.origin.y, 55.0f, versionLabel.frame.size.height);
    appVersionLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    [scrollView addSubview:appVersionLabel];
    
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(15.0f, CGRectGetMaxY(encoderControlsLabel.frame) + 5.0f, self.view.bounds.size.width - 30.0f, 1.0f)];
    line1.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    line1.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f];
    [scrollView addSubview:line1];
    
    selectHomeContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(line1.frame) + 70.0f, self.view.bounds.size.width, 55.0f)];
    selectHomeContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [scrollView addSubview:selectHomeContainer];
    
    selectAwayContainer = [[UIView alloc] initWithFrame:CGRectMake(selectHomeContainer.frame.origin.x, CGRectGetMaxY(selectHomeContainer.frame), selectHomeContainer.bounds.size.width, selectHomeContainer.bounds.size.height)];
    selectAwayContainer.autoresizingMask = selectHomeContainer.autoresizingMask;
    [scrollView addSubview:selectAwayContainer];
    
    selectLeagueContainer = [[UIView alloc] initWithFrame:CGRectMake(selectHomeContainer.frame.origin.x, CGRectGetMaxY(selectAwayContainer.frame), selectHomeContainer.bounds.size.width, selectHomeContainer.bounds.size.height)];
    selectLeagueContainer.autoresizingMask = selectHomeContainer.autoresizingMask;
    [scrollView addSubview:selectLeagueContainer];
    
    firstEncButton = [[UIView alloc] initWithFrame:CGRectMake(80.0f, CGRectGetMaxY(selectLeagueContainer.frame) + 15.0f, 150.0f, 150.0f)];
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
    signalStrengthView.backgroundColor = [UIColor orangeColor];
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
    
    CustomLabel *generalLabel = [CustomLabel labelWithStyle:CLStyleBlackHeader];
    generalLabel.frame = CGRectMake(20.0f, self.view.frame.size.height - 150.0f, 100.0f, 23.0f);
    generalLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
    generalLabel.text = @"General";
    [scrollView addSubview:generalLabel];
    
    viewEulaContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(generalLabel.frame), self.view.bounds.size.width, 85.0f)];
    viewEulaContainer.backgroundColor = [UIColor clearColor];
    viewEulaContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(15.0f, 5.0f, viewEulaContainer.bounds.size.width - 30.0f, 1.0f)];
    line2.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    line2.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f];
    [viewEulaContainer addSubview:line2];
    [scrollView addSubview: viewEulaContainer];
    
    doNotShowContainer = [[UIView alloc] initWithFrame:CGRectMake(generalLabel.frame.origin.x, CGRectGetMaxY(viewEulaContainer.frame) + 14.0f, self.view.bounds.size.width - 2*generalLabel.frame.origin.x, 59.0f)];
    doNotShowContainer.backgroundColor = [UIColor clearColor];
    doNotShowContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [scrollView addSubview:doNotShowContainer];
    
    CustomLabel *userLabel = [CustomLabel labelWithStyle:CLStyleBlack];
    userLabel.text = @"User:";
    userLabel.frame = CGRectMake(15.0f, CGRectGetMaxY(self.view.frame) - 45.0f, 45.0f, 30.0f);
    userLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:userLabel];
    
    userName = [CustomLabel labelWithStyle:CLStyleGrey];
    userName.frame = CGRectMake(CGRectGetMaxX(userLabel.frame), userLabel.frame.origin.y, 207.0f, 30.0f);
    userName.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:userName];
    
    logoutButton = [BorderlessButton buttonWithType:UIButtonTypeSystem];
    [logoutButton setTitle:@"Logout" forState:UIControlStateNormal];
    logoutButton.frame = CGRectMake(self.view.frame.size.width - 90.0f, userLabel.frame.origin.y, 75.0f, 30.0f);
    logoutButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [logoutButton addTarget:self action:@selector(appLogOut:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:logoutButton];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //init subviews
    [self setupView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeSpinnerView) name:@"EventInformationUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateForStatus) name:@"updatedEncoderStatus" object:nil];
   

    
    if (!restClient) {
        restClient =
        [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }


    if(!uController)
    {
        uController=[[UtilitiesController alloc] init];
    }
    //get version information
    [appVersionLabel setText:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    
    //[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(selectTeamCallback) userInfo:nil repeats:YES];
    [self initialiseLayout];
    
    // Do any additional setup after loading the view from its nib.

//    encoderHomeText.frame = encoderHomeLabel.bounds;


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
    
    [super viewWillAppear:animated];
    
    [self setButtonImagesAndLabels];
    
    signalTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateSignalStrength) userInfo:nil repeats:YES];
    [signalTimer fire];
    
    // block
    NSArray * (^grabNames)(NSDictionary * input) = ^NSArray * (NSDictionary * input) {
        NSMutableArray  * collection    = [[NSMutableArray alloc]init];
        NSArray         * keys          = [input allKeys];
        for (NSString * item in keys) {
            NSString    * nam  = [[input objectForKey:item] objectForKey:@"name"];
            [collection addObject:nam];
        }
        return [collection copy];
    };
    // block end
    
    teamNames   = grabNames(encoderManager.masterEncoder.teams);
    leagueNames = grabNames(encoderManager.masterEncoder.league);
    
}


/*
 Deselects all buttons and stops timer
 
 */
-(void)viewWillDisappear:(BOOL)animated
{
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

}

-(void)masterEncoderStatusObserver:(Encoder*)master
{
    EncoderStatus status    = master.status;
    NSString * stringStatus = master.statusAsString;
    switch (status) {
            
        case ENCODER_STATUS_INIT :
            NSLog(@"ENCODER_STATUS_INIT");
        case ENCODER_STATUS_UNKNOWN :
            NSLog(@"ENCODER_STATUS_UNKNOWN");
            [self eventControlsState:EventButtonControlStatesDisabled];
        case ENCODER_STATUS_CAM_LOADING :
            NSLog(@"ENCODER_STATUS_CAM_LOADING");
            [self eventControlsState:EventButtonControlStatesDisabled];
            break;
        case ENCODER_STATUS_READY :
            NSLog(@"ENCODER_STATUS_READY");
            [self eventControlsState:EventButtonControlStatesReady];
            break;
        case ENCODER_STATUS_LIVE :
            NSLog(@"ENCODER_STATUS_LIVE");
            [self eventControlsState:EventButtonControlStatesLive];
            break;
        case ENCODER_STATUS_SHUTDOWN :
            NSLog(@"ENCODER_STATUS_SHUTDOWN");
            [self eventControlsState:EventButtonControlStatesDisabled];
            break;
        case ENCODER_STATUS_PAUSED :
            NSLog(@"ENCODER_STATUS_PAUSED");
            [self eventControlsState:EventButtonControlStatesPause];
            break;
        case ENCODER_STATUS_STOP :
            NSLog(@"ENCODER_STATUS_STOPPING");
            [self eventControlsState:EventButtonControlStatesStopping];
            break;
        case ENCODER_STATUS_START :
            NSLog(@"ENCODER_STATUS_START");
            [self eventControlsState:EventButtonControlStatesStart];
            break;
        case ENCODER_STATUS_NOCAM :
            NSLog(@"ENCODER_STATUS_NOCAM");
            [self eventControlsState:EventButtonControlStatesShutdown];
            break;
        case ENCODER_STATUS_LOCAL :
            NSLog(@"ENCODER_STATUS_LOCAL");
            [self eventControlsState:EventButtonControlStatesDisabled];
            break;
            
        default:
            break;
    }
    
//    NSInteger cc = encoderManager.totalCameraCount;
//    NSString * scourceCount = (cc)?[NSString stringWithFormat:@" (s%i)",cc]:@"";
    [encStateLabel setText:[NSString stringWithFormat:@"( %@ )",stringStatus]];
}


-(void)onMasterFound:(NSNotification*)note
{
    masterEncoder = encoderManager.masterEncoder;
    encoderHomeText.text = @"Encoder Home";
    [encStateLabel setHidden:NO];
    [encoderHomeText setAlpha:1];
    [masterEncoder addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:&masterContext];

    // block
    NSArray * (^grabNames)(NSDictionary * input) = ^NSArray * (NSDictionary * input) {
        NSMutableArray  * collection    = [[NSMutableArray alloc]init];
        NSArray         * keys          = [input allKeys];
        for (NSString * item in keys) {
            NSString    * nam  = [[input objectForKey:item] objectForKey:@"name"];
            [collection addObject:nam];
        }
        return [collection copy];
    };
    // block end
    
    teamNames   = grabNames(encoderManager.masterEncoder.teams);
    leagueNames = grabNames(encoderManager.masterEncoder.league);
}



#pragma mark -
#pragma mark Encoder Controls


- (void)startEnc:(id)sender
{
    
    NSString * buttonTitle = ((UIButton*)sender).titleLabel.text;
    
    NSString *homeTeam=[selectHomeTeam.titleLabel.text isEqualToString:@"Home Team"] ? nil : selectHomeTeam.titleLabel.text;
    NSString *awayTeam=[selectAwayTeam.titleLabel.text isEqualToString:@"Away Team"] ? nil : selectAwayTeam.titleLabel.text;
    NSString *league=[selectLeague.titleLabel.text isEqualToString:@"League"] ? nil : selectLeague.titleLabel.text;
    
    if(!(homeTeam && awayTeam && league))//only allow user to start enc if they have selected all three, home team, away team, league
    {
        if (masterEncoder.status == ENCODER_STATUS_READY || masterEncoder.status == ENCODER_STATUS_STOP)
            //        if([globals.CURRENT_ENC_STATUS isEqualToString:encStateReady] || [globals.CURRENT_ENC_STATUS isEqualToString:encStateStopped])
        {
            CustomAlertView *alert = [[CustomAlertView alloc]
                                      initWithTitle: @"myplayXplay"
                                      message: @"Please select Home team, Away team and League to start the encoder"
                                      delegate: nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
            [alert show];
            //            [globals.ARRAY_OF_POPUP_ALERT_VIEWS addObject:alert];
            return;
        }
    }
    
    if ([buttonTitle isEqualToString:@"Start"]) {
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MASTER_COMMAND object:self userInfo:@{@"start"  : [NSNumber numberWithBool:YES],
                                                                                                              @"homeTeam"   : homeTeam,
                                                                                                              @"awayTeam"   : awayTeam,
                                                                                                              @"league" : league
                                                                                                              }];
        [self eventControlsState:EventButtonControlStatesStart];
    } else { // resume video
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MASTER_COMMAND object:self userInfo:@{@"resume"  : [NSNumber numberWithBool:YES]}];
    }
    
}


- (void)shutdownEnc:(id)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MASTER_COMMAND object:self userInfo:@{@"shutdown"  : [NSNumber numberWithBool:YES]}];
}

- (void)pauseEnc:(id)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MASTER_COMMAND object:self userInfo:@{@"pause"  : [NSNumber numberWithBool:YES]}];
}

- (void)stopEnc:(id)sender {
    // Richard
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MASTER_COMMAND object:self userInfo:@{@"stop":[NSNumber numberWithBool:YES] }];
    
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
//        signalStrengthView.backgroundColor = [UIColor orangeColor];
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
    UIButton *popButton = (UIButton*)sender;
    popButton.selected  = YES;

    [homeTeamPick populateWith:teamNames];
    [homeTeamPick addOnCompletionBlock:^(NSString *pick) {
        [popButton setTitle:pick forState:UIControlStateNormal];
        popButton.selected = NO;
    }];

    [homeTeamPick presentPopoverFromRect:popButton.frame inView:selectHomeContainer permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

-(void)pickAway:(id)sender
{
    UIButton *popButton = (UIButton*)sender;
    popButton.selected = YES;
    [visitTeamPick populateWith:teamNames];
    [visitTeamPick addOnCompletionBlock:^(NSString *pick) {
        [popButton setTitle:pick forState:UIControlStateNormal];
        popButton.selected = NO;
    }];
    
    [visitTeamPick presentPopoverFromRect:popButton.frame inView:selectAwayContainer permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
}

-(void)pickLeague:(id)sender
{
    UIButton *popButton = (UIButton*)sender;
    popButton.selected = YES;
    
    [LeaguePick populateWith:leagueNames];
    [LeaguePick addOnCompletionBlock:^(NSString *pick) {
        [popButton setTitle:pick forState:UIControlStateNormal];
        popButton.selected = NO;
    }];
    
    [LeaguePick presentPopoverFromRect:popButton.frame inView:selectLeagueContainer permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
    
}



-(void)initialiseLayout
{
    selectHomeTeam = [DropdownButton buttonWithType:UIButtonTypeCustom];
    
    [selectHomeTeam setFrame:CGRectMake(0.0f, 0.0f, selectHomeContainer.bounds.size.width, selectHomeContainer.bounds.size.height)];
    selectHomeTeam.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [selectHomeTeam setTitle:homeTeam forState:UIControlStateNormal];
    [selectHomeTeam setTag:0];
    [selectHomeTeam addTarget:self action:@selector(pickHome:) forControlEvents:UIControlEventTouchUpInside];
    [selectHomeContainer addSubview:selectHomeTeam];
    
    selectAwayTeam = [DropdownButton buttonWithType:UIButtonTypeCustom];
    
    [selectAwayTeam setFrame:CGRectMake(0.0f, 0.0f, selectAwayContainer.bounds.size.width, selectAwayContainer.bounds.size.height)];
    selectAwayTeam.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [selectAwayTeam setTitle:awayTeam forState:UIControlStateNormal];
    [selectAwayTeam setTag:1];
    [selectAwayTeam addTarget:self action:@selector(pickAway:) forControlEvents:UIControlEventTouchUpInside];
    [selectAwayContainer addSubview:selectAwayTeam];
    
    selectLeague = [DropdownButton buttonWithType:UIButtonTypeCustom];
    
    [selectLeague setFrame:CGRectMake(0.0f, 0.0f, selectLeagueContainer.bounds.size.width, selectLeagueContainer.bounds.size.height)];
    selectLeague.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [selectLeague setTitle:league forState:UIControlStateNormal];
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
    
    BorderlessButton *viewLicenseButton = [BorderlessButton buttonWithType:UIButtonTypeSystem];
    [viewLicenseButton setFrame:CGRectMake(0.0f, 5.0f, 140, 45)];
    [viewLicenseButton setTitle:@"View EULA" forState:UIControlStateNormal];
    [viewLicenseButton addTarget:self action:@selector(viewLicense:) forControlEvents:UIControlEventTouchUpInside];
    [viewEulaContainer addSubview:viewLicenseButton];
    
    BorderlessButton *accountsButton = [BorderlessButton buttonWithType:UIButtonTypeSystem];
    [accountsButton setFrame:CGRectMake(-5.0f, 35.0f, 140, 45)];
    [accountsButton setTitle:@"Accounts" forState:UIControlStateNormal];
    [accountsButton addTarget:self action:@selector(showAccountView:) forControlEvents:UIControlEventTouchUpInside];
    [viewEulaContainer addSubview:accountsButton];
    
    encHomeButton = [BorderlessButton buttonWithType:UIButtonTypeSystem];
    [encHomeButton setFrame:CGRectMake(0.0f, 5.0f, 140, 45)];
    [encHomeButton setTitle:@"Encoder Home" forState:UIControlStateNormal];
    [encHomeButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [encHomeButton addTarget:self action:@selector(openEncoderHomeInSafari:) forControlEvents:UIControlEventTouchUpInside];
    [encHomeButton setUserInteractionEnabled:YES];
    
    //encoder state label
    encStateLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(encHomeButton.frame), 10, encoderHomeLabel.frame.size.width - encHomeButton.frame.size.width , encoderHomeLabel.frame.size.height)];
    [encoderHomeLabel addSubview:encStateLabel];

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
    if(scrollView.contentSize.width <= self.view.frame.size.width)
    {
        [scrollView setContentSize:CGSizeMake(scrollView.bounds.size.width*2, scrollView.bounds.size.height)];
    }
    [scrollView setScrollEnabled:TRUE];
    if(!dropBoxLabel)
    {
        backToGeneral = [UIButton buttonWithType:UIButtonTypeCustom];
        [backToGeneral setFrame:CGRectMake(scrollView.bounds.size.width, 15,150 ,30  )];
        [backToGeneral setImage:[UIImage imageNamed:@"dropdownleft"] forState:UIControlStateNormal];
        [backToGeneral setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [backToGeneral addTarget:self action:@selector(backToGeneralView:) forControlEvents:UIControlEventTouchUpInside];
        [backToGeneral setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 20.0, 0.0, 0.0)];
        [backToGeneral setTitle:@"Accounts" forState:UIControlStateNormal];
        backToGeneral.titleLabel.font=[UIFont systemFontOfSize:18.0];
        [scrollView addSubview:backToGeneral];
        
        dropboxContainer = [[UIView alloc] initWithFrame:CGRectMake(scrollView.bounds.size.width, backToGeneral.frame.origin.y+40, scrollView.bounds.size.width, 40)];
        [dropboxContainer.layer setBorderColor:[[Utility colorWithHexString:@"#575757"] CGColor]];
        [dropboxContainer.layer setBorderWidth:1.2f];
        
        dropBoxLabel = [BorderlessButton buttonWithType:UIButtonTypeCustom];
        [dropBoxLabel setFrame:CGRectMake(10, 5, 300, 40)];
        
        if([[DBSession sharedSession] isLinked])
        {
            [restClient loadAccountInfo];
        }
        dropBoxLabel.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        dropBoxLabel.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [dropBoxLabel setTitle:@"DropBox" forState:UIControlStateNormal];
        [dropboxContainer addSubview:dropBoxLabel];
        
        
        dropboxLogout = [BorderlessButton buttonWithType:UIButtonTypeCustom];
        [dropboxLogout setFrame:CGRectMake(self.view.frame.size.width-80, 0, 70, dropBoxLabel.frame.size.height)];
        NSString *logoutTitle = [[DBSession sharedSession] isLinked] ? @"Unlink":@"Link";
        [dropboxLogout setTitle:logoutTitle forState:UIControlStateNormal];
        [dropboxLogout addTarget:self action:@selector(logoutDropbox:) forControlEvents:UIControlEventTouchUpInside];
        [dropboxLogout setTitleColor:[Utility colorWithHexString:@"#575757"] forState:UIControlStateNormal];
        
        [dropboxContainer addSubview:dropboxLogout];
        fbAndEmailNote =[[UILabel alloc] initWithFrame:CGRectMake(dropboxContainer.frame.origin.x+5, dropboxContainer.frame.origin.y+40, dropboxContainer.frame.size.width, 80)];
        [fbAndEmailNote setBackgroundColor:[UIColor clearColor]];
        [fbAndEmailNote setNumberOfLines:2];
        [fbAndEmailNote setLineBreakMode:NSLineBreakByWordWrapping];
        [fbAndEmailNote setTextColor:[Utility colorWithHexString:@"#575757"]];
        [fbAndEmailNote setText:@"Note: Login settings for Facebook and Email are available in your iPad's settings app."];
        
        [scrollView addSubview:fbAndEmailNote];
        [scrollView addSubview:dropboxContainer];
    }
    [scrollView scrollRectToVisible:dropboxContainer.frame animated:TRUE];
    [scrollView setScrollEnabled:FALSE];
    
}

-(UIModalPresentationStyle)modalPresentationStyle{
    return UIModalPresentationFormSheet;
}

- (DBRestClient *)restClient {
    if (!restClient) {
        restClient=
        [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}


- (void)restClient:(DBRestClient*)client loadedAccountInfo:(DBAccountInfo*)info
{
    [dropBoxLabel setTitle:[NSString stringWithFormat:@"DropBox: %@",[info displayName]] forState:UIControlStateNormal];
}


-(void)updateDBLabelTimer
{
    if ([[DBSession sharedSession] isLinked]) {
        restClient=nil;
        [self restClient];
        [updateDBLabelTimer invalidate];
        updateDBLabelTimer =nil;
        [dropboxLogout setTitle:@"Unlink" forState:UIControlStateNormal];
        
        [restClient loadAccountInfo];
    }
}



//logout of dropbox
- (void)logoutDropbox:(id)sender
{
    //call dbrestclient
    //unlink the current account.
    BorderlessButton *b = (BorderlessButton*)sender;
    if([b.titleLabel.text isEqualToString:@"Unlink"])
    {
        
        if ([[DBSession sharedSession] isLinked]) {
            [[DBSession sharedSession] unlinkAll];
        }
        [b setTitle:@"Link" forState:UIControlStateNormal];
        [dropBoxLabel setTitle:@"DropBox" forState:UIControlStateNormal];
        
    }else{
        if (![[DBSession sharedSession] isLinked]) {
            [[DBSession sharedSession] linkFromController:self];
        }
        updateDBLabelTimer=[NSTimer scheduledTimerWithTimeInterval:0.0f target:self selector:@selector(updateDBLabelTimer) userInfo:nil repeats:YES];
        
    }
    
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


-(void)viewLicense:(id)sender{
    EulaModalViewController *eulaViewController=[[EulaModalViewController   alloc]init];
    [self presentViewController:eulaViewController animated:YES completion:nil];
    
}

-(void)setButtonImagesAndLabels
{
    
    
   [userName setText:userCenter.customerEmail];

    
    if (!encoderManager.hasWiFi) {
        encoderHomeText.text = @"Encoder is not available.";
        [encHomeButton setTitle:@"Encoder is not available" forState:UIControlStateSelected];
        [encStateLabel setText:@""];
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

- (void)appLogOut:(id)sender {
    BOOL hasInternet = encoderManager.hasInternet;
    if (!hasInternet) {
        CustomAlertView *errorView;
        errorView = [[CustomAlertView alloc]
                     initWithTitle: @"myplayXplay"
                     message: @"Please connect to the internet to log out."
                     delegate: self
                     cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [errorView show];
//        [globals.ARRAY_OF_POPUP_ALERT_VIEWS addObject:errorView];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideSettings" object:self];
        CustomAlertView *alertView;
        alertView = [[CustomAlertView alloc]
                     initWithTitle: @"myplayXplay"
                     message: @"If you log out, you need internet to log in. Are you sure you want to log out?"
                     delegate: self
                     cancelButtonTitle:@"Yes" otherButtonTitles:@"Cancel", nil];
        alertView.accessibilityValue = @"appLogOut";
        [alertView show];
        alertView.delegate = self;
//        [globals.ARRAY_OF_POPUP_ALERT_VIEWS addObject:alertView];
    }
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self sendAppLogoutRequest];
            break;
            
        default:
            break;
    }
}


-(void)sendAppLogoutRequest{
    [encoderManager.logoutAction start];
    dismissEnabled = YES;
    [self dismiss];
}





/*
-(void)startEncCallback:(id)json
{
    
    if([[json objectForKey:@"success"]integerValue] != 0 && [[NSString stringWithFormat:@"%@",[json objectForKey:@"requrl"]] rangeOfString:@"encresume"].location == NSNotFound)
    {
        //reset waitEncoderResponseCounter
        waitEncoderResponseCounter = 0;
        globals.LIVE_TIMER_ON = TRUE;
        
        globals.DID_START_NEW_EVENT=TRUE;
        //reset all the line,period/zone,strength info for new event
        globals.CURRENT_F_LINE = -1;
        globals.CURRENT_D_LINE = -1;
        globals.CURRENT_PERIOD = -1;
        globals.CURRENT_STRENGTH = nil;
        globals.CURRENT_ZONE = nil;
        globals.CURRENT_O_PLAY_NUMBER_FB = -1;
        globals.CURRENT_D_PLAY_NUMBER_FB = -1;
        globals.CURRENT_QUARTER_FB = -1;
        [globals.DURATION_TAGS_TIME removeAllObjects];
        [globals.DURATION_TYPE_TIMES removeAllObjects];
        [globals.ARRAY_OF_COLOURS removeAllObjects];
        globals.SWITCH_TO_DIFFERENT_EVENT = TRUE;
        if ([globals.CURRENT_ENC_STATUS isEqualToString:encStateLive]) {
            //only when encoder status is live, reset global variables, video player and syncme timer
            
            
            [globals.CURRENT_EVENT_THUMBNAILS removeAllObjects];
            //[globals.TAG_MARKER_ITEMS removeAllObjects];
            [globals.TAGGED_ATTS_DICT removeAllObjects];
            [globals.TAGGED_ATTS_DICT_SHIFT removeAllObjects];
            [globals.ARRAY_OF_COLOURS removeAllObjects];
            [globals.ARRAY_OF_TAGSET removeAllObjects];
            [globals.TOAST_QUEUE removeAllObjects];
            [globals.THUMBS_WERE_SELECTED_CLIPVIEW removeAllObjects];
            [globals.THUMBS_WERE_SELECTED_LISTVIEW removeAllObjects];
            globals.THUMB_WAS_SELECTED_CLIPVIEW = nil;
            globals.THUMB_WAS_SELECTED_LISTVIEW = nil;
            NSMutableArray *tempArray = [[globals.TAG_MARKER_OBJ_DICT allKeys] mutableCopy];
            for(NSString *key in tempArray){
                [[[globals.TAG_MARKER_OBJ_DICT objectForKey:key] markerView] removeFromSuperview];
            }
            [globals.TAG_MARKER_OBJ_DICT removeAllObjects];
            globals.EVENT_NAME = @"live";
            globals.HUMAN_READABLE_EVENT_NAME = @"Live";
            [uController getAllGameTags];
            globals.CURRENT_PLAYBACK_EVENT = [NSString stringWithFormat:@"%@/events/live/video/list.m3u8",globals.URL];
            NSURL *videoURL = [NSURL URLWithString:globals.CURRENT_PLAYBACK_EVENT];
            AVPlayer *myPlayer = [AVPlayer playerWithURL:videoURL];
            
            [globals.VIDEO_PLAYER_LIST_VIEW setVideoURL:videoURL];
            [globals.VIDEO_PLAYER_LIST_VIEW setAvPlayer:myPlayer];
            [globals.VIDEO_PLAYER_LIST_VIEW pause];
            
            [globals.VIDEO_PLAYER_LIVE2BENCH setVideoURL:videoURL];
            [globals.VIDEO_PLAYER_LIVE2BENCH setAvPlayer:myPlayer];
            [globals.VIDEO_PLAYER_LIVE2BENCH pause];
            globals.VIDEO_PLAYBACK_FAILED = FALSE;
            globals.PLAYABLE_DURATION = -1;
            
            [uController restartSyncMeTimer];
            
        }
      
        
        
    }else if([[json objectForKey:@"success"]integerValue] != 0 && [[NSString stringWithFormat:@"%@",[json objectForKey:@"requrl"]] rangeOfString:@"encresume"].location != NSNotFound){
        [globals.VIDEO_PLAYER_LIVE2BENCH play];
        [self removeSpinnerView];
        
    }else{
        if ([json objectForKey:@"msg"]) {
            CustomAlertView *alert = [[CustomAlertView alloc]initWithTitle:@"myplayXplay" message:[NSString stringWithFormat:@"start/resume video error: %@",[json objectForKey:@"msg"]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
//            [globals.ARRAY_OF_POPUP_ALERT_VIEWS addObject:alert];
        }
        
    }
}
*/

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


//    globals.ENCODER_SELECTED_HOME_TEAM = @"Home Team";
//    globals.ENCODER_SELECTED_AWAY_TEAM = @"Away Team";
//    globals.ENCODER_SELECTED_LEAGUE = @"League";
    
    
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer
{
    return YES;
}



@end
