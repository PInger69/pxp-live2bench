//
//  CreditsViewController.h
//  Live2BenchNative
//
//  Created by Robert Lee on 2015-06-22.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "SettingViewController.h"


@interface CreditsViewController : SettingViewController

@property (weak, nonatomic) IBOutlet UIView *creditsView;

- (nonnull instancetype)initWithAppDelegate:(nonnull AppDelegate *)appDel;


@end