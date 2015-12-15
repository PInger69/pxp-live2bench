//
//  AnalyzeTabViewController.h
//  Live2BenchNative
//
//  Created by dev on 2015-12-10.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "CustomTabViewController.h"

@interface AnalyzeTabViewController : CustomTabViewController

extern NSString * const AnalyzeWillProcessTagNotification;
extern NSString * const AnalyzeWillPlayClipNotification;
extern NSString * const AnalyzeDidFinishLoadingSetNotification;

@end
