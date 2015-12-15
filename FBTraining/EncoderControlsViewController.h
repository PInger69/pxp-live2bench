//
//  SettingsViewController.h
//  Live2BenchNative
//
//  Created by DEV on 2013-03-08.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "BorderlessButton.h"
#import "BorderButton.h"
#import "CustomLabel.h"
#import "DropdownButton.h"
#import "AppDelegate.h"
@class EncoderManager;


@interface EncoderControlsViewController : UIViewController<UIAlertViewDelegate,UIGestureRecognizerDelegate>
{
    UILabel *wifi;
    UIView *firstEncButton;
    UIView *secondEncButton;
    CustomButton *encHomeButton;
    BorderlessButton *startButton;
    BorderlessButton *pauseButton;
    BorderlessButton *stopButton;
    BorderlessButton *shutdownButton;
    BorderlessButton *resumeButton;
    CustomButton *selectHomeTeam;
    CustomButton *selectAwayTeam;
    CustomButton *selectLeague;
    UIView *selectLeagueContainer;
    UIView *selectAwayContainer;
    UIView *selectHomeContainer;
    UIView *encoderHomeLabel;
    CustomLabel *encoderHomeText;
}


-(id)initWithAppDelegate:(AppDelegate*)appDel;
-(void)changeStatusString:(NSString*)statusString;

-(void)startEnc:(id)sender;
-(void)pauseEnc:(id)sender;
-(void)stopEnc:(id)sender;
-(void)shutdownEnc:(id)sender;

@end
