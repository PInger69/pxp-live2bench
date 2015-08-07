//
//  PxpRangeModifierButton.h
//  Live2BenchNative
//
//  Created by dev on 9/8/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface PxpRangeModifierButton : UIButton

@property (assign, nonatomic) IBInspectable BOOL end;

- (nonnull instancetype)initWithFrame:(CGRect)frame end:(BOOL)end;

@end
