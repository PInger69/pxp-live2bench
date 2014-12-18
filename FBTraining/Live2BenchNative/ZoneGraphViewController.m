//
//  ZoneGraphViewController.m
//  Live2BenchNative
//
//  Created by dev on 5/29/14.
//  Copyright (c) 2014 Avoca. All rights reserved.
//

#import "ZoneGraphViewController.h"
#import "UserInterfaceConstants.h"
#import "zoneGraphView.h"

#import "JPFont.h"
#import "HeatChartView.h"
#import "JPStyle.h"

#import "Globals.h"
#import "ClipImageDownloader.h"

#import "Globals.h"
#import "SharePopoverTableViewController.h"
#import "JPGraphPDFGenerator.h"

#import "SelectPDFTableViewController.h"



@interface ZoneGraphViewController ()

@end

@implementation ZoneGraphViewController
{
    
    NSArray* zoneStrings;
    
    NSArray* soccerPeriodNames;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        self.sportName = @"soccer";
        
        self.title = [[NSString stringWithFormat:@"%@", @"Zone Graph"] capitalizedString];
        
        self.view.backgroundColor = [UIColor whiteColor];
        
        soccerPeriodNames = @[@"First Half", @"Second Half", @"Extra Time", @"PS"];
        
        zoneStrings = @[@"OFF.3RD", @"MID.3RD", @"DEF.3RD"]; 
        globals = [Globals instance];
        
        self.view.frame = CGRectMake(30, 55, 768 - 60, 1024-55);
        self.view.clipsToBounds = YES;
        
        zonePeriodTimeAcendingComparator = ^(NSDictionary* dict1, NSDictionary* dict2)
        {
            if([[dict1 objectForKey:@"time"] floatValue] < [[dict2 objectForKey:@"time"] floatValue])
            {
                return (NSComparisonResult)NSOrderedAscending;
            }
            else if ([[dict1 objectForKey:@"time"] floatValue] > [[dict2 objectForKey:@"time"] floatValue])
            {
                return (NSComparisonResult)NSOrderedDescending;
            }
            else
            {
                return (NSComparisonResult)NSOrderedSame;
            }
        };
        
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    //Line Graph
    self.graphView = [[zoneGraphView alloc] initWithFrame:CGRectMake(0, 25, 1024, 500)];
    self.graphView.dataSource = self;
    self.graphView.delegate = self;
    [self.view addSubview:self.graphView];

    //Heat Graph View
    self.heatView = [[HeatChartView alloc] initWithFrame:CGRectMake(0, 510, 1024, 400)];
    _lastHeatGraphPosition = self.heatView.frame.origin.y;
    [self.view addSubview:self.heatView];
    self.heatView.dataSource = self;
    
    //Basic Components Initialization
    UIButton* shareButton = [[UIButton alloc] initWithFrame:CGRectMake(kiPadWidthLandscape-50, 60, 30, 30)];
    [shareButton setImage:[UIImage imageNamed:@"shareIcon.png"] forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(shareButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareButton];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    //Reload all graphical elements each time the view controller appears
    [self reloadZoneInformation];
    
    [self reloadSubviews];
}


- (void)reloadZoneInformation
{
    //Clear all data fields first
    [self clearAllDataFields];
    
    globals = [Globals instance];
    
    //All event Tags Info
    NSArray* dataArr = [globals.CURRENT_EVENT_THUMBNAILS allValues];
    self.allTagInfo = [dataArr copy];
    
    //Tag Times and Type Times
    NSMutableDictionary *tagTimes = globals.DURATION_TAGS_TIME;
    NSMutableDictionary *typeTimes= globals.DURATION_TYPE_TIMES;
    
    //Type Times: Zone Times (Float)
    NSArray* zoneEndTimesString = [typeTimes objectForKey:@"16"];
    NSMutableArray* zoneEndTimesFloat = [NSMutableArray array];
    
    for(NSString* timeString in zoneEndTimesString){
        CGFloat zoneEndTime = [timeString floatValue];
        [zoneEndTimesFloat addObject:[NSNumber numberWithFloat:zoneEndTime]];
    }
    self.zoneTimes = zoneEndTimesFloat;
    
    //Tag Times: getting zone name for zone times
    NSMutableArray* zoneNames = [NSMutableArray array];
    
    for(NSString* zoneTagTime in zoneEndTimesString)
    {
        //Get all tags at a particular moment, times where a zone tag can be found
        NSDictionary* zoneTagNamesAtParticularTime = [tagTimes objectForKey:zoneTagTime];
        
        //get the name for tag:16, aka zone ended tag name
        NSString* zoneTagName = [zoneTagNamesAtParticularTime objectForKey:@"16"];
        
        //if the typeTime is "0.01", tagTime might not have corresponding name. avoiding crash
        if(zoneTagName == nil)
        {
            zoneTagName = @"unknown";
        }
        [zoneNames addObject:zoneTagName];
    }
    self.zoneNames = zoneNames;
    
    //Reload Period Info
    NSArray* periodEndTimeStrings = [typeTimes objectForKey:@"18"];
    NSMutableArray* periodEndTimes = [NSMutableArray array];
    
    for(NSString* periodString in periodEndTimeStrings)
    {
        CGFloat periodTimeFloat = [periodString floatValue];
        [periodEndTimes addObject:[NSNumber numberWithFloat:periodTimeFloat]];
    }
    self.periodTimes = periodEndTimes;
    
    NSMutableArray* periodNameArray = [NSMutableArray array];
    
    for(NSString* periodEndTimeString in periodEndTimeStrings)
    {
        NSDictionary* tagNamesDict = [tagTimes objectForKey:periodEndTimeString];
        NSString* periodIndexString = [tagNamesDict objectForKey:@"18"];
        NSInteger periodNumber = [periodIndexString integerValue];
        [periodNameArray addObject:soccerPeriodNames[periodNumber]];
    }
    
    self.periodNames = periodNameArray;
    
}


#pragma mark - Heat Chart View Data Source

- (CGFloat)durationForZone:(NSUInteger)zone period:(NSUInteger)period // starts from 1
{
    if(![self.sportName isEqual:@"soccer"])
    {
        return [self notAveragedDurationForZone:zone period:period];
    }
    
    NSMutableArray* averagedPeriodNameDurationArray = [NSMutableArray array];
    //Array of period zone durations
    /*
     [
        [
            //OFF duration
            //MID duration
            //DEF duration in float
        ],
        [
        //period 2
        ],
     
     ]
     */
    for(int i = 0; i<[soccerPeriodNames count]; i++)
    {
        NSMutableArray* periodDurations = [NSMutableArray array];
        for(int i=0; i<[zoneStrings count]; i++)
        {
            [periodDurations addObject:@0.0f];
        }
            
        [averagedPeriodNameDurationArray addObject:periodDurations];
    }
    
    
    NSInteger periodLoopNum = 1;
    
    for(NSDictionary* periodDict in _periodNameTimeDictArray)
    {
        NSString* periodName = [periodDict objectForKey:@"name"];
        
        for(int i=0; i<[zoneStrings count]; i++)
        {
            NSInteger periodIndex = [soccerPeriodNames indexOfObject:periodName];
            CGFloat zoneDuration = [self notAveragedDurationForZone:i period:periodLoopNum];
            
            NSMutableArray* periodArray = averagedPeriodNameDurationArray[periodIndex];
            float prevZoneDuration = [[periodArray objectAtIndex:i] floatValue];
            
            [periodArray replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:zoneDuration+prevZoneDuration]];
        }
        
        periodLoopNum++;
    }
    
    
    NSMutableArray* periodArray = [averagedPeriodNameDurationArray objectAtIndex:period-1];
    return [[periodArray objectAtIndex:zone] floatValue];
    
}




