//
//  TabView.h
//  Test12
//
//  Created by colin on 7/29/15.
//  Copyright (c) 2015 Cezary Wojcik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxpFilter.h"

@interface TabView : UIViewController<UITabBarDelegate> {
    UITabBar *_mainTabBar;
}

@property (strong, nonatomic) PxpFilter *pxpFilter;

@property (strong, nonatomic) IBOutlet UITabBar *mainTabBar;

@property (strong, nonatomic) NSArray *tabs;

@end
