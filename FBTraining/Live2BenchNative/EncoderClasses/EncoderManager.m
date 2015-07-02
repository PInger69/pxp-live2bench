
//
//  EncoderManager.m
//  Live2BenchNative
//
//  Created by dev on 10/17/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "EncoderManager.h"
#import "Encoder.h"
#import "EncoderCommands.h"
#import "EncoderStatusMonitor.h"
#import "Utility.h"
#import "EncoderManagerActionPack.h" // All actions are in here!!
#import "Downloader.h"
#import "DownloadItem.h"
#import "Event.h"
#import "Tag.h"
#import "UserCenter.h"
#import "ActionListItem.h"


#import "FakeEncoder.h"

//#define GET_NOW_TIME        [NSNumber numberWithDouble:CACurrentMediaTime()]
#define GET_NOW_TIME_STRING [NSString stringWithFormat:@"%f",CACurrentMediaTime()]
#define trimSrc(s)  [Utility removeSubString:@"s_" in:(s)]

@implementation EncoderManager
{
    
    NSMutableDictionary         * dictOfEncoders;
    NSMutableArray              * arrayOfTagSets;

    id                          _masterLostObserver;
    id                          _masterFoundObserver;
    id                          _encoderReadyObserver;
    id                          _logoutObserver;
    id                          _liveEventStopped;
    id                          _liveEventFound;
    
    CheckWiFiAction             * checkWiFiAction;
    CheckForACloudAction        * checkForACloudAction;
    CheckMasterEncoderAction    * checkMasterEncoderAction;
    
    id <ActionListItem>         buildEventAction;
    Event                       * eventBeingBuilt;
}

@synthesize bonjourModule;

@synthesize hasWiFi                 = _hasWiFi;
@synthesize hasMAX                  = _hasMAX;

@synthesize hasLive                 = _hasLive;
@synthesize searchForEncoders       = _searchForEncoders;
@synthesize feeds                   = _feeds;           // depricated
@synthesize currentEvent            = _currentEvent;    // depricated
@synthesize currentEventType        = _currentEventType;// depricated
@synthesize currentEventData        = _currentEventData;// depricated
@synthesize currentEventTags        = _currentEventTags;// depricated
@synthesize allEvents               = _allEvents;
@synthesize authenticatedEncoders   = _authenticatedEncoders;
@synthesize openDurationTags        = _openDurationTags;// depricated
@synthesize liveEventName           = _liveEventName;
@synthesize eventTags               = _eventTags;// depricated
@synthesize masterEncoder           = _masterEncoder;
@synthesize cloudEncoder            = _cloudEncoder;
@synthesize localEncoder            = _localEncoder;
@synthesize localMediaManager       = _localMediaManager;
@synthesize primaryEncoder          = _primaryEncoder;

#pragma mark - Encoder Manager Methods

