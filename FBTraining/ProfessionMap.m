//
//  ProfessionMap.m
//  Live2BenchNative
//
//  Created by dev on 2015-09-15.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "ProfessionMap.h"
#import "Tag.h"

#import "ListViewCell.h"
#import "thumbnailCell.h"

// BottomViewControllers
#import "HockeyBottomViewController.h"
#import "SoccerBottomViewController.h"
#import "RugbyBottomViewController.h"
#import "FootballBottomViewController.h"
#import "FootballTrainingBottomViewController.h"
#import "CFLBottomViewController.h"

// FilterTabControllers
#import "PxpFilterHockeyTabViewController.h"
#import "PxpFilterFootballTabViewController.h"
#import "PxpFilterRugbyTabViewController.h"
#import "PxpFilterSoccerTabViewController.h"
#import "PxpFilterCFLTabController.h"

@implementation ProfessionMap

static NSDictionary * _professionMapData;
+(void)initialize
{
    NSMutableDictionary  * dict = [NSMutableDictionary new];
    
    dict[SPORT_HOCKEY]                  =  [ProfessionMap buildHockey];
    dict[SPORT_SOCCER]                  =  [ProfessionMap buildSoccer];
    dict[SPORT_FOOTBALL]                =  [ProfessionMap buildFootball];
    dict[SPORT_CFL]                     =  [ProfessionMap buildCFL];
    dict[SPORT_RUGBY]                   =  [ProfessionMap buildRugby];
    dict[SPORT_CRICKET]                 =  [ProfessionMap buildCricket];
    dict[SPORT_FOOTBALL_TRAINING]       =  [ProfessionMap buildFootballTraining];
    dict[SPORT_BLANK]                   =  [ProfessionMap buildBlank];
    _professionMapData                  =  [dict copy];

}

+(NSDictionary*)data
{
    return _professionMapData;
}

+(Profession*)getProfession:(NSString*)professionName
{
    if (![_professionMapData objectForKey:professionName]) {
        return (Profession*) _professionMapData[SPORT_BLANK];
    }

    return (Profession*) _professionMapData[professionName];
}

#pragma mark -
+(Profession*)buildHockey
{

    Profession * hockey = [Profession new];
    hockey.filterPredicate  =  [NSCompoundPredicate orPredicateWithSubpredicates:@[[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeHockeyStartOLine]
                                                                                   ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeHockeyStopOLine]
                                                                                   ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeHockeyStartDLine]
                                                                                   ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeHockeyStopDLine]
                                                                                   ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeHockeyPeriodStart]
                                                                                   ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeHockeyPeriodStop]
                                                                                   ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeHockeyOppOLineStart]
                                                                                   ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeHockeyOppOLineStop]
                                                                                   ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeHockeyOppDLineStart]
                                                                                   ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeHockeyOppDLineStop]
                                                                                   ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeHockeyStrengthStart]
                                                                                   ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeHockeyStrengthStop]]];
    
    
    hockey.invisiblePredicate   = [NSCompoundPredicate andPredicateWithSubpredicates:@[
                                                                                       [NSPredicate predicateWithFormat:@"type != %ld", (long)TagTypeHockeyStartOLine]
                                                                                       ,[NSPredicate predicateWithFormat:@"type != %ld", (long)TagTypeHockeyStopOLine]
                                                                                       ,[NSPredicate predicateWithFormat:@"type != %ld", (long)TagTypeHockeyStartDLine]
                                                                                       ,[NSPredicate predicateWithFormat:@"type != %ld", (long)TagTypeHockeyStopDLine]
                                                                                       ,[NSPredicate predicateWithFormat:@"type != %ld", (long)TagTypeHockeyPeriodStart]
                                                                                       ,[NSPredicate predicateWithFormat:@"type != %ld", (long)TagTypeHockeyPeriodStop]
                                                                                       ,[NSPredicate predicateWithFormat:@"type != %ld", (long)TagTypeHockeyOppOLineStart]
                                                                                       ,[NSPredicate predicateWithFormat:@"type != %ld", (long)TagTypeHockeyOppOLineStop]
                                                                                       ,[NSPredicate predicateWithFormat:@"type != %ld", (long)TagTypeHockeyOppDLineStart]
                                                                                       ,[NSPredicate predicateWithFormat:@"type != %ld", (long)TagTypeHockeyOppDLineStop]
                                                                                        ,[NSPredicate predicateWithFormat:@"duration != 0"]
                                                                                       //                                                                                      ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeHockeyStrengthStart]
                                                                                       //                                                                                      ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeHockeyStrengthStop]
                                                                                       ]];
    
    
    
    
    
    [hockey setOnClipViewCellStyle:^(thumbnailCell * cellToStyle, Tag * tagForData) {
        [cellToStyle.thumbPeriod setHidden:NO];
        
        if (tagForData.type == TagTypeTele){
            cellToStyle.thumbDur.text = @"";
        }
        
         cellToStyle.thumbPeriod.text = [NSString stringWithFormat:@"Period: %d",[tagForData.period intValue]+1];
        
        
        
    }];
    
    [hockey setOnListViewCellStyle:^(ListViewCell * cellToStyle, Tag * tagForData) {
        
    }];
    
    hockey.bottomViewControllerClass    = [HockeyBottomViewController class];
    hockey.filterTabClass               = [PxpFilterHockeyTabViewController class];
    
    return hockey;
}

