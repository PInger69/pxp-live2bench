//
//  EncoderCommander.m
//  Live2BenchNative
//
//  Created by dev on 2015-06-08.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "EncoderCommander.h"
#import "UserCenter.h"


@implementation EncoderCommander
{
    id                          _masterFoundObserver;
}
@synthesize masterEncoder,allEncoders;
@synthesize event = _event;

#define GET_NOW_TIME        [NSNumber numberWithDouble:CACurrentMediaTime()]
#define GET_NOW_TIME_STRING [NSString stringWithFormat:@"%f",CACurrentMediaTime()]
#define trimSrc(s)  [Utility removeSubString:@"s_" in:(s)]

- (instancetype)init
{
    self = [super init];
    if (self) {
        allEncoders = [[NSMutableArray alloc]init];
        
        _masterFoundObserver = [[NSNotificationCenter defaultCenter]addObserverForName:NOTIF_ENCODER_MASTER_FOUND    object:nil queue:nil usingBlock:^(NSNotification *note) {
            masterEncoder = (Encoder *)note.object;
            
            if (masterEncoder.liveEvent) {
                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MASTER_HAS_LIVE object:nil];
            }
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_EM_FOUND_MASTER object:self];
            
        }];
    }
    return self;
}

-(id <EncoderProtocol>)makePrimary
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onTagPost:)        name:NOTIF_TAG_POSTED           object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onTelePost:)       name:NOTIF_CREATE_TELE_TAG      object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onModTag:)         name:NOTIF_MODIFY_TAG           object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onDeleteTag:)      name:NOTIF_DELETE_TAG           object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deleteEvent:)      name:NOTIF_DELETE_EVENT_SERVER  object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onDownloadClip:)   name:NOTIF_EM_DOWNLOAD_CLIP     object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onDownloadEvent:)  name:NOTIF_EM_DOWNLOAD_EVENT    object:nil];
    return self;
}

-(id <EncoderProtocol>)removeFromPrimary
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_TAG_POSTED              object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_CREATE_TELE_TAG         object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_MODIFY_TAG              object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_DELETE_TAG              object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_DELETE_EVENT_SERVER     object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_EM_DOWNLOAD_CLIP        object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_EM_DOWNLOAD_EVENT       object:nil];
    return self;
}
#pragma mark -
#pragma mark Observers
-(void)onTagPost:(NSNotification*)note
{
    PXPLog(@"Recieved a tage from the bottom view controller or some where");
    NSMutableDictionary * tagData   = [NSMutableDictionary dictionaryWithDictionary:note.userInfo];
    BOOL isDuration                 = ([note.userInfo objectForKey:@"duration"])?[[note.userInfo objectForKey:@"duration"] boolValue ]:FALSE;
    NSString *tagTime               = [tagData objectForKey:@"time"];// just to make sure they are added
    NSString *tagName               = [tagData objectForKey:@"name"];// just to make sure they are added
    NSString *eventNm               = (_event.live)?@"live":_event.name;
    
    // This is the starndard info that is collected from the encoder
    NSMutableDictionary * addTagData = [NSMutableDictionary dictionaryWithDictionary:
                                     @{
                                       @"event"         : eventNm,
                                       @"colour"        : [UserCenter getInstance].customerColor,       //[_dictOfAccountInfo objectForKey:@"tagColour"]
                                       @"user"          : [UserCenter getInstance].userHID,             //[_dictOfAccountInfo objectForKey:@"hid"]
                                       @"time"          : tagTime,
                                       @"name"          : tagName,
                                       @"deviceid"      : [[[UIDevice currentDevice] identifierForVendor]UUIDString]
                                       }];

    if (isDuration)[tagData setObject:tagTime forKey:@"starttime"];
    
    [addTagData addEntriesFromDictionary:tagData];//

    NSUInteger timeout = [allEncoders count] * 20;
    [allEncoders enumerateObjectsUsingBlock:^(id <EncoderProtocol> obj, NSUInteger idx, BOOL *stop){
        [obj issueCommand:MAKE_TAG priority:1 timeoutInSec:timeout tagData:tagData timeStamp:GET_NOW_TIME];
    }];
    
}

