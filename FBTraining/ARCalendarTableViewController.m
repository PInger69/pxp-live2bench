//
//  ARCalendarTableViewController.m
//  Live2BenchNative
//
//  Created by dev on 2015-02-26.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "ARCalendarTableViewController.h"
#import "CalendarTableCell.h"
#import "ARCalendarTableViewCell.h"
#import "Downloader.h"
#import "DownloadItem.h"
#import "ListPopoverController.h"

@interface ARCalendarTableViewController ()

@property (strong, nonatomic) NSMutableArray *tableData;
@property (strong, nonatomic) NSIndexPath *lastSelectedIndexPath;
@property (strong, nonatomic) NSIndexPath *editingIndexPath;
@property (strong, nonatomic) NSMutableDictionary *downloadingItemsDictionary;

@property (strong, nonatomic) ListPopoverController* teamPick;

@end


@implementation ARCalendarTableViewController

-(instancetype)init{
    self = [super init];
    if(self){
        //[self.tableView registerClass:[CalendarTableCell class] forCellReuseIdentifier: @"CalendarTableCell"];
        [self.tableView registerClass:[ARCalendarTableViewCell class] forCellReuseIdentifier: @"ARCalendarTableViewCell"];
        self.downloadingItemsDictionary = [[NSMutableDictionary alloc] init];
        //        self.originalFrame = CGRectMake(568, 768, 370, 0);
        //        [self.deleteButton setFrame: self.originalFrame];
        //        self.newFrame = CGRectMake(568, 708, 370, 60);
        
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filterArray:) name:@"datePicked" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showAllData{
    self.tableData = [self arrayOfAllEventsSorted];
    [self.tableView reloadData];
}

-(NSArray *) arrayOfAllEventsSorted{
    NSMutableArray *sortedArray = [NSMutableArray array];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    
    for (NSDictionary *event in self.arrayOfAllData) {
        NSArray *bothStrings = [event[@"date"]componentsSeparatedByString:@" "];
        NSDate *date = [formatter dateFromString:bothStrings[0]];
        
        
        
        if (!sortedArray.count) {
            [sortedArray addObject:event];
            continue;
        }
        
        for (int i = 0; i < sortedArray.count; ++i) {
            NSArray *bothStringsOfSortedEvent = [sortedArray[i][@"date"] componentsSeparatedByString:@" "];
            NSDate *dateOfSortedEvent = [formatter dateFromString:bothStringsOfSortedEvent[0]];
            
            if ([date compare: dateOfSortedEvent] == NSOrderedAscending) {
                [sortedArray insertObject:event atIndex:i];
                break;
            }else if ([date compare: dateOfSortedEvent] == NSOrderedSame){
                
                NSArray *timeStrings = [bothStrings[1] componentsSeparatedByString:@":"];
                NSArray *timeStringsForSortedEvent = [bothStringsOfSortedEvent[1] componentsSeparatedByString:@":"];
                
                int eventHour = [timeStrings[0] intValue];
                int sortedHour = [timeStringsForSortedEvent[0] intValue];
                
                int eventMin = [timeStrings[0] intValue];
                int sortedMin = [timeStringsForSortedEvent[0] intValue];
                
                if (eventHour < sortedHour) {
                    [sortedArray insertObject:event atIndex:i];
                    break;
                }else if (eventMin < sortedMin){
                    [sortedArray insertObject:event atIndex:i];
                    break;
                }
                
            }else if (([date compare: dateOfSortedEvent] == NSOrderedDescending && i == sortedArray.count-1 )){
                [sortedArray addObject:event];
                break;
            }
        }
    }
    
    NSMutableArray *newestFirstSortedArray = [NSMutableArray array];
    for (NSDictionary *event in sortedArray) {
        [newestFirstSortedArray insertObject:event atIndex:0];
    }
    
    return newestFirstSortedArray;
}

- (void)filterArray:(NSNotification *)note
{
    NSMutableArray *eventsOfTheDay = [NSMutableArray array];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    
    for (NSDictionary *event in self.arrayOfAllData) {
        NSArray *bothStrings = [event[@"date"]componentsSeparatedByString:@" "];
        NSDate *date = [formatter dateFromString:bothStrings[0]];
        
        if ([self date: date isSameDayAsDate:note.userInfo[@"date"]]) {
            [eventsOfTheDay addObject:event];
        }
    }
    
    self.tableData = eventsOfTheDay;
    [self.setOfDeletingCells removeAllObjects];
    [self checkDeleteAllButton];
    [self.tableView reloadData];
}

- (BOOL)date:(NSDate *)date1 isSameDayAsDate:(NSDate *)date2 {
    // Both dates must be defined, or they're not the same
    if (date1 == nil || date2 == nil) {
        return NO;
    }
    
    NSDateComponents *day = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date1];
    NSDateComponents *day2 = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date2];
    return ([day2 day] == [day day] &&
            [day2 month] == [day month] &&
            [day2 year] == [day year] &&
            [day2 era] == [day era]);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.tableData.count + 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // This condition is to add an empty cell at the end of the tableview
    if (indexPath.row >= self.tableData.count || !self.tableData) {
        ARCalendarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ARCalendarTableViewCell" forIndexPath:indexPath];
        [cell.timeLabel setText: @" "];
        [cell.dateLabel setText: @" "];
        [cell.titleLabel setText: @" "];
        cell.downloadButton.hidden = YES;
        cell.playButton.hidden = YES;
        cell.swipeRecognizerLeft.enabled = NO;
        cell.swipeRecognizerRight.enabled = NO;
        [cell setCellAccordingToState:cellStateNormal];
        
        return cell;
    }
    
    
    ARCalendarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ARCalendarTableViewCell" forIndexPath:indexPath];
    
    cell.deleteBlock = ^(UITableViewCell *theCell){
        NSIndexPath *aIndexPath = [self.tableView indexPathForCell:theCell];
        [self tableView:self.tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:aIndexPath];
        [self checkDeleteAllButton];
    };
    
    
    cell.selectedBackgroundView.backgroundColor = [UIColor whiteColor];
    cell.selectedBackgroundView.backgroundColor = [UIColor whiteColor];
    [cell.dateLabel setTextColor:[UIColor blackColor]];
    [cell.timeLabel setTextColor:[UIColor blackColor]];
    [cell.titleLabel setTextColor:[UIColor blackColor]];
    cell.backgroundColor = [UIColor whiteColor];
    cell.layer.borderWidth = 0.0f;
    
    NSDictionary *event = self.tableData[indexPath.row];
    NSString *dateString = [event objectForKey:@"date"];
    NSArray *bothStrings = [dateString componentsSeparatedByString:@" "];
    
    cell.downloadButton.hidden = NO;
    cell.playButton.hidden = NO;
    
    
    __block ARCalendarTableViewController *weakSelf = self;
    cell.sendUserInfo = ^(){
        _teamPick = nil;
        
        NSString *homeName = event[@"homeTeam"];
        NSString *visitName = event[@"visitTeam"];
        NSString *eventName = event[@"name"];
        
        _teamPick = [[ListPopoverController alloc]initWithMessage:NSLocalizedString(@"Please select the team you want to tag:", @"dev comment - asking user to pick a team")
                                                  buttonListNames:@[homeName, visitName]];
        
        _teamPick.contentViewController.modalInPopover = NO;
        
        
        [_teamPick addOnCompletionBlock:^(NSString *pick) {
            [[NSNotificationCenter defaultCenter]postNotificationName: NOTIF_USER_CENTER_UPDATE  object:weakSelf userInfo:@{@"userPick":pick}];
            [[NSNotificationCenter defaultCenter]postNotificationName: NOTIF_SELECT_TAB          object:weakSelf userInfo:@{@"tabName":@"Live2Bench"}];
            [[NSNotificationCenter defaultCenter] postNotificationName: NOTIF_EVENT_CHANGE object:weakSelf userInfo:@{@"eventName":eventName}];
        }];
        [_teamPick presentPopoverCenteredIn:[UIApplication sharedApplication].keyWindow.rootViewController.view
                                   animated:YES];
    };
    
    __block ARCalendarTableViewCell *weakCell = cell;
    cell.downloadButton.enabled = YES;
    if([self.downloadingItemsDictionary objectForKey:dateString]){
        cell.downloadButton.downloadItem = [self.downloadingItemsDictionary objectForKey: dateString];
        [cell.downloadButton.downloadItem addOnProgressBlock:^(float progress, NSInteger kbps) {
            weakCell.downloadButton.progress = progress;
            [weakCell.downloadButton setNeedsDisplay];
            weakCell.playButton.hidden = (weakCell.downloadButton.downloadItem.progress == 1.0)?NO:YES;
        }];
        //cell.downloadButton.progress = cell.downloadButton.downloadItem.progress;
        [cell.downloadButton setNeedsDisplay];
        cell.playButton.hidden = (cell.downloadButton.downloadItem.progress == 1.0)?NO:YES;
    }else{
        
        cell.downloadButton.downloadItem = nil;
        cell.downloadButtonBlock = ^(){
            DownloadItem *downloadItem = [Downloader downloadURL:event[@"mp4"] to: [self.localPath stringByAppendingString:event[@"name"]]];
            downloadItem.name = [NSString stringWithFormat:@"%@ at %@", event[@"visitTeam"], event[@"homeTeam"]];
            weakCell.downloadButton.downloadItem = downloadItem;
            [weakCell.downloadButton.downloadItem addOnProgressBlock:^(float progress, NSInteger kbps) {
                weakCell.downloadButton.progress = progress;
                [weakCell.downloadButton setNeedsDisplay];
                weakCell.playButton.hidden = (weakCell.downloadButton.downloadItem.progress == 1.0)?NO:YES;
            }];
            [weakSelf.downloadingItemsDictionary setObject:downloadItem forKey: dateString];
        };
        cell.playButton.hidden = YES;
    }
    
    [cell.timeLabel setText: [bothStrings[1] substringToIndex: 5]];
    [cell.dateLabel setText: bothStrings[0]];
    [cell.titleLabel setText: [NSString stringWithFormat: @"%@ at %@", event[@"visitTeam"], event[@"homeTeam"]]];
    
    [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
    
    //This condition opens up the cell if it is a deleting cell
    if ([self.setOfDeletingCells containsObject:indexPath]) {
        [cell setCellAccordingToState:cellStateDeleting];
    } else {
        [cell setCellAccordingToState:cellStateNormal];
    }
    
    
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    if (indexPath.row >= self.tableData.count || !self.tableData) {
        return NO;
    }
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        self.editingIndexPath = indexPath;
        
        NSDictionary *event = self.tableData[indexPath.row];
        NSString *dateString = [event objectForKey:@"date"];
        
        CustomAlertView *alert = [[CustomAlertView alloc] init];
        [alert setTitle:@"myplayXplay"];
        [alert setMessage:@"Are you sure you want to delete this Event?"];
        [alert setDelegate:self]; //set delegate to self so we can catch the response in a delegate method
        [alert addButtonWithTitle:@"Yes"];
        if([self.downloadingItemsDictionary objectForKey: dateString]){
            [alert addButtonWithTitle:@"Yes (local)"];
            [alert addButtonWithTitle:@"Yes (remote)"];
        }
        [alert addButtonWithTitle:@"No"];
        [alert show];
        
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
        
        [self.tableData removeObjectsInArray: arrayOfTagsToRemove];
        [self.arrayOfAllData removeObjectsInArray: arrayOfTagsToRemove];
        
        [self.setOfDeletingCells removeAllObjects];
        [self.tableView deleteRowsAtIndexPaths:indexPathsArray withRowAnimation:UITableViewRowAnimationLeft];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"calendarNeedsLayout" object:nil];
        
    }else{
        if (buttonIndex == 0)
        {
            [self removeIndexPathFromDeletion];
            [self.arrayOfAllData removeObject: self.tableData[self.editingIndexPath.row]];
            [self.tableData removeObject: self.tableData[self.editingIndexPath.row]];
            
            [self.tableView deleteRowsAtIndexPaths:@[self.editingIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"calendarNeedsLayout" object:nil];
            
        }else if (buttonIndex == alertView.numberOfButtons - 3){
            
        }else if (buttonIndex == alertView.numberOfButtons - 2){
            
        }
        else if (buttonIndex == alertView.numberOfButtons - 1)
        {
            // No, cancel the action to delete tags
        }
    }
    
    [CustomAlertView removeAlert:alertView];
    
    [self checkDeleteAllButton];
}

