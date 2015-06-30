//
//  LocalMediaManager.m
//  Live2BenchNative
//
//  Created by dev on 2015-06-30.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "LocalMediaManager.h"
#import "Event.h"
#import "Clip.h"
#import "LocalEncoder.h"
#import "Tag.h"
#import "Feed.h"

#define LOCAL_PLIST  @"EventsHid.plist"
#define VIDEO_EXT    @"mp4"

static LocalMediaManager * instance;

@implementation LocalMediaManager{
    NSString        * _localDocsPListPath;
    NSMutableArray  * _bookmarkPlistNames;
    NSComparisonResult(^plistSort)(id obj1, id obj2);
}

+(instancetype)getInstance
{
    return instance;
}

@synthesize name = _name;
@synthesize localPath = _localPath;
@synthesize allEvents       = _allEvents;
@synthesize clips           = _clips;

-(id)initWithDocsPath:(NSString*)aDocsPath{
    self = [super init];
    if (self) {
        
        // Build Local Encoder
        _name                           = @"Local Encoder";
        _localPath                      = aDocsPath;
        _localDocsPListPath             = [aDocsPath stringByAppendingPathComponent:LOCAL_PLIST];// if its not there make it
        _clips                          = [[NSMutableDictionary alloc]init];
        _allEvents                      = [[NSMutableDictionary alloc] init];
        
        
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
                anEvent.parentEncoder       = [LocalEncoder getInstance];
                    anEvent.local               = YES;
                    anEvent.downloadedSources   = [[self listDownloadSourcesFor:anEvent] mutableCopy];
                    
                    NSArray *tags    = [anEvent.rawData[@"tags"] allValues];
                    NSMutableArray *newTags = [[NSMutableArray alloc]init];
                    for (NSDictionary *tagDic in tags) {
                        Tag *newTag = [[Tag alloc] initWithData:tagDic event:anEvent];
                        [newTags addObject:newTag];
                    }
                    
                    [anEvent setTags:newTags];
                    
                    [_allEvents setValue:anEvent forKey:itemHid];// this is the new kind of build that events have their own feed
                }
            }
            
        
        NSMutableArray *localTempPool = [[NSMutableArray alloc]init];
        NSArray *localplishPaths = [self grabAllFiles:_localPath ext:@"plist"];
        for (NSString *localPths in localplishPaths) {
            NSDictionary * temp = [[NSDictionary alloc]initWithContentsOfFile:localPths];
            if (temp) {
                [localTempPool addObject:temp];
            } else {
                PXPLog(@"Error Loading pList: ");
                PXPLog(@"%@",localPths);
            }
        }
            
            
        NSEnumerator *localEnumerator  = [localTempPool objectEnumerator];
        id localValue;
        while ((localValue = [localEnumerator nextObject])) {
            NSDictionary *localTagDic = localValue;
            if ([localTagDic objectForKey:@"emailAddress"] == nil) {
                NSMutableDictionary *finalLocalTags = [[NSMutableDictionary alloc]initWithDictionary:localTagDic];
                [[LocalEncoder getInstance].localTags addEntriesFromDictionary:finalLocalTags];
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
                
            NSInteger n1 = [fn1 integerValue];
            NSInteger n2 = [fn2 integerValue];
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
        [[NSNotificationCenter defaultCenter] addObserverForName:NOTIF_REQUEST_CLIPS object:nil queue:nil usingBlock:^(NSNotification *note){
            void(^blockName)(NSArray *clips) = note.object;
            blockName([self.clips allValues]);
        }];

        
        instance = self;
        }
        return self;
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

/*
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
    
    //[aEvent.tags writeToFile:plistNamePath atomically:YES];
    [aEvent.rawData writeToFile:plistNamePath atomically:YES];
    
    // make an instance of event in local
    Event * anEvent = [[Event alloc]initWithDict:aEvent.rawData isLocal:YES andlocalPath:self.localPath];
    anEvent.parentEncoder = [LocalEncoder getInstance];
    
    
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




@end
