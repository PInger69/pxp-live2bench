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
    NSInteger _endPoint;
    NSInteger _startPoint;
    NSInteger _highestValue;
    NSPredicate *__nullable _combo;
}

@synthesize modified = _modified;

- (void)timeUpdate:(NSNotification*)note {  //observe the notification to update the start time and end time of the slider while refreshing the predicate and parentFilter.
    if(note.object != self.rangeSlider)return;
    
    NSDictionary *userInfo = note.userInfo;
    if (_startPoint == [userInfo[@"startTime"] intValue] && _endPoint == [userInfo[@"endTime"] intValue]){
        return;
    }
    _startPoint = [userInfo[@"startTime"] intValue];
    _endPoint =  [userInfo[@"endTime"] intValue];
    
    if ( _endPoint != 0 && _startPoint != _endPoint){
        _combo = [NSPredicate predicateWithFormat:@"%K >= %d AND %K <= %d ",_sortByPropertyKey, _startPoint, _sortByPropertyKey, _endPoint+1];
        [_parentFilter refresh];
    } else {
        _combo = nil;
    }
}

- (void)initPxpFilterRangeSlider{
    _startPoint = 0;
    _endPoint = -1;  // endPoint is initially set to -1 to indicate the initial value
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
    [self.rangeSlider setHighestValue:_highestValue];
    if(_startPoint > _endPoint) _endPoint = _startPoint; //making sure endPoint is greater or equal to startPoint
    [self.rangeSlider setKnobWithStart:_startPoint withEnd:_endPoint];
    [self addSubview:self.rangeSlider];
    
    
}

-(void)hide{  //delete the slider
    [self.rangeSlider removeFromSuperview];
    self.rangeSlider = nil;
}


-(void)setEndTime:(NSInteger)endTime{   //set the maximum time of the slider
    if(self.rangeSlider){
        [self.rangeSlider setHighestValue:endTime];
    }
    
        _highestValue = endTime;
    if(_endPoint < 0)_endPoint = _highestValue; //If the endpoint hasn't been initialized initialize now
}

//protocol

-(void)reset{          //reset the slider
    [self.rangeSlider deselectAll];
}

-(void)filterTags:(NSMutableArray*)tagsToFilter{ 
    if(_combo && !(_endPoint == _highestValue && _startPoint == 0)) {
        [tagsToFilter filterUsingPredicate:_combo];
    }
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
