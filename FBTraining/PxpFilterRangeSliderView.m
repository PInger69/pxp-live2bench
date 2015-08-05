//
//  PxpFilterRangeSliderView.m
//  Live2BenchNative
//
//  Created by andrei on 2015-08-05.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpFilterRangeSliderView.h"

@implementation PxpFilterRangeSliderView
{
    int endPoint;
    int startPoint;
    NSPredicate * combo;
}

- (void)timeUpdate:(NSNotification*)note {
    NSDictionary *userInfo = note.userInfo;
    startPoint = [userInfo[@"startTime"] intValue];
    endPoint =  [userInfo[@"endTime"] intValue];
    
    //NSLog(@"%d",startPoint);
    //NSLog(@"%d",endPoint);
    combo = [NSPredicate predicateWithFormat:@"%K <= %d AND %K >= %d", _sortByPropertyKey, endPoint,_sortByPropertyKey, startPoint];
    [_parentFilter refresh];
}

- (void)initPxpFilterRangeSlider{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timeUpdate:) name:NOTIF_FILTER_SLIDER_CHANGE object:nil];
    
    self.rangeSlider = [[PxpFilterRangeSlider alloc]initWithFrame:CGRectMake(0, self.frame.size.height/4, self.frame.size.width, self.frame.size.height/2)];
    [self addSubview:self.rangeSlider];
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


-(void)setEndTime:(NSInteger)endTime{
    [self.rangeSlider setHighestValue:endTime];
}

//protocol

-(void)reset{
    [self.rangeSlider deselectAll];
}

-(void)filterTags:(NSMutableArray*)tagsToFilter{
    if(combo)
        [tagsToFilter filterUsingPredicate:combo];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
