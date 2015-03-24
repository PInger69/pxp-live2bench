//
//  DeletableTableViewCell.m
//  Live2BenchNative
//
//  Created by dev on 2015-03-05.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "DeletableTableViewCell.h"

static CGFloat const kBounceValue = 10.0f;

@implementation DeletableTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

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
    [self.deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
    [self.deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.deleteButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [self.deleteButton setBackgroundColor:[UIColor redColor]];
    [self.contentView addSubview:self.deleteButton];
    [self.deleteButton addTarget:self action:@selector(deleteButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    self.shareButton = [[UIButton alloc] init];
    [self.shareButton setTitle:@"Share" forState:UIControlStateNormal];
    [self.shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.shareButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [self.shareButton setBackgroundColor:[UIColor orangeColor]];
    [self.contentView addSubview:self.shareButton];
    [self.shareButton addTarget:self action:@selector(shareButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:anExtraView];
    //[self.myContentView addSubview:self.deleteButton];
    
    NSArray *theConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[theView]-0-|" options:0 metrics:nil views:@{@"theView":self.myContentView}];
    [self.contentView addConstraints: theConstraints];
    self.contentViewLeftConstraint = theConstraints[0];
    self.contentViewRightConstraint = theConstraints[1];
    
    self.myContentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSArray *theConstraintsAgain = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[theView]-0-|" options:0 metrics:nil views:@{@"theView":self.myContentView}];
    [self.contentView addConstraints: theConstraintsAgain];
    
    self.myContentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.swipeRecognizerForDeleting =[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(panThisCellForDeleting:)];
    self.swipeRecognizerForDeleting.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.myContentView addGestureRecognizer:self.swipeRecognizerForDeleting];
    
    self.swipeRecognizerForSharing =[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(panThisCellForSharing:)];
    self.swipeRecognizerForSharing.direction = UISwipeGestureRecognizerDirectionRight;
    [self.myContentView addGestureRecognizer:self.swipeRecognizerForSharing];
    
}

-(void)prepareForReuse{
    [self resetConstraintContstantsToZero:NO notifyDelegateDidClose:NO];
    self.swipeRecognizerForDeleting.direction = UISwipeGestureRecognizerDirectionLeft;
    self.swipeRecognizerForSharing.direction = UISwipeGestureRecognizerDirectionRight;
}

-(void)setCellAsDeleting{
    [self setConstraintsToShowAllButtons:NO notifyDelegateDidOpen:NO];
    self.swipeRecognizerForDeleting.direction = UISwipeGestureRecognizerDirectionRight;
}


-(void)setCellAsSharing{
    [self setConstraintsToShowAllButtonsForSharing:NO notifyDelegateDidOpen:NO];
    self.swipeRecognizerForSharing.direction = UISwipeGestureRecognizerDirectionLeft;
}


- (void)panThisCellForDeleting:(UISwipeGestureRecognizer *)recognizer {
    recognizer.direction = self.swipeRecognizerForDeleting.direction;
    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
        [self.myContentView removeGestureRecognizer:self.swipeRecognizerForDeleting];
        self.swipeRecognizerForDeleting.direction = UISwipeGestureRecognizerDirectionRight;
        [self.myContentView addGestureRecognizer:self.swipeRecognizerForDeleting];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AddDeletionCell" object:self];
    }
    else
    {
        [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:YES];
        [self.myContentView removeGestureRecognizer:self.swipeRecognizerForDeleting];
        self.swipeRecognizerForDeleting.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.myContentView addGestureRecognizer:self.swipeRecognizerForDeleting];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveDeletionCell" object:self];
    }
}

- (void)panThisCellForSharing:(UISwipeGestureRecognizer *)recognizer {
    recognizer.direction = self.swipeRecognizerForSharing.direction;
    if (recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        [self setConstraintsToShowAllButtonsForSharing:YES notifyDelegateDidOpen:YES];
        [self.myContentView removeGestureRecognizer:self.swipeRecognizerForSharing];
        self.swipeRecognizerForSharing.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.myContentView addGestureRecognizer:self.swipeRecognizerForSharing];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AddSharingCell" object:self];
    }
    else
    {
        [self resetConstraintContstantsToZeroForSharing:YES notifyDelegateDidClose:YES];
        [self.myContentView removeGestureRecognizer:self.swipeRecognizerForSharing];
        self.swipeRecognizerForSharing.direction = UISwipeGestureRecognizerDirectionRight;
        [self.myContentView addGestureRecognizer:self.swipeRecognizerForSharing];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveSharingCell" object:self];
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

