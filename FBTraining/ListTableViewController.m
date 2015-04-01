//
//  ListTableViewController.m
//  Live2BenchNative
//
//  Created by dev on 2015-02-18.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "ListTableViewController.h"
#import "ListViewCell.h"
#import "ImageAssetManager.h"
#import "ListPopoverControllerWithImages.h"



@interface ListTableViewController ()

//@property (strong, nonatomic) NSIndexPath *editingIndexPath;
@property (strong, nonatomic) ListPopoverControllerWithImages *sourceSelectPopover;
//@property (strong, nonatomic) NSMutableSet *setOfDeletingCells;
//@property (strong, nonatomic) UIButton *deleteButton;



@end

@implementation ListTableViewController

-(instancetype)init{
    self = [super init];
    if(self){
        self.isEditable = YES;
        //self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(1024 - (TABLE_WIDTH+1) - 85 , LABEL_HEIGHT + 60, TABLE_WIDTH, TABLE_HEIGHT) style:UITableViewStyleGrouped];
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(568 , LABEL_HEIGHT + 25, TABLE_WIDTH, TABLE_HEIGHT + 30) style:UITableViewStyleGrouped];
        self.tableView.backgroundColor = [UIColor whiteColor];
        
        self.tableView.layer.borderWidth = 1.0f;
        self.tableView.layer.borderColor = [[UIColor grayColor] CGColor];
        
        [self.tableView registerClass:[ListViewCell class] forCellReuseIdentifier:@"ListViewCell"];
        self.sourceSelectPopover = [[ListPopoverControllerWithImages alloc]initWithMessage:@"Select Source:" buttonListNames:@[]];
        self.sourceSelectPopover.contentViewController.modalInPopover = NO; // this lets you tap out to dismiss
        
        //        self.deleteButton = [[UIButton alloc] init];
        //        self.deleteButton.backgroundColor = [UIColor redColor];
        //        [self.deleteButton addTarget:self action:@selector(deleteAllButtonTarget) forControlEvents:UIControlEventTouchUpInside];
        //        [self.deleteButton setTitle: @"Delete All" forState: UIControlStateNormal];
        //        [self.deleteButton.titleLabel setTextColor:[UIColor whiteColor]];
        //        [self.deleteButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        //        [self.deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        //        [self.deleteButton setFrame:CGRectMake(568, 768, 370, 0)];
        //
        //
        //
        //        self.setOfDeletingCells = [[NSMutableSet alloc] init];
        //        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addDeletionCell:) name:@"AddDeletionCell" object:nil];
        //        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeDeletionCell:) name:@"RemoveDeletionCell" object:nil];
        
        self.originalFrame = CGRectMake(568, 768, 370, 0);
        [self.deleteButton setFrame: self.originalFrame];
        self.newFrame = CGRectMake(568, 708, 370, 60);
        
    }
    return self;
}




- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    NSLog(@"The view will dissappear");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Multiple Cell Deletion Methods

