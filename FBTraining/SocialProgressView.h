//
//  SocialProgressView.h
//  Live2BenchNative
//
//  Created by dev on 2015-03-18.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SocialProgressView : UIView

@property (assign, nonatomic) int tasksToComplete;
@property (assign, nonatomic) int tasksCompleted;

@property (strong, nonatomic) UILabel *taskLabel;
@property (strong, nonatomic) UILabel *countLabel;


@end
