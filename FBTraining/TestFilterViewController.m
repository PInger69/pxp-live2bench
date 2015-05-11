//
//  FBTFilterViewController.m
//  Live2BenchNative
//
//  Created by dev on 7/31/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "UserColourView.h"
#import "FilterButtonBlockView.h"
#import "FilterProcessorFBTforPlayers.h"
#import "TestFilterViewController.h"

#define LINE_WIDTH 2.0f

@interface TestFilterViewController ()

@end

@implementation TestFilterViewController
{
    
}

static NSMutableSet * shareFilterPlayer;
static NSMutableSet * shareFilterPeriod;
static NSMutableSet * shareFilterSubtag;
static NSMutableSet * shareFilterOffence;
static NSMutableSet * shareFilterDefence;
static NSMutableSet * shareFilterUser;
static TestFilterViewController *commonFilter;

- (id)initWithTagArray: (NSMutableArray *)tagArray
{
    self = [super initWithTagArray:tagArray];
    
    if (self) {
        // Custom initialization
        

    }
    return self;
}

+(TestFilterViewController *) commonFilter{
    if (! commonFilter) {
        commonFilter = [[TestFilterViewController alloc] initWithTagArray:[NSMutableArray array]];
        return commonFilter;
    }
    
    return commonFilter;
}