-(id)initWithLocalDocPath:(NSString*)aLocalDocsPath
{
    
    self = [super init];
    if (self){
        
        _authenticatedEncoders  = [[NSMutableArray alloc]init];
        dictOfEncoders          = [[NSMutableDictionary alloc]init];
        _liveEventName          = @"None";
        
        // Browse for services
        
        bonjourModule           = [[BonjourModule alloc]initWithDelegate:self];
        
        _openDurationTags       = [[NSMutableDictionary alloc]init];
        _eventTags              = [[NSMutableDictionary alloc]init];
        arrayOfTagSets          = [[NSMutableArray alloc]init];
        _feeds                  = [[NSMutableDictionary alloc]init];
        
        _cloudEncoder           = [[CloudEncoder alloc]initWithIP:[Utility getIPAddress]];  // started in searchForEncoders
        [_cloudEncoder startObserving];
        
        _localEncoder           = [[LocalEncoder alloc]initWithDocsPath:aLocalDocsPath];
        _localEncoder.encoderManager = self;
        _localMediaManager      = [[LocalMediaManager alloc]initWithDocsPath:aLocalDocsPath];
        
        _currentEventType       = SPORT_HOCKEY;
        _searchForEncoders      = NO;
        //encoderSync             = [[EncoderDataSync alloc]init];
        _hasLive                = NO; // default before checking
        
        // setup observers
        __block EncoderManager * weakSelf = self;
        
        
        /*_liveEventStopped         = [[NSNotificationCenter defaultCenter]addObserverForName:NOTIF_LIVE_EVENT_STOPPED     object:nil queue:nil usingBlock:^(NSNotification *note) {
            // if the current playing event is the live event and its stopped then we have to make it no Event at all
            if ([weakSelf.currentEvent isEqualToString:weakSelf.liveEventName]){
                weakSelf.currentEvent   = nil; // Depricated
                weakSelf.liveEventName  = nil; // Depricated
                weakSelf.liveEvent      = nil;
            }
        }];*/
        
        _liveEventFound         = [[NSNotificationCenter defaultCenter]addObserverForName:NOTIF_LIVE_EVENT_FOUND     object:nil queue:nil usingBlock:^(NSNotification *note) {
            
            weakSelf.liveEventName  = ((Encoder*) note.object).liveEvent.name; // Depricated
            weakSelf.currentEvent   = weakSelf.liveEventName; // should live be live no matter what?? // Depricated
            weakSelf.liveEvent = ((Encoder*) note.object).liveEvent;
            
            if (weakSelf.masterEncoder == ((Encoder*) note.object).liveEvent.parentEncoder) {
                 // add code here to let the app know if its the only event and to push the app to live2Bench
                if (!weakSelf.primaryEncoder || (weakSelf.primaryEncoder && ![weakSelf.primaryEncoder event]) || weakSelf.masterEncoder.pressingStart) {
                    if (!weakSelf.primaryEncoder) {
                        weakSelf.primaryEncoder = weakSelf.masterEncoder;
                    }
                    weakSelf.masterEncoder.pressingStart = false;
                    [weakSelf declareCurrentEvent:weakSelf.liveEvent];
                    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MASTER_HAS_LIVE object:nil];

                    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SELECT_TAB object:nil userInfo:@{@"tabName":@"Live2Bench"}];
                }
            
            
            }
            
            
        }];
        
        
        _masterFoundObserver = [[NSNotificationCenter defaultCenter]addObserverForName:NOTIF_ENCODER_MASTER_FOUND    object:nil queue:nil usingBlock:^(NSNotification *note) {
            _masterEncoder = note.object;
            
//            if (_masterEncoder.liveEvent) {
//                weakSelf.liveEventName = _masterEncoder.liveEvent.name;
//                //                [weakSelf refresh];
//
//                weakSelf.primaryEncoder = _masterEncoder;
//                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MASTER_HAS_LIVE object:nil];
//            }
//            [weakSelf refresh];
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_EM_FOUND_MASTER object:self];
            
        }];
        
        _masterLostObserver  = [[NSNotificationCenter defaultCenter]addObserverForName:NOTIF_ENCODER_MASTER_HAS_FALLEN     object:nil queue:nil usingBlock:^(NSNotification *note) {
            
            [weakSelf.authenticatedEncoders removeObject:weakSelf.masterEncoder];
            
            if (weakSelf.masterEncoder !=nil) [weakSelf unRegisterEncoder:(Encoder*)weakSelf.masterEncoder];
            
            if ( [weakSelf.liveEventName isEqualToString:weakSelf.currentEvent]){
                weakSelf.currentEvent = nil;
            }
            
            weakSelf.liveEventName = nil;
            
            [weakSelf.authenticatedEncoders enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[Encoder class]]){ // this is so it does not get the local encoder to search
                    Encoder * anEncoder = (Encoder *) obj;
                    [anEncoder searchForMaster];
                }
            }];
        }];
        

        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeCurrentEvent:)       name:NOTIF_EM_CHANGE_EVENT object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(masterCommands:)           name:NOTIF_MASTER_COMMAND   object:nil]; // watch whole app for start or stop events
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(oberverForEncoderStatus:)  name:NOTIF_ENCODER_STAT     object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(masterHasLive:)            name:NOTIF_MASTER_HAS_LIVE  object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationDownloadEvent:) name:NOTIF_EM_DOWNLOAD_EVENT object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onLoginToCloud)            name:NOTIF_USER_LOGGED_IN object:nil];
        // making actions
        
        //SAGAR AND BEN NOTIFICATIONS
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listViewFeed:) name:NOTIF_LIST_VIEW_CONTROLLER_FEED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventDataRequest:) name:NOTIF_REQUEST_CALENDAR_DATA object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:NOTIF_DELETE_EVENT_SERVER object:nil queue:nil usingBlock:^(NSNotification *note) {
            Event *eventToDelete = note.object;
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
                                   @"name": eventToDelete.name,
                                   @"hid": eventToDelete.hid
                                   }];
            [self deleteEvent: dict];
        }];

        
        checkWiFiAction             = [[CheckWiFiAction alloc]initWithEncoderManager:self];
        checkForACloudAction        = [[CheckForACloudAction alloc]initWithEncoderManager:self];
        checkMasterEncoderAction    = [[CheckMasterEncoderAction alloc]initWithEncoderManager:self];
        //logoutAction                = [[LogoutAction alloc]initWithEncoderManager:self];
        
        // This will look for the external encoder if no other normal encoders are found
        [self performSelector:@selector(makeCoachExternal) withObject:nil afterDelay:40];
    }
    return self;
}

