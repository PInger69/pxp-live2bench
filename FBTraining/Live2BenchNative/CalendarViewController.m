  //
//  CalendarViewController.m
//  Live2BenchNative
//
//  Created by DEV on 2013-01-21.
//  Copyright (c) 2013 DEV. All rights reserved.
//
#import "Kal/src/Kal.h"
#import "CalendarViewController.h"
#import "UtilitiesController.h"
#import "GameScheduleJSONDataSource.h"
#import "GameScheduleDetailViewController.h"
#import "MemoryBar.h"
#import "CommentingField.h"
#import "UtilityClasses/Utility.h"
#import "ListPopoverController.h"
/*
 Note: look at keyboard and maybe disable input when lookingo for encoder
 
 */


@interface CalendarViewController ()

@end

@implementation CalendarViewController
{
    BOOL                        firstTimeLoad;
    UtilitiesController         * uController;
    MemoryBar                   * memoryBar;
    CommentingField             * gameSummaryField;
    CommentingField             * monthSummaryField;
    KalViewController           * kal;
    NSString                    * video_id;
    __weak EncoderManager       * encoderManager;
    NSDateFormatter             * _dateFormat_yyyy_MM;
    NSDateFormatter             * _dateFormat_yyyy_MM_DD;
    id                          encoderCountObserver;
    id                          encoderReadyObserver;

}
@synthesize gameScheduleJSONDataSource;


-(id)initWithAppDelegate:(AppDelegate *) appDel
{
    
    _appDel = appDel;
    self = [super init];
    if (self) {
        [self setMainSectionTab:@"Calendar" imageName:@"calendarTab"];
        encoderManager          = _appDel.encoderManager;
        
        _dateFormat_yyyy_MM     = [[NSDateFormatter alloc] init];
        [_dateFormat_yyyy_MM setDateFormat:@"yyyy-MM"];
        
        _dateFormat_yyyy_MM_DD  = [[NSDateFormatter alloc] init] ;
        [_dateFormat_yyyy_MM_DD setDateFormat:@"yyyy-MM-DD"];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    //    add notifiers for keyboard hiding/showing (when a text field gets/loses focus)
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)    name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)    name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playCurrentEvent)
                                                 name:@"IsEventPlayback"
                                               object:nil];
    
    uController                                 = [[UtilitiesController alloc]init];
    kal                                         = [[KalViewController alloc] init];
    gameScheduleJSONDataSource                  = [[GameScheduleJSONDataSource alloc] init];
    gameScheduleJSONDataSource.encoderManager   = encoderManager;
    kal.dataSource                              = gameScheduleJSONDataSource;
    [self.view addSubview:kal.view];
    [self addChildViewController:kal];
    
    //Richard Start
    [self initSummaryFields];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveCalendarNotification:)
                                                 name:@"GameScheduleJSONDataSourceClearEvents"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveCalendarNotification:)
                                                 name:@"GameScheduleJSONDataSourceSelectEvent"
                                               object:nil];

    // Richard End

    [[NSNotificationCenter defaultCenter] addObserver:gameScheduleJSONDataSource
                                             selector:@selector(fetchGameSchedules)
                                                 name:@"sync2CloudCallback"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:gameScheduleJSONDataSource
                                             selector:@selector(fetchGameSchedules)
                                                 name:@"reloadCalendarData"
                                               object:nil];
    
    encoderCountObserver = [[NSNotificationCenter defaultCenter] addObserverForName:NOTIF_ENCODER_COUNT_CHANGE object:nil queue:nil usingBlock:^(NSNotification *note) {
        // the should check to see if a encoder is removed then update the data
        [gameScheduleJSONDataSource fetchGameSchedules];
    }];
    
    encoderReadyObserver  = [[NSNotificationCenter defaultCenter] addObserverForName:NOTIF_THIS_ENCODER_IS_READY object:nil queue:nil usingBlock:^(NSNotification *note) {
        // this updates the cal when an encoder is added and build
        [gameScheduleJSONDataSource fetchGameSchedules];
        
    }];
    
    firstTimeLoad = TRUE;
    [uController startEncoderStatusTimer];
}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //update the data in calendar view
    if (!firstTimeLoad) {
        [gameScheduleJSONDataSource fetchGameSchedules];
    }else{
        firstTimeLoad = FALSE;
    }
    
    memoryBar = [[MemoryBar alloc]initWithFrame:CGRectMake(720, 75, 290, 25)];
    [self.view addSubview:memoryBar];
}

