
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


#import "EncoderManager.h"
#import "LocalEncoder.h"
#import "Feed.h"
#import "Downloader.h"
#import "Event.h"
#import "Clip.h"
#import "Tag.h"




#define LOCAL_PLIST  @"EventsHid.plist"
#define VIDEO_EXT    @"mp4"

#define TAG_SYNC        1
#define TAG_UPLOAD      2

// PRIVATE CLASS
@interface NSURLDataConnection : NSURLConnection
@property (strong, nonatomic) NSMutableData *cumulatedData;
@property (assign, nonatomic) int context;
@end
@implementation NSURLDataConnection
@end

@implementation LocalEncoder
{
    NSString        * _localDocsPListPath;
    //NSString        * _localPath;
    NSMutableArray  * _bookmarkPlistNames;
    NSComparisonResult(^plistSort)(id obj1, id obj2);
    NSMutableArray  * tagSyncConnections;
    //NSURLDataConnection *tagSyncConnection;
    NSURLDataConnection *encoderConnection;
}

@synthesize name            = _name;
@synthesize event           = _event;
@synthesize status          = _status;
@synthesize allEvents       = _allEvents;
@synthesize clips           = _clips;

-(id)initWithDocsPath:(NSString*)aDocsPath
{
    self = [super init];
    if (self){
        
        // Build Local Encoder
        _name                           = @"Local Encoder";
        _localPath                      = aDocsPath;
        _localDocsPListPath             = [aDocsPath stringByAppendingPathComponent:LOCAL_PLIST];// if its not there make it
        _status                         = ENCODER_STATUS_LOCAL;
        _event                          = nil;
        _clips                          = [[NSMutableDictionary alloc]init];
        _allEvents                      = [[NSMutableDictionary alloc] init];
        _localTags                      = [[NSMutableArray alloc] init];
        tagSyncConnections              = [NSMutableArray array];
        
        // build folder structue if not there
        
        BOOL isDir = NO;
        
        [[NSFileManager defaultManager] fileExistsAtPath:[self bookmarkPath] isDirectory:&isDir];
        
        if ( !isDir){
            [[NSFileManager defaultManager] createDirectoryAtPath:[self bookmarkPath] withIntermediateDirectories:YES attributes:nil error:NULL];

        }
        
        BOOL isDir2 = NO;
        [[NSFileManager defaultManager] fileExistsAtPath:[self bookmarkedVideosPath] isDirectory:&isDir2];
        
        if ( !isDir2){
            [[NSFileManager defaultManager] createDirectoryAtPath:[self bookmarkedVideosPath] withIntermediateDirectories:YES attributes:nil error:NULL];
        }
        
        
        
        // Build Bookmark Clip sections
        [self scanForBookmarks];
        
        
        // this takes the plist files of the Events and adds them to _allEventData
        NSMutableArray  * tempPool      = [[NSMutableArray alloc]init];
        NSArray         * plistPaths    = [self grabAllFiles:[_localPath stringByAppendingPathComponent:@"events"] ext:@"plist"];
        for (NSString *pths in plistPaths) {
            [tempPool addObject:[[NSDictionary alloc]initWithContentsOfFile:pths]];
        }
        
        
        
        // and then checks if the videos are downloaded for each source and added to the Event
        NSEnumerator    * enumerator    = [tempPool objectEnumerator];
        id              value;
        while ((value = [enumerator nextObject])) {
            NSDictionary * dict = value;
            NSString * itemHid = [dict objectForKey:@"hid"];
            if (itemHid) {
                Event * anEvent = [[Event alloc]initWithDict:dict isLocal:YES andlocalPath:self.localPath];
                anEvent.parentEncoder       = self;
                anEvent.local               = YES;
                anEvent.downloadedSources   = [[self listDownloadSourcesFor:anEvent] mutableCopy];
                [_allEvents setValue:anEvent forKey:itemHid];// this is the new kind of build that events have their own feed
                
                [self.localTags addObjectsFromArray: [anEvent.localTags allValues]];
            }
        }
        
        
        
        
        
        /**
         Book mark Section!!!
         */
        
        // this gets all the plists for the book marks
        NSMutableArray  * tempPoolClips      = [[NSMutableArray alloc]init];
        NSArray         * clipsPlistPaths    = [self grabAllFiles:[aDocsPath stringByAppendingPathComponent:@"bookmark"] ext:@"plist"];

        // build the clips by sending the plist paths in
        
        for (NSString *pthss in clipsPlistPaths) {
            NSDictionary *theDict = [[NSDictionary alloc]initWithContentsOfFile:pthss] ;
            if (theDict) {
                Clip * clip =[[Clip alloc]initWithDict: theDict];
                clip.path = pthss;
                [_clips setObject:clip forKey:clip.globalID];
            }
            
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
            [_clips setObject:temp forKey:anId];
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myClipDataRequest:)   name:NOTIF_REQUEST_MYCLIP_DATA object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myClipDeleteRequest:) name:NOTIF_DELETE_CLIPS object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:@"NOTIF_DELETE_EVENT" object:nil queue:nil usingBlock:^(NSNotification *note){
            Event *localCounterpart = [self getEventByName:((Event *)note.userInfo[@"Event"]).name];
            if (localCounterpart) {
                [self deleteEvent:localCounterpart];
            }
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:NOTIF_REQUEST_CLIPS object:nil queue:nil usingBlock:^(NSNotification *note){
            void(^blockName)(NSArray *clips) = note.object;
            blockName([self.clips allValues]);
        }];
        
        
        [self checkLocalTags];
    }
    return self;
}




