//
//  JPReorderTableView.m
//  TripleSwipeTableDemo
//
//  Created by Si Te Feng on 8/5/14.
//  Copyright (c) 2014 Si Te Feng. All rights reserved.
//

#import "JPReorderTableView.h"
#import "JPTripleSwipeCell.h"
#import "JPReorderHelper.h"
//#import "JPStyle.h"


static NSString* const kTripleSwipeCellIdentifier = @"TripleSwipeCellReuseIdentifier";

static NSString* const kReorderTableViewTag = @"213";
static NSString* const kTableSelectRecognizerTag = @"214";

@implementation JPReorderTableView


- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    self.separatorInset = UIEdgeInsetsMake(0.0f, 15.0f, 0.0f, 15.0f);
    
    self.dataSource = self;
    self.delegate = self;
    [self registerClass:[JPTripleSwipeCell class] forCellReuseIdentifier:kTripleSwipeCellIdentifier];
    
    //Setup iVars
    _reorderingCell = NO;
    self.tableViewType = NO;
    
    _longRec = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(reorderingToggled:)];
    _longRec.delegate = self;
    _longRec.accessibilityValue = kReorderTableViewTag;
    [self addGestureRecognizer:_longRec];
    
    _panRec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(tableCellPanned:)];
    _panRec.delegate = self;
    _longRec.accessibilityValue = kReorderTableViewTag;
    [self addGestureRecognizer:_panRec];


    return self;
}


- (void)reorderingToggled: (UILongPressGestureRecognizer*)longRec
{
    if(longRec.state == UIGestureRecognizerStateBegan)
    {
        _reorderingCell = YES;
        
        [self cancelGestureRecognizer:_selectRec];
        
        CGPoint longPressLocation = [longRec locationInView:self];
        if(longPressLocation.y <= 0)
            longPressLocation = CGPointMake(longPressLocation.x, 1.0f);
        
        _draggingCellPath = [self indexPathForRowAtPoint:longPressLocation];
        _dragStartIndexPath = _draggingCellPath;
        _draggingCell = [self cellForRowAtIndexPath:_draggingCellPath];
        
        [self reloadRowsAtIndexPaths:@[_draggingCellPath] withRowAnimation:UITableViewRowAnimationNone];
        
        //Adding Dragging Cell Img to Table View
        _draggingCellImg = [[UIImageView alloc] initWithFrame:_draggingCell.frame];
        _draggingCellImg.clipsToBounds = NO;
//        _draggingCellImg.image = [imageFromView(_draggingCell) imageWithAlpha:0.9];
        
        [self addSubview:_draggingCellImg];
        
        [UIView animateWithDuration:0.5 animations:^{
            _draggingCellImg.center = CGPointMake(_draggingCellImg.center.x, longPressLocation.y);
            _draggingCellImg.layer.shadowOffset = CGSizeMake(0, 4);
            _draggingCellImg.layer.shadowOpacity = 0.5;
            _draggingCellImg.layer.shadowRadius = 5;
        }];
        
    }
    else if(longRec.state == UIGestureRecognizerStateEnded)
    {
        _reorderingCell = NO;
        
        _draggingCellPath = nil;
        _draggingCell = nil;
        [_draggingCellImg removeFromSuperview];
        _draggingCellImg = nil;
        
        CGPoint longPressLocation = [longRec locationInView:self];
        _dragEndIndexPath = [self indexPathForRowAtPoint:longPressLocation];
        
        if([self.reorderDelegate respondsToSelector:@selector(reorderTableView:moveRowAtIndexPath:toIndexPath:)])
            [self.reorderDelegate reorderTableView:self moveRowAtIndexPath:_dragStartIndexPath toIndexPath:_dragEndIndexPath];
        
        [self reloadData];
        
    }
    
}