-(void)initSummaryFields
{
    monthSummaryField                       = [[CommentingField alloc]initWithFrame:CGRectMake(2, 523, 490, 180+35) title:@"Month Summary"];
    monthSummaryField.textField.delegate    = self;
    monthSummaryField.enabled               = encoderManager.hasMAX;
    [monthSummaryField onPressSavePerformSelector:@selector(saveSummary:) addTarget:self];
    [self.view addSubview:monthSummaryField];
    
    gameSummaryField                        = [[CommentingField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(monthSummaryField.frame) + 10,
                                                                                                monthSummaryField.frame.origin.y,
                                                                                                monthSummaryField.frame.size.width+28,
                                                                                                monthSummaryField.frame.size.height)
                                                                                                title:@"Event Summary"];
    gameSummaryField.textField.delegate     = self;
    gameSummaryField.enabled                = NO; /// If has MIN
    [gameSummaryField onPressSavePerformSelector:@selector(saveSummary:) addTarget:self];
    [self.view addSubview:gameSummaryField];
   
    NSString *monthYear = [_dateFormat_yyyy_MM stringFromDate:kal.selectedDate];
    
    if (![selectedMonthYear isEqualToString:monthYear]){
        selectedMonthYear   = monthYear;
        [self _updateMonthSummaryWith:monthYear];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

// Display a details screen for the selected row.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GameSchedule *gameSchedule              = [gameScheduleJSONDataSource gameScheduleAtIndexPath:indexPath];
    GameScheduleDetailViewController *vc    = [[GameScheduleDetailViewController alloc] initWithGameSchedule:gameSchedule];
    [self.view addSubview:vc.view];
    [self addChildViewController:vc];
}

-(void)saveSummary:(id)sender
{
    CommentingField *commentField   = sender;
    currentSelectedGame = [gameScheduleJSONDataSource gameIsSelected];
    
    if ([commentField.title isEqualToString:@"Month Summary"]){
        NSString *monthYear = [_dateFormat_yyyy_MM stringFromDate:kal.selectedDate];
        [encoderManager updateSummaryId:monthYear type:@"month" summary:commentField.textField.text onComplete:^(NSArray *pooled) {
            NSLog(@"month pushed");
        }];
    } else {
        NSString * videoId              = currentSelectedGame.videoId;
        NSPredicate *predicate          = [NSPredicate predicateWithFormat:@"vid = %@", videoId];
        NSArray *filteredArray          = [encoderManager.allEventData filteredArrayUsingPredicate:predicate];
        id firstFoundObject             = nil;
        firstFoundObject                = filteredArray.count > 0 ? filteredArray.firstObject : nil;
        NSMutableDictionary * dict      = [NSMutableDictionary dictionaryWithDictionary:firstFoundObject];
        NSString * hid                  = [dict objectForKey:@"hid"];
        [encoderManager updateSummaryId:hid type:@"game" summary:commentField.textField.text onComplete:^(NSArray *pooled) {
            NSLog(@"game pushed");
        }];
    }
    

}


-(void)sumSetCallback:(id)newTagInfo
{
    ////////NSLog(@"sumsetcallback: %@", newTagInfo);
}
//
-(BOOL)textViewShouldEndEditing:(UITextView *)textView{
    [UIView animateWithDuration:0.25
                     animations:^{
                         //what to do for animation
                         [self.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
                     }
                     completion:^(BOOL finished){
                     }];
    [textView resignFirstResponder];
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         //what kind of animation
                         [self.view setFrame:CGRectMake(0, -335, self.view.frame.size.width, self.view.frame.size.height)];
                     }
                     completion:^(BOOL finished){
                     }];
    ////////NSLog(@"TextViewdidbeginEditing");
}

- (void)textViewDidChange:(UITextView *)textView{
    ////////NSLog(@"TextViewdidChange");
}