-(void)onTelePost:(NSNotification*)note
{
    PXPLog(@"Recieved a Telestration command");
    NSMutableDictionary * dict   = [NSMutableDictionary dictionaryWithDictionary:note.userInfo];
    NSString *tagTime           = [dict objectForKey:@"time"];// just to make sure they are added
    NSString *tagName           = [dict objectForKey:@"name"];// just to make sure they are added
    NSString *eventNm           = (_event.live)?@"live":_event.name;
    
    // This is the starndard info that is collected from the encoder
    NSMutableDictionary * tagData = [NSMutableDictionary dictionaryWithDictionary:
                                     @{
                                       @"event"         : eventNm,
                                       @"colour"        : [UserCenter getInstance].customerColor,
                                       @"user"          : [UserCenter getInstance].userHID,
                                       @"time"          : tagTime,
                                       @"name"          : tagName,
                                       @"duration"      : @"1",
                                       @"type"          : @"4",//TagTypeTele

                                       }];
    
    
    [tagData addEntriesFromDictionary:dict];
    
    NSUInteger timeout = [allEncoders count] * 20;
    [allEncoders enumerateObjectsUsingBlock:^(id <EncoderProtocol> obj, NSUInteger idx, BOOL *stop){
        [obj issueCommand:MAKE_TELE_TAG priority:1 timeoutInSec:timeout tagData:tagData timeStamp:GET_NOW_TIME];
    }];
    
}

-(void)onModTag:(NSNotification*)note
{
    if (!note.object){
    
    } else {
    
    }
    
    Tag *tagToModify            = note.object;
    NSMutableDictionary *dict   = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                            @"event":tagToModify.event,
                                                                        @"requesttime":GET_NOW_TIME_STRING,
                                                                                @"user":[UserCenter getInstance].userHID,
                                                                                @"id":tagToModify.ID
                                                                                }];
        
    [dict addEntriesFromDictionary: [tagToModify modifiedData]];
    if (tagToModify.isLive) {
        [dict setObject:@"live" forKey:@"event"];
    }

    for (id <EncoderProtocol> aEncoder  in allEncoders) {
        
        [aEncoder issueCommand:MODIFY_TAG
                      priority:10
                  timeoutInSec:5
                       tagData:dict
                     timeStamp:GET_NOW_TIME];
    }


}

-(void)onDeleteTag:(NSNotification*)note
{
    Tag *tagToDelete            = note.object;
    tagToDelete.type            = TagTypeDeleted;
    NSMutableDictionary *dict   = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                  @"event":tagToDelete.event,
                                                                                  @"requesttime":GET_NOW_TIME_STRING,
                                                                                  @"user":[UserCenter getInstance].userHID,
                                                                                  @"id":tagToDelete.ID
                                                                                  }];
    
    if (tagToDelete.isLive) {
        [dict setObject:@"live" forKey:@"event"];
    }
    
    for (id <EncoderProtocol> aEncoder  in allEncoders) {
        [aEncoder issueCommand:MODIFY_TAG
                      priority:10
                  timeoutInSec:5
                       tagData:dict
                     timeStamp:GET_NOW_TIME];
    }

}

-(void)deleteEvent:(NSNotification*)note
{
    Event *eventToDelete = note.object;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                @"name": eventToDelete.name,
                                                                                @"hid": eventToDelete.hid
                                                                                }];
    for (id <EncoderProtocol> aEncoder  in allEncoders) {
        [aEncoder issueCommand:DELETE_EVENT
                      priority:10
                  timeoutInSec:5
                       tagData:dict
                     timeStamp:GET_NOW_TIME];
    }
}

