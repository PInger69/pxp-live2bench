//
//  SettingsViewController.m
//  Live2BenchNative
//
//  Created by DEV on 2013-03-08.
//  Copyright (c) 2013 DEV. All rights reserved.
//
#import <Crashlytics/Crashlytics.h>
#import <Photos/Photos.h>
#import "EncoderControlsViewController.h"
#import "EncoderManager.h"
#import "Encoder.h"
#import "EncoderOperation.h"
#import "TablePopoverController.h"
#import "LeagueTeam.h"
#import "League.h"
#import "DeviceEncoderSource.h"
#import "LocalMediaManager.h"
#import "MakeEventViewController.h"
#import "CopyDeviceVideoToOperation.h"
#import "DeviceVideoDataSource.h"
#import "ListPopoverController.h"

@interface EncoderControlsViewController ()

@property (nonatomic,strong) DeviceVideoDataSource * deviceVideoDataSource;

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

//@property (strong, nonatomic, nonnull) CustomAlertView *pauseAlertView;
//@property (strong, nonatomic, nonnull) CustomAlertView *stopAlertView;
//@property (strong, nonatomic, nonnull) CustomAlertView *shutdownAlertView;
//@property (strong, nonatomic, nonnull) CustomAlertView *startAlertView;
//@property (strong, nonatomic, nonnull) CustomAlertView *noTeamAlertView;

#define DEFAULT_LEAGUE @"Select a League"
#define DEFAULT_HOME_TEAM @"Select a Home Team"
#define DEFAULT_AWAY_TEAM @"Select a Away Team"

@end

@implementation EncoderControlsViewController{
    
    UILabel                     * _encStateLabel;

    AppDelegate                 * _appDel;
    EncoderManager              * encoderManager;
    NSObject <EncoderProtocol>  * masterEncoder;
    TablePopoverController      * homeTeamPick;
    TablePopoverController      * visitTeamPick;
    TablePopoverController      * _leaguePick;
    NSArray                     * teamNames;
    NSArray                     * leagueNames;
    id                          observerForLostMaster;
    
    NSString                    * _homeTeam;
    NSString                    * _awayTeam;
    NSString                    * _leagueName;
    
    NSArray * (^grabNames)(NSDictionary * input);
    ListPopoverController       *_teamPick;
}

static void *masterContext;



UIPopoverController *signalPop;
SVSignalStatus signalStatus;

-(id)initWithAppDelegate:(AppDelegate*)appDel
{
    self = [super init];
    if (self) {
        _appDel                 = appDel;
        encoderManager          = appDel.encoderManager;
        masterContext           = &masterContext;
        homeTeamPick            = [[TablePopoverController alloc]init];
        visitTeamPick           = [[TablePopoverController alloc]init];
        _leaguePick              = [[TablePopoverController alloc]init];
        
        encoderHomeText         = [CustomLabel labelWithStyle:CLStyleOrange];
        [encoderHomeText setFrame:CGRectMake(0.0f, 5.0f, 140, 45)];
        encoderHomeText.text    = @"Encoder is not available.";
        encoderHomeText.adjustsFontSizeToFitWidth = true;
        
        __block UILabel * weakStateLable    =  _encStateLabel;
        __block UILabel * weakHomeLable     =  encoderHomeText;
        __block NSObject <EncoderProtocol> * weakMasterEncoder =  masterEncoder;
        
        
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
        
        _leagueName          = DEFAULT_LEAGUE;
        _homeTeam            = DEFAULT_HOME_TEAM;
        _awayTeam            = DEFAULT_AWAY_TEAM;
        
//        self.pauseAlertView = [[CustomAlertView alloc] initWithTitle:NSLocalizedString(@"Pause Event", nil) message:NSLocalizedString(@"Are you sure you want to pause the event?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Yes", nil) otherButtonTitles:NSLocalizedString(@"Cancel", nil), nil];
//        self.pauseAlertView.type = AlertIndecisive;
        
//        self.stopAlertView = [[CustomAlertView alloc] initWithTitle:NSLocalizedString(@"Stop Event", nil) message:NSLocalizedString(@"Are you sure you want to stop the event?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Yes", nil) otherButtonTitles:NSLocalizedString(@"Cancel", nil), nil];
//        self.stopAlertView.type = AlertIndecisive;
//        
//        self.shutdownAlertView = [[CustomAlertView alloc] initWithTitle:NSLocalizedString(@"Shutdown Encoder", nil) message:NSLocalizedString(@"Are you sure you want to shutdown the encoder?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Yes", nil) otherButtonTitles:NSLocalizedString(@"Cancel", nil), nil];
//        self.shutdownAlertView.type = AlertIndecisive;
        
//        self.startAlertView = [[CustomAlertView alloc]initWithTitle:NSLocalizedString(@"myplayXplay", nil) message:@"Please select Home team, Away team and League to start the encoder" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];

        self.deviceVideoDataSource = [DeviceVideoDataSource new];
    }
    return self;
}

