//
//  StatsViewController.m
//  Live2BenchNative
//
//  Created by DEV on 1/7/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "StatsViewController.h"

#import "UserInterfaceConstants.h"
#import "ExportTagsSync.h"
#import "ExportPopoverTableViewController.h"



#define STATS_TABLE_VIEW_WIDTH 1024
#define STATS_TABLE_VIEW_HEIGHT 540
#define GRID_CELL_HEIGHT 50
#define GRID_CELL_BUTTON_WIDTH 40
#define EVENT_NAME_CELL_LENGTH 134
#define TOTAL_NUMBER_CELL_LENGTH 90
#define TAG_NAME_BUTTON_WIDTH 100
#define TAG_NAME_BUTTON_HEIGHT 30
#define PLAYER_BUTTON_WIDTH 50
#define PLAYER_BUTTON_HEIIGHT 30
#define TIME_BUTTON_WIDTH 160
#define TIME_BUTTON_HEIGHT 40
#define TABLE_VIEW_HEADER_HEIGHT 40
#define TIME_LABEL_WIDTH 45
#define TOTAL_TIME_DURATION 320
#define PLAY_BUTTON_WIDTH 128
#define PLAY_BUTTON_HEIGHT 72
#define VIDEO_WIDTH 712//900//712//530
#define VIDEO_HEIGHT 400//506//400//300
#define SMALL_VIDEO_WIDTH 530
#define SMALL_VIDEO_HEIGHT 300
#define TOOL_BAR_HEIGHT 50
#define BAR_ITEM_SPACE 50
#define PERIOD_BUTTON_WIDTH 30
#define LINE_BUTTON_WIDTH 60
#define LINE_BUTTON_HEIGHT 23

@interface StatsViewController ()

@end

@implementation StatsViewController

@synthesize statsTableView;
@synthesize statsData;
@synthesize endTime;
@synthesize startTime;
@synthesize startTimePickerView;
@synthesize startTimePikerData;
@synthesize endTimePikerData;
@synthesize endTimePickerView;
@synthesize timeInterval;
@synthesize timeLineInfoButton;
@synthesize popoverController;
@synthesize globals;
@synthesize tagNamesArr;
@synthesize gameStatsDataDict;
@synthesize playerStatsDataDict;
@synthesize videoPlayer;
@synthesize loopTimerStatsView;
@synthesize viewForVideo;
@synthesize playerButtonsArr;
@synthesize selectedEventsArr;
@synthesize selectedPlayersArr;
@synthesize arrayOfMatchedTags;
@synthesize playerNumberArr;
@synthesize playerButtonsScrollView;
@synthesize tagNameButtonsScrollView;
@synthesize tagNameButtonsArr;
@synthesize gridCellButtonSelected;
@synthesize tabAttributes;
@synthesize tabSelectAttributes;
@synthesize gameStatsBarButton;
@synthesize playerStatsBarButton;
@synthesize statsToolBar;
@synthesize tabContentView;
@synthesize totalNumberView;
@synthesize outputReportButton;
@synthesize tagsWithPlayers;
@synthesize onIceTimeDurations;
@synthesize periodButtonsArr;
@synthesize taggedAttsDict;
@synthesize filterButtonsView;
@synthesize dividerView;
@synthesize timeOnIceDataDict;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Game Stats";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(willExitFullScreen) name:@"Exiting FullScreen" object:Nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removeLiveSpinner) name:@"removeLiveSpinner" object:nil];
    
    if (!globals) {
        globals = [Globals instance];
    }
    playerButtonsArr = [[NSMutableArray alloc]init];
    tagNameButtonsArr = [[NSMutableArray alloc]init];
    videoPlayer = [[VideoPlayer alloc] init];
    [videoPlayer initializeVideoPlayerWithFrame:CGRectMake(0, 0, VIDEO_WIDTH, VIDEO_HEIGHT)];
    //init subviews and ivars
    [self setupView];
}

