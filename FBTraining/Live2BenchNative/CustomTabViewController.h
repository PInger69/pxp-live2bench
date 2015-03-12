//
//  CustomTabViewController.h
//  Live2BenchNative
//
//  Created by dev on 9/26/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TabBarButton.h"

@class AppDelegate;
@interface CustomTabViewController : UIViewController
{
    AppDelegate * _appDel;
//    id <UIApplicationDelegate > mainAppDelegate;
}

@property (strong,nonatomic) TabBarButton   * sectionTab;
@property (strong,nonatomic) NSString       * name;

-(id)initWithAppDelegate:(AppDelegate *) appDel;
//-(id)initWithAppDelegate:(id<UIApplicationDelegate >) mainappDelegate;
-(void)setMainSectionTab:(NSString*)name imageName:(NSString*)imgName;

@end