-(void)componentSetup
{
    
    if (self.rangeSlider) {
        return;
    }
    // This is to make the each instance of this filter share the filtering
    if (!shareFilterPlayer) {
        shareFilterPlayer     =  [[NSMutableSet alloc]init];
        shareFilterPeriod     =  [[NSMutableSet alloc]init];
        shareFilterSubtag     =  [[NSMutableSet alloc]init];
        shareFilterOffence    =  [[NSMutableSet alloc]init];
        shareFilterDefence    =  [[NSMutableSet alloc]init];
        shareFilterUser       =  [[NSMutableSet alloc]init];
    }
    
    
    float headerLine        = 50;
    float footerLine        = 290;
    
    // Build tabs
    FilterTab * tab1 = [[FilterTab alloc]initWithName:NSLocalizedString(@"Filter", nil)];
    // This floats above all tabs... same with the tag count
    clearAll.frame      = CGRectMake(800, 55, 100, 30);
    numTagsLabel.frame  = CGRectMake(800, 300, 100, 30);
    
    
    //------------------------------------------
    UserColourView * userColours    = [[UserColourView alloc]initWithFrame:CGRectMake(700, footerLine, 200, 40) Name:NSLocalizedString(@"USER", nil) AccessLable:@"colour"];
    userColours.selectedTags     = shareFilterUser;
    //------------------------------------------
//    FilterButtonBlockView * off = [[FilterButtonBlockView alloc]initWithFrame:CGRectMake(55, footerLine-20, 290, 60)
//                                                                         Name:@"OFF."
//                                                                  AccessLable:@"offense"];
//    
//    off.label.frame     = CGRectMake(-45, 0, 45, 30);
//    off.buttonSize      = CGSizeMake(30, 60);
//    off.buttonMargin    = CGSizeMake(6, 0);
//    [off setFilterBlock:^NSString *(NSDictionary *tagFromDict) {
//        if (tagFromDict[@"offense"]) {
//            return [NSString stringWithFormat:@"%@",tagFromDict[@"group"]];
//        } else {
//            return @"";
//        }
//        
//    }];
//    off.groupLength      = 8;
//    off.selectedTags     = shareFilterOffence;
    
    //------------------------------------------
//    FilterButtonBlockView * def = [[FilterButtonBlockView alloc]initWithFrame:CGRectMake(400, footerLine-20, 290, 60)
//                                                                         Name:@"DEF."
//                                                                  AccessLable:@"defense"];
//    def.label.frame     = CGRectMake(-45, 0, 45, 30);
//    def.buttonSize      = CGSizeMake(30, 60);
//    def.buttonMargin    = CGSizeMake(6, 0);
//    
//    [def setFilterBlock:^NSString *(NSDictionary *tagFromDict) {
//        if (tagFromDict[@"defense"]) {
//            return [NSString stringWithFormat:@"%@",tagFromDict[@"group"]];
//        } else {
//            return @"";
//        }
//        
//    }];
//    def.groupLength     = 8;
//    
//    def.selectedTags     = shareFilterDefence;
//    
//    
    //------------------------------------------
    /*FilterScrollView *  eventScrollViewNew = [[FilterScrollView alloc]
     initWithFrame:CGRectMake(5.0f, headerLine+7, 450.0f, 206.0f)
     Name:@"Event"
     AccessLable:@"name"];
     
     eventScrollViewNew.rowCount         = 7;
     
     */
    //------------------------------------------
    
    FilterScrollView *  playerScrollViewNew = [[FilterScrollView alloc]
                                               initWithFrame:CGRectMake(605, headerLine+7, 320.0f, 206.0f)
                                               Name:NSLocalizedString(@"Players", nil)
                                               AccessLable:@"player"];
    
    playerScrollViewNew.rowCount         = 7;
    playerScrollViewNew.sortType         = FilterScrollSortNumarical;
    playerScrollViewNew.filterP          = [[FilterProcessorFBTforPlayers alloc]initWithTagKey:nil];
    
    //------------------------------------------
    
    
    
    
    
    // components
    //[tab1 addSubview:off];
    //[tab1 addSubview:def];
    //[tab1 addSubview:eventScrollViewNew];
    [tab1 addSubview:playerScrollViewNew];
    [tab1 addSubview:userColours];
    
    // just ui
    //[tab1 addSubview:[self makeDivider:CGRectMake(0, 100.0f - headerLine, FILTER_AREA_WIDTH , LINE_WIDTH)]];
    //[tab1 addSubview:[self makeDivider:CGRectMake(FILTER_AREA_WIDTH/2,50 , LINE_WIDTH , 206)]];
    //[tab1 addSubview:[self makeDivider:CGRectMake(0, footerLine-36, FILTER_AREA_WIDTH , LINE_WIDTH)]];
    
    [tabManager addTabList:@[tab1]];
    //[tab1  linkComponents:@[eventScrollViewNew,playerScrollViewNew,userColours,off,def]];
    
    
    
    
    //------------------------------------------
    FilterScrollView *  subTagScrollViewNew = [[FilterScrollView alloc]
                                               initWithFrame:CGRectMake(5.0f, headerLine+7, 292.0f, 206.0f)
                                               Name:NSLocalizedString(@"Sub Tag", nil)
                                               AccessLable:@"name"];
    
    subTagScrollViewNew.rowCount         = 7;
    subTagScrollViewNew.selectedTags     = shareFilterSubtag;
    //[subTagScrollViewNew populate: self.rawTagArray];
    //------------------------------------------
    FilterScrollView *  periodScrollViewNew = [[FilterScrollView alloc]
                                               initWithFrame:CGRectMake(300+5.0f, headerLine+7, 290.0f, 206.0f)
                                               Name:NSLocalizedString(@"Period", nil) 
                                               AccessLable:@"period"];
    
    periodScrollViewNew.rowCount         = 7;
    periodScrollViewNew.selectedTags     = shareFilterPeriod;
    
    
    //------------------------------------------
    
    /*FilterScrollView *  playerScrollViewNew = [[FilterScrollView alloc]
     initWithFrame:CGRectMake(600+8.0f, headerLine+7,
     300.0f, 206.0f)
     Name:@"Players"
     AccessLable:@"player"];
     
     playerScrollViewNew.rowCount         = 7;
     playerScrollViewNew.sortType         = FilterScrollSortNumarical;
     playerScrollViewNew.filterP          = [[FilterProcessorFBTforPlayers alloc]initWithTagKey:nil];
     playerScrollViewNew.selectedTags     = shareFilterPlayer;*/
    //------------------------------------------
    
    
    self.rangeSlider = [[RangeSlider alloc]initWithFrame:CGRectMake(50, 300, 250, 30)];
    UILabel *rangeSliderLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 265, 250, 30)];
    [rangeSliderLabel setText: NSLocalizedString(@"Time", nil)];
    [rangeSliderLabel setFont:[UIFont systemFontOfSize:18]];
    [rangeSliderLabel setTextColor: [UIColor whiteColor]];
    [rangeSliderLabel setTextAlignment:NSTextAlignmentCenter];
    [tab1 addSubview: rangeSliderLabel];
   
    
    // components
    //[tab1 addSubview:off];
    //[tab1 addSubview:def];
    [tab1 addSubview:subTagScrollViewNew];
    [tab1 addSubview:periodScrollViewNew];
    [tab1 addSubview:playerScrollViewNew];
    [tab1 addSubview:userColours];
    [tab1 addSubview:self.rangeSlider];
    
    // just ui
    
    float listW = 2;
    
    [tab1 drawLine:CGPointMake(0, 100.0f - headerLine)  to:CGPointMake(FILTER_AREA_WIDTH, 100.0f - headerLine)  lineWidth:listW strokeColor:[UIColor whiteColor]];
    [tab1 drawLine:CGPointMake(300, 50)                 to:CGPointMake(300, footerLine-36)                      lineWidth:listW strokeColor:[UIColor whiteColor]];
    [tab1 drawLine:CGPointMake(600, 50)                 to:CGPointMake(600, footerLine-36)                      lineWidth:listW strokeColor:[UIColor whiteColor]];
    [tab1 drawLine:CGPointMake(0, footerLine-36)        to:CGPointMake(FILTER_AREA_WIDTH, footerLine-36)        lineWidth:listW strokeColor:[UIColor whiteColor]];
    
    
    [tabManager addTabList:@[tab1]];
    [tab1  linkComponents:@[subTagScrollViewNew, self.rangeSlider, periodScrollViewNew,playerScrollViewNew,userColours]];
    
    
    
    
    
    
}




@end
