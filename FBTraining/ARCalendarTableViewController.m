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
#import "CustomAlertControllerQueue.h"

@interface ARCalendarTableViewController ()

//@property (strong, nonatomic) NSMutableArray *tableData;
@property (strong, nonatomic) NSIndexPath *lastSelectedIndexPath;
//@property (strong, nonatomic) NSIndexPath *editingIndexPath;
@property (strong, nonatomic) NSMutableArray *arrayOfCollapsableIndexPaths;
@property (strong, nonatomic) ListPopoverController* teamPick;
@property (strong, nonatomic) ListPopoverController* cameraPick;
@property (strong, nonatomic) NSMutableDictionary *downloadSizeDict;
@property (weak,nonatomic) Event * selectedEvent;
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
        self.arrayOfSelectedEvent   = [NSMutableArray array];
        self.downloadSizeDict       = [NSMutableDictionary new];
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

    __block NSDateFormatter *theformatter = [[NSDateFormatter alloc] init];
    theformatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";

    NSArray * theSortedArray = [self.arrayOfAllData sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDate *date1 = [theformatter dateFromString:((Event*)obj1).date];
        NSDate *date2 = [theformatter dateFromString:((Event*)obj2).date];
        return [date2 compare:date1];
    }];
// for beta
//    NSArray * theSortedArray = [self.arrayOfAllData sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
//        NSDate *date1 = [theformatter dateFromString:((Event*)obj1).date];
//        NSDate *date2 = [theformatter dateFromString:((Event*)obj2).date];
//        return [date2 compare:date1];
//    }];
    return theSortedArray;
}

-(NSArray *) sortedByDate:(NSMutableArray*)list{
    
    __block NSDateFormatter *theformatter = [[NSDateFormatter alloc] init];
    theformatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSArray * theSortedArray = [list sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDate *date1 = [theformatter dateFromString:((Event*)obj1).date];
        NSDate *date2 = [theformatter dateFromString:((Event*)obj2).date];
        return [date2 compare:date1];
    }];
    return theSortedArray;
}

- (void)filterArray:(NSNotification *)note
{
    NSMutableArray *eventsOfTheDay = [NSMutableArray array];
    NSMutableArray *eventsOfTheDayLocal = [NSMutableArray array];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    
    for (Event *event in self.arrayOfAllData) {
        NSArray *bothStrings = [event.date componentsSeparatedByString:@" "];
        NSDate *date = [formatter dateFromString:bothStrings[0]];
        
        if ([self date: date isSameDayAsDate:note.userInfo[@"date"]]) {
           
            // separate local and external. you dont want to have local and external at the same time
            if (event.local) {
                [eventsOfTheDayLocal addObject:event];
            } else {
                [eventsOfTheDay addObject:event];
            }

        }
    }
    
    for (Event *event in eventsOfTheDayLocal) {
        if (![eventsOfTheDay containsObject:event]) {
            NSLog(@"%s",__FUNCTION__);
             [eventsOfTheDay addObject:event];
        }
    }
    
    
    
    self.tableData = eventsOfTheDay;
    [self.setOfDeletingCells removeAllObjects];
    [self.arrayOfCollapsableIndexPaths removeAllObjects];
    self.lastSelectedIndexPath = nil;
    [self checkDeleteAllButton];
    self.tableData = [[self sortedByDate:self.tableData]mutableCopy];
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


-(void)downloadAllButtonPress:(id)sender
{
    if (!self.selectedEvent) return;
    
    __weak Event * selectedEvent                       = self.selectedEvent;
    __block ARCalendarTableViewController * weakSelf    = self;
    
    NSArray * sourceList = [selectedEvent.feeds allKeys];
    [selectedEvent build];
    [selectedEvent setOnComplete:^{
        
        if (selectedEvent.isBuilt) {
        
            for (NSString * sourceKey in sourceList) {
                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_EM_DOWNLOAD_EVENT object:selectedEvent userInfo:@{@"source":sourceKey}];
            }
            [weakSelf reloadData];
        } else {
            NSLog(@"%s",__FUNCTION__);

        }
    }];
    
    
    
    

    
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.tableData.count + self.arrayOfCollapsableIndexPaths.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSIndexPath *firstIndexPath = [self.arrayOfCollapsableIndexPaths firstObject];
    if ([self.arrayOfCollapsableIndexPaths containsObject: indexPath]) {
        Event *event = self.tableData[firstIndexPath.row - 1];
        
        NSDictionary *urls = event.originalFeeds;
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
        
        
//        if (![collapsableCell.event.mp4s[key] isKindOfClass:[NSString class]]){
            collapsableCell.dowdloadSize.text = collapsableCell.event.mp4s[key][@"vidsize_hq"];
//        }
        
        if (!self.downloadSizeDict[data]) {
            
            NSURL * aUrl = [NSURL URLWithString:collapsableCell.event.mp4s[key][@"hq"]];
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl];
            [request setHTTPMethod:@"HEAD"];
            
            NSURLSession *session = [NSURLSession sharedSession];
            
            [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data,
                                                                      NSURLResponse * _Nullable response,
                                                                      NSError * _Nullable error) {
                
                unsigned long long size = [response expectedContentLength];
                
                double mb;
                
                if(size >0){
                    mb = size/1000000.0f;
                    
                    NSString * theFileSize = (mb < 5000)?[NSString stringWithFormat:@"%.2f MB",mb]:@"5+ GB";


//                    theFileSize = [Utility downloadByteToStringHuman:size];
                    
                    [self.downloadSizeDict setObject:theFileSize forKey:[aUrl absoluteString]];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        collapsableCell.dowdloadSize.text = theFileSize;
                    });
                }
            }]resume];
            
 
        } else {
            collapsableCell.dowdloadSize.text = self.downloadSizeDict[data];
        }
        
        
        
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
                
