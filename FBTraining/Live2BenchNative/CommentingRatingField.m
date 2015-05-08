//
//  CommentingRatingField.m
//  QuickTest
//
//  Created by dev on 6/16/2014.
//  Copyright (c) 2014 dev. All rights reserved.
//

#import "CommentingRatingField.h"

#define RATING_BOX_HEIGHT 50
#define BUTTON_TOP_MARGIN 5
#define TOP_OFFSET 22

@implementation CommentingRatingField
{
    UIView * ratingBox;
}
@synthesize ratingScale;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setGraphics:frame];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame title:(NSString *)title
{
    self = [super initWithFrame:frame title:title];
    if (self) {
        [self setGraphics:frame];
    }
    return self;
}


/**
 *  This is adding and modifying the graphic layout of the inherataed layout.
 *
 *  @param frame max frame size that all graphics will be adjusted to
 */
-(void)setGraphics:(CGRect)frame
{
    
    textField.frame = CGRectMake( 0, TOP_OFFSET,
                                 frame.size.width,
                                 frame.size.height-RATING_BOX_HEIGHT-BUTTON_TOP_MARGIN-clearButton.frame.size.height- TOP_OFFSET );
    
    fieldTitle.frame = CGRectMake( 0, 0, fieldTitle.frame.size.width, fieldTitle.frame.size.height);
    
    ratingBox = [[UIView alloc]initWithFrame:CGRectMake(
                                                        0,
                                                        textField.frame.size.height+ textField.frame.origin.y-1 ,
                                                        textField.frame.size.width,
                                                        RATING_BOX_HEIGHT)];
    ratingBox.layer.borderColor = textField.layer.borderColor;
    ratingBox.layer.borderWidth = textField.layer.borderWidth;
    [self addSubview:ratingBox];
    
    ratingScale = [[RatingInput alloc]initWithFrame:CGRectMake(0, 0,320, 30)];

    [self addSubview:ratingScale];
    ratingScale.center = ratingBox.center;
    
    clearButton.frame   = CGRectMake(   clearButton.frame.origin.x,
                                     ratingBox.frame.origin.y + ratingBox.frame.size.height + BUTTON_TOP_MARGIN,
                                     clearButton.frame.size.width,
                                     clearButton.frame.size.height );
    saveButton.frame    = CGRectMake(   saveButton.frame.origin.x,
                                     ratingBox.frame.origin.y + ratingBox.frame.size.height + BUTTON_TOP_MARGIN,
                                     saveButton.frame.size.width,
                                     saveButton.frame.size.height );
    
    saveMessage.center = textField.center;
    
}

/**
 *  If set to NO/FALSE this will stop all tap events and alpha out the instance. Setting to YES/TRUE will enable all buttons and set alpha to f1.0
 *
 *  @param val Boolean
 */
-(void)setEnabled:(BOOL) val
{
    super.enabled = ratingScale.enabled = val;
}

/**
 *  Selector to be run when any star buttons are tapped into
 *
 *  @param sel    method you want run when tapped
 *  @param target object that contains the method
 */
-(void)onPressRatePerformSelector:(SEL)sel addTarget:(id)target
{
    [ratingScale onPressRatePerformSelector:sel addTarget:target];
}

-(void)clear
{
    //    [ratingScale setRating:0];
    [super clear];
}

@end
