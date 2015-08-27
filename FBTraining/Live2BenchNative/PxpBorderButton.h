//
//  PxpBorderButton.h
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-10.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface PxpBorderButton : UIButton

@property (assign, nonatomic) IBInspectable CGFloat borderWidth;

- (nonnull instancetype)initWithFrame:(CGRect)frame borderWidth:(CGFloat)borderWidth;
- (nonnull instancetype)initWithBorderWidth:(CGFloat)borderWidth;

@end