//                event.feeds = [[NSMutableDictionary alloc]initWithDictionary:event.originalFeeds];
                if (event.feeds.count > 1) {
//                    for (NSString *feedName in [[event.feeds copy] allKeys]) {
//                        if (![feedName isEqualToString:key]) {
//                            [event.feeds removeObjectForKey:feedName];
//                        }
//                    }
                }else if (localCounterpart.feeds.count > 1){
                    for (NSString *feedName in [[localCounterpart.feeds copy] allKeys]) {
                        if (![feedName isEqualToString:key]) {
                            [localCounterpart.feeds removeObjectForKey:feedName];
                        }
                    }
                }
                
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
    cell.downloadAll.hidden = YES;
    cell.swipeRecognizerLeft.enabled = self.swipeableMode;
    
    cell.deleteBlock = ^(UITableViewCell *theCell){
        NSIndexPath *aIndexPath = [self.tableView indexPathForCell:theCell];
        [self tableView:self.tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:aIndexPath];
        [self checkDeleteAllButton];
    };
    
    
    [cell.downloadAll addTarget:self action:@selector(downloadAllButtonPress:) forControlEvents:UIControlEventTouchUpInside];
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
        event = self.tableData[indexPath.row - self.arrayOfCollapsableIndexPaths.count];
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
    
    
    [cell.timeLabel setText: [bothStrings[1] substringToIndex: 5]];
    [cell.dateLabel setText: bothStrings[0]];
    [cell.titleLabel setText: [NSString stringWithFormat: @"%@ at %@", event.rawData[@"visitTeam"], event.rawData[@"homeTeam"]]];
    [cell.downloadInfoLabel setText:@"0 / 0"];
    [cell.leagueLabel setText:leagueString];

    if (localOne) {
        [cell.downloadInfoLabel setText:[NSString stringWithFormat:@"%lu %@\n%lu %@", (unsigned long) ([localOne.originalFeeds count]), NSLocalizedString(@"Downloaded", nil), (unsigned long)event.originalFeeds, NSLocalizedString(@"Sources", nil)]];
    }

    if (event.local) {
        [cell.downloadInfoLabel setText:[NSString stringWithFormat:@"%lu Downloaded\n%lu Sources", (unsigned long)localOne.downloadedSources.count,(unsigned long)event.originalFeeds.count]];

    } else {
        if (localOne) {
            [cell.downloadInfoLabel setText:[NSString stringWithFormat:@"%lu Downloaded\n%lu Sources", (unsigned long)([localOne.originalFeeds count]),(unsigned long)event.originalFeeds.count]];
        } else {
            
            [cell.downloadInfoLabel setText:[NSString stringWithFormat:@"%lu Downloaded\n%lu Sources", (unsigned long)event.downloadedSources.count,(unsigned long)event.originalFeeds.count]];
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
        

        // Build Alert
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"myplayXplay",nil)
                                                                        message:@"Are you sure you want to delete this Event?"
                                                                 preferredStyle:UIAlertControllerStyleAlert];
        
        
        UIAlertAction * deleteFromServerAndIpadButtons = [UIAlertAction
                                        actionWithTitle:@"Yes, delete from server and ipad"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action)
                                        {
                                            [self.tableView beginUpdates];
                                            NSMutableArray *indexPathsArray     = [[NSMutableArray alloc]init];
                                            NSMutableArray *arrayOfTagsToRemove = [[NSMutableArray alloc]init];
                                            
                                            // This deletes local event
                                            for (NSIndexPath *cellIndexPath in self.setOfDeletingCells) {
                                                [arrayOfTagsToRemove addObject:self.tableData[cellIndexPath.row]];
                                                [indexPathsArray addObject: cellIndexPath];
                                                Event *eventToDelete = self.tableData[cellIndexPath.row];
                                                [eventToDelete.downloadedSources removeAllObjects];
                                                [[LocalMediaManager getInstance] deleteEvent:[[LocalMediaManager getInstance]getEventByName:eventToDelete.name]];
                                            }

                                            // mods the data
                                            [self.tableData removeObjectsInArray: arrayOfTagsToRemove];
                                            [self.arrayOfAllData removeObjectsInArray: arrayOfTagsToRemove];
                                            [self.tableView deleteRowsAtIndexPaths:indexPathsArray withRowAnimation:UITableViewRowAnimationLeft];

                                            // destroy off the server
                                            for (Event *eventToDelete in arrayOfTagsToRemove) {
                                                [eventToDelete destroy];
                                            }
                                            
                                            [self.setOfDeletingCells removeAllObjects];

                                            [self checkDeleteAllButton];
                                            [self.tableView endUpdates];
                                            [[CustomAlertControllerQueue getInstance] dismissViewController:alert animated:YES completion:nil];
                                            [[NSNotificationCenter defaultCenter] postNotificationName:@"calendarNeedsLayout" object:nil];
                                        }];
        
        UIAlertAction * deleteFromServerButtons = [UIAlertAction
                                         actionWithTitle:@"Yes, delete from server"
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action)
                                         {
                                             [self.tableView beginUpdates];
                                             
                                             NSMutableArray *indexPathsArray     = [[NSMutableArray alloc]init];
                                             NSMutableArray *arrayOfEventsToRemove = [[NSMutableArray alloc]init];
                                             
                                             // This deletes local event
                                             for (NSIndexPath *cellIndexPath in self.setOfDeletingCells) {
                                                 [arrayOfEventsToRemove addObject:self.tableData[cellIndexPath.row]];
                                                 [indexPathsArray addObject: cellIndexPath];
                                             }
                                             
                                             // mods the data
                                             [self.tableData removeObjectsInArray: arrayOfEventsToRemove];
                                             [self.arrayOfAllData removeObjectsInArray: arrayOfEventsToRemove];
                                             [self.tableView deleteRowsAtIndexPaths:indexPathsArray withRowAnimation:UITableViewRowAnimationLeft];
                                             
                                             // destroy off the server
                                             for (Event *eventToDelete in arrayOfEventsToRemove) {
                                                 [eventToDelete destroy];
                                             }
                                             
                                             [self.setOfDeletingCells removeAllObjects];

                                             [self checkDeleteAllButton];
                                             [self.tableView endUpdates];
                                             [[CustomAlertControllerQueue getInstance] dismissViewController:alert animated:YES completion:nil];
                                             [[NSNotificationCenter defaultCenter] postNotificationName:@"calendarNeedsLayout" object:nil];
                                         }];
        
        
        UIAlertAction * deleteFromIpadButtons = [UIAlertAction
                                        actionWithTitle:@"Yes, delete from ipad only"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action)
                                        {
                                            [self.tableView beginUpdates];
                                            
                                            NSMutableArray *indexPathsArray     = [[NSMutableArray alloc]init];
                                            NSMutableArray *arrayOfTagsToRemove = [[NSMutableArray alloc]init];
                                            
                                            // This deletes local event
                                            for (NSIndexPath *cellIndexPath in self.setOfDeletingCells) {
                                                [arrayOfTagsToRemove addObject:self.tableData[cellIndexPath.row]];
                                                [indexPathsArray addObject: cellIndexPath];
                                                Event *eventToDelete = self.tableData[cellIndexPath.row];
                                                [eventToDelete.downloadedSources removeAllObjects];
                                                [[LocalMediaManager getInstance] deleteEvent:[[LocalMediaManager getInstance]getEventByName:eventToDelete.name]];
                                            }

                                            
                                            // mods the data
                                            [self.tableData removeObjectsInArray: arrayOfTagsToRemove];
                                            [self.arrayOfAllData removeObjectsInArray: arrayOfTagsToRemove];
                                            [self.tableView deleteRowsAtIndexPaths:indexPathsArray withRowAnimation:UITableViewRowAnimationLeft];
                                            

                                            
                                            [self.setOfDeletingCells removeAllObjects];
                                            
                   
                                            
                                            
                                            
                                            [self checkDeleteAllButton];
                                            [self.tableView endUpdates];
                                            [[CustomAlertControllerQueue getInstance] dismissViewController:alert animated:YES completion:nil];
                                        }];
        
        
        UIAlertAction * cancelButtons = [UIAlertAction
                                        actionWithTitle:@"No"
                                        style:UIAlertActionStyleCancel
                                        handler:^(UIAlertAction * action)
                                        {
                                            [[CustomAlertControllerQueue getInstance] dismissViewController:alert animated:YES completion:nil];
                                        }];
        
        
        
        if ((localCounterpart && [localCounterpart.originalFeeds count] > 0)) {
            [alert addAction:deleteFromServerAndIpadButtons];
            [alert addAction:deleteFromIpadButtons];
        } else {
            [alert addAction:deleteFromServerButtons];
        }
        [alert addAction:cancelButtons];
        
        
       [[CustomAlertControllerQueue getInstance]presentViewController:alert inController:self animated:YES style:AlertImportant completion:nil];
        
        [self checkDeleteAllButton];

    }
    [self.tableView endUpdates];    
}


