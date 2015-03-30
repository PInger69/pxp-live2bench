//
//  RatingInput.m
//  Live2BenchNative
//
//  Created by dev on 6/12/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "RatingInput.h"
#define DISABLE_ALPHA 0.5f
#import "UIFont+Default.h" // should this be added to the common file

#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

/**
 *  This is a Rating Input that allows the user to select a rating that will also execute a selector if one has been assigend
 *  The recommended sizing for this scale should be width 270 and height 30
 */
@implementation RatingInput
{
    //UILabel *ratingLabel;
    NSMutableArray * ratingButtonArray;
    SEL onRateSelector;
    id rateTarget;
    
}

static int MAX = 5;
static int STAR_SIZE = 20;
static UIImage* rateSelected;
static UIImage* rateUnSelected;


@synthesize rating = _rating;
@synthesize enabled;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        enabled = TRUE;
        if (!rateSelected){
            UIImage *image = [UIImage imageNamed:@"rating_selected.png"];
            rateSelected = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            rateUnSelected = [UIImage imageNamed:@"rating_unselected.png"];
        }
        
        
        ratingButtonArray = [[NSMutableArray alloc]init];
        
        // this makes the text field
        _ratingLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 60 , 25)];
        [_ratingLabel setTextAlignment:NSTextAlignmentRight];
        [_ratingLabel setText:@"Rating"];
        [_ratingLabel setFont:[UIFont defaultFontOfSize:18.0f]];
        
        [_ratingLabel setTextColor:[UIColor darkGrayColor]];//[UIColor blackColor]
        [self addSubview:_ratingLabel];
        
        // this make each button
        for(int i = 0;i<MAX;i++) {
            UIButton *ratingButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [ratingButton setFrame:CGRectMake(110 + 40*i, 3, STAR_SIZE,STAR_SIZE)];
            [ratingButton setImage:rateUnSelected forState:UIControlStateNormal];
            ratingButton.tag = i;
            [ratingButton.imageView setContentMode:UIViewContentModeScaleAspectFit]; /// can this be applied to the image it self ??
            [ratingButton addTarget:self action:@selector(sendRating:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:ratingButton];
            [ratingButtonArray addObject:ratingButton];
        }
        
    }
    return self;
}



/**
 *  Set the rating and highlight the corospoiding stars
 *  you have the range of 0-5. If a selector has be declared then it will be executed
 *
 *  @param sender star button
 */
-(void)sendRating:(id)sender{
    UIButton *button = (UIButton*)sender;
    int index = button.tag;
    
    if (self.rating == 1 && index == 0){
        [button setImage:rateUnSelected forState:UIControlStateNormal];
        self.rating = 0;
    } else  {
        self.rating =index+1;
    }
    
    if (onRateSelector){
        [rateTarget performSelector:onRateSelector withObject:self];
    }
}



/**
 *  When a star is pressed run this selector
 *
 *  @param sel    method to be run
 *  @param target object that contains the method
 */
-(void)onPressRatePerformSelector:(SEL)sel addTarget:(id)target
{
    rateTarget = target;
    onRateSelector = sel;
}


// Getter Setter
-(int)rating
{
    return _rating;
}



-(void)setRating:(int)rate
{
    if (rate <0){
        _rating = 0;
    } else if (rate > MAX) {
        _rating = MAX;
    } else {
        _rating = rate;
    }
    
    for(UIButton* starButt in ratingButtonArray) {
        [starButt setImage:rateUnSelected forState:UIControlStateNormal];
    }
    
    for (int i = 0; i < _rating; i++) {
        UIButton *cbutton = [ratingButtonArray objectAtIndex:i];
        [cbutton setImage:rateSelected forState:UIControlStateNormal];
        
    }
}


-(BOOL)enabled
{
    return enabled;
}

-(void)setEnabled:(BOOL) val
{
    if (val && !enabled){
        for(UIButton* starButt in ratingButtonArray) {
            [starButt setUserInteractionEnabled:TRUE];
            
        }
        [self setAlpha: 1.0f];
        self.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
    } else if (!val && enabled) {
        for(UIButton* starButt in ratingButtonArray) {
            [starButt setUserInteractionEnabled:FALSE];
        }
        [self setAlpha: DISABLE_ALPHA];
        self.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
    }
    enabled = val;
}

-(void)tintColorDidChange {
    [super tintColorDidChange];
}



@end
