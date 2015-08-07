//
//  RangeModifierButton.h
//  Live2BenchNative
//
//  Created by dev on 9/8/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    RangeButtonExtendStart,
    RangeButtonExtendEnd,
} RangeButtonType;

@interface RangeModifierButton : UIButton

@property (assign, nonatomic) RangeButtonType type;

- (nonnull instancetype)initWithFrame:(CGRect)frame type:(RangeButtonType)type;

@end
