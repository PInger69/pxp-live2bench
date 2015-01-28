//
//  GameScheduleJSONDataSource.m
//  Live2BenchNative
//
//  Created by dev on 13-01-30.
//  Copyright (c) 2013 DEV. All rights reserved.
//
//#import "JSON.h"



#import "GameScheduleJSONDataSource.h"
#import "GameSchedule.h"
#import "UIButton+Extensions.h"
#import "CalendarTableCell.h"

static BOOL IsDateBetweenInclusive(NSDate *date, NSDate *begin, NSDate *end)
{
    return [date compare:begin] != NSOrderedAscending && [date compare:end] != NSOrderedDescending;
}

@interface GameScheduleJSONDataSource ()
- (NSArray *)gameSchedulesFrom:(NSDate *)fromDate to:(NSDate *)toDate;
- (NSArray *)markedDatesFrom:(NSDate *)fromDate to:(NSDate *)toDate;
@end


@implementation GameScheduleJSONDataSource

@synthesize myTableView,calendarViewController,viewedGames,lastViewedGame;
@synthesize lastSelected;
@synthesize downloadingEventsDict;
@synthesize responseData;
@synthesize currentDownloadingEvent;
@synthesize currentDownloadButtonSender;
@synthesize isPredownloadRequest;
@synthesize isDownloadingStarted;
//@synthesize progressBar;
@synthesize currentDeletingIndexPath;
@synthesize isDeleting;
@synthesize deletedEventsArray;
@synthesize deletedServerEventsArray;
@synthesize errorCount;
@synthesize encoderManager = _encoderManager;

+ (GameScheduleJSONDataSource *)dataSource
{
    return [[[self class] alloc] init];
}

//gameScheduleItems:array containing all the events show up in the table list view according to the date which we selected;
//gameSchedules:array containing all the events saved in the server
- (id)init
{
    if ((self = [super init])) {
        
        gameScheduleItems = [[NSMutableArray alloc] init];
        gameSchedules = [[NSMutableArray alloc] init];
//        globals= [Globals instance];
        errorCount = 0;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDeletedEventsArray) name:@"oldEventsUpdated" object:nil];
        
        //dictionay of events which havenot finish downloading
        downloadingEventsDict = [[NSMutableDictionary alloc]init];
        if(!uController)
        {
            uController = [[UtilitiesController alloc]init];
        }
    }
    return self;
}

//return the row object you selected from the table list view that contains game information
- (GameSchedule *)gameScheduleAtIndexPath:(NSIndexPath *)indexPath
{
    return [gameScheduleItems objectAtIndex:indexPath.row];
}

