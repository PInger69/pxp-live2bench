//
//  PieChartView.m
//  Stats Graph Demo
//
//  Created by dev on 5/29/14.
//  Copyright (c) 2014 Avoca. All rights reserved.
//

#import "HeatChartView.h"
#import "JPStyle.h"
#import "JPFont.h"

#import "HockeyHeatGraph.h"

const NSUInteger kButtonTag = 100;

@interface HeatChartView()
{
    
}

@property (nonatomic, assign, readwrite) NSUInteger selectedMode;

@end


@implementation HeatChartView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [JPStyle colorWithHex:@"FFD0AB" alpha:1];
        
        self.selectedMode = 0;
        
        //Heat Graph
        self.heatGraph = [[HockeyHeatGraph alloc] initWithFrame: CGRectMake(550, 15, 350, 175) andSport:@"soccer"];
        [self addSubview:self.heatGraph];
        
    
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 400, 40)];
        titleLabel.font = [UIFont fontWithName:[JPFont defaultThinFont] size:30];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.text = @"Duration In Zones";
        
        [self addSubview:titleLabel];
        
        

        
        //(Button is initiated when period info is available)
        
        
        
    }
    return self;
}




- (void)periodButtonPressed: (UIButton*)button
{
    
    self.selectedMode = button.tag - kButtonTag;
    
    [self reloadData];
    
}




- (void)setDataSource:(id<JPZoneHeatGraphDataSource>)dataSource
{
    _dataSource = dataSource;
    
}


- (void)reloadData
{
    if(self.dataSource == nil)
    {
        return;
    }
    
    //Adding Period Selection Buttons
    NSInteger numberOfPeriods = [self.dataSource numberOfPeriods];
    _numPeriodButtons = numberOfPeriods;
    
    [self reloadPeriodFilterButtons];
    
    //Durations for selected Periods
    
    NSMutableArray* durationsForSelectedPeriod = [NSMutableArray array];
    
    for(int zone=0; zone<3; zone++)
    {
        CGFloat duration = 0;
        
        if(self.selectedMode != 0)
        {
            duration = [self.dataSource durationForZone:zone period:self.selectedMode];
        }
        else //Entire Game
        {
            CGFloat accumDuration = 0;
            
            if(numberOfPeriods != 0)
            {
                for(int i=1; i<=numberOfPeriods; i++)
                {
                    accumDuration += [self.dataSource durationForZone:zone period:i];
                }
            }
            
            duration = accumDuration/3.0f;
            
        }
        
        //Add to Duration for each zone for the selected period mode. (3 times)
        [durationsForSelectedPeriod addObject:[NSNumber numberWithFloat:duration]];
        
    }
    
    self.heatGraph.durations = durationsForSelectedPeriod;
}


- (void)reloadPeriodFilterButtons
{
    for(int i=0; i<=_numPeriodButtons; i++)
    {
        UIButton* periodButton = (UIButton*)[self viewWithTag:i+kButtonTag];
        
        if(!periodButton)
        {
            CGRect buttonRect = CGRectZero;
            
            if(i % 2 == 0) // 1,3,5...
            {
                buttonRect = CGRectMake(40, 60 + 22 *i, 200, 35);
            }
            else // 2,4,6...
            {
                buttonRect = CGRectMake(280, 38 + 22 *i, 200, 35);
            }
            
            periodButton = [[UIButton alloc] initWithFrame:buttonRect];
            periodButton.layer.cornerRadius = 10;
            periodButton.clipsToBounds = YES;
            periodButton.titleLabel.font = [UIFont fontWithName:[JPFont defaultThinFont] size:20];
            [periodButton setTintColor:[UIColor whiteColor]];
            [periodButton setBackgroundImage:[UIImage imageWithColor:[UIColor lightGrayColor]] forState:UIControlStateDisabled];
            periodButton.tag = i + kButtonTag;
            [periodButton addTarget:self action:@selector(periodButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:periodButton];
        }
        
        if(i==self.selectedMode)
        {
            [periodButton setBackgroundImage:[UIImage imageWithColor:[UIColor orangeColor]] forState:UIControlStateNormal];
        }
        else
        {
            [periodButton setBackgroundImage:[UIImage imageWithColor:[JPStyle colorWithName:@"darkRed"]] forState:UIControlStateNormal];
        }
        
        if(i==0)
        {
            [periodButton setTitle:@"Entire Game" forState:UIControlStateNormal];
        }
        else
        {
            [periodButton setTitle:[self.dataSource nameForPeriod:i] forState:UIControlStateNormal];
        }
        
        
    }

}






@end
