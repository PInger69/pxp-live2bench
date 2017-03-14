//
//  Tag.m
//  Live2BenchNative
//
//  Created by dev on 2015-04-17.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "Tag.h"
#import "Feed.h"
#import "AVAsset+Image.h"

//#define GET_NOW_TIME        [NSNumber numberWithDouble:CACurrentMediaTime()]



static NSMutableDictionary * openDurationTagsWithID;

@implementation Tag{
    id tagModifyObserver;
    NSTimer        * durationTagWarningTimer;
    UIImage * __nullable _cachedThumbnail;
}

@synthesize type = _type;
@synthesize durationID;
@synthesize rating = _rating;
@synthesize eventInstance = _eventInstance;
@synthesize isLive = _isLive;

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
        self.eventInstance   = aEvent;
        self.rawData         = tagData;
        self.colour          = tagData[@"colour"];
        self.deviceID        = tagData[@"deviceid"];
        self.displayTime     = tagData[@"displaytime"];
        self.duration        = [tagData[@"duration"]intValue];
        self.event           = aEvent.name;//tagData[@"event"];
        self.homeTeam        = tagData[@"homeTeam"];
        self.visitTeam       = tagData[@"visitTeam"];
        self.uniqueID        = [tagData[@"id"] intValue];
        self.isLive          = [tagData[@"islive"] boolValue];
        self.name            = tagData[@"name"];
        self.own             = [tagData[@"own"] boolValue];
        self.requestURL      = tagData[@"requrl"];
        self.startTime       = [tagData[@"starttime"] doubleValue];
        self.time            = [tagData[@"time"] doubleValue];
        _type                = [tagData[@"type"] intValue];
        self.user            = tagData[@"user"];
        self.modified        = [tagData[@"modified"] boolValue];
        
        // these items have side-effects in their setters.
        _coachPick           = [tagData[@"coachpick"] boolValue];
        _rating              = [tagData[@"rating"] intValue];
        _comment             = tagData[@"comment"];
        
        
     
        if ([tagData objectForKey:@"role"]) self.role = [[tagData objectForKey:@"role"]integerValue];
        if ([tagData objectForKey:@"userTeam"]) self.userTeam = [tagData objectForKey:@"userTeam"];
            
        if (tagData[@"dtagid"]) self.durationID = tagData[@"dtagid"];
        
       [self builtTelestration:tagData];
        if ([tagData objectForKey:@"period"]) {
            self.period          = tagData[@"period"];
        }
        
        if ([self buildExtraDic:tagData].count > 0) {
            self.extraDic = [self buildExtraDic:tagData];
        }

        if ([tagData objectForKey:@"players"]) {
            self.players = tagData[@"players"];
        }else if ([tagData objectForKey:@"player"]){
            self.players = tagData[@"player"];
        }
        
        if (_type == TagTypeTele || _type == TagTypeFootballDownTags) {
            self.startTime = self.time;
        }
        
        
        NSString *teleData = tagData[@"telestration"];
        if (teleData) {
            _telestration = [PxpTelestration telestrationFromData:teleData];
            _telestration.sourceName = tagData[@"telesrc"];
        }
        
        // only add the timer if its your tag not someone elses
        if (_type == TagTypeOpenDuration && [self.deviceID isEqualToString:[[[UIDevice currentDevice] identifierForVendor]UUIDString]]) {
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
            
            if ([[tagData objectForKey:@"url"] isKindOfClass:[NSDictionary class]]) {
                self.thumbnails = [tagData objectForKey:@"url"];
            } else {
                 self.thumbnails = @{@"onlySource": [tagData objectForKey:@"url"]};
            }
            
           
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
            }
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(memoryWarningHandler:) name:NOTIF_RECEIVE_MEMORY_WARNING object:nil];
    }
    return self;
}

-(NSDictionary*)buildExtraDic:(NSDictionary*)data{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    if ([data objectForKey:@"line"]) {
        [dict setObject:[data objectForKey:@"line"] forKey:@"line"];
    }
    if ([data objectForKey:@"extra"]) {
        
        if (![[data objectForKey:@"extra"] isKindOfClass:[NSDictionary class]]) {
            NSError *jsonError;
            NSData *objectData = [[data objectForKey:@"extra"] dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *temp = [NSJSONSerialization JSONObjectWithData:objectData
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&jsonError];
            [dict addEntriesFromDictionary:temp];
        } else {
        
            [dict addEntriesFromDictionary:[data objectForKey:@"extra"]];
        }
        
 
    }
    return [dict copy];
}

-(void)builtTelestration:(NSDictionary*)data
{
    if ([data objectForKey:@"telestration"]) {
        self.telestration = [PxpTelestration telestrationFromData:[data objectForKey:@"telestration"]];
    }
}


//-(void)postDurationTagWarning:(NSTimer *)timer
//{
//    // post notif
//    [durationTagWarningTimer invalidate];
//    durationTagWarningTimer = nil;
//    PXPLog(@"Warning Tag is too long - %@", self.name);
//    NSLog(@"Warning Tag is too long - %@", self.name);
//}

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
       
    if (durationTagWarningTimer && (_type == TagTypeCloseDuration || _type == TagTypeDeleted )) {
           durationTagWarningTimer = nil;
       }

    }
}









