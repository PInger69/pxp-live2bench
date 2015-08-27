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
#import "LeagueTeam.h"
#import "TeamPlayer.h"

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
            NSDictionary *dict = [[NSDictionary alloc]initWithContentsOfFile:pths];
            if (dict) {
                [tempPool addObject:dict];
            }
        }

        // and then checks if the videos are downloaded for each source and added to the Event
        NSEnumerator    * enumerator    = [tempPool objectEnumerator];
        id              value;
        while ((value = [enumerator nextObject])) {
            NSMutableDictionary * dict = value;
            NSString * itemHid = [dict objectForKey:@"hid"];
            if (itemHid) {
                NSArray *mp4s = [dict[@"mp4_2"] allValues];
                if (mp4s.count > 1) {
                    NSMutableDictionary *feeds = [[NSMutableDictionary alloc]init];
                    for (int i = 0; i < mp4s.count; i++) {
                        NSString *name = [NSString stringWithFormat:@"main_0%ihq.mp4",i];
                        NSString *path = [[[_localPath stringByAppendingPathComponent:@"events"] stringByAppendingPathComponent:dict[@"name"]] stringByAppendingPathComponent:name];
                        [feeds setObject:path forKey:[NSString stringWithFormat:@"s_0%i",i]];
                    }
                    [dict setObject:feeds forKeyedSubscript:@"mp4_2"];
                } else {
                    NSString *path = [[[_localPath stringByAppendingPathComponent:@"events"] stringByAppendingPathComponent:dict[@"name"]] stringByAppendingPathComponent:@"main.mp4"];
                    [dict setObject:path forKey:@"mp4"];
                }
                
                
                Event * anEvent = [[Event alloc]initWithDict:dict isLocal:YES andlocalPath:self.localPath];
                anEvent.parentEncoder       = [LocalEncoder getInstance];
                    anEvent.local               = YES;
                    anEvent.isBuilt             = YES;
                    anEvent.downloadedSources   = [[self listDownloadSourcesFor:anEvent] mutableCopy];
                    
                
                if ([dict objectForKey:@"savedTeamData"]){
                   anEvent.teams =  [self parsedTeamData:dict];
                }
                
                    NSMutableDictionary *eventFinal = [[NSMutableDictionary alloc]initWithDictionary:@{@"local":anEvent}];
                    [_allEvents setValue: eventFinal forKey:anEvent.name];// this is the new kind of build that events have their own feed
                
                    //[_allEvents setValue:anEvent forKey:itemHid];// this is the new kind of build that events have their own feed
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
                    [self assignLocalTags:localTagDic];
                }
                //NSMutableDictionary *finalLocalTags = [[NSMutableDictionary alloc]initWithDictionary:localTagDic];
                //[self assignLocalTags:localTagDic];
                //[[LocalEncoder getInstance].localTags addObjectsFromArray:[finalLocalTags allValues]];
                //[[LocalEncoder getInstance].localTags addEntriesFromDictionary:finalLocalTags];
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
            
            
         // IS THIS DOING ANYTHING ANYMORE??
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

-(void)assignLocalTags:(NSDictionary *)mainDict{
    NSArray *tagToBeAddedArray = [mainDict allValues];
    
    for (NSMutableDictionary *tagToBeAdded in tagToBeAddedArray) {
        
        if (![tagToBeAdded isEqual:@"true"]) {
            Event *event = [self getEventByName:tagToBeAdded[@"event"]];
            
            for (Tag *tag in event.tags) {
                if ([tag.ID isEqual:tagToBeAdded[@"id"]]) {
                    
                    if ([mainDict objectForKey:@"modifiedTags"] != nil) {
                        [[LocalEncoder getInstance].modifiedTags addObject:tag];
                    }else{
                        [[LocalEncoder getInstance].localTags addObject:tag];
                    }
                }
            }
            
            if ([[tagToBeAdded objectForKey:@"type"] integerValue] == TagTypeDeleted) {
                Event *event = [self getEventByName:tagToBeAdded[@"event"]];
                Tag *deletedTag = [[Tag alloc]initWithData:tagToBeAdded event:event];
                [[LocalEncoder getInstance].modifiedTags addObject:deletedTag];
            }

        }
        
    }
}

-(void)assignEncoderVersionEvent:(NSDictionary *)allEvent{
    for (NSString *eventName in [_allEvents allKeys]) {
        NSMutableDictionary *encoderEventDic = [allEvent objectForKey:eventName];
        Event *encoderVersionEvent = [encoderEventDic objectForKey:@"non-local"];
        if (encoderVersionEvent) {
            NSMutableDictionary *eventFinal = [_allEvents objectForKey:eventName];
            [eventFinal setObject:encoderVersionEvent forKey:@"non-local"];
        }
    }
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
            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithContentsOfFile:[bookmarkPath stringByAppendingPathComponent:filename]];
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
        
        //NSMutableDictionary *objDic = evaluatedObject;
        //Event *obj = [objDic objectForKey:@"local"];
        
        Event* obj = evaluatedObject;
        return [obj.name isEqualToString:eventName];
    }];
    
    NSMutableArray *dataToBeFiltered = [[NSMutableArray alloc]init];
    for (NSMutableDictionary *eventDic in [_allEvents allValues]) {
        [dataToBeFiltered addObject:[eventDic objectForKey:@"local"]];
    }
    
    
    //NSArray * filtered = [NSArray arrayWithArray:[[[self allEvents]allValues] filteredArrayUsingPredicate:pred ]];
    NSArray * filtered = [NSArray arrayWithArray:[dataToBeFiltered filteredArrayUsingPredicate:pred ]];
    
    if ([filtered count]==0)return nil;
    
    return (Event*)filtered[0];
}

