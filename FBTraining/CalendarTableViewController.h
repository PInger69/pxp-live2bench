//
//  CalendarTableTableViewController.h
//  Live2BenchNative
//
//  Created by dev on 2015-02-23.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalendarTableViewController : UITableViewController

@property (strong, nonatomic) NSArray *gamesToDisplay;
@property (assign, nonatomic) int context;

@end
