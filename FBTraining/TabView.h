//
//  TabView.h
//  CWPopupDemo
//
//  Created by colin on 7/29/15.
//  Copyright (c) 2015 Cezary Wojcik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxpFilter.h"

@interface TabView : UIViewController<UITabBarDelegate> {
    UITabBar *mainTabBar;
    NSMutableDictionary *tabs; //view controller of all tabs
}

@property (nonatomic, retain) PxpFilter *pxpFilter;

@property (nonatomic, retain) IBOutlet UITabBar *mainTabBar;

@property (nonatomic, retain) NSMutableDictionary *tabs;

@end