#pragma mark - EncoderProtocol

-(void)issueCommand:(NSString *)methodName priority:(int)priority timeoutInSec:(float)time tagData:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp
{
    
    
    if ([methodName isEqualToString: TEAMS_GET]) {
        [self teamsResponse:        tData];
    } else if ([methodName isEqualToString: MAKE_TAG]) {
        [self makeTag: tData timeStamp: aTimeStamp];
    } else if ([methodName isEqualToString: MODIFY_TAG]) {
        [self modTagResponce:       tData];
    } else if ([methodName isEqualToString: EVENT_GET_TAGS]) {
     //   [self eventTagsGetResponce: tData eventNameKey:extra];
    }
    
    
}

#pragma mark - Command Methods
-(void)makeTag:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp
{
    NSString *encodedName = [Utility encodeSpecialCharacters:[tData objectForKey:@"name"]];
    
    //over write name and add request time
    [tData addEntriesFromDictionary:@{
                                      @"name"           : encodedName,
                                      @"requesttime"    : [NSString stringWithFormat:@"%f",CACurrentMediaTime()]
                                      }];

    Tag *newTag = [[Tag alloc] initWithData:tData];
    newTag.uniqueID = self.event.tags.count + self.event.localTags.count;
    newTag.startTime = newTag.time - 5.0;
    newTag.displayTime = [Utility translateTimeFormat: newTag.time];
    newTag.own = YES;
    newTag.homeTeam = self.event.rawData[@"homeTeam"];
    newTag.visitTeam = self.event.rawData[@"visitTeam"];
    newTag.synced = NO;
    //newTag.requestTime = tData[@"requesttime"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_TAG_RECEIVED object:newTag];
    
    [self.localTags addObject: newTag];
    [self.event.localTags addEntriesFromDictionary: @{[NSString stringWithFormat:@"%i", newTag.uniqueID]: newTag}];
    
//    NSString *jsonString                    = [Utility dictToJSON:tData];
//    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"http://%@/min/ajax/tagset/%@",self.ipAddress,jsonString]  ];
//    urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
//    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
//    encoderConnection.connectionType        = MAKE_TAG;
//    encoderConnection.timeStamp             = aTimeStamp;
}

-(void)checkLocalTags{
    if (self.localTags.count >= 1) {
        Tag *tagToSend = [self.localTags firstObject];
        NSDictionary *tData = [tagToSend makeTagData];
        NSString *jsonString                    = [Utility dictToJSON:tData];
        NSString *ipAddress                     = self.encoderManager.masterEncoder.ipAddress;
        NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"http://%@/min/ajax/tagset/%@", ipAddress ,jsonString]  ];
        NSURLRequest *urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0];
        encoderConnection                       = [[NSURLDataConnection alloc] initWithRequest:urlRequest delegate:self];
        encoderConnection.context        = TAG_UPLOAD;
    }
}

