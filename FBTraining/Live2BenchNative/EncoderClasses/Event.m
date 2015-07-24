//
//  Event.m
//  Live2BenchNative
//
//  Created by dev on 2015-04-01.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "Event.h"
#import "Feed.h"
#import "Tag.h"
#import "UserCenter.h"



@implementation Event {
    NSString *localPath;
}

@synthesize name        = _name;
@synthesize eventType   = _eventType;
@synthesize datapath    = _datapath;
@synthesize date        = _date;
@synthesize hid         = _hid;
@synthesize feeds       = _feeds;
@synthesize mp4s        = _mp4s;
@synthesize rawData     = _rawData;
@synthesize deleted     = _deleted;
@synthesize live        = _live;
@synthesize tags        = _tags;

@synthesize downloadedSources       = _downloadedSources; // depricated
@synthesize parentEncoder           = _parentEncoder;
@synthesize isBuilt                 = _isBuilt;
@synthesize primary                 = _primary;

@synthesize delegate = _delegate;

- (instancetype)initWithDict:(NSDictionary*)data  isLocal:(BOOL)isLocal andlocalPath:(NSString *)path
{
    self = [super init];
    if (self) {
        NSMutableDictionary *dataFinal = [[NSMutableDictionary alloc]initWithDictionary:data];
        _rawData            = dataFinal;
        _live               = (_rawData[@"live"] || _rawData[@"live_2"])? YES:NO;
        _primary            = false;
        _name               = [_rawData objectForKey:@"name"];
        _hid                = [_rawData objectForKey:@"hid"];
        _eventType          = [_rawData objectForKey:@"sport"];
        _datapath           = [_rawData objectForKey:@"datapath"];
        _date               = [_rawData objectForKey:@"date"];
        _mp4s               = [self buildMP4s:_rawData];
        localPath           = path;
        //        _feeds              = [self buildFeeds:_rawData];
        _feeds              = [self buildFeeds:_rawData isLive:_live isLocal:isLocal];
        _deleted            = [[_rawData objectForKey:@"deleted"]boolValue];
        _downloadedSources  = [NSMutableArray array]; // depricated
        _downloadingItemsDictionary = [[NSMutableDictionary alloc] init];
        _tags               = [self buildTags:_rawData];

//        _teams              = [[NSMutableDictionary alloc]init];
//        if ([_rawData objectForKey:@"homeTeam"]) [_teams setValue:[_rawData objectForKey:@"homeTeam"] forKey:@"homeTeam"];
//        if ([_rawData objectForKey:@"visitTeam"]) [_teams setValue:[_rawData objectForKey:@"visitTeam"] forKey:@"visitTeam"];
    }
    [[NSNotificationCenter defaultCenter] addObserverForName:NOTIF_EVENT_DOWNLOADED object:nil queue:nil usingBlock:^(NSNotification *note){
        NSArray *key = [self.downloadingItemsDictionary allKeysForObject:note.userInfo[@"Finish"]];
        if (key.count > 0) {
            [self.downloadingItemsDictionary removeObjectForKey:key[0]];
            [self.downloadedSources addObject:[(NSString *)key[0] lastPathComponent]];
        }
    }];
    return self;
}

-(void)setPrimary:(BOOL)primary{
    _primary = primary;
}

-(void)addAllTags:(NSDictionary *)allTagData
{
    NSMutableArray *tagsReceived = [NSMutableArray array];
    
     NSArray *tagArray = [allTagData allValues];
     for (NSDictionary *newTagDic in tagArray) {
         Tag *newTag = [[Tag alloc] initWithData: newTagDic event:self];
         [_tags addObject:newTag];
         [tagsReceived addObject:newTag];
     }
     self.isBuilt = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_TAG_RECEIVED
                                                        object:self
                                                      userInfo:@{
                                                                 @"tags": tagsReceived
                                                                 }];
}



