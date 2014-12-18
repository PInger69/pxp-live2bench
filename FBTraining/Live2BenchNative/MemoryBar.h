//
//  MemoryBar.h
//  QuickTest
//
//  Created by dev on 6/16/2014.
//  Copyright (c) 2014 dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIFont+Default.h"


@interface MemoryBar : UIView
{
    UIView *totalBar;
    UILabel *memoryLabel;
    UIView *fullBar;
    UILabel *fullLabel;
}


/**
 *  This will update all instances of MemoryBar in the porject
 */
+(void)update;

/**
 *  this will update the graphics
 */
-(void)update;
@end
