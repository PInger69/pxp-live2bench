//
//  StatsTabViewController.h
//  Live2BenchNative
//
//  Created by Si Te Feng on 7/15/14.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TabBarButton.h"

@interface StatsTabViewController : UITabBarController
{
    NSDictionary* tabAttributes;
    NSDictionary* tabSelectedAttributes;
    
    UIBarButtonItem *flex;
    UIBarButtonItem *fix;
}


@property (nonatomic, strong) UIBarButtonItem* statsButton;
@property (nonatomic, strong) UIBarButtonItem* importButton;


@property (nonatomic, strong) UIToolbar*  customTabBar;
@property (nonatomic, strong) NSMutableArray*  barButtonItems;

@property (strong,nonatomic) TabBarButton * sectionTab;
-(void)setMainSectionTab:(NSString*)name imageName:(NSString*)imgName;

@end
