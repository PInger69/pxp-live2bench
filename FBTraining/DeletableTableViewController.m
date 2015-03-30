//
//  DeletableTableViewController.m
//  Live2BenchNative
//
//  Created by dev on 2015-03-05.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "DeletableTableViewController.h"
#import "SocialSharingManager.h"
#import "ShareOptionsViewController.h"

@interface DeletableTableViewController ()

@property (strong, nonatomic) UIPopoverController *sharePop;

@end


@implementation DeletableTableViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.deleteButton = [[UIButton alloc] init];
        self.deleteButton.backgroundColor = [UIColor redColor];
        [self.deleteButton addTarget:self action:@selector(deleteAllButtonTarget) forControlEvents:UIControlEventTouchUpInside];
        [self.deleteButton setTitle: @"Delete All" forState: UIControlStateNormal];
        [self.deleteButton.titleLabel setTextColor:[UIColor whiteColor]];
        [self.deleteButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [self.deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.deleteButton setFrame:CGRectMake(568, 768, 370, 0)];
        
        self.shareButton = [[UIButton alloc] init];
        self.shareButton.backgroundColor = [UIColor orangeColor];
        [self.shareButton addTarget:self action:@selector(shareAllButtonTarget) forControlEvents:UIControlEventTouchUpInside];
        [self.shareButton setTitle: @"Share All" forState: UIControlStateNormal];
        [self.shareButton.titleLabel setTextColor:[UIColor whiteColor]];
        [self.shareButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [self.shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.shareButton setFrame:CGRectMake(568, 768, 370, 0)];
        
        
        self.setOfDeletingCells = [[NSMutableSet alloc] init];
        self.setOfSharingCells = [[NSMutableSet alloc] init];
        //self.dictionaryOfObservers = [[NSMutableDictionary alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addDeletionCell:) name:@"AddDeletionCell" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeDeletionCell:) name:@"RemoveDeletionCell" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addSharingCell:) name:@"AddSharingCell" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeSharingCell:) name:@"RemoveSharingCell" object:nil];
        
        
    }
    
    return self;
}


-(void) addDeletionCell: (NSNotification *) aNotification{
    NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:aNotification.object];
    if(cellIndexPath) {
        [self.setOfDeletingCells addObject: cellIndexPath];
    }
    if (self.setOfDeletingCells.count >= 2){
        [self.parentViewController.view addSubview: self.deleteButton];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        self.deleteButton.frame = self.newFrame;
        [self.deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [UIView commitAnimations];
    }
}

-(void)removeDeletionCell: (NSNotification *) aNotification{
    NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:aNotification.object];
    if (cellIndexPath) {
        [self.setOfDeletingCells removeObject: cellIndexPath];
    }
    if (self.setOfDeletingCells.count < 2){
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        self.deleteButton.frame = self.originalFrame;
        [self.deleteButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        [UIView commitAnimations];
    }
    
}

-(void) addSharingCell: (NSNotification *) aNotification{
    NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:aNotification.object];
    if(cellIndexPath) {
        [self.setOfSharingCells addObject: cellIndexPath];
    }
    if (self.setOfSharingCells.count >= 2){
        [self.parentViewController.view addSubview: self.shareButton];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        self.shareButton.frame = self.newFrame;
        [self.shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [UIView commitAnimations];
    }
}

-(void)removeSharingCell: (NSNotification *) aNotification{
    NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:aNotification.object];
    if (cellIndexPath) {
        [self.setOfSharingCells removeObject: cellIndexPath];
    }
    if (self.setOfSharingCells.count < 2){
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        self.shareButton.frame = self.originalFrame;
        [self.shareButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        [UIView commitAnimations];
    }
    
}

-(void)checkDeleteAllButton{
    if (self.setOfDeletingCells.count < 2){
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        self.deleteButton.frame = self.originalFrame;
        [UIView commitAnimations];
    }
}

-(void)checkShareAllButton{
    if (self.setOfSharingCells.count < 2){
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        self.shareButton.frame = self.originalFrame;
        [UIView commitAnimations];
    }
}

