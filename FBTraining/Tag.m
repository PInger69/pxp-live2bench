//
//  Tag.m
//  Live2BenchNative
//
//  Created by dev on 2015-04-17.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "Tag.h"
#import "Feed.h"

//#define GET_NOW_TIME        [NSNumber numberWithDouble:CACurrentMediaTime()]



static NSMutableDictionary * openDurationTagsWithID;

@implementation Tag{
    id tagModifyObserver;
    NSTimer        * durationTagWarningTimer;
}

@synthesize type = _type;
@synthesize durationID;

+ (void)initialize {
    if (self == [Tag self]) {
        openDurationTagsWithID = [[NSMutableDictionary alloc]init];
    }
}

+(void)clearDurationTags
{
    [openDurationTagsWithID removeAllObjects];
}

+( NSString *)makeDurationID
{
    NSString * uid = [[NSUUID UUID]UUIDString];
    [openDurationTagsWithID setObject:[[NSMutableDictionary alloc]init] forKey:uid];
    
    return uid;
}

+(void)addOpenDurationTag:(Tag*)tag dtid:(NSString*)uid
{
    if (uid && ![openDurationTagsWithID objectForKey:uid]){
        [openDurationTagsWithID setObject:[[NSMutableDictionary alloc]init] forKey:uid];
    }
    
    
    NSMutableDictionary * dict =[openDurationTagsWithID objectForKey:uid];
    [dict setObject:tag forKey:@"open"];

}

+(Tag*)getOpenTagByDurationId:(NSString*)uid
{
    return (Tag*)[openDurationTagsWithID objectForKey:uid][@"open"];
}



