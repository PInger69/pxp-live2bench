//
//  PxpFilterRugbyTabViewController.h
//  Live2BenchNative
//
//  Created by dev on 2015-08-17.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpFilterTabController.h"
#import <UIKit/UIKit.h>
#import "PxpFilterButtonScrollView.h"
#import "PxpFilterRangeSliderView.h"
#import "PxpFilterToggleButton.h"
#import "PxpFilterUserButtons.h"
#import "PxpFilterButton.h"

@interface PxpFilterRugbyTabViewController : PxpFilterTabController
@property (strong, nonatomic,nullable) IBOutlet PxpFilterButtonScrollView *tagNameScrollView;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterRangeSliderView *sliderView;

@property (strong, nonatomic,nullable) IBOutlet UILabel *totalTagLabel;
@property (strong, nonatomic,nullable) IBOutlet UILabel *filteredTagLabel;

@property (strong, nonatomic,nullable) IBOutlet PxpFilterToggleButton *favoriteButton;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterToggleButton *telestrationButton;
@property (strong, nonatomic,nullable) IBOutlet UISwitch *preFilterSwitch;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterUserButtons *userButton;

@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *half1;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *half2;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *halfExtra;


@end
