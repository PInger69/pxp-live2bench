//
//  DeletableTableViewCell.m
//  Live2BenchNative
//
//  Created by dev on 2015-03-05.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "DeletableTableViewCell.h"

static CGFloat const kBounceValue = 15.0f;

@implementation DeletableTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)deleteButtonPressed{
    self.deleteBlock(self);
}

- (void)shareButtonPressed{
    self.shareBlock(self);
}

- (void)setupView
{
    UIView *anExtraView = [UIView new];
    anExtraView.backgroundColor = [UIColor whiteColor];
    
    self.myContentView = anExtraView;
    
    self.deleteButton = [[UIButton alloc] init];
    [self.deleteButton setTitle:NSLocalizedString(@"Delete",nil) forState:UIControlStateNormal];
    [self.deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.deleteButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [self.deleteButton setBackgroundColor:[UIColor redColor]];
    [self.contentView addSubview:self.deleteButton];
    [self.deleteButton addTarget:self action:@selector(deleteButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    self.shareButton = [[UIButton alloc] init];
    [self.shareButton setTitle:NSLocalizedString(@"Share",nil) forState:UIControlStateNormal];
    [self.shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.shareButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [self.shareButton setBackgroundColor:PRIMARY_APP_COLOR];
    [self.contentView addSubview:self.shareButton];
    [self.shareButton addTarget:self action:@selector(shareButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:anExtraView];
    
    NSArray *theConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[theView]-0-|" options:0 metrics:nil views:@{@"theView":self.myContentView}];
    [self.contentView addConstraints: theConstraints];
    self.contentViewLeftConstraint = theConstraints[0];
    self.contentViewRightConstraint = theConstraints[1];
    
    self.myContentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSArray *theConstraintsAgain = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[theView]-0-|" options:0 metrics:nil views:@{@"theView":self.myContentView}];
    [self.contentView addConstraints: theConstraintsAgain];
    
    self.myContentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    //    self.swipeRecognizerForDeleting =[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(panThisCellForDeleting:)];
    //    self.swipeRecognizerForDeleting.direction = UISwipeGestureRecognizerDirectionLeft;
    //    [self.myContentView addGestureRecognizer:self.swipeRecognizerForDeleting];
    //
    //    self.swipeRecognizerForSharing =[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(panThisCellForSharing:)];
    //    self.swipeRecognizerForSharing.direction = UISwipeGestureRecognizerDirectionRight;
    //    [self.myContentView addGestureRecognizer:self.swipeRecognizerForSharing];
    
    self.cellState = cellStateNormal;
    self.swipeRecognizerLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(panThisCell:)];
    self.swipeRecognizerLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    self.swipeRecognizerRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(panThisCell:)];
    self.swipeRecognizerRight.direction = UISwipeGestureRecognizerDirectionRight;
    for (UISwipeGestureRecognizer *previous in self.myContentView.gestureRecognizers) {
        [self.myContentView removeGestureRecognizer:previous];
    }
    [self.myContentView addGestureRecognizer:self.swipeRecognizerLeft];
    [self.myContentView addGestureRecognizer:self.swipeRecognizerRight];
}

-(void)prepareForReuse{
    [self.swipeRecognizerRight setEnabled:YES];
    [self.swipeRecognizerLeft setEnabled:YES];
}



-(void)setCellAccordingToState:(cellState)state {
    switch (state) {
        case cellStateNormal:
            if (self.cellState == cellStateDeleting) {
                [self resetConstraintContstantsToZero:NO notifyDelegateDidClose:NO];
            }
            if (self.cellState == cellStateSharing) {
                [self resetConstraintContstantsToZeroForSharing:NO notifyDelegateDidClose:NO];
            }
            self.cellState = state;
            break;
        case cellStateDeleting:
            [self setConstraintsToShowAllButtons:NO notifyDelegateDidOpen:NO];
            self.cellState = state;
            break;
        case cellStateSharing:
            [self setConstraintsToShowAllButtonsForSharing:NO notifyDelegateDidOpen:NO];
            self.cellState = state;
            break;
        default:
            break;
    }
}

- (void)panThisCell:(UISwipeGestureRecognizer *)recognizer {
    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        switch (self.cellState) {
            case cellStateNormal:
                [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"AddDeletionCell" object:self];
                self.cellState = cellStateDeleting;
                break;
            case cellStateSharing:
                [self resetConstraintContstantsToZeroForSharing:YES notifyDelegateDidClose:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveSharingCell" object:self];
                self.cellState = cellStateNormal;
            default:
                break;
        }
    } else {
        switch (self.cellState) {
            case cellStateNormal:
                if (!self.sharingEnabled) {
                    break;
                }
                [self setConstraintsToShowAllButtonsForSharing:YES notifyDelegateDidOpen:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"AddSharingCell" object:self];
                self.cellState = cellStateSharing;
                break;
            case cellStateDeleting:
                [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveDeletionCell" object:self];
                self.cellState = cellStateNormal;
            default:
                break;
        }
    }
}

- (CGFloat)buttonTotalWidthForDeleting {
    return CGRectGetWidth(self.deleteButton.frame);
}
- (CGFloat)buttonTotalWidthForSharing {
    return CGRectGetWidth(self.shareButton.frame);
}


- (void)resetConstraintContstantsToZero:(BOOL)animated notifyDelegateDidClose:(BOOL)endEditing
{
    if (self.startingRightLayoutConstraintConstant == 0 &&
        self.contentViewRightConstraint.constant == 0) {
        //Already all the way closed, no bounce necessary
        return;
    }
    
    self.contentViewRightConstraint.constant = -kBounceValue;
    self.contentViewLeftConstraint.constant = kBounceValue;
    
    [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
        self.contentViewRightConstraint.constant = 0;
        self.contentViewLeftConstraint.constant = 0;
        
        [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
            self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant;
        }];
    }];
}
- (void)resetConstraintContstantsToZeroForSharing:(BOOL)animated notifyDelegateDidClose:(BOOL)endEditing
{
    if (self.startingLeftLayoutConstraintConstant == 0 &&
        self.contentViewLeftConstraint.constant == 0) {
        //Already all the way closed, no bounce necessary
        return;
    }
    
    self.contentViewRightConstraint.constant = kBounceValue;
    self.contentViewLeftConstraint.constant = -kBounceValue;
    
    [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
        self.contentViewRightConstraint.constant = 0;
        self.contentViewLeftConstraint.constant = 0;
        
        [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
            self.startingLeftLayoutConstraintConstant = self.contentViewLeftConstraint.constant;
        }];
    }];
}