-(void)addTag:(Tag *)newtag extraData:(BOOL)notifPost
{
    //BOOL type = (newtag.type == TagTypeDeleted);
    //BOOL contain = [_tags containsObject:newtag];
    //int  index = [_tags indexOfObject:newtag];
    //BOOL mem = (newtag == [_tags objectAtIndex:index]);
    if ((newtag.type == TagTypeDeleted || [_tags containsObject:newtag]) && newtag.type != TagTypeHockeyStrengthStop && newtag.type != TagTypeHockeyStopOLine && newtag.type != TagTypeHockeyStopDLine && newtag.type != TagTypeSoccerZoneStop) {
        return;
    }
    
    [_tags addObject:newtag];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_TAG_RECEIVED
                                                        object:self
                                                      userInfo:@{
                                                                 @"tags": @[newtag]
                                                                 }];
    
    if ((newtag.type == TagTypeCloseDuration || newtag.type == TagTypeTele || newtag.type == TagTypeNormal || newtag.type == TagTypeHockeyStrengthStart || newtag.type == TagTypeHockeyStartOLine || newtag.type == TagTypeHockeyStopOLine || newtag.type == TagTypeHockeyStartDLine || newtag.type == TagTypeHockeyStopDLine || newtag.type == TagTypeSoccerZoneStart || newtag.type == TagTypeSoccerZoneStop) && _primary && notifPost ) {
        
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_TOAST object:nil   userInfo:@{
                                                                                                      @"msg":newtag.name,
                                                                                                      @"colour":newtag.colour,
                                                                                                      @"type":[NSNumber numberWithUnsignedInteger:ARTagCreated]
                                                                                                      }];
    }
}

-(void)modifyTag:(NSDictionary *)modifiedData
{
    NSString * tagId;
    if ([[modifiedData objectForKey:@"id"] isKindOfClass:[NSString class]]) {
        tagId = [modifiedData objectForKey:@"id"];
    }else{
        tagId = [[modifiedData objectForKey:@"id"]stringValue];
    }
    //NSString * tagId = [[modifiedData objectForKey:@"id"]stringValue];// [NSString stringWithFormat:@"%ld",[[data objectForKey:@"id"]integerValue] ];
        NSPredicate *pred = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            Tag * obj = evaluatedObject;
            return [obj.ID isEqualToString:tagId];
        }];
        
        NSArray *filteredArray = [_tags filteredArrayUsingPredicate:pred];
        Tag *tagToBeModded = [filteredArray firstObject];
        
        if ( ((TagType)[modifiedData[@"type"]integerValue]) == TagTypeCloseDuration && tagToBeModded.type == TagTypeOpenDuration) {
           
            if ([Tag getOpenTagByDurationId:modifiedData[@"dtagid"]]) {
                tagToBeModded = [Tag getOpenTagByDurationId:modifiedData[@"dtagid"]];
            }
            
            
            NSMutableDictionary * dictToChange = [[NSMutableDictionary alloc]initWithDictionary:modifiedData];
            double openTime                 = tagToBeModded.time;
            double closeTime                = [dictToChange[@"closetime"]doubleValue];
            
            if (!closeTime) {
                return;
            }
            
            dictToChange[@"duration"]       = [NSNumber numberWithDouble:(closeTime-openTime)];
            dictToChange[@"type"]           = [NSNumber numberWithInteger:TagTypeCloseDuration];
            
            
            [tagToBeModded replaceDataWithDictionary:[dictToChange copy]];
            tagToBeModded.modified = true;
                
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_TOAST object:nil   userInfo:@{
                                                                                                              @"msg":tagToBeModded.name,
                                                                                                              @"colour":tagToBeModded.colour,
                                                                                                              @"type":[NSNumber numberWithUnsignedInteger:ARTagCreated]
                                                                                                              }];
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MODIFY_TAG object:nil userInfo:[tagToBeModded makeTagData]];
            
     
        }else if( ((TagType)[modifiedData[@"type"]integerValue]) == TagTypeDeleted){
            [_tags removeObject:tagToBeModded];
            
        }else {
            [tagToBeModded replaceDataWithDictionary:modifiedData];
        }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_TAG_MODIFIED
                                                        object:self
                                                      userInfo:@{
                                                                 @"tags": tagToBeModded ?  @[tagToBeModded] : @[]
                                                                 }];
    tagToBeModded.modified = false;
}

-(NSDictionary*)rawData
{
    if (_tags != nil && _tags.count != 0) {
        NSMutableDictionary * newRawData    = [[NSMutableDictionary alloc]initWithDictionary:_rawData];
        NSMutableDictionary * tagsToBeAdded = [[NSMutableDictionary alloc]init];
        
        for (Tag *tag in _tags) {
            [tagsToBeAdded setObject:[tag makeTagData] forKey:tag.ID];
        }
        
        [newRawData setObject:tagsToBeAdded forKey:@"tags"];
        return [newRawData copy];
   }
    
    if ([_rawData objectForKey:@"tags"]) {
        [_rawData removeObjectForKey:@"tags"];
    }
    return _rawData;
 
}


-(void)setDownloadedSources:(NSMutableArray *)downloadedSources{
    _downloadedSources = downloadedSources;
}