#pragma mark -
+(Profession*)buildSoccer
{

    Profession * soccer = [Profession new];
    
    soccer.filterPredicate  =  [NSCompoundPredicate orPredicateWithSubpredicates:@[[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeSoccerHalfStart]
                                                                                   ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeSoccerHalfStop]
                                                                                   ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeSoccerZoneStart]
                                                                                   ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeSoccerZoneStop]
                                                                                   ]];
    
    
    soccer.invisiblePredicate   = [NSCompoundPredicate andPredicateWithSubpredicates:@[
                                                                                        [NSPredicate predicateWithFormat:@"type != %ld", (long)TagTypeSoccerHalfStop]
                                                                                       ,[NSPredicate predicateWithFormat:@"type != %ld", (long)TagTypeSoccerZoneStop]
                                                                                       ,[NSPredicate predicateWithFormat:@"type != %ld", (long)TagTypeSoccerHalfStart]
                                                                                       ,[NSPredicate predicateWithFormat:@"type != %ld", (long)TagTypeSoccerZoneStart]
                                                                                       ,[NSPredicate predicateWithFormat:@"duration != 0"]
                                                                                     
                                                                                       ]];
    
    
    
    
    // this is for extra styling for
    [soccer setOnClipViewCellStyle:^(thumbnailCell * cellToStyle, Tag * tagForData) {
        [cellToStyle.thumbPeriod setHidden:NO];
        if (tagForData.type == TagTypeTele){
            cellToStyle.thumbDur.text = @"";
        }
        cellToStyle.thumbPeriod.text = [NSString stringWithFormat:@"Half: %d",[tagForData.period intValue]+1];
        
        
        
    }];
    
    [soccer setOnListViewCellStyle:^(ListViewCell * cellToStyle, Tag * tagForData) {
        
    }];

    // set BottomviewController
    soccer.bottomViewControllerClass = [SoccerBottomViewController class];
    
    // set filter for list and clip view
    soccer.filterTabClass            = [PxpFilterSoccerTabViewController class];
    
    return soccer;
}
#pragma mark -
+(Profession*)buildFootball
{
    
    Profession * profession         = [Profession new];
    
    profession.filterPredicate      =  [NSCompoundPredicate orPredicateWithSubpredicates:@[]];
    
    profession.invisiblePredicate   = [NSCompoundPredicate andPredicateWithSubpredicates:@[]];
    
    // this is for extra styling for
    [profession setOnClipViewCellStyle:^(thumbnailCell * cellToStyle, Tag * tagForData) {
        [cellToStyle.thumbPeriod setHidden:NO];
        if (tagForData.type == TagTypeTele){
            cellToStyle.thumbDur.text = @"";
        }
        cellToStyle.thumbPeriod.text = [NSString stringWithFormat:@"Quarter: %d",[tagForData.period intValue]+1];
        
    }];
    
    [profession setOnListViewCellStyle:^(ListViewCell * cellToStyle, Tag * tagForData) {
        
    }];
    
    profession.bottomViewControllerClass    = [FootballBottomViewController class];
    profession.filterTabClass               = [PxpFilterFootballTabViewController class];
    
    
    return profession;
}
#pragma mark -
+(Profession*)buildCFL
{
    
    Profession * sport = [Profession new];
    
    sport.filterPredicate  =  [NSCompoundPredicate orPredicateWithSubpredicates:@[[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeSoccerHalfStart]
                                                                                   ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeSoccerHalfStop]
                                                                                   ]];
    
    
    sport.invisiblePredicate   = [NSCompoundPredicate andPredicateWithSubpredicates:@[
                                                                                       [NSPredicate predicateWithFormat:@"duration != 0"]
                                                                                       ]];
    
    
    
    
    // this is for extra styling for
    [sport setOnClipViewCellStyle:^(thumbnailCell * cellToStyle, Tag * tagForData) {
        [cellToStyle.thumbPeriod setHidden:NO];
        if (tagForData.type == TagTypeTele){
            cellToStyle.thumbDur.text = @"";
        }
        cellToStyle.thumbPeriod.text = [NSString stringWithFormat:@"Quarter: %d",[tagForData.period intValue]];
        
        
        
    }];
    
    [sport setOnListViewCellStyle:^(ListViewCell * cellToStyle, Tag * tagForData) {
        
    }];
    
    // set BottomviewController
    sport.bottomViewControllerClass = [CFLBottomViewController class];
    
    // set filter for list and clip view
    sport.filterTabClass            = [PxpFilterCFLTabController class];