-(instancetype) initWithData: (NSDictionary *)tagData event:(Event*)aEvent{
    self = [super init];
    if (self) {
        self.rawData         = tagData;
        self.colour          = tagData[@"colour"];
        _comment             = tagData[@"comment"];
        self.deviceID        = tagData[@"deviceid"];
        self.displayTime     = tagData[@"displaytime"];
        self.duration        = [tagData[@"duration"]intValue];
        self.event           = aEvent;//tagData[@"event"];
        self.homeTeam        = tagData[@"homeTeam"];
        self.visitTeam       = tagData[@"visitTeam"];
        self.uniqueID        = [tagData[@"id"] intValue];
        self.isLive          = [tagData[@"islive"] boolValue];
        self.name            = tagData[@"name"];
        self.own             = [tagData[@"own"] boolValue];
        _rating              = [tagData[@"rating"] intValue];
        self.requestURL      = tagData[@"requrl"];
        self.startTime       = [tagData[@"starttime"] doubleValue];
        self.time            = [tagData[@"time"] doubleValue];
        _type                = [tagData[@"type"] intValue];
        self.user            = tagData[@"user"];
        self.modified        = [tagData[@"modified"] boolValue];
        _coachPick           = [tagData[@"coachpick"] boolValue];
       [self builtTelestration:tagData];
        
        if (_type == TagTypeTele) {
            self.startTime = self.time;
        }
        
        
        NSString *teleData = tagData[@"telestration"];
        if (teleData) {
            _telestration = [PxpTelestration telestrationFromData:teleData];
        }
        
        // only add the timer if its your tag not someone elses
        if (_type == TagTypeOpenDuration && [self.deviceID isEqualToString:[[[UIDevice currentDevice] identifierForVendor]UUIDString]]) {
            NSTimeInterval waitInterval = (330);
            durationTagWarningTimer            = [NSTimer scheduledTimerWithTimeInterval:waitInterval target:self selector:@selector(postDurationTagWarning:) userInfo:nil repeats:NO];

            [Tag addOpenDurationTag:self dtid:tagData[@"dtagid"]];
            
        }
        
        
        if ([tagData objectForKey: @"url_2"]) {
            NSDictionary *images = [tagData objectForKey: @"url_2"];
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
            Tag *modifiedTag = note.userInfo[@"tag"];
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

-(void)builtTelestration:(NSDictionary*)data
{
    if ([data objectForKey:@"telestration"]) {
        self.telestration = [PxpTelestration telestrationFromData:[data objectForKey:@"telestration"]];
    }
}


-(void)postDurationTagWarning:(NSTimer *)timer
{
    // post notif
    [durationTagWarningTimer invalidate];
    durationTagWarningTimer = nil;
    PXPLog(@"Warning Tag is too long - %@", self.name);
    NSLog(@"Warning Tag is too long - %@", self.name);
}

#pragma mark - custom setters and getters
-(NSString *)name{
    return _name;
}


-(void)setType:(TagType)type
{
    if (_type == type || type == TagTypeOpenDuration) return; // you can't set a tag to be a duration, it must be init as one
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(type))];

    _type = type;
    
    [self didChangeValueForKey:NSStringFromSelector(@selector(type))];
   if (_type == TagTypeCloseDuration && durationTagWarningTimer){
       
       id <EncoderProtocol> closingEncoder = self.event.parentEncoder;
       
//       MAKE_TAG
//       MODIFY_TAG
       
       
//       (lldb) po mutableDict
//       {
//           colour = 3af20f;
//           deviceid = "922FB422-01C7-4ADC-92E7-A299263F82B2";
//           event = live;
//           id = 7;
//           name = "COACH%20CALL";
//           requesttime = "999704.872756";
//           time = "123.832534";
//           type = 100;
//           user = ae1e7198bc3074ff1b2e9ff520c30bc1898d038e;
//       }

       
       
       [closingEncoder issueCommand:MAKE_TAG priority:5 timeoutInSec:5 tagData:[NSMutableDictionary dictionaryWithDictionary:[self makeTagData]] timeStamp:GET_NOW_TIME];
       
    if (durationTagWarningTimer && (_type == TagTypeCloseDuration || _type == TagTypeDeleted )) {
           [durationTagWarningTimer invalidate];
           durationTagWarningTimer = nil;
       }

    }
}









-(NSString *)displayTime{
    return _displayTime;
}

-(Event *)event{
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
    NSMutableDictionary *output = [NSMutableDictionary dictionary];
    
    output[@"coachpick"] = (self.coachPick?@"1":@"0");
    output[@"comment"] = (self.comment?self.comment:@"");
    output[@"duration"] = [NSString stringWithFormat:@"%i",self.duration];
    output[@"starttime"] = [NSString stringWithFormat:@"%f",self.startTime];
    output[@"rating"] = [NSString stringWithFormat:@"%ld", (long)self.rating];
    output[@"type"] = [NSNumber numberWithInteger:self.type];
    output[@"time"] = [NSNumber numberWithInteger:self.time];
    
    if (self.telestration) {
        output[@"telestration"] = self.telestration.data;
    }
    
    return output;
    
}


-(void)modifyTagWithDict:(NSDictionary*)dict
{



}


-(NSDictionary *)tagDictionary{
    NSMutableDictionary *tagDict = [NSMutableDictionary dictionary];
    
    
    [tagDict addEntriesFromDictionary: @{
             @"colour"      : self.colour,
             @"comment"     : self.comment,
             @"deleted"     : @"1",
             @"displaytime" : self.displayTime,
             @"duration"    : [NSString stringWithFormat: @"%i", self.duration],
             @"event"       : self.event.name,
             @"homeTeam"    : self.homeTeam,
             @"id"          : [NSString stringWithFormat: @"%i", self.uniqueID],
             @"isLive"      : [NSString stringWithFormat: @"%i", self.isLive],
             @"name"        : self.name,
             @"newTagID"    : [NSString stringWithFormat: @"%i",self.uniqueID],
             @"own"         : [NSString stringWithFormat: @"%i",self.own],
             @"rating"      : [NSString stringWithFormat:@"%ld", (long)self.rating],
             @"sender"      : @".min",
             @"starttime"   : [NSString stringWithFormat:@"%f", self.startTime],
             @"success"     : @"1",
             @"time"        : [NSString stringWithFormat:@"%f", self.time],
             @"type"        : [NSString stringWithFormat:@"%li", (long)self.type],
             @"url"         : self.thumbnails,
             @"user"        : self.user,
             @"visitTeam"   : self.visitTeam,
             @"synced"      : [NSString stringWithFormat:@"%i", self.synced]
             //@"deviceid": (self.deviceID ? self.deviceID: @"nil"),
             //@"requrl": (self.requestURL? self.requestURL: @"nil"),
             //@"feeds" : (self.feeds ? self.feeds: @"nil")
             }];
    
    if (self.requestURL) {
        [tagDict addEntriesFromDictionary:@{@"requrl":self.requestURL}];
    }
    
    if (self.deviceID) {
        [tagDict addEntriesFromDictionary:@{@"deviceid": self.deviceID}];
    }
    
    if (self.durationID) {
        [tagDict addEntriesFromDictionary:@{@"durationID": self.durationID}];
    }
    
    if (self.telestration) {
        tagDict[@"telestration"] = self.telestration.data;
    }
    
    return tagDict;
}

-(NSDictionary *) makeTagData{
    
    NSMutableDictionary *tagData = [[NSMutableDictionary alloc]initWithDictionary:@{
                                                                                  @"colour"      : self.colour,
                                                                                  @"deviceid"    : (self.deviceID)?self.deviceID:@"",
                                                                                  @"starttime"   : [NSString stringWithFormat:@"%f", self.startTime],
                                                                                  @"displaytime" : self.displayTime,
                                                                                  @"duration"    : (self.duration)?[NSString stringWithFormat: @"%i", self.duration]:@"",
                                                                                  @"event"       : (self.event.name)?self.event.name:@"",
                                                                                  @"name"        : self.name,
                                                                                  @"requestime"  : [NSString stringWithFormat:@"%f",CACurrentMediaTime()],
                                                                                  @"time"        : [NSString stringWithFormat:@"%f", self.time],
                                                                                  @"user"        : self.user,
                                                                                  @"id"          : [NSString stringWithFormat:@"%d", self.uniqueID],
                                                                                  @"type"        : [NSString stringWithFormat:@"%ld", (long)self.type],
                                                                                  @"comment"     : (self.comment)?self.comment:@"",
                                                                                   @"rating"     : (self.rating)?[NSString stringWithFormat:@"%ld", (long)self.rating]:@""
                                                                                  
                                                                                  }];
    if (self.durationID) {
        [tagData setObject:self.durationID forKey:@"dtagid"];
    }
    
    if (self.thumbnails.count > 1) {
        NSMutableDictionary *urls = [[NSMutableDictionary alloc]init];
        NSArray *keys = [self.thumbnails allKeys];
        for (NSString *key in keys) {
            [urls setObject:[self.thumbnails objectForKey:key] forKey:key];
        }
        [tagData setObject:urls forKey:@"url_2"];
        
    }else if (self.thumbnails.count == 1){
        NSString *url = [[self.thumbnails allValues] firstObject];
        [tagData setObject:url forKey:@"url"];
    }
    
    if (self.telestration) {
        tagData[@"telestration"] = self.telestration.data;
    }
    
    
    return tagData;
    
  }

-(void) replaceDataWithDictionary: (NSDictionary *) tagData{
    _colour      = tagData[@"colour"];
    _comment        = tagData[@"comment"];
    _deviceID    = tagData[@"deviceid"];
    _displayTime = tagData[@"displaytime"];
    _duration    = [tagData[@"duration"]intValue];
//    self.event       = tagData[@"event"];
    _homeTeam    = tagData[@"homeTeam"];
    _visitTeam   = tagData[@"visitTeam"];
    _uniqueID    = [tagData[@"id"] intValue];
    _isLive      = tagData[@"islive"];
    _name        = tagData[@"name"];
    _own         = [tagData[@"own"] boolValue];
    _rating      = [tagData[@"rating"] intValue];
    _requestURL  = tagData[@"requrl"];
    _startTime   = [tagData[@"starttime"] doubleValue];
    _time        = [tagData[@"time"] doubleValue];
    _type        = [tagData[@"type"] intValue];
    _user        = tagData[@"user"];
    //self.requestTime = tagData [@"requettime"];
    if ([tagData objectForKey: @"url_2"]) {
        NSDictionary *images = [tagData objectForKey: @"url_2"];
        NSArray *keys = [images allKeys];
        NSMutableDictionary *thumbnails = [NSMutableDictionary dictionary];
        for (NSString *key in keys) {
            [thumbnails addEntriesFromDictionary:@{key: images[key]}];
        }
        self.thumbnails = thumbnails;
    }else if ([tagData objectForKey:@"url"]){
        self.thumbnails = @{@"onlySource": [tagData objectForKey:@"url"]};
    }
    
    if ([tagData objectForKey:@"durationID"]) {
        self.durationID = [tagData objectForKey:@"durationID"];
    }
    
    
    if (durationTagWarningTimer && (_type == TagTypeCloseDuration || _type == TagTypeDeleted )) {
        [durationTagWarningTimer invalidate];
        durationTagWarningTimer = nil;
    }
    
    NSString *telestrationData = tagData[@"telestration"];
    _telestration = telestrationData ? [PxpTelestration telestrationFromData:telestrationData] : nil;
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
    return [NSString stringWithFormat:@"name: %@, type: %@,displayTime: %@, thumbnails: %@  feeds: %@", self.name,[NSString stringWithFormat:@"%ld",(long)self.type],self.displayTime, self.thumbnails, self.feeds];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver: tagModifyObserver];
}
@end