- (void)setupView
{
    

    
    [self.view setFrame:CGRectMake(0, 0, 350.0f, 768.0f)];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    CGFloat margin = 20;
    CGFloat yOffset = 140;
    CGFloat bWidth = 660;
    
    
    UILabel * leagueLabel = [[UILabel alloc]initWithFrame:CGRectMake(margin, yOffset, bWidth, 35.0f)];
    leagueLabel.text = @"League:";
//    leagueLabel.layer.borderWidth =1;
    
    
    UILabel * homeLabel = [[UILabel alloc]initWithFrame:CGRectMake(margin, yOffset+100, bWidth, 35.0f)];
    homeLabel.text = @"Home Team:";
//    homeLabel.layer.borderWidth =1;
    
    UILabel * awayLabel = [[UILabel alloc]initWithFrame:CGRectMake(margin, yOffset+200, bWidth, 35.0f)];
    awayLabel.text = @"Away Team:";
//    awayLabel.layer.borderWidth =1;
    
    [self.view  addSubview:leagueLabel];
    [self.view  addSubview:homeLabel];
    [self.view  addSubview:awayLabel];
    
    
    
    
    
    wifi = [[UILabel alloc]initWithFrame:CGRectMake(20.0f, 86.0f, 300.0f, 23.0f)];
    wifi.text =[NSString stringWithFormat: @"%@: %@", NSLocalizedString(@"Wi-Fi", nil), [Utility myWifiName] ];
    [self.view  addSubview:wifi];

    selectLeagueContainer = [[UIView alloc] initWithFrame:CGRectMake(margin, CGRectGetMaxY(leagueLabel.frame), bWidth, 55.0f)];
//    selectLeagueContainer.autoresizingMask      = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    selectLeagueContainer.layer.cornerRadius    = 5;
    selectLeagueContainer.layer.masksToBounds   = YES;
    
    [self.view  addSubview:selectLeagueContainer];
    
    selectHomeContainer = [[UIView alloc] initWithFrame:CGRectMake(margin, CGRectGetMaxY(homeLabel.frame), selectLeagueContainer.bounds.size.width, selectLeagueContainer.bounds.size.height)];
//    selectHomeContainer.autoresizingMask = selectLeagueContainer.autoresizingMask;
    selectHomeContainer.layer.cornerRadius    = 5;
    selectHomeContainer.layer.masksToBounds   = YES;
    [self.view  addSubview:selectHomeContainer];
    
    selectAwayContainer = [[UIView alloc] initWithFrame:CGRectMake(margin, CGRectGetMaxY(awayLabel.frame), selectLeagueContainer.bounds.size.width, selectLeagueContainer.bounds.size.height)];
//    selectAwayContainer.autoresizingMask = selectLeagueContainer.autoresizingMask;
    selectAwayContainer.layer.cornerRadius    = 5;
    selectAwayContainer.layer.masksToBounds   = YES;
    [self.view  addSubview:selectAwayContainer];
    
    
    firstEncButton = [[UIView alloc] initWithFrame:CGRectMake(80.0f, CGRectGetMaxY(selectAwayContainer.frame) + 80.0f, 150.0f, 150.0f)];
    firstEncButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view  addSubview:firstEncButton];
    
    secondEncButton = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 80.0f - 150.0f, firstEncButton.frame.origin.y, 150.0f, 150.0f)];
    secondEncButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view  addSubview:secondEncButton];
    
    encoderHomeLabel = [[UIView alloc] initWithFrame:CGRectMake(16.0f, 45.0f, 380.0f, 35.0f)];
    encoderHomeLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view  addSubview:encoderHomeLabel];
    
    
    self.makeLocalEventButton = [[UIButton alloc]initWithFrame:CGRectMake(500, 10, 200, 80)];
    [self.makeLocalEventButton addTarget:self action:@selector(buildStandAloneEvent) forControlEvents:UIControlEventTouchUpInside];
    [self.makeLocalEventButton setTitle:@"Build Local Event" forState:UIControlStateNormal];
    self.makeLocalEventButton.layer.borderWidth = 1;
    if (DEBUG_MODE){
        [self.view  addSubview:self.makeLocalEventButton];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //init subviews
    [self setupView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateWifiStatus) name:NOTIF_WIFI_CHANGED object:nil];
    [self initialiseLayout];
    
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

}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


