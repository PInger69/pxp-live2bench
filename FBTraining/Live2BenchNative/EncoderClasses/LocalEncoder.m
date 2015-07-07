
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
#import "UserCenter.h"
#import "LocalMediaManager.h"


#define LOCAL_PLIST     @"EventsHid.plist"
#define VIDEO_EXT       @"mp4"
//#define TAG_SYNC        1
//#define TAG_UPLOAD      2

#define NEW_TAG_UPLOAD    1
#define OLD_TAG_UPDATE    2

#define GET_NOW_TIME_STRING [NSString stringWithFormat:@"%f",CACurrentMediaTime()]

// PRIVATE CLASS
@interface NSURLDataConnection : NSURLConnection
@property (strong, nonatomic) NSMutableData *cumulatedData;
@property (assign, nonatomic) int context;
@end
@implementation NSURLDataConnection
@end


static LocalEncoder * instance;
@implementation LocalEncoder
{
    //NSString        * _localDocsPListPath;
    //NSMutableArray  * _bookmarkPlistNames;
    //NSComparisonResult(^plistSort)(id obj1, id obj2);
    NSMutableArray  * tagSyncConnections;
    NSURLDataConnection *encoderConnection;
}

//@synthesize name            = _name;
@synthesize event           = _event;
@synthesize status          = _status;
//@synthesize allEvents       = _allEvents;
//@synthesize clips           = _clips;

// ActionListItems
@synthesize delegate,isFinished,isSuccess;


+(instancetype)getInstance
{
    return instance;
}


-(id)initWithDocsPath:(NSString*)aDocsPath
{
    self = [super init];
    if (self){
        
        // Build Local Encoder
        //_name                           = @"Local Encoder";
         _localPath                      = aDocsPath;
        //_localDocsPListPath             = [aDocsPath stringByAppendingPathComponent:LOCAL_PLIST];// if its not there make it
        _status                         = ENCODER_STATUS_LOCAL;
        _event                          = nil;
        //_clips                          = [[NSMutableDictionary alloc]init];
        //_allEvents                      = [[NSMutableDictionary alloc] init];
        _localTags                      = [[NSMutableArray alloc] init];
        _modifiedTags                   = [[NSMutableArray alloc] init];
        tagSyncConnections              = [NSMutableArray array];
        
       /* // build folder structue if not there
        
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
                
                NSArray *tags    = [anEvent.rawData[@"tags"] allValues];
                NSMutableArray *newTags = [[NSMutableArray alloc]init];
                for (NSDictionary *tagDic in tags) {
                    Tag *newTag = [[Tag alloc] initWithData:tagDic event:anEvent];
                    [newTags addObject:newTag];
                }
                
                [anEvent setTags:newTags];
                
                [_allEvents setValue:anEvent forKey:itemHid];// this is the new kind of build that events have their own feed*/
                
                //[self.localTags addEntriesFromDictionary:self.event.localTags];
            /*}
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
                [self.localTags addEntriesFromDictionary:finalLocalTags];
            }
            
        }*/
        
        
        
        
        
        
        /*
         Book mark Section!!!
         
        
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
        
        [[NSNotificationCenter defaultCenter] addObserverForName:NOTIF_DELETE_EVENT object:nil queue:nil usingBlock:^(NSNotification *note){
            Event *localCounterpart = [self getEventByName:((Event *)note.userInfo[@"Event"]).name];
            if (localCounterpart) {
                [self deleteEvent:localCounterpart];
            }
        }];*/
        
        /*[[NSNotificationCenter defaultCenter] addObserverForName:NOTIF_REQUEST_CLIPS object:nil queue:nil usingBlock:^(NSNotification *note){
            void(^blockName)(NSArray *clips) = note.object;
            blockName([self.clips allValues]);
        }];*/
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkEncoder) name:NOTIF_EM_FOUND_MASTER object:nil];
        //[self checkLocalTags];
        instance = self;
    }
    return self;
}


-(id <EncoderProtocol>)makePrimary
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onTagPost:)        name:NOTIF_TAG_POSTED           object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onTelePost:)       name:NOTIF_CREATE_TELE_TAG      object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onModTag:)         name:NOTIF_MODIFY_TAG           object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onDeleteTag:)      name:NOTIF_DELETE_TAG           object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onDownloadClip:)   name:NOTIF_EM_DOWNLOAD_CLIP     object:nil];

    return self;
}

