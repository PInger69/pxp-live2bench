//
//  Tag.m
//  Live2BenchNative
//
//  Created by dev on 2015-04-17.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "Tag.h"

@implementation Tag

-(instancetype) initWithData: (NSDictionary *)tagData{
    self = [super init];
    if (self) {
        //self.rawData = tagData;
        self.colour = tagData[@"colour"];
        self.comment = tagData[@"comment"];
        self.deviceID = tagData[@"deviceid"];
        self.displayTime = tagData[@"displaytime"];
        self.duration = [tagData[@"duration"]intValue];
        self.event = tagData[@"event"];
        self.homeTeam = tagData[@"homeTeam"];
        self.visitTeam = tagData[@"visitTeam"];
        self.uniqueID = [tagData[@"id"] intValue];
        self.isLive = tagData[@"islive"];
        self.name = tagData[@"name"];
        self.own = [tagData[@"own"] boolValue];
        self.rating = tagData[@"rating"];
        self.requestURL = tagData[@"requrl"];
        self.startTime = [tagData[@"starttime"] doubleValue];
        self.time = [tagData[@"time"] doubleValue];
        self.type = [tagData[@"type"] intValue];
        self.user = tagData[@"user"];
        //self.requestTime = tagData [@"requettime"];
        if ([tagData objectForKey: @"urls_2"]) {
            NSDictionary *images = [tagData objectForKey: @"urls_2"];
            NSArray *keys = [images allKeys];
            NSMutableDictionary *thumbnails = [NSMutableDictionary dictionary];
            for (NSString *key in keys) {
                [thumbnails addEntriesFromDictionary:@{key: images[key]}];
            }
            self.thumbnails = thumbnails;
        }else{
            self.thumbnails = @{@"onlySource": [tagData objectForKey:@"url"]};
        }
    }
    return self;
}

-(NSDictionary *)tagDictionary{
    return @{@"colour": self.colour,
             @"comment": self.comment,
             @"deleted": @0,
             @"deviceid":self.deviceID,
             @"displaytime":self.displayTime,
             @"duration": [NSNumber numberWithInt:self.duration],
             @"event":self.event,
             @"homeTeam":self.homeTeam,
             @"id": [NSNumber numberWithInt: self.uniqueID],
             @"isLive": [NSNumber numberWithBool:self.isLive],
             @"name":self.name,
             @"newTagID" : [NSNumber numberWithInt: self.uniqueID],
             @"own": [NSNumber numberWithBool:self.own],
             @"rating" : [NSNumber numberWithInt: self.rating],
             @"requrl": self.requestURL,
             @"sender":@".min",
             @"starttime": [NSString stringWithFormat:@"%f", self.startTime],
             @"success": @1,
             @"time": [NSString stringWithFormat:@"%f", self.time],
             @"type": [NSNumber numberWithInt: self.type],
             @"url": self.requestURL,
             @"user": self.user,
             @"visitTeam": self.visitTeam,
             @"synced": [NSNumber numberWithBool: self.synced]
             };
}

-(NSDictionary *) makeTagData{
    return @{
             @"colour": self.colour,
             @"deviceid":self.deviceID,
             @"event":self.event,
             @"name":[Utility encodeSpecialCharacters:self.name],
             @"requestime":[NSString stringWithFormat:@"%f",CACurrentMediaTime()],
             @"time": [NSString stringWithFormat:@"%f", self.time],
             @"user": self.user
             
             };
}

-(void) replaceDataWithDictionary: (NSDictionary *) tagData{
    self.colour = tagData[@"colour"];
    self.comment = tagData[@"comment"];
    self.deviceID = tagData[@"deviceid"];
    self.displayTime = tagData[@"displaytime"];
    self.duration = [tagData[@"duration"]intValue];
    self.event = tagData[@"event"];
    self.homeTeam = tagData[@"homeTeam"];
    self.visitTeam = tagData[@"visitTeam"];
    self.uniqueID = [tagData[@"id"] intValue];
    self.isLive = tagData[@"islive"];
    self.name = tagData[@"name"];
    self.own = [tagData[@"own"] boolValue];
    self.rating = tagData[@"rating"];
    self.requestURL = tagData[@"requrl"];
    self.startTime = [tagData[@"starttime"] doubleValue];
    self.time = [tagData[@"time"] doubleValue];
    self.type = [tagData[@"type"] intValue];
    self.user = tagData[@"user"];
    //self.requestTime = tagData [@"requettime"];
    if ([tagData objectForKey: @"urls_2"]) {
        NSDictionary *images = [tagData objectForKey: @"urls_2"];
        NSArray *keys = [images allKeys];
        NSMutableDictionary *thumbnails = [NSMutableDictionary dictionary];
        for (NSString *key in keys) {
            [thumbnails addEntriesFromDictionary:@{key: images[key]}];
        }
        self.thumbnails = thumbnails;
    }else{
        self.thumbnails = @{@"onlySource": [tagData objectForKey:@"url"]};
    }

}

-(BOOL) isEqual:(id)object{
    Tag *comparingTag;
    if ([object isKindOfClass:[Tag class]]) {
        comparingTag = (Tag *) object;
    }
    return (comparingTag.uniqueID == self.uniqueID);
}

-(NSString *)description{
    //NSDictionary *tagDictionary = [self tagDictionary];
    //return [NSString stringWithFormat:@"%@", [self tagDictionary]];
    return [NSString stringWithFormat:@"name: %@, displayTime: %@, thumbnails: %@", self.name, self.displayTime, self.thumbnails];
}
@end