-(void)removeIndexPathFromDeletion{
    NSMutableSet *indexPathsToRemove = [[NSMutableSet alloc]init];
    [self.setOfDeletingCells removeObject:self.editingIndexPath];
    
    for (NSIndexPath *indexPath in self.setOfDeletingCells) {
        if (indexPath.row > self.editingIndexPath.row) {
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection: indexPath.section];
            [indexPathsToRemove addObject: newIndexPath];
        }else{
            [indexPathsToRemove addObject: indexPath];
        }
    }
    
    self.setOfDeletingCells = indexPathsToRemove;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row >= self.tableData.count || !self.tableData) {
        return nil;
    }
    return indexPath;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UIColor * color = [UIColor colorWithRed:255/255.0f green:206/255.0f blue:119/255.0f alpha:1.0f];
    UIColor * colorForTesting = [UIColor orangeColor];
    UIColor * textColor = [UIColor colorWithWhite:0.224 alpha:1.0f];
    
    
    
    
    ARCalendarTableViewCell *lastCell = (ARCalendarTableViewCell *)[self.tableView cellForRowAtIndexPath: self.lastSelectedIndexPath];
    lastCell.selectedBackgroundView.backgroundColor = [UIColor whiteColor];
    lastCell.selectedBackgroundView.backgroundColor = [UIColor whiteColor];
    [lastCell.dateLabel setTextColor:[UIColor blackColor]];
    [lastCell.timeLabel setTextColor:[UIColor blackColor]];
    [lastCell.titleLabel setTextColor:[UIColor blackColor]];
    lastCell.backgroundColor = [UIColor whiteColor];
    lastCell.layer.borderWidth = 0.0f;
    
    ARCalendarTableViewCell *currentCell = (ARCalendarTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    currentCell.selectedBackgroundView.backgroundColor = colorForTesting;
    [currentCell.dateLabel setTextColor:textColor];
    [currentCell.timeLabel setTextColor:textColor];
    [currentCell.titleLabel setTextColor:textColor];
    currentCell.backgroundColor = color;
    //[currentCell setSelectionStyle: UITableViewCellSelectionStyleNone];
    self.lastSelectedIndexPath = indexPath;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

@end

