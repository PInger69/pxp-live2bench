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
    if (startPoint == [userInfo[@"startTime"] intValue] && endPoint == [userInfo[@"endTime"] intValue]){
        return;
    }
    startPoint = [userInfo[@"startTime"] intValue];
    endPoint =  [userInfo[@"endTime"] intValue];
    
    if ( endPoint != 0 && startPoint != endPoint){
        combo = [NSPredicate predicateWithFormat:@"%K >= %d AND %K <= %d ",_sortByPropertyKey, startPoint, _sortByPropertyKey, endPoint+1];
        [_parentFilter refresh];
    } else {
        combo = nil;
    }
}

- (void)initPxpFilterRangeSlider{
    startPoint = 0;
    endPoint = -1;  // endPoint is initially set to -1 to indicate the initial value
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timeUpdate:) name:NOTIF_FILTER_SLIDER_CHANGE object:nil];
//       self.backgroundColor = [UIColor clearColor];
//    self.layer.borderWidth = .5;
//    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    self.layer.cornerRadius = 5;
//    self.layer.masksToBounds = YES;
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
    self.rangeSlider = [[PxpFilterRangeSlider alloc]initWithFrame:CGRectMake(30, self.frame.size.height/3, self.frame.size.width-60, self.frame.size.height/2)];
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