- (void)tableCellPanned: (UIPanGestureRecognizer*)panRec
{
    if(_reorderingCell && panRec.state == UIGestureRecognizerStateChanged)
    {
        CGPoint panLocation = [panRec locationInView:self];
        
        _draggingCellImg.center = CGPointMake(_draggingCellImg.center.x, panLocation.y) ;
        
        //Replace the cell underneath;
        NSIndexPath* cellPath = [self indexPathForRowAtPoint:panLocation]; //New
        
        if(cellPath.row != _draggingCellPath.row)
        {
            id cellTitleToBeSwitched = nil;
            id selectedCellTitle = nil;
            if(self.tableViewType == NO)
            {
                cellTitleToBeSwitched= [self.cellCustomViews objectAtIndex:cellPath.row];
                selectedCellTitle = [self.cellCustomViews objectAtIndex:_draggingCellPath.row];
                [self.cellCustomViews replaceObjectAtIndex:_draggingCellPath.row withObject:cellTitleToBeSwitched];
                [self.cellCustomViews replaceObjectAtIndex:cellPath.row withObject:selectedCellTitle];
            }
            else
            {
                cellTitleToBeSwitched= [self.cellTitles objectAtIndex:cellPath.row];
                selectedCellTitle = [self.cellTitles objectAtIndex:_draggingCellPath.row];
                [self.cellTitles replaceObjectAtIndex:_draggingCellPath.row withObject:cellTitleToBeSwitched];
                [self.cellTitles replaceObjectAtIndex:cellPath.row withObject:selectedCellTitle];
            }
            id newValue = [self.cellsSelected objectAtIndex:cellPath.row];
            id oldValue = [self.cellsSelected objectAtIndex:_draggingCellPath.row];
            [self.cellsSelected replaceObjectAtIndex:_draggingCellPath.row withObject:newValue];
            [self.cellsSelected replaceObjectAtIndex:cellPath.row withObject:oldValue];
            
            //Currently Selected Row in Table View
            if(_currSelectedIndexPath.row == _draggingCellPath.row)
                _currSelectedIndexPath = cellPath;
            else if(_currSelectedIndexPath.row == cellPath.row)
                _currSelectedIndexPath = _draggingCellPath;
            
            _draggingCellPath = cellPath;
            [self reloadDataInternally];
        }
    }
}


#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    if([self.reorderDataSource respondsToSelector:@selector(reorderTableView:numberOfRowsInSection:)])
    {
        NSInteger rows = [self.reorderDataSource reorderTableView:self numberOfRowsInSection:0];
//        NSLog(@"rows: %d", rows);
        return rows;
    }
    
    return 0;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JPTripleSwipeCell* cell = [self dequeueReusableCellWithIdentifier:kTripleSwipeCellIdentifier];
    
    cell.indexPath = indexPath;
    cell.delegate = self;
    
    //If cell is picked up to reorder, make the space below empty
    if(_reorderingCell && indexPath.row == _draggingCellPath.row && indexPath.section == _draggingCellPath.section) {
        cell.cellRect = [self rectForRowAtIndexPath:indexPath];
        cell.shouldShowInfoButton = NO;
        return cell;
    }
    
    //CUSTOM MODIFICATIONS
    //////////////////////////////////

    if(self.tableViewType == NO) //Custom Views
    {
        UIView* customView = self.cellCustomViews[indexPath.row];
        
        cell.customView = customView;
    }
    else
    {
        cell.mainLabel.text = self.cellTitles[indexPath.row];
    }
    
    //////////////////////////////////
    //END OF CUSTOM MODIFICATIONS

    if(_currSelectedIndexPath.row == indexPath.row)
    {
        cell.customView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.03];;
    }
    
    cell.cellRect = [self rectForRowAtIndexPath:indexPath];
    
    NSNumber* selected = NO;
    if([self.cellsSelected count] > indexPath.row)
        selected = [self.cellsSelected objectAtIndex:indexPath.row];
    
    if([selected boolValue])
        cell.selectionType = self.selectionType;
    else {
        cell.selectionType = JPTripleSwipeCellSelectionNone;
    }
    
    return cell;
    
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _currSelectedIndexPath = indexPath;
    
    if([self.reorderDelegate respondsToSelector:@selector(reorderTableView:didSelectRowAtIndexPath:)])
        [self.reorderDelegate reorderTableView:self didSelectRowAtIndexPath:indexPath];
    
    [self reloadData];
}