-(id <EncoderProtocol>)removeFromPrimary
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_TAG_POSTED              object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_CREATE_TELE_TAG         object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_MODIFY_TAG              object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_DELETE_TAG              object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_EM_DOWNLOAD_CLIP        object:nil];
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
        [self modTag:tData];
    } else if ([methodName isEqualToString: EVENT_GET_TAGS]) {
     //   [self eventTagsGetResponce: tData eventNameKey:extra];
    }
    
    
}

-(void) writeToPlist{
    
// local event write to plist
    NSString * plistNamePath = [[[_localPath stringByAppendingPathComponent:@"events"] stringByAppendingPathComponent:self.event.datapath]stringByAppendingPathExtension:@"plist"];
    
    for (NSMutableDictionary *eventDic in [[LocalMediaManager getInstance].allEvents allValues]) {
        Event *localEvent = eventDic[@"local"];
        [localEvent.rawData writeToFile:plistNamePath atomically:YES];
    }

// local tags write to plist
    NSMutableDictionary *data = [[NSMutableDictionary alloc]init];
    
    for(int i = 0; i < self.localTags.count; i++){
        Tag *tag = self.localTags[i];
        if (tag.type != TagTypeOpenDuration) {
            NSMutableDictionary *combDict = [[NSMutableDictionary alloc]init];
            [combDict addEntriesFromDictionary:[tag modifiedData]];
            [combDict addEntriesFromDictionary:[tag makeTagData]];
            [data setObject:combDict forKey:[NSString stringWithFormat:@"%i", i]];
        }
    }
    
    NSString * localplistNamePath = [[_localPath stringByAppendingPathComponent:@"localTags"] stringByAppendingPathExtension:@"plist"];
    [data writeToFile:localplistNamePath atomically:YES];
    
// modified tags that weren't made locally write to plist
    [data removeAllObjects];
    for (int i = 0; i < self.modifiedTags.count; i++) {
        Tag *tag = self.modifiedTags[i];
        if (tag.type != TagTypeOpenDuration) {
            NSMutableDictionary *combDict = [[NSMutableDictionary alloc]init];
            [combDict addEntriesFromDictionary:[tag modifiedData]];
            [combDict addEntriesFromDictionary:[tag makeTagData]];
            [data setObject:combDict forKey:[NSString stringWithFormat:@"%i", i]];
        }
    }
    
    NSString * modifiedplistNamePath = [[_localPath stringByAppendingPathComponent:@"modifiedTags"] stringByAppendingPathExtension:@"plist"];
    [data setObject:@"true" forKey:@"modifiedTags"];
    [data writeToFile:modifiedplistNamePath atomically:YES];
}


#pragma mark - Observer


/*-(void)onTagPost:(NSNotification *)note
{
    NSMutableDictionary * data   = [NSMutableDictionary dictionaryWithDictionary:note.userInfo];
    BOOL isDuration                 = ([note.userInfo objectForKey:@"duration"])?[[note.userInfo objectForKey:@"duration"] boolValue ]:FALSE;
    [data removeObjectForKey:@"duration"];
    
    NSString *tagTime = [data objectForKey:@"time"];// just to make sure they are added
    NSString *tagName = [data objectForKey:@"name"];// just to make sure they are added
//    NSString *eventNm = (self.event.live)?LIVE_EVENT:self.event.name;
    
    // This is the starndard info that is collected from the encoder
    NSMutableDictionary * tagData = [NSMutableDictionary dictionaryWithDictionary:
                                     @{
                                       @"event"         : self.event.name,
                                       @"colour"        : [Utility hexStringFromColor: [UserCenter getInstance].customerColor],
                                       @"user"          : [UserCenter getInstance].userHID,
                                       @"time"          : tagTime,
                                       @"name"          : tagName,
                                       @"deviceid"      : [[[UIDevice currentDevice] identifierForVendor]UUIDString]
                                       
                                       }];
    if (isDuration){ // Add extra data for duration Tags
        NSDictionary *durationData =        @{
                                              
                                              @"type"     : [NSNumber numberWithInteger:TagTypeOpenDuration]
                                              // ,@"dtagid": @"123456789" // this should be set before
                                              };
        [tagData addEntriesFromDictionary:durationData];
        
    }
    
    [tagData addEntriesFromDictionary:data];
    
    [self issueCommand:MAKE_TAG priority:1 timeoutInSec:20 tagData:tagData timeStamp:GET_NOW_TIME];
}*/

