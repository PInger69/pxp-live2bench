//
//  NumberedSeekerButton.h
//  QuickTest
//
//  Created by dev on 6/19/2014.
//  Copyright (c) 2014 dev. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface NumberedSeekerButton : UIButton

@property (assign, nonatomic) IBInspectable BOOL backward;
@property (assign, nonatomic) IBInspectable CGFloat textNumber;

- (nonnull instancetype)initWithFrame:(CGRect)frame backward:(BOOL)backward;

@end