- (CGFloat)notAveragedDurationForZone:(NSUInteger)zone period:(NSUInteger)period // starts from 1
{
    CGFloat periodStartTime = 0;
    CGFloat periodEndTime = 0;
    
    periodStartTime = [[_periodNameTimeDictArray[period-1] valueForKey:@"time"] floatValue];
    
    if(period == [_periodNameTimeDictArray count])
    {
        periodEndTime = [self eventDuration] + 10;
        
    }
    else if(period < [_periodNameTimeDictArray count])
    {
        //first time "0.01" is not usable
        periodEndTime = [[_periodNameTimeDictArray[period] objectForKey:@"time"] floatValue];
        
    }
    else
    {
        NSLog(@"Requested Period not valid");
    }
    
    CGFloat zoneTotalDurationForPeriod = 0;
    
    _currentZoneTagCount = 1;
    
    while(_currentZoneTagCount < [_zoneNameTimeDictArray count] && [[_zoneNameTimeDictArray[_currentZoneTagCount] valueForKey:@"time"] floatValue] < periodStartTime)
    {
        _currentZoneTagCount++;
    }
    
    //_currentZoneTagCount start from 2nd zone tag, until period ends (1st zone tag unusable) already initialized to 1
    while(_currentZoneTagCount < [_zoneNameTimeDictArray count] && [[_zoneNameTimeDictArray[_currentZoneTagCount] valueForKey:@"time"] floatValue] < periodEndTime)
    {
        if([[_zoneNameTimeDictArray[_currentZoneTagCount] valueForKey:@"zone"] isEqual: zoneStrings[zone]])
        {
            //Zone time minus the previous Zone time is the additional time spent in the zone
            zoneTotalDurationForPeriod += [[_zoneNameTimeDictArray[_currentZoneTagCount] valueForKey:@"time"] floatValue] - [[_zoneNameTimeDictArray[_currentZoneTagCount-1] valueForKey:@"time"] floatValue];
        }
        
        _currentZoneTagCount++;

    }
    
    //Seconds are turned into minutes here
    CGFloat tagDuration = zoneTotalDurationForPeriod/60;
    
    return tagDuration;
    
}

