//
//  LocalEncoder.m
//  Live2BenchNative
//
//  Created by dev on 2014-11-13.
//  Copyright (c) 2014 DEV. All rights reserved.
//

/**
 *   This class will keep a reference to all the local stored videos and clips
 *   The data stored in the "bookmarks path" will be a collection of plist labeled by number e.g. 1.plist, 2.plist ...
 *   each plist will have reference to a clip that will be in the bookmakvideos.
 *
 *   The reason for this is that one book mark or clip can reference multiple videos (multicam) so its built to be extended
 */



#import "LocalEncoder.h"
#import "Feed.h"
#import "Downloader.h"


#define LOCAL_PLIST  @"EventsHid.plist"


@implementation LocalEncoder
{
    NSString        * _localDocsPListPath;
    NSString        * _localPath;
    NSMutableArray  * _bookmarkPlistNames;
    
    NSComparisonResult(^plistSort)(id obj1, id obj2);

    // new construction
    Event           * _myEvent;
    
    NSDictionary    * _myEvents; // Key by name;
    
    
}

@synthesize name            = _name;
@synthesize event           = _event;
@synthesize eventType       = _eventType;
@synthesize eventData       = _eventData;
@synthesize feeds           = _feeds;
@synthesize status          = _status;
@synthesize allEvents       = _allEvents;
@synthesize allEventData    = _allEventData;
@synthesize eventTagsDict   = _eventTagsDict;



@synthesize clipFeeds       = _clipFeeds;
//@synthesize clipFeedsDict   = _clipFeedsDict;

-(id)initWithDocsPath:(NSString*)aDocsPath
{
    self = [super init];
    if (self){
        
        // Build Local Encoder
        _name                            = @"Local Encoder";
        _localPath                      = aDocsPath;
        _localDocsPListPath             = [aDocsPath stringByAppendingPathComponent:LOCAL_PLIST];// if its not there make it
        _status                         = ENCODER_STATUS_LOCAL;
        _event                          = @"none";
        _allEventData                   = [[NSArray alloc]initWithContentsOfFile:_localDocsPListPath];
        _eventData                      = @{};
        _eventTagsDict                  = [[NSMutableDictionary alloc]init];
        _clipFeeds                      = [[NSMutableDictionary alloc]init];
        // new
        
        _myEvents                       = [[NSMutableDictionary alloc]init];
        
        // Build Bookmark Clip sections
        
        
        
        // this takes the plist files of the Events and adds them to _allEventData
        NSMutableArray  * tempPool      = [[NSMutableArray alloc]init];
        NSArray         * plistPaths    = [self grabAllFiles:[aDocsPath stringByAppendingPathComponent:@"events"] ext:@"plist"];
        for (NSString *pths in plistPaths) {
            [tempPool addObject:[[NSDictionary alloc]initWithContentsOfFile:pths]];
        }
        _allEventData                   = [tempPool copy];
        

        // This builds all the events from the _allEventData
        NSEnumerator    * enumerator    = [_allEventData objectEnumerator];
        id              value;
        while ((value = [enumerator nextObject])) {
            NSDictionary * dict = value;
            NSString * itemName = [dict objectForKey:@"name"];
            if (itemName) {
                [tempPool addObject:itemName];
                [_myEvents setValue:[[Event alloc]initWithDict:dict] forKey:itemName];// this is the new kind of build that events have their own feed
            }
        }
        
        // gets string names of all the events
        _allEvents                      = [tempPool copy];
        
        
        
        
        
        
        
        
        // this gets all the plists for the book marks
        NSMutableArray  * tempPoolClips      = [[NSMutableArray alloc]init];
        NSArray         * clipsPlistPaths    = [self grabAllFiles:[aDocsPath stringByAppendingPathComponent:@"bookmark"] ext:@"plist"];
        for (NSString *pthss in clipsPlistPaths) {
            [tempPoolClips addObject:[[NSDictionary alloc]initWithContentsOfFile:pthss]];
        }
      
        
        
        // This builds all the events from the _allEventData
        NSEnumerator    * enumerator2    = [tempPoolClips objectEnumerator];
        id              value2;
        
        
        // This builds the clips that
        while ((value2 = [enumerator2 nextObject])) {
            Feed * aFeed = [[Feed alloc]initWithURLString:@"" quality:0];
            aFeed.info = (NSDictionary*)value2;
            NSMutableDictionary * temp = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary*)value2];
            [temp addEntriesFromDictionary:@{@"feed":aFeed}];
            NSString * anId = [[temp objectForKey:@"id"]stringValue];
            [_clipFeeds setObject:temp forKey:anId];
           // [_clipFeedsDict  setObject:temp forKey:[temp objectForKey:@"id"]];
            
        }
        
        
        _bookmarkPlistNames             = [[NSMutableArray alloc]init];
        


        // build sorter block
        
        plistSort = ^(id obj1, id obj2) {
        
            NSString * fn1 = [((NSString*)obj1) componentsSeparatedByString: @"."][0];
            NSString * fn2 = [((NSString*)obj2) componentsSeparatedByString: @"."][0];
            
            int n1 = [fn1 integerValue];
            int n2 = [fn2 integerValue];
            if (n1 > n2) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            
            if (n1 < n2) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            
            return (NSComparisonResult)NSOrderedSame;
        };
        // End sorterblock
        
        
        // Observers
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myClipDataRequest:) name:NOTIF_REQUEST_MYCLIP_DATA object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myClipDeleteRequest:) name:@"NOTIF_DELETE_CLIPS" object:nil];
        
        
    }
    return self;
}




