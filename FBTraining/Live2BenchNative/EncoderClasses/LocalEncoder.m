//
//  LocalEncoder.m
//  Live2BenchNative
//
//  Created by dev on 2014-11-13.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "LocalEncoder.h"
#import "Feed.h"
#import "Downloader.h"

#define LOCAL_PLIST  @"EventsHid.plist"


@implementation LocalEncoder
{
    NSString        * _localDocsPListPath;
    NSString        * _localPath;
    NSMutableArray  * _bookmarkPlistNames;
}

@synthesize name;
@synthesize event           = _event;
@synthesize eventType       = _eventType;
@synthesize eventData       = _eventData;
@synthesize feeds           = _feeds;
@synthesize status          = _status;
@synthesize allEvents       = _allEvents;
@synthesize allEventData      = _allEventData;
@synthesize eventTagsDict   = _eventTagsDict;

@synthesize clipFeeds       = _clipFeeds;

-(id)initWithDocsPath:(NSString*)aDocsPath
{
    self = [super init];
    if (self){
        name                            = @"Local Encoder";
        _localPath                      = aDocsPath;
        _localDocsPListPath             = [aDocsPath stringByAppendingPathComponent:LOCAL_PLIST];
        _status                         = ENCODER_STATUS_LOCAL;
        _event                          = @"none";
        _allEventData                   = [[NSArray alloc]initWithContentsOfFile:_localDocsPListPath];
        _eventData                      = @{};
        _eventTagsDict                  = [[NSMutableDictionary alloc]init];
        _clipFeeds                      = [[NSMutableDictionary alloc]init];
        NSMutableArray  * tempPool      = [[NSMutableArray alloc]init];
        NSEnumerator *enumerator        = [_allEventData objectEnumerator];
        id value;
        
        while ((value = [enumerator nextObject])) {
            NSDictionary * dict = value;
            if ([dict objectForKey:@"name"]) {
                [tempPool addObject:[dict objectForKey:@"name"]];
            }
        }
        
        
        _allEvents                      = [tempPool copy];
        Feed * test                     = [[Feed alloc]initWithURLString:@"http://192.168.3.100/events/2014-11-13_16-21-16_dff4c99c75cf73a4b374a693f919244648f5aa31_local/video/list.m3u8" quality:0];
        _feeds                          = @{
                                            @"t1":test
                                            };
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myClipDataRequest:) name:NOTIF_REQUEST_MYCLIP_DATA object:nil];
        
        
        
        
        [self buildEncoderRequest];
        
    }
    return self;
}

-(void)myClipDataRequest: (NSNotification *)note{
    
}

-(void)issueCommand:(NSString *)methodName priority:(int)priority timeoutInSec:(float)time tagData:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp
{
}


-(void)buildEncoderRequest
{
    //_allEvents = [[NSArray alloc]initWithContentsOfFile:_localDocsPListPath];
  //  _allEventData
    
    [self scanPath];
}


/**
 *   This gets all the videos and clips in the bookmarks folder of the device and adds them to dict based off video name key
 */
-(void)buildAllFeeds
{

//    
//    for (int i = ; i< list count ; i++) {
//        Feed * localFeed = [[Feed alloc]initWithURLString:@"http://192.168.3.100/events/2014-11-13_16-21-16_dff4c99c75cf73a4b374a693f919244648f5aa31_local/video/list.m3u8" quality:0];
//        [_clipFeeds setValue:localFeed forKey:@""];
//    }
//    
//    
    
}


-(void)setEvent:(NSString *)event
{
    // Is it the same event or the event is not on the encoder
    if ([event isEqualToString:_event]){
        return;
    }
    
    
    
    
    [self willChangeValueForKey:@"event"];
    
    
    
    NSArray         * events = _allEventData;
    for(NSDictionary* dict in events)
    {
        if([dict isKindOfClass:[NSDictionary class]]  && [dict[@"name"] isEqualToString: event])
        {
            self.eventData = dict;
            
            if ([dict[@"vid"] isKindOfClass:[NSString class]]) { // This is for backwards compatibility
                
                // _feeds = @{ @"s1":@{@"lq":dict[@"vid"]} };
                // this creates a feed object from just a string with it  source named s1
                Feed * theFeed =  [[Feed alloc]initWithURLString:dict[@"vid"] quality:0];
                _feeds = @{ @"s1":theFeed};
                
            }  else if ([dict[@"vid"] isKindOfClass:[NSDictionary class]]){
                NSMutableDictionary * collect = [[NSMutableDictionary alloc]init];
                
                for (id key in dict[@"vid"])
                {
                    if ([key isEqualToString:@"url"]) continue;
                    NSDictionary * vidDict      = dict[@"vid"];
                    NSDictionary * qualities    = [vidDict objectForKey:key];
                    // This builds a Feed and adds it to the feed pool
                    Feed * createdFeed = [[Feed alloc]initWithURLDict:qualities];
                    createdFeed.sourceName = key;
                    
                  
                    [collect setObject:createdFeed forKey:key];
                }
                
                _feeds = [collect copy];
                
                
            } else {
                NSLog(@"JSON ERROR");
            }
            [self willChangeValueForKey:@"eventType"];
            _eventType = [dict objectForKey:@"sport"];
            [self didChangeValueForKey:@"eventType"];
            break;
        }
    }
    _event =  event;
    [self didChangeValueForKey:@"event"];
    
}



-(NSString*)event
{
    return _event;
}


/**
 *  This class is what buils the rest of the data from the encoder
 *
 *
 *  @param data
 */
-(void)getAllEventsResponse:(NSData *)data
{

}

// This will show name and status
-(NSString*)description
{
    NSString * txt = [NSString stringWithFormat:@" %@: %d - %@   - %@",self.name,self.status,self.event,self.eventType  ];
    return txt;
}


-(void)downloadToClip:(NSString*)clip
{


}


-(NSString*)bookmarkPath
{

    return [NSString stringWithFormat:@"%@/bookmark",_localPath];
}

-(void)scanPath
{

    NSString * bookmarkPath = [NSString stringWithFormat:@"%@/bookmark",_localPath];
    NSArray* dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:bookmarkPath
                                                                        error:NULL];
    NSMutableArray *mp3Files = [[NSMutableArray alloc] init];
    [dirs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *filename = (NSString *)obj;
        NSString *extension = [[filename pathExtension] lowercaseString];
        if ([extension isEqualToString:@"plist"]) {
            [_bookmarkPlistNames addObject:filename];
            [mp3Files addObject:[bookmarkPath stringByAppendingPathComponent:filename]];
        }
    }];


}

-(int)gap:(NSArray*)list first:(int)first last:(int)last
{
    
    if ([list count] <1){
        return 0;
    }

    if (first >= last){
        if(first >= list[first]){
            return last+1;
        }
        return last;
    }
    int med =  (last+first)>>1;
    if(med < list[med]){
        return [self gap:list first:med+1 last:last];
    }
    return [self gap:list first:med+1 last:last];
    
}

/**
 *  This will check the bookmark folder on the device and give a number that will be used for the name of the video that will be used
 *
 *  @return n
 */
-(NSInteger)getBookmarkSpace
{
    return 0;
}


-(void)deleteClip:(NSString*)name
{


}




@end