#pragma mark UITableViewDataSource protocol conformance
//create the table list view for all the events according to the date which we selected
- (void)reloadMyTableView {
    [self.myTableView reloadData];
}
- (UITableViewCell *)OLDtableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"MyCell";
    myTableView                 = tableView;
    GameSchedule *gameSchedule  = [self gameScheduleAtIndexPath:indexPath];

    UITableViewCell *cell       = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell                        = nil; // is this basically rebuilding the cell every time???
    
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    //set the selected cell's background colour
    cell.selectedBackgroundView = [[UIView alloc]initWithFrame:CGRectZero];
    cell.selectedBackgroundView.backgroundColor = [UIColor orangeColor];
    UIView* backgroundView = [[UIView alloc] initWithFrame:cell.frame];
    backgroundView.backgroundColor = [UIColor clearColor];
    cell.backgroundView = backgroundView;
    cell.layer.borderColor = [[UIColor orangeColor] CGColor];
    cell.layer.borderWidth = 0.0f;

    //clean scrolling label
    for (UIView *subview in [cell subviews]){
        if ([subview.accessibilityLabel isEqualToString:@"scrollableText"]){
            [subview removeFromSuperview];
        }
    }
    int maxLengthOfLabel = 510;
    if(!viewedGames){
        viewedGames = [[NSMutableArray alloc]init];
    }

    //if the event was viewed, changed the cell's background colour
    for (NSString *event in viewedGames){
        if([gameSchedule.eventHid isEqualToString:event]){
            UIColor * color = [UIColor colorWithRed:255/255.0f green:206/255.0f blue:119/255.0f alpha:1.0f];
            cell.backgroundView.backgroundColor = color;
        }
    }
    
    //if the event was the last viewed one, hightlight the cell
    if ([lastViewedGame isEqualToString:gameSchedule.eventHid]){
        cell.selected = TRUE;
        [myTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    
    //clean play button and download button in the cell's subviews
    for(CustomButton *button in cell.subviews){
        if (button.tag>0) {
            [button removeFromSuperview];
        }
    }
    maxLengthOfLabel = 390;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //the local file path where downloaded video is saved
//    NSString *pathToThisEventVid = [[globals.EVENTS_PATH stringByAppendingPathComponent:gameSchedule.eventName] stringByAppendingPathComponent:@"videos/main.mp4"];
//    
//    //if there is encoder available, then display the download button
//    if (globals.HAS_MIN) {
//        DownloadButton *downloadButton;
//        downloadButton = [DownloadButton buttonWithType:UIButtonTypeCustom];
//        [downloadButton addTarget:self action:@selector(downloadVideo:event:) forControlEvents:UIControlEventTouchUpInside];
//        [downloadButton setFrame:CGRectMake(415, 7, 30,30)];
//        //don't set tag to 0, by default, uiview's tag is 0
//        [downloadButton setTag:98];
//        [cell addSubview:downloadButton];
//        
//        //if the mp4 file of the event exists and the current event is not downloading right now
//        if([fileManager fileExistsAtPath:pathToThisEventVid] && ![currentDownloadingEvent isEqualToString:gameSchedule.eventName])
//        {
//            //if the event is downloaded
//            [downloadButton setState:DBDownloaded];
//            
//        }else if([currentDownloadingEvent isEqualToString:gameSchedule.eventName]){
//            //if the event is downloading but not finishing,show the process bar
//            [downloadButton setHidden:TRUE];
////            progressBar = [[CustomProgressView alloc]initWithFrame:CGRectMake(400, 20, 60, 10)];
////            [progressBar setProgressColor:[UIColor orangeColor]];
////            [cell addSubview:progressBar];
//            
//        }else if([[downloadingEventsDict allKeys] containsObject:gameSchedule.eventName]){// && ![currentDownloadingEvent isEqualToString:gameSchedule.videoId_mp4]){
//            //this event has not started downloading
//            
//            //all the buttons are recreated, need to update the downloadingEventsDict's objective value
//            [downloadingEventsDict setObject:downloadButton forKey:gameSchedule.eventName];
//            [downloadButton setState:DBDownloading];
//        }else{
//            //if the event is not downloaded
//            [downloadButton setState:DBDefault];
//        }
//
//    }
//    
//    //add play button for all the events
//    CustomButton *playButton;
//    playButton = [CustomButton buttonWithType:UIButtonTypeCustom];
//    
//    [playButton addTarget:self action:@selector(playVideoFromCalendarV2:event:) forControlEvents:UIControlEventTouchUpInside];
//    
//    [playButton setBackgroundImage:[UIImage imageNamed:@"play_video"] forState:UIControlStateNormal];
//    [playButton setFrame:CGRectMake(480, 7, 30,30)];
//    //don't set tag to 0, by default, uiview's tag is 0
//    [playButton setTag:101];
//    [cell addSubview:playButton];
//    [cell setUserInteractionEnabled:TRUE];
//    [playButton setEnabled:YES];
//    
//    // if the event name is too long, use scrollview to show the name
//    AutoScrollLabel *textScrollView = [[AutoScrollLabel alloc] initWithFrame:CGRectMake(7, 7, maxLengthOfLabel, 30)];
//    textScrollView.text = [gameSchedule.hmnReadableName substringFromIndex:11];
//    [textScrollView setTextColor:[UIColor colorWithWhite:0.224 alpha:1.0]];
//    [cell addSubview:textScrollView];
//    [textScrollView setAccessibilityLabel:@"scrollableText"];
//    [textScrollView setFont: [UIFont defaultFontOfSize:20.0f] ];
//    [textScrollView setTextColor:[UIColor colorWithWhite:0.224 alpha:1.0]];
//    
//    [self.myTableView setDelegate:self];
//    
//    if (cell.isSelected){
//        lastSelected = indexPath;
//    }
//    
    return cell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"MyCell";
    myTableView                 = tableView;
    GameSchedule *gameSchedule  = [self gameScheduleAtIndexPath:indexPath];
    
    CalendarTableCell *cell       = (CalendarTableCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    cell                        = nil; // is this basically rebuilding the cell every time???
    
    
    if (!cell) {
        cell = [[CalendarTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell.playButton addTarget:self action:@selector(playVideoFromCalendarV2:event:) forControlEvents:UIControlEventTouchUpInside];
    }

    if(!viewedGames){
        viewedGames = [[NSMutableArray alloc]init];
    }
    
    //if the event was viewed, changed the cell's background colour
    for (NSString *event in viewedGames){
        cell.viewed = [gameSchedule.eventHid isEqualToString:event];
    }
    
    //if the event was the last viewed one, hightlight the cell
    if (cell.isLastViewed){
        cell.selected = TRUE;
        [myTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    

    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //the local file path where downloaded video is saved
//    NSString *pathToThisEventVid = [[globals.EVENTS_PATH stringByAppendingPathComponent:gameSchedule.eventName] stringByAppendingPathComponent:@"videos/main.mp4"];
//    
//    //if there is encoder available, then display the download button
//    if (_encoderManager.hasMIN) {
//
//        [cell.downloadButton addTarget:self action:@selector(downloadVideo:event:) forControlEvents:UIControlEventTouchUpInside];
//        
//        //if the mp4 file of the event exists and the current event is not downloading right now
//        if([fileManager fileExistsAtPath:pathToThisEventVid] && ![currentDownloadingEvent isEqualToString:gameSchedule.eventName])
//        {
//            //if the event is downloaded
//            [cell.downloadButton setState:DBDownloaded];
//            
//        }else if([currentDownloadingEvent isEqualToString:gameSchedule.eventName]){
//            //if the event is downloading but not finishing,show the process bar
//            [cell.downloadButton setHidden:TRUE];
////            progressBar = [[CustomProgressView alloc]initWithFrame:CGRectMake(400, 20, 60, 10)];
////            [progressBar setProgressColor:[UIColor orangeColor]];
//            [cell addSubview:progressBar];
//            
//        }else if([[downloadingEventsDict allKeys] containsObject:gameSchedule.eventName]){// && ![currentDownloadingEvent isEqualToString:gameSchedule.videoId_mp4]){
//            //this event has not started downloading
//            
//            //all the buttons are recreated, need to update the downloadingEventsDict's objective value
//            [downloadingEventsDict setObject:cell.downloadButton forKey:gameSchedule.eventName];
//            [cell.downloadButton setState:DBDownloading];
//        }else{
//            //if the event is not downloaded
//            [cell.downloadButton setState:DBDefault];
//        }
//        
//    }
//    
//    [cell setCellText:[gameSchedule.hmnReadableName substringFromIndex:11]];
//    cell.eventHid = gameSchedule.eventHid;
//    
//    [self.myTableView setDelegate:self];
//    
//    if (cell.isSelected){
//        lastSelected = indexPath;
//    }
//    
    return cell;
}



- (void)playVideoFromCalendarV2:(id)sender event:(UIEvent *)event
{
    NSIndexPath *indexPath          = [myTableView indexPathForRowAtPoint:[[[event touchesForView:sender] anyObject] locationInView:myTableView]];
    CalendarTableCell * cell        = (CalendarTableCell*)[myTableView cellForRowAtIndexPath:indexPath];
    GameSchedule *gameSchedule      = [self gameScheduleAtIndexPath:indexPath];
    _encoderManager.currentEvent    = gameSchedule.eventName;
    NSString * eventType            = _encoderManager.currentEventType;
    cell.isLastViewed               = YES;
    /// Find out what this is
//    NSMutableArray *tempArray = [[globals.TAG_MARKER_OBJ_DICT allKeys] mutableCopy];
//    for(NSString *key in tempArray){
//        [[[globals.TAG_MARKER_OBJ_DICT objectForKey:key] markerView] removeFromSuperview];
//        
//    }
//    [globals.TAG_MARKER_OBJ_DICT removeAllObjects];
    // end
    
    [uController getAllTeams];

    //initialize array of periods when get the sport info
//    if ([eventType isEqualToString:SPORT_HOCKEY] || [eventType isEqualToString:SPORT_LACROSSE]) {
//        [globals.ARRAY_OF_PERIODS removeAllObjects];
//        [globals.ARRAY_OF_PERIODS addObjectsFromArray:[[NSArray alloc]initWithObjects:@"1",@"2",@"3",@"OT",@"PS", nil]];
//    }else if([eventType isEqualToString:SPORT_SOCCER] ||[eventType isEqualToString:SPORT_BASKETBALL]){
//        [globals.ARRAY_OF_PERIODS removeAllObjects];
//        [globals.ARRAY_OF_PERIODS addObjectsFromArray:[[NSArray alloc]initWithObjects:@"1",@"2",@"EXTRA",@"PS", nil]];
//    }else if([eventType isEqualToString:SPORT_RUGBY]){
//        [globals.ARRAY_OF_PERIODS removeAllObjects];
//        [globals.ARRAY_OF_PERIODS addObjectsFromArray:[[NSArray alloc]initWithObjects:@"1",@"2",@"EXTRA", nil]];
//    }else if([eventType isEqual:SPORT_FOOTBALL]){
//        [globals.ARRAY_OF_PERIODS removeAllObjects];
//        [globals.ARRAY_OF_PERIODS addObjectsFromArray:[[NSArray alloc]initWithObjects:@"1",@"2",@"3",@"4", nil]];
//    }
//    
//    [globals.TEAM_SETUP removeAllObjects];
//    [globals.ARRAY_OF_HOCKEY_PLAYERS removeAllObjects];
//    
    
    _teamPick = nil;
    _teamPick = [[ListPopoverController alloc]initWithMessage:NSLocalizedString(@"Please select the team you want to tag:", @"dev comment - asking user to pick a team")
                                              buttonListNames:@[@"one",@"two"]];
    
    __block GameScheduleJSONDataSource * weakSelf = self;
    [_teamPick addOnCompletionBlock:^(NSString *pick) {
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_USER_CENTER_UPDATE  object:weakSelf userInfo:@{@"userPick":pick}];
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SELECT_TAB          object:weakSelf userInfo:@{@"tabName":@"Live2Bench"}];
    }];
    [_teamPick presentPopoverCenteredIn:[UIApplication sharedApplication].keyWindow.rootViewController.view
                               animated:YES];
    

    
   
}


//Depricated
//when click the play button of one event, will play the video the it
- (void)playVideoFromCalendar:(id)sender event:(UIEvent *)event
{
    //remove all the objects in global CURRENT EVENT THUMBNAILS; Then get all the tag for the new play back event
//    [globals.CURRENT_EVENT_THUMBNAILS removeAllObjects];
//    //[globals.TAG_MARKER_ITEMS removeAllObjects];
//    [globals.TAGGED_ATTS_DICT removeAllObjects];
//    [globals.TAGGED_ATTS_DICT_SHIFT removeAllObjects];
//    [globals.ARRAY_OF_COLOURS removeAllObjects];
//    [globals.THUMBS_WERE_SELECTED_CLIPVIEW removeAllObjects];
//    [globals.THUMBS_WERE_SELECTED_LISTVIEW removeAllObjects];
//    globals.THUMB_WAS_SELECTED_CLIPVIEW = nil;
//    globals.THUMB_WAS_SELECTED_LISTVIEW = nil;
//    //remove all of tagset request from previoud event
//    [globals.ARRAY_OF_TAGSET removeAllObjects];
//    //empty the toast queue
//    [globals.TOAST_QUEUE removeAllObjects];
//    //empty the app_queue 
//    [globals.APP_QUEUE.queue removeAllObjects];
//    
//    NSMutableArray *tempArray = [[globals.TAG_MARKER_OBJ_DICT allKeys] mutableCopy];
//    for(NSString *key in tempArray){
//        [[[globals.TAG_MARKER_OBJ_DICT objectForKey:key] markerView] removeFromSuperview];
//        
//    }
//    [globals.TAG_MARKER_OBJ_DICT removeAllObjects];
//    globals.SWITCH_TO_DIFFERENT_EVENT = TRUE;
//    globals.DID_GO_TO_LIVE = FALSE;
//    globals.RETAINEDPLAYBACKTIME=-1;
//    [uController showSpinner];
//    NSFileManager *fileManager=[NSFileManager defaultManager];
//    NSIndexPath *indexPath = [myTableView indexPathForRowAtPoint:[[[event touchesForView:sender] anyObject] locationInView:myTableView]];
//
//    
//    //Richard
//    CalendarTableCell * cell = (CalendarTableCell*)[myTableView cellForRowAtIndexPath:indexPath];
//    
//    
//    GameSchedule *gameSchedule = [self gameScheduleAtIndexPath:indexPath];
//    NSString *pathToThisEventVid = [[globals.EVENTS_PATH stringByAppendingPathComponent:gameSchedule.eventName] stringByAppendingPathComponent:@"videos/main.mp4"];
//    globals.WHICH_SPORT = [gameSchedule.sport lowercaseString];
//    
//    [viewedGames addObject:gameSchedule.eventHid];
//    lastViewedGame = gameSchedule.eventHid;
//
//    // Richard
//    cell.isLastViewed =YES;
//
//    
//    
//    if ([globals.WHICH_SPORT isEqualToString:@"lacrosse"]) {
//        globals.WHICH_SPORT = @"hockey";
//    }
//
//    //initialize array of periods when get the sport info
//    if ([globals.WHICH_SPORT isEqualToString:@"hockey"]) {
//        [globals.ARRAY_OF_PERIODS removeAllObjects];
//        [globals.ARRAY_OF_PERIODS addObjectsFromArray:[[NSArray alloc]initWithObjects:@"1",@"2",@"3",@"OT",@"PS", nil]];
//    }else if([globals.WHICH_SPORT isEqualToString:@"soccer"] ||[globals.WHICH_SPORT isEqualToString:@"basketball"]){
//        [globals.ARRAY_OF_PERIODS removeAllObjects];
//        [globals.ARRAY_OF_PERIODS addObjectsFromArray:[[NSArray alloc]initWithObjects:@"1",@"2",@"EXTRA",@"PS", nil]];
//    }else if([globals.WHICH_SPORT isEqualToString:@"rugby"]){
//        [globals.ARRAY_OF_PERIODS removeAllObjects];
//        [globals.ARRAY_OF_PERIODS addObjectsFromArray:[[NSArray alloc]initWithObjects:@"1",@"2",@"EXTRA", nil]];
//    }else if([globals.WHICH_SPORT isEqual:@"football"]){
//        [globals.ARRAY_OF_PERIODS removeAllObjects];
//        [globals.ARRAY_OF_PERIODS addObjectsFromArray:[[NSArray alloc]initWithObjects:@"1",@"2",@"3",@"4", nil]];
//    }
//
//    globals.EVENT_NAME = gameSchedule.eventName;
//    globals.HUMAN_READABLE_EVENT_NAME = gameSchedule.hmnReadableName;
//    NSDateFormatter *fmt = [[NSDateFormatter alloc] init] ;
//    [fmt setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
//    [fmt setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
//    [fmt setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    
//    NSDate* eventDate = [fmt dateFromString:[gameSchedule.hmnReadableName substringToIndex:19]];
//    globals.eventStartDate = eventDate;
//    
//    globals.IS_PAST_EVENT=TRUE;
//    
//    [globals.TEAM_SETUP removeAllObjects];
//    [globals.ARRAY_OF_HOCKEY_PLAYERS removeAllObjects];
//    //if we have internet then the url is on the server, otherwise it is a local file
//    if([fileManager fileExistsAtPath:pathToThisEventVid])
//    {
//        globals.CURRENT_PLAYBACK_EVENT=[[NSString stringWithFormat:@"file://%@",pathToThisEventVid] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        globals.IS_LOCAL_PLAYBACK = true;
//        
//        globals.eventExistsOnServer= FALSE;
//        for(NSDictionary *event in globals.EVENTS_ON_SERVER){
//            if ([[event objectForKey:@"name"] isEqualToString: globals.EVENT_NAME] && ![[event objectForKey:@"deleted"] boolValue] && !                                            [deletedServerEventsArray containsObject:gameSchedule.eventName]){
//                globals.eventExistsOnServer = TRUE;
//            }
//        }
//
//        //if no server or this event is not in the current server, got all the thumbnails locally
//        if (!globals.HAS_MIN || (globals.HAS_MIN && !globals.eventExistsOnServer) ) {
//            globals.CURRENT_EVENT_THUMBNAILS = [[NSMutableDictionary alloc] initWithContentsOfFile:[[globals.EVENTS_PATH stringByAppendingPathComponent:globals.EVENT_NAME] stringByAppendingPathComponent:@"Thumbnails.plist"] ];
//            if (!globals.CURRENT_EVENT_THUMBNAILS) {
//                globals.CURRENT_EVENT_THUMBNAILS = [[NSMutableDictionary alloc]init];
//            }
//            globals.DID_RECV_GAME_TAGS = TRUE;
//            [[NSNotificationCenter defaultCenter]postNotificationName:@"SportInformationUpdated" object:nil];
//        }else{
//           //if current event is in the current server, start sync me timer
//            [uController restartSyncMeTimer];
//        }
//        if(!uController)
//        {
//            uController=[[UtilitiesController alloc] init];
//        }
//        [uController getAllTeams];
//        [uController getAllGameTags];
//        
//    }else{
//        if (gameSchedule.videoId) {
//            globals.CURRENT_PLAYBACK_EVENT = [gameSchedule.videoId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//            globals.CURRENT_PLAYBACK_EVENT_BACKUP = [gameSchedule.videoId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        }else if (gameSchedule.videoId_mp4){
//            globals.CURRENT_PLAYBACK_EVENT = [gameSchedule.videoId_mp4 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//            globals.CURRENT_PLAYBACK_EVENT_BACKUP = [gameSchedule.videoId_mp4 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        }
//        globals.IS_LOCAL_PLAYBACK = false;
//        globals.eventExistsOnServer = TRUE;
//        if(!uController)
//        {
//            uController=[[UtilitiesController alloc] init];
//        }
//        [uController getAllTeams];
//        [uController getAllGameTags];
//        [uController restartSyncMeTimer];
//
//    }
//    
//    globals.THUMBNAILS_PATH = [[globals.EVENTS_PATH stringByAppendingPathComponent:globals.EVENT_NAME] stringByAppendingPathComponent:@"thumbnails"];
//    globals.VIDEOS_PATH = [[globals.EVENTS_PATH stringByAppendingPathComponent:globals.EVENT_NAME] stringByAppendingPathComponent:@"videos"];
//    globals.FIRST_LOCAL_PLAYBACK=TRUE;
//    
//    
//    
//    NSURL *videoURL = [NSURL URLWithString:globals.CURRENT_PLAYBACK_EVENT];
//    //AVPlayer *myPlayer = [AVPlayer playerWithURL:videoURL];
//    
//    [globals.VIDEO_PLAYER_LIST_VIEW setVideoURL:videoURL];
//    [globals.VIDEO_PLAYER_LIST_VIEW setPlayerWithURL:videoURL];
//    [globals.VIDEO_PLAYER_LIST_VIEW pause];
//    
//    [globals.VIDEO_PLAYER_LIVE2BENCH setVideoURL:videoURL];
//    [globals.VIDEO_PLAYER_LIVE2BENCH setPlayerWithURL:videoURL];
//    [globals.VIDEO_PLAYER_LIVE2BENCH pause];
//    globals.VIDEO_PLAYBACK_FAILED = FALSE;
//    globals.PLAYABLE_DURATION = -1;
//    
//    //init dictionary for all the tags
//    if (!globals.CURRENT_EVENT_THUMBNAILS) {
//        globals.CURRENT_EVENT_THUMBNAILS = [[NSMutableDictionary alloc]init];
//    }
//    [[NSNotificationCenter defaultCenter]postNotificationName:@"IsEventPlayback" object:nil];
    
}

//return the game which is selected in the table list view. This function will be called from SecondViewController when try to save game summary of the certain game
- (GameSchedule *)gameIsSelected{
    return gameIsSelected;
}

//when select a row from the table list view, could get the information of the event in the row
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
    
    currentCell.layer.borderWidth = 1.0f;
    
    UITableViewCell *lastCell;
    UIColor * color = [UIColor colorWithRed:255/255.0f green:206/255.0f blue:119/255.0f alpha:1.0f];
    UIColor * textColor = [UIColor colorWithWhite:0.224 alpha:1.0f];

    if (lastSelected && ![lastSelected isEqual:indexPath]) {
        lastCell = [self.myTableView cellForRowAtIndexPath:lastSelected];
        lastCell.layer.borderWidth = 0.0f;
        if (![lastCell.selectedBackgroundView.backgroundColor isEqualToColor:[UIColor orangeColor]]){
            color = [UIColor colorWithWhite:0.9f alpha:1.0f];
            textColor = [UIColor colorWithWhite:0.424f alpha:1.0f];
        }
        for (UIView* view in ((UIView*)[lastCell.subviews firstObject]).subviews){
            if ([view.accessibilityLabel isEqualToString:@"scrollableText"]){
                [((AutoScrollLabel*)view) setTextColor:textColor];
            }
        }
        lastCell.backgroundView.backgroundColor = color;
        [lastCell.textLabel setTextColor:[UIColor whiteColor]];
    }
    GameSchedule *gameSchedule = [self gameScheduleAtIndexPath:indexPath];
    gameIsSelected = gameSchedule;
    lastSelected = indexPath;
    [[NSNotificationCenter defaultCenter]postNotificationName:@"GameScheduleJSONDataSourceSelectEvent" object:nil];
}


//return the total number of events of the particular date you selected
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [gameScheduleItems count];
}



- (void)fetchGameSchedules
{
//    dataReady = NO;
//    [gameSchedules removeAllObjects];
//    NSLog(@"Fetch");
//    //contains events info from server
//    NSString *plistPath = [globals.LOCAL_DOCS_PATH stringByAppendingPathComponent:@"EventsHid.plist"];
//    
//    // Build the array from the plist
////    NSMutableArray  *eventsArray = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
// NSMutableArray  *eventsArray =     _encoderManager.allEventData;
//
//    
//    for (NSDictionary *dict in eventsArray) {
//        
//        NSString *nameStr = ([dict objectForKey:@"name"])?[dict objectForKey:@"name"]:@"";
//        
//        if (!deletedEventsArray || ![deletedEventsArray containsObject:nameStr]) {
//
//            NSString *homeTeamStr   = ([dict objectForKey:@"homeTeam"])?    [dict objectForKey:@"homeTeam"]     :@"";
//            NSString *visitTeamStr  = ([dict objectForKey:@"visitTeam"])?   [dict objectForKey:@"visitTeam"]    :@"";
//            NSString *dateStr       = ([dict objectForKey:@"date"])?        [dict objectForKey:@"date"]         :@"0";
//            NSDateFormatter *fmt    = [[NSDateFormatter alloc] init] ;
//            [fmt setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
//            [fmt setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
//            [fmt setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//
//            NSDate *d               = [fmt dateFromString:[dict objectForKey:@"date"]];
//            NSMutableString *hmnReadableName = [[NSString stringWithFormat:@"%@ %@ at %@",dateStr,visitTeamStr,homeTeamStr] mutableCopy];
//            
//
//            [gameSchedules addObject:[GameSchedule homeTeamNamed: [dict objectForKey:@"homeTeam"]
//                                                       visitTeam: [dict objectForKey:@"visitTeam"]
//                                                            date: d
//                                                         videoId: [dict objectForKey:@"vid"]
//                                                     videoId_mp4: [dict objectForKey:@"mp4"]
//                                                        eventHid: [dict objectForKey:@"hid"]
//                                                       eventName: [dict objectForKey:@"name"]
//                                                           sport: [dict objectForKey:@"sport"]
//                                                 hmnReadableName: hmnReadableName ]];
//            
//        }
//        
//    }
//    
//    
//    dataReady = YES;
//    [callback loadedDataSource:self];
//    [self.myTableView reloadData];
}


#pragma mark Fetch from the internet
//get all the events from the server(eventsArray), and save these events in the array(gameSchedules). Even item in the array gameSchedules is an object of GameSchedule (Please check the GameSchedule class for details).
- (void)oldfetchGameSchedules
{
//    dataReady = NO;
//    [gameSchedules removeAllObjects];
//
//    //contains events info from server
//    NSString *plistPath = [globals.LOCAL_DOCS_PATH stringByAppendingPathComponent:@"EventsHid.plist"];
//    
//    // Build the array from the plist
//    NSMutableArray  *eventsArray;
// //eventsArray = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
//eventsArray =     _encoderManager.allEventData;
////eventsArray =     [NSMutableArray arrayWithArray:@[]];
//    NSDateFormatter *fmt = [[NSDateFormatter alloc] init] ;
//    [fmt setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
//    [fmt setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
//    [fmt setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    for (NSDictionary *dict in eventsArray) {
////        //testing
////        if ([[dict objectForKey:@"dateFmt"]isEqualToString:@"2013-09-12_09-50-01"]) {
////            int i= 0;
////        }
//        
//        NSString *nameStr;
//        if ([dict objectForKey:@"name"]) {
//            nameStr = [dict objectForKey:@"name"];
//        }else{
//            nameStr = @"";
//        }
//        
//        // We donot want to update the "EventsHid.plist" file every time when the user delete an event.(Because we need to go through all events array to find the right event and then deleted, which is not efficient)
//        // So we added all the deleted events into the deletedEventsArray, and check it here.
//        // If the event is already deleted from the server, donot add the dict in the gameschedules array.
//        if (!deletedEventsArray || ![deletedEventsArray containsObject:nameStr]) {
//            
//            if (globals.HAS_MIN) {
//                //if any of the properties of game dictionary is nil, set it to @""; otherwise [gameSchedules addobject:XXX] will fail, then this event won't show up in the calendar
//                
//                NSString *sportStr;
//                if ([dict objectForKey:@"sport"]) {
//                    sportStr = [dict objectForKey:@"sport"];
//                    
//                }else{
//                    sportStr = @"";
//                }
//                NSString *homeTeamStr;
//                if ([dict objectForKey:@"homeTeam"]) {
//                    homeTeamStr = [dict objectForKey:@"homeTeam"];
//                }else{
//                    homeTeamStr = @"";
//                }
//                NSString *visitTeamStr;
//                if ([dict objectForKey:@"visitTeam"]) {
//                    visitTeamStr = [dict objectForKey:@"visitTeam"];
//                }else{
//                    visitTeamStr = @"";
//                }
//                NSString *dateStr;
//                if ([dict objectForKey:@"date"]) {
//                    dateStr = [dict objectForKey:@"date"];
//                }else{
//                    dateStr = @"0";
//                }
//                NSString *hidStr;
//                if ([dict objectForKey:@"hid"]) {
//                    hidStr = [dict objectForKey:@"hid"];
//                }else{
//                    hidStr = @"";
//                }
//                
//                NSDate *d = [fmt dateFromString:[dict objectForKey:@"date"]];
//                NSMutableString *hmnReadableName = [[NSString stringWithFormat:@"%@ %@ at %@",dateStr,visitTeamStr,homeTeamStr] mutableCopy];
//                
//                
//                if (![dict objectForKey:@"vid"] && [dict objectForKey:@"mp4"]) {
//                    [gameSchedules addObject:[GameSchedule homeTeamNamed:homeTeamStr
//                                                               visitTeam:visitTeamStr
//                                                                    date:d
//                                                                 videoId:[dict objectForKey:@"mp4"]
//                                                             videoId_mp4:[dict objectForKey:@"mp4"]
//                                                                eventHid:hidStr
//                                                               eventName:nameStr
//                                                                   sport:sportStr
//                                                         hmnReadableName:hmnReadableName ]];
//               
//                }else if(![dict objectForKey:@"mp4"] && [dict objectForKey:@"vid"]){
//                    [gameSchedules addObject:[GameSchedule homeTeamNamed:homeTeamStr
//                                                               visitTeam:visitTeamStr
//                                                                    date:d
//                                                                 videoId:[dict objectForKey:@"vid"]
//                                                             videoId_mp4:[dict objectForKey:@"vid"]
//                                                                eventHid:hidStr
//                                                               eventName:nameStr
//                                                                   sport:sportStr
//                                                         hmnReadableName:hmnReadableName ]];
//                }else if([dict objectForKey:@"mp4"] && [dict objectForKey:@"vid"]){
//                    [gameSchedules addObject:[GameSchedule homeTeamNamed:homeTeamStr
//                                                               visitTeam:visitTeamStr
//                                                                    date:d
//                                                                 videoId:[dict objectForKey:@"vid"]
//                                                             videoId_mp4:[dict objectForKey:@"mp4"]
//                                                                eventHid:hidStr
//                                                               eventName:nameStr
//                                                                   sport:sportStr
//                                                         hmnReadableName:hmnReadableName ]];
//                }
//            }else{
//                //if no encoder available, only display the downloaded events in the calendar
//                
//                NSFileManager *fileManager = [NSFileManager defaultManager];
//                //the local path of the downloaded video
//                NSString *pathToThisEventVid = [[globals.EVENTS_PATH stringByAppendingPathComponent:nameStr] stringByAppendingPathComponent:@"videos/main.mp4"];
//                if ([fileManager fileExistsAtPath:pathToThisEventVid]) {
//                    //if any of the properties of game dictionary is nil, set it to @""; otherwise [gameSchedules addobject:XXX] will fail, then this event won't show up in the calendar
//                    NSString *sportStr;
//                    if ([dict objectForKey:@"sport"]) {
//                        sportStr = [dict objectForKey:@"sport"];
//                        
//                    }else{
//                        sportStr = @"";
//                    }
//                    NSString *homeTeamStr;
//                    if ([dict objectForKey:@"homeTeam"]) {
//                        homeTeamStr = [dict objectForKey:@"homeTeam"];
//                    }else{
//                        homeTeamStr = @"";
//                    }
//                    NSString *visitTeamStr;
//                    if ([dict objectForKey:@"visitTeam"]) {
//                        visitTeamStr = [dict objectForKey:@"visitTeam"];
//                    }else{
//                        visitTeamStr = @"";
//                    }
//                    NSString *dateStr;
//                    if ([dict objectForKey:@"date"]) {
//                        dateStr = [dict objectForKey:@"date"];
//                    }else{
//                        dateStr = @"0";
//                    }
//                    NSString *hidStr;
//                    if ([dict objectForKey:@"hid"]) {
//                        hidStr = [dict objectForKey:@"hid"];
//                    }else{
//                        hidStr = @"";
//                    }
//                    
//                    NSDate *d = [fmt dateFromString:[dict objectForKey:@"date"]];
//                    NSMutableString *hmnReadableName = [NSString stringWithFormat:@"%@ %@ at %@",dateStr,visitTeamStr,homeTeamStr];
//                    if (![dict objectForKey:@"vid"] && [dict objectForKey:@"mp4"]) {
//                        [gameSchedules addObject:[GameSchedule homeTeamNamed:homeTeamStr visitTeam:visitTeamStr date:d videoId:[dict objectForKey:@"mp4"] videoId_mp4:[dict objectForKey:@"mp4"] eventHid:hidStr eventName:nameStr sport:sportStr hmnReadableName:hmnReadableName ]];
//                    }else if(![dict objectForKey:@"mp4"] && [dict objectForKey:@"vid"]){
//                        [gameSchedules addObject:[GameSchedule homeTeamNamed:homeTeamStr visitTeam:visitTeamStr date:d videoId:[dict objectForKey:@"vid"] videoId_mp4:[dict objectForKey:@"vid"] eventHid:hidStr eventName:nameStr sport:sportStr hmnReadableName:hmnReadableName ]];
//                    }else if([dict objectForKey:@"mp4"] && [dict objectForKey:@"vid"]){
//                        [gameSchedules addObject:[GameSchedule homeTeamNamed:homeTeamStr visitTeam:visitTeamStr date:d videoId:[dict objectForKey:@"vid"] videoId_mp4:[dict objectForKey:@"mp4"] eventHid:hidStr eventName:nameStr sport:sportStr hmnReadableName:hmnReadableName ]];
//                    }
//                    
//                }
//            }
//
//        }
//        
//    }
//    
//        
//    dataReady = YES;
//    [callback loadedDataSource:self];
//    [self.myTableView reloadData];
}

#pragma mark KalDataSource protocol conformance
//get all the data of the events and load it
- (void)presentingDatesFrom:(NSDate *)fromDate to:(NSDate *)toDate delegate:(id<KalDataSourceCallbacks>)delegate
{
    if (dataReady) {
        [callback loadedDataSource:self];
        return;
    }
    
    callback = delegate;
    [self fetchGameSchedules];
}
//return an array contains events in the month you selected
- (NSArray *)markedDatesFrom:(NSDate *)fromDate to:(NSDate *)toDate
{
    if (!dataReady)
        return [NSArray array];
    
    return [[self gameSchedulesFrom:fromDate to:toDate] valueForKeyPath:@"date"];
}
// load the events of the date you selected to the table list view
- (void)loadItemsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    if (!dataReady)
        return;
//return an array contains events in the date you seleted
    lastSelected = nil;
    [gameScheduleItems addObjectsFromArray:[self gameSchedulesFrom:fromDate to:toDate]];
}
//when selected a new date or month, remove all the events which were selected from the array
- (void)removeAllItems
{
    [gameScheduleItems removeAllObjects];
      [[NSNotificationCenter defaultCenter]
     postNotificationName:@"GameScheduleJSONDataSourceClearEvents"
     object:self];
}

