//
//  PcpFilterRangeSlider.h
//  Live2BenchNative
//
//  Created by andrei on 2015-08-05.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PxpFilter.h"


@interface PxpFilterRangeSlider : UIControl

@property (nonatomic) Float64 highestValue;
@property (nonatomic) Float64 lowestValue;

@property (nonatomic) UIColor* trackColour;
@property (nonatomic) UIColor* trackHighlightColour;
@property (nonatomic) UIColor* knobColour;
@property (nonatomic) float curvaceousness;
@property (nonatomic) float knobBorderThickness;

-(void)deselectAll;
-(void)redrawLayers;
-(void)setLayerFrames;

-(void) setKnobWithStart:(NSInteger)startTime withEnd:(NSInteger)endTime;

@end