-(NSString *)displayTime{
    return _displayTime;
}

-(Event *)eventInstance{
    return _eventInstance;
}

-(void)setEventInstance:(Event *)eventInstance{

    if (![eventInstance isKindOfClass:[Event class]]) {
        NSLog(@"%s",__FUNCTION__);
        
    }
    
    
    _eventInstance = eventInstance;
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
    output[@"comment"] = (_comment?_comment:@"");
    output[@"duration"] = [NSString stringWithFormat:@"%i",self.duration];
    output[@"starttime"] = [NSString stringWithFormat:@"%f",self.startTime];
    output[@"rating"] = [NSString stringWithFormat:@"%ld", (long)_rating];
    output[@"type"] = [NSNumber numberWithInteger:self.type];
    output[@"time"] = [NSNumber numberWithInteger:self.time];
    
    if (self.telestration) {
        output[@"telestration"] = self.telestration.data;
    }
    
    if (self.players) {
        output[@"players"] = self.players;
    }
    
    if (self.period) {
        output[@"period"] = self.period;
    }
    
    if (self.extraDic) {
        output[@"extra"] = self.extraDic;
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
             @"comment"     : (_comment)?_comment:@"",
             @"deleted"     : @"1",
             @"displaytime" : self.displayTime,
             @"duration"    : [NSString stringWithFormat: @"%i", self.duration],
             @"event"       : (self.eventInstance.name)?self.eventInstance.name:@"",
             @"homeTeam"    : (self.homeTeam)?self.homeTeam:@"",
             @"id"          : [NSString stringWithFormat: @"%i", self.uniqueID],
             @"isLive"      : [NSString stringWithFormat: @"%i", self.isLive],
             @"name"        : self.name,
             @"newTagID"    : [NSString stringWithFormat: @"%i",self.uniqueID],
             @"own"         : [NSString stringWithFormat: @"%i",self.own],
             @"rating"      : (_rating)?[NSString stringWithFormat:@"%ld", (long)_rating]:@"",
             @"sender"      : @".min",
             @"starttime"   : [NSString stringWithFormat:@"%f", self.startTime],
             @"success"     : @"1",
             @"time"        : [NSString stringWithFormat:@"%f", self.time],
             @"type"        : [NSString stringWithFormat:@"%li", (long)self.type],
             @"url"         : (self.thumbnails)?self.thumbnails:@{},
             @"user"        : self.user == nil ? @"" : self.user,
             @"visitTeam"   : (self.visitTeam)?self.visitTeam:@"",
             @"synced"      : [NSString stringWithFormat:@"%i", self.synced]
             //@"deviceid": (self.deviceID ? self.deviceID: @"nil"),
             //@"requrl": (self.requestURL? self.requestURL: @"nil"),
             //@"feeds" : (self.feeds ? self.feeds: @"nil")
             }];
    
    if ([_rawData objectForKey:@"telesrc"]){
        [tagDict setObject:[_rawData objectForKey:@"telesrc"] forKey:@"telesrc"];
    }

    
    
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
    
    if (self.extraDic) {
        tagDict[@"extra"] = self.extraDic;
    }
    
    if (self.players) {
        tagDict[@"players"] = self.players;
    }
    
    if (self.period) {
        tagDict[@"period"] = self.period;
    }
    
    return tagDict;
}

