//
//  FilterTabViewController.h
//  Live2BenchNative
//
//  Created by dev on 7/23/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterTab.h"
@interface FilterTabViewController : UIViewController


- (id)initWithFrame:(CGRect)frame;
-(FilterTab *)getCurrentTab;
-(void)setCurrentTab:(NSString*)tabName;
-(void)addTabList:(NSArray*)tabList;
-(void)inputArray:(NSArray*)list;
-(void)onSelectPerformSelector:(SEL)sel addTarget:target;
-(NSArray *)currentTabProcessedList;
-(NSArray*)invokedComponentNames;
-(NSArray*)prefilteredList;
@end
