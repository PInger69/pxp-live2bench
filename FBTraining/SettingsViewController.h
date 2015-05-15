//
//  SettingsViewController.h
//  Live2BenchNative
//
//  Created by DEV on 2013-03-08.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "SpinnerView.h"
#import "BorderlessButton.h"
#import "BorderButton.h"
#import "CustomLabel.h"
#import "DropdownButton.h"
#import "AppDelegate.h"
@class EncoderManager;

@interface SettingsViewController : UIViewController<UIScrollViewDelegate,UIAlertViewDelegate,UIPopoverControllerDelegate,UIGestureRecognizerDelegate>/*Removed: DBNetworkRequestDelegate no imp found*/
{
    UILabel *userName;
    UILabel *wifi;
    UIScrollView *scrollView;
    UIView *firstEncButton;
    UIView *secondEncButton;
    CustomButton *encHomeButton;
    BorderlessButton *startButton;
    BorderlessButton *pauseButton;
    BorderlessButton *stopButton;
    BorderlessButton *shutdownButton;
    BorderlessButton *resumeButton;
    CustomButton *accountsLabel;
    CustomButton *selectHomeTeam;
    CustomButton *selectAwayTeam;
    CustomButton *selectLeague;
    UILabel *firstEncLabel;
    UILabel *secondEncLabel;
    SpinnerView *spinnerView;
    UIView *signalStrengthView;
    UIImageView *signalStrengthOverlay;
    UIView *selectLeagueContainer;
    UIView *selectAwayContainer;
    UIView *selectHomeContainer;
    UIView *doNotShowContainer;
    UIView *viewEulaContainer;
    UIView *encoderHomeLabel;
    BorderlessButton *dropBoxLabel;
    UILabel *accountTitle;
    CustomButton *backToGeneral;
    UIView *dropboxContainer;
    BorderlessButton *dropboxLogout;
    NSTimer *updateDBLabelTimer;
    UILabel *fbAndEmailNote;
    CustomLabel *encoderHomeText;
}
@property (strong, nonatomic) CustomButton      *encHomeButton;
@property (strong, nonatomic) BorderlessButton  *logoutButton;
@property (strong, nonatomic) CustomLabel       *appVersionLabel;
@property (nonatomic)int timerCounter;
@property (nonatomic) int willStartNewEventCount;
@property (nonatomic) int waitEncoderResponseCounter;
@property (nonatomic,strong)NSTimer *spinnerTimer;

-(id)initWithAppDelegate:(AppDelegate*)appDel;

-(void)startEnc:(id)sender;
-(void)pauseEnc:(id)sender;
-(void)stopEnc:(id)sender;
-(void)shutdownEnc:(id)sender;
//-(void)encCallback:(id)json;
@end