static void * authenticatContext    = &authenticatContext;
static void * statusContext         = &statusContext;


//SAGAR AND BEN CODE BEGINS

-(void)eventDataRequest: (NSNotification *)note{
    
    void(^theBlock)(NSArray *eventData) = [note.userInfo objectForKey:@"block"];
    theBlock(self.allEventData);
}

-(void)listViewFeed: (NSNotification *)note{
    
    void(^theBlock)(NSDictionary *someFeeds, NSArray *allTags) = [note.userInfo objectForKey:@"block"];
    theBlock(self.feeds, [self.eventTags allValues]);
}

//SAGAR AND BEN CODE FINISHES

-(void)declareCurrentEvent:(Event*)event
{
  
        [self.primaryEncoder event].primary = false;
        if (event == nil) {
            
            if ([[self.primaryEncoder event].name isEqualToString:self.liveEventName]) {
                self.liveEvent = nil;
            }

            [self.primaryEncoder setEvent:nil];
            self.primaryEncoder = nil;
        }
        else{
            if (event.isBuilt){
                self.primaryEncoder = event.parentEncoder;
                event.primary = true;
                [self.primaryEncoder setEvent:event];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_TAG_RECEIVED object:event];
            } else {
                eventBeingBuilt = event;
                buildEventAction = (id <ActionListItem>) eventBeingBuilt.parentEncoder;
                buildEventAction.delegate = self;
                [self requestTagDataForEvent:eventBeingBuilt.name onComplete:nil];


            }
        }

        
}


/**
 *  When an Encoder if found it is checked and obervers are added to check the status
 *  Version is then requested and authenticated with user ID
 *
 *  @param name Name of Encoder
 *  @param ip   ip of Encoder
 */
-(void)registerEncoder:(NSString*)name ip:(NSString*)ip
{
    if ([dictOfEncoders objectForKey:name] == nil) {
        Encoder * newEncoder    = [[Encoder alloc]initWithIP:ip];
        newEncoder.encoderManager = self;
        [newEncoder addObserver:self forKeyPath:@"authenticated"    options:0 context:authenticatContext];
        [newEncoder addObserver:self forKeyPath:@"status"           options:0 context:statusContext];
        newEncoder.name         = name;
        [newEncoder requestVersion];
        
        [newEncoder authenticateWithCustomerID:[UserCenter getInstance].customerID];
//        if (_masterEncoder == nil) [newEncoder searchForMaster];
        [dictOfEncoders setValue:newEncoder forKey:name];
        
        PXPLog(@"*** Registered Encoder ***");
        PXPLog(@"    %@ - %@",newEncoder.name,ip);
        PXPLog(@"**************************");
        
//       if (![newEncoder.name isEqualToString:@"External Encoder"])  [_masterEncoder addEncoder:newEncoder];
    }
}