#pragma mark - EncoderProtocol

-(void)issueCommand:(NSString *)methodName priority:(int)priority timeoutInSec:(float)time tagData:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp
{
    
    
    if ([methodName isEqualToString: TEAMS_GET]) {
        [self teamsResponse:        tData];
    } else if ([methodName isEqualToString: MAKE_TAG]) {
        [self makeTagResponce:      tData];
    } else if ([methodName isEqualToString: MODIFY_TAG]) {
        [self modTagResponce:       tData];
    } else if ([methodName isEqualToString: EVENT_GET_TAGS]) {
     //   [self eventTagsGetResponce: tData eventNameKey:extra];
    }
    
    
}

-(void)clearQueueAndCurrent
{
    // this does nothing
}


#pragma mark - Responces

-(void)teamsResponse:(NSMutableDictionary *)data
{
    
    
    
//    NSDictionary    * results =[Utility JSONDatatoDict:data];
//    if(NSClassFromString(@"NSJSONSerialization"))
//    {
//        NSError *error = nil;
//        id object = [NSJSONSerialization
//                     JSONObjectWithData:data
//                     options:0
//                     error:&error];
//        
//        if([object isKindOfClass:[NSDictionary class]])
//        {
//            results     = object;
//            self.teams      = [results objectForKey:@"teams"];
//            self.playerData = [results objectForKey:@"teamsetup"];
//            self.league     = [results objectForKey:@"leagues"];
//        }
//    }
//    isTeamsGet = YES;
}

-(void)makeTagResponce:(NSMutableDictionary *)data
{
    
//    NSDictionary    * results;
//    if(NSClassFromString(@"NSJSONSerialization"))
//    {
//        NSError *error = nil;
//        id object = [NSJSONSerialization
//                     JSONObjectWithData:data
//                     options:0
//                     error:&error];
//        
//        if([object isKindOfClass:[NSDictionary class]])
//        {
//            results = object;
//            // add tag to its dic
//            if ([results objectForKey:@"id"]) {
//                
//                NSString * tagId = [[results objectForKey:@"id"]stringValue];
//                
//                [_eventTagsDict setObject:results forKey:tagId];
//                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_CLIPVIEW_TAG_RECEIVED object:nil userInfo:results];
//            }
//        }
//    }
    
}


-(void)modTagResponce:(NSMutableDictionary *)data
{
    
//    NSDictionary    * results;
//    if(NSClassFromString(@"NSJSONSerialization"))
//    {
//        NSError *error = nil;
//        id object = [NSJSONSerialization
//                     JSONObjectWithData:data
//                     options:0
//                     error:&error];
//        
//        if([object isKindOfClass:[NSDictionary class]])
//        {
//            results = object;
//            // add tag to its dic
//            if ([results objectForKey:@"id"]) {
//                
//                NSString * tagId = [[results objectForKey:@"id"]stringValue];
//                
//                [_eventTagsDict setObject:results forKey:tagId];
//                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_CLIPVIEW_TAG_RECEIVED object:nil userInfo:results];
//            }
//        }
//    }
    
}


#pragma mark - Event Download








-(void)myClipDataRequest: (NSNotification *)note{
    
}




-(NSString*)event
{
    return _myEvent.name;
}



