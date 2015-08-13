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
#import "PxpFilterButtonView.h"

@interface PxpFilterHockeyTabViewController : PxpFilterTabController

@property (strong, nonatomic,nullable) IBOutlet PxpFilterButtonScrollView *tagNameScrollView;
@property (strong, nonatomic,nullable) IBOutlet UILabel *totalTagLabel;
@property (strong, nonatomic,nullable) IBOutlet UILabel *filteredTagLabel;
@property (strong, nonatomic,nullable) IBOutlet PxpFilterRangeSliderView *sliderView;
@property (strong, nonatomic,nullable) IBOutlet UISwitch *preFilterSwitch;
@property (strong, nonatomic,nullable) IBOutlet UIView *periodView;




//@property (readonly, strong, nonatomic, nullable) UIImage *tabImage;
//@property (strong, nonatomic, nullable) IBOutlet PxpFilterButtonScrollView *rightScrollView;
//@property (strong, nonatomic, nullable) IBOutlet PxpFilterButtonScrollView *middleScrollView;
//@property (strong, nonatomic, nullable) IBOutlet PxpFilterButtonScrollView *leftScrollView;
//@property (strong, nonatomic, nullable) IBOutlet UILabel *filteredTagLabel;
//@property (strong, nonatomic, nullable) IBOutlet UILabel *totalTagLabel;
//@property (strong, nonatomic, nullable) IBOutlet PxpFilterRangeSliderView *sliderView;

//Test rangeSlider

@property (strong, nonatomic, nullable) RangeSlider *rangeSlider;

@end