#pragma mark -
//return an array contains events which happens between the fromDate and toDate. Example1,when selected month Feb.,the dates from Jan.27 to Mar.2 will display in the calendar(please check the calendar),then the fromDate is Jan.27,toDate is Mar.2, all the events between Jan.27 and Mar.2 will be added to the array.Example2,when selected date March 1st, then the fromDate is March 1st,  toDate is March 1st, all the events between March 1st and March 1st (which is March 1st), will be added to the array. 
- (NSArray *)gameSchedulesFrom:(NSDate *)fromDate to:(NSDate *)toDate
{
   
    NSMutableArray *matches = [NSMutableArray array];
    for (GameSchedule *gameSchedule in gameSchedules){
        if (IsDateBetweenInclusive(gameSchedule.date, fromDate, toDate)){
            [matches addObject:gameSchedule];
        }
    }

    return matches;
}


//download game video from the server
-(void)downloadVideo:(id)sender event:(UIEvent*)event{
    
//    UIAlertView *alert = [[UIAlertView alloc] init];
//    [alert setTitle:@"myplayXplay"];
//    [alert setMessage:@"Please connect your device via USB. Downloading from wifi will take longer time."];
//    [alert setDelegate:self]; //set delegate to self so we can catch the response in a delegate method
//    [alert addButtonWithTitle:@"OK"];
//    [alert setAccessibilityValue:@"download"];
//    [alert show];
//    [globals.ARRAY_OF_POPUP_ALERT_VIEWS addObject:alert];
    
    NSIndexPath *indexPath = [myTableView indexPathForRowAtPoint:[[[event touchesForView:sender] anyObject] locationInView:myTableView]];
    //get the video's mp4 file path
    GameSchedule *gameSchedule = [self gameScheduleAtIndexPath:indexPath];
    if (![[downloadingEventsDict allKeys] containsObject:gameSchedule.eventName]) {
        [downloadingEventsDict setObject:sender forKey:gameSchedule.eventName];
    }
    
    DownloadButton *downloadButton = (DownloadButton*)sender;
    [downloadButton setState:DBDownloading];
    
//    if (downloadingEventsDict.count == 1) {
//        isPredownloadRequest = TRUE;
//        isDownloadingStarted = FALSE;
//        currentDownloadingEvent = gameSchedule.eventName;
//        currentDownloadButtonSender = nil;
//        currentDownloadButtonSender = sender;
//        //convert string to url and send request
//        NSURL *predownloadURL = [[NSURL alloc]initWithString:[[NSString stringWithFormat:@"%@/min/ajax/prepdown/?event=%@",globals.URL,currentDownloadingEvent] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//        NSURLRequest *request = [NSURLRequest requestWithURL:predownloadURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:120];
//        NSURLConnection *conn = [[NSURLConnection alloc] init];
//        (void)[conn initWithRequest:request delegate:self];
//        //update the downloadButton's state
//        
//    }
}