-(void)viewWillAppear:(BOOL)animated
{
    wifi.text =[NSString stringWithFormat: @"%@: %@", NSLocalizedString(@"Wi-Fi", nil), [Utility myWifiName] ];
    [super viewWillAppear:animated];
    [self setButtonImagesAndLabels];
    [self showInformation];
}


/*
 Deselects all buttons and stops timer
 
 */
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    selectHomeTeam.selected     = NO;
    selectAwayTeam.selected     = NO;
    selectLeague.selected       = NO;
}

#pragma mark - Observers

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &masterContext){
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
    [_encStateLabel setText:@"( No Wifi )"];
    //[_encStateLabel setHidden:NO];
    [encoderHomeText setAlpha:1];
    [masterEncoder addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:&masterContext];
    [masterEncoder addObserver:self forKeyPath:@"isAlive" options:NSKeyValueObservingOptionNew context:nil];
    [self masterEncoderStatusObserver:masterEncoder];// run it once just to display status
}



#pragma mark -
#pragma mark Encoder Controls


- (void)startEnc:(id)sender
{
    
    NSString * buttonTitle = ((UIButton*)sender).titleLabel.text;
    
    NSString *ahomeTeam =[selectHomeTeam.titleLabel.text isEqualToString:DEFAULT_HOME_TEAM] ? nil : selectHomeTeam.titleLabel.text;
    NSString *aawayTeam =[selectAwayTeam.titleLabel.text isEqualToString:DEFAULT_AWAY_TEAM] ? nil : selectAwayTeam.titleLabel.text;
    NSString *aleague   =[selectLeague.titleLabel.text   isEqualToString:DEFAULT_LEAGUE]    ? nil : selectLeague.titleLabel.text;
    
    if(!(ahomeTeam && aawayTeam && aleague))//only allow user to start enc if they have selected all three, home team, away team, league
    {
        if (masterEncoder.status == ENCODER_STATUS_READY || masterEncoder.status == ENCODER_STATUS_STOP){

            // Build the alert
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"myplayXplay", nil)
                                                                            message:@"Please select Home team, Away team and League to start the encoder"
                                                                     preferredStyle:UIAlertControllerStyleAlert];
            // build ok button
            UIAlertAction* okButtons = [UIAlertAction
                                        actionWithTitle:@"Ok"
                                        style:UIAlertActionStyleCancel
                                        handler:^(UIAlertAction * action)
                                        {
                                            [[CustomAlertControllerQueue getInstance] dismissViewController:alert animated:YES completion:nil];
                                        }];
            [alert addAction:okButtons];
            
            [[CustomAlertControllerQueue getInstance]presentViewController:alert inController:self animated:YES style:AlertImportant completion:nil];

            return;
        }
    }
    
    if ([buttonTitle isEqualToString:@"Start"]) {
        
        // build operation
        EncoderOperation * startEvent = [[EncoderOperationStart alloc]initEncoder:encoderManager.masterEncoder data:@{@"start"  : [NSNumber numberWithBool:YES],
                                                                                                                      @"homeTeam"   : ahomeTeam,
                                                                                                                      @"awayTeam"   : aawayTeam,
                                                                                                                      @"league" : aleague
                                                                                                                      }];
        
        
        
        
        
        [startEvent setOnRequestComplete:^(NSData * data, EncoderOperation * op) {
            NSDictionary * results = [Utility JSONDatatoDict:data];
            if ([results[@"success"]intValue] == 0) {
                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_STATUS_LABEL_CHANGED object:self];
                
                UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Can't Start Event"
                                                                                message:results[@"msg"]
                                                                         preferredStyle:UIAlertControllerStyleAlert];
                
                // build NO button
                UIAlertAction* cancelButtons = [UIAlertAction
                                                actionWithTitle:OK_BUTTON_TXT
                                                style:UIAlertActionStyleCancel
                                                handler:^(UIAlertAction * action)
                                                {
                                                    [[CustomAlertControllerQueue getInstance] dismissViewController:alert animated:YES completion:nil];
                                                }];
                [alert addAction:cancelButtons];

                
                 [[CustomAlertControllerQueue getInstance] presentViewController:alert inController:ROOT_VIEW_CONTROLLER animated:YES style:AlertImportant completion:nil];
            }
        }];
        
        [encoderManager.masterEncoder runOperation:startEvent];
        
        
        // change UI
        [self eventControlsState:EventButtonControlStatesStart];
    } else { // resume video
        
        EncoderOperation * operation = [[EncoderOperationResume alloc]initEncoder:encoderManager.masterEncoder data:nil];
        [encoderManager.masterEncoder runOperation:operation];
    }
    
}