-(void)viewWillAppear:(BOOL)animated
{
    
    //tagNamesArr: an array contains events which were tagged during the game
    //playerNumberArr: an array of players numbers which were tagged during the game
    for(NSDictionary *tag in [globals.CURRENT_EVENT_THUMBNAILS allValues]){
        if ([[tag objectForKey:@"type"]intValue] == 0 || [[tag objectForKey:@"type"]intValue] == 100 ) {
            //save tag name in the array: tagNamesArr
            if(!tagNamesArr){
                tagNamesArr = [NSMutableArray arrayWithObject:[tag objectForKey:@"name"]];
            }else if(![tagNamesArr containsObject:[tag objectForKey:@"name"]]){
                [tagNamesArr addObject:[tag objectForKey:@"name"]];
            }
            
            if ([[tag  objectForKey:@"player"]count]>0 && ![[[tag  objectForKey:@"player"] objectAtIndex:0] isEqualToString: @""] ) {
                
                NSMutableSet* set1 = [NSMutableSet setWithArray:playerNumberArr];
                NSMutableSet* set2 = [NSMutableSet setWithArray:[tag  objectForKey:@"player"]];
                [set1 intersectSet:set2]; //this will give you only the obejcts that are in both sets
                NSArray* intersectArray = [set1 allObjects];
                if (intersectArray.count < [[tag objectForKey:@"player"]count]) {
                    NSMutableArray *tempPlayerArr = [[tag objectForKey:@"player"]mutableCopy];
                    //new players which are not included in the array typesoftags
                    [tempPlayerArr removeObjectsInArray:intersectArray];
                    if (!playerNumberArr) {
                        playerNumberArr = [NSMutableArray arrayWithArray:tempPlayerArr];
                    }else{
                        [playerNumberArr addObjectsFromArray:tempPlayerArr];
                    }
                    
                }
                
                if (!tagsWithPlayers) {
                    tagsWithPlayers = [NSMutableArray arrayWithObject:[tag objectForKey:@"name"]];
                }else if(![tagsWithPlayers containsObject:[tag objectForKey:@"name"]]){
                    [tagsWithPlayers addObject:[tag objectForKey:@"name"]];
                }
            }


        }
    }

    //create player buttons
    if (playerNumberArr.count <1) {
        CustomButton *playerButton = [CustomButton buttonWithType:UIButtonTypeCustom];
        [playerButton setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
        [playerButton setFrame:CGRectMake(0, 0, STATS_TABLE_VIEW_WIDTH, PLAYER_BUTTON_HEIIGHT)];
        [playerButton setTitle:@"No player available" forState:UIControlStateNormal];
        [playerButton setFont:[UIFont defaultFontOfSize:15.0f]];
        [playerButton setUserInteractionEnabled:FALSE];
        [playerButton.titleLabel setTextAlignment:NSTextAlignmentLeft];
        [playerButtonsScrollView addSubview:playerButton];
        [playerButtonsArr addObject:playerButton];
    }else{
        
        for(NSString *playerNumber in playerNumberArr){
            int i = [playerNumberArr indexOfObject:playerNumber];
            CustomButton *playerButton = [CustomButton buttonWithType:UIButtonTypeCustom];
            [playerButton setFont:[UIFont defaultFontOfSize:15.0f]];
            [playerButton setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
            [playerButton setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
            [playerButton setFrame:CGRectMake(i*(PLAYER_BUTTON_WIDTH+1), 0, PLAYER_BUTTON_WIDTH, PLAYER_BUTTON_HEIIGHT)];
            [playerButton setTitle:[NSString stringWithFormat:@"Pl.%@",playerNumber] forState:UIControlStateNormal];
            [playerButton addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
            [playerButtonsScrollView addSubview:playerButton];
            [playerButtonsArr addObject:playerButton];
            [playerButton setAccessibilityLabel:@"players"];
            [playerButton setAccessibilityValue:playerNumber];
        }
        
        //if the total width of player buttons if greater than the screen width, then extend the scroll view's content size for scrolling
        if (playerNumberArr.count * PLAYER_BUTTON_WIDTH < 1024) {
            [playerButtonsScrollView setContentSize:playerButtonsScrollView.frame.size];
        }else{
            [playerButtonsScrollView setContentSize:CGSizeMake((playerNumberArr.count +1) * PLAYER_BUTTON_WIDTH, PLAYER_BUTTON_HEIIGHT)];
        }
    }
    
    if (tagNamesArr.count <1) {
        CustomButton *tagNameButton = [CustomButton buttonWithType:UIButtonTypeCustom];
        [tagNameButton setFrame:CGRectMake(0, 0, STATS_TABLE_VIEW_WIDTH, TAG_NAME_BUTTON_HEIGHT)];
        [tagNameButton setTitle:@"No tag available" forState:UIControlStateNormal];
        [tagNameButton setFont:[UIFont defaultFontOfSize:15.0f]];
        [tagNameButton setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
        [tagNameButton setUserInteractionEnabled:FALSE];
        [tagNameButton.titleLabel setTextAlignment:NSTextAlignmentLeft];
        [tagNameButtonsScrollView addSubview:tagNameButton];
        [tagNameButtonsArr addObject:tagNameButton];
    }else{
        for(NSString *tagName in tagNamesArr ){
            int i = [tagNamesArr indexOfObject:tagName];
            CustomButton *tagNameButton = [CustomButton buttonWithType:UIButtonTypeCustom];
            [tagNameButton setFont:[UIFont defaultFontOfSize:15.0f]];
            [tagNameButton setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
            [tagNameButton setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
            //[tagNameButton setFrame:CGRectMake((i/2)*(TAG_NAME_BUTTON_WIDTH + 1), (i%2)*(TAG_NAME_BUTTON_HEIGHT+1)+1, TAG_NAME_BUTTON_WIDTH, TAG_NAME_BUTTON_HEIGHT)];
            [tagNameButton setFrame:CGRectMake(i*(TAG_NAME_BUTTON_WIDTH + 1), 1, TAG_NAME_BUTTON_WIDTH, TAG_NAME_BUTTON_HEIGHT)];
            [tagNameButton setTitle:[tagNamesArr objectAtIndex:i] forState:UIControlStateNormal];
            [tagNameButton addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
            [tagNameButton setAccessibilityLabel:@"events"];
            [tagNameButton setAccessibilityValue:tagName];
            [tagNameButtonsScrollView addSubview:tagNameButton];
            [tagNameButtonsArr addObject:tagNameButton];
        }
        //if the total width of tag name buttons if greater than the screen width, then extend the scroll view's content size for scrolling
        if (tagNamesArr.count * TAG_NAME_BUTTON_WIDTH < 1024) {
            [tagNameButtonsScrollView setContentSize:CGSizeMake(self.view.frame.size.width, tagNameButtonsScrollView.frame.size.height)];
        }else{
            [tagNameButtonsScrollView setContentSize:CGSizeMake((tagNamesArr.count + 1) * TAG_NAME_BUTTON_WIDTH, tagNameButtonsScrollView.frame.size.height)];
        }

    }

    //reset the dictionary
    onIceTimeDurations = nil;
    //period
    [self getShiftsDurations:@"7" :@"8" :@"0"];
    
    //get line&period shifts time durations
    
    if ([globals.WHICH_SPORT isEqualToString:@"hockey"]) {
        //offense line
        [self getShiftsDurations:@"1" :@"2" :@"line_f_1"];
        //defense line
        [self getShiftsDurations:@"5" :@"6" :@"line_d_1"];
        //strength
        [self getShiftsDurations:@"9" :@"10" :@"5,5"];
    }
  
    //fetch the stats data for table view display
    arrayOfMatchedTags = [NSMutableArray arrayWithArray:[globals.CURRENT_EVENT_THUMBNAILS allValues]];
    [self getStatsData:arrayOfMatchedTags];
    
    [self updateFilterButtons];
    
    //when enter stats page, by default goes to game stats tab
    [self selectTab:gameStatsBarButton];
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [globals.SPINNERVIEW removeSpinner];
}


-(void)setupView{
    //set the whole view's background color to white color
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    tabAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont defaultFontOfSize:30.0f],NSFontAttributeName,[UIColor colorWithWhite:0.3 alpha:1.0f],NSForegroundColorAttributeName, nil];
    tabSelectAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont defaultFontOfSize:30.0f],NSFontAttributeName,[UIColor orangeColor],NSForegroundColorAttributeName, nil];
    
    
    if ([globals.WHICH_SPORT isEqualToString:@"hockey"]) {
         playerStatsBarButton = [[UIBarButtonItem alloc]initWithTitle:@"Time on Ice" style:UIBarButtonItemStylePlain target:self action:@selector(selectTab:)];
    }else{
         playerStatsBarButton = [[UIBarButtonItem alloc]initWithTitle:@"Player Stats" style:UIBarButtonItemStylePlain target:self action:@selector(selectTab:)];
    }
    playerStatsBarButton = [[UIBarButtonItem alloc]initWithTitle:@"Time on Ice" style:UIBarButtonItemStylePlain target:self action:@selector(selectTab:)];
    playerStatsBarButton.tag = 1;
    [playerStatsBarButton setTitleTextAttributes:tabAttributes forState:UIControlStateNormal];
    
    
    tabContentView = [[UIView alloc]initWithFrame:CGRectMake(0, 60, STATS_TABLE_VIEW_WIDTH,768 - 60 - TOOL_BAR_HEIGHT)];
    tabContentView.tag = 0;
    [self.view addSubview:tabContentView];
    
    //init timer interval to 160mins
    endTime = 160;
    //init start time
    startTime = 0;
    //init time interval
    timeInterval = (endTime-startTime)/16;

    //init time line info button
    timeLineInfoButton = [[UIButton alloc]init];//buttonWithType:UIButtonTypeCustom];
    [timeLineInfoButton setFrame:CGRectMake(2, 0, TIME_BUTTON_WIDTH, TIME_BUTTON_HEIGHT)];
    [timeLineInfoButton setTitle:[NSString stringWithFormat:@"Duration: [%d, %d)",startTime,endTime] forState:UIControlStateNormal];
    [timeLineInfoButton addTarget:self action:@selector(changeTimeLineInfo:) forControlEvents:UIControlEventTouchUpInside];
    timeLineInfoButton.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:1.0].CGColor;
    [timeLineInfoButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    timeLineInfoButton.layer.borderWidth = 2;
    [timeLineInfoButton.titleLabel setFont:[UIFont defaultFontOfSize:17.0f]];
    [tabContentView addSubview:timeLineInfoButton];
    
    //init start time picker view data
    for(int i = 0; i<TOTAL_TIME_DURATION -1;i++){
        if (!startTimePikerData) {
            startTimePikerData = [NSMutableArray arrayWithObject:[NSString stringWithFormat:@"%d",i]];
        }else{
            [startTimePikerData addObject:[NSString stringWithFormat:@"%d",i]];
        }
        if (!endTimePikerData) {
            endTimePikerData = [NSMutableArray arrayWithObject:[NSString stringWithFormat:@"%d",i+2]];
        }else{
            [endTimePikerData addObject:[NSString stringWithFormat:@"%d",i+2]];
        }
    }
    
    //init the scroll view for player buttons
    playerButtonsScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, TIME_BUTTON_HEIGHT+10, STATS_TABLE_VIEW_WIDTH, PLAY_BUTTON_HEIGHT)];
    [playerButtonsScrollView setBackgroundColor:[UIColor clearColor]];
    playerButtonsScrollView.scrollEnabled = TRUE;
    playerButtonsScrollView.showsHorizontalScrollIndicator = TRUE;
    [tabContentView addSubview:playerButtonsScrollView];
    
    dividerView = [[UIImageView alloc]initWithFrame:CGRectMake(0, playerButtonsScrollView.frame.origin.y, STATS_TABLE_VIEW_WIDTH, 1)];
    [dividerView setImage:[UIImage imageNamed:@"line-button-grey.png"]];
    [tabContentView addSubview:dividerView];

    //init table view
    statsTableView.contentInset = UIEdgeInsetsZero;
    statsTableView = [[UITableView alloc]initWithFrame:CGRectMake(statsTableView.frame.origin.x, PLAYER_BUTTON_HEIIGHT+TIME_BUTTON_HEIGHT+10, STATS_TABLE_VIEW_WIDTH, STATS_TABLE_VIEW_HEIGHT)];
    statsTableView.delegate = self;
    statsTableView.dataSource = self;
    [tabContentView addSubview:statsTableView];
    
    //init the scroll view for tag names
    tagNameButtonsScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(statsTableView.frame), STATS_TABLE_VIEW_WIDTH, self.view.frame.size.height - CGRectGetMaxY(statsTableView.frame) )];
    [tagNameButtonsScrollView setBackgroundColor:[UIColor clearColor]];
    tagNameButtonsScrollView.scrollEnabled = TRUE;
    tagNameButtonsScrollView.showsHorizontalScrollIndicator = TRUE;
    [tabContentView addSubview:tagNameButtonsScrollView];
    
    //init sub view for displaying tags' total numbers
    totalNumberView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(statsTableView.frame), STATS_TABLE_VIEW_WIDTH, self.view.frame.size.height - CGRectGetMaxY(statsTableView.frame))];
    [totalNumberView setBackgroundColor:[UIColor clearColor]];
    [tabContentView addSubview:totalNumberView];
    //by default, hide this view
    totalNumberView.hidden = TRUE;
    
    outputReportButton = [[CustomButton alloc] initWithFrame:CGRectMake(STATS_TABLE_VIEW_WIDTH - PLAYER_BUTTON_WIDTH,20,30,30) ];
    [outputReportButton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    [outputReportButton setImage:[UIImage imageNamed:@"sharehighlight"] forState:UIControlStateHighlighted];
    [outputReportButton addTarget:self action:@selector(outputReport:) forControlEvents:UIControlEventTouchUpInside];
    [tabContentView addSubview:outputReportButton];
    outputReportButton.hidden = TRUE;
   
    
   
    
    //Export Button
    _exportSync = [[ExportTagsSync alloc] init];
    
    _exportButton = [[UIButton alloc] initWithFrame:CGRectMake(7, 146, 30, 30)];
    [_exportButton setImage:[UIImage imageNamed:@"exportIcon"] forState:UIControlStateNormal];
    [_exportButton addTarget:self action:@selector(exportButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_exportButton];
    
    
}

-(void)updateFilterButtons
{
    
    filterButtonsView = [[UIView alloc]init];
    [tabContentView addSubview:filterButtonsView];
    
    //update tab button title
    if ([globals.WHICH_SPORT isEqualToString:@"hockey"]) {
        [playerStatsBarButton setTitle:@"Time on Ice"];
    }else{
        [playerStatsBarButton setTitle:@"Player Stats"];
    }
    
    if ([globals.WHICH_SPORT isEqualToString:@"hockey"]) {
        
        [timeLineInfoButton setFrame:CGRectMake(2, 8, TIME_BUTTON_WIDTH, TIME_BUTTON_HEIGHT)];
        [filterButtonsView setFrame:CGRectMake(CGRectGetMaxX(timeLineInfoButton.frame), 0, 1024 - CGRectGetMaxX(timeLineInfoButton.frame), TIME_BUTTON_HEIGHT+10)];
        
    }else if ([globals.WHICH_SPORT isEqualToString:@"soccer"]){
        
        [timeLineInfoButton setFrame:CGRectMake(150, 0, TIME_BUTTON_WIDTH, TIME_BUTTON_HEIGHT)];
        [filterButtonsView setFrame:CGRectMake(CGRectGetMaxX(timeLineInfoButton.frame), 0, 1024 - CGRectGetMaxX(timeLineInfoButton.frame), TIME_BUTTON_HEIGHT+10)];

    }else if ([globals.WHICH_SPORT isEqualToString:@"rugby"]){
        
        [timeLineInfoButton setFrame:CGRectMake(300, 0, TIME_BUTTON_WIDTH, TIME_BUTTON_HEIGHT)];
        
        [filterButtonsView setFrame:CGRectMake(CGRectGetMaxX(timeLineInfoButton.frame) + timeLineInfoButton.frame.size.width, 0, 1024 - CGRectGetMaxX(timeLineInfoButton.frame) - timeLineInfoButton.frame.size.width, TIME_BUTTON_HEIGHT+10)];
    }else if ([globals.WHICH_SPORT isEqual:@"football"])
    {
        [timeLineInfoButton setFrame:CGRectMake(300, 0, TIME_BUTTON_WIDTH, TIME_BUTTON_HEIGHT)];
        
        [filterButtonsView setFrame:CGRectMake(CGRectGetMaxX(timeLineInfoButton.frame) + timeLineInfoButton.frame.size.width, 0, 1024 - CGRectGetMaxX(timeLineInfoButton.frame) - timeLineInfoButton.frame.size.width, TIME_BUTTON_HEIGHT+10)];
    }
    
    if (globals.CURRENT_PLAYBACK_EVENT && ![globals.CURRENT_PLAYBACK_EVENT isEqualToString:@""]) {
        //period label
        UILabel *periodLabel;
        if ([globals.WHICH_SPORT isEqualToString:@"hockey"]) {
            periodLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 8, PERIOD_BUTTON_WIDTH, TIME_BUTTON_HEIGHT)];
        }else{
            periodLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, PERIOD_BUTTON_WIDTH, TIME_BUTTON_HEIGHT)];
        }
        
        [periodLabel setText:@"P/H"];
        [periodLabel setTextColor:[UIColor darkGrayColor]];
        [periodLabel setFont:[UIFont defaultFontOfSize:13.0f]];
        [periodLabel setBackgroundColor:[UIColor clearColor]];
        [filterButtonsView addSubview:periodLabel];
        
        //create period buttons
        for(NSString *period in globals.ARRAY_OF_PERIODS){
            int i = [globals.ARRAY_OF_PERIODS indexOfObject:period];
            CustomButton *button;
            if ([globals.WHICH_SPORT isEqualToString:@"hockey"]) {
                button = [[CustomButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(periodLabel.frame) + (PERIOD_BUTTON_WIDTH + 2)*i, periodLabel.frame.origin.y, PERIOD_BUTTON_WIDTH, TIME_BUTTON_HEIGHT)];
            }else{
                button = [[CustomButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(periodLabel.frame) + (PERIOD_BUTTON_WIDTH*2 + 2)*i, periodLabel.frame.origin.y, PERIOD_BUTTON_WIDTH*2, TIME_BUTTON_HEIGHT)];
            }
            
            [button setTitle:period forState:UIControlStateNormal];
            [button setAccessibilityLabel:@"period"];
            button.accessibilityValue = [NSString stringWithFormat:@"%d",i];
            [button setFont:[UIFont defaultFontOfSize:15.0f]];
            [button setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
            [button addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
            [filterButtonsView addSubview:button];
            [periodButtonsArr addObject:button];
        }
        
        
        if ([globals.WHICH_SPORT isEqualToString:@"hockey"] || [globals.WHICH_SPORT isEqualToString:@"soccer"]) {
            //zone label, which is a button to display a zone graph
            UIButton *zoneButton = [[UIButton alloc] initWithFrame:CGRectZero];
            if ([globals.WHICH_SPORT isEqualToString:@"hockey"]) {
                zoneButton.frame = CGRectMake(20 + CGRectGetMaxX(periodLabel.frame) + (PERIOD_BUTTON_WIDTH + 2)*(globals.ARRAY_OF_PERIODS.count), periodLabel.frame.origin.y, PERIOD_BUTTON_WIDTH*1.5, TIME_BUTTON_HEIGHT);
            }else{
                zoneButton.frame = CGRectMake(20 + CGRectGetMaxX(periodLabel.frame) + (PERIOD_BUTTON_WIDTH*2 + 2)*(globals.ARRAY_OF_PERIODS.count), periodLabel.frame.origin.y, PERIOD_BUTTON_WIDTH*1.5, TIME_BUTTON_HEIGHT);
            }
            
            [zoneButton setTitle:@"ZONE" forState:UIControlStateNormal];
            [zoneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//            [zoneButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
            zoneButton.titleLabel.font = [UIFont defaultFontOfSize:13.0f];
            
            [filterButtonsView addSubview:zoneButton];
            
            //create zone buttons
            NSArray *zoneArray;
            if ([globals.WHICH_SPORT isEqualToString:@"hockey"]) {
                zoneArray = globals.ARRAY_OF_ZONES_HOCKEY;
            }else if ([globals.WHICH_SPORT isEqualToString:@"soccer"]){
                zoneArray = globals.ARRAY_OF_ZONES;
            }
            for(NSString *zone in zoneArray){
                int i = [zoneArray indexOfObject:zone];
                CustomButton *button;
                if ([globals.WHICH_SPORT isEqualToString:@"hockey"]) {
                    button = [[CustomButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(zoneButton.frame)+ (PERIOD_BUTTON_WIDTH + 2)*i, zoneButton.frame.origin.y, PERIOD_BUTTON_WIDTH, TIME_BUTTON_HEIGHT)];
                    
                }else{
                    button = [[CustomButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(zoneButton.frame)+ (PERIOD_BUTTON_WIDTH*2.5 + 2)*i, zoneButton.frame.origin.y, PERIOD_BUTTON_WIDTH*2.5, TIME_BUTTON_HEIGHT)];
                    
                }
                [button setTitle:zone forState:UIControlStateNormal];
                [button setAccessibilityLabel:@"zone"];
                button.accessibilityValue = zone;
                [button setFont:[UIFont defaultFontOfSize:15.0f]];
                [button setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
                [button setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
                [button addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
                [filterButtonsView addSubview:button];
            }
            
            if ([globals.WHICH_SPORT isEqualToString:@"hockey"]) {
                //offense line label
                UILabel *offLineLabel = [[UILabel alloc]initWithFrame:CGRectMake(20 + CGRectGetMaxX(zoneButton.frame) + (PERIOD_BUTTON_WIDTH + 2)*(globals.ARRAY_OF_ZONES_HOCKEY.count), 2, PERIOD_BUTTON_WIDTH*1.5, 20)];
                [offLineLabel setText:@"OFF."];
                [offLineLabel setTextColor:[UIColor darkGrayColor]];
                [offLineLabel setFont:[UIFont defaultFontOfSize:13.0f]];
                [offLineLabel setBackgroundColor:[UIColor clearColor]];
                [filterButtonsView addSubview:offLineLabel];
                
                //defense line label
                UILabel *defLineLabel = [[UILabel alloc]initWithFrame:CGRectMake(offLineLabel.frame.origin.x,CGRectGetMaxY(offLineLabel.frame) + 2, PERIOD_BUTTON_WIDTH*1.5, 20)];
                [defLineLabel setText:@"DEF."];
                [defLineLabel setTextColor:[UIColor darkGrayColor]];
                [defLineLabel setFont:[UIFont defaultFontOfSize:13.0f]];
                [defLineLabel setBackgroundColor:[UIColor clearColor]];
                [filterButtonsView addSubview:defLineLabel];
                
                
                if ([globals.WHICH_SPORT isEqualToString:@"hockey"]) {
                    NSArray *lineArr = [[NSArray alloc]initWithObjects:@"line_f_1",@"line_f_2",@"line_f_3",@"line_f_4",@"line_d_1",@"line_d_2",@"line_d_3",@"line_d_4", nil];
                    for(NSString *lineStr in lineArr){
                        int i = [lineArr indexOfObject:lineStr];
                        CustomButton *button;
                        if (i < 4) {
                            button = [[CustomButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(offLineLabel.frame) +  i*(LINE_BUTTON_WIDTH+2), 0, LINE_BUTTON_WIDTH, LINE_BUTTON_HEIGHT)];
                        }else{
                            button = [[CustomButton alloc]initWithFrame:CGRectMake( CGRectGetMaxX(offLineLabel.frame)  + (i%4)*(LINE_BUTTON_WIDTH+2), LINE_BUTTON_HEIGHT + 2, LINE_BUTTON_WIDTH, LINE_BUTTON_HEIGHT)];
                        }
                        [button setTitle:lineStr forState:UIControlStateNormal];
                        [button setFont:[UIFont defaultFontOfSize:15.0f]];
                        [button setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
                        [button setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
                        [button addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
                        [filterButtonsView addSubview:button];
                        //[lineButtonsArr addObject:button];
                        if (i < 4) {
                            [button setAccessibilityLabel:@"offline"];
                        }else{
                            [button setAccessibilityLabel:@"defline"];
                        }
                        button.accessibilityValue = lineStr;
                    }
                    
                    //home team label
                    UILabel *homeStrLabel =[[UILabel alloc]initWithFrame:CGRectMake((PERIOD_BUTTON_WIDTH + 2)*(globals.ARRAY_OF_PERIODS.count) + (LINE_BUTTON_WIDTH +2) *9 - 10, 2, 20, 20)];
                    [homeStrLabel setText:@"H"];
                    [homeStrLabel setFont:[UIFont defaultFontOfSize:13.0f]];
                    [homeStrLabel setTextColor:[UIColor darkGrayColor]];
                    [homeStrLabel setBackgroundColor:[UIColor clearColor]];
                    [filterButtonsView addSubview:homeStrLabel];
                    
                    //home strength buttons
                    for (NSString *strength in globals.ARRAY_OF_STRENGTH) {
                        int i = [globals.ARRAY_OF_STRENGTH indexOfObject:strength];
                        CustomButton *strButton = [CustomButton buttonWithType:UIButtonTypeCustom];
                        [strButton setFrame:CGRectMake(CGRectGetMaxX(homeStrLabel.frame)+(i*32), 0, 30, LINE_BUTTON_HEIGHT)];
                        [strButton setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
                        [strButton setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
                        [strButton setAccessibilityLabel:@"homestr"];
                        [strButton setAccessibilityValue:strength];
                        [strButton addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
                        [strButton setTitle:strength forState:UIControlStateNormal];
                        [strButton setTag:i+1];
                        strButton.titleLabel.font=[UIFont systemFontOfSize:14.0f];
                        [filterButtonsView addSubview:strButton];
                    }
                    
                    //away team label
                    UILabel *awayStrLabel =[[UILabel alloc]initWithFrame:CGRectMake(homeStrLabel.frame.origin.x, CGRectGetMaxY(homeStrLabel.frame)+5, 20, 20)];
                    [awayStrLabel setText:@"A"];
                    [awayStrLabel setFont:[UIFont defaultFontOfSize:13.0f]];
                    [awayStrLabel setTextColor:[UIColor darkGrayColor]];
                    [awayStrLabel setBackgroundColor:[UIColor clearColor]];
                    [filterButtonsView addSubview:awayStrLabel];
                    
                    //away strength buttons
                    for (NSString *strength in globals.ARRAY_OF_STRENGTH) {
                        int i = [globals.ARRAY_OF_STRENGTH indexOfObject:strength];
                        CustomButton *strButton = [CustomButton buttonWithType:UIButtonTypeCustom];
                        [strButton setFrame:CGRectMake(CGRectGetMaxX(homeStrLabel.frame)+(i*32), awayStrLabel.frame.origin.y -2, 30, LINE_BUTTON_HEIGHT)];
                        [strButton setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
                        [strButton setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
                        [strButton setAccessibilityLabel:@"awaystr"];
                        [strButton setAccessibilityValue:strength];
                        [strButton addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
                        [strButton setTitle:strength forState:UIControlStateNormal];
                        [strButton setTag:i+1];
                        strButton.titleLabel.font=[UIFont systemFontOfSize:14.0f];
                        [filterButtonsView addSubview:strButton];
                    }
                    
                }
            }
            
            
        }

        timeLineInfoButton.hidden = NO;
    }
    else //NO sport is availble
    {
        timeLineInfoButton.hidden = YES;
    }
       

}


-(void)getShiftsDurations:(NSString*)openType :(NSString*)closeType :(NSString*)defaultName{
    
    NSMutableArray *timeArr = [globals.DURATION_TYPE_TIMES objectForKey:closeType];
    if ([globals.DURATION_TYPE_TIMES objectForKey:openType]) {
        [timeArr addObjectsFromArray:[globals.DURATION_TYPE_TIMES objectForKey:openType]];
    }
    
    //remove duplicated time items
    timeArr = [[[NSSet setWithArray:timeArr]allObjects]mutableCopy];
    
    //sort by time, makes our binary search faster
    [timeArr sortUsingComparator:^NSComparisonResult(NSString *str1, NSString *str2) {
        return [str1 compare:str2 options:(NSNumericSearch)];
    }];
    
    for(NSString *timeStr in timeArr){
        int i = [timeArr indexOfObject:timeStr];
        if (i < timeArr.count -1) {
            NSString *shiftName = [[globals.DURATION_TAGS_TIME objectForKey:timeStr]objectForKey:closeType];
            if (shiftName == nil) {
                shiftName = [[globals.DURATION_TAGS_TIME objectForKey:timeStr]objectForKey:openType];
                //TODO: check why this case happens
                if (shiftName == nil) {
                    shiftName = defaultName;
                }
            }
            
            if (!onIceTimeDurations) {
                    onIceTimeDurations = [NSMutableDictionary dictionaryWithObject:[NSMutableDictionary dictionaryWithObject:[timeArr objectAtIndex:(i+1)] forKey:timeStr] forKey:shiftName];

            }else if (![[onIceTimeDurations allKeys] containsObject:shiftName]) {
               
                    [onIceTimeDurations setObject:[NSMutableDictionary dictionaryWithObject:[timeArr objectAtIndex:(i+1)] forKey:timeStr] forKey:shiftName];

            }else{
               
                    [[onIceTimeDurations objectForKey:shiftName]setObject:[timeArr objectAtIndex:(i+1)] forKey:timeStr];

               
            }
        }
        //Not to consider the last unclosed tag for now
//        else{
//            //if the last time object is type "1", means this duration tag is open and not close yet
//            NSString *shiftName = [[globals.DURATION_TAGS_TIME objectForKey:timeStr]objectForKey:openType];
//            if (shiftName != nil) {
//                if (!onIceTimeDurations) {
//                    onIceTimeDurations = [NSMutableDictionary dictionaryWithObject:[NSMutableDictionary dictionaryWithObject:@"100000" forKey:timeStr] forKey:shiftName];
//                }else if (![[onIceTimeDurations allKeys] containsObject:shiftName]) {
//                    [onIceTimeDurations setObject:[NSMutableDictionary dictionaryWithObject:@"100000" forKey:timeStr] forKey:shiftName];
//                }else{
//                    [[onIceTimeDurations objectForKey:shiftName]setObject:@"100000" forKey:timeStr];
//                }
//            }
//        }
    }
    
    //if time 0.01 is not saved in globals.DURATION_TYPE_TIMES, need to add it here TODO: why time 0.01 is not saved in globals.DURATION_TYPE_TIMES
    if (![[[onIceTimeDurations objectForKey:defaultName]allKeys] containsObject:@"0.01"] && [onIceTimeDurations objectForKey:defaultName]) {
        [[onIceTimeDurations objectForKey:defaultName] setObject:[timeArr objectAtIndex:0] forKey:@"0.01"];
    }

}

-(void)selectTab:(UIBarButtonItem*)tabButton{
    if(tabContentView.tag == tabButton.tag){
        return;
    }
    
    for(UIBarButtonItem *item in statsToolBar.items){
        [item setTitleTextAttributes:tabAttributes forState:UIControlStateNormal];
    }
    [tabButton setTitleTextAttributes:tabSelectAttributes forState:UIControlStateNormal];
    tabContentView.tag = tabButton.tag;
    switch (tabButton.tag) {
        case 0:
            [totalNumberView setHidden:TRUE];
            [outputReportButton setHidden:TRUE];
            [tagNameButtonsScrollView setHidden:FALSE];
            [playerButtonsScrollView setHidden:FALSE];
            [filterButtonsView setHidden:FALSE];
            [dividerView setHighlighted:FALSE];
            [self updateTimeInfoButton];
            if ([globals.WHICH_SPORT isEqualToString:@"hockey"]) {
                 [timeLineInfoButton setFrame:CGRectMake(timeLineInfoButton.frame.origin.x, 8, TIME_BUTTON_WIDTH, TIME_BUTTON_HEIGHT)];
            }else{
                 [timeLineInfoButton setFrame:CGRectMake(timeLineInfoButton.frame.origin.x, 0, TIME_BUTTON_WIDTH, TIME_BUTTON_HEIGHT)];
            }
           
            statsData = [NSMutableArray arrayWithArray:[gameStatsDataDict allKeys]];
            if (!statsData) {
                statsData = [[NSMutableArray alloc]init];
            }
            while(statsData.count < 10) {
                [statsData addObject: @"-1"];
            }
            [statsTableView reloadData];
            break;
        case 1:
            [totalNumberView setHidden:FALSE];
            [outputReportButton setHidden:FALSE];
            [tagNameButtonsScrollView setHidden:TRUE];
            [playerButtonsScrollView setHidden:TRUE];
            [filterButtonsView setHidden:TRUE];
            [dividerView setHidden:TRUE];
            [self updateTimeInfoButton];
            [timeLineInfoButton setFrame:CGRectMake(timeLineInfoButton.frame.origin.x, outputReportButton.frame.origin.y, TIME_BUTTON_WIDTH, TIME_BUTTON_HEIGHT)];
            statsData = [NSMutableArray arrayWithObjects:@"line_f_1",@"line_f_2",@"line_f_3",@"line_f_4",@"line_d_1",@"line_d_2",@"line_d_3",@"line_d_4", nil];
            if (playerNumberArr.count > 0) {
                [statsData addObjectsFromArray:playerNumberArr];
            }
            while(statsData.count < 10) {
                [statsData addObject: @"-1"];
            }
            [statsTableView reloadData];
            break;
            
        default:
            break;
    }
}

-(void)outputReport:(id)sender{
    
}
//player selected and then filter the events
-(void)playerSelected:(id)sender{
    BorderButton *button = (BorderButton*)sender;
    if (!button.selected) {
        button.selected = TRUE;
        if (!selectedPlayersArr) {
            selectedPlayersArr = [NSMutableArray arrayWithObject:button.accessibilityLabel];
        }else{
            [selectedPlayersArr addObject:button.accessibilityLabel];
        }
    }else{
        button.selected = FALSE;
        [selectedPlayersArr removeObject:button.accessibilityLabel];
    }
    
     //if any player or event selected, call the filter methods, otherwise passing [globals.CURRENT_EVENT_THUMBNAILS allValues] to getStatsData method
    if (selectedPlayersArr.count > 0 || selectedEventsArr.count >0) {
        arrayOfMatchedTags = [self filterPlayersAndEvents];
        [self getStatsData:arrayOfMatchedTags];

    }else{
        arrayOfMatchedTags = [[globals.CURRENT_EVENT_THUMBNAILS allValues]mutableCopy];
        [self getStatsData:arrayOfMatchedTags];
    }
        
}


//events selected and then filter the events
-(void)eventSelected:(id)sender{

    BorderButton *button = (BorderButton*)sender;
    if (!button.selected) {
        button.selected = TRUE;
        if (!selectedEventsArr) {
            selectedEventsArr = [NSMutableArray arrayWithObject:button.titleLabel.text];
        }else{
            [selectedEventsArr addObject:button.titleLabel.text];
        }
    }else{
        button.selected = FALSE;
        [selectedEventsArr removeObject:button.titleLabel.text];
    }
    
    //if any player or event selected, call the filter methods, otherwise passing [globals.CURRENT_EVENT_THUMBNAILS allValues] to getStatsData method
    if (selectedPlayersArr.count > 0 || selectedEventsArr.count >0) {
        arrayOfMatchedTags = [self filterPlayersAndEvents];
        [self getStatsData:arrayOfMatchedTags];
        
    }else{
        arrayOfMatchedTags = [[globals.CURRENT_EVENT_THUMBNAILS allValues]mutableCopy];
        [self getStatsData:arrayOfMatchedTags];
    }

}

//filter tags by players and events, return an array of tags which mathches the selections
-(NSMutableArray*)filterPlayersAndEvents{
    
    if (gridCellButtonSelected) {
        gridCellButtonSelected.selected = FALSE;
        gridCellButtonSelected = nil;
    }
    
    NSMutableArray *arrayOfSelectedTags;
    
    if (selectedPlayersArr.count > 0 && (selectedEventsArr.count ==0 || !selectedEventsArr)) {
        for (NSDictionary *tag in [globals.CURRENT_EVENT_THUMBNAILS allValues]) {
            if (([[tag objectForKey:@"type"]integerValue] == 0 || [[tag objectForKey:@"type"]integerValue] == 100) && [[tag  objectForKey:@"player"]count]>0 && ![[[tag objectForKey:@"player"] objectAtIndex:0] isEqualToString: @""]) {
                NSMutableSet *set1 = [NSMutableSet setWithArray: [tag  objectForKey:@"player"]];
                NSSet *set2 = [NSSet setWithArray: selectedPlayersArr];
                [set1 intersectSet: set2];
                NSArray *resultArray = [set1 allObjects];
                if (resultArray.count > 0) {
                    if (!arrayOfSelectedTags) {
                        arrayOfSelectedTags = [NSMutableArray arrayWithObject:tag];
                    }else{
                        [arrayOfSelectedTags addObject:tag];
                    }
                }
            }
        }
    }else if (selectedPlayersArr.count > 0 && selectedEventsArr.count > 0){
        for (NSDictionary *tag in [globals.CURRENT_EVENT_THUMBNAILS allValues]) {
            if (([[tag objectForKey:@"type"]integerValue] == 0 || [[tag objectForKey:@"type"]integerValue] == 100) && [selectedEventsArr containsObject:[tag objectForKey:@"name"]]  && [[tag  objectForKey:@"player"]count]>0 && ![[[tag objectForKey:@"player"] objectAtIndex:0] isEqualToString: @""]) {
                NSMutableSet *set1 = [NSMutableSet setWithArray: [tag  objectForKey:@"player"]];
                NSSet *set2 = [NSSet setWithArray: selectedPlayersArr];
                [set1 intersectSet: set2];
                NSArray *resultArray = [set1 allObjects];
                if (resultArray.count > 0) {
                    if (!arrayOfSelectedTags) {
                        arrayOfSelectedTags = [NSMutableArray arrayWithObject:tag];
                    }else{
                        [arrayOfSelectedTags addObject:tag];
                    }
                }
            }
        }

    }else  if (selectedEventsArr.count > 0 && (selectedPlayersArr.count==0 || !selectedPlayersArr)) {
        for(NSDictionary *tag in [globals.CURRENT_EVENT_THUMBNAILS allValues]){
            if (([[tag objectForKey:@"type"]integerValue] == 0 || [[tag objectForKey:@"type"]integerValue] == 100) && [selectedEventsArr containsObject:[tag objectForKey:@"name"]]) {
                if (!arrayOfSelectedTags) {
                    arrayOfSelectedTags = [NSMutableArray arrayWithObject:tag];
                }else{
                    [arrayOfSelectedTags addObject:tag];
                }
            }
        }
    }

   
    return arrayOfSelectedTags;
}

/********** STRUCTURE OF dataDict ****************
 
 ***********************************************************************
 *****************when the GAME STATS tab is selected*******************
 ***********************************************************************
 
 gameStatsDataDict is a big dictionary whith keys are tagnames:
 
 gameStatsDataDict{
         tagName1{
                 timeInterval1{tag1,tag2,....tagX}
                 timeInterval2{...}
                     .
                     .
                     .
                 timeIntervalX{...}
     
                  }
         tagName2{...}
         .
         .
         .
         tagNameX{...}

     }
 
And the object for the each key is another big dictionary with key values are time:
 
 tagName1{
     time1{tag1,tag2,....tagX}
     time2{...}
     .
     .
     .
     timeX{...}
 }
 
 And the object for each time key is an array of tags which belongs to the time interval.
 For example:
 
 time1{tag1,tag2,....tagX}
 
 All the tags happened duration the time interval: [time1 - timeInterval, time1)
 
 Methods:getStatsData and addObjectinDict: are creating the dataDict according to the current time line's start time, current time interval and current event tags

***********************************************************************
*****************when the Time on Ice tab is selected*****************
***********************************************************************
 timeOnIceDataDict is a big dictionary with keys:@"line_f_1",@"line_f_2",@"line_f_3",@"line_f_4",@"line_d_1",@"line_d_2",@"line_d_3",@"line_d_4".
 
 timeOnIceDataDict{
 
         line_f_1{  //(All line_f_1 tags are saved in this dictionary with keys(tag time) and objects(tag))
                  lineTagTime1:lineTag1
                  lineTagTime2:lineTag2
                             .
                             .
                             .
                  lineTagTimeX:lineTagX

                 }
              .
              .
              .
         line_d_4{
                 lineTagTime1:lineTag1
                 lineTagTime2:lineTag2
                 .
                 .
                 .
                 lineTagTimeX:lineTagX

                }
 
        }
 
 
***********************************************************************
*****************when the PLAYER STATS tab is selected*****************
***********************************************************************
playerStatsDataDict is a big dictionary with keys are player numbers:

    playerStatsDataDict{
                playerNumber1{
                    tagName1{tag1,tag2,....tagX}
                    tagName2{...}
                    .
                    .
                    .
                    tagNameX{...}
                    
                }
                playerNumber2{...}
                .
                .
                .
                playerNumberX{...}
 
              }

    And the object for the each key(playerNumberX) is another big dictionary with key values are tag names(all the tag name events belong to the player):

    playerNumber1{
        tagName1{tag1,tag2,....tagX}
        tagName2{...}
        .
        .
        .
        tagNameX{...}
    }

    And the object for each tag name key is an array of tags which have the same tag name.
    For example:

    tagName1{tag1,tag2,....tagX}

********************/
//get data for table view to display
-(void)getStatsData:(NSArray*)dataArr{
    statsData = nil;
    gameStatsDataDict = nil;
    playerStatsDataDict = nil;
    timeOnIceDataDict = nil;
    
    for(NSDictionary *tag in dataArr){
        if ([[tag objectForKey:@"type"]integerValue] == 0 || [[tag objectForKey:@"type"]integerValue] == 100) {
          //data for game stats tab
            if (!gameStatsDataDict) {
                gameStatsDataDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSMutableDictionary alloc]init],[tag objectForKey:@"name"], nil];
            }else{
                if (![[gameStatsDataDict allKeys] containsObject:[tag objectForKey:@"name"]]) {
                    [gameStatsDataDict setObject:[[NSMutableDictionary alloc]init] forKey:[tag objectForKey:@"name"]];
                }
            }
            [self addObjectinDict:tag];

//            //data for player stats tab; Not used now
//            if ([[tag objectForKey:@"player"]count]>0 && ![[[tag objectForKey:@"player"] objectAtIndex:0] isEqualToString: @""]) {
//                for(id playerNumber in [tag objectForKey:@"player"]){
//                    NSString *playerStr = [NSString stringWithFormat:@"%@",playerNumber];
//                    if (!playerStatsDataDict) {
//                        playerStatsDataDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSMutableArray arrayWithObject:tag],[tag objectForKey:@"name"], nil],playerStr, nil];
//                    }else if(![[playerStatsDataDict allKeys] containsObject:playerStr]){
//                        [playerStatsDataDict setObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSMutableArray arrayWithObject:tag],[tag objectForKey:@"name"], nil] forKey:playerStr];
//                    }else{
//                        [[[playerStatsDataDict objectForKey:playerStr] objectForKey:[tag objectForKey:@"name"]]addObject:tag];
//                    }
//                }
//            }
            
        }else if ([[tag objectForKey:@"type"]integerValue] == 2 || [[tag objectForKey:@"type"]integerValue] == 6){
            if (!timeOnIceDataDict) {
                timeOnIceDataDict = [NSMutableDictionary dictionaryWithObject:[NSMutableDictionary dictionaryWithObject:tag forKey:[NSString stringWithFormat:@"%@",[tag objectForKey:@"time"]]] forKey:[NSString stringWithFormat:@"%@",[tag objectForKey:@"name"]]];
            }else if (![[timeOnIceDataDict allKeys] containsObject:[tag objectForKey:@"name"]]){
                [timeOnIceDataDict setObject:[NSMutableDictionary dictionaryWithObject:tag forKey:[NSString stringWithFormat:@"%@",[tag objectForKey:@"time"]]] forKey:[NSString stringWithFormat:@"%@",[tag objectForKey:@"name"]]];
            }else{
                [[timeOnIceDataDict objectForKey:[NSString stringWithFormat:@"%@",[tag objectForKey:@"name"]]] setObject:tag forKey:[NSString stringWithFormat:@"%@",[tag objectForKey:@"time"]]];
            }
        }
    
        
    }
    //make sure the 10 table cells in the stats view have grid cells
    //if -(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath not called, not grid cells will be created
    
    statsData = [NSMutableArray arrayWithArray:[gameStatsDataDict allKeys]];
    if (!statsData) {
        statsData = [[NSMutableArray alloc]init];
    }
    while(statsData.count < 10) {
        [statsData addObject: @"-1"];
    }
    
    [statsTableView reloadData];
}

-(void)addObjectinDict:(NSDictionary*)tag{
    float tagTime= [[tag objectForKey:@"time"]floatValue];
    NSString *tagName = [tag objectForKey:@"name"];
    NSMutableDictionary *currentTagDict = [gameStatsDataDict objectForKey:tagName];
    for(int i = 1; i< 17; i++){
        if ((i < 16 && tagTime >= (startTime + timeInterval*(i-1))*60 && tagTime < (startTime + timeInterval*i)*60) || (i == 16 && tagTime >= (startTime + timeInterval*(i-1))*60 && tagTime < endTime*60)){
            //NSLog(@"start time %d, end time %d, interval %f, tagTime %f, cell number %d",startTime,endTime,timeInterval,tagTime,i);
            NSString *timeKeyStr = [NSString stringWithFormat:@"%f",startTime + timeInterval*i];
            if (![[currentTagDict allKeys]containsObject:timeKeyStr]) {
                [currentTagDict setObject:[NSMutableArray arrayWithObject:tag] forKey:timeKeyStr];
            }else{
                [[currentTagDict objectForKey:timeKeyStr] addObject:tag];
            }

            break;
        }
    }
    [gameStatsDataDict setObject:currentTagDict forKey:tagName];
}

-(void)resetStatsData{
    
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    StatsCell *cell = [[StatsCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"StatsCell"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //this line removes the white space of the cell head
    cell.separatorInset = UIEdgeInsetsZero;
    if (tabContentView.tag == 0) {
        [cell addColumns:17 :GRID_CELL_HEIGHT :EVENT_NAME_CELL_LENGTH];
    }else if(tabContentView.tag == 1){
        [cell addColumns:2 :STATS_TABLE_VIEW_WIDTH - EVENT_NAME_CELL_LENGTH - TOTAL_NUMBER_CELL_LENGTH :EVENT_NAME_CELL_LENGTH];
    }
    
    
    NSString *cellName = [statsData objectAtIndex:indexPath.row];
    
    if ([cellName intValue] == -1) {
        return cell;
    }else{

        UILabel *cellNameLabel = [[UILabel alloc]init];//WithFrame:CGRectMake(0, 0, EVENT_NAME_CELL_LENGTH, GRID_CELL_HEIGHT)];
        [cellNameLabel setTextAlignment:NSTextAlignmentCenter];
        [cell addSubview:cellNameLabel];
        
        if (tabContentView.tag == 0) {
            
            [cellNameLabel setFrame:CGRectMake(0, 0, EVENT_NAME_CELL_LENGTH, GRID_CELL_HEIGHT)];
            [cellNameLabel setText:cellName];
            
            int totalNumber = 0;
            
            for(NSString *timeStr in [[gameStatsDataDict objectForKey:cellName]allKeys]){
                float time = [timeStr floatValue];
                int i = (int)((time - startTime)/timeInterval); //the number of grid cell which the button will be created inside
                BorderButton *button = [BorderButton buttonWithType:UIButtonTypeCustom];
                [button setAccessibilityLabel:timeStr];
                [button setFrame:CGRectMake(EVENT_NAME_CELL_LENGTH+(i-1)*GRID_CELL_HEIGHT + (GRID_CELL_HEIGHT-GRID_CELL_BUTTON_WIDTH)/2.0, (GRID_CELL_HEIGHT-GRID_CELL_BUTTON_WIDTH)/2.0, GRID_CELL_BUTTON_WIDTH, GRID_CELL_BUTTON_WIDTH)];
                //how many tags in this time interval
                int number = [[[gameStatsDataDict objectForKey:cellName]objectForKey:timeStr]count];
                totalNumber += number;
                [button setTitle:[NSString stringWithFormat:@"%d",number] forState:UIControlStateNormal];
                [button addTarget:self action:@selector(showTagsDetails:event:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:button];
            }
            UILabel *totalNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(1024 - TOTAL_NUMBER_CELL_LENGTH, 0, TOTAL_NUMBER_CELL_LENGTH, GRID_CELL_HEIGHT)];
            [totalNumberLabel setText:[NSString stringWithFormat:@"%d",totalNumber]];
            [totalNumberLabel setTextAlignment:NSTextAlignmentCenter];
            [cell addSubview:totalNumberLabel];

        }else if (tabContentView.tag == 1){
            if ([globals.WHICH_SPORT isEqualToString:@"hockey"]) {
                [cellNameLabel setFrame:CGRectMake(0, 0, EVENT_NAME_CELL_LENGTH, GRID_CELL_HEIGHT)];
                [cellNameLabel setText:cellName];
            }
          
            float totalTime = 0;
            for(NSString *shiftStartTimeStr in [[onIceTimeDurations objectForKey:cellName]allKeys]){
                float shiftStartTime = [shiftStartTimeStr floatValue];
                if ([shiftStartTimeStr isEqualToString:@"0.01"]) {
                    shiftStartTime = 0;
                }
                //only display the shift between the table time line [startTime, endTime)
                if (startTime*60 <= shiftStartTime && shiftStartTime <= endTime*60) {
                    float shiftEndTime = [[[onIceTimeDurations objectForKey:cellName]objectForKey:shiftStartTimeStr]floatValue];
                    float buttonXValue = CGRectGetMaxX(cellNameLabel.frame)+ (shiftStartTime - startTime*60)*GRID_CELL_HEIGHT/(timeInterval*60);
                    float shiftDuration;
                    float buttonLength;
                    //if the shift end time is beyond ght table time line interval, then set the shift end time to endTime
                    if (endTime*60 < shiftEndTime) {
                        shiftDuration = endTime*60 - shiftStartTime;
                        buttonLength = STATS_TABLE_VIEW_WIDTH - TOTAL_NUMBER_CELL_LENGTH - buttonXValue;
                    }else{
                        shiftDuration = shiftEndTime - shiftStartTime;
                        buttonLength = shiftDuration *GRID_CELL_HEIGHT/(timeInterval*60);
                        
                        //In table header view, the total time is divided into 16 small time intervals.
                        //For accuracy, timeInterval is set to be integer (if it is greater or equal to 1min): timeInterval = (int)(endTime - startTime)/16.0, so we could not alway evenly distribute the time in table header view's time line;
                        //If timeInterval < (endTime - startTime)/16.0, the first 15 time cells's time duration is equal to timeInterval and the last time cell's time duration is (endTime - 15*timeInterval) which might be much greater than timeInterval, in this case,the following condition will happen.
                        if (buttonLength + buttonXValue > STATS_TABLE_VIEW_WIDTH - TOTAL_NUMBER_CELL_LENGTH) {
                             buttonLength = STATS_TABLE_VIEW_WIDTH - TOTAL_NUMBER_CELL_LENGTH - buttonXValue;
                        }
                    }

                    BorderButton *button = [BorderButton buttonWithType:UIButtonTypeCustom];
                    [button setAccessibilityLabel:shiftStartTimeStr];
                    [button setAccessibilityValue:[NSString stringWithFormat:@"%f",shiftEndTime]];
                    [button setFrame:CGRectMake(buttonXValue, (GRID_CELL_HEIGHT-GRID_CELL_BUTTON_WIDTH)/2.0, buttonLength, GRID_CELL_BUTTON_WIDTH)];
                    NSString *titleStr;
                    if (buttonLength < 30) {
                        titleStr = @"...";
                    }else{
                        titleStr = [NSString stringWithFormat:@"%.0fs",shiftDuration];
                    }
                    [button setTitle:titleStr forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    [button addTarget:self action:@selector(showTagsDetails:event:) forControlEvents:UIControlEventTouchUpInside];
                    [cell addSubview:button];
                    totalTime = totalTime + shiftDuration;

                }
            }
            
            if ([globals.WHICH_SPORT isEqualToString:@"hockey"]) {
                UILabel *totalNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(1024 - TOTAL_NUMBER_CELL_LENGTH, 0, TOTAL_NUMBER_CELL_LENGTH, GRID_CELL_HEIGHT)];
                [totalNumberLabel setText:[NSString stringWithFormat:@"%.0fs",totalTime]];
                [totalNumberLabel setTextAlignment:NSTextAlignmentCenter];
                [cell addSubview:totalNumberLabel];
            }

        }

        
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}
-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return statsData.count;
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return GRID_CELL_HEIGHT;
}

//create custom table title view
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *customView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, TABLE_VIEW_HEADER_HEIGHT)];
    [customView setBackgroundColor:[UIColor colorWithWhite:0.9f alpha:1.0f]];
    //title label
    UILabel *headerNameLabel = [[UILabel alloc]init];//WithFrame:CGRectMake(0, 0, EVENT_NAME_CELL_LENGTH, customView.frame.size.height)];
    [headerNameLabel setFont:[UIFont defaultFontOfSize:17.0]];
    [headerNameLabel setTextAlignment:NSTextAlignmentCenter];
    [customView addSubview:headerNameLabel];
    
    if(tabContentView.tag == 0){
        [headerNameLabel setFrame:CGRectMake(0, 0, EVENT_NAME_CELL_LENGTH, customView.frame.size.height)];
        [headerNameLabel setText:@"Event"];
    }else if (tabContentView.tag == 1){
        [headerNameLabel setFrame:CGRectMake(0, 0, EVENT_NAME_CELL_LENGTH, customView.frame.size.height)];
        [headerNameLabel setText:@"Shift & Player"];
    }
    
    for(int i = 0; i < 16; i++){
        
        UILabel *timeLabel = [[UILabel alloc]init];
        [timeLabel setText:[NSString stringWithFormat:@"%.2fm",startTime + timeInterval*i]];
        [timeLabel setFont:[UIFont defaultFontOfSize:11.0]];
        [timeLabel setTextAlignment:NSTextAlignmentCenter];
        [customView addSubview:timeLabel];
        if (tabContentView.tag == 0) {
            [timeLabel setFrame:CGRectMake(CGRectGetMaxX(headerNameLabel.frame) + GRID_CELL_HEIGHT*i - TIME_LABEL_WIDTH/2.0 , 20, TIME_LABEL_WIDTH, customView.frame.size.height-20)];
        }else if (tabContentView.tag == 1){
            [timeLabel setFrame:CGRectMake(CGRectGetMaxX(headerNameLabel.frame) + GRID_CELL_HEIGHT*i - TIME_LABEL_WIDTH/2.0 , 15, TIME_LABEL_WIDTH, customView.frame.size.height-20)];
            //short lines indicate time positions
            UILabel *grayLine = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(headerNameLabel.frame) + GRID_CELL_HEIGHT*i - 1, CGRectGetMaxY(timeLabel.frame), 2, 5)];
            [grayLine setBackgroundColor:[UIColor colorWithWhite:0.7 alpha:1.0]];
            [customView addSubview:grayLine];
        }
       
    }
    
    //last label with text to be the end time
    UILabel *timeLabel = [[UILabel alloc]init];
    [timeLabel setText:[NSString stringWithFormat:@"%.2fm",(float)endTime]];
    [timeLabel setFont:[UIFont defaultFontOfSize:11.0]];
    [timeLabel setTextAlignment:NSTextAlignmentCenter];
    [customView addSubview:timeLabel];
    if (tabContentView.tag == 0) {
        [timeLabel setFrame:CGRectMake(CGRectGetMaxX(headerNameLabel.frame) + GRID_CELL_HEIGHT*16 - TIME_LABEL_WIDTH/2.0 , 20, TIME_LABEL_WIDTH, customView.frame.size.height-20)];
    }else{
        [timeLabel setFrame:CGRectMake(CGRectGetMaxX(headerNameLabel.frame) + GRID_CELL_HEIGHT*16 - TIME_LABEL_WIDTH/2.0 , 15, TIME_LABEL_WIDTH, customView.frame.size.height-20)];
        //short lines indicate time positions
        UILabel *grayLine = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(headerNameLabel.frame) + GRID_CELL_HEIGHT*16 - 1, CGRectGetMaxY(timeLabel.frame), 2, 5)];
        [grayLine setBackgroundColor:[UIColor colorWithWhite:0.7 alpha:1.0]];
        [customView addSubview:grayLine];
    }
   
    
    UILabel *totalNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(930, 0, TOTAL_NUMBER_CELL_LENGTH, customView.frame.size.height)];
    [totalNumberLabel setText:@"Total"];
    [totalNumberLabel setFont:[UIFont defaultFontOfSize:20.0]];
    [totalNumberLabel setTextAlignment:NSTextAlignmentCenter];
    [customView addSubview:totalNumberLabel];

    
    return customView;
}

-(float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return TABLE_VIEW_HEADER_HEIGHT;
}

-(void)showTagsDetails:(id)sender event:(UIEvent *)event{
    BorderButton *button = (BorderButton*)sender;
    //highlight selected button
    if (gridCellButtonSelected && ![gridCellButtonSelected isEqual:button]) {
        gridCellButtonSelected.selected = FALSE;
    }
    gridCellButtonSelected = button;
    gridCellButtonSelected.selected = TRUE;
    
    NSIndexPath *indexPath = [statsTableView indexPathForRowAtPoint:[[[event touchesForView:sender] anyObject] locationInView:statsTableView]];
    NSString *cellName = [statsData objectAtIndex:indexPath.row];
    NSArray *tagsArr;
    if (tabContentView.tag == 0) {
        tagsArr = [[gameStatsDataDict objectForKey:cellName]objectForKey:button.accessibilityLabel];
    }else if (tabContentView.tag == 1){
        tagsArr = [NSArray arrayWithObject:[[timeOnIceDataDict objectForKey:cellName]objectForKey:button.accessibilityLabel]];
    }
    
    UIViewController* popoverContent = [[UIViewController alloc] init];
    UIScrollView *popoverView = [[UIScrollView alloc]init];
    
    for(NSDictionary *tag in tagsArr){
        
        int i = [tagsArr indexOfObject:tag];
        
        //play button with background image which is the tag thumbnail
        CustomButton *playButton;
        playButton = [CustomButton buttonWithType:UIButtonTypeCustom];
        [playButton setAccessibilityLabel:[tag objectForKey:@"time"]];
        [playButton setAccessibilityValue:[tag objectForKey:@"duration"]];
        playButton.associatedTag = tag;
        [playButton addTarget:self action:@selector(playTag:) forControlEvents:UIControlEventTouchUpInside];
        NSString *currentImage;
        globals.THUMBNAILS_PATH = [[globals.EVENTS_PATH stringByAppendingPathComponent:globals.EVENT_NAME] stringByAppendingPathComponent:@"thumbnails"];
        currentImage = [globals.THUMBNAILS_PATH stringByAppendingPathComponent:[[tag objectForKey:@"url"] lastPathComponent]];
        [playButton setBackgroundImage:[UIImage imageWithContentsOfFile:currentImage] forState:UIControlStateNormal];
        [playButton setFrame:CGRectMake(10, 10 + (PLAY_BUTTON_HEIGHT + 20)*i, PLAY_BUTTON_WIDTH,PLAY_BUTTON_HEIGHT)];
        [popoverView addSubview:playButton];

        //label for tag time
        UILabel *tagTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(playButton.frame) +10, playButton.frame.origin.y, 300, 18)];
        [tagTimeLabel setText:[NSString stringWithFormat:@"Tag time: %@ ",[tag objectForKey:@"displaytime"]]];
        [tagTimeLabel setTextAlignment:NSTextAlignmentLeft];
        [tagTimeLabel setFont:[UIFont defaultFontOfSize:13.0f]];
        [popoverView addSubview:tagTimeLabel];
        
        //label for tag duration
        UILabel *tagDurationLabel = [[UILabel alloc]initWithFrame:CGRectMake(tagTimeLabel.frame.origin.x, CGRectGetMaxY(tagTimeLabel.frame) , 300, tagTimeLabel.frame.size.height)];
        [tagDurationLabel setText:[NSString stringWithFormat:@"Tag length: %@s ",[tag objectForKey:@"duration"]]];
        [tagDurationLabel setTextAlignment:NSTextAlignmentLeft];
        [tagDurationLabel setFont:[UIFont defaultFontOfSize:13.0f]];
        [popoverView addSubview:tagDurationLabel];

        
        //label for players info
        UILabel *tagPlayersLabel = [[UILabel alloc]initWithFrame:CGRectMake(tagTimeLabel.frame.origin.x, CGRectGetMaxY(tagDurationLabel.frame) , tagTimeLabel.frame.size.width, tagTimeLabel.frame.size.height)];
        NSString *playerString;
        if ([[tag  objectForKey:@"player"]count]>0 && ![[[tag objectForKey:@"player"] objectAtIndex:0] isEqualToString: @""] ) {
            playerString = [[tag  objectForKey:@"player"] componentsJoinedByString: @","];
            [tagPlayersLabel setText:[NSString stringWithFormat:@"Players' #: %@",playerString]];
        }else{
            [tagPlayersLabel setText:@"No player tagged."];
        }
        [tagPlayersLabel setTextAlignment:NSTextAlignmentLeft];
        [tagPlayersLabel setFont:[UIFont defaultFontOfSize:13.0f]];
        //[tagPlayersLabel setBackgroundColor:[UIColor greenColor]];
        [popoverView addSubview:tagPlayersLabel];
        
        //label for tag name
        UILabel *tagNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(tagTimeLabel.frame.origin.x, CGRectGetMaxY(tagPlayersLabel.frame), 300, tagTimeLabel.frame.size.height)];
        [tagNameLabel setText:[NSString stringWithFormat:@"%@ ",[tag objectForKey:@"name"]]];
        [tagNameLabel setTextAlignment:NSTextAlignmentLeft];
        [tagNameLabel setFont:[UIFont defaultFontOfSize:13.0f]];
        [popoverView addSubview:tagNameLabel];

    }
    
    popoverContent.view = popoverView;
    popoverController = [[UIPopoverController alloc]initWithContentViewController:popoverContent];
    if (tagsArr.count > 11) {
        [popoverView setContentSize:CGSizeMake(2.2*PLAY_BUTTON_WIDTH, (PLAY_BUTTON_HEIGHT+20)*tagsArr.count + 10)];
        [popoverController setPopoverContentSize:CGSizeMake(2.2*PLAY_BUTTON_WIDTH, (PLAY_BUTTON_HEIGHT+20)*11 + 10) animated:NO];
        [popoverView setScrollEnabled:TRUE];
        popoverView.showsVerticalScrollIndicator = TRUE;
    }else{
        [popoverController setPopoverContentSize:CGSizeMake(2.2*PLAY_BUTTON_WIDTH, (PLAY_BUTTON_HEIGHT+20)*tagsArr.count + 10) animated:NO];
        [popoverView setScrollEnabled:FALSE];
    }
    [popoverController presentPopoverFromRect:[sender bounds] inView:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:NO];
}

-(void)playTag:(CustomButton*)sender{
    
    [self.popoverController dismissPopoverAnimated:YES];
    
    CustomTabBar* tabController = (CustomTabBar*)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
    
    Live2BenchViewController* l2bController = [[tabController viewControllers] objectAtIndex:2];
    [l2bController setCurrentPlayingTag:sender.associatedTag];
    
    tabController.selectedIndex = 2;
}

-(void)removeStatsVideoPlayer{
    
    [self invalidateTimer];
    [videoPlayer.view removeFromSuperview];
    
}

//stop the loop timer
- (void)invalidateTimer
{
    [loopTimerStatsView invalidate];
    loopTimerStatsView = nil;
}

//back from fullscreen view
-(void)willExitFullScreen{

}


-(void)changeTimeLineInfo:(id)sender{
    
    UIViewController* popoverContent = [[UIViewController alloc] init];
    UIView *popoverView = [[UIView alloc] init];
   
    //init start time picker view
    startTimePickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(45, 10,80,30 )];
    [startTimePickerView setDataSource:self];
    [startTimePickerView setDelegate:self];
    startTimePickerView.layer.borderColor = [UIColor colorWithWhite:0.9f alpha:1.0f].CGColor;
    startTimePickerView.layer.borderWidth = 1;
    startTimePickerView.showsSelectionIndicator = YES;
    int selectedRow = [startTimePikerData indexOfObject:[NSString stringWithFormat:@"%d",(int)startTime]];
    [startTimePickerView selectRow:selectedRow inComponent:0 animated:NO];
    [popoverView addSubview:startTimePickerView];

    UILabel *startTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(startTimePickerView.frame.origin.x -25,CGRectGetMaxY(startTimePickerView.frame), 130, 60)];
    [startTimeLabel setText:@"Start Time (mins)"];
    [startTimeLabel setTextAlignment:NSTextAlignmentCenter];
    [popoverView addSubview:startTimeLabel];
    
    //init start time picker view
    endTimePickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(startTimeLabel.frame) + 60, 10,80,30 )];
    [endTimePickerView setDataSource:self];
    [endTimePickerView setDelegate:self];
    endTimePickerView.layer.borderColor = [UIColor colorWithWhite:0.9f alpha:1.0f].CGColor;
    endTimePickerView.layer.borderWidth = 1;
    endTimePickerView.showsSelectionIndicator = YES;
    selectedRow = [endTimePikerData indexOfObject:[NSString stringWithFormat:@"%d",endTime]];
    [endTimePickerView selectRow:selectedRow inComponent:0 animated:NO];
    [popoverView addSubview:endTimePickerView];
    
    UILabel *endTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(endTimePickerView.frame.origin.x - 25,startTimeLabel.frame.origin.y, startTimeLabel.frame.size.width, startTimeLabel.frame.size.height)];
    [endTimeLabel setText:@"End Time (mins)"];
    [endTimeLabel setTextAlignment:NSTextAlignmentCenter];
    [popoverView addSubview:endTimeLabel];
    
    popoverContent.view = popoverView;
    popoverController = [[UIPopoverController alloc]initWithContentViewController:popoverContent];
    [popoverController setPopoverContentSize:CGSizeMake(340, 250) animated:NO];
    [popoverController presentPopoverFromRect:[sender bounds] inView:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:NO];
}