#pragma mark - Gesture Recognizer Delegate Methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if(!_reorderingCell)
    {
        return YES;
    }
    else if(_reorderingCell && [otherGestureRecognizer.accessibilityValue isEqual:kReorderTableViewTag])
    {
        return YES;
    }
    else {
        return NO;
    }
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if([gestureRecognizer.accessibilityValue isEqual: kTableSelectRecognizerTag] && _reorderingCell)
        return NO;
    else
        return YES;
}


#pragma mark - Convenience Methods


- (void)cancelGestureRecognizer: (UIGestureRecognizer*)rec
{
    rec.enabled = NO;
    rec.enabled = YES;
}



#pragma mark - JP Triple Swipe Cell Delegate

- (void)cellSelectedAtIndexPath: (NSIndexPath*)indexPath withSelectionType: (JPTripleSwipeCellSelection)type
{
    if(type == self.selectionType)
    {
        if(type == JPTripleSwipeCellSelectionNone)
        {
        }
        else
        {
            [self.cellsSelected replaceObjectAtIndex:indexPath.row withObject:@YES];
        }
        
    }
    else //Table Type Change
    {
        if(self.selectionType == JPTripleSwipeCellSelectionNone)
        {
            self.selectionType = type;
            [self.cellsSelected replaceObjectAtIndex:indexPath.row withObject:@YES];
        }
        else
        {
            JPTripleSwipeCell* cell = (JPTripleSwipeCell*)[self cellForRowAtIndexPath:indexPath];
            [cell setSelectionType:JPTripleSwipeCellSelectionNone animated:YES];
            
            [self.cellsSelected replaceObjectAtIndex:indexPath.row withObject:@NO];
            
            BOOL allDeselected = YES;
            for(NSNumber* selected in self.cellsSelected)
            {
                if([selected boolValue])
                {
                    allDeselected = NO;
                }
            }
            if(allDeselected)
                self.selectionType = JPTripleSwipeCellSelectionNone;
            
        }
    }
}


//Assumed To Be Section 1
- (void)selectAllCellsWithSelectionType:(JPTripleSwipeCellSelection)type
{
    for(int i= 0; i< [self numberOfRowsInSection:0]; i++)
    {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        
        if(type != JPTripleSwipeCellSelectionNone)
        {
            JPTripleSwipeCell* cell = (JPTripleSwipeCell*)[self cellForRowAtIndexPath:indexPath];
            [cell setSelectionType:type];
            [self.cellsSelected replaceObjectAtIndex:indexPath.row withObject:@YES];
        }
        else
        {
            [self.cellsSelected replaceObjectAtIndex:indexPath.row withObject:@NO];
        }
    }
    self.selectionType = type;
    [self reloadData];
}


//FOR TRIPLE SWIPE CELL ONLY
- (void)cellPressed: (NSIndexPath*)indexPath
{
    if(!_reorderingCell)
    {
        if([self respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)])
            [self tableView:self didSelectRowAtIndexPath:indexPath];
    }
}


- (void)cellInfoButtonPressed:(NSIndexPath *)indexPath
{
    if(!_reorderingCell)
    {
        if([self.reorderDelegate respondsToSelector:@selector(reorderTableView:accessoryButtonTappedForRowWithIndexPath:)]){
            [self.reorderDelegate reorderTableView:self accessoryButtonTappedForRowWithIndexPath:indexPath];
        }
    }
}



#pragma mark - Public Methods

