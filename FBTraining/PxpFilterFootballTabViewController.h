//
//  PxpFilterFootballTabViewController.h
//  Live2BenchNative
//
//  Created by andrei on 2015-08-06.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpFilterTabController.h"
#import "PxpFilterButtonView.h"
#import "PxpFilterUserInputView.h"
#import "PxpFilterButtonScrollView.h"
#import "PxpFilterRangeSliderView.h"
#import "PxpFilterButton.h"
#import "PxpFilterToggleButton.h"
#import "PxpFilterUserButtons.h"
#import "RangeSlider.h"

@interface PxpFilterFootballTabViewController : PxpFilterTabController <PxpFilterModuleDelegate>

/*@property (strong, nonatomic, nullable) IBOutlet UILabel *filteredTagLabel;
@property (strong, nonatomic, nullable) IBOutlet UILabel *totalTagLabel;
@property (strong, nonatomic, nullable) IBOutlet PxpFilterButtonView *leftButtonView;
@property (strong, nonatomic, nullable) IBOutlet PxpFilterUserInputView *middleUserInputView;*/

@property (strong, nonatomic,nullable) IBOutlet PxpFilterButtonScrollView *tagNameScrollView;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterButtonScrollView *playersScrollView;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterRangeSliderView *sliderView;


@property (strong, nonatomic,nullable) IBOutlet PxpFilterUserButtons *userButton;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterToggleButton *favoriteButton;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterToggleButton *telestrationButton;
@property (strong, nonatomic,nullable) IBOutlet UISwitch *preFilterSwitch;

@property (strong, nonatomic,nullable) IBOutlet UILabel *totalTagLabel;
@property (strong, nonatomic,nullable) IBOutlet UILabel *filteredTagLabel;

@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *runTypeButton;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *passTypeButton;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *kickTypeButton;

@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *offenseDown1;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *offenseDown2;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *offenseDown3;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *defenseDown1;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *defenseDown2;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *defenseDown3;

@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *quarter1;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *quarter2;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *quarter3;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *quarter4;

@end
