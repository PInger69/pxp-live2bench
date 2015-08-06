//
//  ViewController.h
//  Test12
//
//  Created by colin on 7/29/15.
//  Copyright (c) 2015 colin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxpFilterTabController.h"
#import "PxpFilterButtonScrollView.h"
#import "PxpFilterRangeSliderView.h"
#import "RangeSlider.h"

@interface PxpFilterDefaultTabViewController: PxpFilterTabController

@property (readonly, strong, nonatomic, nullable) UIImage *tabImage;
@property (strong, nonatomic, nullable) IBOutlet PxpFilterButtonScrollView *rightScrollView;
@property (strong, nonatomic, nullable) IBOutlet PxpFilterButtonScrollView *middleScrollView;
@property (strong, nonatomic, nullable) IBOutlet PxpFilterButtonScrollView *leftScrollView;
@property (strong, nonatomic, nullable) IBOutlet UILabel *filteredTagLabel;
@property (strong, nonatomic, nullable) IBOutlet UILabel *totalTagLabel;
@property (strong, nonatomic, nullable) IBOutlet PxpFilterRangeSliderView *sliderView;

//Test rangeSlider

@end
