//
//  DeletableTableViewController.h
//  Live2BenchNative
//
//  Created by dev on 2015-03-05.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeletableTableViewCell.h"




@interface DeletableTableViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *tableData;
@property (strong, nonatomic) NSIndexPath *editingIndexPath;
@property (strong, nonatomic) NSMutableSet *setOfDeletingCells;
@property (strong, nonatomic) NSMutableSet *setOfSharingCells;
@property (strong, nonatomic) UIButton *deleteButton;
@property (strong, nonatomic) UIButton *shareButton;
@property (strong, nonatomic) NSString *contextString;
@property (nonatomic, assign) BOOL swipeableMode;

//@property (strong, nonatomic) NSMutableDictionary *dictionaryOfObservers;

@property (assign, nonatomic) CGRect originalFrame;
@property (assign, nonatomic) CGRect newFrame;

@property (strong, nonatomic) NSIndexPath *selectedPath;
//@property (strong, nonatomic) NSIndexPath *previouslySelectedIndexPath;

//- (void)addObserverForCell:(id)cell atIndexPath:(NSIndexPath *)indexPath;

-(void)removeIndexPathFromDeletion;
-(void)checkDeleteAllButton;
-(void)checkShareAllButton;
-(void) reloadData;
@end

