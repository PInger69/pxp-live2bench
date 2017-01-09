//
//  CustomTabViewController.h
//  Live2BenchNative
//
//  Created by dev on 9/26/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TabBarButton.h"
#import "AppDelegate.h"

@interface CustomTabViewController : UIViewController
{
    AppDelegate * _appDel;
}

@property (strong,nonatomic) TabBarButton   * sectionTab;
@property (strong,nonatomic) NSString       * name;

-(id)initWithAppDelegate:(AppDelegate *) appDel;
-(void)setMainSectionTab:(NSString*)name imageName:(NSString*)imgName;
-(void)onAppTerminate:(NSNotification *)note;

@end
