//
//  GameSchedule.h
//  Live2BenchNative
//
//  Created by dev on 13-01-30.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameSchedule : NSObject{
    
    NSDate *date;
    NSString *homeTeam;
    NSString *visitTeam;
    NSString *videoId;
    NSString *videoId_mp4;
    NSString *eventName;
    NSString *hmnReadableName;
    NSString *sport;
    NSString *eventHid;
}

@property (nonatomic, strong, readonly) NSString *hmnReadableName;
@property (nonatomic, strong, readonly) NSDate *date;
@property (nonatomic, strong, readonly) NSString *homeTeam;
@property (nonatomic, strong, readonly) NSString *visitTeam;
@property (nonatomic, strong, readonly) NSString *videoId;
@property (nonatomic, strong, readonly) NSString *videoId_mp4;
@property (nonatomic, strong, readonly) NSString *eventHid;
@property (nonatomic, strong, readonly) NSString *eventName;
@property (nonatomic, strong, readonly) NSString *sport;


+ (GameSchedule*)homeTeamNamed:(NSString *)homeTeam visitTeam:(NSString *)visitTeam date:(NSDate *)date videoId:(NSString *)videoId videoId_mp4:(NSString *)videoId_mp4 eventHid:(NSString *)eventHid eventName:(NSString*)eventName sport:(NSString*)sport hmnReadableName:(NSString*)hmnReadableName;
- (id)initWithName:(NSString *)homeTeam visitTeam:(NSString *)visitTeam date:(NSDate *)date videoId:(NSString *)videoId videoId_mp4:(NSString *)videoId_mp4 eventHid:(NSString *)eventHid eventName:(NSString*)eventName sport:(NSString*)sport  hmnReadableName:(NSString*)hmnReadableName;




@end