/*
 *  This will return the clip if found on the device.
 *  The acts as tool to check if a specific exist on the device
 *  It will check for clip with the Tag ID then check that clip for the source
 *
 *  @param tagID   the ID of the tag your looking for
 *  @param scrKey  what a source are you looking for if you send nil it will just send you the clip
 *
 *  @output if the clip is found and the source is not it will return nil
 */
-(Clip*)getClipByTag:(Tag*)tag scrKey:(NSString*)scrKey
{
    
    NSString * eventName = tag.event.name;
    NSString * tagID = tag.ID;
    NSString * searchClipID = [NSString stringWithFormat:@"%@_%@", eventName, tagID];
    Clip    * foundClip;
    NSArray * justClips = [_clips allValues];
    // Cheking all clips
    for (Clip * someClip in justClips) {
        if ([someClip.globalID isEqualToString:searchClipID]){
            foundClip = someClip;
            break;
        }
    }
    
    if (foundClip && !scrKey){
        return foundClip;
    }
    
    if(!foundClip){
        return nil; // no clip found!!
    }
    
    // Now search the clip if it has the source
    if ([foundClip.videosBySrcKey objectForKey:[NSString stringWithFormat:@"%@hq", scrKey]]) {
        return foundClip;
    }
    
    return nil;
}

-(Feed*)getFeedByEvent:(Event*)event scrKey:(NSString *)scrKey
{
    Event *localEvent = [self getEventByName:event.name];
    if (!localEvent) {
        return  nil;
    }
    NSDictionary *feeds = localEvent.originalFeeds;
    NSArray *keys = [feeds allKeys];
    Feed *foundFeed;
    
    for (NSString *key in keys) {
        if ([key isEqualToString:scrKey]) {
            foundFeed = [feeds objectForKey:key];
        }
    }
    
    if (foundFeed) {
        return foundFeed;
    }else{
        return nil;
    }
}