-(void)notificationDownloadClip:(NSNotification*)note
{

//    Tag *tag = note.userInfo[@"tag"];
//    
//    unsigned long srcID;
//    sscanf([note.userInfo[@"src"] UTF8String], "s_%lu", &srcID);
//    
//    __block void(^dItemBlock)(DownloadItem*) = note.userInfo[@"block"];
//    
//    // This gets run when the server responds
//    void(^onCompleteGet)(NSArray *) = ^void (NSArray*pooledResponces) {
//        
//        NSData          * data                  = pooledResponces[0];
//        NSDictionary    * results               = [Utility JSONDatatoDict: data];
//        NSString        * urlForImageOnServer   = (NSString *)[results objectForKey:@"vidurl"];;
//        if (!urlForImageOnServer) PXPLog(@"Warning: vidurl not found on Encoder");
//        // if in the data success is 0 then there is an error!
//        
//        // we add "+srcID" so we can grab the srcID from the file name by scanning up to the '+'
//        NSString * videoName = [NSString stringWithFormat:@"%@_vid_%@+%02lu.mp4",results[@"event"],results[@"id"], srcID];
//        
//        
//        // http://10.93.63.226/events/live/video/01hq_vid_10.mp4
//        
//        // BEGIN SERVER IS DUMB (Fake the URL of the saved video, because encoder pretty much always give back s_01)
//        
//        NSString *tagID = tag.ID;
//        NSString *ip = ((Encoder *)_primaryEncoder).ipAddress;
//        NSString *src = note.userInfo[@"src"];
//        
//        unsigned long n;
//        sscanf(src.UTF8String, "s_%lu", &n);
//        NSString *remoteSrc = [NSString stringWithFormat:@"%02luhq", n];
//        
//        NSString *remotePath = [NSString stringWithFormat:@"http://%@/events/live/video/%@_vid_%@.mp4", ip, remoteSrc, tagID];
//        
//        // END SERVER IS DUMB
//        
//        NSString * pth = [NSString stringWithFormat:@"%@/%@",[_localEncoder bookmarkedVideosPath],videoName];
//        DownloadItem * dli = [Downloader downloadURL:remotePath to:pth type:DownloadItem_TypeVideo];
//        dItemBlock(dli);
//        
//        
//        
//        
//        
//        [[NSNotificationCenter defaultCenter] addObserverForName:NOTIF_DOWNLOAD_COMPLETE object:nil queue:nil usingBlock:^(NSNotification *note) {
//            // is the object what we ware downloading
//            if (note.object == dli) {
//                NSLog(@"Download Complete");
//                
//                // we must now forge the results
//                
//                [_localEncoder saveClip:videoName withData:results]; // this is the data used to make the plist
//            }
//        }];
//    };
//    
//    
//    
//    NSMutableDictionary * sumRequestData = [NSMutableDictionary dictionaryWithDictionary:
//                                            @{
//                                              @"id": tag.ID,
//                                              @"event": (tag.isLive)?@"live":tag.event,
//                                              @"requesttime":GET_NOW_TIME_STRING,
//                                              @"bookmark":@"1",
//                                              @"user":[_dictOfAccountInfo objectForKey:@"hid"]
//                                              }];
//    
//    [sumRequestData addEntriesFromDictionary:@{@"sidx":trimSrc(note.userInfo[@"src"])}];
//    
//    [_primaryEncoder issueCommand:MODIFY_TAG priority:1 timeoutInSec:30 tagData:sumRequestData timeStamp:GET_NOW_TIME];
//    
//    [encoderSync syncAll:@[_primaryEncoder] name:NOTIF_ENCODER_CONNECTION_FINISH timeStamp:GET_NOW_TIME onFinish:onCompleteGet];
//    
//    PXPLog(@"Downloading Clip!");
    
}



-(void)closeDurationTag:(NSString *)tagName
{
    
    NSMutableDictionary * tag = [_openDurationTags objectForKey:tagName];
    [_openDurationTags removeObjectForKey:tagName];
    
    
    // issues mod tag command
    
    for (id <EncoderProtocol> aEncoder  in allEncoders) {
        
        [aEncoder issueCommand:MODIFY_TAG
                      priority:10
                  timeoutInSec:5
                       tagData:tag
                     timeStamp:GET_NOW_TIME];
    }
    
}

#pragma mark -
#pragma mark Common


/**
 *  This menthod Will recollect all the data from the encoders for the current Event
 */
-(void)refresh
{
//    // this collects all the tags from the encoders
//    [self willChangeValueForKey:@"currentEventTags"];
//    
//    
//    if (![_primaryEncoder isKindOfClass:[Encoder class]]&& _primaryEncoder) { // if its any other type of encoder then just take the tags from it only
//        _currentEventTags = [[_primaryEncoder.event.tags allValues] copy];
//        
//    } else {// if its normal encoder get from all connected and authenticated
//        NSMutableArray * tempList  = [[NSMutableArray alloc]init];
//        for (Encoder * encoder in _authenticatedEncoders) {
//            if (encoder.event.eventType != nil && ![encoder isKindOfClass:[LocalEncoder class]]){
//                [tempList addObjectsFromArray:[encoder.event.tags allValues]];
//            }
//            
//        }
//        _currentEventTags = [tempList copy];
//    }
//    
//    [self didChangeValueForKey:@"currentEventTags"];
}