/**
 *  This removes an encoder and posts to the app to let it know when a feed changes or when master is lost
 *  If master is loas Setting ViewController is always checking for master status
 *
 *  @param aEncoder
 */
-(void)unRegisterEncoder:(Encoder *) aEncoder
{
    PXPLog(@"!!! ENCODER REMOVED !!! %@",aEncoder.name);
    
    [aEncoder removeObserver:self forKeyPath:@"authenticated"];
    [aEncoder removeObserver:self forKeyPath:@"status"];

    [aEncoder destroy];
//    if (((Encoder*)_masterEncoder) == aEncoder){
//        
//        _masterEncoder = nil;
//        PXPLog(@"Master Encoder Linched!");
//
//    }
    [_authenticatedEncoders removeObject:aEncoder];
    [dictOfEncoders removeObjectForKey:aEncoder.name];
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_ENCODER_COUNT_CHANGE object:self];

}

-(void)masterHasLive:(NSNotification *)note
{
    self.currentEvent   = self.liveEventName;
//    [self requestTagDataForEvent:_liveEventName onComplete:^(NSDictionary *all) {
//        [_eventTags setObject:all forKey:_liveEventName];
//    }];
}



-(void)setPrimaryEncoder:(id<EncoderProtocol>)primaryEncoder
{
    if (_primaryEncoder == primaryEncoder) return;

    [self willChangeValueForKey:NSStringFromSelector(@selector(primaryEncoder))];
    
    if (_primaryEncoder) (void)[_primaryEncoder removeFromPrimary];
    _primaryEncoder = [primaryEncoder makePrimary];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_PRIMARY_ENCODER_CHANGE object:primaryEncoder];
    
    [self didChangeValueForKey:NSStringFromSelector(@selector(primaryEncoder))];
}

-(id <EncoderProtocol>)primaryEncoder
{
    return _primaryEncoder;
}



-(Event*)getEventByHID:(NSString*)eventHID
{
    Event * event;
    
    // collects all events
    NSMutableArray * collection = [[NSMutableArray alloc]init];
    
    for (Encoder * enc in self.authenticatedEncoders) {
        [collection addObjectsFromArray:[enc.allEvents allValues]];
    }
    
    
    for (Event * evt in collection) {
        if ([evt.hid isEqualToString:eventHID]) {
            event = evt;
            break;
        };
    }
    
    // If there is no exteral events check the local
    if (!event){
        collection = [NSMutableArray arrayWithArray:[[LocalMediaManager getInstance].allEvents allValues]];
        
        for (Event * evt in collection) {
            if ([evt.hid isEqualToString:eventHID]) {
                event = evt;
                break;
            };
        }
    }

    return event;
}

-(Event*)getEventByName:(NSString*)eventName
{
    for (Encoder * enc in self.authenticatedEncoders) {
        
        if ([enc getEventByName:eventName]){
            return [enc getEventByName:eventName];
        }
    }
    
    //return [self.localEncoder getEventByName:eventName];
    return [[LocalMediaManager getInstance] getEventByName:eventName];
}

-(void)makeFakeEncoder
{

        FakeEncoder * newEncoder    = [[FakeEncoder alloc]init];
        newEncoder.encoderManager = self;
        [newEncoder addObserver:self forKeyPath:@"authenticated"    options:0 context:authenticatContext];
        [newEncoder addObserver:self forKeyPath:@"status"           options:0 context:statusContext];
        newEncoder.name         = [NSString stringWithFormat:@"Fake %d",[FakeEncoder fakeCount] ];
//        [newEncoder requestVersion];
//        [newEncoder authenticateWithCustomerID:_customerID];
//        if (_masterEncoder == nil) [newEncoder searchForMaster];
        [dictOfEncoders setValue:newEncoder forKey:newEncoder.name];
    
        
        PXPLog(@"*** Registered FAKE Encoder ***");
        PXPLog(@"    %@ ",newEncoder.name);
        PXPLog(@"**************************");

}


