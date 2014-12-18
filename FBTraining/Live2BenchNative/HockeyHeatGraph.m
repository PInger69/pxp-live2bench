//
//  hockeyHeatGraph.m
//  Stats Graph Demo
//
//  Created by Si Te Feng on 2014-06-02.
//  Copyright (c) 2014 Avoca. All rights reserved.
//

#import "HockeyHeatGraph.h"

#import "JPFont.h"

@implementation HockeyHeatGraph

const NSInteger kNoDataLabelTag = 204;
//const NSString *kNoDataLabelText = @"NO DATA AVAILABLE"; already declared


- (id)initWithFrame:(CGRect)frame andSport:(NSString *)sport
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        
        ///////////////////////////////////////////////////
        // Gradient View ///////////////////////////////
        _gradientView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.masksToBounds = YES;
        [_gradientView.layer insertSublayer:_gradientLayer atIndex:0];
        CATransform3D rotate2 = CATransform3DMakeRotation(-M_PI_2, 0, 0, 90);
        _gradientLayer.transform = rotate2;
        _gradientLayer.frame = _gradientView.frame;
        
        //////////////////////////////////////////////////
        //Adding a second layer of transparent rink, only for showing the outlines
        self.backgroundColor = [UIColor clearColor];
        UIImageView* imgView2 = [[UIImageView alloc] initWithFrame:CGRectZero];
        
        if([sport isEqualToString:@"hockey"])
        {
            imgView.image = [UIImage imageNamed:@"hockeyRinkWhite.png"];
            CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI_2);
            imgView.transform = transform;
            _gradientLayer.cornerRadius = 50;
            
            imgView2.image = [UIImage imageNamed:@"hockeyRink.png"];
            CGAffineTransform transform2 = CGAffineTransformMakeRotation(M_PI_2);
            imgView2.transform = transform2;
        }
        else if([sport isEqual:@"soccer"])
        {
            imgView.image = [UIImage imageNamed:@"soccerFieldWhite.png"];
            imgView2.image = [UIImage imageNamed:@"soccerField.png"];
        }
        
        imgView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [self addSubview:imgView];
        
        [self addSubview:_gradientView];
        
        imgView2.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [self addSubview:imgView2];
        
        //No Data Label
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, imgView.frame.size.height/2.0 - 20, frame.size.width, 40)];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        label.font = [UIFont fontWithName:[JPFont defaultThinFont] size:25];
        label.text = @"NO DATA AVAILABLE";
        label.tag = kNoDataLabelTag;
        label.hidden = YES;
        
        [self addSubview:label];
        
        ///////////////////////////////////////////////////////////////
        //OFF/DEF Side Labels
        UILabel* OFFLabel = [[UILabel alloc] init];
        OFFLabel.font = [UIFont fontWithName:[JPFont defaultThinFont] size:20];
        OFFLabel.textAlignment = NSTextAlignmentCenter;
        OFFLabel.text = @"Offence";
        CGAffineTransform rotateCCW= CGAffineTransformMakeRotation(-M_PI_2);
        OFFLabel.transform = rotateCCW;
        OFFLabel.frame = CGRectMake(-30, 25, 30, 140);
        [self addSubview:OFFLabel];
        
        UILabel* DEFLabel = [[UILabel alloc] init];
        DEFLabel.font = [UIFont fontWithName:[JPFont defaultThinFont] size:20];
        DEFLabel.textAlignment = NSTextAlignmentCenter;
        DEFLabel.text = @"Defence";
        CGAffineTransform rotateCW= CGAffineTransformMakeRotation(M_PI_2);
        DEFLabel.transform = rotateCW;
        DEFLabel.frame = CGRectMake(frame.size.width + 5, 25, 30, 140);
        [self addSubview:DEFLabel];
        
        
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [self initWithFrame:frame andSport:@"hockey"];
    return self;
}


- (void)setDurations:(NSArray *)durations
{
    _durations = durations;
    
    UILabel* noDataLabel = (UILabel*)[self viewWithTag:kNoDataLabelTag];

    if([durations count] == 3)
    {
        _gradientLayer.locations = @[@0.2, @0.5, @0.8];
    }
    
    CGFloat totalTime = 0.0f;
    
    for(int i= 0; i<[durations count]; i++)
    {
        totalTime += [durations[i] floatValue];
        
        if(durations[i]==nil || isnan([durations[i] floatValue]))
        {
            noDataLabel.hidden = NO;
        }
        else
        {
            noDataLabel.hidden = YES;
        }
    }
    
    if(totalTime == 0 || isnan(totalTime))
    {
        noDataLabel.hidden = NO;
    }
    else
    {
        noDataLabel.hidden = YES;
    }
    
    CGColorRef color = [UIColor clearColor].CGColor;
    
    NSMutableArray* colors = [NSMutableArray array];
    
    for(int i=0; i<[durations count]; i++)
    {
        CGFloat ratio = [durations[i] floatValue]/totalTime;
    
        color = [UIColor colorWithRed:1 green:0 blue:0 alpha:ratio].CGColor;
        
        [colors addObject:(__bridge id)color];
    
    }
    
    _gradientLayer.colors = colors;
    
}



- (void)reloadData
{
    
}





/*

if(ratio > 0.5)
{
    ratio -= 0.5;
    color = [[UIColor colorWithHue:(360 - ratio/0.5*20)/360  saturation:1 brightness:1 alpha:0.5 + 0.2*(ratio/0.5)] CGColor];
    
}
else if(ratio > 0.3)
{
    ratio -= 0.3;
    color = [[UIColor colorWithHue:(120 - ratio/0.2*120) / 360 saturation:1 brightness:1 alpha:0.5] CGColor];
}
else if(ratio > 0.15)
{
    ratio -= 0.15;
    color = [[UIColor colorWithHue:((60 - ratio/0.15*60) + 120) / 360 saturation:1 brightness:1 alpha:0.5] CGColor];
}
else //ratio <= 0.15
{
    color = [[UIColor colorWithHue:((80 - ratio/0.15*80) + 180) / 360 saturation:1 brightness:1 alpha:0.5] CGColor];
}


*/




@end