// This method mods the clip GlobalID so that its no longer connected to live event
// as well as mod the data kept here
-(void)breakTagLink:(Clip*)aClip
{
   
//    [_clips objectForKey:aClip.name];
    [_clips removeObjectForKey:aClip.globalID];
    [aClip breakClipId];
    
    [_clips setObject:aClip forKey:[NSString stringWithFormat:@"%@",aClip.globalID ]];

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
        
        //Event *encoderEvent = [[LocalEncoder getInstance] searchEventByName:event];
        //clipData[@"event"] = encoderEvent;
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
-(NSString*)saveEvent:(NSMutableDictionary*)eventDic
{
    Event *encoderEvent = eventDic[@"non-local"];
    
    // This gets the path and makes a DIR if its not there
    NSString * aPath = [[_localPath stringByAppendingPathComponent:@"events"] stringByAppendingPathComponent:encoderEvent.datapath];
    BOOL isDir = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:aPath isDirectory:&isDir];
    
    
    if ( !isDir){
        [[NSFileManager defaultManager] createDirectoryAtPath:aPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    NSString * plistNamePath = [[[_localPath stringByAppendingPathComponent:@"events"] stringByAppendingPathComponent:encoderEvent.datapath]stringByAppendingPathExtension:@"plist"];
    
    //[aEvent.tags writeToFile:plistNamePath atomically:YES];
    //[aEvent.rawData writeToFile:plistNamePath atomically:YES];
    
    // make an instance of event in local
    //Event * localEvent = [[Event alloc]initWithDict:encoderEvent.rawData isLocal:YES andlocalPath:self.localPath];
    //localEvent.parentEncoder = [LocalEncoder getInstance];
    //localEvent.local = true;
    //localEvent.tags = encoderEvent.tags;
    //localEvent.isBuilt = true;
    
    NSMutableDictionary * localEventRawData = [[NSMutableDictionary alloc]initWithDictionary:[encoderEvent.rawData copy]];
    if (encoderEvent.mp4s.count > 1) {
        NSMutableDictionary *feeds = [[NSMutableDictionary alloc]init];
        for (int i = 0; i < encoderEvent.mp4s.count; i++) {
            NSString *name = [NSString stringWithFormat:@"main_0%ihq.mp4",i];
            NSString *path = [[[[LocalMediaManager getInstance].localPath stringByAppendingPathComponent:@"events"] stringByAppendingPathComponent:encoderEvent.name] stringByAppendingPathComponent:name];
           // NSDictionary *mp4Dic = @{@"hq":path};
            [feeds setObject:path forKey:[NSString stringWithFormat:@"s_0%i",i]];
        }
        [localEventRawData setObject:feeds forKeyedSubscript:@"mp4_2"];
    } else {
        NSString *path = [[[[LocalMediaManager getInstance].localPath stringByAppendingPathComponent:@"events"] stringByAppendingPathComponent:encoderEvent.name] stringByAppendingPathComponent:@"main.mp4"];
        //NSDictionary *mp4Dic = @{@"hq":path};
        //[localEventRawData removeObjectForKey:@"mp4"];
        [localEventRawData setObject:path forKey:@"mp4"];
    }
    

    Event * localEvent = [[Event alloc]initWithDict:localEventRawData isLocal:YES andlocalPath:self.localPath];
    localEvent.parentEncoder = [LocalEncoder getInstance];
    localEvent.local = true;
    //localEvent.tags = encoderEvent.tags;
    //localEvent.isBuilt = true;
    
    [encoderEvent.teams allKeys];
    

    // This is all the pooled data from the team data added to the savePlist
    // this is parsing out the data the data the same way that its being recieved from the encoder
    NSMutableDictionary * teamSaveData = [[NSMutableDictionary  alloc]init];
    [teamSaveData setObject:    [NSMutableDictionary new] forKey:@"leagues"];
    [teamSaveData setObject:    [NSMutableDictionary new] forKey:@"teams"];
    [teamSaveData setObject:    [NSMutableDictionary new] forKey:@"teamsetup"];
    
    for (NSString *key in [encoderEvent.teams allKeys]) {
        
        LeagueTeam * team =  (LeagueTeam *) [encoderEvent.teams objectForKey:key];

        [teamSaveData[@"leagues"] setObject:[team.league asDictionary]  forKey:team.league.hid]; // i know that this will get overwriten for each team because they are both in the same league
        
        [teamSaveData[@"teams"] setObject:[team asDictionary]  forKey:team.hid];
        
        
        NSMutableArray * playerPool = [NSMutableArray new];
        NSArray * playersInTeam     = [team.players allValues];
        for (TeamPlayer* player in playersInTeam) {
            [playerPool addObject:[player asDictionary]];
        }
        [teamSaveData[@"teamsetup"] setObject:playerPool  forKey:team.hid];
        
         NSLog(@"%@ Teams have %lu",team.name,(unsigned long)[team.players count]);
    }
    
    
    NSMutableDictionary * combinedTeamData = [NSMutableDictionary dictionaryWithDictionary:localEvent.rawData];
    
    
   
    
    localEvent.teams = [self parsedTeamData:localEventRawData]; // add teams to the new local event
     [combinedTeamData setObject:teamSaveData forKey:@"savedTeamData"];
    [combinedTeamData writeToFile:plistNamePath atomically:YES];
    
    [eventDic setObject:localEvent forKey:@"local"];
    [eventDic setObject:encoderEvent forKey:@"non-local"];
    NSMutableDictionary *eventFinal = [[NSMutableDictionary alloc]initWithDictionary:@{@"local":localEvent,@"non-local":encoderEvent}];
    [_allEvents setObject:eventFinal forKey:encoderEvent.name];
    //[[LocalEncoder getInstance] checkEncoder];
    
    //NSMutableDictionary            * allEventsMutable =  [_allEvents mutableCopy];
    //[allEventsMutable setObject:anEvent forKey:anEvent.hid];
    //_allEvents = [allEventsMutable copy];
     
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
    
    [_allEvents removeObjectForKey:aEvent.name];
    
    //NSMutableDictionary * temp = [NSMutableDictionary dictionaryWithDictionary:_allEvents];
    //[temp removeObjectForKey:aEvent.hid];
    
    //_allEvents = [temp copy];
    
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

// This returns @{@"homeTeam":<LeagueTeam>,@"visitTeam":<LeagueTeam>} // to be added to the event
// This is basically the same as in the Encoder class. One day I would like to make one or two classes that focus on parsing
-(NSDictionary*)parsedTeamData:(NSDictionary*)mainDict
{
    NSDictionary *dict = [mainDict objectForKey:@"savedTeamData"];
    NSMutableDictionary * leaguePool        = [[NSMutableDictionary alloc]init]; // this is the final
    NSMutableDictionary * leagueTempHIDPool = [[NSMutableDictionary alloc]init];
    NSArray * rawleagues = [[dict objectForKey:@"leagues"]allValues];
    
    for (NSDictionary * lData in rawleagues) {
        League * aLeague    = [[League alloc]init];
        aLeague.hid         = lData[@"hid"];
        aLeague.name        = lData[@"name"];
        aLeague.shortName   = lData[@"short"];
        aLeague.sport       = lData[@"sport"];
        
        
        [leaguePool setObject:aLeague forKey:aLeague.name];
        
        [leagueTempHIDPool setObject:aLeague forKey:aLeague.hid];
    }
    
    
    
    // Build Teams
    NSMutableDictionary * teamTempHIDPool = [[NSMutableDictionary alloc]init];
    NSArray             * rawTeams          = [[dict objectForKey:@"teams"]allValues];
    
    for (NSDictionary * tData in rawTeams) {
        LeagueTeam  * lTeam = [[LeagueTeam alloc]init];
        NSString    * lHID  = tData[@"league"];
        lTeam.extra         = tData[@"extra"];
        lTeam.hid           = tData[@"hid"];
        lTeam.name          = tData[@"name"];
        lTeam.sport         = tData[@"sport"];
        lTeam.txt_name      = tData[@"txt_name"];
        
        League * owningLeague = (League *)[leagueTempHIDPool objectForKey:lHID];
        lTeam.league        = owningLeague;
        [owningLeague addTeam:lTeam];
        [teamTempHIDPool setObject:lTeam forKey:lTeam.hid];
    }
    
    // build players
    
    NSArray             * rawTeamSetup          = [[dict objectForKey:@"teamsetup"]allValues];
    for (NSArray * pList in rawTeamSetup) {
        
        // each item in the Array should all be the same team
        if (![pList count]) break ;
        NSString    * tHID      = pList[0][@"team"];
        LeagueTeam * owningTeam = (LeagueTeam *)[teamTempHIDPool objectForKey:tHID];
        for (NSDictionary * pData in pList) {
            TeamPlayer * aPlayer    = [[TeamPlayer alloc]init];
            aPlayer.jersey          = pData[@"jersey"];
            aPlayer.line            = pData[@"line"];
            aPlayer.player          = pData[@"player"];
            aPlayer.position        = pData[@"position"];
            aPlayer.role            = pData[@"role"];
            aPlayer.team            = owningTeam;
            
            tHID      = pData[@"team"];
            owningTeam = (LeagueTeam *)[teamTempHIDPool objectForKey:tHID];
            [owningTeam addPlayer:aPlayer];
        }
    }
    
    
    // populating teams based off data
    
    NSDictionary * dic = [[dict[@"leagues"]allValues]firstObject];
    NSString * lName = [dic objectForKey:@"name"] ;
    League      * league        = [leaguePool objectForKey:lName];
    LeagueTeam  * homeTeam      = [league.teams objectForKey:mainDict[@"homeTeam"]];
    LeagueTeam  * visitTeam     = [league.teams objectForKey:mainDict[@"visitTeam"]];
    
    if ([league.teams count]==1){
        homeTeam = visitTeam = [[league.teams allValues]firstObject];
    }
    
    if (!homeTeam) {
        homeTeam     = [LeagueTeam new];

    }
    if (!visitTeam) {
        visitTeam   = [LeagueTeam new];

    }

    
    

    return @{@"homeTeam":homeTeam,@"visitTeam":visitTeam};
}



@end
