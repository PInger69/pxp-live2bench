//
//  CalendarViewController.m
//  Live2BenchNative
//
//  Created by DEV on 2013-01-21.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "CalendarViewController.h"
#import "MemoryBar.h"
#import "UtilityClasses/Utility.h"
#import "ListPopoverController.h"
#import "CKViewController.h"
#import "ARCalendarTableViewController.h"
#import "UserCenter.h"

@interface CalendarViewController ()

@property (nonatomic, strong) UIDatePicker  * datePicker;
@property (nonatomic, strong) UIButton      * todayButton;
@property (nonatomic, strong) UIButton      * latestButton;
@property (nonatomic, strong) UIButton      * allEventsButton;

@property (nonatomic, strong) NSMutableArray  *allEvents;

@end

@implementation CalendarViewController
{
    MemoryBar                       * memoryBar;
    CKViewController                * calendarViewController;
    ARCalendarTableViewController   * tableViewController;
    NSString                        * localPath;
}

-(id)initWithAppDelegate:(AppDelegate *) appDel
{
    _appDel = appDel;
    self = [super init];
    if (self) {
        [self setMainSectionTab:@"Calendar" imageName:@"calendarTab"];
        localPath = _appDel.userCenter.localPath;
        memoryBar = [[MemoryBar alloc]initWithFrame:CGRectMake(720, 75, 290, 25)];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    tableViewController      = [[ARCalendarTableViewController alloc]init];
    [tableViewController.view setFrame:CGRectMake(502, 110, 518, 650)];
    [tableViewController.tableView setAutoresizingMask:UIViewAutoresizingNone];
    tableViewController.localPath = localPath;

    calendarViewController                      = [[CKViewController alloc] init];
    [calendarViewController setFrame: CGRectMake(5, 110, 485, 400)];
    
    [self addChildViewController:tableViewController];
    [self.view addSubview: tableViewController.tableView];
    [self.view addSubview:calendarViewController.view];

    UIView *pickerArea = [[UIView alloc] initWithFrame:CGRectMake(5, 530, 486, 230)];
    pickerArea.layer.borderWidth = 0.7f;
    pickerArea.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.view addSubview:pickerArea];
    
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(5, 540, 486, 200)];
    [self.datePicker addTarget:self action:@selector(fastPick:) forControlEvents:UIControlEventValueChanged];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    [self.view addSubview:self.datePicker];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(datePicked:) name:@"datePicked" object:nil];
    
    self.todayButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 720, 162, 40)];
    [self.todayButton setTitle:@"Today" forState:UIControlStateNormal];
    self.todayButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.todayButton.layer.borderWidth = 0.5f;
    [self.todayButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [self.todayButton addTarget:self action:@selector(goBackToday:) forControlEvents:UIControlEventTouchUpInside];
    [self.todayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    self.todayButton.showsTouchWhenHighlighted = YES;
    [self.view addSubview:self.todayButton];
    
    self.latestButton = [[UIButton alloc] initWithFrame:CGRectMake(167, 720, 162, 40)];
    [self.latestButton setTitle:@"Latest Events" forState:UIControlStateNormal];
    self.latestButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.latestButton.layer.borderWidth = 0.5f;
    [self.latestButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [self.latestButton addTarget:self action:@selector(goToLatestEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.latestButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    self.latestButton.showsTouchWhenHighlighted = YES;
    [self.view addSubview:self.latestButton];
    
    self.allEventsButton = [[UIButton alloc] initWithFrame:CGRectMake(329, 720, 162, 40)];
    [self.allEventsButton setTitle:@"All Events" forState:UIControlStateNormal];
    self.allEventsButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.allEventsButton.layer.borderWidth = 0.5f;
    [self.allEventsButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [self.allEventsButton addTarget:self action:@selector(goToAllEvents:) forControlEvents:UIControlEventTouchUpInside];
    [self.allEventsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    self.allEventsButton.showsTouchWhenHighlighted = YES;
    [self.view addSubview:self.allEventsButton];
    
    [self.view addSubview:memoryBar];
    
    tableViewController.arrayOfAllData = [[_appDel.encoderManager.masterEncoder.allEvents allValues] mutableCopy];
    //tableViewController.arrayOfAllData = _appDel.encoderManager.masterEncoder.allEvents;
    [tableViewController.arrayOfAllData addObjectsFromArray:[[_appDel.encoderManager.localEncoder.allEvents allValues] mutableCopy]];
    calendarViewController.arrayOfAllData = [[_appDel.encoderManager.masterEncoder.allEvents allValues] mutableCopy];
    //calendarViewController.arrayOfAllData = _appDel.encoderManager.masterEncoder.allEvents;
    [calendarViewController.arrayOfAllData addObjectsFromArray:[[_appDel.encoderManager.localEncoder.allEvents allValues] mutableCopy]];
    tableViewController.encoderManager = _appDel.encoderManager;
}

- (void)goToLatestEvent:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"goToLatestEvent" object:self];
}

-(void) goToAllEvents: (id) sender{
    [tableViewController showAllData];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"goToAllEvents" object:self];
}

- (void)datePicked:(NSNotification *)note
{
    [self.datePicker setDate:note.userInfo[@"date"] animated:YES];
}

- (void)fastPick:(UIDatePicker *)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"fastPick" object:self userInfo:@{@"date" : sender.date}];
}

- (void)goBackToday:(UIButton *)sender
{
    [self.datePicker setDate:[NSDate date] animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"fastPick" object:self userInfo:@{@"date" : [NSDate date]}];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REQUEST_CALENDAR_DATA object:nil userInfo:@{@"block": ^(NSMutableArray *eventArray){
//  
//        NSMutableArray *notliveEvents = [NSMutableArray array];
//        for (NSDictionary *event in eventArray) {
//            if (!event[@"live"]) {
//                [notliveEvents addObject:event];
//            }
//        }
//    }}];
}

- (void)didReceiveMemoryWarning
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_RECEIVE_MEMORY_WARNING object:self userInfo:nil];
    [super didReceiveMemoryWarning];
}

@end
