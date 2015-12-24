//
//  DeletableTableViewController.m
//  Live2BenchNative
//
//  Created by dev on 2015-03-05.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "DeletableTableViewController.h"
#import "CustomAlertControllerQueue.h"


@interface DeletableTableViewController ()

@property (strong, nonatomic) UIPopoverController *sharePop;
//@property (strong, nonatomic) id previousOne;

@end


@implementation DeletableTableViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.deleteButton = [[UIButton alloc] init];
        self.deleteButton.backgroundColor = [UIColor redColor];
        [self.deleteButton addTarget:self action:@selector(deleteAllButtonTarget) forControlEvents:UIControlEventTouchUpInside];
        [self.deleteButton setTitle:NSLocalizedString(@"Delete All", nil)  forState: UIControlStateNormal];
        [self.deleteButton.titleLabel setTextColor:[UIColor whiteColor]];
        [self.deleteButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [self.deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.deleteButton setFrame:CGRectMake(568, 768, 370, 0)];
        
        /*
        self.shareButton = [[UIButton alloc] init];
        self.shareButton.backgroundColor = PRIMARY_APP_COLOR;
        [self.shareButton addTarget:self action:@selector(shareAllButtonTarget) forControlEvents:UIControlEventTouchUpInside];
        [self.shareButton setTitle:NSLocalizedString(@"Share All", nil) forState: UIControlStateNormal];
        [self.shareButton.titleLabel setTextColor:[UIColor whiteColor]];
        [self.shareButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [self.shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.shareButton setFrame:CGRectMake(568, 768, 370, 0)];
         */
        
        self.setOfDeletingCells = [[NSMutableSet alloc] init];
        self.setOfSharingCells = [[NSMutableSet alloc] init];
        //self.dictionaryOfObservers = [[NSMutableDictionary alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addDeletionCell:)     name:@"AddDeletionCell"     object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeDeletionCell:)  name:@"RemoveDeletionCell"  object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addSharingCell:)      name:@"AddSharingCell"      object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeSharingCell:)   name:@"RemoveSharingCell"   object:nil];
        
        self.swipeableMode = YES;
    }
    
    return self;
}