-(void)setEvent:(NSString *)event
{
    // Is it the same event or the event is not on the encoder
    if ([event isEqualToString:_event]){
        return;
    }
    [self willChangeValueForKey:@"event"];
    
    _myEvent    = [_myEvents objectForKey:event];
    _event      = _myEvent.name;
    _feeds      = _myEvent.feeds;
    
    [self willChangeValueForKey:@"eventType"];
    _eventType  = _myEvent.eventType;
    [self didChangeValueForKey:@"eventType"];
    _event      =  event;
    [self didChangeValueForKey:@"event"];
    
    _eventData  = _myEvent.rawData;
    
    
//    
//    NSArray         * events = _allEventData;
//    for(NSDictionary* dict in events)
//    {
//        if([dict isKindOfClass:[NSDictionary class]]  && [dict[@"name"] isEqualToString: event])
//        {
//            self.eventData = dict;
//            
//            if ([dict[@"vid"] isKindOfClass:[NSString class]]) { // This is for backwards compatibility
//                
//                // _feeds = @{ @"s1":@{@"lq":dict[@"vid"]} };
//                // this creates a feed object from just a string with it  source named s1
//                Feed * theFeed =  [[Feed alloc]initWithURLString:dict[@"vid"] quality:0];
//                _feeds = @{ @"s1":theFeed};
//                
//            }  else if ([dict[@"vid"] isKindOfClass:[NSDictionary class]]){
//                NSMutableDictionary * collect = [[NSMutableDictionary alloc]init];
//                
//                for (id key in dict[@"vid"])
//                {
//                    if ([key isEqualToString:@"url"]) continue;
//                    NSDictionary * vidDict      = dict[@"vid"];
//                    NSDictionary * qualities    = [vidDict objectForKey:key];
//                    // This builds a Feed and adds it to the feed pool
//                    Feed * createdFeed = [[Feed alloc]initWithURLDict:qualities];
//                    createdFeed.sourceName = key;
//                    
//                  
//                    [collect setObject:createdFeed forKey:key];
//                }
//                
//                _feeds = [collect copy];
//                
//                
//            } else {
//                NSLog(@"JSON ERROR");
//            }
//            [self willChangeValueForKey:@"eventType"];
//            _eventType = [dict objectForKey:@"sport"];
//            [self didChangeValueForKey:@"eventType"];
//            break;
//        }
//    }
//    _event =  event;
//    [self didChangeValueForKey:@"event"];
    
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




-(NSString*)bookmarkPath
{
    return [NSString stringWithFormat:@"%@/bookmark",_localPath];
}

-(NSString*)bookmarkedVideosPath
{
    return [NSString stringWithFormat:@"%@/bookmark/bookmarkvideo",_localPath];
}


/**
 *  This get all the plists in the bookmark folder on the device
 *  the plists are labeled as such 1.plist, 2.plist, 3.plist...
 */
-(void)scanForBookmarks
{

    NSString * bookmarkPath = [NSString stringWithFormat:@"%@/bookmark",_localPath];
    NSArray* dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:bookmarkPath
                                                                        error:NULL];
    NSMutableArray *mp3Files = [[NSMutableArray alloc] init];
    [dirs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *filename = (NSString *)obj;

        
        if ([self myClipPlistNameCheck:filename]) {
           
            [_bookmarkPlistNames addObject:filename];
            [mp3Files addObject:[bookmarkPath stringByAppendingPathComponent:filename]];
            
        }
        
        
    }];


    
    
    _bookmarkPlistNames = [NSMutableArray arrayWithArray:[_bookmarkPlistNames sortedArrayUsingComparator: plistSort]];
    
//    _bookmarkPlistNames = @[@"0.plist",@"1.plist",@"2.plist",@"3.plist",@"4.plist",@"5.plist"];
    
//    int n = [self gap:_bookmarkPlistNames first:0 last:[_bookmarkPlistNames count]-1];
    
}

-(NSArray*)grabAllFiles:(NSString*)aPath ext:(NSString*)ext
{
    NSArray         * dirs      = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:aPath
                                                                        error:NULL];
    NSMutableArray  * files     = [[NSMutableArray alloc] init];
    
    [dirs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *filename      = (NSString *)obj;
        NSString *extension     = [[filename pathExtension] lowercaseString];
        
        if ([extension isEqualToString:ext]) {
            [files addObject:[aPath stringByAppendingPathComponent:filename]];
        }
    }];
    
    return [files copy];
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





#pragma mark - Bookmark Clip Methods


-(void)saveClip:(NSString*)aName withData:(NSDictionary*)tagData
{
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:tagData];
    
    // add local file name to the plist
    [dict addEntriesFromDictionary:@{@"fileNames": @[aName]}];
    
    
    // adds the clip to the rest of the feeds
    NSString * clipPath = [NSString stringWithFormat:@"%@/%@",[self bookmarkedVideosPath],aName];
    Feed     * myFeed   = [[Feed alloc]initWithURLString:clipPath quality:0];
    [_clipFeeds setValue:myFeed forKey:aName];
    
    [self scanForBookmarks];
    // writes the plist to the harddrive
    int nextGap = [self gap:_bookmarkPlistNames first:0 last:[_bookmarkPlistNames count]-1];
    // write the plist
    NSString * bookmarkPath = [NSString stringWithFormat:@"%@/bookmark/%d.plist",_localPath,nextGap];
    

    
    
    // give the plist a reference to is self. This is so when the Plist is a dict I can find and delete it self
    [dict addEntriesFromDictionary:@{@"plistName": [NSString stringWithFormat:@"%d.plist",nextGap] }];
    // adds the plist to the list of clips
    [dict writeToFile:bookmarkPath atomically:YES];
    
    [_eventTagsDict setObject:dict forKey:aName];
}


