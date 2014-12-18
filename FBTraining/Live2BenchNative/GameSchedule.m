//
//  GameSchedule.m
//  Live2BenchNative
//
//  Created by dev on 13-01-30.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "GameSchedule.h"

@implementation GameSchedule

@synthesize date,homeTeam,visitTeam,videoId,eventName,hmnReadableName,sport,videoId_mp4,eventHid;

+ (GameSchedule*)homeTeamNamed:(NSString *)aHomeTeam visitTeam:(NSString *)aVisitTeam date:(NSDate *)aDate videoId:(NSString *)aVideoId videoId_mp4:(NSString *)avideoId_mp4 eventHid:(NSString *)anEventHid eventName:(NSString*)anEventName sport:(NSString *)aSport hmnReadableName:(NSString *)ahmnReadableName;
{
   // //// 
    return [[GameSchedule alloc] initWithName:aHomeTeam visitTeam:aVisitTeam date:aDate videoId:aVideoId videoId_mp4:avideoId_mp4 eventHid:anEventHid eventName:anEventName sport:aSport hmnReadableName:ahmnReadableName];
}

- (id)initWithName:(NSString *)aHomeTeam visitTeam:(NSString *)aVisitTeam date:(NSDate *)aDate videoId:(NSString *)aVideoId videoId_mp4:(NSString *)avideoId_mp4 eventHid:(NSString *)anEventHid eventName:(NSString*)anEventName sport:(NSString *)aSport hmnReadableName:(NSString *)ahmnReadableName
{
    if ((self = [super init])) {
        NSDateFormatter *fmt = [[NSDateFormatter alloc] init] ;
        [fmt setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        [fmt setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        [fmt setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        
        NSString * _videoId;
        NSString * _videoId_mp4;
        
        if (!aVideoId && avideoId_mp4) {
            _videoId         = avideoId_mp4;
            _videoId_mp4     = avideoId_mp4;
        }else if(!avideoId_mp4 && aVideoId){
            _videoId         = aVideoId;
            _videoId_mp4     = aVideoId;
        }else if(avideoId_mp4 && aVideoId){
            _videoId         = aVideoId;
            _videoId_mp4     = avideoId_mp4;
        }
        
        
        homeTeam            = (aHomeTeam != nil)?       [aHomeTeam copy]        : @"";
        visitTeam           = (aVisitTeam != nil)?      [aVisitTeam copy]       : @"";
        date                = (aDate != nil)?           aDate                   : [fmt dateFromString:@"0"];
        videoId             = [_videoId copy];
        videoId_mp4         = [_videoId_mp4 copy];
        eventHid            = (anEventHid != nil)?      [anEventHid copy]       : @"";
        eventName           = (anEventName != nil)?     [anEventName copy]      : @"";
        sport               = (aSport != nil)?          [aSport copy]           : @"";
         hmnReadableName    = [ahmnReadableName copy];
        
       // NSString *tempDateStr = [date description]; // temporary string holding the date,  also has time and time zone,zone not needed, we are going to get rid of it
        
       // NSRange rangeOfSubstring = [tempDateStr rangeOfString:@"+"];//find where the '+' occurs in the big string
        //NSString *parsedDate = [tempDateStr substringToIndex:rangeOfSubstring.location]; // grab everything before '+'
        
        //hmnReadableName = [NSString stringWithFormat:@"%@ %@ at %@",parsedDate,visitTeam,homeTeam]; // set the human readable version of the title -- Date Away at Home

    }
    return self;
}


-(NSString*)description
{
    NSString* txt = [NSString stringWithFormat:@"%@  -  %@",hmnReadableName,date];

    return txt;
}

/*
- (NSComparisonResult)compare:(GameSchedule *)otherGameSchedule
{
    NSComparisonResult comparison = [self.date compare:otherGameSchedule.date];
    if (comparison == NSOrderedSame)
        return [self.homeTeam compare:otherGameSchedule.homeTeam];
    else
        return comparison;
}
*/


@end
