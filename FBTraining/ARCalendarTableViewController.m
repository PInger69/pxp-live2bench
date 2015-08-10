//
//  ARCalendarTableViewController.m
//  Live2BenchNative
//
//  Created by dev on 2015-02-26.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "ARCalendarTableViewController.h"

#import "ARCalendarTableViewCell.h"
#import "Downloader.h"
#import "DownloadItem.h"
#import "ListPopoverController.h"
#import "FeedSelectCell.h"
#import "Feed.h"
#import "Tag.h"
#import "UserCenter.h"
#import "SpinnerView.h"
#import "Downloader.h"
#import "LocalMediaManager.h"
#import "LeagueTeam.h"

@interface ARCalendarTableViewController ()

//@property (strong, nonatomic) NSMutableArray *tableData;
@property (strong, nonatomic) NSIndexPath *lastSelectedIndexPath;
//@property (strong, nonatomic) NSIndexPath *editingIndexPath;
@property (strong, nonatomic) NSMutableArray *arrayOfCollapsableIndexPaths;
@property (strong, nonatomic) ListPopoverController* teamPick;

@end


@implementation ARCalendarTableViewController

-(instancetype)init{
    self = [super init];
    if(self){

        [self.tableView registerClass:[ARCalendarTableViewCell class] forCellReuseIdentifier: @"ARCalendarTableViewCell"];
        self.arrayOfCollapsableIndexPaths = [NSMutableArray array];
        //Set the frame for deleteAllButton
        self.originalFrame = CGRectMake(568, 768, 370, 0);
        [self.deleteButton setFrame: self.originalFrame];
        self.newFrame = CGRectMake(568, 708, 370, 60);
        //The context string is used to determine in which tableViewController you delete a cell
        self.contextString = @"Event";
        self.arrayOfSelectedEvent = [NSMutableArray array];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filterArray:) name:@"datePicked" object:nil];
    //To reload the number of downloaded sources
    [[NSNotificationCenter defaultCenter] addObserverForName:NOTIF_EVENT_DOWNLOADED object:nil queue:nil usingBlock:^(NSNotification *note){
        [self.tableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)onPressDownload:(FeedSelectCell*)aCell
{
    __block Event * eventgettingBuilt = aCell.event;
    NSString * sourceKey = aCell.dicKey;
    __block ARCalendarTableViewController * weakSelf = self;
    [aCell.event setOnComplete:^{
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_EM_DOWNLOAD_EVENT object:eventgettingBuilt userInfo:@{@"source":sourceKey}];
        [weakSelf reloadData];

    }];
    
    [eventgettingBuilt build];
}



//This method is getting called when you press "All Events Button" of datePicker.
-(void)showAllData{
    //To remove those collapsible cells and selected effect(orange background).
    [self.arrayOfCollapsableIndexPaths removeAllObjects];
    self.lastSelectedIndexPath = nil;
    
    self.tableData = [[self arrayOfAllEventsSorted] mutableCopy];
    [self.tableView reloadData];
}

-(NSArray *) arrayOfAllEventsSorted{
    NSMutableArray *sortedArray = [NSMutableArray array];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    
    for (Event *event in self.arrayOfAllData) {
        NSArray *bothStrings = [event.date componentsSeparatedByString:@" "];
        NSDate *date = [formatter dateFromString:bothStrings[0]];
        
        if (!sortedArray.count) {
            [sortedArray addObject:event];
            continue;
        }
        
        for (int i = 0; i < sortedArray.count; ++i) {
            Event *temp = sortedArray[i];
            NSArray *bothStringsOfSortedEvent = [temp.date componentsSeparatedByString:@" "];
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
    for (Event *event in sortedArray) {
        [newestFirstSortedArray insertObject:event atIndex:0];
    }
    
    return newestFirstSortedArray;
}

- (void)filterArray:(NSNotification *)note
{
    NSMutableArray *eventsOfTheDay = [NSMutableArray array];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    
    for (Event *event in self.arrayOfAllData) {
        NSArray *bothStrings = [event.date componentsSeparatedByString:@" "];
        NSDate *date = [formatter dateFromString:bothStrings[0]];
        
        if ([self date: date isSameDayAsDate:note.userInfo[@"date"]]) {
            [eventsOfTheDay addObject:event];
        }
    }
    
    self.tableData = eventsOfTheDay;
    [self.setOfDeletingCells removeAllObjects];
    [self.arrayOfCollapsableIndexPaths removeAllObjects];
    self.lastSelectedIndexPath = nil;
    [self checkDeleteAllButton];
    [self.tableView reloadData];
}

- (BOOL)date:(NSDate *)date1 isSameDayAsDate:(NSDate *)date2 {
    // Both dates must be defined, or they're not the same
    if (date1 == nil || date2 == nil) {
        return NO;
    }
    
    NSDateComponents *day = [[NSCalendar currentCalendar] components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date1];
    NSDateComponents *day2 = [[NSCalendar currentCalendar] components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date2];
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
    return self.tableData.count + self.arrayOfCollapsableIndexPaths.count + 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // This condition is to add an empty cell at the end of the tableview
    if (indexPath.row >= (self.tableData.count + self.arrayOfCollapsableIndexPaths.count) || !self.tableData) {
        ARCalendarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ARCalendarTableViewCell" forIndexPath:indexPath];
        [cell.timeLabel setText: @" "];
        [cell.dateLabel setText: @" "];
        [cell.titleLabel setText: @" "];
        [cell.leagueLabel setText:@" "];
        [cell.downloadInfoLabel setText:@" "];
        cell.swipeRecognizerLeft.enabled = NO;
        cell.swipeRecognizerRight.enabled = NO;
        [cell setCellAccordingToState:cellStateNormal];
        [cell isSelected:NO];
        return cell;
    }
    
    NSIndexPath *firstIndexPath = [self.arrayOfCollapsableIndexPaths firstObject];
    if ([self.arrayOfCollapsableIndexPaths containsObject: indexPath]) {
        Event *event = self.tableData[firstIndexPath.row - 1];
        
        NSDictionary *urls = event.feeds;
        NSString *key;
        NSString *data;
        Feed *feed;
        
        key = [urls allKeys][indexPath.row - firstIndexPath.row];
        feed = urls[key];
        data = [[feed.allPaths firstObject] absoluteString];
        
        FeedSelectCell *collapsableCell = [[FeedSelectCell alloc] initWithImageData:nil andName:key];
        collapsableCell.feedView.hidden = YES;
        
        collapsableCell.event = event;
        collapsableCell.downloadButton.enabled = YES;
        NSString *name = event.name;
        
        Event *localCounterpart = [[LocalMediaManager getInstance] getEventByName:name];
        
        [collapsableCell positionWithFrame:CGRectMake(0, 0, 518, 40)];
        __block ARCalendarTableViewController *weakSelf = self;
        collapsableCell.sendUserInfo = ^(NSString *key){
            _teamPick = nil;
            
            
            LeagueTeam *homeTeam = event.teams[@"homeTeam"];
            LeagueTeam *visitTeam = event.teams[@"visitTeam"];
            
            if (!homeTeam) {
                homeTeam = [[LeagueTeam alloc] init];
                homeTeam.name = event.rawData[@"homeTeam"];
            }
            
            if (!visitTeam) {
                visitTeam = [[LeagueTeam alloc] init];
                visitTeam.name = event.rawData[@"visitTeam"];
            }
            
            
            NSDictionary *team = @{homeTeam.name:homeTeam,visitTeam.name:visitTeam};
            
            //NSString *homeName = event.teams[@"homeTeam"];
            //NSString *visitName = event.teams[@"visitTeam"];
            
            
            if (_teamPick){
                [_teamPick dismissPopoverAnimated:NO];
                [_teamPick clear];
                _teamPick = nil;
            }
            
            
            _teamPick = [[ListPopoverController alloc]initWithMessage:NSLocalizedString(@"Please select the team you want to tag:", @"dev comment - asking user to pick a team")
                                                      buttonListNames:@[[[team allKeys]firstObject],[[team allKeys]lastObject]]];
            
            _teamPick.contentViewController.modalInPopover = NO;
            
            
            
            [_teamPick addOnCompletionBlock:^(NSString *pick) {
                
                [UserCenter getInstance].taggingTeam = [team objectForKey:pick];

                
                
                
                __block Event * weakEvent = event;
                
                if (event.local && ([localCounterpart.downloadedSources containsObject:[data lastPathComponent]] || [event.downloadedSources containsObject:[data lastPathComponent]])) {
                    Feed *source = [localCounterpart.feeds objectForKey:key];
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_COMMAND_VIDEO_PLAYER object:nil userInfo:@{@"feed":source, @"command":[NSNumber numberWithInt:VideoPlayerCommandPlayFeed], @"context":STRING_LIVE2BENCH_CONTEXT}];
                    [[NSNotificationCenter defaultCenter] postNotificationName: NOTIF_SELECT_TAB          object:weakSelf userInfo:@{@"tabName":@"Live2Bench"}];
                    [weakSelf.encoderManager declareCurrentEvent:localCounterpart];
                }else{
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_COMMAND_VIDEO_PLAYER object:nil userInfo:@{@"feed":feed, @"command":[NSNumber numberWithInt:VideoPlayerCommandPlayFeed], @"context":STRING_LIVE2BENCH_CONTEXT}];
                    [[NSNotificationCenter defaultCenter] postNotificationName: NOTIF_SELECT_TAB          object:weakSelf userInfo:@{@"tabName":@"Live2Bench"}];
                    [weakSelf.encoderManager declareCurrentEvent:weakEvent];
                }
                
            }];
            
            [_teamPick presentPopoverCenteredIn:[UIApplication sharedApplication].keyWindow.rootViewController.view
                                       animated:YES];
        };
        
        
        __block FeedSelectCell *weakCell = collapsableCell;

        if([[Downloader defaultDownloader].keyedDownloadItems objectForKey:[NSString stringWithFormat:@"%@_%@",collapsableCell.event.name,collapsableCell.dicKey ]]) {
        // This is checking if the downloader is downloading this event.. if so link the item to the download button
            collapsableCell.downloadButton.downloadItem = [[Downloader defaultDownloader].keyedDownloadItems objectForKey:[NSString stringWithFormat:@"%@_%@",collapsableCell.event.name,collapsableCell.dicKey ]];
            [collapsableCell.downloadButton.downloadItem addOnProgressBlock:^(float progress, NSInteger kbps) {
                weakCell.downloadButton.progress = progress;
                [weakCell.downloadButton setNeedsDisplay];
            }];
            [collapsableCell.downloadButton setNeedsDisplay];
        }
        else if ([[LocalMediaManager getInstance]getFeedByEvent:collapsableCell.event scrKey:collapsableCell.dicKey]) {
            weakCell.downloadButton.downloadComplete = YES;
            weakCell.downloadButton.progress = 1;
            [weakCell setNeedsDisplay];
        } else {
            collapsableCell.downloadButton.downloadItem = nil;
            __block ARCalendarTableViewController * weakSelf = self;
            collapsableCell.downloadButtonBlock = ^(){
                [weakSelf onPressDownload:weakCell]; // LOL okay why not
            };
        }
        return collapsableCell;
    }
    
    ARCalendarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ARCalendarTableViewCell" forIndexPath:indexPath];
    
    cell.swipeRecognizerLeft.enabled = self.swipeableMode;
    
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
    [cell.leagueLabel setTextColor:[UIColor blackColor]];
    cell.backgroundColor = [UIColor whiteColor];
    cell.layer.borderWidth = 0.0f;
    
    Event *event;
    
    if (firstIndexPath.row < indexPath.row) {
        event = self.tableData[indexPath.row -self.arrayOfCollapsableIndexPaths.count];
    }else{
        event = self.tableData[indexPath.row];
    }
    //Event *localOne = [self.encoderManager.localEncoder getEventByName:event.name];
    Event *localOne = [[LocalMediaManager getInstance] getEventByName:event.name];
    
    [cell isSelected:NO];
    if ([self.arrayOfSelectedEvent containsObject:event.name]) {
        [cell isSelected:YES];
    }
    
    NSString *dateString = event.date;
    NSArray *bothStrings = [dateString componentsSeparatedByString:@" "];
    NSString *leagueString = [[[[event.teams allValues] firstObject] league] name];
    
    //    cell.downloadButton.hidden = NO;
    //    cell.playButton.hidden = NO;
    
    [cell.timeLabel setText: [bothStrings[1] substringToIndex: 5]];
    [cell.dateLabel setText: bothStrings[0]];
    [cell.titleLabel setText: [NSString stringWithFormat: @"%@ at %@", event.rawData[@"visitTeam"], event.rawData[@"homeTeam"]]];
    [cell.downloadInfoLabel setText:@"0 / 0"];
    [cell.leagueLabel setText:leagueString];

    
//    if ()
    
    
    if (localOne) {
        [cell.downloadInfoLabel setText:[NSString stringWithFormat:@"%lu %@\n%lu %@", (unsigned long) ([localOne.feeds count]), NSLocalizedString(@"Downloaded", nil), (unsigned long)event.mp4s.count, NSLocalizedString(@"Sources", nil)]];
    }

    if (event.local) {
        [cell.downloadInfoLabel setText:[NSString stringWithFormat:@"%lu Downloaded\n%lu Sources", (unsigned long)localOne.downloadedSources.count,(unsigned long)event.mp4s.count]];

    } else {
        if (localOne) {
            [cell.downloadInfoLabel setText:[NSString stringWithFormat:@"%lu Downloaded\n%lu Sources", (unsigned long)([localOne.feeds count]),(unsigned long)event.mp4s.count]];
        } else {
            
            [cell.downloadInfoLabel setText:[NSString stringWithFormat:@"%lu Downloaded\n%lu Sources", (unsigned long)event.downloadedSources.count,(unsigned long)event.mp4s.count]];
        }
    }
    
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
        
        Event *event = self.tableData[indexPath.row];
//        NSString *dateString = event.date;
        
        //Event *localCounterpart = [self.encoderManager.localEncoder getEventByName:event.name];
        Event *localCounterpart = [[LocalMediaManager getInstance] getEventByName:event.name];
        CustomAlertView *alert = [[CustomAlertView alloc] init];
        alert.type = AlertImportant;
        [alert setTitle:NSLocalizedString(@"myplayXplay",nil)];
        [alert setMessage:NSLocalizedString(@"Are you sure you want to delete this Event?",nil)];
        if ((localCounterpart && [localCounterpart.feeds count] > 0)) {
            [alert addButtonWithTitle:NSLocalizedString(@"Yes(From server and local device)",nil)];
            [alert addButtonWithTitle:NSLocalizedString(@"Yes(Only local)",nil)];
            [alert addButtonWithTitle:NSLocalizedString(@"No",nil)];
        } else {
            [alert addButtonWithTitle:NSLocalizedString(@"Yes(From server)",nil)];
            [alert addButtonWithTitle:NSLocalizedString(@"No",nil)];
        }
        [alert setDelegate:self]; //set delegate to self so we can catch the response in a delegate method
        [alert display];
    }
}