//-(void) addDeletionCell: (NSNotification *) aNotification{
//    NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:aNotification.object];
//    [self.setOfDeletingCells addObject: cellIndexPath];
//    if (self.setOfDeletingCells.count >= 2){
//        [self.listViewControllerView addSubview: self.deleteButton];
//        [UIView beginAnimations:nil context:nil];
//        [UIView setAnimationDuration:0.5];
//        self.deleteButton.frame = CGRectMake(568, 708, 370, 60);
//        [UIView commitAnimations];
//    }
//}
//
//-(void)removeDeletionCell: (NSNotification *) aNotification{
//     NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:aNotification.object];
//    [self.setOfDeletingCells removeObject: cellIndexPath];
//    if (self.setOfDeletingCells.count < 2){
//        [UIView beginAnimations:nil context:nil];
//        [UIView setAnimationDuration:0.5];
//        self.deleteButton.frame = CGRectMake(568, 768, 370, 0);
//        [UIView commitAnimations];
//    }
//
//}
//
//-(void)deleteAllButtonTarget{
//    CustomAlertView *alert = [[CustomAlertView alloc] init];
//    [alert setTitle:@"myplayXplay"];
//    [alert setMessage:@"Are you sure you want to delete all these tags?"];
//    [alert setDelegate:self]; //set delegate to self so we can catch the response in a delegate method
//    [alert addButtonWithTitle:@"Yes"];
//    [alert addButtonWithTitle:@"No"];
//    [alert show];
//}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    // Return the number of sections.
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    // Return the number of rows in the section.
//    return [self.tagsToDisplay count];
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //fixed the issue: when lots of tags created, couldn't scroll to tableview bottom
    [self.tableView setContentSize:CGSizeMake(self.tableView.frame.size.width,[self.tableData count]*CELL_HEIGHT )];
    
    ListViewCell *cell = (ListViewCell*)[tableView dequeueReusableCellWithIdentifier:@"ListViewCell"];
    [cell setFrame: CGRectMake(0, 0, TABLE_WIDTH, TABLE_HEIGHT)];
    
    cell.deleteBlock = ^(UITableViewCell *theCell){
        NSIndexPath *aIndexPath = [self.tableView indexPathForCell:theCell];
        [self tableView:self.tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:aIndexPath];
    };
    
    //This condition opens up the cell if it is a deleting cell
    if ([self.setOfDeletingCells containsObject:indexPath]) {
        [cell setCellAccordingToState:cellStateDeleting];
    } else {
        [cell setCellAccordingToState:cellStateNormal];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //fixed: randomly highlight cells problem
    cell.backgroundView = nil;
    cell.selectedBackgroundView = [[UIView alloc]initWithFrame:CGRectZero];
    cell.selectedBackgroundView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
    //cell.backgroundColor = [UIColor redColor];
    
    UIView* backgroundView = [ [ UIView alloc ] initWithFrame:cell.frame ];
    backgroundView.backgroundColor = [UIColor clearColor];
    backgroundView.layer.borderColor = [[UIColor orangeColor] CGColor];
    cell.backgroundView = backgroundView;
    
    //This is the condition where a cell that is selected is reused
    [cell.translucentEditingView removeFromSuperview];
    cell.translucentEditingView = nil;
    
    // This condition is if the user is scrolling up and down and the
    // cell is selected
    if ([self.previouslySelectedIndexPath isEqual:indexPath]) {
        cell.translucentEditingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
        [cell.translucentEditingView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [cell.translucentEditingView setBackgroundColor: [UIColor colorWithRed:255/255.0f green:206/255.0f blue:119/255.0f alpha:1.0f]];
        [cell.translucentEditingView setAlpha:0.3];
        [cell.translucentEditingView setUserInteractionEnabled:FALSE];
        [cell addSubview:cell.translucentEditingView];
        
    }
    
    
    //Setting the Image
    ImageAssetManager *imageAssetManager = [[ImageAssetManager alloc]init];
    NSString *url = [self.tableData[indexPath.row] objectForKey:@"url"];
    [imageAssetManager imageForURL:url atImageView:cell.tagImage];
    
    NSDictionary *tag = self.tableData[indexPath.row];
    
    [cell.tagname setText:[[tag objectForKey:@"name"] stringByRemovingPercentEncoding]];
    [cell.tagname setFont:[UIFont boldSystemFontOfSize:18.f]];
    
    NSString *durationString = [NSString stringWithFormat:@"%@s",[tag objectForKey:@"duration"]];
    NSString *periodString = [NSString stringWithFormat:@"%@", [tag objectForKey:@"time"]];
    
    [cell.tagInfoText setText:[NSString stringWithFormat:@"Duration: %@ \nPeriod: %@ ",durationString,periodString]];
    
    [cell.tagtime setText: [tag objectForKey:@"displaytime"]];
    
    UIColor *thumbColour = [Utility colorWithHexString:[tag objectForKey:@"colour"]];
    [cell.tagcolor changeColor:thumbColour withRect:cell.tagcolor.frame];
    
    [cell removeGestureRecognizer:cell.swipeRecognizerRight];
    
    return cell;
}


- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    ImageAssetManager *imageAssetManager = [[ImageAssetManager alloc]init];
    
    ListViewCell *cell = (ListViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    
    if(![indexPath isEqual:self.previouslySelectedIndexPath])
    {
        cell.translucentEditingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
        [cell.translucentEditingView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [cell.translucentEditingView setBackgroundColor: [UIColor colorWithRed:255/255.0f green:206/255.0f blue:119/255.0f alpha:1.0f]];
        [cell.translucentEditingView setAlpha:0.3];
        [cell.translucentEditingView setUserInteractionEnabled:FALSE];
        [cell addSubview:cell.translucentEditingView];
        
        ListViewCell *lastSelectedCell = (ListViewCell*)[self.tableView cellForRowAtIndexPath: self.previouslySelectedIndexPath];
        //[lastSelectedCell.backgroundView setBackgroundColor:[UIColor colorWithWhite:0.95f alpha:1.0f]];
        [lastSelectedCell.backgroundView setBackgroundColor:[UIColor whiteColor]];
        [lastSelectedCell.translucentEditingView removeFromSuperview];
        
        //lastSelectedCell.backgroundView.layer.borderWidth = 0.0f;
        self.previouslySelectedIndexPath = indexPath;
        
        //cell.backgroundView.layer.borderWidth = 1.0f;
        [cell.backgroundView setBackgroundColor:[UIColor whiteColor]];
    }
    
    if (self.isEditable) {
        
        
        
        
        
    }else{
        
        
        NSDictionary *tag = [self.tableData objectAtIndex:indexPath.row];
        
                [self.sourceSelectPopover clear];
        
                [self.sourceSelectPopover setListOfButtonNames:[[tag objectForKey:@"url_2"] allKeys]];
//        [cell.data objectForKey:@"url_2"] ;
//        This is where the Thumbnail images are added to the popover
//         NSDictionary *tagSelect = [self.tagsToDisplay objectAtIndex:[indexPath indexAtPosition:1]];
                NSDictionary *urls = tag[@"url_2"];
                int i = 0;
                for (NSString *url in [urls allValues]){
                    //NSString *url = urls[[NSString stringWithFormat: @"s_0%i" , i +1 ]];
        
        
                    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, POP_WIDTH - 10, BUTTON_HEIGHT - 10)];
        
        
                    [imageAssetManager imageForURL: url atImageView:imageView ];
        
                    [(UIButton *)self.sourceSelectPopover.arrayOfButtons[i] addSubview:imageView];
                    ++i;
                }
        
        
        
        
        self.definesPresentationContext = YES;
        
        
     

        
        if ( [urls count] >1 ){
                    [self.sourceSelectPopover addOnCompletionBlock:^(NSString *pick) {
            
                        NSLog(@"You Picked a feed: %@",pick);
                        //[[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SELECT_TAB object:nil userInfo:@{@"tabName":@"Live2Bench"}];
            
                        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SET_PLAYER_FEED_IN_LIST_VIEW object:nil userInfo:@{@"forFeed":@{@"context":STRING_LISTVIEW_CONTEXT,
                                                                                                                                                        @"feed":pick,
                                                                                                                                                        @"time":[tag objectForKey:@"starttime"],
                                                                                                                                                        @"duration":[tag objectForKey:@"duration"],
                                                                                                                                                        @"comment":[tag objectForKey:@"comment"]},
                                                                                                                                           @"forWhole":tag}];
                    }];
            
                    [self.sourceSelectPopover presentPopoverCenteredIn: [self.tableView cellForRowAtIndexPath:indexPath] animated:YES];
            

        
        } else {
            NSString * key =        [urls allKeys][0];
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SET_PLAYER_FEED_IN_LIST_VIEW object:nil userInfo:@{@"forFeed":@{@"context":STRING_LISTVIEW_CONTEXT,
                                                                                                                                            @"feed":key,
                                                                                                                                            @"time":[tag objectForKey:@"starttime"],
                                                                                                                                            @"duration":[tag objectForKey:@"duration"],
                                                                                                                                            @"comment":[tag objectForKey:@"comment"]},
                                                                                                                               @"forWhole":tag}];
            
        }
        
        
        
        
        
        /*//if the cell in the indexPath was not selected before, adding it to the "selectedCellRows" dictionary and display the checkmark and hide bookmark button and coachpick button;
         //else, deselecting the cell, will hide the checkmark and display bookmark button and coachpick button
         if(![[selectedCellRows allKeys] containsObject:[NSString stringWithFormat:@"%d",indexPath.row]])
         {
         [cell.translucentEditingView setHidden:FALSE];
         [cell.checkmarkOverlay setHidden:FALSE];
         [cell.bookmarkButton setHidden:TRUE];
         [cell.coachpickButton setHidden:TRUE];
         //save the indexpath of the cell and the check box button in the selectedCellRows array
         NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithObjects:[[NSArray alloc] initWithObjects:tag,indexPath, nil] forKeys:[[NSArray alloc]initWithObjects:@"tag",@"indexpath", nil]];
         [selectedCellRows setObject:dict forKey:[NSString stringWithFormat:@"%d",indexPath.row]];
         }else{
         [selectedCellRows removeObjectForKey:[NSString stringWithFormat:@"%d",indexPath.row]];
         [cell.translucentEditingView setHidden:TRUE];
         [cell.checkmarkOverlay setHidden:TRUE];
         [cell.bookmarkButton setHidden:FALSE];
         [cell.coachpickButton setHidden:FALSE];
         }*/
    }
}



- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
    
    //    if (self.isEditable){
    //        return YES;
    //    } else {
    //        return YES;
    //    }
}

//- (void)tableView:(UITableView *)tableView
//willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath{
//    [super tableView: tableView willBeginEditingRowAtIndexPath:indexPath];
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    cell.editing = NO;
//    tableView.editing = NO;
//}

//
//// Override to support editing the table view.
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        // Delete the row from the data source
//        self.editingIndexPath = indexPath;
//
//        CustomAlertView *alert = [[CustomAlertView alloc] init];
//        [alert setTitle:@"myplayXplay"];
//        [alert setMessage:@"Are you sure you want to delete this tag?"];
//        [alert setDelegate:self]; //set delegate to self so we can catch the response in a delegate method
//        [alert addButtonWithTitle:@"Yes"];
//        [alert addButtonWithTitle:@"No"];
//        [alert show];
//
//
//    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//    }
//}
//
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//
//    if ([alertView.message isEqualToString:@"Are you sure you want to delete all these tags?"] && buttonIndex == 0) {
//        NSMutableArray *indexPathsArray = [[NSMutableArray alloc]init];
//        NSMutableArray *arrayOfTagsToRemove = [[NSMutableArray alloc]init];
//
//        for (NSIndexPath *cellIndexPath in self.setOfDeletingCells) {
//            [arrayOfTagsToRemove addObject:self.tableData[cellIndexPath.row]];
//            [indexPathsArray addObject: cellIndexPath];
//        }
//
//        for (NSDictionary *tag in arrayOfTagsToRemove) {
//            [self.tableData removeObject:tag];
//        }
//
//        [self.setOfDeletingCells removeAllObjects];
//        [self.tableView deleteRowsAtIndexPaths:indexPathsArray withRowAnimation:UITableViewRowAnimationLeft];
//
//    }else{
//        if (buttonIndex == 0)
//        {
//            [self.tableData removeObjectAtIndex:self.editingIndexPath.row];
//            [self.setOfDeletingCells removeObject: self.editingIndexPath];
//            [self.tableView deleteRowsAtIndexPaths:@[self.editingIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//        }
//        else if (buttonIndex == 1)
//        {
//            // No, cancel the action to delete tags
//        }
//
//    }
//    [CustomAlertView removeAlert:alertView];
//
//    if (self.setOfDeletingCells.count < 2){
//        [UIView beginAnimations:nil context:nil];
//        [UIView setAnimationDuration:0.5];
//        self.deleteButton.frame = CGRectMake(568, 768, 370, 0);
//        [UIView commitAnimations];
//
//    }
//    //[self.tableView reloadData];
//}

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