-(void)addEncoder:(Encoder*)aEncoder
{
    
  
}

-(Encoder*)removeEncoder:(Encoder*)aEncoder
{
    return nil;
    
}


-(void)setEvent:(Event *)event
{
    if (event ==_event){
        return;
    }
    
    [self willChangeValueForKey:@"event"];
    _event      =  event;
    [self didChangeValueForKey:@"event"];
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_EVENT_CHANGE object:nil];
}

-(Event*)event
{
    return _event;
}





//
//-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
//    
//    
//    Encoder * encoder = object;
//    if (context == &authenticatContext){
//        
//        if (encoder.authenticated  && ![_authenticatedEncoders containsObject:encoder]) {
//            [_authenticatedEncoders addObject:encoder];
//            [encoder buildEncoderRequest]; // its authenticated... now collect all data from the encoder
//            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_ENCODER_COUNT_CHANGE object:self];
//        }
//    }
//    
//}
//
//
//



// this gets all Events, Masters Event take priority and all events are unique.
-(NSMutableArray*)allEventData
{
    
    // Collects all data from encoders into a temp array
    NSMutableArray * temp1  = [[NSMutableArray alloc]init];
    NSMutableArray * eventPool  = [[NSMutableArray alloc]init];
    
    
    //Why doesn't the protocol have allEvents?
    for (Encoder <EncoderProtocol> *encoder in allEncoders) {
        [eventPool addObjectsFromArray:[encoder.allEvents allValues]];
    }
    
    for (Event * anEvent in eventPool) {
        //        [temp1 addObjectsFromArray:anEvent.rawData];
        [temp1 addObjectsFromArray:[anEvent.rawData allValues]];
    }
    
    
    // This filters the data so its all unique
    NSMutableSet    * uniqueHIDS  = [[NSMutableSet alloc]init];
    NSPredicate     * makeUniquie = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        
        if (![evaluatedObject isKindOfClass:[NSDictionary class]]) return NO; // quick filter.. if not a dict... remove
        
        NSDictionary * thisDict = evaluatedObject;
        NSString * thisHID = [thisDict objectForKey:@"hid"];
        if ( thisHID == nil) {
            return NO;
        } else if ([uniqueHIDS containsObject:thisHID]){
            return NO;
        } else {
            [uniqueHIDS addObject:thisHID];
            return YES;
        }
    }];
    temp1  = [NSMutableArray arrayWithArray:[temp1 filteredArrayUsingPredicate:makeUniquie]];
    
    
    // convert data to a dict to make it easier to add/overwrite data from the master encoder
    NSMutableDictionary * uniqueDict = [[NSMutableDictionary alloc]init];
    NSEnumerator * converToDict = [temp1 objectEnumerator];
    id value;
    while ((value = [converToDict nextObject])) {
        NSDictionary * dict = value;
        [uniqueDict setObject:dict forKey:[dict objectForKey:@"name"]];
    }
    
    // this adds the data from the master encoder and overwrites slave data
    if (masterEncoder != nil){
        NSEnumerator * masterEnum = [masterEncoder.allEvents objectEnumerator];
        id value2;
        while ((value2 = [masterEnum nextObject])) {
            Event *event = value2;
            NSDictionary * dict = event.rawData;
            [uniqueDict setObject:dict forKey:[dict objectForKey:@"name"]];
        }
        
    }
    return [[uniqueDict allValues]copy];
}





-(void)issueCommand:(NSString *)methodName priority:(int)priority timeoutInSec:(float)time tagData:(NSMutableDictionary*)tData  timeStamp:(NSNumber *)aTimeStamp
{
    [allEncoders enumerateObjectsUsingBlock:^(id <EncoderProtocol> obj, NSUInteger idx, BOOL *stop){
        [obj issueCommand:methodName priority:priority timeoutInSec:time tagData:tData timeStamp:aTimeStamp];
    }];
}

-(Event*)getEventByName:(NSString*)eventName
{
    return nil;
}

-(void)clearQueueAndCurrent
{



}

@end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


/// Make Combo Event class - this cla


