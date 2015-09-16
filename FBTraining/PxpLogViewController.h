//
//  PxpLogViewController.h
//  Live2BenchNative
//
//  Created by dev on 2015-04-24.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AppDelegate;

@interface PxpLogViewController : UIViewController <UITextViewDelegate>

-(instancetype) initWithAppDelegate: (AppDelegate *) appDel;

@end
