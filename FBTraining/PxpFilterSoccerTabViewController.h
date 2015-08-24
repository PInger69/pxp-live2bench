//
//  PxpFilterSoccerTabViewController.h
//  Live2BenchNative
//
//  Created by dev on 2015-08-14.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxpFilterButton.h"
#import "PxpFilterButtonScrollView.h"
#import "PxpFilterRangeSliderView.h"
#import "PxpFilterToggleButton.h"
#import "PxpFilterUserButtons.h"

@interface PxpFilterSoccerTabViewController : PxpFilterTabController <PxpFilterModuleDelegate>

@property (strong, nonatomic,nullable) IBOutlet PxpFilterButtonScrollView *tagNameScrollView;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterButtonScrollView *playersScrollView;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterRangeSliderView *sliderView;

@property (strong, nonatomic,nullable) IBOutlet PxpFilterUserButtons *userButton;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterToggleButton *favoriteButton;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterToggleButton *telestrationButton;
@property (strong, nonatomic,nullable) IBOutlet UISwitch *preFilterSwitch;

@property (strong, nonatomic,nullable) IBOutlet UILabel *totalTagLabel;
@property (strong, nonatomic,nullable) IBOutlet UILabel *filteredTagLabel;

@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *half1;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *half2;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *halfExtra;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *halfPS;

@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *zoneOFF;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *zoneMID;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *zoneDEF;
@end
