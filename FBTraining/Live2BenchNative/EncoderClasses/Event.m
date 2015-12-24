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
@synthesize originalFeeds = _originalFeeds;
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

//Depricated
- (instancetype)initWithDict:(NSDictionary*)data  isLocal:(BOOL)isLocal andlocalPath:(NSString *)path
{
    self = [super init];
    if (self) {

        _open               = NO;
        _rawData            = [[NSMutableDictionary alloc]initWithDictionary:data];
        _live               = (_rawData[@"live"] || _rawData[@"live_2"])? YES:NO;
        _primary            = false;
        _name               = [_rawData objectForKey:@"name"];
        _hid                = [_rawData objectForKey:@"hid"];
        _eventType          = [_rawData objectForKey:@"sport"];
        _datapath           = [_rawData objectForKey:@"datapath"];
        _date               = [_rawData objectForKey:@"date"];
        _deleted            = [[_rawData objectForKey:@"deleted"]boolValue];
        _mp4s               = [self buildMP4s:_rawData];
        localPath           = path;
        _downloadedSources  = [NSMutableArray array]; // depricated
        _downloadingItemsDictionary = [[NSMutableDictionary alloc] init];
        
        
        _feeds              = [self buildFeeds:_rawData isLive:_live isLocal:isLocal];
        _originalFeeds      = [[self buildFeeds:_rawData isLive:_live isLocal:isLocal] copy];
        _tags               = [self buildTags:_rawData];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventDownloaded:) name:NOTIF_EVENT_DOWNLOADED object:nil];
    return self;
}


- (instancetype)initWithDict:(NSDictionary*)data localPath:(NSString *)path
{
    self = [super init];
    if (self) {
        
        _open               = NO;
        _rawData            = [[NSMutableDictionary alloc]initWithDictionary:data];
        _live               = (_rawData[@"live"] || _rawData[@"live_2"])? YES:NO;
        _primary            = false;
        _name               = [_rawData objectForKey:@"name"];
        _hid                = [_rawData objectForKey:@"hid"];
        _eventType          = [_rawData objectForKey:@"sport"];
        _datapath           = [_rawData objectForKey:@"datapath"];
        _date               = [_rawData objectForKey:@"date"];
        _deleted            = [[_rawData objectForKey:@"deleted"]boolValue];
        _mp4s               = [self buildMP4s:_rawData];
        localPath           = path;
        _downloadedSources  = [NSMutableArray array]; // depricated
        _downloadingItemsDictionary = [[NSMutableDictionary alloc] init];
        
        _feeds              = [self buildFeeds:_rawData isLive:_live isLocal:path != nil];
        _originalFeeds      = [[self buildFeeds:_rawData isLive:_live isLocal:path!= nil] copy];

        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventDownloaded:) name:NOTIF_EVENT_DOWNLOADED object:nil];
    return self;
}



-(void)openEvent
{
    if (!_open){
       _tags = [self buildTags:_rawData];
       _open = YES;
    }
}

-(void)closeEvent
{
    if (_open){
        _open = NO;
        
        NSMutableDictionary * tagToRaw = [NSMutableDictionary new];
        // convert tags to rawdata
        for (Tag* t in _tags) {
            tagToRaw[t.ID] = [t makeTagData];
        }
        _rawData[@"tags"]   = [tagToRaw copy];
        _tags               = nil;
    }
}




-(void)eventDownloaded:(NSNotification*)note
{
    NSArray *key = [self.downloadingItemsDictionary allKeysForObject:note.userInfo[@"Finish"]];
    if (key.count > 0) {
        [self.downloadingItemsDictionary removeObjectForKey:key[0]];
        [self.downloadedSources addObject:[(NSString *)key[0] lastPathComponent]];
    }

}



-(void)setPrimary:(BOOL)primary{
    _primary = primary;
}

-(void)addAllTags:(NSDictionary *)allTagData
{
    NSMutableArray *tagsReceived = [NSMutableArray array];
    
//     NSArray *tagArray = [allTagData allValues];
//     for (NSDictionary *newTagDic in tagArray) {
//         Tag *newTag = [[Tag alloc] initWithData: newTagDic event:self];
//         [_tags addObject:newTag];
//         [tagsReceived addObject:newTag];
//     }
    _rawData[@"tags"]   = [allTagData copy];
    
     self.isBuilt = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_TAG_RECEIVED
                                                        object:self
                                                      userInfo:@{
                                                                 @"tags": tagsReceived
                                                                 }];
    
}



