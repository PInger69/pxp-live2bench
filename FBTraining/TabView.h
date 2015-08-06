//
//  TabView.h
//  Test12
//
//  Created by colin on 7/29/15.
//  Copyright (c) 2015 Cezary Wojcik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxpFilter.h"
#import "PxpFilterTabController.h"

@interface TabView : UIViewController<UITabBarDelegate> {
    UITabBar *_mainTabBar;
}

@property (strong, nonatomic, nullable) PxpFilter *pxpFilter;

@property (strong, nonatomic, nullable) IBOutlet UITabBar *mainTabBar;

@property (strong, nonatomic, nullable) NSArray *tabs;

- (nonnull instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil tabs:(nullable NSArray *)tabs;

- (void)addTab:(nonnull PxpFilterTabController*) newTab;
- (BOOL)removeTab:(nonnull PxpFilterTabController*) tabToRemove;

@end
