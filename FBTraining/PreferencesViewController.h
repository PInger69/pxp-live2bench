//
//  PreferencesViewController.h
//  Live2BenchNative
//
//  Created by dev on 2015-09-14.
//  Copyright © 2015 DEV. All rights reserved.
//


#import "SettingViewController.h"

@interface PreferencesViewController : SettingViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton       * connectButton;
@property (weak, nonatomic) IBOutlet UITextField    * urlInputTextArea;


- (nonnull instancetype)initWithAppDelegate:(nonnull AppDelegate *)appDel;

@end