-(void)setSwipeableMode:(BOOL)swipeableMode{
    _swipeableMode = swipeableMode;
    
    for (DeletableTableViewCell *cell in self.tableView.visibleCells){
        if ([cell isKindOfClass:[DeletableTableViewCell class]]){
            cell.swipeRecognizerRight.enabled = swipeableMode;
            cell.swipeRecognizerLeft.enabled = swipeableMode;
        }
    }
    
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
    //    if ([self.contextString isEqualToString:@"TAG"]) {
    //        if (self.setOfDeletingCells.count < 1) {
    //            self.downloadEnabled = YES;
    //            [self reloadData];
    //        }
    //    }
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

-(void)checkDownloadButton {
    if (self.setOfDeletingCells.count < 2) {
        
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

-(void)shareOptionChosen:(NSString *)optionChosen{
    [self.sharePop dismissPopoverAnimated:YES];
}

-(void)deleteAllButtonTarget{
//    CustomAlertView *alert = [[CustomAlertView alloc] init];
//    [alert setTitle: NSLocalizedString(@"myplayXplay", nil)];
//    alert.type = AlertImportant;
//    [alert setMessage:[NSString stringWithFormat:@"%@ %@s?", NSLocalizedString(@"Are you sure you want to delete all these", nil), [self.contextString lowercaseString]]];
//    [alert setDelegate:self]; //set delegate to self so we can catch the response in a delegate method
//    [alert addButtonWithTitle: NSLocalizedString(@"Yes, delete from both server and ipad", nil)];
//    [alert addButtonWithTitle: NSLocalizedString(@"Yes, delete from ipad", nil)];
//    [alert addButtonWithTitle: NSLocalizedString(@"No", nil)];
//    [alert showView];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        self.editingIndexPath = indexPath;
        
        
        
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"myplayXplay",nil)
                                                                        message:[NSString stringWithFormat:@"%@ %@s?", NSLocalizedString(@"Are you sure you want to delete this",nil), [self.contextString lowercaseString]]
                                                                 preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okayButton = [UIAlertAction
                                     actionWithTitle:@"Yes"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         
                                         
                                         
                                         
                                         
                                         
                                         NSInteger row = self.editingIndexPath.row;
                                         
                                         
                                         NSDictionary *tagToRemove = self.tableData[row];
                                         
                                         [self.setOfDeletingCells removeAllObjects];
                                         if (_delegate && [_delegate respondsToSelector:@selector(tableView:indexesToBeDeleted:)]) {
                                             
                                             [_delegate tableView:self indexesToBeDeleted:@[self.editingIndexPath]];
                                         }
                                         

                                         
                                         [self.tableData removeObject:tagToRemove];
                                         [self removeIndexPathFromDeletion];
                                         [self.tableView deleteRowsAtIndexPaths:@[self.editingIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                                         [self.tableView reloadData];
                                         [[CustomAlertControllerQueue getInstance] dismissViewController:alert animated:YES completion:nil];
                                             [self checkDeleteAllButton];
                                     }];
        
        UIAlertAction* cancelButtons = [UIAlertAction
                                        actionWithTitle:@"No"
                                        style:UIAlertActionStyleCancel
                                        handler:^(UIAlertAction * action)
                                        {
                                            
                                            [[CustomAlertControllerQueue getInstance] dismissViewController:alert animated:YES completion:nil];
                                        }];
        
        
        [alert addAction:okayButton];
        [alert addAction:cancelButtons];
        
        
        BOOL isAllowed = [[CustomAlertControllerQueue getInstance]presentViewController:alert inController:self animated:YES style:AlertIndecisive completion:nil];
        if (!isAllowed) {
            NSDictionary *tagToRemove = self.tableData[self.editingIndexPath.row];
            [self.tableData removeObject:tagToRemove];
            [self removeIndexPathFromDeletion];
            [self.tableView deleteRowsAtIndexPaths:@[self.editingIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView reloadData];
                [self checkDeleteAllButton];

        }
        
        
//        
//        CustomAlertView *alert = [[CustomAlertView alloc] init];
//        alert.type = AlertImportant;
//        [alert setTitle: NSLocalizedString(@"myplayXplay", nil)];
//        [alert setMessage:[NSString stringWithFormat:@"%@ %@?", NSLocalizedString(@"Are you sure you want to delete this", nil), [self.contextString lowercaseString]]];
//        [alert setDelegate:self]; //set delegate to self so we can catch the response in a delegate method
//        [alert addButtonWithTitle: NSLocalizedString(@"Yes", nil)];
//        [alert addButtonWithTitle: NSLocalizedString(@"No", nil)];
//        [alert showView];
//        
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        //Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

//- (void)alertView:(CustomAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    
//    if ([alertView.message isEqualToString:[NSString stringWithFormat:@"Are you sure you want to delete all these %@s?", [self.contextString lowercaseString]]] && buttonIndex == 0) {
//        NSMutableArray *indexPathsArray = [[NSMutableArray alloc]init];
//        NSMutableArray *arrayOfTagsToRemove = [[NSMutableArray alloc]init];
//        
//        for (NSIndexPath *cellIndexPath in self.setOfDeletingCells) {
//            [arrayOfTagsToRemove addObject:self.tableData[cellIndexPath.row]];
//            [indexPathsArray addObject: cellIndexPath];
//        }
//        
//        for (NSIndexPath *path in self.setOfDeletingCells) {
//            if ([path isEqual:self.selectedPath]) {
//                //NSDictionary *tag = self.tableData[self.selectedPath.row];
//                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REMOVE_INFORMATION object:nil];
//                self.selectedPath = nil;
//            }
//        }
//        
//        for (NSDictionary *tag in arrayOfTagsToRemove) {
//            [self.tableData removeObject:tag];
//            //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_DELETE_TAG object:tag];
//            //[[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"NOTIF_DELETE_%@", self.contextString]  object:nil userInfo:tag];
//        }
//        
//        [self.setOfDeletingCells removeAllObjects];
//        if (_delegate && [_delegate respondsToSelector:@selector(tableView:indexesToBeDeleted:)]) {
//        
//            [_delegate tableView:self indexesToBeDeleted:indexPathsArray];
//        }
//        [self.tableView deleteRowsAtIndexPaths:indexPathsArray withRowAnimation:UITableViewRowAnimationLeft];
//        [self.tableView reloadData];
//        
//        /*
//        for (NSDictionary *tag in arrayOfTagsToRemove) {
//            //[self.tableData removeObject:tag];
//            //[[NSNotificationCenter defaultCenter] post]
//            //[[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"NOTIF_DELETE_%@", self.contextString]  object:nil userInfo:tag];
//        }
//         */
//        
//    }else{
//        if (buttonIndex == 0)
//        {
//            NSDictionary *tagToRemove = self.tableData[self.editingIndexPath.row];
//            [self.tableData removeObject:tagToRemove];
//            
//            //[[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"NOTIF_DELETE_%@", self.contextString]  object:nil userInfo:tagToRemove];
//            
//            [self removeIndexPathFromDeletion];
//            [self.tableView deleteRowsAtIndexPaths:@[self.editingIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//            [self.tableView reloadData];
//            
//            //[[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"NOTIF_DELETE_%@", self.contextString]  object:tagToRemove userInfo:tagToRemove];
//        }
//        else if (buttonIndex == 1)
//        {
//            // No, cancel the action to delete tags
//        }
//        
//    }
//    [alertView viewFinished];
//    [CustomAlertView removeAlert:alertView];
//    
//    [self checkDeleteAllButton];
//    //[self.tableView reloadData];
//}

-(void)removeIndexPathFromDeletion{
    NSMutableSet *newIndexPathSet = [[NSMutableSet alloc]init];
//    [self.setOfDeletingCells removeObject:self.editingIndexPath];
    if ([self.selectedPath isEqual:self.editingIndexPath]) {
        //NSDictionary *tag = self.tableData[self.selectedPath.row];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REMOVE_INFORMATION object:self];
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