-(void)deleteAllButtonTarget
{
    NSMutableArray * localEvents     = [[NSMutableArray alloc]init];
    NSMutableArray * encoderEvents   = [[NSMutableArray alloc]init];
    
    for (NSIndexPath *cellIndexPath in self.setOfDeletingCells) {
        Event *eventToDelete = self.tableData[cellIndexPath.row];
        [encoderEvents addObject:eventToDelete];
        
        Event *localCounterPart = [[LocalMediaManager getInstance] getEventByName:eventToDelete.name];
        
        if (localCounterPart)[localEvents addObject:localCounterPart];
    }
    
    
    
    
    
    
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"myplayXplay",nil)
                                                                    message:@"Are you sure you want to delete all these events?"
                                                             preferredStyle:UIAlertControllerStyleAlert];

    
    
    
    UIAlertAction * deleteFromServerAndIpadButtons = [UIAlertAction
                                                      actionWithTitle:@"Yes, delete from server and ipad"
                                                      style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action)
                                                      {
                                                          [self.tableView beginUpdates];
                                                          NSMutableArray *indexPathsArray     = [[NSMutableArray alloc]init];
                                                          NSMutableArray *arrayOfTagsToRemove = [[NSMutableArray alloc]init];
                                                          
                                                          // This deletes local event
                                                          for (NSIndexPath *cellIndexPath in self.setOfDeletingCells) {
                                                              [arrayOfTagsToRemove addObject:self.tableData[cellIndexPath.row]];
                                                              [indexPathsArray addObject: cellIndexPath];
                                                              Event *eventToDelete = self.tableData[cellIndexPath.row];
                                                              [eventToDelete.downloadedSources removeAllObjects];
                                                              [[LocalMediaManager getInstance] deleteEvent:[[LocalMediaManager getInstance]getEventByName:eventToDelete.name]];
                                                          }
                                                          
                                                          // mods the data
                                                          [self.tableData removeObjectsInArray: arrayOfTagsToRemove];
                                                          [self.arrayOfAllData removeObjectsInArray: arrayOfTagsToRemove];
                                                          [self.tableView deleteRowsAtIndexPaths:indexPathsArray withRowAnimation:UITableViewRowAnimationLeft];
                                                          
                                                          // destroy off the server
                                                          for (Event *eventToDelete in arrayOfTagsToRemove) {
                                                              [eventToDelete destroy];
                                                          }
                                                          
                                                          [self.setOfDeletingCells removeAllObjects];
                                                          
                                                          [self checkDeleteAllButton];
                                                          [self.tableView endUpdates];
                                                          [[CustomAlertControllerQueue getInstance] dismissViewController:alert animated:YES completion:nil];
                                                          [[NSNotificationCenter defaultCenter] postNotificationName:@"calendarNeedsLayout" object:nil];
                                                      }];
    
    UIAlertAction * deleteFromServerButtons = [UIAlertAction
                                               actionWithTitle:@"Yes, delete from server"
                                               style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action)
                                               {
                                                   
                                                   [self.tableView beginUpdates];
                                                   
                                                   NSMutableArray *indexPathsArray     = [[NSMutableArray alloc]init];
                                                   NSMutableArray *arrayOfEventsToRemove = [[NSMutableArray alloc]init];
                                                   
                                                   // This deletes local event
                                                   for (NSIndexPath *cellIndexPath in self.setOfDeletingCells) {
                                                       [arrayOfEventsToRemove addObject:self.tableData[cellIndexPath.row]];
                                                       [indexPathsArray addObject: cellIndexPath];
                                                   }
                                                   
                                                   // mods the data
                                                   [self.tableData removeObjectsInArray: arrayOfEventsToRemove];
                                                   [self.arrayOfAllData removeObjectsInArray: arrayOfEventsToRemove];
                                                   [self.tableView deleteRowsAtIndexPaths:indexPathsArray withRowAnimation:UITableViewRowAnimationLeft];
                                                   
                                                   // destroy off the server
                                                   for (Event *eventToDelete in arrayOfEventsToRemove) {
                                                       [eventToDelete destroy];
                                                   }
                                                   
                                                   [self.setOfDeletingCells removeAllObjects];
                                                   
                                                   [self checkDeleteAllButton];
                                                   [self.tableView endUpdates];
                                                   [[CustomAlertControllerQueue getInstance] dismissViewController:alert animated:YES completion:nil];
                                                   [[NSNotificationCenter defaultCenter] postNotificationName:@"calendarNeedsLayout" object:nil];
                                                   
                                               }];
    
    
    UIAlertAction * deleteFromIpadButtons = [UIAlertAction
                                             actionWithTitle:@"Yes, delete from ipad only"
                                             style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction * action)
                                             {
                                                 [self.tableView beginUpdates];

                                                 NSMutableArray * indexDeletePool = [NSMutableArray new];
                                                 
                                                 
                                                 for (NSIndexPath *cellIndexPath in self.setOfDeletingCells) {
                                                     Event * theEvent               = self.tableData[cellIndexPath.row];
                                                     Event * nonLocalEvent          = (theEvent.local)? nil : theEvent;
                                                     Event * localCounterPartEvent  = (theEvent.local)? theEvent : [[LocalMediaManager getInstance] getEventByName:theEvent.name];
                                                     
                                                     [[LocalMediaManager getInstance] deleteEvent:localCounterPartEvent];
                                                     localCounterPartEvent = nil;
                                                     // if there is no local and non local event remove the cell
                                                     if (nonLocalEvent == nil && localCounterPartEvent == nil) {
                                                         [indexDeletePool addObject:cellIndexPath];
                                                     }
                                                 }

                                                 
                                                 // mods the data
                                                 [self.tableData removeObjectsInArray:      indexDeletePool];
                                                 [self.arrayOfAllData removeObjectsInArray: indexDeletePool];
                                                 [self.tableView deleteRowsAtIndexPaths:    indexDeletePool withRowAnimation:UITableViewRowAnimationLeft];


                                                 // removes the cell
                                                 self.setOfDeletingCells = [NSMutableSet setWithArray:indexDeletePool] ;
                                                 [self checkDeleteAllButton];
                                                 [self.setOfDeletingCells removeAllObjects]; // this just clears out all the selected cells to deleate
      
                                                 [self.tableView reloadData];
                                                 [[NSNotificationCenter defaultCenter] postNotificationName:@"calendarNeedsLayout" object:nil];
                                                 
     
                                                 [self.tableView endUpdates];
                                                 [[CustomAlertControllerQueue getInstance] dismissViewController:alert animated:YES completion:nil];
                                             }];
    
    
    UIAlertAction * cancelButtons = [UIAlertAction
                                     actionWithTitle:@"No"
                                     style:UIAlertActionStyleCancel
                                     handler:^(UIAlertAction * action)
                                     {
                                         [[CustomAlertControllerQueue getInstance] dismissViewController:alert animated:YES completion:nil];
                                     }];
    
    
    
    if ([localEvents count]>0) {
        [alert addAction:deleteFromServerAndIpadButtons];
        [alert addAction:deleteFromIpadButtons];
        [alert addAction:deleteFromServerButtons];
    } else {
        [alert addAction:deleteFromServerButtons];
    }
    [alert addAction:cancelButtons];
    
    
    [[CustomAlertControllerQueue getInstance]presentViewController:alert inController:self animated:YES style:AlertImportant completion:nil];
    
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
    self.selectedEvent = event;
   
    
