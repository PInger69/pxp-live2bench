//
//  CalendarTableTableViewController.m
//  Live2BenchNative
//
//  Created by dev on 2015-02-23.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "CalendarTableViewController.h"

@interface CalendarTableViewController ()

@end

@implementation CalendarTableViewController

-(instancetype) init{
    self = [super init];
    if (self){
        
        
    }
    return self;
}

-(void)loadView{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 170, 900, 300)];
    [self.tableView setAutoresizingMask:UIViewAutoresizingNone];
    [self.tableView registerClass: [UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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

-(void)downloadButtonPressed: (id) sender{

}

-(void)openButtonPressed: (id) sender{

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.gamesToDisplay count];

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.context) {
        UITableViewCell *cell = [[UITableViewCell alloc]init];
        
        //[self.tableView setRowHeight:100];
        
        NSArray *gameInfo = [self.gamesToDisplay[indexPath.row] componentsSeparatedByString:@", "];
        
        int cellHeight = [self tableView: tableView heightForRowAtIndexPath:indexPath];
        
        //This label displays the name of each game
        UILabel *gameNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, cellHeight/2)];
        //gameNameLabel.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
        [gameNameLabel setText:gameInfo[0]];
        [gameNameLabel setFont:[UIFont systemFontOfSize: 24.0]];
        [gameNameLabel setTextAlignment:NSTextAlignmentCenter];
        [cell.contentView addSubview:gameNameLabel];
        
        
        // Download Image
        UIImageView *downloadImage = [[UIImageView alloc] initWithFrame:CGRectMake(125, cellHeight/2, 50, cellHeight/2)];
        [downloadImage setImage: [UIImage imageNamed:@"downloadImage"]];
        [cell.contentView addSubview:downloadImage];
        
        //DownloadButton
        // This is the button that receives the target for download
        UIButton *downloadButton = [[UIButton alloc] initWithFrame:CGRectMake(125, cellHeight/2, 50, cellHeight/2)];
        [downloadButton addTarget:self action:@selector(downloadButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview: downloadButton];
        
        if ( [gameInfo[2] isEqualToString:@"YES"]){
            // Checkmark Image
            UIImageView *checkmarkImage = [[UIImageView alloc] initWithFrame:CGRectMake(175, cellHeight/2, 50, cellHeight/2)];
            [checkmarkImage setImage: [UIImage imageNamed:@"checkmark"]];
            [cell.contentView addSubview:checkmarkImage];
        }
        
        UIImageView *folderImage = [[UIImageView alloc] initWithFrame:CGRectMake(325, 25, 50, cellHeight/2)];
        [folderImage setImage: [UIImage imageNamed:@"folder"]];
        [cell.contentView addSubview: folderImage];
        
        UIButton *openButton = [[UIButton alloc] initWithFrame:CGRectMake(325, 25, 50, cellHeight/2)];
        [openButton addTarget:self action:@selector(openButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview: openButton];
        
        // Configure the cell...
        
        return cell;
    }else{
    
        
        UITableViewCell *cell = [[UITableViewCell alloc]init];
        
        NSArray *gameInfo = [self.gamesToDisplay[indexPath.row] componentsSeparatedByString:@", "];
        
        int cellHeight = [self tableView: tableView heightForRowAtIndexPath:indexPath];
        
        //This label displays the name of each game
        UILabel *gameNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, cellHeight-1)];
        gameNameLabel.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
        [gameNameLabel setText:gameInfo[0]];
        [gameNameLabel setFont:[UIFont systemFontOfSize: 24.0]];
        [gameNameLabel setTextAlignment:NSTextAlignmentCenter];
        [cell.contentView addSubview:gameNameLabel];
        
        // DATE LABEL
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(300, 0, 180, cellHeight)];
        [dateLabel setText:gameInfo[1]];
        [dateLabel setFont:[UIFont systemFontOfSize: 24.0]];
        [dateLabel setTextAlignment:NSTextAlignmentCenter];
        [cell.contentView addSubview: dateLabel];
        
        
        // Download Image
        UIImageView *downloadImage = [[UIImageView alloc] initWithFrame:CGRectMake(525, 0, 50, cellHeight)];
        [downloadImage setImage: [UIImage imageNamed:@"downloadImage"]];
        [cell.contentView addSubview:downloadImage];
        
        //DownloadButton
        // This is the button that receives the target for download
        UIButton *downloadButton = [[UIButton alloc] initWithFrame:CGRectMake(525, 0, 50, cellHeight)];
        [downloadButton addTarget:self action:@selector(downloadButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview: downloadButton];
        
        if ( [gameInfo[2] isEqualToString:@"YES"]){
            // Checkmark Image
            UIImageView *checkmarkImage = [[UIImageView alloc] initWithFrame:CGRectMake(575, 0, 50, cellHeight)];
            [checkmarkImage setImage: [UIImage imageNamed:@"checkmark"]];
            [cell.contentView addSubview:checkmarkImage];
        }
        
        UIImageView *folderImage = [[UIImageView alloc] initWithFrame:CGRectMake(700, 0, 50, cellHeight)];
        [folderImage setImage: [UIImage imageNamed:@"folder"]];
        [cell.contentView addSubview: folderImage];
        
        UIButton *openButton = [[UIButton alloc] initWithFrame:CGRectMake(700, 0, 50, cellHeight)];
        [openButton addTarget:self action:@selector(openButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview: openButton];
        
        // Configure the cell...
        
        return cell;

    }
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.context){
        return 100.0;
    }else{
        return [super tableView:(UITableView *)tableView
        heightForRowAtIndexPath:(NSIndexPath *)indexPath];
    }
}
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
