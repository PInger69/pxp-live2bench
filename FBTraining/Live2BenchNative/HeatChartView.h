//
//  PieChartView.h
//  Stats Graph Demo
//
//  Created by dev on 5/29/14.
//  Copyright (c) 2014 Avoca. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol JPZoneHeatGraphDataSource;

@class HockeyHeatGraph;
@interface HeatChartView : UIView
{
    NSInteger   _numPeriodButtons;
}






@property (nonatomic, strong) HockeyHeatGraph* heatGraph;

@property (nonatomic, strong) id<JPZoneHeatGraphDataSource> dataSource;


@property (nonatomic, assign, readonly) NSUInteger selectedMode; //0-all, 1-period, 2-Period2...

- (void)reloadData;


@end


@protocol JPZoneHeatGraphDataSource <NSObject>

//0- offence, 1-Neutral, 2-Defence
- (CGFloat)durationForZone: (NSUInteger)zone period: (NSUInteger)period;


- (NSInteger)numberOfPeriods;
- (NSString*)nameForPeriod: (NSUInteger)period;





@end



