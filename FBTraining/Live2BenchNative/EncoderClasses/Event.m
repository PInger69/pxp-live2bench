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

@synthesize downloadedSources       = _downloadedSources;
@synthesize parentEncoder           = _parentEncoder;


- (instancetype)initWithDict:(NSDictionary*)data  isLocal:(BOOL)isLocal andlocalPath:(NSString *)path
{
    self = [super init];
    if (self) {
        NSMutableDictionary *dataFinal = [[NSMutableDictionary alloc]initWithDictionary:data];
        _rawData            = dataFinal;
        _live               = (_rawData[@"live"] || _rawData[@"live_2"])? YES:NO;
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
        _downloadedSources  = [NSMutableArray array];
        _downloadingItemsDictionary = [[NSMutableDictionary alloc] init];
        _tags               = [self buildTags:_rawData];
        //_downloadedSources  = @[];
    }
    [[NSNotificationCenter defaultCenter] addObserverForName:@"NOTIF_EVENT_DOWNLOADED" object:nil queue:nil usingBlock:^(NSNotification *note){
        NSArray *key = [self.downloadingItemsDictionary allKeysForObject:note.userInfo[@"Finish"]];
        if (key.count > 0) {
            [self.downloadingItemsDictionary removeObjectForKey:key[0]];
            [self.downloadedSources addObject:[(NSString *)key[0] lastPathComponent]];
        }
    }];
    return self;
}

-(void)setTags:(NSMutableDictionary *)tags
{
    _tags = tags;
}


-(NSDictionary*)rawData
{
    if (_tags != nil && _tags.count != 0) {
        NSMutableDictionary *newRawData = [[NSMutableDictionary alloc]initWithDictionary:_rawData];
        
        
        NSMutableDictionary * tagsToBeAdded = [[NSMutableDictionary alloc]init];
        /*NSArray * keys = [_tags allKeys];
        for (NSString * key in keys) {
            Tag * newTag = [[Tag alloc]initWithData:[_tags objectForKey:key]];
            [tagsToBeAdded setObject:newTag.rawData forKey:key];
        }*/
        
        NSArray *tagInArray = [_tags allValues];
        
        for (Tag *tag in tagInArray) {
            [tagsToBeAdded setObject:[tag makeTagData] forKey:tag.ID];
        }
        
        [newRawData setObject:tagsToBeAdded forKey:@"tags"];
        return [newRawData copy];
   }
    return _rawData;
 
}


-(void)setDownloadedSources:(NSMutableArray *)downloadedSources{
    _downloadedSources = downloadedSources;
}


-(NSMutableDictionary *)buildTags:(NSDictionary*)aDict{
    
    if (aDict[@"tags"]) {
        NSDictionary *tagToBeAdded = aDict[@"tags"];
        NSArray *tagArray = [tagToBeAdded allValues];
        NSMutableDictionary *tagsDic = [[NSMutableDictionary alloc]init];
        
        
        for (NSDictionary *tagDic in tagArray) {
            [tagsDic setObject:tagDic forKey:tagDic[@"id"]];
        }
    }

    NSMutableDictionary *tagDict = [[NSMutableDictionary alloc]init];
        return tagDict;
}

-(NSDictionary*)buildMP4s:(NSDictionary*)aDict
{
    NSMutableDictionary * tempDict = [[NSMutableDictionary alloc]init];
    
    if ([aDict objectForKey:@"mp4_2"]) {
        tempDict = [aDict objectForKey:@"mp4_2"];
    } else if ([aDict objectForKey:@"mp4"]) {
        [tempDict setObject:[aDict objectForKey:@"mp4"] forKey:@"s_00"];
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
        
        for (id key in aDict[toypKey])
        {
            NSDictionary * vidDict      = aDict[toypKey];
            NSDictionary * qualities    = [vidDict objectForKey:key];
            NSString *filePath = [[[localPath stringByAppendingPathComponent:@"events"] stringByAppendingPathComponent:self.name] stringByAppendingPathComponent:@"main_00hq.mp4"];
            
            Feed * createdFeed = (isLocal)? [[Feed alloc]initWithFileURL:filePath] : [[Feed alloc] initWithURLDict:qualities];
            
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
        
    } else { // old encoder
        Feed * theFeed;
        if (aDict[@"live"]) { // This is for backwards compatibility
            theFeed =  [[Feed alloc]initWithURLString:aDict[@"live"] quality:0];
            _live = YES;
        } else if (aDict[@"vid"] || aDict[@"mp4"]) {
            theFeed = (isLocal)? [[Feed alloc]initWithFileURL:aDict[@"mp4"]] :  [[Feed alloc]initWithURLString:aDict[@"vid"]  quality:0]  ;
        } else {
            PXPLog(@"Event Warning: No Feeds on Encoder for Event");
            PXPLog(@"   HID: %@",aDict[@"hid"]);
            return @{};
        }
        [tempDict setObject:theFeed forKey:@"s1"];
    }
    
    return [tempDict copy];
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
            PXPLog(@"Event Warning: No Feeds on Encoder for Event");
            PXPLog(@"   HID: %@",aDict[@"hid"]);
            return @{};
        }
        [tempDict setObject:theFeed forKey:@"s1"];
    }
    return [tempDict copy];
}

-(NSString*)description
{
    NSString * txt = [NSString stringWithFormat:@"Event Name: %@ \nLocal: %@\n", _name,(_local)?@"YES":@"NO"];
    
    return txt;
}


@end