-(void)updateTimeInfoButton{
    float timeValue = (endTime - startTime)/16.0;
    if (timeValue > 1 || timeValue == 1) {
        int intValue = (int)timeValue;
        if ((timeValue > intValue && timeValue < intValue + 0.25 ) || timeValue == intValue) {
            timeInterval = intValue;
        }else if ((timeValue > intValue + 0.25 && timeValue < intValue + 0.5 ) || timeValue == intValue + 0.25){
            timeInterval = intValue + 0.25;
        }else if ((timeValue > intValue + 0.5 && timeValue < intValue + 0.75 ) || timeValue == intValue + 0.5){
            timeInterval = intValue + 0.5;
        }else if ((timeValue > intValue + 0.75 && timeValue < intValue + 1 ) || timeValue == intValue + 0.75){
            timeInterval = intValue + 0.75;
        }
    }else if ((timeValue > 0.5 && timeValue < 1) || timeValue == 0.5){
        timeInterval = 0.5;
    }else if((timeValue > 0.25 && timeValue < 0.5) || timeValue == 0.25){
        timeInterval = 0.25;
    }else if(endTime == 3){
        timeInterval = 0.15;
    }else{
        timeInterval = 0.1;
    }
    [timeLineInfoButton setTitle:[NSString stringWithFormat:@"Duration: [%d, %d)",startTime,endTime] forState:UIControlStateNormal];
    
}