#pragma mark - Event Download
-(void)syncEvents{
//    NSArray *allEvents = [self.allEvents allValues];
//    for (int i = 0; i < self.allEvents.count; ++i) {
//        Event *eventToSync = allEvents[i];
//        NSDictionary *tData = @{@"device":
//                                @"event":
//                                @"requesttime": CACurrentMediaTime(),
//                                @"user":
//                                    };
//                                
//                                
//        NSString *jsonString                    = [Utility dictToJSON:tData];
//        
//        NSString *ipAddress                     = self.encoderManager.masterEncoder.ipAddress;
//        NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"http://%@/min/ajax/gametags/%@", ipAddress,jsonString]  ];
//        NSURLRequest *urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0];
//        NSURLDataConnection *urlConnection                    = [[NSURLDataConnection alloc]initWithRequest:urlRequest delegate:self];
//        urlConnection.context = TAG_SYNC;
//        
//    
//
//    }
}

#pragma mark - Responces

-(void)teamsResponse:(NSMutableDictionary *)data
{

}

//-(void)makeTagResponce:(NSMutableDictionary *)data
//{
//}


-(void)modTagResponce:(NSMutableDictionary *)data
{
    
}

#pragma mark - NSURLConnection Delegate methods

-(void)connection:(NSURLDataConnection *)connection didReceiveData:(NSData *)data{
    if (connection.cumulatedData == nil){
        connection.cumulatedData = [NSMutableData dataWithData:data];
    } else {
        [connection.cumulatedData appendData:data];
    }
}

-(void)connectionDidFinishLoading:(NSURLDataConnection *)connection{
    if (connection.context == TAG_UPLOAD) {
        NSDictionary    * results =[Utility JSONDatatoDict: connection.cumulatedData];
        if([results isKindOfClass:[NSDictionary class]])
        {
            Tag *localTag = [self.localTags firstObject];
            [localTag replaceDataWithDictionary: results];
            for (Event *event in [self.allEvents allValues]) {
                if ([[event.localTags allValues] containsObject: localTag]){
                    [event.tags addEntriesFromDictionary: @{[NSString stringWithFormat: @"%i", localTag.uniqueID]:localTag }];
                    [event.localTags removeObjectForKey:[[event.localTags allKeysForObject: localTag] firstObject]];
                }
            }
            [self.localTags removeObject: localTag];
        }
        
        [self checkLocalTags];

    }else if (connection.context == TAG_SYNC){
        NSDictionary    * results =[Utility JSONDatatoDict:connection.cumulatedData];
        
        if (results){
            NSDictionary    * tags = [results objectForKey:@"tags"];
            if (tags) {
                Event *theEvent;
                Tag *firstTag = [[Tag alloc] initWithData:[[tags allValues]firstObject]];
                for (Event *event in [self.allEvents allValues]) {
                    if ([event.rawData[@"hid"] isEqualToString: firstTag.event]) {
                        theEvent = event;
                    }
                }
                
                for (NSDictionary *tag in tags) {
                    Tag *newTag = [[Tag alloc]initWithData:tag];
                    if (![[theEvent.tags allValues] containsObject: newTag]) {
                        [theEvent.tags addEntriesFromDictionary:@{[NSString stringWithFormat:@"%d", newTag.uniqueID]: newTag}];
                    }
                }
                
                
            }
        }

    }
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [self.localTags removeObjectAtIndex:0];
    [self checkLocalTags];
}



// Depricated?
-(void)myClipDataRequest: (NSNotification *)note{
    
}


-(Event*)event
{
    return _event;
}

-(void)setEvent:(Event *)event
{
    if (event ==_event){
        return;
    }
    [self willChangeValueForKey:@"event"];
    _event      =  event;
    [self didChangeValueForKey:@"event"];
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
    [_bookmarkPlistNames removeAllObjects];
    
//    NSString * bookmarkPath     = [NSString stringWithFormat:@"%@/bookmark",_localPath];
    NSArray* dirs;
    
    NSString * bookmarkPath = [_localPath stringByAppendingPathComponent:@"bookmark"];
    BOOL isDir = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:bookmarkPath isDirectory:&isDir];
    
    if ( !isDir){
        [[NSFileManager defaultManager] createDirectoryAtPath:bookmarkPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:bookmarkPath error:NULL];

    // go thru all found files
    [dirs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *filename = (NSString *)obj;
        
        // validate file names
        if ([self myClipPlistNameCheck:filename]) {
            [_bookmarkPlistNames addObject:filename]; // add names to clean list
            NSDictionary * dict = [NSDictionary dictionaryWithContentsOfFile:[bookmarkPath stringByAppendingPathComponent:filename]];
            Clip * clipFromPlist = [[Clip alloc]initWithDict:dict];
            clipFromPlist.path = filename;
            [_clips setObject:clipFromPlist forKey:clipFromPlist.globalID];
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
    NSPredicate *pred = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        
        Event* obj = evaluatedObject;
        return [obj.name isEqualToString:eventName];
    }];
    
    NSArray * filtered = [NSArray arrayWithArray:[[[self allEvents]allValues] filteredArrayUsingPredicate:pred ]];
    
    if ([filtered count]==0)return nil;

    return (Event*)filtered[0];
}


