//
//  PreferencesViewController.m
//  Live2BenchNative
//
//  Created by dev on 2015-09-14.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PreferencesViewController.h"


typedef NS_ENUM (NSInteger,ConnectionStatus){
    ConnectionStatusIdle,
    ConnectionStatusConnecting,
    ConnectionStatusConnected,
    ConnectionStatusNotFound,
    ConnectionStatusFail
    
    
};




@interface PreferencesViewController ()
@property (nonatomic,assign) ConnectionStatus connectionStatus;
@end

@implementation PreferencesViewController

- (instancetype)initWithAppDelegate:(nonnull AppDelegate *)appDel {
    
    self.connectionStatus = ConnectionStatusIdle;
    
    return [super initWithAppDelegate:appDel name:NSLocalizedString(@"Preferences", nil) identifier:@"Preferences"];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.connectButton addTarget:self action:@selector(onConnect:) forControlEvents:UIControlEventTouchUpInside];
    [self.liveBuffer addTarget:self action:@selector(pickLiveBuffer:) forControlEvents:UIControlEventValueChanged];
    [self.modeSegment addTarget:self action:@selector(onModeSwitch:) forControlEvents:UIControlEventValueChanged];
    
    self.urlInputTextArea.delegate = self;
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    
    NSString * mode =  [defaults objectForKey:@"mode"];
    if (mode) {
        if ([mode isEqualToString:@"hq"]) {
            self.modeSegment.selectedSegmentIndex =1;
        } else if ([mode isEqualToString:@"streamOp"]) {
            self.modeSegment.selectedSegmentIndex =2;
        } else if ([mode isEqualToString:@"proxy"]) {
            self.modeSegment.selectedSegmentIndex =0;
        } else if ([mode isEqualToString:@"dual"]) {
            self.modeSegment.selectedSegmentIndex =3;
        }
        
    } else {
        self.modeSegment.selectedSegmentIndex =0;
        [defaults setObject:@"proxy" forKey:@"mode"];
        [defaults synchronize];
    }
    
    // get user defaults
    
    
    [self.recToggle setOnTintColor:PRIMARY_APP_COLOR];
    [self.recToggle setTintColor:PRIMARY_APP_COLOR];
//    [self.recToggle setThumbTintColor:[UIColor grayColor]];
    
    [self.lockStart setOnTintColor:PRIMARY_APP_COLOR];
    [self.lockStart setTintColor:PRIMARY_APP_COLOR];
//    [self.lockStart setThumbTintColor:[UIColor grayColor]];
    
     [UserCenter getInstance].isStartLocked = self.lockStart.isOn;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.lockStart.on = [UserCenter getInstance].isStartLocked ;
    PXPLog(@"%@ is %@",[[UserCenter getInstance]userHID],[[EncoderManager getInstance].liveEvent.gameStartTag user]);
    if (![[[UserCenter getInstance]userHID] isEqualToString:[[EncoderManager getInstance].liveEvent.gameStartTag user]]) {
        self.lockStart.enabled = NO;
    } else  {
        self.lockStart.enabled = YES;
        
    }
    
    
}

- (IBAction)onLockStartTime:(id)sender {
    UISwitch * swit = (UISwitch *)sender;
    [UserCenter getInstance].isStartLocked = swit.isOn;
    
    
    
}

-(void)onConnect:(id)sender
{
    [self.urlInputTextArea resignFirstResponder];
    
    switch (self.connectionStatus) {
        case ConnectionStatusIdle:
            [self startConnection];
            break;
        case ConnectionStatusConnected:
             [self cancelConnection];
            break;
        case ConnectionStatusConnecting:
        case ConnectionStatusNotFound:
        case ConnectionStatusFail:
        default:
            break;
    }
    

}

