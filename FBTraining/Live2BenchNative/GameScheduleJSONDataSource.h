//
//  GameScheduleJSONDataSource.h
//  Live2BenchNative
//
//  Created by dev on 13-01-30.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Kal/src/Kal.h"
//#import "Globals.h"
#import "CalendarViewController.h"
#import "Live2BenchViewController.h"
#import "UtilitiesController.h"
#import "CustomButton.h"
#import "AutoScrollLabel.h"
#import "UIFont+Default.h" 
#import "DownloadButton.h"
//#import "CustomProgressView.h"
#import "EncoderClasses/EncoderManager.h"
#import "ListPopoverController.h"
#import "UIColor+Expanded.h"
@class GameSchedule;
@class CalendarViewController;
@class Live2BenchViewController;
@class UtilitiesController;
@class EncoderManager;
@interface GameScheduleJSONDataSource : NSObject <KalDataSource,UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>{
//    Globals *globals;
    NSMutableArray *gameScheduleItems;
    NSMutableArray *gameSchedules;
    NSMutableData *buffer;
    id<KalDataSourceCallbacks> callback;
    BOOL dataReady;
    GameSchedule *gameIsSelected;
    CalendarViewController *calendarViewController;
    UIEvent *touchEvent;
    id deleteButtonSender;
    UtilitiesController *uController;
    ListPopoverController       * _teamPick;

}

+ (GameScheduleJSONDataSource *)dataSource;
- (GameSchedule *)gameScheduleAtIndexPath:(NSIndexPath *)indexPath;
- (GameSchedule *)gameIsSelected;
//-(UITableView *)getInstanceofTableView;
- (void)fetchGameSchedules;
- (void)reloadMyTableView;

//table view used to display all the events name of the selected date
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) CalendarViewController *calendarViewController;
//array of events' hid of all the events which have been viewed
@property (nonatomic, strong) NSMutableArray *viewedGames;
//event hid of the event which was last viewed
@property (nonatomic, strong) NSString *lastViewedGame;
//index path of the cell which was last selected
@property (nonatomic, strong) NSIndexPath *lastSelected;
////array of events which have finished downloading
//@property (nonatomic, strong) NSMutableArray *downloadedEventsArray;
//when the cell's download button is pressed, add this event info the this dictionary.The format is key: event_name object: downloadButtonSender
@property (nonatomic, strong) NSMutableDictionary *downloadingEventsDict;
//response data from the server
@property (nonatomic, strong) NSMutableData *responseData;
//the event name of the current downloading event
@property (nonatomic, strong) NSString *currentDownloadingEvent;
//the download button in cell which is currently downloading
@property (nonatomic, strong) id currentDownloadButtonSender;
//when "predownload" request is sent, this value is set to TRUE
@property (nonatomic)BOOL isPredownloadRequest;
//if get success response from "dlstart" request, this value is set to TRUE
@property (nonatomic)BOOL isDownloadingStarted;
//progress bar indicates the downloading process
//@property (nonatomic, strong) CustomProgressView *progressBar;
//the index path of the cell which is selected to be deleted
@property (nonatomic, strong) NSIndexPath *currentDeletingIndexPath;
@property (nonatomic) BOOL isDeleting;
//array of events which have been deleted and won't show up in the calendar
@property (nonatomic, strong) NSMutableArray *deletedEventsArray;
//array of events which have been deleted from the server
@property (nonatomic, strong) NSMutableArray *deletedServerEventsArray;
//count for error msg, if this value is greater than 3, pop up alert view for error
@property (nonatomic)int errorCount;

@property (nonatomic,weak) EncoderManager * encoderManager;

@end