/**
 *  This saves the clip. This method only saves one source at a time
 *
 *  @param aName   !!! This name has to change
 *  @param tagData the data for the raw clip
 */
-(void)saveClip:(NSString*)aName withData:(NSDictionary *)tagData
{
    
    // check the device if the clip is there.. if not then make a new clip from and make get an Id
    NSString *event = tagData[@"event"];
    NSString *globalID = [NSString stringWithFormat:@"%@_%@", event, tagData[@"id"]];
    
    if ([_clips objectForKey:globalID]) { // if there is a plist there already then just mod the data
        Clip * selectedClip = _clips[globalID];
        
        [selectedClip addSourceToClip:@{@"fileNames": @[aName]}];
      //  return [[VideoTrimItem alloc] init];
    } else { // there is no plist for this clip... make a new plist
       
        [self scanForBookmarks];
        NSString *bookmarkPlistPath = [NSString stringWithFormat:@"%@/bookmark/%@.plist",_localPath, globalID];
        
        NSMutableDictionary *clipData = [NSMutableDictionary dictionaryWithDictionary:tagData];
        clipData[@"plistPath"] = bookmarkPlistPath;
        
        Clip * buildClip = [[Clip alloc]initWithPlistPath:bookmarkPlistPath data: clipData];
        [buildClip addSourceToClip:@{@"fileNames": @[aName]}];
        [_clips setObject:buildClip forKey:buildClip.globalID];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_CLIP_SAVED object:buildClip];

    }
    
   
}


-(void)myClipDeleteRequest:(NSNotification*)note
{
    // if the object is is a clip then KILL it with Fire!
    if ([note.object isKindOfClass:[Clip class]]) {
        Clip * selectedClip = note.object;
        [self deleteClip: selectedClip.globalID];
    } else {
        [self deleteClip: [NSString stringWithFormat:@"%@_%@", note.userInfo[@"event"], note.userInfo[@"id"]]];
    }
}

-(void)deleteClip:(NSString*)aId
{
    Clip * selectedClip = [_clips objectForKey:aId];
    [selectedClip destroy];
    [_clips removeObjectForKey:aId];

    // sort list on delete  // this is used in gap detection for clip sequence
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
    Event * anEvent = [[Event alloc]initWithDict:aEvent.rawData isLocal:YES andlocalPath:self.localPath];
    anEvent.parentEncoder = self;
//    anEvent.local   = YES;
    //anEvent.downloadedSources = [[self listDownloadSourcesFor:anEvent] mutableCopy];
    
    
    NSMutableDictionary            * allEventsMutable =  [_allEvents mutableCopy];
    [allEventsMutable setObject:anEvent forKey:anEvent.hid];
    _allEvents = [allEventsMutable copy];
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
    
    NSMutableDictionary * temp = [NSMutableDictionary dictionaryWithDictionary:_allEvents];
    [temp removeObjectForKey:aEvent.hid];
    
    _allEvents = [temp copy];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_UPDATE_MEMORY object:nil];
    
    // This is run when the current playing event is deleted
    if (_event == aEvent){
        _event = nil;
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


/**
 *  Validate clip names
 *
 *  @param check file name
 *
 *  @return is valid
 */
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
-(NSString*)description
{
    NSString * bookmarkPath = [NSString stringWithFormat:@"%@/bookmark",_localPath];
    NSString * txt = [NSString stringWithFormat:@" %@: %d - %@   - %@\nBookmark Path:%@",self.name,self.status,self.event.name,self.event.eventType,  bookmarkPath ];
    return txt;
}


@end