- (void)alertView:(CustomAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.message isEqualToString:@"Are you sure you want to delete all these events?"] && (buttonIndex == 0 || buttonIndex == 1)) {
        NSMutableArray *indexPathsArray = [[NSMutableArray alloc]init];
        NSMutableArray *arrayOfTagsToRemove = [[NSMutableArray alloc]init];
        
        for (NSIndexPath *cellIndexPath in self.setOfDeletingCells) {
            [arrayOfTagsToRemove addObject:self.tableData[cellIndexPath.row]];
            [indexPathsArray addObject: cellIndexPath];
            Event *eventToDelete = self.tableData[cellIndexPath.row];
            //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_DELETE_EVENT object:nil userInfo:@{@"Event" : self.tableData[cellIndexPath.row]}];
            [eventToDelete.downloadedSources removeAllObjects];
            [[LocalMediaManager getInstance] deleteEvent:[[LocalMediaManager getInstance]getEventByName:eventToDelete.name]];
            if (buttonIndex == 0) {
                //Post a notification to delete it from server.
            }
        }
        if (buttonIndex == 0) {
            [self.tableData removeObjectsInArray: arrayOfTagsToRemove];
            [self.arrayOfAllData removeObjectsInArray: arrayOfTagsToRemove];
            [self.tableView deleteRowsAtIndexPaths:indexPathsArray withRowAnimation:UITableViewRowAnimationLeft];
            
            
            for (Event *eventToDelete in arrayOfTagsToRemove) {
                [eventToDelete destroy];
//                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_DELETE_EVENT_SERVER object:eventToDelete];
            }
        }
        
        [self.setOfDeletingCells removeAllObjects];
        if (buttonIndex == 1) {
            [self.tableView reloadData];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"calendarNeedsLayout" object:nil];
    } else{
        if (alertView.numberOfButtons == 3) {
            if (buttonIndex == 2) {
                [alertView viewFinished];
                return;
            }
            Event *eventToRemove = self.tableData[self.editingIndexPath.row];
            
            if (buttonIndex == 0) {
                [eventToRemove destroy];
                //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_DELETE_EVENT_SERVER object:eventToRemove];
                [self.arrayOfAllData removeObject:eventToRemove];
                [self.tableData removeObject: eventToRemove];
                [self.tableView deleteRowsAtIndexPaths:@[self.editingIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"calendarNeedsLayout" object:nil];
            }


            [[LocalMediaManager getInstance]deleteEvent:[[LocalMediaManager getInstance]getEventByName:eventToRemove.name]];
//            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_DELETE_EVENT object:nil userInfo:@{@"Event" : eventToRemove}];
            [eventToRemove.downloadedSources removeAllObjects];
            //[eventToRemove destroy];// deletes event from the server
            [self removeIndexPathFromDeletion];
            
            if (buttonIndex == 1) {
                [self.tableView reloadData];
            }
        } else {
            if (buttonIndex == 0) {
                Event *eventToRemove = self.tableData[self.editingIndexPath.row];
                [eventToRemove destroy];
                //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_DELETE_EVENT_SERVER object:eventToRemove];
                [self removeIndexPathFromDeletion];
                [self.arrayOfAllData removeObject:eventToRemove];
                [self.tableData removeObject: eventToRemove];
                [self.tableView cellForRowAtIndexPath:self.editingIndexPath];
                [self.tableView deleteRowsAtIndexPaths:@[self.editingIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"calendarNeedsLayout" object:nil];
                [self removeIndexPathFromDeletion];
            } else {
                [alertView viewFinished];
                return;
            }
        }
    }
    
    [CustomAlertView removeAlert:alertView];
    [alertView viewFinished];
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
    if (indexPath.row >= self.tableData.count + self.arrayOfCollapsableIndexPaths.count || !self.tableData) {
        return nil;
    }
    return indexPath;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.setOfDeletingCells.count ) {
        return;
    }else if ([self.arrayOfCollapsableIndexPaths containsObject: indexPath]){
        //        FeedSelectCell *cell = (FeedSelectCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        //        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SET_PLAYER_FEED_IN_LIST_VIEW object:nil userInfo:@{@"forFeed":@{@"context":STRING_LISTVIEW_CONTEXT,
        //                                                                                                                                        @"feed":cell.feedName.text,
        //                                                                                                                                        @"time":[event objectForKey:@"starttime"],
        //                                                                                                                                        @"duration":[event objectForKey:@"duration"],
        //                                                                                                                                        @"comment":[event objectForKey:@"comment"],
        //                                                                                                                                        @"forWhole":event
        //                                                                                                                                        }}];
        //
        return;
    }
    
    Event *event;
    NSIndexPath *firstDownloadCellPath = [self.arrayOfCollapsableIndexPaths firstObject];
    
    if ([self.arrayOfCollapsableIndexPaths containsObject:indexPath]) {
        event = self.tableData[firstDownloadCellPath.row -1];
    }else if (firstDownloadCellPath.row < indexPath.row) {
        event = self.tableData[indexPath.row -self.arrayOfCollapsableIndexPaths.count];
    }else{
        event = self.tableData[indexPath.row];
    }
    
   
    
//    ARCalendarTableViewCell *lastCell = (ARCalendarTableViewCell *)[self.tableView cellForRowAtIndexPath: self.lastSelectedIndexPath];
//    [lastCell isSelected:NO];
    ARCalendarTableViewCell *currentCell = (ARCalendarTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [currentCell isSelected:YES];
    if (event.mp4s.count >= 1) {
        [self.arrayOfSelectedEvent addObject:event.name];
    }
    
    if(![indexPath isEqual:self.lastSelectedIndexPath])
    {
        NSArray *arrayToRemove = [self.arrayOfCollapsableIndexPaths copy];
        
        NSMutableArray *insertionIndexPaths = [NSMutableArray array];
        if ([event.feeds allValues].count > 1) {
            if (self.lastSelectedIndexPath.row < indexPath.row && self.lastSelectedIndexPath) {
                for (int i = 0; i < ((NSArray *)[event.feeds allValues]).count ; ++i) {
                    NSIndexPath *insertionIndexPath = [NSIndexPath indexPathForRow:indexPath.row - arrayToRemove.count + i + 1 inSection:indexPath.section];
                    [insertionIndexPaths addObject:insertionIndexPath];
                }
                
                self.lastSelectedIndexPath = [NSIndexPath indexPathForRow:indexPath.row -arrayToRemove.count inSection:indexPath.section];
            }else{
                for (int i = 0; i < ((NSArray *)[event.feeds allValues]).count ; ++i) {
                    NSIndexPath *insertionIndexPath = [NSIndexPath indexPathForRow:indexPath.row + i+1 inSection:indexPath.section];
                    [insertionIndexPaths addObject:insertionIndexPath];
                }
                
                self.lastSelectedIndexPath = indexPath;
            }
        } else if (event.feeds.count == 1) {
            if (self.lastSelectedIndexPath.row < indexPath.row && self.lastSelectedIndexPath) {
                NSIndexPath *insertionIndexPath = [NSIndexPath indexPathForRow:indexPath.row - arrayToRemove.count + 1 inSection:indexPath.section];
                [insertionIndexPaths addObject:insertionIndexPath];
                self.lastSelectedIndexPath = [NSIndexPath indexPathForRow:indexPath.row -arrayToRemove.count inSection:indexPath.section];
            }else{
                NSIndexPath *insertionIndexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
                [insertionIndexPaths addObject:insertionIndexPath];
                self.lastSelectedIndexPath = indexPath;
            }
        } else {
            [currentCell isSelected:NO];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:NO];
            self.lastSelectedIndexPath = nil;
            [self.arrayOfSelectedEvent removeObject:event.name];
            [self.arrayOfCollapsableIndexPaths removeAllObjects];
            [self.tableView deleteRowsAtIndexPaths: arrayToRemove withRowAnimation:UITableViewRowAnimationRight];
            self.swipeableMode = YES;
            return;
        }
        
        
        [self.arrayOfCollapsableIndexPaths removeAllObjects];
        [self.tableView deleteRowsAtIndexPaths: arrayToRemove withRowAnimation:UITableViewRowAnimationRight];
        self.swipeableMode = NO;
        [self.arrayOfCollapsableIndexPaths addObjectsFromArray: insertionIndexPaths];
        [self.tableView insertRowsAtIndexPaths: insertionIndexPaths withRowAnimation:UITableViewRowAnimationRight];
        [self.tableView scrollToRowAtIndexPath:self.lastSelectedIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }else{
        //[currentCell isSelected: NO];
        NSArray *arrayToRemove = [self.arrayOfCollapsableIndexPaths copy];
        [self.arrayOfCollapsableIndexPaths removeAllObjects];
        [self.tableView deleteRowsAtIndexPaths: arrayToRemove withRowAnimation:UITableViewRowAnimationRight];
        NSIndexPath *temp = self.lastSelectedIndexPath;
        self.lastSelectedIndexPath = nil;
        [self.tableView reloadRowsAtIndexPaths:@[temp] withRowAnimation:NO];
        self.swipeableMode = YES;
    }
    
    
    
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.arrayOfCollapsableIndexPaths containsObject: indexPath]) {
        return 40;
    }
    return 80;
}

@end



