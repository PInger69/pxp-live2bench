//
//  CommentingRatingField.h
//  QuickTest
//
//  Created by dev on 6/16/2014.
//  Copyright (c) 2014 dev. All rights reserved.
//

#import "CommentingField.h"
#import "RatingInput.h"

@interface CommentingRatingField : CommentingField

@property (strong,nonatomic) RatingInput * ratingScale;


-(void)onPressRatePerformSelector:(SEL)sel addTarget:(id)target;

@end
