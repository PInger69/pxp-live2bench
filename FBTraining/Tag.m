//
//  Tag.m
//  Live2BenchNative
//
//  Created by dev on 2015-04-17.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "Tag.h"
#import "Feed.h"

@implementation Tag{
    id tagModifyObserver;
}

-(instancetype) initWithData: (NSDictionary *)tagData{
    self = [super init];
    if (self) {
        self.rawData = tagData;
        self.colour = tagData[@"colour"];
        _comment = tagData[@"comment"];
        self.deviceID = @"";//tagData[@"deviceid"];
        self.displayTime = tagData[@"displaytime"];
        self.duration = [tagData[@"duration"]intValue];
        self.event = tagData[@"event"];
        self.homeTeam = tagData[@"homeTeam"];
        self.visitTeam = tagData[@"visitTeam"];
        self.uniqueID = [tagData[@"id"] intValue];
        self.isLive = [tagData[@"islive"] boolValue];
        self.name = tagData[@"name"];
        self.own = [tagData[@"own"] boolValue];
        _rating = [tagData[@"rating"] intValue];
        self.requestURL = tagData[@"requrl"];
        self.startTime = [tagData[@"starttime"] doubleValue];
        self.time = [tagData[@"time"] doubleValue];
        self.type = [tagData[@"type"] intValue];
        self.user = tagData[@"user"];
        self.modified = [tagData[@"modified"] boolValue];
        _coachPick = [tagData[@"coachpick"] boolValue];
        //self.requestTime = tagData [@"requettime"];
        if ([tagData objectForKey: @"urls_2"]) {
            NSDictionary *images = [tagData objectForKey: @"urls_2"];
            NSArray *keys = [images allKeys];
            NSMutableDictionary *thumbnails = [NSMutableDictionary dictionary];
            for (NSString *key in keys) {
                [thumbnails addEntriesFromDictionary:@{key: images[key]}];
            }
            self.thumbnails = thumbnails;
        }else if([tagData objectForKey:@"url"]){
            self.thumbnails = @{@"onlySource": [tagData objectForKey:@"url"]};
        }
        
        tagModifyObserver = [[NSNotificationCenter defaultCenter] addObserverForName:NOTIF_TAG_MODIFIED object:nil queue:nil usingBlock:^(NSNotification *note) {
            Tag *modifiedTag = note.object;
            if (modifiedTag.uniqueID == self.uniqueID) {
                if (modifiedTag.comment) {
                    _comment = modifiedTag.comment;
                }
                
                if (modifiedTag.rating) {
                    _rating = modifiedTag.rating;
                }
                
                _coachPick = modifiedTag.coachPick;
//                self.duration = modifiedTag.duration;
//                self.startTime = modifiedTag.startTime;
            }
        }];
    }
    return self;
}

#pragma mark - custom setters and getters
-(NSString *)name{
    return _name;
}

-(NSString *)displayTime{
    return _displayTime;
}

-(NSString *)event{
    return _event;
}

-(void)setFeeds:(NSDictionary *)feeds{
    _feeds = [feeds copy];
    if (feeds.count == 1) {
        self.thumbnails = @{ [[feeds allKeys] firstObject]: [[self.thumbnails allValues] firstObject]};
    }
}

-(void)setCoachPick:(BOOL)coachPick{
    _coachPick = coachPick;
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_MODIFY_TAG object:self];
}

-(void)setComment:(NSString *)comment{
    _comment = comment;
    if (comment) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_MODIFY_TAG object:self];
    }
    
}

-(void)setRating:(NSInteger)rating{
    _rating = rating;
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_MODIFY_TAG object:self];
}

-(NSDictionary *)rawData{
    return [self tagDictionary];
}

-(NSDictionary *)modifiedData{
    return @{ @"coachpick":(self.coachPick?@"1":@"0"),
              @"comment": (self.comment?self.comment:@""),
              @"rating": [NSString stringWithFormat:@"%ld", (long)self.rating]
              };
    
}

-(NSDictionary *)tagDictionary{
    NSMutableDictionary *tagDict = [NSMutableDictionary dictionary];
    
    
    [tagDict addEntriesFromDictionary: @{@"colour": self.colour,
             @"comment": self.comment,
             @"deleted": @"1",
             //@"deviceid": (self.deviceID ? self.deviceID: @"nil"),
             @"displaytime":self.displayTime,
             @"duration": [NSString stringWithFormat: @"%i", self.duration],
             @"event":self.event,
             @"homeTeam":self.homeTeam,
             @"id": [NSString stringWithFormat: @"%i", self.uniqueID],
             @"isLive": [NSString stringWithFormat: @"%i", self.isLive],
             @"name":self.name,
             @"newTagID" : [NSString stringWithFormat: @"%i",self.uniqueID],
             @"own": [NSString stringWithFormat: @"%i",self.own],
             @"rating" :[NSString stringWithFormat:@"%ld", (long)self.rating],
             //@"requrl": (self.requestURL? self.requestURL: @"nil"),
             @"sender":@".min",
             @"starttime": [NSString stringWithFormat:@"%f", self.startTime],
             @"success": @"1",
             @"time": [NSString stringWithFormat:@"%f", self.time],
             @"type": [NSString stringWithFormat:@"%li", (long)self.type],
             @"url": self.thumbnails,
             @"user": self.user,
             @"visitTeam": self.visitTeam,
             @"synced": [NSString stringWithFormat:@"%i", self.synced]
             //@"feeds" : (self.feeds ? self.feeds: @"nil")
             }];
    
    if (self.requestURL) {
        [tagDict addEntriesFromDictionary:@{@"requrl":self.requestURL}];
    }
    
    if (self.deviceID) {
        [tagDict addEntriesFromDictionary:@{@"deviceid": self.deviceID}];
    }
    
    return tagDict;
}

-(NSDictionary *) makeTagData{
    return @{
             @"colour": self.colour,
             @"deviceid":self.deviceID,
             @"event":self.event,
             //@"name":[Utility encodeSpecialCharacters:self.name],
             @"name":self.name,
             @"requestime":[NSString stringWithFormat:@"%f",CACurrentMediaTime()],
             @"time": [NSString stringWithFormat:@"%f", self.time],
             @"user": self.user,
             @"id": [NSString stringWithFormat:@"%d", self.uniqueID]
             
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

-(NSString *)ID{
    return [NSString stringWithFormat: @"%i" ,self.uniqueID];
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

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver: tagModifyObserver];
}
@end
