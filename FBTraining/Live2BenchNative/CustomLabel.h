//
//  CustomLabel.h
//  Live2BenchNative
//
//  Created by Dev on 2013-09-20.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIFont+Default.h"

@interface CustomLabel : UILabel

typedef enum {
    CLStyleOrangeHeader = 1,
    CLStyleBlackHeader = 2,
    CLStyleWhiteHeader = 3,
    CLStyleOrange = 4,
    CLStyleBlack = 5,
    CLStyleWhite = 6,
    CLStyleGrey = 7
} CLStyleType;

+ (CustomLabel*)labelWithStyle:(CLStyleType)style;

-(void)setMargin:(CGRect)newMargin;


@end
