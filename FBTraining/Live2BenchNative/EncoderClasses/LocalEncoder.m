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
#import "Event.h"
#import "Clip.h"

#define LOCAL_PLIST  @"EventsHid.plist"
#define VIDEO_EXT    @"mp4"

@implementation LocalEncoder
{
    NSString        * _localDocsPListPath;
    NSString        * _localPath;
    NSMutableArray  * _bookmarkPlistNames;
    NSComparisonResult(^plistSort)(id obj1, id obj2);
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
        _clips              = [[NSMutableDictionary alloc]init];
        _allEvents          = [[NSMutableDictionary alloc] init];
        
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
                Event * anEvent = [[Event alloc]initWithDict:dict];
                anEvent.local   = YES;
                anEvent.downloadedSources = [self listDownloadSourcesFor:anEvent];
                [_allEvents setValue:anEvent forKey:itemHid];// this is the new kind of build that events have their own feed
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
            Clip * clip =[[Clip alloc]initWithDict:[[NSDictionary alloc]initWithContentsOfFile:pthss]];
            //[_clips setObject:clip forKey:clip.clipId];
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

#pragma mark - Responces

-(void)teamsResponse:(NSMutableDictionary *)data
{

}

-(void)makeTagResponce:(NSMutableDictionary *)data
{
}


-(void)modTagResponce:(NSMutableDictionary *)data
{
    
}


#pragma mark - Event Download
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
    
    NSString * bookmarkPath     = [NSString stringWithFormat:@"%@/bookmark",_localPath];
    NSArray* dirs               = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:bookmarkPath error:NULL];
    
    // go thru all found files
    [dirs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *filename = (NSString *)obj;
        
        // validate file names
        if ([self myClipPlistNameCheck:filename]) {
            [_bookmarkPlistNames addObject:filename]; // add names to clean list
            NSDictionary * dict = [NSDictionary dictionaryWithContentsOfFile:[bookmarkPath stringByAppendingPathComponent:filename]];
            Clip * clipFromPlist = [[Clip alloc]initWithDict:dict];
            [_clips setObject:clipFromPlist forKey:clipFromPlist.clipId];
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
-(void)saveClip:(NSString*)aName withData:(NSDictionary*)tagData
{
    
    // check the device if the clip is there.. if not then make a new clip from and make get an Id
    
    NSString * clipID = tagData[@"id"];
    
    if ([_clips objectForKey:clipID]) { // if there is a plist there already then just mod the data
        Clip * selectedClip         = [_clips objectForKey:clipID];
        
        [selectedClip addSourceToClip:@{}];
    
    } else { // there is no plist for this clip... make a new plist
       
        // fina available plist path
        [self scanForBookmarks];
        int nextGap = [self gap:_bookmarkPlistNames first:0 last:[_bookmarkPlistNames count]-1];
        NSString * bookmarkPlistPath = [NSString stringWithFormat:@"%@/bookmark/%d.plist",_localPath,nextGap];
        
        Clip * buildClip = [[Clip alloc]initWithPlistPath:bookmarkPlistPath data:tagData];
        [buildClip addSourceToClip:@{@"fileNames": @[aName]}];
        [_clips setObject:buildClip forKey:buildClip.clipId];
    }
    
}


-(void)myClipDeleteRequest:(NSNotification*)note
{
    [self deleteClip:    [note.userInfo objectForKey:@"id"]];
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
    Event * anEvent = [[Event alloc]initWithDict:aEvent.rawData];
    anEvent.local   = YES;
    anEvent.downloadedSources = [self listDownloadSourcesFor:anEvent];
    
    
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
    [temp removeObjectForKey:aEvent.name];
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