-(void)predownloadCallback{
//    UIAlertView *alert = [[UIAlertView alloc] init];
//    [alert setTitle:@"myplayXplay"];
//    [alert setMessage:@"Predownload success!"];
//    [alert setDelegate:self]; //set delegate to self so we can catch the response in a delegate method
//    [alert addButtonWithTitle:@"OK"];
//    [alert show];
  
//    isPredownloadRequest = FALSE;
//    isDownloadingStarted = FALSE;
//    NSURL *startDownloadURL = [[NSURL alloc]initWithString:[[NSString stringWithFormat:@"%@/min/dlstart.php/?event=%@",globals.URL,currentDownloadingEvent] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    NSURLRequest *request = [NSURLRequest requestWithURL:startDownloadURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:120];
//    NSURLConnection *conn = [[NSURLConnection alloc] init];
//    (void)[conn initWithRequest:request delegate:self];
    
}

-(void)trackDownloadProcess{
    
//    isDownloadingStarted = TRUE;
//    NSURL *downloadURL = [[NSURL alloc]initWithString:[[NSString stringWithFormat:@"%@/min/ajax/dlprogress",globals.URL] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:120];
//    NSURLConnection *conn = [[NSURLConnection alloc] init];
//    (void)[conn initWithRequest:request delegate:self];
}

