//
//  hockeyHeatGraph.h
//  Stats Graph Demo
//
//  Created by Si Te Feng on 2014-06-02.
//  Copyright (c) 2014 Avoca. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HockeyHeatGraph : UIView
{
    CAGradientLayer* _gradientLayer;
    UIView*          _gradientView;
}


@property (nonatomic, strong) NSArray* durations; //oz,nz,dz

- (id)initWithFrame:(CGRect)frame andSport: (NSString*)sport;

- (void)reloadData;

@end