- (void)shutdownEnc:(id)sender {
    
    // Build the alert
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Shutdown Encoder"
                                                                    message:@"Are you sure you want to shutdown the encoder?"
                                                             preferredStyle:UIAlertControllerStyleAlert];
    // build YES button
    UIAlertAction* yesButtons = [UIAlertAction
                                 actionWithTitle:@"Yes"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     EncoderOperation * operation = [[EncoderOperationShutdown alloc]initEncoder:encoderManager.masterEncoder data:nil];
                                     [encoderManager.masterEncoder runOperation:operation];
                                     [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MASTER_COMMAND object:self userInfo:@{@"shutdown"  : [NSNumber numberWithBool:YES]}];
                                     [[CustomAlertControllerQueue getInstance] dismissViewController:alert animated:YES completion:nil];
                                 }];
    [alert addAction:yesButtons];
    
    // build NO button
    UIAlertAction* noButtons = [UIAlertAction
                                actionWithTitle:@"No"
                                style:UIAlertActionStyleCancel
                                handler:^(UIAlertAction * action)
                                {
                                    [[CustomAlertControllerQueue getInstance] dismissViewController:alert animated:YES completion:nil];
                                }];
    [alert addAction:noButtons];
    
    // this check to see if the alert was successful if indisisive
    BOOL isIndecisive = [[CustomAlertControllerQueue getInstance]presentViewController:alert inController:self animated:YES style:AlertIndecisive completion:nil];
    
    // if your decisive
    if (!isIndecisive){
        EncoderOperation * operation = [[EncoderOperationShutdown alloc]initEncoder:encoderManager.masterEncoder data:nil];
        [encoderManager.masterEncoder runOperation:operation];
    }

    
    
}

- (void)pauseEnc:(id)sender {
    
    // Build the alert
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Pause Event"
                                                                    message:@"Are you sure you want to pause the event?"
                                                             preferredStyle:UIAlertControllerStyleAlert];
    // build YES button
    UIAlertAction* yesButtons = [UIAlertAction
                                 actionWithTitle:@"Yes"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     EncoderOperation * operation = [[EncoderOperationPause alloc]initEncoder:encoderManager.masterEncoder data:nil];
                                     [encoderManager.masterEncoder runOperation:operation];
                                     [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MASTER_COMMAND object:self userInfo:@{@"pause"  : [NSNumber numberWithBool:YES]}];
                                     [[CustomAlertControllerQueue getInstance] dismissViewController:alert animated:YES completion:nil];
                                 }];
    [alert addAction:yesButtons];
    
    // build NO button
    UIAlertAction* noButtons = [UIAlertAction
                                actionWithTitle:@"No"
                                style:UIAlertActionStyleCancel
                                handler:^(UIAlertAction * action)
                                {
                                    [[CustomAlertControllerQueue getInstance] dismissViewController:alert animated:YES completion:nil];
                                }];
    [alert addAction:noButtons];
    
    // this check to see if the alert was successful if indisisive
    BOOL isIndecisive = [[CustomAlertControllerQueue getInstance]presentViewController:alert inController:self animated:YES style:AlertIndecisive completion:nil];
    
    // if your decisive
    if (!isIndecisive){
        EncoderOperation * operation = [[EncoderOperationPause alloc]initEncoder:encoderManager.masterEncoder data:nil];
        [encoderManager.masterEncoder runOperation:operation];
    }
}

- (void)stopEnc:(id)sender {
    
    // Build the alert
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Stop Event"
                                                                    message:@"Are you sure you want to stop the event?"
                                                             preferredStyle:UIAlertControllerStyleAlert];
    // build YES button
    UIAlertAction* yesButtons = [UIAlertAction
                                    actionWithTitle:@"Yes"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        EncoderOperation * operation = [[EncoderOperationStop alloc]initEncoder:encoderManager.masterEncoder data:nil];
                                        
                                        // TODO: Make this
                                        if (YES /*IF has startTag and not have close Tag*/) {
//                                            EncoderOperation * closeGameTag = [[EncoderOperationMakeTag alloc]initEncoder:encoderManager.masterEncoder data:@{}];
//                                            [operation addDependency:closeGameTag];
//                                            [encoderManager.masterEncoder runOperation:closeGameTag];
                                        }
                                        
                                        
                                        
                                        
                                        
                                        [encoderManager.masterEncoder runOperation:operation];
                                        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MASTER_COMMAND object:self userInfo:@{@"stop"  : [NSNumber numberWithBool:YES]}];
                                        [[CustomAlertControllerQueue getInstance] dismissViewController:alert animated:YES completion:nil];
                                    }];
    [alert addAction:yesButtons];
    
    // build NO button
    UIAlertAction* noButtons = [UIAlertAction
                                    actionWithTitle:@"No"
                                    style:UIAlertActionStyleCancel
                                    handler:^(UIAlertAction * action)
                                    {
                                        [[CustomAlertControllerQueue getInstance] dismissViewController:alert animated:YES completion:nil];
                                    }];
    [alert addAction:noButtons];
    
    // this check to see if the alert was successful if indisisive
    BOOL isIndecisive = [[CustomAlertControllerQueue getInstance]presentViewController:alert inController:self animated:YES style:AlertIndecisive completion:nil];
    
    // if your decisive
    if (!isIndecisive){
        EncoderOperation * operation = [[EncoderOperationStop alloc]initEncoder:encoderManager.masterEncoder data:nil];
        [encoderManager.masterEncoder runOperation:operation];
    }
    

}