-(void)sendNextDownloadRequest{
//    errorCount = 0;
//    isPredownloadRequest = TRUE;
//    isDownloadingStarted = FALSE;
//    currentDownloadingEvent = [[downloadingEventsDict allKeys] objectAtIndex:0];
//    currentDownloadButtonSender = [downloadingEventsDict objectForKey:currentDownloadingEvent];
//    NSURL *predownloadURL = [[NSURL alloc]initWithString:[[NSString stringWithFormat:@"%@/min/ajax/prepdown/?event=%@",globals.URL,currentDownloadingEvent] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    NSURLRequest *request = [NSURLRequest requestWithURL:predownloadURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:120];
//    NSURLConnection *conn = [[NSURLConnection alloc] init];
//    (void)[conn initWithRequest:request delegate:self];
//    DownloadButton *downloadButton = (DownloadButton*)currentDownloadButtonSender;
//    [downloadButton setState:DBDownloading];
}

/*********
 the following NSURLConnection protocal methods are used for receiving download response
 *******/

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
//    // Append the new data to the instance variable you declared
//    [responseData appendData:data];
//    if(responseData.length > 10000000){
//        
//        NSError* error;
//        NSFileManager *fileManager = [NSFileManager defaultManager];
//        if(![fileManager fileExistsAtPath:globals.EVENTS_PATH])
//        {
//            [fileManager createDirectoryAtPath:globals.EVENTS_PATH withIntermediateDirectories:YES attributes:nil error:&error];
//		}
////        NSString *videoName = [[currentBookmark objectForKey:@"event"] stringByAppendingFormat:@"_%@",[[currentBookmark objectForKey:@"vidurl"] lastPathComponent]];
////        //add video to directory
////        NSString *videoFilePath = [globals.BOOKMARK_VIDEO_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",videoName]];
//        NSFileHandle *output = [NSFileHandle fileHandleForWritingAtPath:globals.EVENTS_PATH];
//        if(output == nil) {
//            [[NSFileManager defaultManager] createFileAtPath:globals.EVENTS_PATH contents:nil attributes:nil];
//            output = [NSFileHandle fileHandleForWritingAtPath:globals.EVENTS_PATH];
//        } else {
//            [output seekToEndOfFile];
//        }
//        
//		//[output truncateFileAtOffset:[output seekToEndOfFile]]; //setting aFileHandle to write at the end of the file
//		
//		[output writeData:responseData]; //actually write the data
//        
//        //        unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:videoFilePath error:nil] fileSize];
//        //        if (fileSize){
//        //            ////////NSLog(@"Length of file: %llu", fileSize);
//        //        }
//		responseData = nil;
//		responseData = [[NSMutableData alloc] init];
//	}
//
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
//    // The request is complete and data has been received
//    // You can parse the stuff in your instance variable now
//    if (!responseData) {
//        return;
//    }
//    
//    id json;
//    json = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
//    
//    if (isDeleting) {
//        if ([[json objectForKey:@"success"]integerValue] == 0) {
//            
//            NSString *errorMsg = [NSString stringWithFormat:@"Deleting event: %@ failed. Please try it again later.",currentDownloadingEvent];
//            CustomAlertView *alert = [[CustomAlertView alloc] init];
//            [alert setTitle:@"myplayXplay"];
//            [alert setMessage:errorMsg];
//            [alert setDelegate:self]; //set delegate to self so we can catch the response in a delegate method
//            [alert addButtonWithTitle:@"OK"];
//            //[alert addButtonWithTitle:@"CANCEL"];
//            [alert setAccessibilityValue:@"deleteError"];
//            [alert show];
////            [globals.ARRAY_OF_POPUP_ALERT_VIEWS addObject:alert];
//        }else{
//            GameSchedule *gameSchedule = [self gameScheduleAtIndexPath:currentDeletingIndexPath];
//            NSFileManager *fileManager = [NSFileManager defaultManager];
//            //the local file path where downloaded video is saved
//            NSString *pathToThisEventVid = [[globals.EVENTS_PATH stringByAppendingPathComponent:gameSchedule.eventName] stringByAppendingPathComponent:@"videos/main.mp4"];
//           
//            //remove this game from the array of the selected date's games if it is deleted from the server and it was not downloaded
//            if (![fileManager fileExistsAtPath:pathToThisEventVid]) {
//                
//                if (!deletedEventsArray) {
//                    deletedEventsArray = [[NSMutableArray alloc]initWithObjects:gameSchedule.eventName, nil];
//                }else{
//                    [deletedEventsArray addObject:gameSchedule.eventName];
//                }
//                [gameScheduleItems removeObject:gameSchedule];
//                [gameSchedules removeObject:gameSchedule];
//                //if the deleted event was not downloaded and it is the event currently playing, reset avplayer and all globals inform
//                if ([globals.EVENT_NAME isEqualToString:gameSchedule.eventName]) {
//                    
//                    [self resetVideoPlayerInfo];
//                }
//
//            }
//            
//            //add the event deleted from the server to the deletedServerEventsArray;
//            //This array will be used to check whether the event exists in the server or not before the eventsHid.plist file is updated
//            if (!deletedServerEventsArray) {
//                deletedServerEventsArray = [[NSMutableArray alloc]initWithObjects:gameSchedule.eventName, nil];
//            }else{
//                [deletedServerEventsArray addObject:gameSchedule.eventName];
//            }
//            
//            [myTableView reloadData];
//            
//        }
//        isDeleting = FALSE;
//    }else{
//        
//        if (isPredownloadRequest) {
//            responseData = nil;
//            if ([[json objectForKey:@"success"]integerValue] == 0) {
//                //TODO:if the current event was downloaded from other encoder, could not generate bookmark from current servr and no error msg received from current encoder
//                
//                //after resent request 3 times, still get error pop up error msg
//                if (errorCount > 2) {
//                    errorCount = 0;
//                    //for debugging
//                    NSString *errorMsg = [NSString stringWithFormat:@"Download Error: %@. \nPlease try it again later.",[json objectForKey:@"msg"]];
//                    CustomAlertView *alert = [[CustomAlertView alloc] init];
//                    [alert setTitle:@"myplayXplay"];
//                    [alert setMessage:errorMsg];
//                    [alert setDelegate:self]; //set delegate to self so we can catch the response in a delegate method
//                    [alert addButtonWithTitle:@"OK"];
//                    //[alert addButtonWithTitle:@"CANCEL"];
//                    [alert setAccessibilityValue:@"downloadError"];
//                    [alert show];
////                    [globals.ARRAY_OF_POPUP_ALERT_VIEWS addObject:alert];
//                    
//                }else{
//                    
////                    //for debugging
////                    NSString *debugStr = [NSString stringWithFormat:@"Retry predownload. error msg : %@, error count: %d",[json objectForKey:@"msg"],errorCount];
////                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"myplayXplay" message:debugStr delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
////                    [alertView show];
////                    
//                    [self performSelector:@selector(retryPredownload) withObject:nil afterDelay:2];
//                }
//                errorCount++;
//                
//            }else{
//                //errorCount = 0;
//                [self predownloadCallback];
//            }
//            isPredownloadRequest = FALSE;
//            
//        }else if(!isDownloadingStarted){
//            responseData = nil;
//            if ([[json objectForKey:@"success"]integerValue] == 0) {
//                //TODO:if the current event was downloaded from other encoder, could not generate bookmark from current servr and no error msg received from current encoder
//                //after resent request 3 times, still get error pop up error msg
//                if (errorCount > 2) {
//                     errorCount = 0;
//                    NSString *errorMsg = [NSString stringWithFormat:@"Downloading Error: %@. \nPlease try it again later.",[json objectForKey:@"msg"]];
//                    CustomAlertView *alert = [[CustomAlertView alloc] init];
//                    [alert setTitle:@"myplayXplay"];
//                    [alert setMessage:errorMsg];
//                    [alert setDelegate:self]; //set delegate to self so we can catch the response in a delegate method
//                    [alert addButtonWithTitle:@"OK"];
//                    //[alert addButtonWithTitle:@"CANCEL"];
//                    [alert setAccessibilityValue:@"downloadError"];
//                    [alert show];
////                    [globals.ARRAY_OF_POPUP_ALERT_VIEWS addObject:alert];
//                }else{
////                    //for debugging
////                    NSString *debugStr = [NSString stringWithFormat:@"Retry start download. error msg : %@, error count: %d",[json objectForKey:@"msg"],errorCount];
////                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"myplayXplay" message:debugStr delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
////                    [alertView show];
////                    
//                    //resent the start download request
//                    [self performSelector:@selector(predownloadCallback) withObject:nil afterDelay:2];
//                }
//                
//                errorCount++;
//            }else{
//                //            UIAlertView *alert = [[UIAlertView alloc] init];
//                //            [alert setTitle:@"myplayXplay"];
//                //            [alert setMessage:@"Start Download success!"];
//                //            [alert setDelegate:self]; //set delegate to self so we can catch the response in a delegate method
//                //            [alert addButtonWithTitle:@"OK"];
//                //            [alert show];
//                 //errorCount = 0;
//                [self trackDownloadProcess];
//            }
//        }else {
//            
//            int status = [[json objectForKey:@"status"]intValue];
//            
//            NSString *statusMsg;
//            switch(status){
//                case -1: //idevcopy app crashed - retry download
//                    statusMsg = @"";//@"Error - please retry";
//                    break;
//                case 0:
//                    statusMsg = @"Success";
//                    break;
//                case 1:
//                    statusMsg = @"Not enough space";
//                    break;
//                case 4:
//                    statusMsg = @"Connect iPad via USB";
//                    break;
//                case 7:
//                    statusMsg = @"Make sure you clicked TRUST this computer";
//                    break;
//                default:
//                    statusMsg= [NSString stringWithFormat:@"Error %i",status+1];
//                    break;
//            }
//            
//            if (status != 0) {
//                errorCount++;
//                
////                //for debugging
////                NSString *debugStr = [NSString stringWithFormat:@"Redownload. error msg : %@, error count: %d",statusMsg,errorCount];
////                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"myplayXplay" message:debugStr delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
////                [alertView show];
//                
//                //if continuously get error for three times, pop up the error message and stop the downloading process;
//                //else keep sending downloading request to the server
//                if (errorCount > 2) {
//                    
//                    NSString *errorMsg = [NSString stringWithFormat:@"Download Error: %@. \nPlease try it again later.",statusMsg];
//                    CustomAlertView *alert = [[CustomAlertView alloc] init];
//                    [alert setTitle:@"myplayXplay"];
//                    [alert setMessage:errorMsg];
//                    [alert setDelegate:self]; //set delegate to self so we can catch the response in a delegate method
//                    [alert addButtonWithTitle:@"OK"];
//                    //[alert addButtonWithTitle:@"CANCEL"];
//                    [alert setAccessibilityValue:@"downloadError"];
//                    [alert show];
////                    [globals.ARRAY_OF_POPUP_ALERT_VIEWS addObject:alert];
//                    errorCount = 0;
//                }else{
//                    
//                    //resent the start download request
//                    [self performSelector:@selector(predownloadCallback) withObject:nil afterDelay:2];
//
//                }
//                
//            }else{
//                
//                //if success, reset errorCount
//                //errorCount = 0;
//                
//                //init progress bar
//                if (!progressBar) {
//                    DownloadButton *downloadButton = (DownloadButton*)currentDownloadButtonSender;
//                    [downloadButton setHidden:TRUE];
//                    UITableViewCell *cell = (UITableViewCell*)downloadButton.superview;
//                    progressBar = [[CustomProgressView alloc]initWithFrame:CGRectMake(400, 20, 60, 10)];
//                    [progressBar setProgressColor:[UIColor orangeColor]];
//                    [cell addSubview:progressBar];
//                }
//                
//                if([[json objectForKey:@"progress"]intValue] != 100){
//                    //if downloading not finish yet, set the proper progress value
//                    float progressValue = [[json objectForKey:@"progress"]intValue]/100.0;
//                    [progressBar setProgress: progressValue];
//                    [self trackDownloadProcess];
//                }else{
//                    //if downloading finishes, remove the progress bar
//                    [progressBar removeFromSuperview];
//                    progressBar = nil;
//                    
//                    //remove the finished event fom the downloading event dictionary
//                    [downloadingEventsDict removeObjectForKey:currentDownloadingEvent];
//                    //change the download button state
//                    DownloadButton *downloadButton = (DownloadButton*)currentDownloadButtonSender;
//                    [downloadButton setState:DBDownloaded];
//                    [downloadButton setHidden:FALSE];
//                    //reset variables
//                    currentDownloadingEvent = nil;
//                    currentDownloadButtonSender = nil;
//                    //if there are more events waiting for downloading, send the next request
//                    if (downloadingEventsDict.count>0) {
//                        [self sendNextDownloadRequest];
//                    }
//                }
//                
//            }
//            
//        }
//
//    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (isDeleting) {
        
        NSString *errorMsg = [NSString stringWithFormat:@"Deleting event: %@ failed. Please try it again later.",currentDownloadingEvent];
        CustomAlertView *alert = [[CustomAlertView alloc] init];
        [alert setTitle:@"myplayXplay"];
        [alert setMessage:errorMsg];
        [alert setDelegate:self]; //set delegate to self so we can catch the response in a delegate method
        [alert addButtonWithTitle:@"OK"];
        //[alert addButtonWithTitle:@"CANCEL"];
        [alert setAccessibilityValue:@"deleteError"];
        [alert show];
