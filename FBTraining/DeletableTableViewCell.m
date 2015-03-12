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
    
    self.swipeRecognizer =[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(panThisCell:)];
    self.swipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.myContentView addGestureRecognizer:self.swipeRecognizer];
    
}

-(void)prepareForReuse{
    [self resetConstraintContstantsToZero:NO notifyDelegateDidClose:NO];
    self.swipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
}

-(void)setCellAsDeleting{
    [self setConstraintsToShowAllButtons:NO notifyDelegateDidOpen:NO];
    self.swipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
}


- (void)panThisCell:(UISwipeGestureRecognizer *)recognizer {
    recognizer.direction = self.swipeRecognizer.direction;
    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
        [self.myContentView removeGestureRecognizer:self.swipeRecognizer];
        self.swipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
        [self.myContentView addGestureRecognizer:self.swipeRecognizer];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AddDeletionCell" object:self];
    }
    else
    {
        [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:YES];
        [self.myContentView removeGestureRecognizer:self.swipeRecognizer];
        self.swipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.myContentView addGestureRecognizer:self.swipeRecognizer];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveDeletionCell" object:self];
    }
    
}


- (CGFloat)buttonTotalWidth {
    return CGRectGetWidth(self.deleteButton.frame);
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


- (void)setConstraintsToShowAllButtons:(BOOL)animated notifyDelegateDidOpen:(BOOL)notifyDelegate
{
    
    if (self.startingRightLayoutConstraintConstant == [self buttonTotalWidth] &&
        self.contentViewRightConstraint.constant == [self buttonTotalWidth]) {
        return;
    }
    self.contentViewLeftConstraint.constant = -[self buttonTotalWidth] - kBounceValue;
    self.contentViewRightConstraint.constant = [self buttonTotalWidth] + kBounceValue;
    
    [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
        
        self.contentViewLeftConstraint.constant = -[self buttonTotalWidth];
        self.contentViewRightConstraint.constant = [self buttonTotalWidth];
        
        [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
            
            self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant;
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
