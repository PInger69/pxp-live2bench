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

@interface PxpFilterFootballTabViewController : PxpFilterTabController

@property (strong, nonatomic, nullable) IBOutlet UILabel *filteredTagLabel;
@property (strong, nonatomic, nullable) IBOutlet UILabel *totalTagLabel;
@property (strong, nonatomic, nullable) IBOutlet PxpFilterButtonView *leftButtonView;
@property (strong, nonatomic, nullable) IBOutlet PxpFilterUserInputView *middleUserInputView;

@end
