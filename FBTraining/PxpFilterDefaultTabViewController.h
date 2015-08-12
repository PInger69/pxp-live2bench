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
#import "PxpFilterUserButtons.h"
#import "PxpFilterRatingView.h"
#import "PxpFilterUserInputView.h"
#import "PxpFilterToggleButton.h"

@interface PxpFilterDefaultTabViewController: PxpFilterTabController

@property (readonly, strong, nonatomic, nullable) UIImage                   * tabImage;
@property (strong, nonatomic, nullable) IBOutlet PxpFilterButtonScrollView  * leftScrollView;
@property (strong, nonatomic, nullable) IBOutlet UILabel                    * filteredTagLabel;
@property (strong, nonatomic, nullable) IBOutlet UILabel                    * totalTagLabel;
@property (strong, nonatomic, nullable) IBOutlet PxpFilterRangeSliderView   * sliderView;
@property (strong, nonatomic, nullable) IBOutlet PxpFilterUserButtons       * userButtons;
@property (strong, nonatomic, nullable) IBOutlet PxpFilterRatingView        * ratingButtons;
@property (strong, nonatomic, nullable) IBOutlet PxpFilterUserInputView     * userInputView;
@property (strong, nonatomic, nullable) IBOutlet UISwitch                   * preFilterSwitch;
@property (strong, nonatomic, nullable) IBOutlet PxpFilterToggleButton      * favoriteButton;
@property (strong, nonatomic, nullable) IBOutlet PxpFilterToggleButton      * telestrationButton;


@end