#pragma mark -
#pragma mark Observers



-(void)oberverForEncoderStatus:(NSNotification *)note
{
    Encoder * encoder = (Encoder * )note.object;
    
    switch (encoder.status) {
        case ENCODER_STATUS_UNKNOWN: // Disconnected
            PXPLog(@"ENCODER_STATUS_UNKNOWN");
            [self unRegisterEncoder:encoder];
            break;
        case ENCODER_STATUS_LIVE:  // This is so when you start a live event on the device it builds a encoder
            if (!encoder.isBuild) {
                encoder.isReady = NO;
                [encoder issueCommand:BUILD priority:3 timeoutInSec:15 tagData:nil timeStamp:GET_NOW_TIME];
            }
            break;
        case ENCODER_STATUS_STOP:
            self.hasLive = NO;
            // rebuld all encoders
            [self.authenticatedEncoders enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[Encoder class]]){ // this is so it does not get the local encoder to search
                    Encoder * anEncoder = (Encoder *) obj;
                    [anEncoder issueCommand:BUILD priority:3 timeoutInSec:15 tagData:nil timeStamp:GET_NOW_TIME];
                }
            }];
            break;
        case ENCODER_STATUS_READY:
            self.hasLive = NO;
            encoder.justStarted = true;
            break;
        default:
            break;
    }
    
    
    
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    Encoder * encoder = object;
    if (context == authenticatContext){
        
        if (encoder.authenticated  && ![_authenticatedEncoders containsObject:encoder]) {
            [_authenticatedEncoders addObject:encoder];
            [encoder buildEncoderRequest]; // its authenticated... now collect all data from the encoder
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_ENCODER_COUNT_CHANGE object:self];
        }
    }
    
}

-(void)changeCurrentEvent:(NSNotification*)note
{
    NSString * eventName = note.userInfo[@"name"];
    self.currentEvent = eventName;
    
}

/**
 *  This method prepares the clip for download
 *
 *  @param note
 */
-(void)notificationDownloadEvent:(NSNotification*)note
{
    __block void(^dItemBlock)(DownloadItem*) = note.userInfo[@"block"];
    
    NSDictionary * theEventData = note.userInfo[@"data"];
    NSString     * eventHID     = theEventData[@"hid"];
    NSString     * source       = note.userInfo[@"source"];
    NSString *encoderSource;
    if (theEventData[@"mp4_2"]) {
        encoderSource = theEventData[@"mp4_2"][source][@"hq"];
    } else {
        encoderSource = theEventData[@"mp4"];
    }
    
    Event * theEvent = [self getEventByHID:eventHID];
    
    if (theEvent.isBuilt){
    
        //NSString * videoFolderPath =  [_localEncoder saveEvent:theEvent]; // this is the data used to make the plist
        NSString * videoFolderPath =  [_localMediaManager saveEvent:theEvent]; // this is the data used to make the plist
        NSString * savedFileName   =  [encoderSource lastPathComponent];
        DownloadItem * dli = [Downloader downloadURL:encoderSource to:[videoFolderPath stringByAppendingPathComponent:savedFileName] type:DownloadItem_TypeVideo];
        dItemBlock(dli);
        
    } else {
        theEvent.onComplete = nil;// clear out the on complete build block
        [self requestTagDataForEvent:theEvent.name onComplete:^(NSDictionary *all) {
            
            NSMutableDictionary * tagsBuilt = [[NSMutableDictionary alloc]init];
            NSArray * keys = [all allKeys];
            for (NSString * key in keys) {
                
                Tag * t = [[Tag alloc]initWithData:[all objectForKey:key] event:theEvent];
                [tagsBuilt setObject:t forKey:key];
                
            }
            theEvent.tags = [tagsBuilt copy];
            //NSString * videoFolderPath =  [_localEncoder saveEvent:theEvent]; // this is the data used to make the plist
            NSString * videoFolderPath =  [_localMediaManager saveEvent:theEvent]; // this is the data used to make the plist
            NSString * savedFileName   =  [encoderSource lastPathComponent];

            DownloadItem * dli = [Downloader downloadURL:encoderSource to:[videoFolderPath stringByAppendingPathComponent:savedFileName] type:DownloadItem_TypeVideo];
            dItemBlock(dli);
            
        }];
    }
    
}