-(void)onTagPost:(NSNotification *)note
{
    NSMutableDictionary * data   = [NSMutableDictionary dictionaryWithDictionary:note.userInfo];
    
    NSString *tagTime = [data objectForKey:@"time"];// just to make sure they are added
    NSString *tagName = [data objectForKey:@"name"];// just to make sure they are added
    
    // This is the starndard info that is collected from the encoder
    NSMutableDictionary * tagData = [NSMutableDictionary dictionaryWithDictionary:
                                     @{
                                       @"event"         : self.event.name,
                                       @"colour"        : [Utility hexStringFromColor: [UserCenter getInstance].customerColor],
                                       @"user"          : [UserCenter getInstance].userHID,
                                       @"time"          : tagTime,
                                       @"name"          : tagName,
                                       @"deviceid"      : [[[UIDevice currentDevice] identifierForVendor]UUIDString]
                                       
                                       }];
    
    [tagData addEntriesFromDictionary:data];
    
    if ([[data objectForKey:@"type"] integerValue] == TagTypeOpenDuration) {
        [tagData addEntriesFromDictionary:@{ @"type": [data objectForKey:@"type"]}];
    }
    
    [self issueCommand:MAKE_TAG priority:1 timeoutInSec:20 tagData:tagData timeStamp:GET_NOW_TIME];
}




-(void)onTelePost:(NSNotification *)note
{
//    NSMutableDictionary * data   = [NSMutableDictionary dictionaryWithDictionary:note.userInfo];
//    
//    NSString *tagTime = [data objectForKey:@"time"];// just to make sure they are added
//    NSString *tagName = [data objectForKey:@"name"];// just to make sure they are added
//    NSString *eventNm = (self.event.live)?LIVE_EVENT:self.event.name;
//    
//    // This is the starndard info that is collected from the encoder
//    NSMutableDictionary * tagData = [NSMutableDictionary dictionaryWithDictionary:
//                                     @{
//                                       @"event"         : eventNm,
//                                       @"colour"        : [UserCenter getInstance].customerColor,
//                                       @"user"          : [UserCenter getInstance].userHID,
//                                       @"time"          : tagTime,
//                                       @"name"          : tagName,
//                                       @"duration"      : @"1",
//                                       @"type"          : @"4",
//                                       }];
//    
//    [tagData addEntriesFromDictionary:data];
//    
//    [self issueCommand:MAKE_TELE_TAG priority:1 timeoutInSec:20 tagData:tagData timeStamp:GET_NOW_TIME];
    
}

-(void)onModTag:(NSNotification *)note
{
    
    NSMutableDictionary * dict;
    
    if (!note.object && note.userInfo) {
        
        dict = [NSMutableDictionary dictionaryWithDictionary:note.userInfo];
        
        ///@"event"         : (tagToModify.isLive)?LIVE_EVENT:tagToModify.event.name, // LIVE_EVENT == @"live"
        
        
        if ([self.event.name isEqualToString:dict[@"event"]] && self.event.live) {
            dict[@"event"] = LIVE_EVENT;
        }
        
    } else {
        Tag *tagToModify = note.object;
        dict = [NSMutableDictionary dictionaryWithDictionary:
                @{
                  @"displaytime"   : tagToModify.displayTime,
                  @"deviceid"      : [[[UIDevice currentDevice] identifierForVendor]UUIDString],
                  @"colour"        : tagToModify.colour,
                  @"event"         : (tagToModify.isLive)?LIVE_EVENT:tagToModify.event.name, // LIVE_EVENT == @"live"
                  @"id"            : tagToModify.ID, 
                  @"requesttime"   : GET_NOW_TIME_STRING,
                  @"name"          : tagToModify.name,
                  @"user"          : tagToModify.user
                  }];
        
        
        [dict addEntriesFromDictionary: [tagToModify modifiedData]];
        
        if (tagToModify.isLive) {
            [dict setObject:LIVE_EVENT forKey:@"event"];
        }
    }
    
    
    
    
    
    
    [self issueCommand:MODIFY_TAG priority:10 timeoutInSec:5 tagData:dict timeStamp:GET_NOW_TIME];
}

