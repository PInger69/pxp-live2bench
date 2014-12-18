//
//  StatsViewController.h
//  Live2BenchNative
//
//  Created by DEV on 1/7/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BorderButton.h"
#import "StatsCell.h"
#import "Globals.h"
#import "VideoPlayer.h"
#import "CustomTabBar.h"

@class ZoneGraphNavViewController, ZoneGraphViewController, ExportTagsSync;
@interface StatsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate>
{
    UIView*  _zoneBackgroundView;
    ExportTagsSync*  _exportSync;
    
    UIButton*  _exportButton;
    UIPopoverController* _exportPopover;
    
}

@property(nonatomic,strong)Globals *globals;
//stats table view for displaying stats data
@property(nonatomic, strong)UITableView *statsTableView;
//data for the stats table view
@property(nonatomic, strong)NSMutableArray *statsData;
@property(nonatomic, strong)NSMutableArray *arrayOfMatchedTags;
//array of tag names
@property(nonatomic,strong)NSMutableArray *tagNamesArr;
//time interval for the table time line
@property(nonatomic)float timeInterval;
@property(nonatomic)int endTime;
//start time for the table time line
@property(nonatomic)int startTime;
//picker view for selecting the start time for the table time line
@property(nonatomic,strong)UIPickerView *startTimePickerView;
//data available for the start time picker view
@property(nonatomic,strong)NSMutableArray *startTimePikerData;
//picker view for selecting the time interval the table time line
@property(nonatomic,strong)UIPickerView *endTimePickerView;
//data available for the start time picker view
@property(nonatomic,strong)NSMutableArray *endTimePikerData;
//button displays the current start time and time interval for the table time line
@property(nonatomic,strong)UIButton *timeLineInfoButton;
//pop over controller
@property(nonatomic,strong)UIPopoverController *popoverController;
//instance of video player
@property(nonatomic,strong)VideoPlayer *videoPlayer;
//timer for looping tags
@property(nonatomic,strong)NSTimer *loopTimerStatsView;
//uiview for videoplayer view
@property(nonatomic,strong)UIView *viewForVideo;
//array of player buttons
@property(nonatomic,strong)NSMutableArray *playerButtonsArr;
//array of players been selected
@property(nonatomic,strong)NSMutableArray *selectedPlayersArr;
//array of events been selected
@property(nonatomic,strong)NSMutableArray *selectedEventsArr;
//array of player number which have been tagged in the event
@property(nonatomic,strong)NSMutableArray *playerNumberArr;
//scrolling view for player buttons
@property(nonatomic,strong)UIScrollView *playerButtonsScrollView;
//scrolling view for tag name buttons
@property(nonatomic,strong)UIScrollView *tagNameButtonsScrollView;
//array of tag name buttons
@property(nonatomic,strong)NSMutableArray *tagNameButtonsArr;
//used for highligting the grid cell when view tag belongs to it
@property(nonatomic,strong)BorderButton *gridCellButtonSelected;
//attributes for tab bar item when it is unselected
@property(nonatomic,strong)NSDictionary *tabAttributes;
//attributes for tab bar item when it is selected
@property(nonatomic,strong)NSDictionary *tabSelectAttributes;
//tab for game stats
@property(nonatomic,strong)UIBarButtonItem *gameStatsBarButton;
//tab for report stats
@property(nonatomic,strong)UIBarButtonItem *playerStatsBarButton;
//tool bar for bar button items
@property(nonatomic,strong)UIToolbar *statsToolBar;
@property(nonatomic,strong)UIView *tabContentView;
//view below table view used for displaying the total tag numbers
@property(nonatomic,strong)UIView *totalNumberView;
@property(nonatomic,strong)NSMutableArray *arrayOfEventLabels;
@property(nonatomic,strong)NSMutableArray *arrayOfTotalNumLabels;
@property(nonatomic,strong)CustomButton *outputReportButton;
//array of tag names (tags have player tagged)
@property(nonatomic,strong)NSMutableArray *tagsWithPlayers;
//dictionary to game stats tab
@property(nonatomic,strong)NSMutableDictionary *gameStatsDataDict;
//dictionary for player stats tab
@property(nonatomic,strong)NSMutableDictionary *playerStatsDataDict;
//dictionary recording line and period shifts
@property(nonatomic,strong)NSMutableDictionary *onIceTimeDurations;
//array of period buttons
@property(nonatomic,strong)NSMutableArray *periodButtonsArr;
////array of line buttons
//@property(nonatomic,strong)NSMutableArray *lineButtonsArr;
////strength button
//@property(nonatomic,strong)CustomButton *strengthButton;
//dictionary of all selected filter atrributes
@property(nonatomic,strong)NSMutableDictionary *taggedAttsDict;
//view for filter buttons,ie:period/half,lines,strength buttons
@property(nonatomic,strong)UIView *filterButtonsView;
//a line divides player buttons and filter buttons
@property(nonatomic,strong)UIImageView *dividerView;
//dictionary for line shift tags
@property(nonatomic,strong)NSMutableDictionary *timeOnIceDataDict;

//Zone Graph
@property(nonatomic, strong) ZoneGraphViewController* zoneController;

@property(nonatomic, strong) ZoneGraphNavViewController* zoneNavController;




- (void)dismissZoneGraph;









@end


