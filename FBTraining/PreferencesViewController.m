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
    self.urlInputTextArea.delegate = self;
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
    [[CustomAlertView supressedTitles]addObject:@"No Encoder"]; // this suppresses the no encoder pop up
    for (Encoder * encoder in self.encoderManager.authenticatedEncoders) {
        [self.encoderManager unRegisterEncoder:encoder];
    }
    [[CustomAlertView supressedTitles]removeObject:@"No Encoder"];
    
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
    [[CustomAlertView supressedTitles]addObject:@"No Encoder"]; // this suppresses the no encoder pop up
    for (Encoder * encoder in self.encoderManager.authenticatedEncoders) {
        [self.encoderManager unRegisterEncoder:encoder];
    }
    [[CustomAlertView supressedTitles]removeObject:@"No Encoder"];
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



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    PXPLog(@"*** didReceiveMemoryWarning ***");
    // Dispose of any resources that can be recreated.
}



@end
