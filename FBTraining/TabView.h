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

+(TabView*)sharedFilterTab;


@property (strong, nonatomic, nullable) PxpFilter *pxpFilter;

@property (strong, nonatomic, nullable) IBOutlet UITabBar *mainTabBar;

@property (strong, nonatomic, nullable) NSArray *tabs;

- (nonnull instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil tabs:(nullable NSArray *)tabs;

@end