//        [globals.ARRAY_OF_POPUP_ALERT_VIEWS addObject:alert];
        
        isDeleting = FALSE;
    }else{
        errorCount++;
        if (errorCount > 2) {
            // The request has failed for some reason!
            NSString *errorMsg = [NSString stringWithFormat:@"Error: %ld.\nPlease try it again later.",(long)error.code];
            CustomAlertView *alert = [[CustomAlertView alloc] init];
            [alert setTitle:@"myplayXplay"];
            [alert setMessage:errorMsg];
            [alert setDelegate:self]; //set delegate to self so we can catch the response in a delegate method
            [alert addButtonWithTitle:@"OK"];
            //[alert addButtonWithTitle:@"CANCEL"];
            [alert setAccessibilityValue:@"downloadError"];
            [alert show];
//            [globals.ARRAY_OF_POPUP_ALERT_VIEWS addObject:alert];
            errorCount = 0;
        }else{
            if (isPredownloadRequest) {
//                //for debugging
//                NSString *debugStr = [NSString stringWithFormat:@"Retry predownload. error count: %d",errorCount];
//                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"myplayXplay" message:debugStr delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                [alertView show];
//                
                [self performSelector:@selector(retryPredownload) withObject:nil afterDelay:2];

            }else{
                [self performSelector:@selector(predownloadCallback) withObject:nil afterDelay:2];
            }
                
//                if(!isDownloadingStarted){
//                //for debugging
//                NSString *debugStr = [NSString stringWithFormat:@"Retry start download.error count: %d",errorCount];
//                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"myplayXplay" message:debugStr delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                [alertView show];
//                
//                [self performSelector:@selector(predownloadCallback) withObject:nil afterDelay:2];
//            }else{
//                //for debugging
//                NSString *debugStr = [NSString stringWithFormat:@"Redownload.error count: %d",errorCount];
//                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"myplayXplay" message:debugStr delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                [alertView show];
//                [self performSelector:@selector(predownloadCallback) withObject:nil afterDelay:2];
//            }
            
        }
      
    }
    
}