//    ARCalendarTableViewCell *lastCell = (ARCalendarTableViewCell *)[self.tableView cellForRowAtIndexPath: self.lastSelectedIndexPath];
//    [lastCell isSelected:NO];
    ARCalendarTableViewCell *currentCell = (ARCalendarTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    
    [currentCell isSelected:YES];
    if ([event.originalFeeds allValues].count >= 1) {
        [self.arrayOfSelectedEvent addObject:event.name];
    }
    
    if(![indexPath isEqual:self.lastSelectedIndexPath])
    {
        NSArray *arrayToRemove = [self.arrayOfCollapsableIndexPaths copy];
        
        NSMutableArray *insertionIndexPaths = [NSMutableArray array];
        if ([event.originalFeeds allValues].count > 1) {
            if (self.lastSelectedIndexPath.row < indexPath.row && self.lastSelectedIndexPath) {
                for (int i = 0; i < ((NSArray *)[event.originalFeeds allValues]).count ; ++i) {
                    NSIndexPath *insertionIndexPath = [NSIndexPath indexPathForRow:indexPath.row - arrayToRemove.count + i + 1 inSection:indexPath.section];
                    [insertionIndexPaths addObject:insertionIndexPath];
                }
                
                self.lastSelectedIndexPath = [NSIndexPath indexPathForRow:indexPath.row -arrayToRemove.count inSection:indexPath.section];
            }else{
                for (int i = 0; i < ((NSArray *)[event.originalFeeds allValues]).count ; ++i) {
                    NSIndexPath *insertionIndexPath = [NSIndexPath indexPathForRow:indexPath.row + i+1 inSection:indexPath.section];
                    [insertionIndexPaths addObject:insertionIndexPath];
                }
                
                self.lastSelectedIndexPath = indexPath;
            }
        } else if ([event.originalFeeds allValues].count == 1) {
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
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths: arrayToRemove withRowAnimation:UITableViewRowAnimationRight];
            [self.tableView endUpdates];
            self.swipeableMode = YES;
            return;
        }
        
        [self.tableView beginUpdates];
        [self.arrayOfCollapsableIndexPaths removeAllObjects];
        [self.tableView deleteRowsAtIndexPaths: arrayToRemove withRowAnimation:UITableViewRowAnimationRight];
        self.swipeableMode = NO;
        [self.arrayOfCollapsableIndexPaths addObjectsFromArray: insertionIndexPaths];
        [self.tableView insertRowsAtIndexPaths: insertionIndexPaths withRowAnimation:UITableViewRowAnimationRight];
        [self.tableView scrollToRowAtIndexPath:self.lastSelectedIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        [self.tableView endUpdates];
        
        if ([Utility hasWiFi]) currentCell.downloadAll.hidden = NO;
    }else{
        
        [self.tableView beginUpdates];
        NSArray *arrayToRemove = [self.arrayOfCollapsableIndexPaths copy];
        [self.arrayOfCollapsableIndexPaths removeAllObjects];
        [self.tableView deleteRowsAtIndexPaths: arrayToRemove withRowAnimation:UITableViewRowAnimationRight];
        NSIndexPath *temp = self.lastSelectedIndexPath;
        self.lastSelectedIndexPath = nil;
        [self.tableView reloadRowsAtIndexPaths:@[temp] withRowAnimation:NO];
        self.swipeableMode = YES;
        [self.tableView endUpdates];
        currentCell.downloadAll.hidden = YES;
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



