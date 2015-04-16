#import <CoreGraphics/CoreGraphics.h>
#import "CKViewController.h"
#import "CKCalendarView.h"
#import "Event.h"

@interface CKViewController () <CKCalendarDelegate>

@property(nonatomic, weak) CKCalendarView *calendar;
@property(nonatomic, strong) UILabel *dateLabel;
@property(nonatomic, strong) NSDateFormatter *dateFormatter;
@property(nonatomic, strong) NSDate *minimumDate;
@property(nonatomic, strong) NSArray *disabledDates;
@property(nonatomic, strong) NSMutableArray *dateArray;

@end

@implementation CKViewController

- (id)init {
    self = [super init];
    if (self) {
        CKCalendarView *calendar = [[CKCalendarView alloc] initWithStartDay:startSunday];
        self.calendar = calendar;
        calendar.delegate = self;
        
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateFormat:@"dd/MM/yyyy"];
        //self.minimumDate = [self.dateFormatter dateFromString:@"20/09/2012"];
        
        self.disabledDates = @[
                               [self.dateFormatter dateFromString:@"05/01/2013"],
                               [self.dateFormatter dateFromString:@"06/01/2013"],
                               [self.dateFormatter dateFromString:@"07/01/2013"],
                               [self.dateFormatter dateFromString:@"05/01/2013"],
                               [self.dateFormatter dateFromString:@"06/01/2014"],
                               [self.dateFormatter dateFromString:@"07/01/2014"],
                               [self.dateFormatter dateFromString:@"02/01/2015"]
                               ];
        
        calendar.onlyShowCurrentMonth = NO;
        calendar.adaptHeightToNumberOfWeeksInMonth = YES;
        
        calendar.frame = CGRectMake(0, 0, 400, 420);
        [self.view setFrame:CGRectMake(100, 100, 400, 400)];
        
        [self.view addSubview: self.calendar];
        //self.view = calendar.calendarContainer;
        //self.view = calendar;
        //self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(calendar.frame) + 4, self.view.bounds.size.width, 24)];
        //[self.view addSubview:self.dateLabel];
        
        //self.view.backgroundColor = [UIColor whiteColor];
        //self.dateArray = [[NSMutableArray alloc]init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fastPick:) name:@"fastPick" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localeDidChange) name:NSCurrentLocaleDidChangeNotification object:nil];
        //[[NSNotificationCenter defaultCenter] addObserver:self.calendar selector:@selector(setNeedsLayout) name:@"calendarNeedsLayout" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(arrayOfAllDataChanged) name:@"calendarNeedsLayout" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToLatestEvent:) name:@"goToLatestEvent" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToAllEvents:) name:@"goToAllEvents" object:nil];
        
        [self.view setAutoresizingMask:UIViewAutoresizingNone];
    }
    return self;
}

- (void)goToAllEvents:(NSNotification *)note
{
    [self.calendar selectDate:nil makeVisible:YES];
    [self calendar:self.calendar didSelectDate:nil];
    self.calendar.isAllEventsMode = YES;
    [self.calendar setNeedsLayout];
}

- (void)goToLatestEvent:(NSNotification *)note
{
    self.calendar.isAllEventsMode = NO;
    NSMutableArray *arrayOfDate = [NSMutableArray array];
    for (NSString *dateString in self.dateArray) {
        NSDate *date = [self.dateFormatter dateFromString:dateString];
        [arrayOfDate addObject:date];
    }
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"self" ascending:NO];
    NSArray *descriptors = [NSArray arrayWithObject: descriptor];
    
    
    NSArray *sortedArray = [arrayOfDate sortedArrayUsingDescriptors:descriptors];
    
    [self.calendar selectDate:[sortedArray firstObject] makeVisible:YES];
    [self calendar:self.calendar didSelectDate:[sortedArray firstObject]];
    [self.calendar setNeedsLayout];
}

