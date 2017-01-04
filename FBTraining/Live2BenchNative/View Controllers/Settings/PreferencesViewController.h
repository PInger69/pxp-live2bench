//
//  PreferencesViewController.h
//  Live2BenchNative
//
//  Created by dev on 2015-09-14.
//  Copyright © 2015 DEV. All rights reserved.
//


#import "SettingItemViewController.h"

@interface PreferencesViewController : SettingItemViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton               * connectButton;
@property (weak, nonatomic) IBOutlet UITextField            * urlInputTextArea;
@property (weak, nonatomic) IBOutlet UISegmentedControl     * liveBuffer;
@property (nonatomic,weak) IBOutlet UISwitch    * lockStart;



@property (weak, nonatomic) IBOutlet UISegmentedControl     * modeSegment;

- (nonnull instancetype)initWithAppDelegate:(nonnull AppDelegate *)appDel;



@end