-(void)addTag:(Tag *)newtag extraData:(BOOL)notifPost
{
    if ((newtag.type == TagTypeDeleted ) && newtag.type != TagTypeHockeyStrengthStop && newtag.type != TagTypeHockeyStopOLine && newtag.type != TagTypeHockeyStopDLine && newtag.type != TagTypeSoccerZoneStop) {
        return;
    }
    
    
    [_tags addObject:newtag];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_TAG_RECEIVED
                                                        object:self
                                                      userInfo:@{
                                                                 @"tags": @[newtag]
                                                                 }];
    
    if ((newtag.type == TagTypeCloseDuration
         || newtag.type == TagTypeTele
         || newtag.type == TagTypeNormal
//         || newtag.type == TagTypeHockeyStrengthStart
//         || newtag.type == TagTypeHockeyStartOLine
//         || newtag.type == TagTypeHockeyStopOLine
//         || newtag.type == TagTypeHockeyStartDLine
//         || newtag.type == TagTypeHockeyStopDLine
//         || newtag.type == TagTypeSoccerZoneStart
//         || newtag.type == TagTypeSoccerZoneStop
//         || newtag.type == TagTypeFootballDownTags
         )&& _primary && notifPost ) {
        
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
//    if (_tags != nil && _tags.count != 0) {
//        NSMutableDictionary * newRawData    = [[NSMutableDictionary alloc]initWithDictionary:_rawData];
//        NSMutableDictionary * tagsToBeAdded = [[NSMutableDictionary alloc]init];
//        
//        for (Tag *tag in _tags) {
//            [tagsToBeAdded setObject:[tag makeTagData] forKey:tag.ID];
//        }
//        
//        [newRawData setObject:tagsToBeAdded forKey:@"tags"];
//        return [newRawData copy];
//   }
//    
//    if ([_rawData objectForKey:@"tags"]) {
//        [_rawData removeObjectForKey:@"tags"];
//    }
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

-(NSMutableDictionary*)buildFeeds:(NSDictionary*)aDict isLive:(BOOL)isLive isLocal:(BOOL)isLocal
{
    NSString            * toypKey;//   = (isLive)?@"live_2":@"mp4_2"
    if (isLive) { // the Event is Live
        toypKey     = @"live_2";
    } else if (!isLive && isLocal) { // is not live event and its on the ipad
        toypKey     = @"mp4_2";
    } else if (!isLive && !isLocal) { // it is not live and not on the iPad but is sitting on the encoder
        toypKey     = @"vid_2";
    }
    
    
    NSMutableDictionary * tempDict  = [[NSMutableDictionary alloc]init];
    
    // this is a check for the new encoder vs the old
    if ([aDict[toypKey] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *vidDict = aDict[toypKey];
        NSArray *keys = [vidDict allKeys];
        //for (id key in aDict[toypKey])
        for (int i = 0; i < vidDict.count; i++)
        {
            Feed * createdFeed;
        
            // This picks out local to non local
            if (isLocal) {
                NSString *name = [NSString stringWithFormat:@"main_0%ihq.mp4",i];
                NSString *filePath = [[[localPath stringByAppendingPathComponent:@"events"] stringByAppendingPathComponent:self.name] stringByAppendingPathComponent:name];
                createdFeed = [[Feed alloc]initWithFileURL:filePath];
                createdFeed.type = FEED_TYPE_LOCAL;
            } else {
                NSDictionary * qualities    = [vidDict objectForKey:keys[i]];
                createdFeed = [[Feed alloc] initWithURLDict:qualities];
                createdFeed.type = (self.live)? FEED_TYPE_LIVE: FEED_TYPE_ENCODER;
            }

            // if feed is okay then add it to the array
            if (createdFeed != nil) {
                createdFeed.sourceName = keys[i];
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
            return [[NSMutableDictionary alloc]initWithDictionary:@{}];
        }
        //[tempDict setObject:theFeed forKey:@"s1"];
        if (theFeed != nil) {
            [tempDict setObject:theFeed forKey:@"onlySource"];
        }
    }
    
    return tempDict;
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


// IS THIS DEPRICATED????
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
    [temp addEntriesFromDictionary:_originalFeeds];
    _feeds = [temp copy];
    _originalFeeds = [temp copy];
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
    NSString * txt = [NSString stringWithFormat:@"Event Name: %@ \n Local: %@\n IsBuilt: %@ Live: %@ isDel:%@ open:%@",
                      _name,(_local)?@"YES":@"NO",
                      (_isBuilt)?@"YES":@"NO",
                      (self.live)?@"YES":@"NO",
                      self.deleted?@"YES":@"NO",
                      self.open?@"YES":@"NO"
                      ];
    
    return txt;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_EVENT_DOWNLOADED object:nil];
}

@end

