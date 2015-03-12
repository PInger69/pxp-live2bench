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

@interface BookmarkTableViewController ()
@property (strong, nonatomic) UILongPressGestureRecognizer *longPressRecognizer;
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
\
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    //[self.tableView setContentSize:CGSizeMake(self.tableView.frame.size.width, [self.tableData count] * 44)];
    // Return the number of rows in the section.
    return [self.tableData count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BookmarkViewCell *selectedCell = (BookmarkViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    NSDictionary *tag = [self.tableData objectAtIndex:indexPath.row];
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SET_PLAYER_FEED_IN_MYCLIP object:nil userInfo:@{@"forFeed":@{@"context":STRING_MYCLIP_CONTEXT,
                                                                                                                                 @"feed":@"s_00",
                                                                                                                                 @"time":[tag objectForKey:@"starttime"],
                                                                                                                                 @"duration":[tag objectForKey:@"duration"],
                                                                                                                                 @"comment":[tag objectForKey:@"comment"]},
                                                                                                                    @"forWhole":tag}];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BookmarkViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BookmarkViewCell" forIndexPath:indexPath];
    NSDictionary *cellDictionary = self.tableData[indexPath.row];
    
    [cell.eventDate setText: [Utility dateFromEvent: cellDictionary[@"event"]]];
    [cell.tagTime setText:cellDictionary[@"displaytime"]];
    [cell.tagName setText: [cellDictionary[@"name"] stringByRemovingPercentEncoding] ];
    [cell.indexNum setText: [NSString stringWithFormat:@"%i",indexPath.row + 1]];
    
    cell.deleteBlock = ^(UITableViewCell *cell){
        [self.tableData removeObjectAtIndex: [self.tableView indexPathForCell:cell]];
        [self.setOfDeletingCells removeObject: cell];
        [self checkDeleteAllButton];
        [self tableView: self.tableView commitEditingStyle: UITableViewCellEditingStyleDelete forRowAtIndexPath:indexPath];
    };
    
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



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}



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