- (NSInteger)numberOfPeriods
{
    if([self.sportName isEqual: @"soccer"])
    {
        return 4;
    }
    else
    {
        return [_periodNameTimeDictArray count];
    }
}


- (NSString*)nameForPeriod:(NSUInteger)period
{
    if([self.sportName isEqual:@"soccer"])
    {
        return [soccerPeriodNames objectAtIndex:period-1];
    }
    else
    {
        return [_periodNameTimeDictArray[period-1] valueForKey:@"name"];
    }
}




#pragma mark - Other Methods

- (void)reloadSubviews
{
    [self.heatView reloadData];
    [self.graphView reloadData];
}



#pragma mark - Setter and Getter Methods

- (void)setZoneTimes:(NSArray *)zoneTimes
{
    _zoneTimes = zoneTimes;

    [self reloadZoneTagInfo];
}


- (void)setZoneNames:(NSArray *)zoneNames
{
    _zoneNames = zoneNames;
    [self reloadZoneTagInfo];
}

- (void)reloadZoneTagInfo
{
    if(self.zoneTimes == nil || self.zoneNames==nil)
    {
        return;
    }
    
    _zoneNameTimeDictArray = [NSMutableArray array];
    
    for(int i=0; i<[self.zoneTimes count]; i++)
    {
        
        NSMutableDictionary* zoneDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.zoneNames[i],@"zone", self.zoneTimes[i], @"time", nil];
        
        [_zoneNameTimeDictArray addObject:zoneDict];
        
    }
    
    [_zoneNameTimeDictArray sortUsingComparator:zonePeriodTimeAcendingComparator];

    
}



- (void)setPeriodNames:(NSArray *)periodNames
{
    _periodNames = periodNames;
    [self reloadPeriodInfo];
    
}

- (void)setPeriodTimes:(NSArray *)periodTimes
{
    _periodTimes = periodTimes;
    [self reloadPeriodInfo];
}


