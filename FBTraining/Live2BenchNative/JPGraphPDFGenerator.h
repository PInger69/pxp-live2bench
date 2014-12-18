//
//  JPGraphPDFGenerator.h
//  Live2BenchNative
//
//  Created by Si Te Feng on 7/25/14.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "graphDisplayView.h"

@protocol JPZoneVisualizationDataSource;
@class graphDisplayView;
@interface JPGraphPDFGenerator : NSObject



@property (nonatomic, assign) CGFloat totalZoneAverage;

@property (nonatomic, weak) id<JPZoneVisualizationDataSource> dataSource;


- (void)savePDFWithFileName: (NSString*)name;

- (void)deletePDFWithFileName: (NSString*)name;

- (NSString*)pdfExportPath;



@end



//@protocol JPZoneVisualizationDataSource <NSObject>
//@required
//
//- (NSUInteger)numberOfDataPointsInGraphView: (graphDisplayView*)graph;
//
//- (JPZonePoint)graphView: (graphDisplayView*)graph zonePointForPointNumber: (NSUInteger)number;
//- (NSUInteger)numberOfTagsInGraphView: (graphDisplayView*)graph;
//- (NSDictionary*)graphView: (graphDisplayView*)graph tagInfoDictForTagNumber: (NSUInteger)tagNum;
//- (CGFloat)eventDuration;
//
//@optional
//- (CGFloat)timeForPeriodEnded: (NSUInteger)period;
//- (NSInteger)numberOfPeriods;
//- (NSInteger)numberOfTaggedPeriods;
//- (NSString*)nameForAllTaggedPeriod: (NSUInteger)period;
//
//@end