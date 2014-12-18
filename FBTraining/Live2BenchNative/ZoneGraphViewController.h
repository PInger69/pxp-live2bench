//
//  ZoneGraphViewController.h
//  Stats Graph Demo
//
//  Created by dev on 5/29/14.
//  Copyright (c) 2014 Avoca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeatChartView.h"
#import "zoneGraphView.h"
#import "StatsViewController.h"
#import "SharePopoverTableViewController.h"

@class zoneGraphView, HeatChartView, Globals, StatsViewController;
@interface ZoneGraphViewController : UIViewController <JPZoneHeatGraphDataSource, JPZoneVisualizationDataSource, JPZoneGraphDelegate, JPSharePopoverDelegate>
{
    Globals* globals;
    
    CGFloat _lastHeatGraphPosition;
    
    NSMutableArray*       _zoneNameTimeDictArray; //zone, and time
    NSMutableArray*       _periodNameTimeDictArray; //name, and time
    
    NSComparisonResult   (^zonePeriodTimeAcendingComparator)(id, id);
    
    NSInteger             _currentZoneTagCount;
    
    UIPopoverController*  _popover;
}


@property(nonatomic, weak) StatsViewController* statsController;
@property(nonatomic, strong)NSString* sportName;

@property(nonatomic, strong)NSArray *zoneTimes; //In seconds
@property(nonatomic, strong)NSArray *zoneNames; //Both must be set

@property(nonatomic, strong)NSArray *periodTimes;
@property(nonatomic, strong)NSArray *periodNames;

@property(nonatomic, strong)NSArray *allTagInfo;



@property (nonatomic, strong) zoneGraphView* graphView;
@property (nonatomic, strong) HeatChartView* heatView;








- (void)reloadSubviews;



@end






//ZoneNameTimeDictArray/ period array Structure:
//            [
//             {
//                 @"name": @"DEF_3RD";
//                 @"time": [NSNumber numberWithFloat: 2.0];
//             },
//             {
//                 .......
//             }
//
//
//            ]