-(void)onDeleteTag:(NSNotification *)note
{
    Tag *tagToDelete = note.object;
    tagToDelete.type = 3;
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:
                                  @{
                                    @"type"          : @"3",
                                    @"delete"        : @"1",
                                    @"event"         : (tagToDelete.isLive)?LIVE_EVENT:tagToDelete.event.name, // LIVE_EVENT == @"live"
                                    @"id"            : tagToDelete.ID,
                                    @"requesttime"   : GET_NOW_TIME_STRING,
                                    @"user"          : tagToDelete.user
                                    }];
    
    [self issueCommand:MODIFY_TAG priority:10 timeoutInSec:5 tagData:dict timeStamp:GET_NOW_TIME];
}


-(void)ondeleteEvent:(NSNotification *)note
{
//    Event *eventToDelete = note.object;
//    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
//                                                                                @"name": eventToDelete.name,
//                                                                                @"hid": eventToDelete.hid
//                                                                                }];
//    
//    [self issueCommand:DELETE_EVENT priority:10 timeoutInSec:5 tagData:dict timeStamp:GET_NOW_TIME];
}

-(void)onDownloadClip:(NSNotification *)note
{
// this should cut an MP4
}










#pragma mark - Command Methods
-(void)makeTag:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp
{
    
    //over write add request time
    [tData addEntriesFromDictionary:@{
                                      @"requesttime"    : [NSString stringWithFormat:@"%f",CACurrentMediaTime()]
                                      }];

    Tag *newTag                     = [[Tag alloc] initWithData:tData event:self.event];
    NSDictionary *tagArePresent     = [[NSDictionary alloc]initWithDictionary:self.event.rawData[@"tags"]];
    double tagArePresentCount       = tagArePresent.count + 1;
    newTag.uniqueID                 = tagArePresentCount;
    
    if ([[tData objectForKey:@"type"]integerValue] == TagTypeOpenDuration) {
        newTag.startTime = newTag.time;
        newTag.durationID = [tData objectForKey:@"dtagid"];
    }else{
        double newStartTime = newTag.time - 10.0;
        if (newStartTime < 0) {
            newStartTime = 0.0;
        }else{
            newTag.startTime = newStartTime;
        }
        newTag.duration = 20.0;
    }
    
    newTag.displayTime              = [Utility translateTimeFormat: newTag.time];
    newTag.own                      = YES;
    newTag.homeTeam                 = self.event.teams[@"homeTeam"];
    newTag.visitTeam                = self.event.teams[@"visitTeam"];
    newTag.synced                   = NO;

    [self.event addTag:newTag extraData:true];

    [self.localTags addObject:newTag];
    
    [self writeToPlist];
   /* //[self.event.localTags setObject:newTag.makeTagData forKey: [NSString stringWithFormat:@"%lu",(unsigned long)self.event.localTags.count]];
    [self.localTags setObject:[newTag makeTagData] forKey:[NSString stringWithFormat:@"%lu",(unsigned long)self.localTags.count]];
    
    NSString * plistNamePath = [[[_localPath stringByAppendingPathComponent:@"events"] stringByAppendingPathComponent:self.event.datapath]stringByAppendingPathExtension:@"plist"];
    [self.event.rawData writeToFile:plistNamePath atomically:YES];
    
    NSString * localplistNamePath = [[_localPath stringByAppendingPathComponent:@"localTags"] stringByAppendingPathExtension:@"plist"];
    [self.localTags writeToFile:localplistNamePath atomically:YES];*/

//    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_TAG_RECEIVED object:newTag userInfo:newTag.makeTagData];

}

