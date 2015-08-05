
//
//  ListTableViewController.h
//  Live2BenchNative
//
//  Created by dev on 2015-02-18.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeletableTableViewController.h"
#import "Tag.h"

#define BUTTON_HEIGHT   125
#define POP_WIDTH       200

#define CELL_HEIGHT                  155//172
#define LABEL_HEIGHT                 40
#define LABEL_WIDTH                 100
#define TABLE_WIDTH                 460
#define TABLE_HEIGHT                620//575

#define NOTIF_CELL_SELECTED        @"cell selected"

@interface ListTableViewController : DeletableTableViewController

//@property (strong, nonatomic) NSMutableArray *tagsToDisplay;
@property (assign, nonatomic) BOOL isEditable;
@property (strong, nonatomic) NSIndexPath *previouslySelectedIndexPath;
@property (strong, nonatomic) NSMutableArray *arrayOfCollapsableIndexPaths;
- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath;

@end
