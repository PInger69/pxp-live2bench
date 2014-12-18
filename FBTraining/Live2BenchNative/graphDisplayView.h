//
//  GraphScrollView.h
//  Stats Graph Demo
//
//  Created by dev on 5/29/14.
//  Copyright (c) 2014 Avoca. All rights reserved.
//

#import <UIKit/UIKit.h>


struct JPZonePoint{
    CGFloat minute;
    float zone; //top 100 to 0 at bottom
};
typedef struct JPZonePoint JPZonePoint;

JPZonePoint JPZonePointMake(CGFloat minute, float zone);


//Protocol
@class graphDisplayView;

@protocol JPZoneVisualizationDataSource <NSObject>
@required

- (NSUInteger)numberOfDataPointsInGraphView: (graphDisplayView*)graph;

- (JPZonePoint)graphView: (graphDisplayView*)graph zonePointForPointNumber: (NSUInteger)number;
- (NSUInteger)numberOfTagsInGraphView: (graphDisplayView*)graph;
- (NSDictionary*)graphView: (graphDisplayView*)graph tagInfoDictForTagNumber: (NSUInteger)tagNum;
- (CGFloat)eventDuration;

@optional
- (CGFloat)timeForPeriodEnded: (NSUInteger)period;
- (NSInteger)numberOfPeriods;
- (NSInteger)numberOfTaggedPeriods;
- (NSString*)nameForAllTaggedPeriod: (NSUInteger)period;

@end


@protocol JPZoneGraphDelegate <NSObject>

@optional

- (void)tagTapped: (UIView*)view;

@end


@protocol JPZoneGraphDataSource;
@interface graphDisplayView : UIView
{
    CGRect   _frame;
    CGFloat graphHeight, dashedLineHeight;
    
    UIView*  _tagIndicatorBackground;
    
    CGMutablePathRef  _periodDashedLinePath;
    NSMutableArray*   _dashedLineViews;
    
    CGFloat     _currentEventDuration;
    CGFloat     _currentNumberOfTags;
}



@property (nonatomic, assign) CGFloat horizontalIncrement;


@property (nonatomic, weak) id<JPZoneVisualizationDataSource> dataSource;
@property (nonatomic, weak) id<JPZoneGraphDelegate> delegate;


@property (nonatomic, assign, readonly) CGFloat totalZoneAverage;
@property (nonatomic, assign, readonly) CGFloat OZoneYPosition;
@property (nonatomic, assign, readonly) CGFloat DZoneYPosition;


- (void)reloadData;

- (void)reloadDataCachedForScrolling;

@end