-(void)modTag:(NSMutableDictionary *)tData {
    
    
    
    for (Tag *tag in self.event.tags) {
        if ([tag.ID isEqualToString:tData[@"id"]]) {
            if (![self.localTags containsObject:tag] && ![self.modifiedTags containsObject:tag])  {
                [self.modifiedTags addObject:tag];
            }
        }
    }
    
    [self.event modifyTag:tData];
    
    [self writeToPlist];
    
    /*NSString * plistNamePath = [[[_localPath stringByAppendingPathComponent:@"events"] stringByAppendingPathComponent:self.event.datapath]stringByAppendingPathExtension:@"plist"];
    [self.event.rawData writeToFile:plistNamePath atomically:YES];
    
    NSString * localplistNamePath = [[_localPath stringByAppendingPathComponent:@"localTags"] stringByAppendingPathExtension:@"plist"];
    [self.localTags writeToFile:localplistNamePath atomically:YES];*/
}

-(void)checkEncoder{
    if (self.encoderManager.masterEncoder) {
        
        
        [[LocalMediaManager getInstance] assignEncoderVersionEvent:self.encoderManager.masterEncoder.allEvents];
        if (!self.localTags && !self.modifiedTags) {
            [self syncTagsFromEncoder];
        }else{
            [self builtEncoderEvent];
        }
        
        //[self checkLocalTags];
        //[self syncEvents];
    }
}

// Check if all event that need to be build before updating tags is build
-(void)onEventBuildFinished:(Event *)event{
    event.delegate = nil;
    
    NSMutableSet *eventToBeBuilt = [[NSMutableSet alloc]init];
    BOOL *allBuilt = true;
    
    for (Tag *tag in self.localTags) {
        [eventToBeBuilt addObject:tag.event];
    }
    
    for (Tag *tag in self.modifiedTags) {
        [eventToBeBuilt addObject:tag.event];
    }
    
    for (Event *event in eventToBeBuilt) {
        NSMutableDictionary *eventFinal = [[LocalMediaManager getInstance].allEvents objectForKey:event.name];
        Event *encoderEvent = [eventFinal objectForKey:@"non-local"];

        if (!encoderEvent.isBuilt) {
            allBuilt = false;
        }
    }
    
    if (allBuilt) {
        [self updateLocalTags];
    }

}

/*-(void)checkLocalTags{
    if (self.localTags.count >= 1 && self.encoderManager.masterEncoder) {

    //NSArray *arrya = [[NSArray alloc]initWithArray:[self.localTags allValues]];
        //Tag *tagToSend = [[Tag alloc]initWithData:[arrya firstObject] event:self.event];
        //NSArray *arrya = [self.localTags allValues];
        Tag *tag = [self.localTags firstObject];
        
        //Event *event = [self.encoderManager.masterEncoder.allEvents objectForKey:tagToSend[@"event"]];
        if (![[self.encoderManager.masterEncoder.allEvents objectForKey:tag.event.name] isBuilt]) {
            [self.encoderManager requestTagDataForEvent:tag.event.name onComplete:nil];
        }

        NSDictionary *tData = [tag makeTagData];
        NSString *jsonString                    = [Utility dictToJSON:tData];
        NSString *ipAddress                     = self.encoderManager.masterEncoder.ipAddress;
        NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"http://%@/min/ajax/tagset/%@", ipAddress ,jsonString]  ];
        NSURLRequest *urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0];
        encoderConnection                       = [[NSURLDataConnection alloc] initWithRequest:urlRequest delegate:self];
        encoderConnection.context        = MAKE_TAG;
        }
}*/

// Built all the event that have local tags to upload or modify
-(void)builtEncoderEvent{
    NSMutableSet *eventToBeBuilt = [[NSMutableSet alloc]init];
    
    for (Tag *tag in self.localTags) {
        [eventToBeBuilt addObject:tag.event];
    }
    
    for (Tag *tag in self.modifiedTags) {
        [eventToBeBuilt addObject:tag.event];
    }
    
    for (Event *event in eventToBeBuilt ) {
        NSMutableDictionary *eventDic = [[LocalMediaManager getInstance].allEvents objectForKey:event.name];
        Event *encoderEvent = [eventDic objectForKey:@"non-local"];
        if (!encoderEvent.isBuilt && encoderEvent) {
            [encoderEvent setDelegate:self];
            [self.encoderManager requestTagDataForEvent:encoderEvent.name onComplete:nil];
        }
    }
}