//if predownload failed, try it again
-(void)retryPredownload{
    [currentDownloadButtonSender sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return TRUE;
}
// Override to support editing the table view.
// enable swipe to delete but only on individual cells
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        
//        GameSchedule *gameSchedule = [self gameScheduleAtIndexPath:indexPath];
//        
//        BOOL existsOnServer = FALSE;
//        for(NSDictionary *event in globals.EVENTS_ON_SERVER){
//            if ([[event objectForKey:@"name"] isEqualToString: gameSchedule.eventName] && ![[event objectForKey:@"deleted"] boolValue] && ![deletedServerEventsArray containsObject:gameSchedule.eventName]){
//                existsOnServer = TRUE;
//                break;
//            }
//        }
//        
//        NSFileManager *fileManager = [NSFileManager defaultManager];
//        //the local file path where downloaded video is saved
//        NSString *pathToThisEventVid = [[globals.EVENTS_PATH stringByAppendingPathComponent:gameSchedule.eventName] stringByAppendingPathComponent:@"videos/main.mp4"];
//        CustomAlertView *alert = [[CustomAlertView alloc] init];
//        if ([fileManager fileExistsAtPath:pathToThisEventVid]) {
//            if (existsOnServer && globals.HAS_MIN){
//                
//                //this event was downloaded and exits in the current server
//                
//                [alert setTitle:@"myplayXplay"];
//                [alert setMessage:@"Are you sure you want to delete this event? If Yes, please choose to delete it from this iPad or from the server."];
//                [alert setDelegate:self]; //set delegate to self so we can catch the response in a delegate method
//                [alert addButtonWithTitle:@"Yes iPad"];
//                [alert addButtonWithTitle:@" Yes Server"];
//                [alert addButtonWithTitle:@"No"];
//                [alert setAccessibilityValue:@"localServerDeletion"];
//            }else{
//                
//                // //this event was downloaded and not exits in the current server
//                
//                [alert setTitle:@"myplayXplay"];
//                [alert setMessage:@"Are you sure you want to delete this event from this iPad?"];
//                [alert setDelegate:self]; //set delegate to self so we can catch the response in a delegate method
//                [alert addButtonWithTitle:@"Yes"];
//                [alert addButtonWithTitle:@"No"];
//                [alert setAccessibilityValue:@"localDeletion"];
//            }
//        }else{
//            
//            //this event was not downloaded and exits in the current server
//            
//            [alert setTitle:@"myplayXplay"];
//            [alert setMessage:@"Are you sure you want to delete this event from the Server?"];
//            [alert setDelegate:self]; //set delegate to self so we can catch the response in a delegate method
//            [alert addButtonWithTitle:@"Yes"];
//            [alert addButtonWithTitle:@"No"];
//            [alert setAccessibilityValue:@"serverDeletion"];
//        }
//    
//        [alert show];
//        
////        [globals.ARRAY_OF_POPUP_ALERT_VIEWS addObject:alert];
//        
//        currentDeletingIndexPath = indexPath;
//
//    }
}