- (void)fastPick:(NSNotification *)note
{
    self.calendar.isAllEventsMode = NO;
    [self.calendar selectDate:note.userInfo[@"date"] makeVisible:YES];
    [self calendar:self.calendar didSelectDate:note.userInfo[@"date"]];
    [self.calendar setNeedsLayout];
    //[self.calendar _dateButtonPressed:]
}

-(void)arrayOfAllDataChanged{
    // THE MOST MEANINGFUL LINE OF CODE EVER WRITTEN!
    self.arrayOfAllData = self.arrayOfAllData;
    [self.calendar setNeedsLayout];
}

-(void)setArrayOfAllData:(NSMutableArray *)arrayOfAllData{
    // These lines of code only get called after the app has started up
    // and the user first taps on the calendar page
    if (!self.dateArray) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"datePicked" object:nil userInfo:@{@"date" : [NSDate date]}];
    }
    
    self.dateArray = [[NSMutableArray alloc]init];
    NSDateFormatter *aDateFormatter = [[NSDateFormatter alloc]init];
    aDateFormatter.dateFormat = @"yyyy-MM-dd";
    for (Event *event in arrayOfAllData) {
        NSArray *bothStrings = [event.date componentsSeparatedByString:@" "];
        
        NSArray *dateByComponents = [bothStrings[0] componentsSeparatedByString:@"-"];
        NSString *dateString = [NSString stringWithFormat:@"%@/%@/%@", dateByComponents[2], dateByComponents[1], dateByComponents[0] ];
        
        [self.dateArray addObject: dateString];
    }
    
    _arrayOfAllData = arrayOfAllData;
}

-(void)setFrame: (CGRect)frame{
    [self.view setFrame:frame];
    CGRect calendarFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    [self.calendar setFrame: calendarFrame];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"datePicked" object:nil userInfo:@{@"date" : [NSDate date]}];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)localeDidChange {
    [self.calendar setLocale:[NSLocale currentLocale]];
}

- (BOOL)dateIsDisabled:(NSDate *)date {
    for (NSDate *disabledDate in self.disabledDates) {
        if ([disabledDate isEqualToDate:date]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark -
#pragma mark - CKCalendarDelegate

- (void)calendar:(CKCalendarView *)calendar configureDateItem:(CKDateItem *)dateItem forDate:(NSDate *)date {
    // TODO: play with the coloring if we want to...
//    if ([self dateIsDisabled:date]) {
//        //dateItem.backgroundColor = [UIColor lightGrayColor];
//        dateItem.textColor = [UIColor lightGrayColor];
//       // dateItem.numberOfDots = 1;
//    
//    }
    
    dateItem.numberOfDots = [self numberOfEventsOnDate: date];
    if (dateItem.numberOfDots >= 10) {
        dateItem.numberOfDots = 10;
    }
}
- (BOOL)calendar:(CKCalendarView *)calendar willSelectDate:(NSDate *)date {
    return ![self dateIsDisabled:date];
}

- (void)calendar:(CKCalendarView *)calendar didSelectDate:(NSDate *)date {
    //self.dateLabel.text = [self.dateFormatter stringFromDate:date];
    if(date){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"datePicked" object:nil userInfo:@{@"date" : date}];
    }
}

- (BOOL)calendar:(CKCalendarView *)calendar willChangeToMonth:(NSDate *)date {
    if ([date laterDate:self.minimumDate] == date) {
        //self.calendar.backgroundColor = [UIColor blueColor];
        return YES;
    } else {
        //self.calendar.backgroundColor = [UIColor redColor];
        return NO;
    }
}

- (void)calendar:(CKCalendarView *)calendar didLayoutInRect:(CGRect)frame {
    NSLog(@"calendar layout: %@", NSStringFromCGRect(frame));
}

-(int)numberOfEventsOnDate: (NSDate *)date{
    int numberOfEvents = 0;
    NSString *dateString = [self.dateFormatter stringFromDate:date];
    for (NSString * arrayDate in self.dateArray) {
        if ([dateString isEqualToString:arrayDate]) {
            numberOfEvents++;
        }
    }
    return numberOfEvents;
}

@end