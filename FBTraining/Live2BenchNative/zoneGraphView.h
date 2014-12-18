//
//  zoneGraphView.h
//  Stats Graph Demo
//
//  Created by dev on 5/29/14.
//  Copyright (c) 2014 Avoca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "graphDisplayView.h"

@protocol JPZoneVisualizationDataSource, graphDisplayView;
@class HeatChartView, DashedLineView;
@interface zoneGraphView : UIView 
{
    CGPoint   _origin, _yMax, _xMax, _yMaxGraph;
    CGFloat   graphHeight;
    
    UIScrollView* _graphScrollView;

    CGFloat   _totalAvgYPosition;
    UIButton* _avgIndicator;
    
    DashedLineView*  _dashedLine;
    
    UILabel* _noGraphInfoLabel;
    
    CGFloat  _currentHorizontalIncrement;
    CGFloat  _pastHorizIncrBeforePinch;
    CGFloat  _currentEventDuration;
    
    CGFloat  _currentPinchLocInScrollView; //Touch location based on the frame of the scrollview as supposed to default contentframe
    CGFloat  _currentPinchLocInDisplayView;
    
    CGFloat  _currentGraphContentWidth;
}



@property (nonatomic, assign) NSInteger dataPoints;

@property (nonatomic, strong) id<JPZoneVisualizationDataSource> dataSource;
@property (nonatomic, weak)   id<JPZoneGraphDelegate>           delegate;


@property (nonatomic, strong) graphDisplayView* displayView;




- (void)reloadData;



@end