-(void)myClipDeleteRequest:(NSNotification*)note
{

    [self deleteClip:    [note.userInfo objectForKey:@"id"]];
}


-(void)deleteClip:(NSString*)aId
{
    
    NSDictionary * clipDict = [_clipFeeds objectForKey:aId];
    
    NSError  * error        = nil;
    NSString * plistPath    = [NSString stringWithFormat:@"%@/%@",[self bookmarkPath],[clipDict objectForKey:@"plistName"]];
    NSString * videoPath    = [NSString stringWithFormat:@"%@/%@",[self bookmarkedVideosPath],[clipDict objectForKey:@"fileNames"][0]];
    NSString * clipID       = [NSString stringWithFormat:@"%@",[clipDict objectForKey:@"id"]];
    [[NSFileManager defaultManager] removeItemAtPath:videoPath error:&error];
    [[NSFileManager defaultManager] removeItemAtPath:plistPath error:&error];
    [_clipFeeds removeObjectForKey:clipID];

    // sort list on delete
    _bookmarkPlistNames = [NSMutableArray arrayWithArray:[_bookmarkPlistNames sortedArrayUsingComparator: plistSort]];
}


-(void)saveEvent:(Event*)aEvent
{


}



/**
 *  This deletes the event from the device
 *
 *  @param aHid <#aHid description#>
 */
-(void)deleteEvent:(NSString*)aHid
{
//    NSDictionary * clipDict = [_clipFeeds objectForKey:aId];
//    
//    NSError  * error        = nil;
//    NSString * plistPath    = [NSString stringWithFormat:@"%@/%@",[self bookmarkPath],[clipDict objectForKey:@"plistName"]];
//    NSString * videoPath    = [NSString stringWithFormat:@"%@/%@",[self bookmarkedVideosPath],[clipDict objectForKey:@"fileNames"][0]];
//    NSString * clipID       = [NSString stringWithFormat:@"%@",[clipDict objectForKey:@"id"]];
//    [[NSFileManager defaultManager] removeItemAtPath:videoPath error:&error];
//    [[NSFileManager defaultManager] removeItemAtPath:plistPath error:&error];
//    [_clipFeeds removeObjectForKey:clipID];
//    
//    // sort list on delete
//    _bookmarkPlistNames = [NSMutableArray arrayWithArray:[_bookmarkPlistNames sortedArrayUsingComparator: plistSort]];

}




-(int)gap:(NSArray*)list first:(int)first last:(int)last
{
    // if there is nothing in the list
    if ([list count] <1){
        return 0;
    }
    
    if (first >= last){
        if(first >= [list[first] intValue]){
            return last+1;
        }
        return last;
    }
    int med =  (last+first)>>1;//(int)((last+first)*.5);//
    if(med < [list[med]intValue]){
        return [self gap:list first:first last:med];
    }
    return [self gap:list first:med+1 last:last];
    
}

-(BOOL)myClipPlistNameCheck:(NSString*)check
{
    // Regx
    //    NSRange   searchedRange     = NSMakeRange(0, [check length]);
    //    NSString *pattern           = @".*\\.plist";//@"(?:www\\.)?((?!-)[a-zA-Z0-9-]{2,63}(?<!-))\\.?((?:[a-zA-Z0-9]{2,})?(?:\\.[a-zA-Z0-9]{2,})?)";
    //    NSError  *error             = nil;
    //    NSRegularExpression* regex  = [NSRegularExpression regularExpressionWithPattern: pattern options:0 error:&error];
    //    NSArray* matches            = [regex matchesInString:check options:0 range: searchedRange];
    //
    //    // name split
    //
    ////    NSArray *lines = [filename componentsSeparatedByString: @"."];
    ////    NSString *lineOne = lines[0];
    //
    //    NSString *extension = [[check pathExtension] lowercaseString];
    //
    NSRange range = [check rangeOfString:@"[0-9]+\\.plist" options:NSRegularExpressionSearch];
    return range.location != NSNotFound;
}




//debugging
#pragma mark - debugging

// This will show name and status
// This will show name and status
-(NSString*)description
{
    NSString * bookmarkPath = [NSString stringWithFormat:@"%@/bookmark",_localPath];
    NSString * txt = [NSString stringWithFormat:@" %@: %d - %@   - %@\nBookmark Path:%@",self.name,self.status,self.event,self.eventType,  bookmarkPath ];
    return txt;
}


-(NSString*)name
{
    return _name;
}

-(void)setName:(NSString *)name
{
    [self willChangeValueForKey:@"name"];
    _name = name;
    [self didChangeValueForKey:@"name"];
}


@end
