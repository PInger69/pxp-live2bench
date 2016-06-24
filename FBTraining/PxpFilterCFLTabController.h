//
//  PxpFilterCFLTabController.h
//  Live2BenchNative
//
//  Created by dev on 2016-06-01.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "PxpFilterTabController.h"
#import "PxpFilterTabController.h"
#import "PxpFilterButtonScrollView.h"
#import "PxpFilterRangeSliderView.h"
#import "RangeSlider.h"
#import "PxpFilterButton.h"
#import "PxpFilterToggleButton.h"
#import "PxpFilterUserButtons.h"

@interface PxpFilterCFLTabController : PxpFilterTabController <PxpFilterModuleDelegate>


@property (strong, nonatomic,nullable) IBOutlet PxpFilterButtonScrollView *tagNameScrollView;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterButtonScrollView *playersScrollView;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterRangeSliderView *sliderView;

@property (strong, nonatomic,nullable) IBOutlet PxpFilterUserButtons *userButton;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterToggleButton *favoriteButton;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterToggleButton *telestrationButton;
@property (strong, nonatomic,nullable) IBOutlet UISwitch *preFilterSwitch;

@property (strong, nonatomic,nullable) IBOutlet UILabel *totalTagLabel;
@property (strong, nonatomic,nullable) IBOutlet UILabel *filteredTagLabel;

@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *p1;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *p2;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *p3;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *p4;


@end