// Updating all the locally made or modified tags
-(void)updateLocalTags{
    
    if (self.localTags.count >= 1 && self.encoderManager.masterEncoder) {
        for (Tag *tag in self.localTags) {
            NSMutableDictionary *eventFinal = [[LocalMediaManager getInstance].allEvents objectForKey:tag.event.name];
            Event *encoderEvent = [eventFinal objectForKey:@"non-local"];
            if (encoderEvent) {
                [encoderEvent.parentEncoder issueCommand:MAKE_TAG priority:1 timeoutInSec:20 tagData:[[NSMutableDictionary alloc]initWithDictionary:[tag makeTagData]] timeStamp:GET_NOW_TIME];
            }
        }
    }
    
    if (self.modifiedTags.count >= 1 && self.encoderManager.masterEncoder) {
        for (Tag *tag in self.modifiedTags) {
            
            NSMutableDictionary *eventFinal = [[LocalMediaManager getInstance].allEvents objectForKey:tag.event.name];
            Event *encoderEvent = [eventFinal objectForKey:@"non-local"];
            if (encoderEvent) {
                [encoderEvent.parentEncoder issueCommand:MODIFY_TAG priority:1 timeoutInSec:20 tagData:[[NSMutableDictionary alloc]initWithDictionary:[tag makeTagData]] timeStamp:GET_NOW_TIME];
            }
        }

    }
    
    [self.localTags removeAllObjects];
    [self.modifiedTags removeAllObjects];
    [self writeToPlist];
    [self syncTagsFromEncoder];
}

-(void)syncTagsFromEncoder{
    for (NSMutableDictionary *eventDic in [[LocalMediaManager getInstance].allEvents allValues]) {
        Event *encoderEvent = eventDic[@"non-local"];
        Event *localEvent = eventDic[@"local"];
        if (encoderEvent.isBuilt && localEvent.isBuilt) {
            for (Tag *tag in encoderEvent.tags) {
                if (![localEvent.tags containsObject:tag]) {
                    Tag *localTag = [[Tag alloc]initWithData:[tag makeTagData] event:localEvent];
                    [localEvent.tags addObject:tag];
                }
            }
        }
    }
    [self writeToPlist];
}


/*-(void)modifyLocalTags{
    NSArray *allEvent = [[LocalMediaManager getInstance].allEvents allValues];
    for (Event *event in allEvent) {
        for (Tag *tag in event.tags) {
            if (tag.modified) {
                
            }
        }
    }
}*/



#pragma mark - Event Download
-(void)syncEvents{
    NSArray *allEvents = [[LocalMediaManager getInstance].allEvents allValues];
    for (int i = 0; i < [LocalMediaManager getInstance].allEvents.count; ++i) {
        Event *eventToSync = allEvents[i];
        NSDictionary *tData = @{
                                @"device":[[[UIDevice currentDevice] identifierForVendor]UUIDString],
                                @"event": eventToSync.name,
                                @"requesttime": [NSString stringWithFormat:@"%f",CACurrentMediaTime()],
                                @"user": [UserCenter getInstance].userHID
                                };
        
        
        NSString *jsonString                    = [Utility dictToJSON:tData];
        
        NSString *ipAddress                     = self.encoderManager.masterEncoder.ipAddress;
        NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"http://%@/min/ajax/gametags/%@", ipAddress,jsonString]  ];
        NSURLRequest *urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0];
        //NSURLDataConnection *urlConnection                    = [[NSURLDataConnection alloc]initWithRequest:urlRequest delegate:self];
        //urlConnection.context = TAG_SYNC;
        encoderConnection                       = [[NSURLDataConnection alloc] initWithRequest:urlRequest delegate:self];
        //encoderConnection.context        = TAG_SYNC;
    }
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
    if (connection.context == NEW_TAG_UPLOAD) {
        NSData *dataToBeUsed = [connection.cumulatedData copy];
        NSDictionary    * results =[Utility JSONDatatoDict: dataToBeUsed];
        if([results isKindOfClass:[NSDictionary class]])
        {
            if ( ![[results objectForKey:@"success"]integerValue] ) {
                PXPLog(@"Encoder Error!!");
                PXPLog(@"   %@",[results objectForKey:@"msg"]);
                return;
            }
            [self.localTags removeObjectAtIndex:0];
            [self writeToPlist];
        }
        
        //[self checkLocalTags];
        
    }else if (connection.context == OLD_TAG_UPDATE){
        NSDictionary    * results =[Utility JSONDatatoDict:connection.cumulatedData];
        
        if (results){
            NSDictionary    * tags = [results objectForKey:@"tags"];
            if (tags) {
              
                
            }
        }
    }
    
}