- (void)reloadPeriodInfo
{
    
    if(self.periodTimes==nil || self.periodNames==nil)
    {
        return;
    }
    
    _periodNameTimeDictArray = [NSMutableArray array];
    
    for(int i=0; i<[self.periodTimes count]; i++)
    {
        NSDictionary* periodDict = [NSDictionary dictionaryWithObjectsAndKeys:self.periodTimes[i], @"time", self.periodNames[i], @"name", nil];
        
        [_periodNameTimeDictArray addObject:periodDict];
    }
    
    [_periodNameTimeDictArray sortUsingComparator: zonePeriodTimeAcendingComparator];
    
   
}

///////////////////////////////////////

- (void)setAllTagInfo:(NSArray *)allTagInfo
{
    _allTagInfo = allTagInfo;
    
    self.graphView.dataPoints = [allTagInfo count];
}




#pragma mark - Zone Graph Visualization Data Source

//Data source for tags view
- (NSUInteger)numberOfTagsInGraphView: (graphDisplayView*)graph
{
    NSUInteger numberOfTags = [self.allTagInfo count];
    
    return numberOfTags;
}

- (NSDictionary*)graphView: (graphDisplayView*)graph tagInfoDictForTagNumber: (NSUInteger)tagNum
{
    return (NSDictionary*)[self.allTagInfo objectAtIndex:tagNum];
}


- (NSUInteger)numberOfDataPointsInGraphView:(graphDisplayView *)graph
{
    NSUInteger dataPoints = [_zoneNameTimeDictArray count];
    
    return dataPoints;
}


- (JPZonePoint)graphView: (graphDisplayView*)graph zonePointForPointNumber: (NSUInteger)number
{
    JPZonePoint zonePoint = JPZonePointMake(0, 50);
    
    if(!_zoneNameTimeDictArray)
    {
        return zonePoint;
    }
    
    NSString* zonePointName = [_zoneNameTimeDictArray[number] valueForKey:@"zone"];
    NSInteger zoneNum = -1;
    zoneNum = [zoneStrings indexOfObject:zonePointName];

    float zonePosition = 50.0f;
    if(zoneNum != -1)
    {
        if(zoneNum == 0)
            zonePosition = 83.33333f;
        else if(zoneNum == 1)
            zonePosition = 50.0f;
        else if(zoneNum == 2)
            zonePosition = 16.66667f;
        else
            zonePosition = 0;
        
        zonePoint = JPZonePointMake([[_zoneNameTimeDictArray[number] valueForKey:@"time"] floatValue], zonePosition);
    }
    
    return zonePoint; //In seconds
}

- (CGFloat)eventDuration
{
    NSDictionary* zoneDict = [_zoneNameTimeDictArray lastObject];
    CGFloat duration = [[zoneDict objectForKey: @"time"] floatValue] + 10.0f;
    
    if(globals.eventDuration != 0)
    {
        duration = globals.eventDuration;
    }
    
    return duration;
}


- (NSInteger)numberOfTaggedPeriods
{
    return [_periodNameTimeDictArray count];
}


- (CGFloat)timeForPeriodEnded:(NSUInteger)period
{
    
    CGFloat periodEndTime = 0;
    
    if(period == [_periodNameTimeDictArray count])
    {
        periodEndTime = [self eventDuration];
        
    }
    else if(period < [_periodNameTimeDictArray count])
    {
        //first time "0.01" is not usable
        periodEndTime = [[_periodNameTimeDictArray[period] objectForKey:@"time"] floatValue];
        
    }
    else
    {
        NSLog(@"Requested Period not valid");
    }

    return periodEndTime;
}


- (NSString*)nameForAllTaggedPeriod:(NSUInteger)period
{
    NSDictionary* periodDict = [_periodNameTimeDictArray objectAtIndex:period];
    return [periodDict objectForKey:@"name"];
}



#pragma mark - Zone Graph Delegate

