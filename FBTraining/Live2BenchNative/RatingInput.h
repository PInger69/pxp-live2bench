//
//  RatingInput.h
//  Live2BenchNative
//
//  Created by dev on 6/12/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RatingInput : UIView
{
    int rating;
    BOOL enabled;
}
@property (assign, nonatomic)   int rating;
@property (nonatomic,assign)    BOOL enabled;
@property (nonatomic, strong)   UILabel *ratingLabel;

-(void)onPressRatePerformSelector:(SEL)sel addTarget:(id)target;

@end
