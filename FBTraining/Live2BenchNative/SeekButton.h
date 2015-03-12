//
//  SeekButton.h
//  QuickTest
//
//  Created by dev on 6/16/2014.
//  Copyright (c) 2014 dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomButton.h"
typedef enum : NSUInteger {
    SEEK_DIRECTION_LEFT,
    SEEK_DIRECTION_RIGHT
    
} Direction;
@interface SeekButton : UIView <UIGestureRecognizerDelegate>

@property (nonatomic,assign)    float speed;

+(id)makeForwardAt:(CGPoint)pt;
+(id)makeBackwardAt:(CGPoint)pt;
+(id)makeFullScreenForwardAt:(CGPoint)pt;
+(id)makeFullScreenBackwardAt:(CGPoint)pt;

/**
 *  This preforms a selector when ever you tap on any of the buttons in this seeker are tapped
 *  
 *  Usage:
 *  -(void)seekerMethod:(id)theSeekerItSelf
 *  {
 *      NSLog(@"Speed is: %f ",((SeekButton*)theSeekerItSelf).speed);
 *  }
 *
 *  @param sel    method to run
 *  @param target object that contains method
 */
-(void)onPressSeekPerformSelector:(SEL)sel addTarget:(id)target;

-(BOOL)isOpen;
@end