//delegate methods for picker view

//display each row's data
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if ([pickerView isEqual:startTimePickerView]) {
        return [startTimePikerData objectAtIndex:row];
    }else{
        return [endTimePikerData objectAtIndex:row];
    }
}

-(int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if ([pickerView isEqual:startTimePickerView]) {
        return [startTimePikerData count];
    }else{
        return [endTimePikerData count];
    }
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if ([pickerView isEqual:startTimePickerView]) {
        startTime = [[startTimePikerData objectAtIndex:row]intValue];
    }else{
         endTime = [[endTimePikerData objectAtIndex:row]intValue];
    }
    //NSLog(@"start time %d,end time %d",startTime,endTime);
    [self updateTimeInfoButton];
    if (tabContentView.tag == 0) {
        [self getStatsData:arrayOfMatchedTags];
    }else if(tabContentView.tag == 1){
        [statsTableView reloadData];
    }
  
    
}


//expand time interval and reload data
-(void)expandTimeInterval:(id)sender{
    UIButton *button = (UIButton*)sender;
    if (!button.selected) {
        [button setBackgroundColor:[UIColor orangeColor]];
        button.selected = TRUE;
    }else{
        [button setBackgroundColor:[UIColor clearColor]];
        button.selected = FALSE;
    }
    //NSLog(@"time button pressed!");
}