-(NSMutableArray *)buildTags:(NSDictionary*)aDict{
    
    NSMutableArray *tagResult = [[NSMutableArray alloc]init];
    
    if (aDict[@"tags"]) {
        NSDictionary *tagToBeAdded = aDict[@"tags"];
        NSArray *tagArray = [tagToBeAdded allValues];
       
        
        
        for (NSDictionary *tagDic in tagArray) {
            Tag *tag = [[Tag alloc]initWithData:tagDic event:self];
            if (tag.type !=  TagTypeDeleted ) {
            [tagResult addObject:tag];
            }
        }
    }
    return (tagResult)?tagResult:nil;
}

-(NSDictionary*)buildMP4s:(NSDictionary*)aDict
{
    NSMutableDictionary * tempDict = [[NSMutableDictionary alloc]init];
    
    if ([aDict objectForKey:@"mp4_2"]) {
        tempDict = [aDict objectForKey:@"mp4_2"];
    } else if ([aDict objectForKey:@"mp4"]) {
        NSDictionary *dic = @{@"hq":[aDict objectForKey:@"mp4"]};
        [tempDict setObject:dic forKey:@"onlySource"];
    }
    return [tempDict copy];
}

// Local events have different feed inits

-(NSDictionary*)buildFeeds:(NSDictionary*)aDict isLive:(BOOL)isLive isLocal:(BOOL)isLocal
{
    NSString            * toypKey   = (isLive)?@"live_2":@"mp4_2";
    NSMutableDictionary * tempDict  = [[NSMutableDictionary alloc]init];
    
    // this is a check for the new encoder vs the old
    if ([aDict[toypKey] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *vidDict = aDict[toypKey];
        NSArray *keys = [vidDict allKeys];
        //for (id key in aDict[toypKey])
        for (int i = 0; i < vidDict.count; i++)
        {
            //NSDictionary * vidDict      = aDict[toypKey];
            NSDictionary * qualities    = [vidDict objectForKey:keys[i]];
            NSString *name = [NSString stringWithFormat:@"main_0%ihq.mp4",i];
            NSString *filePath = [[[localPath stringByAppendingPathComponent:@"events"] stringByAppendingPathComponent:self.name] stringByAppendingPathComponent:name];
            
            Feed * createdFeed = (isLocal)? [[Feed alloc]initWithFileURL:filePath] : [[Feed alloc] initWithURLDict:qualities];
            
            if (createdFeed != nil) {
                createdFeed.sourceName = keys[i];
                if (self.live){
                    createdFeed.type = FEED_TYPE_LIVE;
                } else if (self.local) {
                    createdFeed.type = FEED_TYPE_LOCAL;
                } else {
                    createdFeed.type = FEED_TYPE_ENCODER;
                }
                
                
                [tempDict setObject:createdFeed forKey:keys[i]];

            }
            
        }
        
    } else { // old encoder
        Feed * theFeed;
        if (aDict[@"live"]) { // This is for backwards compatibility
            theFeed =  [[Feed alloc]initWithURLString:aDict[@"live"] quality:0];
            _live = YES;
        } else if (aDict[@"vid"] || aDict[@"mp4"]) {
//            theFeed = [[Feed alloc]initWithFileURL:aDict[@"mp4"]];
            if (!aDict[@"mp4"] && !isLocal) {
                theFeed = [[Feed alloc]initWithURLString:aDict[@"vid"]  quality:0]  ;
            } else {
                theFeed = (isLocal)? [[Feed alloc]initWithFileURL:aDict[@"mp4"]] :  [[Feed alloc]initWithURLString:aDict[@"mp4"]  quality:0]  ;
            }
            
            
        } else {
//            PXPLog(@"Event Warning: No Feeds on Encoder for Event");
//            PXPLog(@"   HID: %@",aDict[@"hid"]);
            return @{};
        }
        //[tempDict setObject:theFeed forKey:@"s1"];
        if (theFeed != nil) {
            [tempDict setObject:theFeed forKey:@"onlySource"];
        }
    }
    
    return [tempDict copy];
}

-(NSArray*)getTagsByID:(NSString*)tagId
{
    NSPredicate *pred = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {        
        Tag * obj = evaluatedObject;
        return [obj.name isEqualToString:tagId];
    }];
    
    return [self.tags filteredArrayUsingPredicate:pred];
}

/**
 *  This makes the feeds from the data and returns the a dict based of the feeds labeled by scource name as key
 *
 *  @param dict raw data
 *
 *  @return key
 */