-(NSDictionary *) makeTagData{
    
    NSMutableDictionary *tagData = [[NSMutableDictionary alloc]initWithDictionary:@{
                                                                                    @"colour"      : self.colour ? self.colour : @"000000",
                                                                                  @"deviceid"    : (self.deviceID)?self.deviceID:@"",
                                                                                  @"starttime"   : [NSString stringWithFormat:@"%f", self.startTime],
                                                                                    @"displaytime" : self.displayTime ? self.displayTime : @"",
                                                                                  @"duration"    : (self.duration)?[NSString stringWithFormat: @"%i", self.duration]:@"",
                                                                                  @"event"       : (self.event)?self.event:@"",
                                                                                  @"name"        : self.name ? self.name : @"",
                                                                                  @"requestime"  : [NSString stringWithFormat:@"%f",CACurrentMediaTime()],
                                                                                  @"time"        : [NSString stringWithFormat:@"%f", self.time],
                                                                                  @"user"        : self.user ? self.user : @"",
                                                                                  @"id"          : [NSString stringWithFormat:@"%d", self.uniqueID],
                                                                                  @"type"        : [NSString stringWithFormat:@"%ld", (long)self.type],
                                                                                  @"comment"     : (_comment)?_comment:@"",
                                                                                  @"rating"     : (_rating)?[NSString stringWithFormat:@"%ld", (long)_rating]:@""
                                                                                  
                                                                                  }];
    if (self.durationID) {
        [tagData setObject:self.durationID forKey:@"dtagid"];
    }
    
    if (self.closeTime) {
        [tagData setObject:[NSString stringWithFormat:@"%f", self.closeTime] forKey:@"closetime"];
    }
    
    if (([tagData[@"type"]integerValue] == TagTypeTele) && [self.rawData objectForKey:@"telesrc"]){
         [tagData setObject:[self.rawData objectForKey:@"telesrc"] forKey:@"telesrc"];
    }
    
    
    if (self.extraDic) {
        [tagData setObject:self.extraDic forKey:@"extra"];
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
    
    if (self.period) {
        tagData[@"period"] = self.period;
    }
    
    if (self.players) {
        tagData[@"players"] = self.players;
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
    _isLive      = [tagData[@"islive"]boolValue];
    _name        = tagData[@"name"];
    _own         = [tagData[@"own"] boolValue];
    _rating      = [tagData[@"rating"] intValue];
    _requestURL  = tagData[@"requrl"];
    _startTime   = [tagData[@"starttime"] doubleValue];
    _time        = [tagData[@"time"] doubleValue];
    _type        = [tagData[@"type"] intValue];
    _user        = tagData[@"user"];
    _extraDic    = tagData[@"extra"];
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
        if ([[tagData objectForKey:@"url"] isKindOfClass:[NSDictionary class]]) {
            self.thumbnails = [tagData objectForKey:@"url"];
        } else {
            self.thumbnails = @{@"onlySource": [tagData objectForKey:@"url"]};
        }
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


-(void)setEvent:(NSString *)event
{

    _event = event;
}


-(BOOL) isEqual:(id)object{
    Tag *comparingTag;
    if ([object isKindOfClass:[Tag class]]) {
        comparingTag = (Tag *) object;
        
        BOOL check = (comparingTag.uniqueID == self.uniqueID);
        
        return check;
    }
    return NO;
}

- (NSUInteger)hash
{
    return self.uniqueID; //Must be a unique unsigned integer
}


-(NSString *)description{
    return [NSString stringWithFormat:@"name: %@, ID: %@, type: %@,displayTime: %@, thumbnails: %@  feeds: %@", self.name,self.ID,[NSString stringWithFormat:@"%ld",(long)self.type],self.displayTime, self.thumbnails, self.feeds];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver: tagModifyObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_RECEIVE_MEMORY_WARNING object:nil];
}

- (nullable UIImage *)thumbnailForSource:(nullable NSString *)source {
    
//    if (_cachedThumbnail) {
//    
//        return _cachedThumbnail;
//    }
    
    Feed *feed = source && self.eventInstance.feeds[source] ? self.eventInstance.feeds[source] : self.eventInstance.feeds.allValues.firstObject;
    
    if (!source && self.telestration) {
        for (NSString *k in self.eventInstance.feeds.keyEnumerator) {
            if ([self.telestration.sourceName isEqualToString:k]) {
                feed = self.eventInstance.feeds[k];
                break;
            }
        }
    }
    
    if (feed.path) {
        NSTimeInterval time = self.telestration ? self.telestration.thumbnailTime : self.time;

        NSLog(@"Feed path: %@", feed.path);
        AVAsset *asset = [AVURLAsset URLAssetWithURL:feed.path options:nil];
        UIImage *thumb = [asset imageForTime:CMTimeMake(time, 1)];
        
        if (thumb && (self.telestration.sourceName == feed.sourceName || [self.telestration.sourceName isEqualToString:feed.sourceName])) {
            UIGraphicsBeginImageContext(thumb.size);
            
            [thumb drawInRect:CGRectMake(0.0, 0.0, thumb.size.width, thumb.size.height)];
            [self.telestration.thumbnail drawInRect:CGRectMake(0.0, 0.0, thumb.size.width, thumb.size.height)];
            
            thumb = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        _cachedThumbnail = thumb;
    }
    
    return _cachedThumbnail;
}

-(void)setIsLive:(BOOL)isLive
{
    _isLive = isLive;
}

-(BOOL)isLive
{
    return _isLive;
}

// duration tags dont start at startTime they start at time
-(double)startTime
{
    return (self.type != TagTypeCloseDuration && self.type != TagTypeOpenDuration )?_startTime:_time;
}


- (void)memoryWarningHandler:(NSNotification *)note {
    _cachedThumbnail = nil;
}


-(NSDictionary*)thumbnails
{
//    NSLog(@"%@",_thumbnails);
    return _thumbnails;
}

-(BOOL) isTelestration {
    return self.type == TagTypeTele || self.telestration != nil;
}

@end