-(void)buttonSelected:(CustomButton*)button{
    NSString *att = button.accessibilityLabel;
    if (!button.selected) {
        button.selected = TRUE;
        if (!taggedAttsDict) {
            taggedAttsDict = [NSMutableDictionary dictionaryWithObject:[NSMutableArray arrayWithObject:button.accessibilityValue] forKey:att];
        }else if (![[taggedAttsDict allKeys] containsObject:att]) {
            [taggedAttsDict setObject:[NSMutableArray arrayWithObject:button.accessibilityValue] forKey:att];
        }else{
            [[taggedAttsDict objectForKey:att] addObject:button.accessibilityValue];
        }
        
        // [att isEqualToString:@"homestr"]: array of home strength value selected, i.e. @"3",@"4";
        // [att isEqualToString:@"awaystr"]: array of away strength value selected, i.e. @"5",@"6";
        // [taggedAttsDict objectForKey:@"strength"]: array of patterns of home strength V.S. away strength, i.e.@"3,5",@"3,6",@"4,5",@"4,6"
        if ([att isEqualToString:@"homestr"] || [att isEqualToString:@"awaystr"]) {
            //delete the old stength patterns, then get new ones
            if ([taggedAttsDict objectForKey:@"strength"]) {
                [taggedAttsDict removeObjectForKey:@"strength"];
            }
            NSArray *allStrengthValues = @[@"3",@"4",@"5",@"6"];
            if ([taggedAttsDict objectForKey:@"homestr"] && ![taggedAttsDict objectForKey:@"awaystr"]) {
                [self getSelectedStrengthPatterns:[taggedAttsDict objectForKey:@"homestr"] :allStrengthValues];
            }else if ([taggedAttsDict objectForKey:@"awaystr"] && ![taggedAttsDict objectForKey:@"homestr"]){
                [self getSelectedStrengthPatterns:allStrengthValues :[taggedAttsDict objectForKey:@"awaystr"]];
            }else{
                 [self getSelectedStrengthPatterns:[taggedAttsDict objectForKey:@"homestr"] :[taggedAttsDict objectForKey:@"awaystr"]];
            }
            
        }
        
    }else{
        button.selected = FALSE;
        [[taggedAttsDict objectForKey:att] removeObject:button.accessibilityValue];
        if ([[taggedAttsDict objectForKey:att]count] < 1) {
            [taggedAttsDict removeObjectForKey:att];
        }
        
        if ([att isEqualToString:@"homestr"] || [att isEqualToString:@"awaystr"]) {
            if ([taggedAttsDict objectForKey:@"strength"]) {
                [taggedAttsDict removeObjectForKey:@"strength"];
            }
            NSArray *allStrengthValues = @[@"3",@"4",@"5",@"6"];
            if ([taggedAttsDict objectForKey:@"homestr"] && ![taggedAttsDict objectForKey:@"awaystr"]) {
                [self getSelectedStrengthPatterns:[taggedAttsDict objectForKey:@"homestr"] :allStrengthValues];
            }else if ([taggedAttsDict objectForKey:@"awaystr"] && ![taggedAttsDict objectForKey:@"homestr"]){
                [self getSelectedStrengthPatterns:allStrengthValues :[taggedAttsDict objectForKey:@"awaystr"]];
            }else if([taggedAttsDict objectForKey:@"homestr"] && [taggedAttsDict objectForKey:@"awaystr"]){
                [self getSelectedStrengthPatterns:[taggedAttsDict objectForKey:@"homestr"] :[taggedAttsDict objectForKey:@"awaystr"]];
            }
            
        }

    }
    if ([taggedAttsDict count] < 1) {
        arrayOfMatchedTags = [NSMutableArray arrayWithArray:[globals.CURRENT_EVENT_THUMBNAILS allValues]];
    }else{
        arrayOfMatchedTags = [self filterTagsByDuration];
    }
    
     [self getStatsData:arrayOfMatchedTags];
}

