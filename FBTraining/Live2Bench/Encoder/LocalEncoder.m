
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
#import "TagProtocol.h"
#import "UserCenter.h"
#import "LocalMediaManager.h"
#import "UserCenter.h"

#define LOCAL_PLIST     @"EventsHid.plist"
#define VIDEO_EXT       @"mp4"

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

    NSMutableArray  * tagSyncConnections;
//    NSURLDataConnection *encoderConnection;
    NSDictionary    * closeTags;
    NSOperationQueue * operationQueue; // new
}

@synthesize name            = _name;
@synthesize event           = _event;
@synthesize status          = _status;
@synthesize allEvents       = _allEvents;


@synthesize eventContext = _eventContext;

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
         _localPath                      = aDocsPath;
        _status                         = ENCODER_STATUS_LOCAL;
        _event                          = nil;
        _localTags                      = [[NSMutableArray alloc] init];
        _modifiedTags                   = [[NSMutableArray alloc] init];
        tagSyncConnections              = [NSMutableArray array];
//        _eventContext                   = [PxpEventContext context];
        _urlProtocol                    = @"local";
        _ipAddress                      = @"ip";
        _version                        = @"local";
        closeTags = @{[NSNumber numberWithInteger:TagTypeSoccerZoneStart]:[NSNumber numberWithInteger:TagTypeSoccerZoneStop],[NSNumber numberWithInteger:TagTypeSoccerHalfStart]:[NSNumber numberWithInteger:TagTypeSoccerHalfStop],[NSNumber numberWithInteger:TagTypeHockeyPeriodStart]:[NSNumber numberWithInteger:TagTypeHockeyPeriodStop],[NSNumber numberWithInteger:TagTypeHockeyStrengthStart]:[NSNumber numberWithInteger:TagTypeHockeyStrengthStop],[NSNumber numberWithInteger:TagTypeHockeyStartOLine]:[NSNumber numberWithInteger:TagTypeHockeyStopOLine],[NSNumber numberWithInteger:TagTypeHockeyStartDLine]:[NSNumber numberWithInteger:TagTypeHockeyStopDLine],[NSNumber numberWithInteger:TagTypeFootballQuarterStart]:[NSNumber numberWithInteger:TagTypeFootballQuarterStop]};
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkEncoder) name:NOTIF_EM_FOUND_MASTER object:nil];
  
        instance = self;
        self.cameraResource = [CameraResource new];
        
        NSLog(@"LocalEncoder local path: %@", _localPath);
        
//        NSString * aPath = [_localPath stringByAppendingPathComponent:@"localTags.plist"];
//        NSDictionary * rawLocaltagData = [NSDictionary dictionaryWithContentsOfFile:aPath];
//        NSArray * locTagsRaw = [rawLocaltagData allValues];
        
//        for (NSDictionary * aTagRaw in locTagsRaw) {
//            Tag *aTag = [Tag alloc]ini
            
//            [_localTags addObject:aTag];
//        }
        
        NSLog(@"%s",__FUNCTION__);

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
    }else if ([methodName isEqualToString:MAKE_TELE_TAG]){
        [self teleTag:tData];
    }
    
    
}

-(void) writeToPlist{
    
    for (NSMutableDictionary *eventDic in [[LocalMediaManager getInstance].allEvents allValues]) {
        Event *localEvent = eventDic[@"local"];
        NSString * plistNamePath = [[[_localPath stringByAppendingPathComponent:@"events"] stringByAppendingPathComponent:localEvent.datapath]stringByAppendingPathExtension:@"plist"];
  
        if (![localEvent.rawData writeToFile:plistNamePath atomically:YES]) {
            NSLog(@"error writing event");
        }
        
    }

// local tags write to plist
    NSMutableDictionary *data = [[NSMutableDictionary alloc]init];
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
}