- (NSArray*)cellSelectionTypes
{
    NSMutableArray* selectionTypes = [NSMutableArray array];
    
    for(int i= 0; i< [self.cellTitles count]; i++)
    {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        JPTripleSwipeCell* cell = (JPTripleSwipeCell*)[self cellForRowAtIndexPath:indexPath];
        [selectionTypes addObject:[NSNumber numberWithInteger:cell.selectionType]];
    }
    
    return selectionTypes;
}



- (void)deleteSelections
{
    NSInteger count = [self.cellsSelected count];
    
    NSMutableArray* newCellsSelectedArray = [NSMutableArray array];
    NSMutableArray* newCellsTitlesArray = [NSMutableArray array];
    
    for(int i=0; i<count; i++)
    {
        NSNumber* selection = [self.cellsSelected objectAtIndex:i];
        if(![selection boolValue])
        {
            [newCellsSelectedArray addObject:[self.cellsSelected objectAtIndex:i]];
            [newCellsTitlesArray addObject:[self.cellTitles objectAtIndex:i]];
        }
    }
    
    self.cellsSelected = newCellsSelectedArray;
    self.cellTitles = newCellsTitlesArray;
    
    if([self.cellTitles count] == 0)
        self.selectionType = JPTripleSwipeCellSelectionNone;
    
    [self reloadData];
}


- (void)reloadData
{
    if(!_cellSelectedInitialized)
    {
        self.cellsSelected = [NSMutableArray array];
        
        NSInteger rows = 0;
        
        if([self.reorderDataSource respondsToSelector:@selector(reorderTableView:numberOfRowsInSection:)]) {
            rows = [self.reorderDataSource reorderTableView:self numberOfRowsInSection:0];
        }
        for(int i=0 ;i<rows;i++)
        {
            [self.cellsSelected addObject:@NO];
        }
        
        _cellSelectedInitialized = YES;
    }
    
    //////////////////////////////////////////////////////////////////
    //Other Data
    self.cellCustomViews = [NSMutableArray array];
    self.cellTitles = [NSMutableArray array];
    
    NSInteger rows = 0;
    
    if([self.reorderDataSource respondsToSelector:@selector(reorderTableView:numberOfRowsInSection:)])
    {
        rows = [self.reorderDataSource reorderTableView:self numberOfRowsInSection:0];
    }
    
    for(int i=0 ;i<rows;i++)
    {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        
        if([self.reorderDataSource respondsToSelector:@selector(reorderTableView:cellForRowAtIndexPath:)] && self.tableViewType == NO)
        {
            UITableViewCell* regularCell = [self.reorderDataSource reorderTableView:self cellForRowAtIndexPath:indexPath];
            [_cellCustomViews addObject:regularCell];
        }
        else if([self.reorderDataSource respondsToSelector:@selector(reordertableView:cellTitleForRowAtIndexPath:)] && self.tableViewType == YES)
        {
            NSString* cellTitle = [self.reorderDataSource reordertableView:self cellTitleForRowAtIndexPath:indexPath];
            [_cellTitles addObject:cellTitle];
        }
    }

    [super reloadData];
}


- (void)reloadDataInternally
{
    [super reloadData];
    
}


#pragma mark - Setter Methods

- (void)setSelectionType:(JPTripleSwipeCellSelection)selectionType
{
    _selectionType = selectionType;
    
    if([self.reorderDelegate respondsToSelector:@selector(reorderTableView:selectionTypeChangedTo:)])
    {
        [self.reorderDelegate reorderTableView:self selectionTypeChangedTo:selectionType];
    }
}



#pragma mark - Getter Methods

- (NSArray*)selectedRows
{
    NSMutableArray* selectedRows = [NSMutableArray array];
    
    for(int i=0; i< [self.cellsSelected count]; i++)
    {
        NSNumber* selected = self.cellsSelected[i];
        
        if([selected boolValue] == YES)
        {
            [selectedRows addObject:[NSNumber numberWithInt:i]];
        }
    }
    
    return selectedRows;
}






@end