-(void)getSelectedStrengthPatterns:(NSArray*)homeArray :(NSArray*)awayArray{
    for(NSString *strength in homeArray){
        for(NSString *awayStr in awayArray){
            if (![taggedAttsDict objectForKey:@"strength"]) {
                [taggedAttsDict setObject:[NSMutableArray arrayWithObject:[NSString stringWithFormat:@"%@,%@",strength,awayStr]] forKey:@"strength"];
            }else{
                [[taggedAttsDict objectForKey:@"strength"] addObject:[NSString stringWithFormat:@"%@,%@",strength,awayStr]];
            }
        }
        
    }

}

-(NSMutableArray*)filterTagsByDuration{
    NSMutableArray *filteredArr;
    
    for(NSDictionary *obj in [globals.CURRENT_EVENT_THUMBNAILS allValues])
    {
        if ([[obj objectForKey:@"type"]integerValue] == 0 || [[obj objectForKey:@"type"]integerValue] == 100) {
            BOOL doesContainEvent = !([[taggedAttsDict objectForKey:@"events"]count]>0) || [[taggedAttsDict objectForKey:@"events"] containsObject:[obj objectForKey:@"name"]] ;
            BOOL doesContainPlayers =  !([[taggedAttsDict objectForKey:@"players"]count] >0)||[[taggedAttsDict objectForKey:@"players"]firstObjectCommonWithArray:[obj objectForKey:@"player"]]!=nil;
            
            //for hockey
            NSString *tagTime = [NSString stringWithFormat:@"%@",[obj objectForKey:@"time"]];
            BOOL doesContainOFFLines = [[taggedAttsDict objectForKey:@"offline"]count]<1;
            
            if(!doesContainOFFLines)
            {
                if([[taggedAttsDict objectForKey:@"offline"]count]>0)
                {
                    doesContainOFFLines = [self doesBelongShift:@"offline" :@"1" :@"2" :tagTime];
                }
            }
            
            BOOL doesContainDEFLines = [[taggedAttsDict objectForKey:@"defline"]count]<1;
            
            if(!doesContainDEFLines)
            {
                if([[taggedAttsDict objectForKey:@"defline"]count]>0)
                {
                    doesContainDEFLines = [self doesBelongShift:@"defline" :@"5" :@"6" :tagTime];
                }
            }
            
            BOOL doesContainStrength = [[taggedAttsDict objectForKey:@"strength"]count] < 1;
            if (!doesContainStrength) {
                doesContainStrength = [self doesBelongShift:@"strength" :@"9" :@"10" :tagTime];
            }
            

            BOOL doesContainPeriod = [[taggedAttsDict objectForKey:@"period"]count]<1 && [[taggedAttsDict objectForKey:@"half"]count]<1;
            if(!doesContainPeriod)
            {
                if([[taggedAttsDict objectForKey:@"period"]count]>0 || [[taggedAttsDict objectForKey:@"half"]count]>0)
                {
                    if([globals.WHICH_SPORT isEqualToString:@"hockey"])
                    {
                        doesContainPeriod = [self doesBelongShift:@"period" :@"7" :@"8" :tagTime];
                        
                    }else if([globals.WHICH_SPORT isEqualToString:@"soccer"] || [globals.WHICH_SPORT isEqualToString:@"rugby"])
                    {
                        doesContainPeriod = [self doesBelongShift:@"period" :@"17" :@"18" :tagTime];
                    }
                    
                }
            }
            
            BOOL doesContainType = FALSE;
            
            if ([globals.WHICH_SPORT isEqualToString:@"football"]) {
                if ([obj objectForKey:@"period"] && [[obj objectForKey:@"period"] isKindOfClass:[NSArray class]]) {
                    NSArray *temArr = [[NSArray alloc]initWithObjects:[[obj objectForKey:@"period"]objectAtIndex:0], nil];
                    doesContainPeriod = !([[taggedAttsDict objectForKey:@"period"]count] >0 )|| [[taggedAttsDict objectForKey:@"period"]firstObjectCommonWithArray:temArr]!=nil;
                    
                    NSDictionary *jsonExtra ; // we need to turn our extra string into a json dictionary, will be contained in this variable
                    if([[obj objectForKey:@"extra"] length] != 0) // check if there is anything in the extra param
                    {
                        NSData *data=[[obj objectForKey:@"extra"] dataUsingEncoding:NSUTF8StringEncoding]; // convert extra param to data]
                        NSError *err;
                        jsonExtra = [[NSDictionary alloc]initWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:NSUTF8StringEncoding error:&err] ]; //convert data to dictionary
                    }
                    doesContainType = ![[taggedAttsDict objectForKey:@"type"]count]>0 || [[taggedAttsDict objectForKey:@"type"] containsObject:[jsonExtra objectForKey:@"type"]] ;
                    if(doesContainType)
                    {
                        //  ////////NSLog(@"boo");
                    }
                }
                
            }else{
                doesContainType = TRUE;
            }
            
            BOOL doesContainZone = [[taggedAttsDict objectForKey:@"zone"]count]<1;
            if ([globals.WHICH_SPORT isEqualToString:@"soccer"] || [globals.WHICH_SPORT isEqualToString:@"rugby"]) {
                if(!doesContainZone)
                {
                    if([[taggedAttsDict objectForKey:@"zone"]count]>0)
                    {
                        doesContainZone = [self doesBelongShift:@"zone" :@"15" :@"16" :tagTime];
                    }
                }
            }else if ([globals.WHICH_SPORT isEqualToString:@"hockey"]){
                //for hockey
                doesContainZone = ![[taggedAttsDict objectForKey:@"zone"]count]>0 || [[taggedAttsDict objectForKey:@"zone"] containsObject:[obj objectForKey:@"zone"]];
            }else{
                doesContainZone = TRUE;
            }
        
            if(doesContainEvent && doesContainOFFLines && doesContainDEFLines && doesContainStrength && doesContainPeriod && doesContainPlayers && doesContainZone && doesContainType)
            {
                if (!filteredArr) {
                    filteredArr = [NSMutableArray arrayWithObject:obj];
                }else{
                     [filteredArr addObject:obj];
                }
               
            }
        }

        }
     
       return filteredArr;
}