#pragma mark - Observer

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
    NSMutableDictionary * data   = [NSMutableDictionary dictionaryWithDictionary:note.userInfo];
    
    NSString *tagTime = [data objectForKey:@"time"];// just to make sure they are added
    NSString *tagDuration = [data objectForKey:@"duration"];// just to make sure they are added
    NSData *teleData = [data objectForKey:@"telestration"];
    NSString *eventNm = (self.event.live)?LIVE_EVENT:self.event.name;
    
    // This is the starndard info that is collected from the encoder
    NSMutableDictionary * tagData = [NSMutableDictionary dictionaryWithDictionary:
                                     @{
                                       @"event"         : eventNm,
                                       @"colour"        : [Utility hexStringFromColor: [UserCenter getInstance].customerColor],
                                       @"user"          : [UserCenter getInstance].userHID,
                                       @"time"          : tagTime,
                                       @"name"          : @"Tele",
                                       @"duration"      : tagDuration,
                                       @"type"          : [NSNumber numberWithInteger:TagTypeTele],
                                       @"telestration"  : teleData,
                                       @"deviceid"      : [[[UIDevice currentDevice] identifierForVendor]UUIDString]
                                       }];
    
    
    [self issueCommand:MAKE_TELE_TAG priority:1 timeoutInSec:20 tagData:tagData timeStamp:GET_NOW_TIME];
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
                  @"event"         : (tagToModify.isLive)?LIVE_EVENT:tagToModify.event, // LIVE_EVENT == @"live"
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
                                    @"event"         : (tagToDelete.isLive)?LIVE_EVENT:tagToDelete.event, // LIVE_EVENT == @"live"
                                    @"id"            : tagToDelete.ID,
                                    @"requesttime"   : GET_NOW_TIME_STRING,
                                    @"user"          : tagToDelete.user
                                    }];
    
    [self issueCommand:MODIFY_TAG priority:10 timeoutInSec:5 tagData:dict timeStamp:GET_NOW_TIME];
}


-(void)ondeleteEvent:(NSNotification *)note
{
    Event *eventToDelete = note.object;
    [[LocalMediaManager getInstance] deleteEvent:eventToDelete];
}

-(void)onDownloadClip:(NSNotification *)note
{
    Tag *tag = note.userInfo[@"tag"];
    NSString * srcID = note.userInfo[@"key"];
    
    Feed *feed = self.event.feeds[srcID];
    NSString *vidURL = feed.path.path;

    __block void(^dItemBlock)(DownloadItem*) = note.userInfo[@"block"];
    

        NSString * videoName = [NSString stringWithFormat:@"%@_vid_%@+%@hq.mp4",self.event.name,tag.ID, srcID];
 
//        //NSString * pth = [NSString stringWithFormat:@"%@/%@",[[LocalEncoder getInstance] bookmarkedVideosPath],videoName];
        NSString * pth = [NSString stringWithFormat:@"%@/%@",[[LocalMediaManager getInstance] bookmarkedVideosPath] ,videoName];
//        DownloadItem * dli = [Downloader downloadURL:vidURL to:pth type:DownloadItem_TypeVideo key:[NSString stringWithFormat:@"%@-%@",tag.ID,srcIDwithQ ]];
    
    CMTime sTime  = CMTimeMakeWithSeconds(tag.startTime, 600);
    CMTime dur = CMTimeMakeWithSeconds(tag.duration, 600);
    CMTimeRange tr = CMTimeRangeMake(sTime, dur);

    DownloadItem * dli = [Downloader trimVideoURL:vidURL to:pth withTimeRange:tr key:[NSString stringWithFormat:@"%@-%@",tag.ID,srcID ]];

        dItemBlock(dli);

        [[NSNotificationCenter defaultCenter] addObserverForName:NOTIF_DOWNLOAD_COMPLETE object:nil queue:nil usingBlock:^(NSNotification *note) {
            // is the object what we ware downloading
            if (note.object == dli) {
                NSLog(@"Download Complete");
                [[LocalMediaManager getInstance] saveClip:videoName withData:tag.rawData];

            }
        }];

    PXPLog(@"Downloading Clip!");
    
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
//    double tagArePresentCount       = tagArePresent.count + 1;
//    newTag.uniqueID                 = tagArePresentCount;
    
    // BCH: this is a terrible choice.
    newTag.uniqueID                 = (int)[self.event.tags count]+100;
    
    newTag.displayTime              = [Utility translateTimeFormat: newTag.time];
    newTag.own                      = YES;
    newTag.homeTeam                 = ((LeagueTeam*)self.event.teams[@"homeTeam"]).name;
    newTag.visitTeam                = ((LeagueTeam*)self.event.teams[@"visitTeam"]).name;
    newTag.synced                   = NO;
    
    if ([[tData objectForKey:@"type"]integerValue] == TagTypeOpenDuration) {
        newTag.startTime = newTag.time;
        newTag.durationID = [tData objectForKey:@"dtagid"];
        [self.event addTag:newTag extraData:false];
    }else{
        
        double newStartTime = newTag.time - [UserCenter getInstance].preRoll;
        if (newStartTime < 0) {
            newStartTime = 0.0;
        }else{
            newTag.startTime = newStartTime;
        }
        newTag.duration = [UserCenter getInstance].postRoll + [UserCenter getInstance].preRoll;
        [self.event addTag:newTag extraData:true];

    }

   
//    TagProxy * proxy = [[TagProxy alloc]init];
//    proxy.colour      = newTag.colour;
//    proxy.comment     = newTag.comment;
//    proxy.deviceID    = newTag.deviceID;
//    proxy.duration    = newTag.duration;
//    proxy.event       = newTag.event;
//    proxy.ID          = newTag.ID;
//    proxy.name        = newTag.name;
//    proxy.rating      = newTag.rating;
//    proxy.time        = newTag.time;
//    proxy.displayTime = newTag.displayTime;
//    proxy.startTime   = newTag.startTime;
//    proxy.user        = newTag.user;
//    

    
    [self.localTagSyncManager addTag:[newTag rawData]];
    
//    [self.localTags addObject:newTag];
    
    [self writeToPlist];
    
    if ([closeTags objectForKey:[NSNumber numberWithInteger:newTag.type]]) {
        for (Tag *tag in self.event.tags) {
            if (tag.type == newTag.type && tag != newTag)
            {
                tag.duration = newTag.time - tag.time;
                tag.type = [[closeTags objectForKey:[NSNumber numberWithInteger:newTag.type]]intValue];
                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MODIFY_TAG object:tag];
            }
        }
    }
}

