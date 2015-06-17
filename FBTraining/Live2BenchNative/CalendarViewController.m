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
#import "Utility.h"

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
        [self setMainSectionTab:NSLocalizedString(@"Calendar",nil) imageName:@"calendarTab"];
        localPath = _appDel.userCenter.localPath;
        memoryBar = [[MemoryBar alloc]initWithFrame:CGRectMake(720, 75, 290, 25)];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:NOTIF_EVENTS_ARE_READY object:nil queue:nil usingBlock:^(NSNotification *note) {
            NSMutableArray *temp = [[NSMutableArray alloc] init];
            if (_appDel.encoderManager.masterEncoder) {
                [temp addObjectsFromArray:[[_appDel.encoderManager.masterEncoder.allEvents allValues] mutableCopy]];
            } else {
                [temp addObjectsFromArray:[[_appDel.encoderManager.localEncoder.allEvents allValues] mutableCopy]];
            }
            NSMutableArray *liveEvents = [NSMutableArray array];
            for (Event *event in temp) {
                if (event.live) {
                    [liveEvents addObject:event];
                }
            }
            [temp removeObjectsInArray:liveEvents];
            
            tableViewController.arrayOfAllData = [temp mutableCopy];
            calendarViewController.arrayOfAllData = tableViewController.arrayOfAllData;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"calendarNeedsLayout" object:nil];

        }];
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
    [self.todayButton setTitle:NSLocalizedString(@"Today",nil) forState:UIControlStateNormal];
    self.todayButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.todayButton.layer.borderWidth = 0.5f;
    [self.todayButton setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
    [self.todayButton addTarget:self action:@selector(goBackToday:) forControlEvents:UIControlEventTouchUpInside];
    [self.todayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    self.todayButton.showsTouchWhenHighlighted = YES;
    [self.view addSubview:self.todayButton];
    
    self.latestButton = [[UIButton alloc] initWithFrame:CGRectMake(167, 720, 162, 40)];
    [self.latestButton setTitle:NSLocalizedString(@"Latest Events",nil) forState:UIControlStateNormal];
    self.latestButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.latestButton.layer.borderWidth = 0.5f;
    [self.latestButton setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
    [self.latestButton addTarget:self action:@selector(goToLatestEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.latestButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    self.latestButton.showsTouchWhenHighlighted = YES;
    [self.view addSubview:self.latestButton];
    
    self.allEventsButton = [[UIButton alloc] initWithFrame:CGRectMake(329, 720, 162, 40)];
    [self.allEventsButton setTitle:NSLocalizedString(@"All Events",nil) forState:UIControlStateNormal];
    self.allEventsButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.allEventsButton.layer.borderWidth = 0.5f;
    [self.allEventsButton setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
    [self.allEventsButton addTarget:self action:@selector(goToAllEvents:) forControlEvents:UIControlEventTouchUpInside];
    [self.allEventsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    self.allEventsButton.showsTouchWhenHighlighted = YES;
    [self.view addSubview:self.allEventsButton];
    
    [self.view addSubview:memoryBar];
    
    
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    if (_appDel.encoderManager.masterEncoder) {
        [temp addObjectsFromArray:[[_appDel.encoderManager.masterEncoder.allEvents allValues] mutableCopy]];
    } else {
        [temp addObjectsFromArray:[[_appDel.encoderManager.localEncoder.allEvents allValues] mutableCopy]];
    }
    NSMutableArray *liveEvents = [NSMutableArray array];
    for (Event *event in temp) {
        if (event.live) {
            [liveEvents addObject:event];
        }
    }
    [temp removeObjectsInArray:liveEvents];
    
    tableViewController.arrayOfAllData      = [temp mutableCopy];
    calendarViewController.arrayOfAllData   = tableViewController.arrayOfAllData;
    tableViewController.encoderManager      = _appDel.encoderManager;
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
}

- (void)didReceiveMemoryWarning
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_RECEIVE_MEMORY_WARNING object:self userInfo:nil];
    [super didReceiveMemoryWarning];
}

@end
