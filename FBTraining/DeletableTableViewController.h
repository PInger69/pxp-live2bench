//
//  DeletableTableViewController.h
//  Live2BenchNative
//
//  Created by dev on 2015-03-05.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <UIKit/UIKit.h>

@interface DeletableTableViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *tableData;
@property (strong, nonatomic) NSIndexPath *editingIndexPath;
@property (strong, nonatomic) NSMutableSet *setOfDeletingCells;
@property (strong, nonatomic) UIButton *deleteButton;

@property (strong, nonatomic) NSMutableDictionary *dictionaryOfObservers;

@property (assign, nonatomic) CGRect originalFrame;
@property (assign, nonatomic) CGRect newFrame;

//- (void)addObserverForCell:(id)cell atIndexPath:(NSIndexPath *)indexPath;

-(void)checkDeleteAllButton;
-(void) reloadData;
@end

