//
//  SignalStrengthViewController.h
//  Live2BenchNative
//
//  Created by Dev on 2013-11-01.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import "Globals.h"
#import "GraphView.h"
#import "CustomLabel.h"

@interface SignalStrengthViewController : UIViewController

@property (nonatomic, strong) Globals *globals;
@property (nonatomic, strong) CustomLabel *SSIDLabel;
@property (nonatomic, strong) GraphView *graphView;

@end