#pragma mark - Master Command Methods
-(void)masterCommands:(NSNotification *)note
{
    NSDictionary * data = note.userInfo;
    NSMutableDictionary * requestData = [NSMutableDictionary dictionaryWithDictionary: data];
    if (_masterEncoder) {
        if ([data objectForKey:@"stop"]) {
            [_masterEncoder issueCommand:STOP_EVENT     priority:3 timeoutInSec:6 tagData:requestData timeStamp:GET_NOW_TIME];
        } else if ([data objectForKey:@"start"]) {
            [_masterEncoder issueCommand:START_EVENT    priority:3 timeoutInSec:6 tagData:requestData timeStamp:GET_NOW_TIME];
            [_masterEncoder issueCommand:BUILD    priority:3 timeoutInSec:6 tagData:requestData timeStamp:GET_NOW_TIME];// this just rebuilds so it can find the live
        } else if ([data objectForKey:@"pause"]) {
            [_masterEncoder issueCommand:PAUSE_EVENT    priority:3 timeoutInSec:6 tagData:requestData timeStamp:GET_NOW_TIME];
        } else if ([data objectForKey:@"resume"]) {
            [_masterEncoder issueCommand:RESUME_EVENT    priority:3 timeoutInSec:6 tagData:requestData timeStamp:GET_NOW_TIME];
        } else if ([data objectForKey:@"shutdown"]) {
            [_masterEncoder issueCommand:SHUTDOWN    priority:3 timeoutInSec:6 tagData:requestData timeStamp:GET_NOW_TIME];
        }
    }
    
}

#pragma mark - Command Methods

-(void)logoutOfCloud
{
    [_cloudEncoder logoutOfCloud];
    
    NSArray * allEnc = [dictOfEncoders allValues];
    
    for (Encoder * enc in allEnc) {
        PXPLog(@"Logged out of Encoder");
        [self unRegisterEncoder:enc];
    }
    [_authenticatedEncoders removeAllObjects];
    [dictOfEncoders removeAllObjects];
    [bonjourModule clear];
}

-(void)onLoginToCloud
{
    [bonjourModule reset];
}

-(void)pushTag:(NSMutableDictionary *)tagSet
{
    [arrayOfTagSets addObject:tagSet];
}



// depricated
//-(void)reqestTeamData:(void(^)(NSArray*pooled))onCompleteGet
//{
//    
//    if (_primaryEncoder) {
//        NSNumber    * nowTime             = GET_NOW_TIME;
//        [_primaryEncoder issueCommand:TEAMS_GET priority:1 timeoutInSec:10 tagData:nil timeStamp:nowTime];
//        //        encoderSync =  [[EncoderDataSync alloc]initWith:@[_masterEncoder] name:NOTIF_ENCODER_CONNECTION_FINISH timeStamp:GET_NOW_TIME onFinish:onCompleteGet];
//        //[encoderSync syncAll:@[_primaryEncoder] name:NOTIF_ENCODER_CONNECTION_FINISH timeStamp:nowTime onFinish:onCompleteGet];
//    } else {
//        // Alert the user that there is not master encoder
//    }
//}



-(void)deleteEvent:(NSMutableDictionary *)data{

    for (id <EncoderProtocol> aEncoder  in _authenticatedEncoders) {
        [aEncoder issueCommand:DELETE_EVENT
                      priority:10
                  timeoutInSec:5
                       tagData:data
                     timeStamp:GET_NOW_TIME];
    }
    

}