#pragma mark - Standalone Event
-(void)buildStandAloneEvent
{
    MakeEventViewController * vc = [MakeEventViewController new];
    vc.modalPresentationStyle  = UIModalPresentationPopover; // Might have to make it custom if we want the fade darker
    vc.preferredContentSize    = vc.view.bounds.size;

    vc.delegate = self;
    vc.videoTable.dataSource   = self.deviceVideoDataSource;
//    vc.videoCollection.dataSource = self.deviceVideoDataSource;
    [vc.videoTable reloadData];
    
    UIPopoverPresentationController *presentationController = [vc popoverPresentationController];
    presentationController.sourceRect               = self.view.frame;//[[UIScreen mainScreen] bounds];
    presentationController.sourceView               = self.view;
    presentationController.permittedArrowDirections = 0;

    [self presentViewController:vc animated:YES completion:nil];
    

    
    
}

#pragma mark -

-(void)teamPick:(id)sender
{
    
    TablePopoverController  * tablePopup        = (sender == selectHomeTeam)?homeTeamPick:visitTeamPick;
    UIView                  * popupContainer    = (sender == selectHomeTeam)?selectHomeContainer:selectAwayContainer;
    

    if ([_leagueName isEqualToString:DEFAULT_LEAGUE]){
        teamNames   = grabNames(encoderManager.masterEncoder.encoderTeams);
    } else {
        League          * currentLeague         = [encoderManager.masterEncoder.encoderLeagues objectForKey:_leagueName];
        NSArray         * teamsCollection       = [currentLeague.teams allValues];
        NSMutableArray  * teamsNameCollection   = [[NSMutableArray alloc]init];
        for (LeagueTeam * team in teamsCollection) {
            NSString    * teamName  = team.name;
            [teamsNameCollection addObject:teamName];
        }
        teamNames = [[NSSet setWithArray:teamsNameCollection]allObjects];
    }
    
    
    if (teamNames) {
        UIButton *popButton = (UIButton*)sender;

        [tablePopup populateWith:teamNames];
        __block EncoderControlsViewController * weakSelf = self;
        
        if (sender == selectHomeTeam) {
            [tablePopup addOnCompletionBlock:^(NSString *pick) {
                [popButton setTitle:pick forState:UIControlStateNormal];
                weakSelf -> _homeTeam = pick;
            }];

        } else {
            [tablePopup addOnCompletionBlock:^(NSString *pick) {
                [popButton setTitle:pick forState:UIControlStateNormal];
                weakSelf -> _awayTeam = pick;
            }];
        }
        [tablePopup presentPopoverFromRect:popButton.frame inView:popupContainer permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    
    
    
    
}

-(void)pickLeague:(id)sender
{
    leagueNames = grabNames(encoderManager.masterEncoder.encoderLeagues);
    if (leagueNames) {
        UIButton *popButton = (UIButton*)sender;

        __block EncoderControlsViewController * weakSelf = self;
        [_leaguePick populateWith:leagueNames];
        [_leaguePick addOnCompletionBlock:^(NSString *pick) {
            [popButton setTitle:pick forState:UIControlStateNormal];
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

        // Build the alert
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"No Team", nil)
                                                                        message:NSLocalizedString(@"There is no team for this league", nil)
                                                                 preferredStyle:UIAlertControllerStyleAlert];

        
        // build NO button
        UIAlertAction* noButtons = [UIAlertAction
                                    actionWithTitle:@"Ok"
                                    style:UIAlertActionStyleCancel
                                    handler:^(UIAlertAction * action)
                                    {
                                        [[CustomAlertControllerQueue getInstance] dismissViewController:alert animated:YES completion:nil];
                                    }];
        [alert addAction:noButtons];
        
        // this check to see if the alert was successful if indisisive
        [[CustomAlertControllerQueue getInstance]presentViewController:alert inController:self animated:YES style:AlertImportant completion:nil];
        

    }

    [selectHomeTeam setTitle:DEFAULT_HOME_TEAM forState:UIControlStateNormal];
    [selectAwayTeam setTitle:DEFAULT_AWAY_TEAM forState:UIControlStateNormal];
}

-(void)initialiseLayout
{
    selectHomeTeam = [DropdownButton buttonWithType:UIButtonTypeCustom];
    
    [selectHomeTeam setFrame:CGRectMake(0.0f, 0.0f, selectHomeContainer.bounds.size.width, selectHomeContainer.bounds.size.height)];
    selectHomeTeam.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [selectHomeTeam setTitle:_homeTeam forState:UIControlStateNormal];
    [selectHomeTeam setTag:0];
    [selectHomeTeam addTarget:self action:@selector(teamPick:) forControlEvents:UIControlEventTouchUpInside];
    [selectHomeContainer addSubview:selectHomeTeam];
    
    selectAwayTeam = [DropdownButton buttonWithType:UIButtonTypeCustom];
    
    [selectAwayTeam setFrame:CGRectMake(0.0f, 0.0f, selectAwayContainer.bounds.size.width, selectAwayContainer.bounds.size.height)];
    selectAwayTeam.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [selectAwayTeam setTitle:_awayTeam forState:UIControlStateNormal];
    [selectAwayTeam setTag:1];
    [selectAwayTeam addTarget:self action:@selector(teamPick:) forControlEvents:UIControlEventTouchUpInside];
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
    
    encHomeButton = [BorderlessButton buttonWithType:UIButtonTypeSystem];
    [encHomeButton setFrame:CGRectMake(0.0f, 5.0f, 140, 45)];
    [encHomeButton setTitle:@"Encoder Home" forState:UIControlStateNormal];
    [encHomeButton setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
    [encHomeButton addTarget:self action:@selector(openEncoderHomeInSafari:) forControlEvents:UIControlEventTouchUpInside];
    [encHomeButton setUserInteractionEnabled:YES];
    
    //encoder state label
    _encStateLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(encHomeButton.frame), 10, encoderHomeLabel.frame.size.width - encHomeButton.frame.size.width , encoderHomeLabel.frame.size.height)];
    [encoderHomeLabel addSubview:_encStateLabel];
    [_encStateLabel setText:@"( No Wifi )"];
    


    [self setButtonImagesAndLabels];
    if (masterEncoder){
        [self masterEncoderStatusObserver:masterEncoder];
    } else {
        [self eventControlsState:EventButtonControlStatesDisabled];
    }
}

- (void)updateWifiStatus{
    
    wifi.text =[NSString stringWithFormat: @"%@: %@", NSLocalizedString(@"Wi-Fi", nil), [Utility myWifiName] ];
}

-(UIModalPresentationStyle)modalPresentationStyle{
    return UIModalPresentationFormSheet;
}


-(void)setButtonImagesAndLabels
{
        
    if (![Utility hasWiFi]) {
        encoderHomeText.text = @"Encoder is not available.";
        encoderHomeText.adjustsFontSizeToFitWidth = true;
        [encHomeButton setTitle:@"Encoder is not available" forState:UIControlStateSelected];
        [_encStateLabel setText:@"( No Wifi )"];
        [encHomeButton removeFromSuperview];
        [encHomeButton setUserInteractionEnabled:NO];
        [encoderHomeLabel addSubview:encoderHomeText];
        

    }else{
        if([_encStateLabel.text  isEqual: @"( No Wifi )"])
//        [_encStateLabel setText:@"( No Encoder )"];
        [_encStateLabel setText:@"( Searching for Encoder )"];
        [encoderHomeText removeFromSuperview];
        [encoderHomeLabel addSubview:encHomeButton];
        [encHomeButton setUserInteractionEnabled:YES];
        

    }
}

-(void)openEncoderHomeInSafari:(id)sender
{
    if (encoderManager.masterEncoder.ipAddress){
        NSString * urlPath = [NSString stringWithFormat:@"http://%@/min",encoderManager.masterEncoder.ipAddress];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: urlPath]];
    }
}


