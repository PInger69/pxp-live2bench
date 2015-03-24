//
//  DeletableTableViewCell.h
//  Live2BenchNative
//
//  Created by dev on 2015-03-05.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
//@protocol DeletableTableViewController <NSObject>
//
//@end


@interface DeletableTableViewCell : UITableViewCell

@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIButton *shareButton;

@property (nonatomic, strong) UISwipeGestureRecognizer *swipeRecognizerForDeleting;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeRecognizerForSharing;


@property (nonatomic, assign) CGFloat startingRightLayoutConstraintConstant;
@property (nonatomic, assign) CGFloat startingLeftLayoutConstraintConstant;

@property (nonatomic, weak) NSLayoutConstraint *contentViewRightConstraint;
@property (nonatomic, weak) NSLayoutConstraint *contentViewLeftConstraint;
@property (nonatomic, strong) UIView *myContentView;

@property (nonatomic, strong) void(^deleteBlock)(UITableViewCell * theCell);
@property (nonatomic, strong) void(^shareBlock)(UITableViewCell * theCell);

-(void) setCellAsDeleting;
-(void) setCellAsSharing;
-(void) setupView;


@end