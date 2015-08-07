//
//  PxpFilterRangeSliderView.m
//  Live2BenchNative
//
//  Created by Colin on 2015-08-05.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpFilterRangeSliderView.h"

@implementation PxpFilterRangeSliderView
{
    NSInteger endPoint;
    NSInteger startPoint;
    NSInteger highestValue;
    NSPredicate * combo;
}

- (void)timeUpdate:(NSNotification*)note {  //observe the notification to update the start time and end time of the slider while refreshing the predicate and parentFilter.
    if(note.object != self.rangeSlider)return;
    
    NSDictionary *userInfo = note.userInfo;
    startPoint = [userInfo[@"startTime"] intValue];
    endPoint =  [userInfo[@"endTime"] intValue];
    
    combo = [NSPredicate predicateWithFormat:@"%K <= %d AND %K >= %d", _sortByPropertyKey, endPoint,_sortByPropertyKey, startPoint];
    [_parentFilter refresh];
}

- (void)initPxpFilterRangeSlider{
    startPoint = 0;
    endPoint = -1;  // endPoint is initially set to -1 to indicate the initial value
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timeUpdate:) name:NOTIF_FILTER_SLIDER_CHANGE object:nil];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initPxpFilterRangeSlider];
    }
    return self;
}

-(void)encodeWithCoder:(nonnull NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initPxpFilterRangeSlider];
    }
    return self;
}

-(void)show{  //initialize a PxpFilterRangeSlider with the start point and end point stored by the view
    self.rangeSlider = [[PxpFilterRangeSlider alloc]initWithFrame:CGRectMake(0, self.frame.size.height/4, self.frame.size.width, self.frame.size.height/2)];
    [self.rangeSlider setHighestValue:highestValue];
    if(startPoint > endPoint) endPoint = startPoint; //making sure endPoint is greater or equal to startPoint
    [self.rangeSlider setKnobWithStart:startPoint withEnd:endPoint];
    [self addSubview:self.rangeSlider];
    
}

-(void)hide{  //delete the slider
    [self.rangeSlider removeFromSuperview];
    self.rangeSlider = nil;
}


-(void)setEndTime:(NSInteger)endTime{   //set the maximum time of the slider
    if(self.rangeSlider)
        [self.rangeSlider setHighestValue:endTime];
    else
        highestValue = endTime;
    if(endPoint < 0)endPoint = highestValue; //If the endpoint hasn't been initialized initialize now
}

//protocol

-(void)reset{          //reset the slider
    [self.rangeSlider deselectAll];
}

-(void)filterTags:(NSMutableArray*)tagsToFilter{ 
    if(combo)
        [tagsToFilter filterUsingPredicate:combo];
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
