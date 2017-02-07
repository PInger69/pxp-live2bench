//
//  BookmarkTableViewController.h
//  Live2BenchNative
//
//  Created by dev on 2015-03-04.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeletableTableViewController.h"

@interface BookmarkTableViewController : DeletableTableViewController
@property (strong,nonatomic) UILabel * progress;
-(BOOL) playNext;
-(BOOL) playPrevious;

@end
