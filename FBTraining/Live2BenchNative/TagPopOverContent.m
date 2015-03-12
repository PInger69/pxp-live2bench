//
//  TagPopOverContent.m
//  Live2BenchNative
//
//  Created by dev on 8/19/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "TagPopOverContent.h"

typedef enum : NSUInteger {
    Normal,
    Bold
} TextStyle;



@implementation TagPopOverContent
{
    NSDictionary                * NormalAttrs;
    NSDictionary                * BoldAttrs;
    NSMutableAttributedString   * contentText;
}

- (id)initWithData:(NSDictionary *)data frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor        = [UIColor whiteColor];
        UITextView *tagDetailsView  = [[UITextView alloc]initWithFrame:CGRectMake(10, 5,frame.size.width, frame.size.height)];
        NSArray *tempArr            = [[data objectForKey:@"event" ] componentsSeparatedByString:@"_"];
        NSString *eventDate         =  [NSString stringWithString:[tempArr objectAtIndex:0] ];
        NSArray *tempTime           = [[NSString stringWithFormat:@"%@",[tempArr objectAtIndex:1]]componentsSeparatedByString:@"-"] ;
        NSString *eventTime         = [NSString stringWithFormat:@"%@ : %@ : %@",[tempTime objectAtIndex:0],[tempTime objectAtIndex:1],[tempTime objectAtIndex:2]];
        
        NSDictionary *teamInfo;// = [[allEvents objectForKey:[data objectForKey:@"event"]] copy];
        NSString *homeTeam;
        NSString *visitTeam;
        NSString *leagueName;
        if (teamInfo){
            homeTeam = [teamInfo objectForKey:@"homeTeam"];
            visitTeam = [teamInfo objectForKey:@"visitTeam"];
            leagueName = [teamInfo objectForKey:@"league"];
        } else {
            homeTeam = [data objectForKey:@"homeTeam"];
            visitTeam = [data objectForKey:@"visitTeam"];
            leagueName = @"";
        }
        
        [tagDetailsView setText:[NSString stringWithFormat:@"Event Date: %@ \nEvent Time: %@ \nHome Team: %@ \nVisit Team: %@ \nLeague: %@\nTag Name: %@ \nTag Time: %@",eventDate,eventTime,homeTeam,visitTeam,leagueName,[data objectForKey:@"name"],           [data objectForKey:@"displaytime"]]];
        [tagDetailsView setFont:[UIFont boldSystemFontOfSize:18.f]];
        [tagDetailsView setUserInteractionEnabled:FALSE];
        [self addSubview:tagDetailsView];

        
        // Create the attributes
        
        const CGFloat fontSize      = 18.f;
        UIFont *boldFont            = [UIFont boldSystemFontOfSize:fontSize];
        UIFont *regularFont         = [UIFont systemFontOfSize:fontSize];
        UIColor *foregroundColor    = [UIColor blackColor];
        
        BoldAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                                    boldFont, NSFontAttributeName,
                                    foregroundColor, NSForegroundColorAttributeName, nil];
        
        NormalAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                                  regularFont, NSFontAttributeName,
                                  nil];
        
       
        contentText = [[NSMutableAttributedString alloc]init];
        // Create the attributed string (text + attributes)

        [self addText: @"Event Date:\t"     style:Bold];          [self addText: eventDate style:Normal];
        [self addText: @"\nEvent Time:\t"   style:Bold];          [self addText: eventTime style:Normal];
        [self addText: @"\nHome Team:\t"    style:Bold];          [self addText: homeTeam style:Normal];
        [self addText: @"\nVisit Team:\t"   style:Bold];          [self addText: visitTeam style:Normal];
        if(![leagueName isEqualToString:@""]){
            [self addText: @"\nLeague:\t"       style:Bold];          [self addText: leagueName style:Normal];
        }
        [self addText: @"\nTag Name:\t"     style:Bold];          [self addText: [data objectForKey:@"name"] style:Normal];
        [self addText: @"\nTag Time:\t\t"     style:Bold];          [self addText: [data objectForKey:@"displaytime"] style:Normal];
        
        
        
        
        [tagDetailsView setAttributedText:contentText];
    }
    
    return self;
}

-(void)addText:(NSString*)txt style:(TextStyle)tStyle
{
    if (!tStyle) tStyle = Normal;
    NSMutableAttributedString *concatText;
    switch (tStyle) {
        case Normal:
            concatText = [[NSMutableAttributedString alloc] initWithString:txt attributes:NormalAttrs];
            break;
            
        case Bold:
            concatText = [[NSMutableAttributedString alloc] initWithString:txt attributes:BoldAttrs];
            break;

    }
    [contentText insertAttributedString:concatText atIndex:contentText.length];
}

@end
