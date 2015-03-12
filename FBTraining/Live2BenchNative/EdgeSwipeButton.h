//
//  EdgeSwipeButton.h
//  Live2BenchNative
//
//  Created by Si Te Feng on 6/23/14.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, JPSwipeButtonType)
{
    JPSwipeButtonTypeRetract,
    JPSwipeButtonTypeRetain
};




@interface EdgeSwipeButton : UIControl <UIGestureRecognizerDelegate>
/*
 Subclass of UIView for the extra swiping function
 There is an invisibe part of the button that takes in pan gesture, then, 
 the visible part of the button appears into the screen in a similar manner as
 notification pane.
 
 Modification to "selected" property changes the left button light indicator color
 */
{
    UIView *   _lightIndicator;
    CGFloat    _originalPosition;
    CGFloat    _lastButtonImagePosition;
    
    CGFloat    _buttonImageOffset;
    
    UIColor*   _colorBeforeSwipe;
   
    CGFloat    _translationWhenActivated;
    BOOL       _translationWhenActIsSet;
    /////////////////////////////////
    
    UITapGestureRecognizer* _dismissTapRec;
    UIPanGestureRecognizer* _buttonPanRec;

}



@property (nonatomic, strong) UIImage* image;
@property (nonatomic, assign) JPSwipeButtonType type;


@property (nonatomic, strong, readonly) UIImageView* buttonImageView;


- (instancetype)initWithFrame:(CGRect)frame imageOffset: (CGFloat)offset;

- (void)bringUpButtonImage;
- (void)retractButtonImage;

@end
