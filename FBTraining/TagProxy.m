//
//  TagProxy.m
//  Live2BenchNative
//
//  Created by dev on 2016-06-13.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "TagProxy.h"
#import "Event.h"
#import "ImageAssetManager.h"
#import "Tag.h"
@interface TagProxy ()

@property (nonatomic, strong) id <TagProtocol> tag;

@end

static NSInteger _proxyTempID;




@implementation TagProxy

+(void)initialize
{
    _proxyTempID = 0;
}

// this is to save the tag if you change event before you  remove the proxy
+(NSString*)proxyTempID
{
    _proxyTempID--;
    return [NSString stringWithFormat:@"%ld",(long)_proxyTempID];
}


@synthesize tagData = _tagData;
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.tagData = [self defaultData];
    }
    return self;
}

- (instancetype)initWithTagData:(NSDictionary*)dict ownEvent:(Event*)event
{
    self = [super init];
    if (self) {
        self.eventInstance = event;
        _tagData = [self defaultData];
        [self.tagData addEntriesFromDictionary:dict];
        _tagData[@"displaytime"] = [Utility translateTimeFormat:[_tagData[@"time"] doubleValue]];
        
    }
    return self;
}

-(NSMutableDictionary*)defaultData
{
    
    NSNumber *dur = [NSNumber numberWithDouble:([UserCenter getInstance].preRoll + [UserCenter getInstance].postRoll)];
    
    NSString * anID = [TagProxy proxyTempID];
    
    NSMutableDictionary* data = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                @"duration"    : dur,
                                                                                @"comment"     : @"",
                                                                                @"deleted"     : @0,
                                                                                @"displaytime" : @"",
                                                                                @"event"       : self.eventInstance.name,
                                                                                @"homeTeam"    : @"",
                                                                                @"visitTeam"   : @"",
                                                                                @"id"          : anID,
                                                                                @"isLive"      : @1,
                                                                                @"newTagID"    : anID,
                                                                                @"own"         : @1,
                                                                                @"rating"      : @"",
                                                                                @"starttime"   : @0,
                                                                                @"synced"      : @0,
                                                                                @"time"        : @0,
                                                                                @"type"        : @0


                                                                                }];
    return data;
}


-(BOOL)hasTag
{
    return (self.tag != nil);
}





// this merges the proxy tag data to the real tag
-(void)addTagToProxy:(id<TagProtocol>)tag
{
    
    if (![tag isKindOfClass:[Tag class]]){
        [tag.tagData addEntriesFromDictionary:self.tagData];
    }
    
    
    self.tag = tag;
    _tagData = nil; // clear up some space
    
    
    // Download Thumbnail for new tags
    
    [[ImageAssetManager getInstance]thumbnailsPreload:[[self.tag thumbnails] allValues]];
}

-(void)setTagData:(NSMutableDictionary *)tagData
{
    if (self.tag) {
        self.tag.tagData = tagData;
    } else {
        _tagData = tagData;
    }
}

-(NSMutableDictionary*)tagData
{
    if (self.tag) {
        return self.tag.tagData;
    } else {
        return _tagData;
    }
}



-(void)setName:(NSString *)name
{
    if (self.tag) {
        self.tag.name = name;
    } else {
        self.tagData[@"name"] = name;
    }
}

-(NSString*)name
{
    if (self.tag) {
        return self.tag.name;
    } else {
        return self.tagData[@"name"];
    }
}


-(BOOL)own
{
    if (self.tag) {
        return self.tag.own;
    } else {
        return [self.tagData[@"own"]boolValue];
    }
}

-(void)setDeviceid:(NSString*)deviceID
{
    if (self.tag){
        self.tag.deviceID = deviceID;
    } else {
        self.tagData[@"deviceid"] = deviceID;
    }
}

-(NSString*)deviceid
{
    if ( self.tag){
        return self.tag.deviceID;
    }   else {
        return self.tagData[@"deviceid"];
    }
}

-(void)setUser:(NSString*)user
{
    if (self.tag){
        self.tag.user = user;
    } else {
        self.tagData[@"user"] = user;
    }
}

-(NSString*)user
{
    if ( self.tag){
        return self.tag.user;
    }   else {
        return self.tagData[@"user"];
    }
}

-(void)setColour:(NSString*)colour
{
    if (self.tag){
        self.tag.colour = colour;
    } else {
        self.tagData[@"colour"] = colour;
    }
}

-(NSString*)colour
{
    if ( self.tag){
        return self.tag.colour;
    }   else {
        return self.tagData[@"colour"];
    }
}

-(void)setRating:(NSInteger)rating
{
    if (self.tag){
        self.tag.rating = rating;
    } else {
        self.tagData[@"rating"] = [NSNumber numberWithInteger:rating];
    }
}

-(NSInteger)rating
{
    if ( self.tag){
        return self.tag.rating;
    }   else {
        return [self.tagData[@"rating"]integerValue];
    }
}

-(void)setComment:(NSString*)comment
{
    if (self.tag){
        self.tag.comment = comment;
    } else {
        self.tagData[@"comment"] = comment;
    }
}

-(NSString*)comment
{
    if ( self.tag){
        return self.tag.comment;
    }   else {
        return self.tagData[@"comment"];
    }
}

