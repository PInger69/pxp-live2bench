//
//  PxpFilterHockeyTabViewController.h
//  Live2BenchNative
//
//  Created by andrei on 2015-08-05.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxpFilterTabController.h"
#import "PxpFilterButtonScrollView.h"
#import "PxpFilterRangeSliderView.h"
#import "RangeSlider.h"
#import "PxpFilterButton.h"
#import "PxpFilterToggleButton.h"
#import "PxpFilterUserButtons.h"

@interface PxpFilterHockeyTabViewController : PxpFilterTabController <PxpFilterModuleDelegate>

@property (strong, nonatomic,nullable) IBOutlet PxpFilterButtonScrollView *tagNameScrollView;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterButtonScrollView *playersScrollView;
@property (strong, nonatomic,nullable) IBOutlet UILabel *totalTagLabel;
@property (strong, nonatomic,nullable) IBOutlet UILabel *filteredTagLabel;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterRangeSliderView *sliderView;
@property (strong, nonatomic,nullable) IBOutlet UISwitch *preFilterSwitch;
@property (strong, nonatomic,nullable) IBOutlet UIView *periodView;

@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *getAllStrengthTags;

@property (strong, nonatomic,nullable) IBOutlet PxpFilterUserButtons *userButton;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterToggleButton *favoriteButton;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterToggleButton *telestrationButton;

@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *period1;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *period2;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *period3;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *periodOT;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *periodPS;

@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *offenseLine1;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *offenseLine2;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *offenseLine3;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *offenseLine4;

@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *defenseLine1;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *defenseLine2;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *defenseLine3;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *defenseLine4;

@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *homeStrength3;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *homeStrength4;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *homeStrength5;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *homeStrength6;

@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *awayStrength3;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *awayStrength4;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *awayStrength5;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterButton *awayStrength6;


//@property (readonly, strong, nonatomic, nullable) UIImage *tabImage;
//@property (strong, nonatomic, nullable) IBOutlet PxpFilterButtonScrollView *rightScrollView;
//@property (strong, nonatomic, nullable) IBOutlet PxpFilterButtonScrollView *middleScrollView;
//@property (strong, nonatomic, nullable) IBOutlet PxpFilterButtonScrollView *leftScrollView;
//@property (strong, nonatomic, nullable) IBOutlet UILabel *filteredTagLabel;
//@property (strong, nonatomic, nullable) IBOutlet UILabel *totalTagLabel;
//@property (strong, nonatomic, nullable) IBOutlet PxpFilterRangeSliderView *sliderView;

//Test rangeSlider

//@property (strong, nonatomic, nullable) RangeSlider *rangeSlider;

@end