-(void)teleTag:(NSMutableDictionary *)tData{
    
    [tData addEntriesFromDictionary:@{
                                      @"requesttime"    : [NSString stringWithFormat:@"%f",CACurrentMediaTime()]
                                      }];
    
    Tag *newTag                     = [[Tag alloc] initWithData:tData event:self.event];
    NSDictionary *tagArePresent     = [[NSDictionary alloc]initWithDictionary:self.event.rawData[@"tags"]];
    double tagArePresentCount       = tagArePresent.count + 1;
    newTag.uniqueID                 = tagArePresentCount;
    newTag.startTime                = newTag.time;
    newTag.displayTime              = [Utility translateTimeFormat: newTag.time];
    
    newTag.own                      = YES;
    newTag.homeTeam                 = self.event.teams[@"homeTeam"];
    newTag.visitTeam                = self.event.teams[@"visitTeam"];
    newTag.synced                   = NO;
    
    [self.event addTag:newTag extraData:true];
    
    [self.localTags addObject:newTag];
    
    [self writeToPlist];

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
    [self.localTagSyncManager addMod:tData];
    [self writeToPlist];
}

-(void)checkEncoder{
    if (self.encoderManager.masterEncoder) {
        [[LocalMediaManager getInstance] assignEncoderVersionEvent:self.encoderManager.masterEncoder.allEvents];
        [self builtEncoderEvent];
    }
}

-(Event*)searchEventByName:(NSString*)eventName{
    NSDictionary *dict = [self.encoderManager.masterEncoder.allEvents objectForKey:eventName];
    return dict[@"non-local"];
}