-(void)setTime:(double)time
{
    if (self.tag){
        self.tag.time = time;
    } else {
        self.tagData[@"time"] = [NSNumber numberWithDouble:time];
    }
}

-(double)time
{
    if ( self.tag){
        return self.tag.time;
    }   else {
        return [self.tagData[@"time"]doubleValue];
    }
}

-(void)setUniqueID:(int)uniqueID
{
    if (self.tag){
        self.tag.uniqueID = uniqueID;
    } else {
        self.tagData[@"id"] = [NSNumber numberWithInt:uniqueID];
    }
}



-(NSString*)ID
{
    
    if ( self.tag){
        return [self.tag ID];
    }   else {
        return self.tagData[@"id"];
    }
}

-(void)setStarttime:(double)startTime
{
    if (self.tag){
        self.tag.startTime = startTime;
    } else {
        self.tagData[@"starttime"] = [NSNumber numberWithDouble:startTime];
    }
}

-(double)starttime
{
    if ( self.tag){
        return self.tag.startTime;
    }   else {
        return [self.tagData[@"starttime"] doubleValue];
    }
}

-(void)setDisplayTime:(NSString*)displayTime
{
    if (self.tag){
        self.tag.displayTime = displayTime;
    } else {
        self.tagData[@"displaytime"] = displayTime;
    }
}

-(NSString*)displayTime
{
    if ( self.tag){
        return self.tag.displayTime;
    }   else {
        return self.tagData[@"displaytime"];
    }
}

-(void)setDuration:(int)duration
{
    if (self.tag){
        self.tag.duration = duration;
    } else {
        self.tagData[@"duration"] = [NSNumber numberWithInt:duration];
    }
}

-(int)duration
{
    if ( self.tag){
        return self.tag.duration;
    }   else {
        return [self.tagData[@"duration"]intValue];
    }
}

-(void)setType:(TagType)type
{
    [self willChangeValueForKey:NSStringFromSelector(@selector(type))];
    
    if (self.tag){
        self.tag.type = type;
    } else {
        self.tagData[@"type"] = [NSNumber numberWithInteger:type];
    }
    
    [self didChangeValueForKey:NSStringFromSelector(@selector(type))];
}

-(TagType)type
{
    if ( self.tag){
        return (TagType)self.tag.type;
    }   else {
        return (TagType)[self.tagData[@"type"]integerValue];
    }
}


-(BOOL)deleted
{
    if ( self.tag){
        return self.tag.deleted;
    }   else {
        return [self.tagData[@"deleted"]boolValue];
    }
}

-(void)setDurationID:(NSString*)dtid
{
    if (self.tag){
        self.tag.durationID = dtid;
    } else {
        self.tagData[@"dtid"] = dtid;
    }
}

-(NSString*)durationID
{
    if ( self.tag){
        return self.tag.durationID;
    }   else {
        return self.tagData[@"dtid"];
    }
}

-(void)setEvent:(NSString*)event
{
    if (self.tag){
        self.tag.event = event;
    } else {
        self.tagData[@"event"] = event;
    }
}

-(NSString*)event
{
    if (self.tag){
        return self.tag.event;
    }   else {
        return self.tagData[@"event"];
    }
}

-(void)setHomeTeam:(NSString*)homeTeam
{
    if (self.tag){
        self.tag.homeTeam = homeTeam;
    } else {
        self.tagData[@"homeTeam"] = homeTeam;
    }
}

-(NSString*)homeTeam
{
    if ( self.tag){
        return self.tag.homeTeam;
    }   else {
        return self.tagData[@"homeTeam"];
    }
}

-(void)setVisitTeam:(NSString*)visitTeam
{
    if (self.tag){
        self.tag.visitTeam = visitTeam;
    } else {
        self.tagData[@"visitTeam"] = visitTeam;
    }
}

-(NSString*)visitTeam
{
    if ( self.tag){
        return self.tag.visitTeam;
    }   else {
        return self.tagData[@"visitTeam"];
    }
}

-(BOOL)isLive
{
    if (self.tag){
        return self.tag.isLive;
    }   else {
        return self.tagData[@"islive"];
    }
}

-(void)setPeriod:(NSString*)period
{
    if (self.tag){
        self.tag.period = period;
    } else {
        self.tagData[@"period"] = period;
    }
}

-(NSString*)period
{
    if ( self.tag){
        return self.tag.period;
    }   else {
        return self.tagData[@"period"];
    }
}

// WARNING
-(BOOL)synced
{
    if ( self.tag){
        return self.tag.synced;
    }   else {
        return NO;
    }
}

-(NSDictionary *)thumbnails
{
    if (self.tag){
        return self.tag.thumbnails;
    } else {
        return self.tagData[@"thumbnails"];
    }
}

-(void)setThumbnails:(NSDictionary *)thumbnails
{
    if (self.tag){
        self.tag.thumbnails = thumbnails;
    } else {
        self.tagData[@"thumbnails"] = thumbnails;
    }
}

//-(BOOL)success
//{
//    if ( self.tag){
//        return self.tag.success;
//    }    else {
//        return [self.tagData[@"success"] boolValue];
//    }
//}





- (nullable UIImage *)thumbnailForSource:(nullable NSString *)source
{
    if (self.tag){
        return  [self.tag thumbnailForSource:source];
    } else {
        return nil;
    }
}


@end