// min/ajax/evtdelete/?name=XXX(eventname)&event=XXX(hid)
//delete event from the server
-(void)deleteEventFromTheServer{
//    isDeleting = TRUE;
//    GameSchedule *gameSchedule = [self gameScheduleAtIndexPath:currentDeletingIndexPath];
//    //convert string to url and send request
//    NSURL *deletionURL = [[NSURL alloc]initWithString:[[NSString stringWithFormat:@"%@/min/ajax/evtdelete/?name=%@&event=%@",globals.URL,gameSchedule.eventName,gameSchedule.eventHid] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    NSURLRequest *request = [NSURLRequest requestWithURL:deletionURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:120];
//    NSURLConnection *conn = [[NSURLConnection alloc] init];
//    (void)[conn initWithRequest:request delegate:self];

}

//delete downloaded event from local device
-(void)deleteEventFromLocalStorage:(NSString*)eventStorage{
    
//    GameSchedule *gameSchedule = [self gameScheduleAtIndexPath:currentDeletingIndexPath];
//    NSString *pathToThisEventVid = [globals.EVENTS_PATH stringByAppendingPathComponent:gameSchedule.eventName]; //stringByAppendingPathComponent:@"videos/main.mp4"];
//    NSFileManager *fileManager=[NSFileManager defaultManager];
//    
//    NSError *error;
//    
//    [fileManager removeItemAtPath:pathToThisEventVid error:&error];
//    
//    
//    NSMutableArray *modifiedLocalEventsArray = [[NSMutableArray alloc] initWithContentsOfFile:[globals.EVENTS_PATH stringByAppendingPathComponent:@"LocalEvents.plist"]];
//    if ([modifiedLocalEventsArray containsObject:gameSchedule.eventName]) {
//        [modifiedLocalEventsArray removeObject:gameSchedule.eventName];
//        [modifiedLocalEventsArray writeToFile:[globals.EVENTS_PATH stringByAppendingPathComponent:@"LocalEvents.plist"] atomically:YES];
//    }
//    
//    //[downloadedEventsArray removeObject:gameSchedule.eventName];
//    //[downloadedEventsArray writeToFile:globals.DOWNLOADED_EVENTS_PLIST atomically:YES];
//    
//    //EventStorage is "local" means this event is not in the current server;Then remove it from the calendar
//    if ([eventStorage isEqualToString:@"local"]) {
//        if (!deletedEventsArray) {
//            deletedEventsArray = [[NSMutableArray alloc]initWithObjects:gameSchedule.eventName, nil];
//        }else{
//            [deletedEventsArray addObject:gameSchedule.eventName];
//        }
//        [gameScheduleItems removeObject:gameSchedule];
//        [gameSchedules removeObject:gameSchedule];
//    }
//    
//    [self.myTableView reloadData];
//    
//    //if the deleted event is currently playing, reset the avplayer
//    if([globals.EVENT_NAME isEqualToString:gameSchedule.eventName]){
//        [self resetVideoPlayerInfo];
//    }
//
}

//if the deleted event was not downloaded and it is currently playing, reset avplayer and globals variables' info
-(void)resetVideoPlayerInfo{
//    
//    //if no live event
//    if (![globals.CURRENT_ENC_STATUS isEqualToString:encStateLive]) {
//        
//        //reset video player
//        globals.EVENT_NAME = @"";
//        globals.HUMAN_READABLE_EVENT_NAME = @"";
//        globals.CURRENT_PLAYBACK_EVENT = @"";
//        NSURL *videoURL = [NSURL URLWithString:globals.CURRENT_PLAYBACK_EVENT];
//        //AVPlayer *myPlayer = [AVPlayer playerWithURL:videoURL];
//        
//        [globals.VIDEO_PLAYER_LIVE2BENCH setVideoURL:videoURL];
//        [globals.VIDEO_PLAYER_LIVE2BENCH setPlayerWithURL:videoURL];
//        
//        [globals.VIDEO_PLAYER_LIST_VIEW setVideoURL:videoURL];
//        [globals.VIDEO_PLAYER_LIST_VIEW setPlayerWithURL:videoURL];
//        
//        globals.VIDEO_PLAYBACK_FAILED = FALSE;
//         globals.PLAYABLE_DURATION = -1;
//        
//        //reset globals info
//        
//        globals.WHICH_SPORT = @"";
//        [globals.TEAM_SETUP removeAllObjects];
//        [globals.TAGGED_ATTS_DICT removeAllObjects];
//        [globals.TAGGED_ATTS_DICT_SHIFT removeAllObjects];
//        [globals.ARRAY_OF_COLOURS removeAllObjects];
//        [globals.THUMBS_WERE_SELECTED_CLIPVIEW removeAllObjects];
//        [globals.THUMBS_WERE_SELECTED_LISTVIEW removeAllObjects];
//        globals.THUMB_WAS_SELECTED_CLIPVIEW = nil;
//        globals.THUMB_WAS_SELECTED_LISTVIEW = nil;
//        //remove all the objects in global CURRENT EVENT THUMBNAILS; Then get all the tag for the new play back event
//        [globals.CURRENT_EVENT_THUMBNAILS removeAllObjects];
//        //[globals.TAG_MARKER_ITEMS removeAllObjects];
//        [globals.ARRAY_OF_TAGSET removeAllObjects];
//        [globals.TOAST_QUEUE removeAllObjects];
//        
//        NSMutableArray *tempArray = [[globals.TAG_MARKER_OBJ_DICT allKeys] mutableCopy];
//        for(NSString *key in tempArray){
//            [[[globals.TAG_MARKER_OBJ_DICT objectForKey:key] markerView] removeFromSuperview];
//        }
//        [globals.TAG_MARKER_OBJ_DICT removeAllObjects];
//        //reset all the line,period/zone,strength info for new event
//        globals.CURRENT_F_LINE = -1;
//        globals.CURRENT_D_LINE = -1;
//        globals.CURRENT_PERIOD = -1;
//        globals.CURRENT_STRENGTH = nil;
//        globals.CURRENT_ZONE = nil;
//        [globals.DURATION_TAGS_TIME removeAllObjects];
//        [globals.DURATION_TYPE_TIMES removeAllObjects];
//
//        //update bottom view and player collection in live2bench view
//        [[NSNotificationCenter defaultCenter]postNotificationName:@"EventInformationUpdated" object:nil];
//    }else{
//        
//        //if there is live event, post notifiction to go to live
//        [[NSNotificationCenter defaultCenter]postNotificationName:@"GoToLive" object:nil];
//    }
//  

}


//alerview response for deleting events and downloading events error
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
//    if ([alertView.accessibilityValue isEqualToString:@"localServerDeletion"]) {
//        if (buttonIndex == 0)
//        {
//            //if the user press "Y Local" to delete the current downloaded event from the local storage
//            [self deleteEventFromLocalStorage:@"localServer"];
//            
//        }else if (buttonIndex == 1){
//            
//            //if the user press "Y Server" to delete the current from the server
//            
//            [self deleteEventFromTheServer];
//        }
//    }else if ([alertView.accessibilityValue isEqualToString:@"serverDeletion"]){
//        
//        //if the user press YES to delete the current from the server
//        if (buttonIndex == 0){
//            [self deleteEventFromTheServer];
//        }
//
//    }else if ([alertView.accessibilityValue isEqualToString:@"localDeletion"]){
//        
//        //if the user press "Yes" to delete the current downloaded event from the local storage
//        if (buttonIndex == 0){
//            [self deleteEventFromLocalStorage:@"local"];
//        }
//        
//    }else if([alertView.accessibilityValue isEqualToString:@"downloadError"]){
//        //delete progressBar
////        if (progressBar) {
////            [progressBar removeFromSuperview];
////            progressBar = nil;
////        }
//        
//        //if the downloading failed after processing a while, the local path pointing to the mp4 video is already created but the mp4 file is crapted
//        NSFileManager *fileManager = [NSFileManager defaultManager];
//        NSString *pathToThisEventVid = [[globals.EVENTS_PATH stringByAppendingPathComponent:currentDownloadingEvent] stringByAppendingPathComponent:@"videos/main.mp4"];
//        if ([fileManager fileExistsAtPath:pathToThisEventVid]) {
//            [fileManager removeItemAtPath:pathToThisEventVid error:nil];
//        }
//        
//        // stop downloading and empty the downloadingEventsDict
//        for(id sender in [downloadingEventsDict allValues]){
//            DownloadButton *downloadButton = (DownloadButton*)sender;
//            [downloadButton setState:DBDefault];
//            [downloadButton setHidden:FALSE];
//        }
//        [downloadingEventsDict removeAllObjects];
//        currentDownloadingEvent = nil;
//        currentDownloadButtonSender = nil;
//        
//    }
//     [CustomAlertView removeAlert:alertView];
////    [globals.ARRAY_OF_POPUP_ALERT_VIEWS removeObject:alertView];
//    
}

//if the "Events.plist" file is updated, all the events info will be updated, then old data in deleted events arrays are not useful anymore
-(void)updateDeletedEventsArray{
    [deletedServerEventsArray removeAllObjects];
    [deletedEventsArray removeAllObjects];
}


@end
