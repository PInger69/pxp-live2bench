//
//  BookmarkTableViewController.m
//  Live2BenchNative
//
//  Created by dev on 2015-03-04.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "BookmarkTableViewController.h"
#import "BookmarkViewcell.h"
#import "Utility.h"
#import "Clip.h"
#import "SocialSharingManager.h"
#import "ShareOptionsViewController.h"

@interface BookmarkTableViewController ()
@property (strong, nonatomic) UILongPressGestureRecognizer *longPressRecognizer;
@property (strong, nonatomic) UIPopoverController *sharePop;


@end

@implementation BookmarkTableViewController

-(instancetype)init{
    self = [super init];
    if (self){
        [self.tableView registerClass:[BookmarkViewCell class] forCellReuseIdentifier:@"BookmarkViewCell"];
        self.longPressRecognizer = [[UILongPressGestureRecognizer alloc] init];
        [self.tableView addGestureRecognizer: self.longPressRecognizer];
        self.longPressRecognizer.minimumPressDuration = 0.7;
        [self.longPressRecognizer addTarget:self action:@selector(longPressDetected:)];
        
        //[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        
    }
    return self;
}

-(void) longPressDetected: (UILongPressGestureRecognizer *) longPress{
    NSLog(@"%@", longPress);
    if(longPress.state == UIGestureRecognizerStateBegan){
        if (!self.editing) {
            [self setEditing:YES animated:YES];
        }else if(self.editing){
            [self setEditing:NO animated:NO];
        }
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 1;
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    // Force your tableview margins (this may be a bad idea)
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //[self.tableView setContentSize:CGSizeMake(self.tableView.frame.size.width, [self.tableData count] * 44)];
    // Return the number of rows in the section.
    return [self.tableData count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    BookmarkViewCell *selectedCell = (BookmarkViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    Clip *clip = [self.tableData objectAtIndex:indexPath.row];
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SET_PLAYER_FEED_IN_MYCLIP object:nil userInfo:@{@"forFeed":@{@"context":STRING_MYCLIP_CONTEXT,
                                                                                                                                 @"feed": clip,
                                                                                                                                 @"time":[clip.rawData objectForKey:@"starttime"],
                                                                                                                                 @"duration":[clip.rawData objectForKey:@"duration"],
                                                                                                                                 @"comment":[clip.rawData objectForKey:@"comment"]},
                                                                                                                                 @"forWhole":clip.rawData}];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"tagSelected" object:self userInfo: clip];
    if(![indexPath isEqual:self.selectedPath])
    {
        selectedCell.translucentEditingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, selectedCell.frame.size.width, selectedCell.frame.size.height)];
        [selectedCell.translucentEditingView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [selectedCell.translucentEditingView setBackgroundColor: [UIColor colorWithRed:255/255.0f green:206/255.0f blue:119/255.0f alpha:1.0f]];
        [selectedCell.translucentEditingView setAlpha:0.3];
        [selectedCell.translucentEditingView setUserInteractionEnabled:FALSE];
        [selectedCell addSubview:selectedCell.translucentEditingView];
        
        BookmarkViewCell *lastSelectedCell = (BookmarkViewCell*)[self.tableView cellForRowAtIndexPath: self.selectedPath];
        [lastSelectedCell.backgroundView setBackgroundColor:[UIColor colorWithWhite:0.95f alpha:1.0f]];
        [lastSelectedCell.backgroundView setBackgroundColor:[UIColor whiteColor]];
        [lastSelectedCell.translucentEditingView removeFromSuperview];
        
        
        self.selectedPath = indexPath;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BookmarkViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BookmarkViewCell" forIndexPath:indexPath];
    Clip *clip = self.tableData[indexPath.row];
    
    
    
    [cell.eventDate setText: [Utility dateFromEvent: clip.rawData[@"event"]]];
    [cell.tagTime setText: clip.rawData[ @"displaytime"]];
    [cell.tagName setText: [clip.name stringByRemovingPercentEncoding] ];
    [cell.indexNum setText: [NSString stringWithFormat:@"%i",indexPath.row + 1]];
    
    
    
    cell.deleteBlock = ^(UITableViewCell *cell){
        NSIndexPath *aIndexPath = [self.tableView indexPathForCell:cell];
        [self tableView:self.tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:aIndexPath];
    };
    
    cell.shareBlock = ^(UITableViewCell *cell){
        ShareOptionsViewController *shareOptions = [[ShareOptionsViewController alloc] initWithArray: [[SocialSharingManager commonManager] arrayOfSocialOptions] andIcons:[[SocialSharingManager commonManager] arrayOfIcons] andSelectedIcons: [[SocialSharingManager commonManager] arrayOfSelectedIcons]];
        UIPopoverController *sharePop = [[UIPopoverController alloc] initWithContentViewController:shareOptions];
        sharePop.popoverContentSize = CGSizeMake(280, 180);
        BookmarkViewCell *cellCasted = (BookmarkViewCell *)cell;
        [sharePop presentPopoverFromRect: cellCasted.shareButton.frame inView: cell permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
        self.sharePop = sharePop;
    };
    
    //This is the condition where a cell that is selected is reused
    if (cell.translucentEditingView) {
        [cell.translucentEditingView removeFromSuperview];
        cell.translucentEditingView = nil;
    }
    
    
    // This condition is if the user is scrolling up and down and the
    // cell is selected
    if ([self.selectedPath isEqual:indexPath]) {
        cell.translucentEditingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
        [cell.translucentEditingView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [cell.translucentEditingView setBackgroundColor: [UIColor colorWithRed:255/255.0f green:206/255.0f blue:119/255.0f alpha:1.0f]];
        [cell.translucentEditingView setAlpha:0.3];
        [cell.translucentEditingView setUserInteractionEnabled:FALSE];
        [cell addSubview:cell.translucentEditingView];
        
    }
    
    if ([self.setOfDeletingCells containsObject:indexPath]) {
        [cell setCellAccordingToState:cellStateDeleting];
    }else if ([self.setOfSharingCells containsObject:indexPath]){
        [cell setCellAccordingToState:cellStateSharing];
    } else {
        [cell setCellAccordingToState:cellStateNormal];
    }
    
    //cell.editingAccessoryType = UI
    //cell.deleteButton.hidden = YES;
    //cell.accessoryType = UITableViewCellAccessoryCheckmark;
    // Configure the cell...
    
    //self.tableView.editing = YES;
    
    return cell;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear: animated];
    //[self setEditing:YES animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    if(self.editing){
        return YES;
    }
    return NO;
}



//// Override to support editing the table view.
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        // Delete the row from the data source
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//    }
//}



// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    NSDictionary *trans = [self.tableData objectAtIndex:fromIndexPath.row];
    [self.tableData removeObjectAtIndex:fromIndexPath.row];
    [self.tableData insertObject:trans atIndex:toIndexPath.row];
    [self.tableView reloadData];
    
}



// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