-(void) showInformation
{
    if (encoderManager.masterEncoder && encoderManager.masterEncoder.liveEvent) {
        Event * liveE = encoderManager.masterEncoder.liveEvent;
        //        liveE.teams
        LeagueTeam * away = liveE.teams[@"visitTeam"];
        LeagueTeam * home = liveE.teams[@"homeTeam"];
        
        [selectHomeTeam setTitle:home.name forState:UIControlStateNormal];
        [selectAwayTeam setTitle:away.name forState:UIControlStateNormal];
        [selectLeague setTitle:home.league.name forState:UIControlStateNormal];

        if (!away.league || !home.league) {
            PXPLog(@"No bottomViewController for ");

        }
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
//    [pauseButton setHidden:      YES];
    
    [resumeButton setHidden:     (state & RESUME_HIDDEN)!=0];
    [resumeButton setEnabled:    (state & RESUME_ENABLE)!=0];
    [resumeButton setAlpha:      (state & RESUME_ENABLE)?1.0f:0.6f];
//    [resumeButton setHidden:     YES];
    
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

//-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer
//{
//    return YES;
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}


#define mark - MakeEventViewControllerDeleagate
-(void)onMakeEvent:(MakeEventViewController*)sender
{
  
    
    
    
    
    
    NSDateFormatter *aDateFormatter = [[NSDateFormatter alloc]init];
    aDateFormatter.dateFormat = @"yyyy-MM-dd";
    
    NSString * hid              = [[NSUUID UUID]UUIDString];
    NSString * fileName         = @"main_00hq.mp4";
    
    NSString * dateString       = [aDateFormatter stringFromDate:sender.datePicker.date];
    dateString                  = [dateString stringByAppendingString:@"_12-00-00"];
    
    NSString * dateString1      = [aDateFormatter stringFromDate:sender.datePicker.date];
    dateString1                  = [dateString1 stringByAppendingString:@" 12:00:00"];
    
    
    NSString * localPath   = [LocalMediaManager getInstance].localPath;
    
    
    NSString * folderURL    = [NSString stringWithFormat:@"%@/events/%@_%@",localPath,dateString,hid];
    NSString * fileURL     = [folderURL stringByAppendingPathComponent:fileName];
    
    NSMutableDictionary * data = [NSMutableDictionary dictionaryWithDictionary:@{
                                        @"datapath"      : [NSString stringWithFormat:@"%@_%@",dateString,hid],
                                        @"date"          : dateString1,//@"2016-06-08 12:11:20"
                                        @"dateFmt"       : dateString,//@"2016-06-08_12-11-20"
                                        @"hid"           : hid,
                                        @"homeTeam"      : sender.homeTeamNameInput.text,
                                        @"visitTeam"     : sender.awayTeamNameInput.text,
                                        @"league"        : sender.leagueNameInput.text,
                                        @"sport"         : @"none",
                                        @"mp4"           : fileURL,
                                        @"mp4_2"         : [ @{@"s_00" : fileURL}mutableCopy],
                                        @"name"          : [NSString stringWithFormat:@"%@_%@",dateString,hid],//@"2016-06-08_12-11-20_3f30c7c14d4da656f9eda33b792838a2a0fb7236_local"
                                        @"tags"          : [@{} mutableCopy],
                                        @"vid"           : fileURL,
                                        @"vid_2"         : [@{@"s_00" : [@{
                                                                     @"hq" : fileURL,
                                                                     @"lq" : fileURL,
                                                                     @"vidsize_hq" : @"0.00MB",
                                                                     @"vidsize_lq" : @"0.00MB",
                                                                     @"vq" : @"lq"
                                                                     }mutableCopy]
                                                              }mutableCopy],
                                        
                                        }];
    
    

    // make the event
    

    
    // add Video
    
     
    NSString * eventName = [[LocalMediaManager getInstance] makeLocalEvent:data];
    
    
    NSLog(@"Output video URL: %@",fileURL);
    
    PHAsset *assetFromTable = self.deviceVideoDataSource.videos[sender.videoTable.indexPathForSelectedRow.row];
    
    CopyDeviceVideoToOperation * copyOp = [[CopyDeviceVideoToOperation alloc]initAsset:assetFromTable outputStringURL:fileURL];
    
    
    
    [copyOp setCompletionBlock:^{
        NSLog(@"Complete");
    }];
    [[NSOperationQueue mainQueue]addOperation:copyOp];

 
}

-(void)onMakeEventAndLaunch:(MakeEventViewController*)sender
{
    
    
    
    
    
    
    
    [self makeNewLocalEvent:sender onComplete:^(Event *event) {
           [[LocalMediaManager getInstance] refresh];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSString * eventName = event.datapath;
            
            Event *updatedEvent = [[LocalMediaManager getInstance] getEventByName:eventName];
            
            LeagueTeam * home = event.teams[@"homeTeam"];
            LeagueTeam * away = event.teams[@"visitTeam"];
            updatedEvent.teams = event.teams;
            NSArray * teamNames = @[ home.name,away.name];//[event.teams allKeys];
            
            _teamPick = [[ListPopoverController alloc]initWithMessage:NSLocalizedString(@"Please select the team you want to tag:", @"dev comment - asking user to pick a team")
                                                      buttonListNames:@[
                                                                        [teamNames firstObject],
                                                                        [teamNames lastObject]
                                                                        ]];
            
            _teamPick.contentViewController.modalInPopover = NO;
            
            [_teamPick addOnCompletionBlock:^(NSString *pick) {
                
                [UserCenter getInstance].taggingTeam = [updatedEvent.teams objectForKey:pick];
//
                    [[NSNotificationCenter defaultCenter] postNotificationName: NOTIF_SELECT_TAB          object:updatedEvent userInfo:@{@"tabName":@"Live2Bench"}];
                    [[EncoderManager getInstance] declareCurrentEvent:updatedEvent];
                
            }];
            
            [_teamPick presentPopoverCenteredIn:[UIApplication sharedApplication].keyWindow.rootViewController.view
                                       animated:YES];
            
            
            
            
            
            
            
//            [[NSNotificationCenter defaultCenter] postNotificationName: NOTIF_SELECT_TAB          object:event userInfo:@{@"tabName":@"Live2Bench"}];
//            [[EncoderManager getInstance] declareCurrentEvent:event];
        });

    }];
}