// Check if all event that need to be build before updating tags is build
-(void)onEventBuildFinished:(Event *)event{
    event.delegate = nil;
    
    NSMutableSet *eventToBeBuilt = [[NSMutableSet alloc]init];
    BOOL allBuilt = YES;
    
    for (Tag *tag in self.localTags) {
        [eventToBeBuilt addObject:tag.event];
    }
    
    for (Tag *tag in self.modifiedTags) {
        [eventToBeBuilt addObject:tag.event];
    }
    
    for (NSMutableDictionary *eventDic in [[LocalMediaManager getInstance].allEvents allValues]) {
        Event *localEvent = [eventDic objectForKey:@"local"];
        [eventToBeBuilt addObject:localEvent];
    }
    
    for (Event *event in eventToBeBuilt) {
        NSMutableDictionary *eventFinal = [[LocalMediaManager getInstance].allEvents objectForKey:event];
        Event *encoderEvent = [eventFinal objectForKey:@"non-local"];

        if (!encoderEvent.isBuilt && encoderEvent) {
            allBuilt = false;
        }
    }
    
    if (allBuilt) {
        [self updateLocalTags];
    }

}


// Built all the event that have local tags to upload or modify
-(void)builtEncoderEvent{
    NSMutableSet *eventToBeBuilt = [[NSMutableSet alloc]init];
    
    for (Tag *tag in self.localTags) {
        [eventToBeBuilt addObject:tag.event];
    }
    
    for (Tag *tag in self.modifiedTags) {
        [eventToBeBuilt addObject:tag.event];
    }
    
    for (NSMutableDictionary *eventDic in [[LocalMediaManager getInstance].allEvents allValues]) {
        Event *localEvent = [eventDic objectForKey:@"local"];
        [eventToBeBuilt addObject:localEvent];
    }
    
    for (Event *event in eventToBeBuilt ) {
        NSMutableDictionary *eventDic = [[LocalMediaManager getInstance].allEvents objectForKey:event];
        Event *encoderEvent = [eventDic objectForKey:@"non-local"];
        if (!encoderEvent.isBuilt && encoderEvent) {
            [encoderEvent setDelegate:self];
            [encoderEvent build];
            //[self.encoderManager requestTagDataForEvent:encoderEvent.name onComplete:nil];
        }
    }
}


// Updating all the locally made or modified tags
-(void)updateLocalTags{
    
    if (self.localTags.count >= 1 && self.encoderManager.masterEncoder) {
        for (Tag *tag in self.localTags) {
            NSMutableDictionary *eventFinal = [[LocalMediaManager getInstance].allEvents objectForKey:tag.event];
            Event *encoderEvent = [eventFinal objectForKey:@"non-local"];
            if (encoderEvent.isBuilt) {
                [encoderEvent.parentEncoder issueCommand:MAKE_TAG priority:1 timeoutInSec:20 tagData:[[NSMutableDictionary alloc]initWithDictionary:[tag makeTagData]] timeStamp:GET_NOW_TIME];
            }
        }
    }
    
    if (self.modifiedTags.count >= 1 && self.encoderManager.masterEncoder) {
        for (Tag *tag in self.modifiedTags) {
            
            NSMutableDictionary *eventFinal = [[LocalMediaManager getInstance].allEvents objectForKey:tag.event];
            Event *encoderEvent = [eventFinal objectForKey:@"non-local"];
            if (encoderEvent.isBuilt) {
                [encoderEvent.parentEncoder issueCommand:MODIFY_TAG priority:1 timeoutInSec:20 tagData:[[NSMutableDictionary alloc]initWithDictionary:[tag makeTagData]] timeStamp:GET_NOW_TIME];
            }
        }

    }
    
//    [self.localTags removeAllObjects];
//    [self.modifiedTags removeAllObjects];
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
                    [localEvent.tags addObject:localTag];
                }
            }
            NSArray *localEventArray = [localEvent.tags copy];
            for (Tag *tag in localEventArray) {
                if (![encoderEvent.tags containsObject:tag]) {
                    [localEvent.tags removeObject:tag];
                }
            }
        }
    }
    [self writeToPlist];
}


#pragma mark - Responces

-(void)teamsResponse:(NSMutableDictionary *)data
{

}

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

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{

    [self.localTags removeObjectAtIndex:0];
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
    _eventContext.event = event;
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_EVENT_CHANGE object:self userInfo:@{@"eventType":_event.eventType}];
}



/**
 *  This class is what buils the rest of the data from the encoder
 */