//user clicked in a textbox field - animate the screen to move up with the keyboard
- (void)keyboardWillShow:(NSNotification *)note
{
 
    [UIView animateWithDuration:0.25
                     animations:^{
                         //what kind of animation
                         [self.view setFrame:CGRectMake(0, -335, self.view.frame.size.width, self.view.frame.size.height)];
                     }
                     completion:^(BOOL finished){
                     }];
}
//user clicked out of a textbox field - animate the screen to move down with the keyboard
- (void)keyboardWillHide:(NSNotification *)note
{

    [UIView animateWithDuration:0.25
                     animations:^{
                         //what to do for animation
                         [self.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
                     }
                     completion:^(BOOL finished){
                     }];
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
   
    UITouch *touch = [[event allTouches] anyObject];
    
    if ([gameSummaryField.textField isFirstResponder] && [touch view] != gameSummaryField.textField) {
        [gameSummaryField.textField resignFirstResponder];
    }
    if ([monthSummaryField.textField isFirstResponder] && [touch view] != monthSummaryField.textField) {
        [monthSummaryField.textField resignFirstResponder];
    }

    [super touchesBegan:touches withEvent:event];
}

//change the current app state, will jump to custom tab bar's "updateAppState" method
-(void)playCurrentEvent{
//    [[NSNotificationCenter defaultCenter]postNotificationName: NOTIF_APST_CHANGE
//                                                       object: self
//                                                     userInfo: @{@"state":[NSNumber numberWithInt:apstWaitPlaybackStrt]} ];
}


- (void)receiveCalendarNotification:(NSNotification *) notification
{
    if (!encoderManager.hasMAX) return;
   
    [gameSummaryField clear];
    
    if ([[notification name] isEqualToString:@"GameScheduleJSONDataSourceClearEvents"]){
        
        [gameSummaryField clear];
        NSString *monthYear             = [_dateFormat_yyyy_MM stringFromDate:kal.selectedDate];
        NSString *date                  = [_dateFormat_yyyy_MM_DD stringFromDate:kal.selectedDate];
        
        //if selecting a different date, disable the game summary control
        if (![selectedMonthDate isEqual:date]) {
            selectedMonthDate           = date;
            gameSummaryField.enabled    = NO;
        }
        
        //select a different month
        if (![selectedMonthYear isEqualToString:monthYear]){
            [monthSummaryField clear];
            selectedMonthYear = monthYear;
            [self _updateMonthSummaryWith:monthYear];
        }
    } else if ([[notification name] isEqualToString:@"GameScheduleJSONDataSourceSelectEvent"]){
        currentSelectedGame         = [gameScheduleJSONDataSource gameIsSelected];
        NSString *videoId           = currentSelectedGame.videoId;
        NSPredicate *predicate      = [NSPredicate predicateWithFormat:@"vid = %@", videoId];
        NSArray *filteredArray      = [encoderManager.allEventData filteredArrayUsingPredicate:predicate];
        id firstFoundObject         = nil;
        firstFoundObject            = filteredArray.count > 0 ? filteredArray.firstObject : nil;
        NSMutableDictionary *dict   = [NSMutableDictionary dictionaryWithDictionary:firstFoundObject];

        if ([gameScheduleJSONDataSource gameIsSelected] && dict){
            gameSummaryField.enabled        = YES;
            NSString *hid                   = [dict objectForKey:@"hid"];
            [self _updateEventSummaryWith:hid];
        } else {
            gameSummaryField.enabled = NO;
        }
    }
}

-(void)sumGetCallback:(id)getDict
{
    NSDictionary *dict = getDict;
    NSString *gameText = [dict objectForKey:@"summary"];
    [gameSummaryField setText:gameText];//Richard
}

-(void)sumGetGameCallback:(id)getDict
{
    NSDictionary *dict = getDict;
    NSString *monthText = [dict objectForKey:@"summary"];
    [monthSummaryField setText:monthText];//Richard
}


// This method is called when ever there is a month change and also when the tab is loaded
-(void)_updateMonthSummaryWith:(NSString*)aMonthYear
{
    [encoderManager reqestSummaryId:aMonthYear type:SUMMARY_TYPE_MONTH onComplete:^void(NSArray*pooled){
        NSString * monthText = @"";
        for (NSData * data in pooled) {
            NSString * checkText    = [[Utility JSONDatatoDict:data] objectForKey:@"summary"];
            NSString * trimmed      = [checkText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([trimmed length] >1){
                monthText = checkText;
            }
        }
        [monthSummaryField setText:monthText];
    }];
}

// This method is called when ever there is a month change and also when the tab is loaded
-(void)_updateEventSummaryWith:(NSString*)aEvent
{
    [encoderManager reqestSummaryId:aEvent type:SUMMARY_TYPE_EVENT onComplete:^void(NSArray*pooled){
        NSString * eventText = @"";
        for (NSData * data in pooled) {
            NSString * checkText    = [[Utility JSONDatatoDict:data] objectForKey:@"summary"];
            NSString * trimmed      = [checkText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([trimmed length] >1){
                eventText = checkText;
            }
        }
        [gameSummaryField setText:eventText];
    }];
}



-(void)viewWillDisappear:(BOOL)animated{

    //set the frame dimensions back to normal
    [self.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [CustomAlertView removeAll];
    [gameSummaryField.textField resignFirstResponder];
    [monthSummaryField.textField resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_RECEIVE_MEMORY_WARNING object:self userInfo:nil];
    [super didReceiveMemoryWarning];
}

@end
