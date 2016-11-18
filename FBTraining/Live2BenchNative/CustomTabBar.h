//
//  CustomTabBar.h
//  Live2BenchNative
//
//  Created by DEV on 2013-01-21.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"




@interface CustomTabBar : UITabBarController {

}


/**
 *  Select the tab at index "tabID"
 *
 *  @param tabID tabID
 */
-(void) selectTab:(NSInteger)tabID;


@end
