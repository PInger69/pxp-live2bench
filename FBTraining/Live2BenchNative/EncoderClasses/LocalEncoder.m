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
#define VIDEO_EXT    @"mp4"

@implementation LocalEncoder
{
    NSString        * _localDocsPListPath;
    NSString        * _localPath;
    NSMutableArray  * _bookmarkPlistNames;
    
    NSComparisonResult(^plistSort)(id obj1, id obj2);

    // new construction
    NSMutableDictionary * _bookmarkPlistById;
    
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
        
        _bookmarkPlistById              = [[NSMutableDictionary alloc]init];
        _myEvents                       = [[NSMutableDictionary alloc]init];
        
        // Build Bookmark Clip sections
        [self scanForBookmarks];
        
        
        // this takes the plist files of the Events and adds them to _allEventData
        NSMutableArray  * tempPool      = [[NSMutableArray alloc]init];
        NSArray         * plistPaths    = [self grabAllFiles:[_localPath stringByAppendingPathComponent:@"events"] ext:@"plist"];
        for (NSString *pths in plistPaths) {
            [tempPool addObject:[[NSDictionary alloc]initWithContentsOfFile:pths]];
        }
        _allEventData                   = [tempPool copy];
        

        // This builds all the events from the _allEventData
        // and then checks if the videos are downloaded for each source and added to the Event
        NSEnumerator    * enumerator    = [_allEventData objectEnumerator];
        id              value;
        while ((value = [enumerator nextObject])) {
            NSDictionary * dict = value;
            NSString * itemName = [dict objectForKey:@"name"];
            if (itemName) {
                [tempPool addObject:itemName];
                Event * anEvent = [[Event alloc]initWithDict:dict];
                anEvent.local   = YES;
                anEvent.downloadedSources = [self listDownloadSourcesFor:anEvent];
                [_myEvents setValue:anEvent forKey:itemName];// this is the new kind of build that events have their own feed
            }
        }
        
        // gets string names of all the events
        _allEvents                      = [tempPool copy];
        
        
        
        
        
        
        
        
        // this gets all the plists for the book marks
        NSMutableArray  * tempPoolClips      = [[NSMutableArray alloc]init];
        NSArray         * clipsPlistPaths    = [self grabAllFiles:[aDocsPath stringByAppendingPathComponent:@"bookmark"] ext:@"plist"];
//        for (NSString *pthss in clipsPlistPaths) {
//            [tempPoolClips addObject:[[NSDictionary alloc]initWithContentsOfFile:pthss]];
//        }
      
        
        
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
//                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_TAG_RECEIVED object:nil userInfo:results];
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
//                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_TAG_RECEIVED object:nil userInfo:results];
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
            
            
            NSDictionary * dict = [NSDictionary dictionaryWithContentsOfFile:[bookmarkPath stringByAppendingPathComponent:filename]];
            
            NSString * aID = dict[@"id"];
            [_bookmarkPlistById setObject:dict forKey:aID];
        }
        
        
    }];


    
    
    _bookmarkPlistNames = [NSMutableArray arrayWithArray:[_bookmarkPlistNames sortedArrayUsingComparator: plistSort]];
    
    
}

/**
 *  Grabs all files from a directory with and extention 
 *  will create a directory if its not there
 *
 *  @param aPath <#aPath description#>
 *  @param ext   <#ext description#>
 *
 *  @return <#return value description#>
 */
-(NSArray*)grabAllFiles:(NSString*)aPath ext:(NSString*)ext
{
    
//    if ( ![[NSFileManager defaultManager] fileExistsAtPath:aPath isDirectory:YES]){
//        [[NSFileManager defaultManager] createDirectoryAtPath:aPath withIntermediateDirectories:YES attributes:nil error:NULL];
//        return @[];
//    }
    
    
    NSArray         * dirs      = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:aPath error:NULL];
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


-(Event*)getEventByName:(NSString*)eventName
{
    return _myEvents[eventName];
}

-(Event*)getEventByHID:(NSString*)eventHID
{
    NSPredicate *pred = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        
        NSString * thisHID = [evaluatedObject objectForKey:@"hid"];
        
        return [thisHID isEqualToString:eventHID];
    }];
    
    
    //   NSPredicate *pred2 =  [pred predicateWithSubstitutionVariables:@{@"asdlfkj":@"poop"}];
    
    
    NSArray * filtered = [NSArray arrayWithArray:[[self allEventData] filteredArrayUsingPredicate:pred ]];
    
    if ([filtered count]==0)return nil;
    
    NSString * eventName = filtered[0][@"name"];
   
    
    return _myEvents[eventName];
}


/**
 *  This saves the lip
 *
 *  @param aName   !!! This name has to change
 *  @param tagData the data for the raw clip
 */