/*-(void)connectionDidFinishLoading:(NSURLDataConnection *)connection{
    if (connection.context == TAG_UPLOAD) {
        NSData *dataToBeUsed = [connection.cumulatedData copy];
        NSDictionary    * results =[Utility JSONDatatoDict: dataToBeUsed];
        if([results isKindOfClass:[NSDictionary class]])
        {
            if ( ![[results objectForKey:@"success"]integerValue] ) {
                PXPLog(@"Encoder Error!!");
                PXPLog(@"   %@",[results objectForKey:@"msg"]);
                return;
            }
            
            NSArray *arrayFromDic = [[NSArray alloc]initWithArray:[self.localTags allValues]];
             Tag *localTag = [[Tag alloc]initWithData:[arrayFromDic firstObject] event:self.event];
            Tag *localTag = [self.localTags firstObject];
            [localTag replaceDataWithDictionary: results];
            for (Event *event in [[LocalMediaManager getInstance].allEvents allValues]) {
                if ([[event.localTags allValues] containsObject: localTag]){
                    [event addTag:localTag];
                    //[event addTag:localTag];
                    //[event.tags addObject:localTag];
                    //[event.tags addEntriesFromDictionary: @{[NSString stringWithFormat: @"%i", localTag.uniqueID]:localTag }];
                    [event.localTags removeObjectForKey:[[event.localTags allKeysForObject: localTag] firstObject]];
                }
            }
            NSArray *array = [[NSArray alloc]initWithArray:[self.localTags allKeys]];
             NSString *keyref;
             for (NSString *key in array ) {
             keyref = key;
             break;
             }
             if (keyref) [self.localTags removeObjectForKey:keyref];
             NSString * localplistNamePath = [[_localPath stringByAppendingPathComponent:@"localTags"] stringByAppendingPathExtension:@"plist"];
             [self.localTags writeToFile:localplistNamePath atomically:YES];
             
             //[self.localTags removeObject: localTag];
            
            [self.localTags removeObjectAtIndex:0];
            [self writeToPlist];
            
        }
        
        [self checkLocalTags];
        
    }else if (connection.context == TAG_SYNC){
        NSDictionary    * results =[Utility JSONDatatoDict:connection.cumulatedData];
        
        if (results){
            NSDictionary    * tags = [results objectForKey:@"tags"];
            if (tags) {
                Event *theEvent;
                Tag *firstTag = [[Tag alloc] initWithData:[[tags allValues]firstObject] event:self.event];
                for (Event *event in [[LocalMediaManager getInstance].allEvents allValues]) {
                    if ([event.rawData[@"hid"] isEqualToString: firstTag.event.hid]) {
                        theEvent = event;
                    }
                }
                
                for (NSDictionary *newDic in [tags allValues]) {
                    Tag *newTag = [[Tag alloc]initWithData:newDic event:self.event];
                    if (![theEvent.tags containsObject: newTag]) {
                        [theEvent addTag:newTag];
                        //[theEvent addTag:newTag];
                        //[theEvent.tags addObject:newTag];
                        //[theEvent.tags addEntriesFromDictionary:@{[NSString stringWithFormat:@"%d", newTag.uniqueID]: newTag}];
                    }
                }
                
                
            }
        }
    }else if (connection.context == EVENT_GET_TAGS){
        
    }
    
    
    isSuccess   = YES;
    isFinished  = YES;
    if (self.delegate) {
        [self.delegate onSuccess:self];
    }
    
}*/
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
   /* NSArray *arrayFromDic = [[NSArray alloc]initWithArray:[self.localTags allValues]];
    NSDictionary *dicToBeRemoved = [[NSDictionary alloc]initWithDictionary:[arrayFromDic firstObject]];
    NSString *keyToBeRemoved = dicToBeRemoved[@"id"];
    [self.localTags removeObjectForKey:keyToBeRemoved];*/
    //[self.localTags removeObjectAtIndex:0];
    //[self.localTags removeObjectAtIndex:0];
    //[self checkLocalTags];
    isSuccess   = NO;
    isFinished  = YES;
    if (self.delegate) {
        [self.delegate onFail:self];
    }
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
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_EVENT_CHANGE object:self];
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




