//
//  DeletableTableViewCell.h
//  Live2BenchNative
//
//  Created by dev on 2015-03-05.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSInteger, cellState) {
    cellStateDeleting = 1<<1,
    cellStateSharing = 1<<2,
    cellStateNormal = 1<<3,
};



@interface DeletableTableViewCell : UITableViewCell

@property cellState cellState;

@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIButton *shareButton;

@property (nonatomic, strong) UISwipeGestureRecognizer *swipeRecognizerLeft;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeRecognizerRight;

@property (nonatomic, assign) CGFloat startingRightLayoutConstraintConstant;
@property (nonatomic, assign) CGFloat startingLeftLayoutConstraintConstant;

@property (nonatomic, weak) NSLayoutConstraint *contentViewRightConstraint;
@property (nonatomic, weak) NSLayoutConstraint *contentViewLeftConstraint;
@property (nonatomic, strong) UIView *myContentView;

@property (nonatomic, strong) void(^deleteBlock)(UITableViewCell * theCell);
@property (nonatomic, strong) void(^shareBlock)(UITableViewCell * theCell);

@property (nonatomic, assign) BOOL sharingEnabled;

-(void)setCellAccordingToState:(cellState)state;
-(void) setupView;

- (void)panThisCell:(UISwipeGestureRecognizer *)recognizer;

@end
