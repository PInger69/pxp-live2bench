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
#import "FeedSelectCell.h"
#import "Feed.h"
#import "Tag.h"
#import "UserCenter.h"
#import "SpinnerView.h"

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
        //[self.tableView registerClass:[CalendarTableCell class] forCellReuseIdentifier: @"CalendarTableCell"];
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
    Event * eventgettingBuilt = aCell.event;
    eventgettingBuilt.delegate = self; // onEventBuildFinished will get run
    
}

// reloads the tableView so that the downloader reflects
-(void)onEventBuildFinished:(Event*)event
{
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_EM_DOWNLOAD_EVENT object:event userInfo:@{}];
    [self reloadData];
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
        [cell.downloadInfoLabel setText:@" "];
        cell.swipeRecognizerLeft.enabled = NO;
        cell.swipeRecognizerRight.enabled = NO;
        [cell setCellAccordingToState:cellStateNormal];
        [cell isSelected:NO];
        return cell;
    }
    
//    NSString *data;
    NSIndexPath *firstIndexPath = [self.arrayOfCollapsableIndexPaths firstObject];
    if ([self.arrayOfCollapsableIndexPaths containsObject: indexPath]) {
        Event *event = self.tableData[firstIndexPath.row - 1];
        NSDictionary *urls = event.mp4s;
        NSString *key;
        NSString *data;
        
        key = [urls allKeys][indexPath.row - firstIndexPath.row];
        if (event.rawData[@"mp4_2"]) {
            data = urls[key][@"hq"];
        } else {
            data = urls[key];
        }
        
        FeedSelectCell *collapsableCell = [[FeedSelectCell alloc] initWithImageData:data andName:key];
        
        collapsableCell.event = event.rawData;
        collapsableCell.downloadButton.enabled = YES;
        NSString *name = event.name;
        
        //Event *localCounterpart = [self.encoderManager.localEncoder getEventByName:name];
        Event *localCounterpart = [[LocalMediaManager getInstance] getEventByName:name];
        
        [collapsableCell positionWithFrame:CGRectMake(0, 0, 518, 40)];
        __block ARCalendarTableViewController *weakSelf = self;
        collapsableCell.sendUserInfo = ^(NSString *key){
            _teamPick = nil;
            
            NSString *homeName = event.rawData[@"homeTeam"];
            NSString *visitName = event.rawData[@"visitTeam"];
            NSString *eventName = event.rawData[@"name"];
            
            _teamPick = [[ListPopoverController alloc]initWithMessage:NSLocalizedString(@"Please select the team you want to tag:", @"dev comment - asking user to pick a team")
                                                      buttonListNames:@[homeName, visitName]];
            
            _teamPick.contentViewController.modalInPopover = NO;
            
            /*NSString *path;
            if (event.rawData[@"mp4_2"]) {
                path = [[[[LocalMediaManager getInstance].localPath stringByAppendingPathComponent:@"events"] stringByAppendingPathComponent:event.name] stringByAppendingPathComponent:@"main_00hq.mp4"];
                //path = @"/Documents/events/2015-04-16_16-17-13_368156f1cc13acdf43d265c420b4d2956ed0f645_local/main_00hq.mp4";
            } else {
                path = [[[[LocalMediaManager getInstance].localPath stringByAppendingPathComponent:@"events"] stringByAppendingPathComponent:event.name] stringByAppendingPathComponent:@"main.mp4"];
//                path = [[self.encoderManager.localEncoder.localPath stringByAppendingPathComponent:@"events"]stringByAppendingPathComponent:@"main.mp4"];
            }*/
            
            
            
            
            
            [_teamPick addOnCompletionBlock:^(NSString *pick) {
                
                [UserCenter getInstance].userPick = pick;

                
                
                
                __block Event * weakEvent = event;
                
                if (event.local && ([localCounterpart.downloadedSources containsObject:[data lastPathComponent]] || [event.downloadedSources containsObject:[data lastPathComponent]])) {
                    Feed *source = [[Feed alloc] initWithFileURL:[event.mp4s objectForKey:key]];
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_COMMAND_VIDEO_PLAYER object:nil userInfo:@{@"feed":source, @"command":[NSNumber numberWithInt:VideoPlayerCommandPlayFeed], @"context":STRING_LIVE2BENCH_CONTEXT}];
                    [[NSNotificationCenter defaultCenter] postNotificationName: NOTIF_SELECT_TAB          object:weakSelf userInfo:@{@"tabName":@"Live2Bench"}];
                    [weakSelf.encoderManager declareCurrentEvent:localCounterpart];
                }else{
                    //source = [[Feed alloc] initWithURLString:data quality:0];
                    Feed *source = [[Feed alloc] initWithURLString:[event.mp4s objectForKey:key] quality:0];
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_COMMAND_VIDEO_PLAYER object:nil userInfo:@{@"feed":source, @"command":[NSNumber numberWithInt:VideoPlayerCommandPlayFeed], @"context":STRING_LIVE2BENCH_CONTEXT}];
                    [[NSNotificationCenter defaultCenter] postNotificationName: NOTIF_SELECT_TAB          object:weakSelf userInfo:@{@"tabName":@"Live2Bench"}];
                    [weakSelf.encoderManager declareCurrentEvent:weakEvent];
                }
                
                

                /*if ([localCounterpart.downloadedSources containsObject:[data lastPathComponent]] || [event.downloadedSources containsObject:[data lastPathComponent]]) {
                    
                    source = [[Feed alloc] initWithFileURL:path];
                    //[localCounterpart setOnComplete:^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_COMMAND_VIDEO_PLAYER object:nil userInfo:@{@"feed":source, @"command":[NSNumber numberWithInt:VideoPlayerCommandPlayFeed], @"context":STRING_LIVE2BENCH_CONTEXT}];
                        [[NSNotificationCenter defaultCenter] postNotificationName: NOTIF_SELECT_TAB          object:weakSelf userInfo:@{@"tabName":@"Live2Bench"}];
                        
                    //}];
                    [weakSelf.encoderManager declareCurrentEvent:localCounterpart];

                } else {
                    
                    
                    NSMutableDictionary * requestData = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                                        @"user"        : [UserCenter getInstance].userHID,
                                                                                                        @"requesttime" : GET_NOW_TIME,
                                                                                                        @"device"      : [[[UIDevice currentDevice] identifierForVendor]UUIDString],
                                                                                                        @"event"       : event.name
                                                                                                        }];
                                                                                                        
    
                    
                    source = [[Feed alloc] initWithURLString:data quality:0];
                    
                    
                    //[weakEvent setOnComplete:^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_COMMAND_VIDEO_PLAYER object:nil userInfo:@{@"feed":source, @"command":[NSNumber numberWithInt:VideoPlayerCommandPlayFeed], @"context":STRING_LIVE2BENCH_CONTEXT}];
                        [[NSNotificationCenter defaultCenter] postNotificationName: NOTIF_SELECT_TAB          object:weakSelf userInfo:@{@"tabName":@"Live2Bench"}];

                    //}];
                    
                    [weakSelf.encoderManager declareCurrentEvent:weakEvent];
                    
                    
                    
//                    if (event.isBuilt){
//                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_COMMAND_VIDEO_PLAYER object:nil userInfo:@{@"feed":source, @"command":[NSNumber numberWithInt:VideoPlayerCommandPlayFeed], @"context":STRING_LIVE2BENCH_CONTEXT}];
//                        [[NSNotificationCenter defaultCenter] postNotificationName: NOTIF_SELECT_TAB          object:weakSelf userInfo:@{@"tabName":@"Live2Bench"}];
//                        [weakSelf.encoderManager declareCurrentEvent:weakEvent];



//                    } else {
//                        // The Event was not built and it will have to wait for the server to build all the tag data
//                        
//                        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_OPEN_SPINNER
//                                                                           object:nil
//                                                                         userInfo:[SpinnerView message:@"Retreving tag data..." progress:0 animated:NO ]];
//                        event.onComplete = ^(){
//                            
//                            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_COMMAND_VIDEO_PLAYER object:nil userInfo:@{@"feed":source, @"command":[NSNumber numberWithInt:VideoPlayerCommandPlayFeed], @"context":STRING_LIVE2BENCH_CONTEXT}];
//                            [[NSNotificationCenter defaultCenter] postNotificationName: NOTIF_SELECT_TAB          object:weakSelf userInfo:@{@"tabName":@"Live2Bench"}];
//                            [weakSelf.encoderManager declareCurrentEvent:weakEvent];
//                            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_TAG_RECEIVED object:weakEvent];
//                            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_CLOSE_SPINNER object:nil];
//                        };
//                        [event.parentEncoder issueCommand:EVENT_GET_TAGS priority:1 timeoutInSec:15 tagData:requestData timeStamp:GET_NOW_TIME];
//                    }


                }*/

            }];
            [_teamPick presentPopoverCenteredIn:[UIApplication sharedApplication].keyWindow.rootViewController.view
                                       animated:YES];
        };
        
        //        NSString *path = [[[self.encoderManager.localEncoder.localPath stringByAppendingPathComponent:@"events"]stringByAppendingPathComponent:event.datapath] stringByAppendingString:@".plist"];
        //        NSDictionary *plistForEvent = [[NSDictionary alloc] initWithContentsOfFile:path];
        
        
        __block FeedSelectCell *weakCell = collapsableCell;
        if([event.downloadingItemsDictionary objectForKey:data]) {
            collapsableCell.downloadButton.downloadItem = [event.downloadingItemsDictionary objectForKey:data];
            [collapsableCell.downloadButton.downloadItem addOnProgressBlock:^(float progress, NSInteger kbps) {
                weakCell.downloadButton.progress = progress;
                [weakCell.downloadButton setNeedsDisplay];
            }];
            [collapsableCell.downloadButton setNeedsDisplay];
        } else if ([localCounterpart.downloadedSources containsObject:[data lastPathComponent]] || [event.downloadedSources containsObject:[data lastPathComponent]]) {
            weakCell.downloadButton.downloadComplete = YES;
            weakCell.downloadButton.progress = 1;
            [weakCell setNeedsDisplay];
        } else {
            collapsableCell.downloadButton.downloadItem = nil;
            
            __block ARCalendarTableViewController * weakSelf = self;
            collapsableCell.downloadButtonBlock = ^(){
                
                [weakSelf onPressDownload:weakCell];
//                [Utility downloadEvent:weakCell.event sourceName:weakCell.dicKey returnBlock:
//                 ^(DownloadItem *item){
//                     DownloadItem *downloadItem = item;
//                     downloadItem.name = [NSString stringWithFormat:@"%@ at %@", event.rawData[@"visitTeam"], event.rawData[@"homeTeam"]];
//                     weakCell.downloadButton.downloadItem = downloadItem;
//                     __block FeedSelectCell *weakerCell = weakCell;
//                     [weakCell.downloadButton.downloadItem addOnProgressBlock:^(float progress, NSInteger kbps) {
//                         weakerCell.downloadButton.progress = progress;
//                         [weakerCell.downloadButton setNeedsDisplay];
//                     }];
//                     [event.downloadingItemsDictionary setObject:downloadItem forKey:data];
//                 }];
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
    
    //    cell.downloadButton.hidden = NO;
    //    cell.playButton.hidden = NO;
    
    [cell.timeLabel setText: [bothStrings[1] substringToIndex: 5]];
    [cell.dateLabel setText: bothStrings[0]];
    [cell.titleLabel setText: [NSString stringWithFormat: @"%@ at %@", event.rawData[@"visitTeam"], event.rawData[@"homeTeam"]]];
    [cell.downloadInfoLabel setText:@"0 / 0"];

    if (localOne) {
        [cell.downloadInfoLabel setText:[NSString stringWithFormat:@"%lu %@\n%lu %@", (unsigned long) (localOne.downloadedSources.count + event.downloadedSources.count), NSLocalizedString(@"Downloaded", nil), (unsigned long)event.mp4s.count, NSLocalizedString(@"Sources", nil)]];
    }

    if (event.local) {
        [cell.downloadInfoLabel setText:[NSString stringWithFormat:@"%lu Downloaded\n%lu Sources", (unsigned long)localOne.downloadedSources.count,(unsigned long)event.mp4s.count]];

    } else {
        if (localOne) {
            [cell.downloadInfoLabel setText:[NSString stringWithFormat:@"%lu Downloaded\n%lu Sources", (unsigned long)(localOne.downloadedSources.count + event.downloadedSources.count),(unsigned long)event.mp4s.count]];
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
        if ((localCounterpart && localCounterpart.downloadedSources.count > 0) || event.downloadedSources.count > 0) {
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.message isEqualToString:@"Are you sure you want to delete all these events?"] && (buttonIndex == 0 || buttonIndex == 1)) {
        NSMutableArray *indexPathsArray = [[NSMutableArray alloc]init];
        NSMutableArray *arrayOfTagsToRemove = [[NSMutableArray alloc]init];
        
        for (NSIndexPath *cellIndexPath in self.setOfDeletingCells) {
            [arrayOfTagsToRemove addObject:self.tableData[cellIndexPath.row]];
            [indexPathsArray addObject: cellIndexPath];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_DELETE_EVENT object:nil userInfo:@{@"Event" : self.tableData[cellIndexPath.row]}];
            [((Event *)self.tableData[cellIndexPath.row]).downloadedSources removeAllObjects];
            if (buttonIndex == 0) {
                //Post a notification to delete it from server.
            }
        }
        if (buttonIndex == 0) {
            [self.tableData removeObjectsInArray: arrayOfTagsToRemove];
            [self.arrayOfAllData removeObjectsInArray: arrayOfTagsToRemove];
            [self.tableView deleteRowsAtIndexPaths:indexPathsArray withRowAnimation:UITableViewRowAnimationLeft];
            
            for (Event *eventToDelete in arrayOfTagsToRemove) {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_DELETE_EVENT_SERVER object:eventToDelete];
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
                return;
            }
            Event *eventToRemove = self.tableData[self.editingIndexPath.row];
            
            if (buttonIndex == 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_DELETE_EVENT_SERVER object:eventToRemove];
                [self.arrayOfAllData removeObject:eventToRemove];
                [self.tableData removeObject: eventToRemove];
                [self.tableView deleteRowsAtIndexPaths:@[self.editingIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"calendarNeedsLayout" object:nil];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_DELETE_EVENT object:nil userInfo:@{@"Event" : eventToRemove}];
            [eventToRemove.downloadedSources removeAllObjects];
            [self removeIndexPathFromDeletion];
            
            if (buttonIndex == 1) {
                [self.tableView reloadData];
            }
        } else {
            if (buttonIndex == 0) {
                Event *eventToRemove = self.tableData[self.editingIndexPath.row];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_DELETE_EVENT_SERVER object:eventToRemove];
                [self removeIndexPathFromDeletion];
                [self.arrayOfAllData removeObject:eventToRemove];
                [self.tableData removeObject: eventToRemove];
                [self.tableView deleteRowsAtIndexPaths:@[self.editingIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"calendarNeedsLayout" object:nil];
                [self removeIndexPathFromDeletion];
            } else {
                return;
            }
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
        NSArray *arrayToRemove = [NSArray array];
        arrayToRemove = [self.arrayOfCollapsableIndexPaths copy];
        
        NSMutableArray *insertionIndexPaths = [NSMutableArray array];
        if ([event.mp4s allValues].count > 1) {
            if (self.lastSelectedIndexPath.row < indexPath.row && self.lastSelectedIndexPath) {
                for (int i = 0; i < ((NSArray *)[event.mp4s allValues]).count ; ++i) {
                    NSIndexPath *insertionIndexPath = [NSIndexPath indexPathForRow:indexPath.row - arrayToRemove.count + i + 1 inSection:indexPath.section];
                    [insertionIndexPaths addObject:insertionIndexPath];
                }
                
                self.lastSelectedIndexPath = [NSIndexPath indexPathForRow:indexPath.row -arrayToRemove.count inSection:indexPath.section];
            }else{
                for (int i = 0; i < ((NSArray *)[event.mp4s allValues]).count ; ++i) {
                    NSIndexPath *insertionIndexPath = [NSIndexPath indexPathForRow:indexPath.row + i+1 inSection:indexPath.section];
                    [insertionIndexPaths addObject:insertionIndexPath];
                }
                
                self.lastSelectedIndexPath = indexPath;
            }
        } else if (event.mp4s.count == 1) {
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



