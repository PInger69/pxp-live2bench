//
//  MyClipFilterViewController.m
//  Live2BenchNative
//
//  Created by dev on 7/31/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "MyClipFilterViewController.h"

#import "FilterButtonBlockView.h"
#import "UserColourView.h"
#import "ToggleButton.h"
#import "CoachFilterProcessor.h"


@interface MyClipFilterViewController ()

@end

@implementation MyClipFilterViewController

-(void)componentSetup
{
    
    // Build tabs
    FilterTab * tab1 = [[FilterTab alloc]initWithName:@"My Clip Filtering"];

    
    float headerLine        = 50;
    float scrollBoxHeight   = 200;
    float teamX             = 300;
    float dateX             = 730;
    float footerLine        = headerLine+scrollBoxHeight+6;
    
    
    
    ToggleButton * coachPick = [[ToggleButton alloc]initWithFrame:CGRectMake(300, 290, 200, 40)
                                                                          Name:@"Coach Pick"
                                                                   AccessLable:@"coachpick"];

    coachPick.filterP = [[CoachFilterProcessor alloc]initWithTagKey:@"coachpick"];
    [coachPick setFilterBlock:^NSString *(NSDictionary * data){
        return @"1";
    }];

   
    
    
    
    
    
    UserColourView * userColours =     [[UserColourView alloc]initWithFrame:CGRectMake(10, 290, 200, 40) Name:@"USER" AccessLable:@"colour"];
    
    
    FilterScrollView * oppScrollViewNew = [[FilterScrollView alloc]
                                           initWithFrame:CGRectMake(teamX, headerLine+6, 410, scrollBoxHeight)
                                           Name:@"Teams"
                                           AccessLable:@"teams"];
    oppScrollViewNew.buttonSize = CGSizeMake(220, 25);
    [oppScrollViewNew setFilterBlock:^NSString *(NSDictionary *tagFromDict) {
        return [NSString stringWithFormat:@"%@ VS. %@",tagFromDict[@"homeTeam"],tagFromDict[@"visitTeam"]];
    }];
    oppScrollViewNew.rowCount = 7;
    
    
    
    FilterScrollView *  eventScrollViewNew = [[FilterScrollView alloc]
                                              initWithFrame:CGRectMake(5.0f, headerLine+6, 290.0f, scrollBoxHeight)
                                              Name:@"Event"
                                              AccessLable:@"name"];

    eventScrollViewNew.rowCount = 7;
    
    FilterScrollView *  dateScrollViewNew = [[FilterScrollView alloc]
                                             initWithFrame:CGRectMake(dateX , headerLine+6, 195.0f, scrollBoxHeight)
                                             Name:@"Date"
                                             AccessLable:@"date"];
    
    [dateScrollViewNew setFilterBlock:^NSString *(NSDictionary *tagFromDict) {
        NSArray *tempArr = [[tagFromDict objectForKey:@"event" ] componentsSeparatedByString:@"_"];
        return [NSString stringWithString:[tempArr objectAtIndex:0]];
    }];
    dateScrollViewNew.rowCount = 7;
    
    
    [tab1 addSubview:oppScrollViewNew];
    [tab1 addSubview:eventScrollViewNew];
    [tab1 addSubview:dateScrollViewNew];
    [tab1 addSubview:userColours];
    [tab1 addSubview:coachPick];
    
    
     float listW = 2;
    
    [tab1 drawLine:CGPointMake(0, 100.0f - headerLine)  to:CGPointMake(FILTER_AREA_WIDTH, 100.0f - headerLine)      lineWidth:listW strokeColor:[UIColor whiteColor]];
    [tab1 drawLine:CGPointMake(teamX-5, 50)             to:CGPointMake(teamX-5, footerLine)                         lineWidth:listW strokeColor:[UIColor whiteColor]];
    [tab1 drawLine:CGPointMake(dateX-5, 50)             to:CGPointMake(dateX-5, footerLine)                         lineWidth:listW strokeColor:[UIColor whiteColor]];
    [tab1 drawLine:CGPointMake(0, footerLine)           to:CGPointMake(FILTER_AREA_WIDTH, footerLine)               lineWidth:listW strokeColor:[UIColor whiteColor]];
    
    

    
    [tabManager addTabList:@[tab1]];
    [tab1 linkComponents:@[oppScrollViewNew,userColours,eventScrollViewNew,dateScrollViewNew,coachPick]];
    
    [clearAll setFrame:CGRectMake(dateX+2,          footerLine+70, 100, 40)];
    //[numTagsLabel setFrame:CGRectMake(dateX+2+105,  footerLine+70, 70, 40)];
    
    
    
    // Test
    

}



/**
 *  This is meant to be overriden by the MyClipFilterViewController
 *  The reason is that the data used in the bookmark area has an extra layer of dicts based off event names
 */
-(NSMutableArray *)formatTagsForDisplay:(NSMutableArray *)unformatedTags
{
    NSMutableArray *allBookmarkTags;
    for (NSDictionary *dict in unformatedTags) {
        if (allBookmarkTags) {
            [allBookmarkTags addObjectsFromArray:[dict allValues]];
        }else{
            allBookmarkTags = [[NSMutableArray alloc]initWithArray:[dict allValues]];
        }
    }
    return [allBookmarkTags copy];
}

@end
