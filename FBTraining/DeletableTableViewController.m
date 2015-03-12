//
//  DeletableTableViewController.m
//  Live2BenchNative
//
//  Created by dev on 2015-03-05.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "DeletableTableViewController.h"

@interface DeletableTableViewController ()

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
        
        self.setOfDeletingCells = [[NSMutableSet alloc] init];
        self.dictionaryOfObservers = [[NSMutableDictionary alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addDeletionCell:) name:@"AddDeletionCell" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeDeletionCell:) name:@"RemoveDeletionCell" object:nil];
        
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
        
        for (NSDictionary *tag in arrayOfTagsToRemove) {
            [self.tableData removeObject:tag];
        }
        
        [self.setOfDeletingCells removeAllObjects];
        [self.tableView deleteRowsAtIndexPaths:indexPathsArray withRowAnimation:UITableViewRowAnimationLeft];
        
    }else{
        if (buttonIndex == 0)
        {
            [self.tableData removeObjectAtIndex:self.editingIndexPath.row];
            [self.setOfDeletingCells removeObject: self.editingIndexPath];
            [self.tableView deleteRowsAtIndexPaths:@[self.editingIndexPath] withRowAnimation:UITableViewRowAnimationFade];
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