//    sport.filterTabClass            = [PxpFilterSoccerTabViewController class];
    
    return sport;
}



#pragma mark -
+(Profession*)buildRugby
{
    
    Profession * profession         = [Profession new];
    
    profession.filterPredicate      = [NSCompoundPredicate orPredicateWithSubpredicates:@[]];
    
    profession.invisiblePredicate   = [NSCompoundPredicate andPredicateWithSubpredicates:@[]];
    
    // this is for extra styling for
    [profession setOnClipViewCellStyle:^(thumbnailCell * cellToStyle, Tag * tagForData) {
        [cellToStyle.thumbPeriod setHidden:NO];
        if (tagForData.type == TagTypeTele){
            cellToStyle.thumbDur.text = @"";
        }
        cellToStyle.thumbPeriod.text = [NSString stringWithFormat:@"Half: %d",[tagForData.period intValue]+1];
        
    }];
    
    [profession setOnListViewCellStyle:^(ListViewCell * cellToStyle, Tag * tagForData) {
        
    }];
    
    profession.bottomViewControllerClass    = [RugbyBottomViewController class];
    profession.filterTabClass               = [PxpFilterRugbyTabViewController class];
    
    
    
    return profession;
}

#pragma mark -
+(Profession*)buildFootballTraining
{
    
    Profession * profession = [Profession new];
    
    profession.filterPredicate  =  [NSCompoundPredicate orPredicateWithSubpredicates:@[[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeSoccerHalfStart]
                                                                                       ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeSoccerHalfStop]
                                                                                       ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeSoccerZoneStart]
                                                                                       ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeSoccerZoneStop]
                                                                                       ]];
    
    
    profession.invisiblePredicate   = [NSCompoundPredicate andPredicateWithSubpredicates:@[]];
    
    
    
    
    // this is for extra styling for
    [profession setOnClipViewCellStyle:^(thumbnailCell * cellToStyle, Tag * tagForData) {
        [cellToStyle.thumbPeriod setHidden:NO];
        if (tagForData.type == TagTypeTele){
            cellToStyle.thumbDur.text = @"";
        }
        cellToStyle.thumbPeriod.text = [NSString stringWithFormat:@"Half: %d",[tagForData.period intValue]+1];
        
        
        
    }];
    
    [profession setOnListViewCellStyle:^(ListViewCell * cellToStyle, Tag * tagForData) {
        
    }];
    
    profession.bottomViewControllerClass    = [FootballTrainingBottomViewController class];
    profession.filterTabClass               = nil;
    return profession;
}

#pragma mark -
+(Profession*)buildCricket
{
    
    Profession * profession = [Profession new];
    
    profession.filterPredicate  =  [NSCompoundPredicate orPredicateWithSubpredicates:@[[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeSoccerHalfStart]
                                                                                   ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeSoccerHalfStop]
                                                                                   ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeSoccerZoneStart]
                                                                                   ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeSoccerZoneStop]
                                                                                   ]];
    
    
    profession.invisiblePredicate   = [NSCompoundPredicate andPredicateWithSubpredicates:@[]];
    
    
    
    
    // this is for extra styling for
    [profession setOnClipViewCellStyle:^(thumbnailCell * cellToStyle, Tag * tagForData) {
        [cellToStyle.thumbPeriod setHidden:NO];
        if (tagForData.type == TagTypeTele){
            cellToStyle.thumbDur.text = @"";
        }
        cellToStyle.thumbPeriod.text = [NSString stringWithFormat:@"Half: %d",[tagForData.period intValue]+1];
        
        
        
    }];
    
    [profession setOnListViewCellStyle:^(ListViewCell * cellToStyle, Tag * tagForData) {
        
    }];
    
    profession.bottomViewControllerClass    = [SoccerBottomViewController class];
    profession.filterTabClass               = nil;
    return profession;
}

#pragma mark -
+(Profession*)buildBlank
{
    
    Profession * profession         = [Profession new];
    
    profession.filterPredicate      = [NSCompoundPredicate orPredicateWithSubpredicates:@[]];
    
    profession.invisiblePredicate   = [NSCompoundPredicate andPredicateWithSubpredicates:@[]];
    
    // this is for extra styling for
    [profession setOnClipViewCellStyle:^(thumbnailCell * cellToStyle, Tag * tagForData) {
        [cellToStyle.thumbPeriod setHidden:YES];
    }];
    
    [profession setOnListViewCellStyle:^(ListViewCell * cellToStyle, Tag * tagForData) {
        
    }];
    
    profession.bottomViewControllerClass    = nil;
    profession.filterTabClass               = nil;
    
    return profession;
}

@end


@implementation Profession

@end