/**
 *  This gets all Event Classes from all encoders in a group
 *
 *  @return Array of Event Classes
 */
-(NSMutableArray*)allEvents
{
    NSMutableArray * temp  = [[NSMutableArray alloc]init];
    for (id <EncoderProtocol> encoder in _authenticatedEncoders) {
        [temp addObjectsFromArray:[encoder.allEvents allValues]];
    }
    
    return temp;
}

// This will be depricated soon with the construction of a new MasterSlaveEncoder
// this gets all Events, Masters Event take priority and all events are unique.
-(NSMutableArray*)allEventData
{
    
    // Collects all data from encoders into a temp array
    NSMutableArray * temp1  = [[NSMutableArray alloc]init];
    NSMutableArray * eventPool  = [[NSMutableArray alloc]init];
    
    
    //Why doesn't the protocol have allEvents?
    for (Encoder <EncoderProtocol> *encoder in _authenticatedEncoders) {
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
    if (_masterEncoder != nil){
        NSEnumerator * masterEnum = [_masterEncoder.allEvents objectEnumerator];
        id value2;
        while ((value2 = [masterEnum nextObject])) {
            Event *event = value2;
            NSDictionary * dict = event.rawData;
            [uniqueDict setObject:dict forKey:[dict objectForKey:@"name"]];
        }
        
    }
    return [[uniqueDict allValues]copy];
}

// This will be depricated soon with the construction of a new MasterSlaveEncoder
-(void)requestTagDataForEvent:(NSString*)event onComplete:(void(^)(NSDictionary*all))onCompleteGet
{
    NSString * myEvent = ([event isEqualToString:_liveEventName])?@"live":event; // Converts event name to live if needed

    
    NSMutableDictionary * requestData = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                        @"user"        : [UserCenter getInstance].userHID,
                                                                                        @"requesttime" : GET_NOW_TIME,
                                                                                        @"device"      : [[[UIDevice currentDevice] identifierForVendor]UUIDString],
                                                                                        @"event"       : myEvent
                                                                                        }];
    
    NSArray     * encoders;
    
    if (![_primaryEncoder isKindOfClass:[Encoder class]] && _primaryEncoder) {
        encoders    = @[_primaryEncoder];
    } else {
        encoders    = [_authenticatedEncoders copy];
        
    }
    

    [encoders enumerateObjectsUsingBlock:^(id <EncoderProtocol>obj, NSUInteger idx, BOOL *stop){
        [obj issueCommand:EVENT_GET_TAGS priority:1 timeoutInSec:15 tagData:requestData timeStamp:GET_NOW_TIME onComplete:^{
            onCompleteGet(nil);
        }];
    }];

}


// This will be depricated soon with the construction of a new MasterSlaveEncoder
-(NSMutableDictionary*)eventTags
{
    
    NSMutableDictionary * tags = [[NSMutableDictionary alloc]init];
    NSArray             * encoders;
    
    if (![_primaryEncoder isKindOfClass:[Encoder class]]&& _primaryEncoder) {
        encoders    = @[_primaryEncoder];
    } else {
        encoders    = [_authenticatedEncoders copy];
        
    }
    
    for (id <EncoderProtocol> encoder in /*_authenticatedEncoders*/encoders) {
        NSLog(@"%@", encoder.event);
        if (encoder.event.tags != nil ){
            NSLog(@"%@", encoder.event);
            
            NSMutableArray *keys = [[NSMutableArray alloc]init];
            for(Tag *tags in encoder.event.tags){
                [keys addObject:tags.ID];
            }
            
            NSDictionary *newTagDic = [[NSDictionary alloc]initWithObjects:encoder.event.tags forKeys:keys];
            [tags  addEntriesFromDictionary:newTagDic];
        }
    }
    return tags;
}


/**
 *  TODO fix this global crap. this was added so global can be cut out slowly
 *  DEPRICATED!
 *  @return connected to Encoder
 */
-(BOOL)hasMIN
{
    return NO;//[Globals instance].HAS_MIN;
}


-(BOOL)hasLive
{
    return _hasLive;
}