-(BOOL)doesBelongShift:(NSString*)shift :(NSString*)openType :(NSString*)closeType :(NSString*)tagTime{
    
    BOOL doesContainShift;
    //first of all we need to grab the times for type we are filtering
    //we have a temporary array - t - and we will add all the times at which the even type occurs
    NSMutableArray *t = [[NSMutableArray alloc]initWithArray:[globals.DURATION_TYPE_TIMES objectForKey:closeType]];
    
    //if we have server then we can also add the times at which the odd type happens -- this only happens when server is available
    //because thats the only time we don't know the end time of the last tag, so its still open
    //offline duration tags will always be closed because we know the total duration of the game
    if(globals.HAS_MIN)
    {
        [t addObjectsFromArray:[globals.DURATION_TYPE_TIMES objectForKey:openType]];
    }
    
    //sort t by time, makes our binary search faster
    
    NSInteger *sortedIndex = 0;
    NSString *closestTagTime;
    if (t.count > 1) {
        //first do a binary search to find the index that this time would be inserted
        int binSearchIndex =[t indexOfObject:tagTime] ; // binsearch returns -1 if time not found
        binSearchIndex = (int)binSearchIndex <0 ? 0:binSearchIndex; // make sure the binary search index is greater then 0
        
        //we are going to set the index to the returned index -1 because we want the time before this one (tells us which tags were open at this time)
        sortedIndex=(int)binSearchIndex >t.count-1 ? t.count-1 : binSearchIndex-1; //make sure index doesn't go beyond the bounds of the array
        sortedIndex=(int)sortedIndex <0 ? 0:sortedIndex; //make sure index isn't less then 0
        
        closestTagTime = [t objectAtIndex:sortedIndex]; //based on our binary search, we get the closest tag time before ours (floor)
        
        //now take the global dictionary which relates times to which tags happen at those times, and find the dictionary of tags for our closest time
        NSDictionary *timeDictionary = [[NSDictionary alloc]initWithDictionary:[globals.DURATION_TAGS_TIME objectForKey:closestTagTime]];
        
        //our boolean values are set based on whether or not our timedictionary contains whichever line was filtered
        doesContainShift =[[taggedAttsDict objectForKey:shift] containsObject:[timeDictionary objectForKey:closeType]];
        //if there is no even type in the timedictionary, there might be an odd type
        doesContainShift= doesContainShift ? TRUE : [[taggedAttsDict objectForKey:shift] containsObject:[timeDictionary objectForKey:openType]];
        
    }else if(t.count==1){
        closestTagTime = [t objectAtIndex:0];
        NSDictionary *timeDictionary = [[NSDictionary alloc]initWithDictionary:[globals.DURATION_TAGS_TIME objectForKey:closestTagTime]];
        
        doesContainShift =[[taggedAttsDict objectForKey:shift] containsObject:[timeDictionary objectForKey:closeType]];
        doesContainShift= doesContainShift ? TRUE : [[taggedAttsDict objectForKey:shift] containsObject:[timeDictionary objectForKey:openType]];
    }else{
        doesContainShift=FALSE;
    }
    return doesContainShift;
}

-(void)viewWillDisappear:(BOOL)animated{
    [self removeStatsVideoPlayer];
    for(UIButton *button in playerButtonsArr){
        [button removeFromSuperview];
    }
    [playerButtonsArr removeAllObjects];
    [selectedPlayersArr removeAllObjects];
    [playerNumberArr removeAllObjects];
    
    for(UIButton *button in tagNameButtonsArr){
        [button removeFromSuperview];
    }
    [tagNameButtonsArr removeAllObjects];
    [selectedEventsArr removeAllObjects];
    [tagNamesArr removeAllObjects];
    
    [filterButtonsView removeFromSuperview];
    filterButtonsView = nil;
    
}

- (void)removeLiveSpinner
{
    [globals.SPINNERVIEW removeSpinner];
    
}


#pragma mark - Button Callback Methods

- (void)exportButtonPressed: (UIButton*)button
{
    ExportPopoverTableViewController* tableController = [[ExportPopoverTableViewController alloc] initWithStyle:UITableViewStyleGrouped statsDicts:[gameStatsDataDict copy] startTime:startTime endTime:endTime];

    _exportPopover = [[UIPopoverController alloc] initWithContentViewController:tableController];
    
    [_exportPopover presentPopoverFromRect:button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    
}







- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}













@end
