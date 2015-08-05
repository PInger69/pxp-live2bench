//
//  PxpFilterRangeSliderView.h
//  Live2BenchNative
//
//  Created by andrei on 2015-08-05.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpFilter.h"
#import "PxpFilterRangeSlider.h"
#import "PxpFilterTabController.h"
#import <UIKit/UIKit.h>

@interface PxpFilterRangeSliderView : UIView<PxpFilterModuleProtocol>

@property (nonatomic,strong) PxpFilterRangeSlider *rangeSlider;

@property (nonatomic,strong) NSString           * sortByPropertyKey;

// Protocol
@property (nonatomic,weak) PxpFilter * parentFilter;


//Debug
@property (nonatomic,weak) PxpFilterTabController *parentTab;

-(void)setEndTime:(NSInteger)endTime;

// Protocol
-(void)filterTags:(NSMutableArray *)tagsToFilter;

-(void)reset;


@end
