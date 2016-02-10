//
//  RicoPlayerGroupContainer.m
//  Live2BenchNative
//
//  Created by dev on 2016-02-08.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "RicoPlayerGroupContainer.h"

// This holds x players and when resized it change the size of all the subviews


@implementation RicoPlayerGroupContainer




-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    for (UIView * subview in self.subviews) {
        [subview setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
//        [subview.layer removeAllAnimations];
    }
}


@end