- (void)tagTapped:(UIView*)view
{
    NSInteger kTagMarkConstant = 100;
    
    
    UIViewController* viewController = [[UIViewController alloc] init];
//    viewController.preferredContentSize = CGSizeMake(200, 200);
    
    globals.THUMBNAILS_PATH = [[globals.EVENTS_PATH stringByAppendingPathComponent:globals.EVENT_NAME] stringByAppendingPathComponent:@"thumbnails"];
    //path of the thumb image file in the local folder
    
    if(view.tag-kTagMarkConstant >= [self.allTagInfo count])
    {
        return;
    }
    
    NSDictionary* tagDictionary = [self.allTagInfo objectAtIndex:(view.tag - kTagMarkConstant)];
    BOOL imageLoaded = NO;
    
    NSString *currentImage = [globals.THUMBNAILS_PATH stringByAppendingPathComponent:[[tagDictionary objectForKey:@"url"] lastPathComponent]];
    //if the image file is not downloaded to the local folder, redownloaded
    if ([[NSFileManager defaultManager] fileExistsAtPath:currentImage]) {
        imageLoaded = TRUE;
    }
    else
    {
        ClipImageDownloader* downloader = [[ClipImageDownloader alloc] init];
        imageLoaded = [downloader redownloadImageFromtheServer:tagDictionary];
    }
    
    UIImageView* popoverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 112.5)]; //16:9 ratio
    
    if (imageLoaded){
        //if the thumb image has been downloaded, present the image
        [popoverImageView setImage:[UIImage imageWithContentsOfFile:currentImage]];
        popoverImageView.contentMode = UIViewContentModeScaleAspectFill;

    } else {
        popoverImageView.contentMode = UIViewContentModeCenter;
        [popoverImageView setImage:[UIImage imageNamed:@"live.png"]];
    }

    [viewController.view addSubview:popoverImageView];
    
    UIView* coloredBar = [[UIView alloc] initWithFrame:CGRectMake(popoverImageView.frame.origin.x, popoverImageView.frame.size.height, popoverImageView.frame.size.width, 10)];
    coloredBar.backgroundColor = [JPStyle colorWithHex: [tagDictionary objectForKey:@"colour"] alpha:1];
    
    [viewController.view addSubview:coloredBar];
    
    UILabel* tagNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 127, 100, 30)];
    tagNameLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    tagNameLabel.text = [tagDictionary objectForKey:@"name"];
    [viewController.view addSubview:tagNameLabel];
    
    UILabel* tagDurLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 127, 90, 30)];
    tagNameLabel.font = [UIFont systemFontOfSize:18.0f];
    float tagDur = [(NSString*)[tagDictionary objectForKey:@"time"] floatValue];
    tagDurLabel.textAlignment = NSTextAlignmentRight;
    tagDurLabel.text = [NSString stringWithFormat:@"%.02fs", tagDur];
    [viewController.view addSubview:tagDurLabel];
    
    UILabel* tagTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 160, 180, 30)];
    tagTimeLabel.font = [UIFont systemFontOfSize:18.0f];
    tagTimeLabel.text = [tagDictionary objectForKey:@"displaytime"];
    tagTimeLabel.textAlignment = NSTextAlignmentCenter;
    [viewController.view addSubview:tagTimeLabel];
    
    _popover = [[UIPopoverController alloc] initWithContentViewController:viewController];
    [_popover setPopoverContentSize:CGSizeMake(200, 200)];
    UIView* superView = [view superview];
    [_popover presentPopoverFromRect: view.frame inView:superView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
}





- (void)clearAllDataFields
{
    self.zoneTimes = nil;
    self.zoneNames = nil;
    self.periodNames = nil;
    self.periodTimes = nil;
    self.allTagInfo = nil;
    _zoneNameTimeDictArray= nil;
    _periodNameTimeDictArray= nil;
    
}



#pragma mark - Navigation Bar Button Methods

- (void)dismissButtonPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


- (void)shareButtonPressed: (UIButton*)button
{
    SharePopoverTableViewController* shareTableViewController = [[SharePopoverTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    shareTableViewController.delegate = self;
    shareTableViewController.graphGenerator.dataSource = self;
    
    _popover = [[UIPopoverController alloc] initWithContentViewController:shareTableViewController];
    
    [_popover setPopoverContentSize:CGSizeMake(400, 400)];
    
    [_popover presentPopoverFromRect:button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
}


- (void)sharePopoverControllerDidFinishSelectionWithIndex:(NSIndexPath *)indexPath
{
    [_popover dismissPopoverAnimated:YES];
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