-(NSDictionary*)buildFeeds:(NSDictionary*)aDict
{
    
    NSMutableDictionary * tempDict = [[NSMutableDictionary alloc]init];
    
    if ([aDict[@"vid_2"] isKindOfClass:[NSDictionary class]]){ // For new encoder and non live
        
        for (id key in aDict[@"vid_2"])
        {
            NSDictionary * vidDict      = aDict[@"vid_2"];
            NSDictionary * qualities    = [vidDict objectForKey:key];
            
            Feed * createdFeed = [[Feed alloc]initWithURLDict:qualities];
            createdFeed.sourceName = key;
            if (self.live){
                createdFeed.type = FEED_TYPE_LIVE;
            } else if (self.local) {
                createdFeed.type = FEED_TYPE_LOCAL;
            } else {
                createdFeed.type = FEED_TYPE_ENCODER;
            }
            [tempDict setObject:createdFeed forKey:key];
        }
        
    } else if ([aDict[@"live_2"] isKindOfClass:[NSDictionary class]]){ // for new encoder and Live
        
        for (id key in aDict[@"live_2"])
        {
            NSDictionary * vidDict      = aDict[@"live_2"];
            NSDictionary * qualities    = [vidDict objectForKey:key];
            
            Feed * createdFeed = [[Feed alloc]initWithURLDict:qualities];
            createdFeed.sourceName = key;
            if (self.live){
                createdFeed.type = FEED_TYPE_LIVE;
            } else if (self.local) {
                createdFeed.type = FEED_TYPE_LOCAL;
            } else {
                createdFeed.type = FEED_TYPE_ENCODER;
            }
            _live = YES;
            [tempDict setObject:createdFeed forKey:key];
        }
    } else { // for old encoder
        Feed * theFeed;
        if (aDict[@"live"]) { // This is for backwards compatibility
            theFeed =  [[Feed alloc]initWithURLString:aDict[@"live"] quality:0];
            _live = YES;
        } else if (aDict[@"vid"]) {
            theFeed =  [[Feed alloc]initWithURLString:aDict[@"vid"]  quality:0];
        } else {
//            PXPLog(@"Event Warning: No Feeds on Encoder for Event");
//            PXPLog(@"   HID: %@",aDict[@"hid"]);
            return @{};
        }
       // [tempDict setObject:theFeed forKey:@"s1"];
        [tempDict setObject:theFeed forKey:@"onlySource"];
    }
    return [tempDict copy];
}


-(void)destroy
{

    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                @"name": self.name,
                                                                                @"hid": self.hid
                                                                                }];
    
    [self.parentEncoder issueCommand:DELETE_EVENT priority:10 timeoutInSec:5 tagData:dict timeStamp:GET_NOW_TIME];


}

// this rebuilds feeds this will add feeds that are missing from the event
-(void)buildFeeds
{
    NSMutableDictionary * temp = [NSMutableDictionary dictionaryWithDictionary:[self buildFeeds:_rawData isLive:_live isLocal:YES]];
    [temp addEntriesFromDictionary:_feeds];
    _feeds = [temp copy];
}

// this builds
-(void)build
{
    if (_isBuilt) { // If the event is already built then you want these methods to run anyway
        if (self.onComplete)self.onComplete();
        if([_delegate respondsToSelector:@selector(onEventBuildFinished:)]) {
            [_delegate onEventBuildFinished:self];
        }
        return;
    }

    NSMutableDictionary * requestData = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                        @"user"        : [UserCenter getInstance].userHID,
                                                                                        @"requesttime" : GET_NOW_TIME,
                                                                                        @"device"      : [[[UIDevice currentDevice] identifierForVendor]UUIDString],
                                                                                        @"event"       : (self.live)?LIVE_EVENT:self.name
                                                                                        }];
    
    [_parentEncoder issueCommand:EVENT_GET_TAGS priority:1 timeoutInSec:15 tagData:requestData timeStamp:[NSNumber numberWithDouble:CACurrentMediaTime()]];

}

-(void)setIsBuilt:(BOOL)isBuilt
{
    if (_isBuilt == isBuilt) return;
    _isBuilt = isBuilt;
    if (_isBuilt && self.onComplete){
        self.onComplete();
    }
    if([_delegate respondsToSelector:@selector(onEventBuildFinished:)]) {
        [_delegate onEventBuildFinished:self];
    }
    
}

-(BOOL)isBuilt
{
    return _isBuilt;
}


-(NSString*)description
{
    NSString * txt = [NSString stringWithFormat:@"Event Name: %@ \n Local: %@\n IsBuilt: %@ Live: %@", _name,(_local)?@"YES":@"NO",(_isBuilt)?@"YES":@"NO",(self.live)?@"YES":@"NO"];
    
    return txt;
}


@end

