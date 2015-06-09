//
//  RangeModifierButton.m
//  Live2BenchNative
//
//  Created by dev on 9/8/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "RangeModifierButton.h"

@implementation RangeModifierButton
#define LITTLE_ICON_DIMENSIONS       30
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        [self setContentMode:UIViewContentModeScaleAspectFill];
        [self setImage:[UIImage imageNamed:@"extendstartsec.png"] forState:UIControlStateNormal];
//        [self addTarget:self action:@selector(startRangeBeenModified:) forControlEvents:UIControlEventTouchUpInside];
//        [startRangeModifierButton setAccessibilityValue:@"extend"];
        
//        UILongPressGestureRecognizer *modifiedTagDurationByStartTimeLongpressgesture = [[UILongPressGestureRecognizer alloc]
//                                                                                        initWithTarget:self action:@selector(changeDurationModifierButtonIcon:)];
//        modifiedTagDurationByStartTimeLongpressgesture.minimumPressDuration = 0.5; //seconds
//        modifiedTagDurationByStartTimeLongpressgesture.delegate = self;
//        [startRangeModifierButton addGestureRecognizer:modifiedTagDurationByStartTimeLongpressgesture];
    }
    return self;
}



@end