-(void)startConnection
{
    // Remove all Encoder and start connection
    [[CustomAlertControllerQueue getInstance].suppressedTitles addObject:@"No Encoder"];// this suppresses the no encoder pop up
    for (Encoder * encoder in self.encoderManager.authenticatedEncoders) {
        [self.encoderManager unRegisterEncoder:encoder];
    }
    [[CustomAlertControllerQueue getInstance].suppressedTitles removeObject:@"No Encoder"];

    
    self.encoderManager.bonjourModule.searching = NO;
    self.connectionStatus = ConnectionStatusConnecting;
    [self.connectButton setTitle:@"Connecting..." forState:UIControlStateNormal];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onConnection:)    name:NOTIF_ENCODER_COUNT_CHANGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failAuth:)        name:NOTIF_EM_CONNECTION_ERROR object:nil];
    [self.encoderManager registerEncoder:@"External Encoder" ip:self.urlInputTextArea.text];
    
}


-(void)onConnection:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_ENCODER_COUNT_CHANGE object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_EM_CONNECTION_ERROR object:nil];
    self.connectionStatus = ConnectionStatusConnected;
    [self.connectButton setTitle:@"Disconnect" forState:UIControlStateNormal];
}


-(void)failAuth:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_ENCODER_COUNT_CHANGE object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_EM_CONNECTION_ERROR object:nil];
    self.connectionStatus = ConnectionStatusFail;
    [self.connectButton setTitle:@"FAILED" forState:UIControlStateNormal];
}




-(void)cancelConnection
{
    [[CustomAlertControllerQueue getInstance].suppressedTitles addObject:@"No Encoder"];// this suppresses the no encoder pop up
    for (Encoder * encoder in self.encoderManager.authenticatedEncoders) {
        [self.encoderManager unRegisterEncoder:encoder];
    }
    [[CustomAlertControllerQueue getInstance].suppressedTitles removeObject:@"No Encoder"];
    [self.connectButton setTitle:@"Disconnected" forState:UIControlStateNormal];
    self.connectionStatus = ConnectionStatusIdle;
    self.encoderManager.bonjourModule.searching = YES;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.connectionStatus = ConnectionStatusIdle;
    [self.connectButton setTitle:@"Connect" forState:UIControlStateNormal];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{

    [self onConnect:nil];
    return YES;
}


// preference
-(void)pickLiveBuffer:(id)sender
{
    UISegmentedControl * segmenter = sender;

    
    
    switch (segmenter.selectedSegmentIndex) {
        case 1:
            [UserCenter getInstance].preferenceLiveBuffer = 3;
            break;
        case 2:
            [UserCenter getInstance].preferenceLiveBuffer = 5;
            break;
        case 0:
        default:
            [UserCenter getInstance].preferenceLiveBuffer = 0;
            break;
    }
    
    


}

-(void)onModeSwitch:(id)sender
{
    UISegmentedControl * segmenter = sender;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
 
    switch (segmenter.selectedSegmentIndex) {
        case 0:
                [defaults setObject:@"proxy" forKey:@"mode"];
            break;
        case 1:
                [defaults setObject:@"hq" forKey:@"mode"];
            break;
        case 2:
            [defaults setObject:@"streamOp" forKey:@"mode"];
            break;
        case 3:
            [defaults setObject:@"dual" forKey:@"mode"];
            break;
        default:
            [defaults setObject:@"streamOp" forKey:@"mode"];
            break;
    }

     [defaults synchronize];
    
//    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_PREFERENCE_FEED_MODE object:nil];
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Pxp Preferences"
                                  message:@"After making a mode change please restart app"
                                  preferredStyle:UIAlertControllerStyleAlert];
    

    UIAlertAction* okButton = [UIAlertAction
                               actionWithTitle:@"Ok"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                [alert dismissViewControllerAnimated:YES completion:nil];
                                   
                               }];
    
    [alert addAction:okButton];
    
    [self presentViewController:alert animated:YES completion:nil];

}

- (IBAction)toggleRegStat:(id)sender {
    UISwitch * switcher = (UISwitch *)sender;
    
    Encoder * enc = (Encoder *)[EncoderManager getInstance].liveEvent.parentEncoder;
    if ( switcher.on) {
        
        
        EncoderOperation * testOp =  [[EncoderOperationCameraStartTimes alloc]initEncoder:enc data:nil];
        [enc runOperation:testOp];

    } else {

        Event * liveEvent = enc.liveEvent;

        if (liveEvent) {
            for (Feed * fed in [liveEvent.feeds allValues]) {
                fed.offset = 0;
                [fed.offsetDict removeAllObjects];
            }
        }

    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}



@end
