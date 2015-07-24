//
//  TablePopoverController.m
//  Live2BenchNative
//
//  Created by dev on 2015-01-06.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "TablePopoverController.h"
#import "AutoScrollLabel.h"
#import "UIFont+Default.h"


#pragma mark - Helper


@protocol TablePopoverControllerDelegate
- (void)dismissPopover;
@end

@interface PopTableController : UITableViewController
{
}
@property (nonatomic,strong)    NSArray                             * dataList;
@property (nonatomic,strong)    NSMutableArray                      * onCompletionBlocks;
@property (nonatomic,strong)      id<TablePopoverControllerDelegate>  delegate;


-(void)addOnCompletionBlock:(void (^)(NSString*pick))blockName;

@end



@implementation PopTableController

@synthesize dataList            = _dataList;
@synthesize onCompletionBlocks  = _onCompletionBlocks;
@synthesize delegate            = _delegate;

-(id)init
{
    self = [super init];
    if (self) {
        _dataList               = @[];
        _onCompletionBlocks     = [[NSMutableArray alloc]init];
    }
    return self;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataList count];
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[_dataList objectAtIndex:indexPath.row]];

    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell   = [tableView cellForRowAtIndexPath:indexPath];
    NSString * nameSelected = cell.textLabel.text;
    
    for ( void (^aBlock)(NSString*pick) in _onCompletionBlocks) {
        aBlock(nameSelected);
    }
    if (_delegate) [_delegate dismissPopover];
}




-(void)addOnCompletionBlock:(void (^)(NSString*pick))aBlock
{
    [_onCompletionBlocks addObject:aBlock];
}




@end




#pragma mark - End of Helper

@interface TablePopoverController () <TablePopoverControllerDelegate>
@end


@implementation TablePopoverController
{
PopTableController * myTableViewController;
    NSArray * dataList;
}

@synthesize userPick = _userPick;
@synthesize animateDismiss      = _animateDismiss;
@synthesize animatePresent      = _animatePresent;

- (id)init
{
    self = [super initWithContentViewController:myTableViewController];
    if (self) {
        myTableViewController   = [[PopTableController alloc]init];
        myTableView                     = [[UITableView alloc] initWithFrame:myTableViewController.view.bounds style:UITableViewStylePlain];
        myTableView.backgroundColor     = [UIColor whiteColor];
        [myTableView setSeparatorInset:UIEdgeInsetsMake(0.0f, 15.0f, 0.0f, 15.0f)];
        myTableViewController.view      = myTableView;

        myTableViewController.dataList  = dataList;
        [myTableView setDataSource:myTableViewController];
        [myTableView setDelegate:myTableViewController];
        myTableViewController.delegate  = self;
        _animateDismiss                 = YES;
        _animatePresent                 = NO;

    }
    return self;
}

-(void)presentPopoverFromRect:(CGRect)rect inView:(UIView *)view permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated
{
    
    [super presentPopoverFromRect:rect inView:view permittedArrowDirections:arrowDirections animated:animated];
 [myTableView reloadData];
}

// clears list and adds new table items
-(void)populateWith:(NSArray*)aList
{
    [self clear];
    NSArray             * list = [aList sortedArrayUsingSelector:@selector(compare:)];

    myTableViewController.dataList = list;
    
    [myTableView reloadData];
}

// when a table item is selected run the block with the picked string
-(void)addOnCompletionBlock:(void (^)(NSString*pick))blockName
{
    [myTableViewController addOnCompletionBlock:blockName];
}

// clear list
-(void)clear
{
    myTableViewController.dataList = @[];
    [myTableViewController.onCompletionBlocks removeAllObjects];
    [myTableView reloadData];
}


-(void)dismissPopover
{
    [self dismissPopoverAnimated:_animateDismiss];
}


@end