-(void)shareAllButtonTarget{
    ShareOptionsViewController *shareOptions = [[ShareOptionsViewController alloc] initWithArray: [[SocialSharingManager commonManager] arrayOfSocialOptions] andIcons:[[SocialSharingManager commonManager] arrayOfIcons] andSelectedIcons: [[SocialSharingManager commonManager] arrayOfSelectedIcons]];
    self.sharePop = [[UIPopoverController alloc] initWithContentViewController:shareOptions];
    self.sharePop.popoverContentSize = CGSizeMake(280, 180);
    [self.sharePop presentPopoverFromRect:self.shareButton.frame inView:self.parentViewController.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    
}
-(void)deleteAllButtonTarget{
    CustomAlertView *alert = [[CustomAlertView alloc] init];
    [alert setTitle:@"myplayXplay"];
    [alert setMessage:@"Are you sure you want to delete all these tags?"];
    [alert setDelegate:self]; //set delegate to self so we can catch the response in a delegate method
    [alert addButtonWithTitle:@"Yes"];
    [alert addButtonWithTitle:@"No"];
    [alert show];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        self.editingIndexPath = indexPath;
        
        CustomAlertView *alert = [[CustomAlertView alloc] init];
        [alert setTitle:@"myplayXplay"];
        [alert setMessage:@"Are you sure you want to delete this tag?"];
        [alert setDelegate:self]; //set delegate to self so we can catch the response in a delegate method
        [alert addButtonWithTitle:@"Yes"];
        [alert addButtonWithTitle:@"No"];
        [alert show];
        
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if ([alertView.message isEqualToString:@"Are you sure you want to delete all these tags?"] && buttonIndex == 0) {
        NSMutableArray *indexPathsArray = [[NSMutableArray alloc]init];
        NSMutableArray *arrayOfTagsToRemove = [[NSMutableArray alloc]init];
        
        for (NSIndexPath *cellIndexPath in self.setOfDeletingCells) {
            [arrayOfTagsToRemove addObject:self.tableData[cellIndexPath.row]];
            [indexPathsArray addObject: cellIndexPath];
        }
        
        for (NSIndexPath *path in self.setOfDeletingCells) {
            if ([path isEqual:self.selectedPath]) {
                //NSDictionary *tag = self.tableData[self.selectedPath.row];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"removeInformation" object:nil];
                self.selectedPath = nil;
            }
        }
        
        for (NSDictionary *tag in arrayOfTagsToRemove) {
            [self.tableData removeObject:tag];
        }
        
        [self.setOfDeletingCells removeAllObjects];
        [self.tableView deleteRowsAtIndexPaths:indexPathsArray withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView reloadData];
        
    }else{
        if (buttonIndex == 0)
        {
            [self.tableData removeObjectAtIndex:self.editingIndexPath.row];
            [self removeIndexPathFromDeletion];
            [self.tableView deleteRowsAtIndexPaths:@[self.editingIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView reloadData];
        }
        else if (buttonIndex == 1)
        {
            // No, cancel the action to delete tags
        }
        
    }
    [CustomAlertView removeAlert:alertView];
    
    [self checkDeleteAllButton];
    //[self.tableView reloadData];
}

-(void)removeIndexPathFromDeletion{
    NSMutableSet *newIndexPathSet = [[NSMutableSet alloc]init];
    [self.setOfDeletingCells removeObject:self.editingIndexPath];
    if ([self.selectedPath isEqual:self.editingIndexPath]) {
        //NSDictionary *tag = self.tableData[self.selectedPath.row];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"removeInformation" object:self];
        self.selectedPath = nil;
    }
    if (self.selectedPath && self.selectedPath.row > self.editingIndexPath.row) {
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:self.selectedPath.row - 1 inSection: self.selectedPath.section];
        self.selectedPath = newIndexPath;
    }
    
    for (NSIndexPath *indexPath in self.setOfDeletingCells) {
        if (indexPath.row > self.editingIndexPath.row) {
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection: indexPath.section];
            [newIndexPathSet addObject: newIndexPath];
        }else{
            [newIndexPathSet addObject: indexPath];
        }
    }
    
    self.setOfDeletingCells = newIndexPathSet;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.tableData count];
}





- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.originalFrame = CGRectMake(self.tableView.frame.origin.x, 768, self.tableView.frame.size.width, 0);
    self.newFrame = CGRectMake(self.tableView.frame.origin.x, 700, self.tableView.frame.size.width, 68);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) reloadData{
    [self.tableView reloadData];
}

#pragma mark - Table view data source

/*
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
 
 // Configure the cell...
 
 return cell;
 }
 */

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end


