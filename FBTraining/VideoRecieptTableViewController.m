//
//  VideoRecieptTableViewController.m
//  Live2BenchNative
//
//  Created by dev on 2016-08-19.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "VideoRecieptTableViewController.h"
#import "VideoRecieptDataProvider.h"
#import "VideoRecieptStatusOperation.h"
#import "UserCenter.h"
//#import "VideoRecieptTableViewCell.h"

@interface VideoRecieptTableViewController ()
@property (nonatomic,strong) VideoRecieptDataProvider * dataProvider;
@property (nonatomic,strong) VideoRecieptStatusOperation * vidCheckOp;
@property (nonatomic,strong) UIActivityIndicatorView * activityIndicator;


@end

@implementation VideoRecieptTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.dataProvider    =  [[VideoRecieptDataProvider alloc]initWithTableView:self.tableView];
    self.tableView.dataSource = self.dataProvider;
    self.tableView.rowHeight = 86;
    self.activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.activityIndicator setFrame:CGRectMake(300, 300, 100, 100)];
    
}



-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.view addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
    [self.dataProvider refreshOnRefreshComplete:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.activityIndicator stopAnimating];
            [self.activityIndicator removeFromSuperview];
            [self.tableView reloadData];
        });
    }];
    
    
 
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 0;
}

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