-(void)getAllEventsResponse:(NSData *)data
{

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


/**
 *  This deletes the event from the device
 *
 *  @param aEvent the event you want to delete from the device
 */
-(void)deleteEvent:(Event*)aEvent
{
    [[LocalMediaManager getInstance] deleteEvent:aEvent];
    // This is run when the current playing event is deleted
    if (_event == aEvent){
        _event = nil;
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_CURRENT_LOCAL_EVENT_DELETED object:nil];
    }
}


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

- (nullable Event *)getEventByName:(NSString *)eventName {
    return self.allEvents[eventName];
}

-(void)resetEventAfterRemovingFeed:(Event *)event{
//    _event = event;
//    _eventContext.event = event;
}


-(void)runOperation:(EncoderOperation *)operation
{
    
    
    
    
    

    
    
    if ([operation isKindOfClass:[EncoderOperationMakeTag class]]) { // NOTIF_TAG_POSTED
        NSMutableDictionary * data   = [NSMutableDictionary dictionaryWithDictionary:operation.argData];
        
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

        [self makeTag:tagData  timeStamp: GET_NOW_TIME];
    } else if ([operation isKindOfClass:[EncoderOperationModTag class]]) { // NOTIF_MODIFY_TAG
        
        NSMutableDictionary * dict;
        
        if (operation.argData) {
            
            dict = [NSMutableDictionary dictionaryWithDictionary:operation.argData];
            
            ///@"event"         : (tagToModify.isLive)?LIVE_EVENT:tagToModify.event.name, // LIVE_EVENT == @"live"
            
            
            if ([self.event.name isEqualToString:dict[@"event"]] && self.event.live) {
                dict[@"event"] = LIVE_EVENT;
            }
            
        } else {
//            Tag *tagToModify = note.object;
//            dict = [NSMutableDictionary dictionaryWithDictionary:
//                    @{
//                      @"displaytime"   : tagToModify.displayTime,
//                      @"deviceid"      : [[[UIDevice currentDevice] identifierForVendor]UUIDString],
//                      @"colour"        : tagToModify.colour,
//                      @"event"         : (tagToModify.isLive)?LIVE_EVENT:tagToModify.event.name, // LIVE_EVENT == @"live"
//                      @"id"            : tagToModify.ID,
//                      @"requesttime"   : GET_NOW_TIME_STRING,
//                      @"name"          : tagToModify.name,
//                      @"user"          : tagToModify.user
//                      }];
//            
//            
//            [dict addEntriesFromDictionary: [tagToModify modifiedData]];
//            
//            if (tagToModify.isLive) {
//                [dict setObject:LIVE_EVENT forKey:@"event"];
//            }
        }
        
        
        [self modTag:dict];
    } else if ([operation isKindOfClass:[EncoderOperationMakeTelestration class]]) { // NOTIF_CREATE_TELE_TAG
        NSLog(@"TELE");
        NSMutableDictionary * data   = [NSMutableDictionary dictionaryWithDictionary:operation.argData];
        
        NSString *tagTime = [data objectForKey:@"time"];// just to make sure they are added
        
        // This is the starndard info that is collected from the encoder
        NSMutableDictionary * tagData = [NSMutableDictionary dictionaryWithDictionary:
                                         @{
                                           @"event"         : self.event.name,
                                           @"colour"        : [Utility hexStringFromColor: [UserCenter getInstance].customerColor],
                                           @"user"          : [UserCenter getInstance].userHID,
                                           @"time"          : tagTime,
                                           @"name"          : @"Telestration",
                                           @"deviceid"      : [[[UIDevice currentDevice] identifierForVendor]UUIDString],
                                           @"type"          : @"4"
                                           }];
        
        [tagData addEntriesFromDictionary:data];
        
        if ([[data objectForKey:@"type"] integerValue] == TagTypeOpenDuration) {
            [tagData addEntriesFromDictionary:@{ @"type": [data objectForKey:@"type"]}];
        }
        
     

        [self teleTag:tagData];
        
        
    }
    
//    else if ([operation isKindOfClass:[EncoderOperation class]]) { // NOTIF_DELETE_TAG
//        
//    } else if ([operation isKindOfClass:[EncoderOperation class]]) { // NOTIF_EM_DOWNLOAD_CLIP
//        

    
    
    
    [operation cancel];
}


@end
