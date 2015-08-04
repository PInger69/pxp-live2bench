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
    UITabBar *_mainTabBar;
}

@property (nonatomic, retain) PxpFilter *pxpFilter;

@property (nonatomic, retain) IBOutlet UITabBar *mainTabBar;

@property (nonatomic, retain) NSArray *tabs;

//@property (nonatomic, strong) UISwipeGestureRecognizer *rightSwipGestureRecognizer;
//@property (nonatomic, strong) UISwipeGestureRecognizer *leftSwipGestureRecognizer;

@end
