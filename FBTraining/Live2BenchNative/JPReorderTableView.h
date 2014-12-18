//
//  JPReorderTableView.h
//  TripleSwipeTableDemo
//
//  Created by Si Te Feng on 8/5/14.
//  Copyright (c) 2014 Si Te Feng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JPTripleSwipeCell.h"


@protocol JPReorderTableViewDelegate, JPReorderTableViewDataSource;;

@interface JPReorderTableView : UITableView <UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate, JPTripleSwipeCellDelegate>
{
    UILongPressGestureRecognizer*  _longRec; //for moving cell
    UIPanGestureRecognizer*        _panRec;
    
    UILongPressGestureRecognizer*  _selectRec; //for selecting cell
    
    BOOL               _reorderingCell;

    NSIndexPath*       _draggingCellPath;
    UITableViewCell*   _draggingCell;
    UIImageView*       _draggingCellImg;
    
    
    NSIndexPath*       _dragStartIndexPath;
    NSIndexPath*       _dragEndIndexPath;
    
    NSIndexPath*       _currSelectedIndexPath;
    
    //////////////////////////////////
    BOOL       _cellSelectedInitialized;
}

@property (nonatomic, assign) BOOL tableViewType; //0-cell Custom Views,1-cellTitle

@property (nonatomic, strong) NSMutableArray* cellTitles;
@property (nonatomic, strong) NSMutableArray* cellCustomViews;
//array of NSNumber BOOL To indicate whether a specific row is selected
@property (nonatomic, strong) NSMutableArray* cellsSelected;

@property (nonatomic, weak) id<JPReorderTableViewDelegate> reorderDelegate;
@property (nonatomic, weak) id<JPReorderTableViewDataSource> reorderDataSource;

@property (nonatomic, assign) JPTripleSwipeCellSelection selectionType;



- (NSArray*)cellSelectionTypes;

- (void)deleteSelections;

- (void)selectAllCellsWithSelectionType:(JPTripleSwipeCellSelection)type;

- (NSArray*)selectedRows;


@end


@protocol JPReorderTableViewDelegate <NSObject>

@optional
- (void)reorderTableView: (JPReorderTableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath;

- (void)reorderTableView: (JPReorderTableView*)tableView accessoryButtonTappedForRowWithIndexPath: (NSIndexPath*)indexPath;


- (void)reorderTableView: (JPReorderTableView*)tableView selectionTypeChangedTo: (JPTripleSwipeCellSelection)type;

- (void)reorderTableView:(JPReorderTableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;

@end


@protocol JPReorderTableViewDataSource <NSObject>


- (NSInteger)reorderTableView:(JPReorderTableView *)tableView numberOfRowsInSection:(NSInteger)section;

@optional
- (NSString*)reordertableView: (JPReorderTableView*)tableView cellTitleForRowAtIndexPath: (NSIndexPath*)indexPath;

- (UITableViewCell*)reorderTableView: (JPReorderTableView*)tableView cellForRowAtIndexPath: (NSIndexPath*)indexPath;




@end









