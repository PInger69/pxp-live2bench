//
//  PxpFilterMyClipTabViewController.h
//  Live2BenchNative
//
//  Created by dev on 2015-08-14.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpFilterTabController.h"
#import "PxpFilterButtonScrollView.h"
#import "PxpFilterUserButtons.h"
#import "PxpFilterRatingView.h"
#import "PxpFilterToggleButton.h"
#import "PxpFilterModuleDelegate.h"

@interface PxpFilterMyClipTabViewController : PxpFilterTabController <PxpFilterModuleDelegate>

@property (strong, nonatomic, nullable) IBOutlet PxpFilterButtonScrollView  * eventScrollView;
@property (strong, nonatomic, nullable) IBOutlet PxpFilterButtonScrollView  * teamsScrollView;
@property (strong, nonatomic, nullable) IBOutlet PxpFilterButtonScrollView  * playersScrollView;
@property (strong, nonatomic, nullable) IBOutlet PxpFilterButtonScrollView  * dateScrollView;
@property (strong, nonatomic, nullable) IBOutlet UILabel                    * filteredTagLabel;
@property (strong, nonatomic, nullable) IBOutlet UILabel                    * totalTagLabel;
@property (strong, nonatomic, nullable) IBOutlet PxpFilterRatingView        * ratingButtons;
//@property (strong, nonatomic, nullable) IBOutlet PxpFilterToggleButton      * favoriteButton;



@end