-(void)saveClip:(NSString*)aName withData:(NSDictionary*)tagData
{
    
    NSString            * clipID        = tagData[@"id"];
    NSMutableDictionary * mutableDict   = [NSMutableDictionary dictionaryWithDictionary:tagData];
    NSString            * bookmarkPlistPath;
    
    if ([_bookmarkPlistById objectForKey:clipID]) { // if there is a plist there already then just mod the data
        mutableDict                 = [_bookmarkPlistById objectForKey:clipID];
        NSMutableArray * list       = [NSMutableArray arrayWithArray:mutableDict[@"fileNames"]];
        [list addObject:aName];
        mutableDict[@"fileNames"]   = list;
        NSString * plistFileName    = mutableDict[@"plistName"];
        bookmarkPlistPath = [NSString stringWithFormat:@"%@/bookmark/%@",_localPath,plistFileName];
    
    } else { // there is no plist for this clip... make a new plist
        [mutableDict addEntriesFromDictionary:@{@"fileNames": @[aName]}];
        [self scanForBookmarks];
        int nextGap = [self gap:_bookmarkPlistNames first:0 last:[_bookmarkPlistNames count]-1];
        bookmarkPlistPath = [NSString stringWithFormat:@"%@/bookmark/%d.plist",_localPath,nextGap];
    }
    
    // make bookmarkvideo path if not there
    BOOL isDir = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:[self bookmarkedVideosPath] isDirectory:&isDir];
    
    if ( !isDir){
        [[NSFileManager defaultManager] createDirectoryAtPath:[self bookmarkedVideosPath] withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    NSString * clipPath = [NSString stringWithFormat:@"%@/%@",[self bookmarkedVideosPath],aName]; // is this right
    
    
    // adds the clip to the rest of the clip feeds
    
    Feed     * myFeed   = [[Feed alloc]initWithURLString:clipPath quality:0];
    [_clipFeeds setValue:myFeed forKey:aName];
    

    [mutableDict addEntriesFromDictionary:@{@"plistName": [bookmarkPlistPath lastPathComponent] }];
    [mutableDict writeToFile:bookmarkPlistPath atomically:YES];
    
    [_eventTagsDict setObject:mutableDict forKey:aName];
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


/**
 *  This saves sent Events by taking the raw data and then making a dir to store the videos and then writes the plist
 *
 *  @param aEvent Event to Save as plist
 *
 *  @return returns path of folder to save the videos
 */
-(NSString*)saveEvent:(Event*)aEvent
{
    // This gets the path and makes a DIR if its not there
    NSString * aPath = [[_localPath stringByAppendingPathComponent:@"events"] stringByAppendingPathComponent:aEvent.datapath];
    BOOL isDir = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:aPath isDirectory:&isDir];

    
    if ( !isDir){
        [[NSFileManager defaultManager] createDirectoryAtPath:aPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    NSString * plistNamePath = [[[_localPath stringByAppendingPathComponent:@"events"] stringByAppendingPathComponent:aEvent.datapath]stringByAppendingPathExtension:@"plist"];
    [aEvent.rawData writeToFile:plistNamePath atomically:YES];
    
    // make an instance of event in local
    Event * anEvent = [[Event alloc]initWithDict:aEvent.rawData];
    anEvent.local   = YES;
    anEvent.downloadedSources = [self listDownloadSourcesFor:anEvent];
    [_myEvents setValue:anEvent forKey:anEvent.name];// this is the new kind of build that events have their own feed
    
    return aPath;
}



/**
 *  This deletes the event from the device
 *
 *  @param aEvent the event you want to delete from the device
 */
-(void)deleteEvent:(Event*)aEvent
{
    
    if (aEvent == nil || !aEvent.local) {
        NSLog(@"CAN NOT DELETE NON LOCAL EVENTS");
        return;
    }
    
    NSString * aPath = [[_localPath stringByAppendingPathComponent:@"events"] stringByAppendingPathComponent:aEvent.datapath];


    [[NSFileManager defaultManager] removeItemAtPath:aPath error:NULL]; // deletes the folder
    [[NSFileManager defaultManager] removeItemAtPath: [aPath stringByAppendingPathExtension:@"plist"] error:NULL]; // delets the plist
    
    NSMutableDictionary * temp = [NSMutableDictionary dictionaryWithDictionary:_myEvents];
    [temp removeObjectForKey:aEvent.name];
    _myEvents = [temp copy];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_UPDATE_MEMORY object:nil];
    
    // This is run when the current playing event is deleted
    if (_myEvent == aEvent){
        _myEvent = nil;
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_CURRENT_LOCAL_EVENT_DELETED object:nil];
    }
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


-(NSArray*)listDownloadSourcesFor:(Event*)aEvent
{
    NSString        * thePath       = [[_localPath stringByAppendingPathComponent:@"events"]stringByAppendingPathComponent:aEvent.datapath];
    
    NSArray         * allFiles      = [self grabAllFiles:thePath ext:VIDEO_EXT];
    NSMutableArray  * collection    = [[NSMutableArray alloc]init];
    
    for (NSString * dlFileNames in allFiles) {
        [collection addObject:[dlFileNames lastPathComponent]];
    }
    return [collection copy];
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