- (void)setConstraintsToShowAllButtons:(BOOL)animated notifyDelegateDidOpen:(BOOL)notifyDelegate
{
    
    if (self.startingRightLayoutConstraintConstant == [self buttonTotalWidthForDeleting] &&
        self.contentViewRightConstraint.constant == [self buttonTotalWidthForDeleting]) {
        return;
    }
    self.contentViewLeftConstraint.constant = -[self buttonTotalWidthForDeleting] - kBounceValue;
    self.contentViewRightConstraint.constant = [self buttonTotalWidthForDeleting] + kBounceValue;
    
    [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
        
        self.contentViewLeftConstraint.constant = -[self buttonTotalWidthForDeleting];
        self.contentViewRightConstraint.constant = [self buttonTotalWidthForDeleting];
        
        [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
            
            self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant;
        }];
    }];
}

- (void)setConstraintsToShowAllButtonsForSharing:(BOOL)animated notifyDelegateDidOpen:(BOOL)notifyDelegate
{
    
    if (self.startingLeftLayoutConstraintConstant == [self buttonTotalWidthForSharing] &&
        self.contentViewLeftConstraint.constant == [self buttonTotalWidthForSharing]) {
        return;
    }
    self.contentViewRightConstraint.constant = -[self buttonTotalWidthForSharing] - kBounceValue;
    self.contentViewLeftConstraint.constant = [self buttonTotalWidthForSharing] + kBounceValue;
    
    [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
        
        self.contentViewLeftConstraint.constant = [self buttonTotalWidthForSharing];
        self.contentViewRightConstraint.constant = -[self buttonTotalWidthForSharing];
        
        [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
            
            self.startingLeftLayoutConstraintConstant = self.contentViewLeftConstraint.constant;
        }];
    }];
}




- (void)updateConstraintsIfNeeded:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    float duration = 0;
    if (animated) {
        duration = 0.1;
    }
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self layoutIfNeeded];
    } completion:completion];
}


@end

