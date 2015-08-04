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

IB_DESIGNABLE
@interface SeekButton : UIControl

@property (readonly, assign, nonatomic) CGFloat speed;
@property (readonly, assign, nonatomic) BOOL isOpen;

@property (assign, nonatomic) IBInspectable BOOL backward;
@property (assign, nonatomic) IBInspectable CGFloat margin;
@property (assign, nonatomic) IBInspectable CGFloat textNumber;
@property (assign, nonatomic) IBInspectable BOOL independent;

@property (strong, nonatomic, nonnull) NSArray *speeds;

+ (nonnull instancetype)makeForwardAt:(CGPoint)pt;
+ (nonnull instancetype)makeBackwardAt:(CGPoint)pt;
+ (nonnull instancetype)makeFullScreenForwardAt:(CGPoint)pt;
+ (nonnull instancetype)makeFullScreenBackwardAt:(CGPoint)pt;

- (nonnull instancetype)initWithFrame:(CGRect)frame backward:(BOOL)backward;
- (nonnull instancetype)initWithFrame:(CGRect)frame backward:(BOOL)backward margin:(CGFloat)margin;
- (nonnull instancetype)initWithFrame:(CGRect)frame backward:(BOOL)backward margin:(CGFloat)margin speeds:(nonnull NSArray *)speeds;

- (void)onPressSeekPerformSelector:(nullable SEL)sel addTarget:(nullable id)target;

@end