/*-(NSString*)bookmarkPath
{
    return [NSString stringWithFormat:@"%@/bookmark",_localPath];
}

-(NSString*)bookmarkedVideosPath
{
    return [NSString stringWithFormat:@"%@/bookmark/bookmarkvideo",_localPath];
}


 *
 *  This get all the plists in the bookmark folder on the device
 *  the plists are labeled as such 1.plist, 2.plist, 3.plist...
 
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

*
 *  Grabs all files from a directory with and extention 
 *  will create a directory if its not there
 *
 *  @param aPath <#aPath description#>
 *  @param ext   <#ext description#>
 *
 *  @return <#return value description#>
 
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
}*/


/**
 *  This will check the bookmark folder on the device and give a number that will be used for the name of the video that will be used
 *
 *  @return n
 */
-(NSInteger)getBookmarkSpace
{
    return 0;
}





/*#pragma mark - Bookmark Clip Methods

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


*
 *  This saves the clip. This method only saves one source at a time
 *
 *  @param aName   !!! This name has to change
 *  @param tagData the data for the raw clip
 
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







*
 *  This saves sent Events by taking the raw data and then making a dir to store the videos and then writes the plist
 *
 *  @param aEvent Event to Save as plist
 *
 *  @return returns path of folder to save the videos
 
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
    anEvent.parentEncoder = self;
//    anEvent.local   = YES;
    //anEvent.downloadedSources = [[self listDownloadSourcesFor:anEvent] mutableCopy];
    
    
    NSMutableDictionary            * allEventsMutable =  [_allEvents mutableCopy];
    [allEventsMutable setObject:anEvent forKey:anEvent.hid];
    _allEvents = [allEventsMutable copy];
    return aPath;
}*/



/**
 *  This deletes the event from the device
 *
 *  @param aEvent the event you want to delete from the device
 */
-(void)deleteEvent:(Event*)aEvent
{
    
    /*if (aEvent == nil || !aEvent.local) {
        NSLog(@"CAN NOT DELETE NON LOCAL EVENTS");
        return;
    }
    
    NSString * aPath = [[_localPath stringByAppendingPathComponent:@"events"] stringByAppendingPathComponent:aEvent.datapath];
    
    
    [[NSFileManager defaultManager] removeItemAtPath:aPath error:NULL]; // deletes the folder
    [[NSFileManager defaultManager] removeItemAtPath: [aPath stringByAppendingPathExtension:@"plist"] error:NULL]; // delets the plist
    
    NSMutableDictionary * temp = [NSMutableDictionary dictionaryWithDictionary:_allEvents];
    [temp removeObjectForKey:aEvent.hid];
    
    _allEvents = [temp copy];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_UPDATE_MEMORY object:nil];*/
    
    
    [[LocalMediaManager getInstance] deleteEvent:aEvent];
    // This is run when the current playing event is deleted
    if (_event == aEvent){
        _event = nil;
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_CURRENT_LOCAL_EVENT_DELETED object:nil];
    }
}

/*-(int)gap:(NSArray*)list first:(int)first last:(int)last
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


*
 *  Validate clip names
 *
 *  @param check file name
 *
 *  @return is valid
 
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
}*/

// ActionListItem Methods

-(void)start
{
    isFinished = NO;
}




//debugging
#pragma mark - debugging


// This will show name and status
-(NSString*)description
{
    NSString * bookmarkPath = [NSString stringWithFormat:@"%@/bookmark",_localPath];
    NSString * txt = [NSString stringWithFormat:@" %@: %ld - %@   - %@\nBookmark Path:%@",self.name,(long)self.status,self.event.name,self.event.eventType,  bookmarkPath ];
    return txt;
}


@end