-(void)makeNewLocalEvent:(MakeEventViewController*)sender onComplete:(void (^)(Event*event))onComplete
{
    
    NSDateFormatter *aDateFormatter = [[NSDateFormatter alloc]init];
    aDateFormatter.dateFormat = @"yyyy-MM-dd";
    NSString * hid              = [[NSUUID UUID]UUIDString];
    NSString * fileName         = @"main_00hq.mp4";
    NSString * dateString       = [aDateFormatter stringFromDate:sender.datePicker.date];
    dateString                  = [dateString stringByAppendingString:@"_12-00-00"];
    NSString * dateString1      = [aDateFormatter stringFromDate:sender.datePicker.date];
    dateString1                  = [dateString1 stringByAppendingString:@" 12:00:00"];
    
    NSString * localPath   = [LocalMediaManager getInstance].localPath;
    
    NSString * folderURL    = [NSString stringWithFormat:@"%@/events/%@_%@",localPath,dateString,hid];
    NSString * fileURL     = [folderURL stringByAppendingPathComponent:fileName];
    
    NSMutableDictionary * data = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                 @"datapath"      : [NSString stringWithFormat:@"%@_%@",dateString,hid],
                                                                                 @"date"          : dateString1,//@"2016-06-08 12:11:20"
                                                                                 @"dateFmt"       : dateString,//@"2016-06-08_12-11-20"
                                                                                 @"hid"           : hid,
                                                                                 @"homeTeam"      : sender.homeTeamNameInput.text,
                                                                                 @"visitTeam"     : sender.awayTeamNameInput.text,
                                                                                 @"league"        : sender.leagueNameInput.text,
                                                                                 @"sport"         : @"none",
                                                                                 @"mp4"           : fileURL,
                                                                                 @"mp4_2"         : [ @{@"s_00" : fileURL}mutableCopy],
                                                                                 @"name"          : [NSString stringWithFormat:@"%@_%@",dateString,hid],//@"2016-06-08_12-11-20_3f30c7c14d4da656f9eda33b792838a2a0fb7236_local"
                                                                                 @"tags"          : [@{} mutableCopy],
                                                                                 @"vid"           : fileURL,
                                                                                 @"vid_2"         : [@{@"s_00" : [@{
                                                                                                                    @"hq" : fileURL,
                                                                                                                    @"lq" : fileURL,
                                                                                                                    @"vidsize_hq" : @"0.00MB",
                                                                                                                    @"vidsize_lq" : @"0.00MB",
                                                                                                                    @"vq" : @"lq"
                                                                                                                    }mutableCopy]
                                                                                                       }mutableCopy],
                                                                                 
                                                                                 }];
    
    
    
    // make the event
    

    // populating teams based off data
    LeagueTeam  * homeTeam      = [LeagueTeam new];
    homeTeam.name = data[@"homeTeam"];
    
    LeagueTeam  * visitTeam     = [LeagueTeam new];
    visitTeam.name = data[@"visitTeam"];

    
    // add Video
    
    //Event*event
    
    NSString * eventName = [[LocalMediaManager getInstance] makeLocalEvent:data];
    
    PHAsset *assetFromTable = self.deviceVideoDataSource.videos[sender.videoTable.indexPathForSelectedRow.row];
    
    CopyDeviceVideoToOperation * copyOp = [[CopyDeviceVideoToOperation alloc]initAsset:assetFromTable outputStringURL:fileURL];
    
    [copyOp setCompletionBlock:^{
        NSLog(@"Complete");
        
        
        Event* event =  [[LocalMediaManager getInstance] getEventByName:[eventName lastPathComponent]];
        event.teams = @{@"homeTeam":homeTeam,@"visitTeam":visitTeam};
        if (onComplete){
             onComplete(event);
        }
    }];
    [[NSOperationQueue mainQueue]addOperation:copyOp];



}

@end