-(void)setHasLive:(BOOL)hasLive
{
    if (hasLive == _hasLive) return;
    
    [self willChangeValueForKey:@"hasLive"];
    _hasLive = hasLive;
    if ([_currentEvent isEqualToString:_liveEventName] && !_hasLive){
        self.currentEvent = @"None";
    }
    [self didChangeValueForKey:@"hasLive"];
    
}




#pragma mark -
#pragma This what starts the encoder manager to start searching
-(BOOL)searchForEncoders
{
    return _searchForEncoders;
}
-(void)setSearchForEncoders:(BOOL)searchForEncoders
{
    if (searchForEncoders == _searchForEncoders)return;
    if (searchForEncoders) {
        bonjourModule.searching = YES;
        [[UserCenter getInstance] updateTagInfoFromCloud];
    } else{
        bonjourModule.searching = NO;
    }
    [self willChangeValueForKey:@"searchForEncoders"];
    _searchForEncoders = searchForEncoders;
    [self didChangeValueForKey:@"searchForEncoders"];
}



-(NSString*)description
{
    NSString * txt = [NSString stringWithFormat:@"Encoder Manager - Type: %@\n Event:%@\n Encoders:\n",_currentEventType,_currentEvent];
    
    for (Encoder * enc in _authenticatedEncoders)
    {
        NSString * encoderStats = [NSString stringWithFormat:@"\t%@",enc.name];
        NSString * socialStatus;
        NSString * encoderStatus = [Utility encoderStatusToString:enc.status];
        encoderStats = [NSString stringWithFormat:@"%@%*c - ",encoderStats, (int) (16 - encoderStats.length), ' '];
        if ([enc isKindOfClass:[LocalEncoder class]]){
            socialStatus = @"Django";
        } else{
            socialStatus = (enc.isMaster)?@"Master":@"Slave";
        }
        
        encoderStats = [NSString stringWithFormat:@"%@ %@   %@",encoderStats, socialStatus,encoderStatus];
        
        txt = [NSString stringWithFormat:@"%@%@\n",txt,encoderStats];
    }
    return txt;
}


/**
 *   This makes the external encoder
 */
-(void)makeCoachExternal
{
    if ([_authenticatedEncoders count] == 1 && self.hasMAX){
        __block EncoderManager * weakSelf = self;
        void (^onRecieveData)(NSDictionary*) = ^void(NSDictionary* theData){
            if ([theData[@"emailAddress"] isEqualToString:@"coach"]){
                [weakSelf registerEncoder:@"External Encoder" ip:@"avocatec.org:8888"];
            }
        };
        
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_USER_CENTER_DATA_REQUEST object:nil userInfo:@{@"type":UC_REQUEST_USER_INFO, @"block":onRecieveData}];
    }

}


#pragma mark -
#pragma Action Delegate Methods


-(void)onSuccess:(id<ActionListItem>)actionListItem
{
    if (actionListItem == buildEventAction && eventBeingBuilt.isBuilt) {
        buildEventAction            = nil;
        eventBeingBuilt.delegate    = nil;
        [self declareCurrentEvent:eventBeingBuilt];
    
    }
}

-(void)onFail:(id<ActionListItem>)actionListItem
{
    // too bad so sad
}

 

#pragma mark -
#pragma Action Methods
// Action Methods

-(id<ActionListItem>)checkForWiFiAction
{
    checkWiFiAction.isFinished = NO;
    checkWiFiAction.isSuccess  = NO;
    return checkWiFiAction;
}
-(id<ActionListItem>)checkForACloudAction
{
    checkForACloudAction.isFinished = NO;
    checkForACloudAction.isSuccess  = NO;
    return checkForACloudAction;
}


/**
 *  This just pings the cloud
 *
 *  @return the action
 */
-(id<ActionListItem>)checkForMasterAction
{
    checkMasterEncoderAction.isFinished = NO;
    checkMasterEncoderAction.isSuccess  = NO;
    return checkMasterEncoderAction;
}

@end

