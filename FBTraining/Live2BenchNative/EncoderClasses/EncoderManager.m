
//
//  EncoderManager.m
//  Live2BenchNative
//
//  Created by dev on 10/17/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "EncoderManager.h"
#import "Encoder.h"
#import "EncoderStatusMonitor.h"
#import "Utility.h"
#import "EncoderManagerActionPack.h" // All actions are in here!!
#import "Downloader.h"
#import "DownloadItem.h"
#import "Event.h"
#import "Tag.h"
#import "UserCenter.h"
#import "ActionListItem.h"

#import "ListPopoverController.h"
#import "FakeEncoder.h"

//#define GET_NOW_TIME        [NSNumber numberWithDouble:CACurrentMediaTime()]
#define GET_NOW_TIME_STRING [NSString stringWithFormat:@"%f",CACurrentMediaTime()]
#define trimSrc(s)  [Utility removeSubString:@"s_" in:(s)]

@implementation EncoderManager
{
    NSMutableDictionary         * dictOfEncoders;
  
    Event                       * eventBeingBuilt;
    ListPopoverController       * askPickMaster;
    
    id <ActionListItem>         buildEventAction;
    CheckWiFiAction             * checkWiFiAction;
    CheckForACloudAction        * checkForACloudAction;
    CheckMasterEncoderAction    * checkMasterEncoderAction;
}

@synthesize bonjourModule;
@synthesize hasMAX                  = _hasMAX;
@synthesize hasLive                 = _hasLive;
@synthesize searchForEncoders       = _searchForEncoders;
@synthesize allEvents               = _allEvents;
@synthesize authenticatedEncoders   = _authenticatedEncoders;
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
        
        _authenticatedEncoders          = [[NSMutableArray alloc]init];
        dictOfEncoders                  = [[NSMutableDictionary alloc]init];
        bonjourModule                   = [[BonjourModule alloc]initWithDelegate:self];
        _cloudEncoder                   = [[CloudEncoder alloc]initWithIP:[Utility getIPAddress]];  // started in searchForEncoders
        _localEncoder                   = [[LocalEncoder alloc]initWithDocsPath:aLocalDocsPath];
        _localEncoder.encoderManager    = self;
        _localMediaManager              = [[LocalMediaManager alloc]initWithDocsPath:aLocalDocsPath];
        _searchForEncoders              = NO;
        _hasLive                        = NO; // default before checking
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onLiveEventFound:)             name:NOTIF_LIVE_EVENT_FOUND             object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onMasterFound:)                name:NOTIF_ENCODER_MASTER_FOUND         object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onMasterLost:)                 name:NOTIF_ENCODER_MASTER_HAS_FALLEN    object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onDeleteEvent:)                name:NOTIF_DELETE_EVENT_SERVER          object:nil];

        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(masterCommands:)               name:NOTIF_MASTER_COMMAND               object:nil]; // watch whole app for start or stop events
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(oberverForEncoderStatus:)      name:NOTIF_ENCODER_STAT                 object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationDownloadEvent:)    name:NOTIF_EM_DOWNLOAD_EVENT            object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onLoginToCloud)                name:NOTIF_USER_LOGGED_IN               object:nil];

        checkWiFiAction             = [[CheckWiFiAction alloc]initWithEncoderManager:self];
        checkForACloudAction        = [[CheckForACloudAction alloc]initWithEncoderManager:self];
        checkMasterEncoderAction    = [[CheckMasterEncoderAction alloc]initWithEncoderManager:self];
        
        // This will look for the external encoder if no other normal encoders are found
        [self performSelector:@selector(makeCoachExternal) withObject:nil afterDelay:40];
    }
    return self;
}


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





// This will be depricated soon with the construction of a new MasterSlaveEncoder
-(void)requestTagDataForEvent:(NSString*)event onComplete:(void(^)(NSDictionary*all))onCompleteGet
{
    // check if this line is really being used
    NSString * myEvent = ([event isEqualToString:self.liveEvent.name])?@"live":event; // Converts event name to live if needed
    
    
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






#pragma mark -
#pragma mark Encoder Administartion

// This method switches encoders if need then changes the event. It will also build event if it has not been built
-(void)declareCurrentEvent:(Event*)event
{
  
        [self.primaryEncoder event].primary = false;
        if (event == nil) {
            
            if ([[self.primaryEncoder event].name isEqualToString:self.liveEventName]) {
                self.liveEvent = nil;
            }

            [self.primaryEncoder setEvent:nil];
            self.primaryEncoder = nil;
        } else {
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
        Encoder * newEncoder        = [[Encoder alloc]initWithIP:ip];
        newEncoder.encoderManager   = self;
        newEncoder.name             = name;
        [newEncoder requestVersion];
        [newEncoder authenticateWithCustomerID:[UserCenter getInstance].customerID];
        [dictOfEncoders setValue:newEncoder forKey:name];
        
        PXPLog(@"*** Registered Encoder ***");
        PXPLog(@"    %@ - %@",newEncoder.name,ip);
        PXPLog(@"**************************");
        
        
    }
}

// once the encoder is registered completed you can do what you want with it
-(void)onRegisterEncoderCompleted:(Encoder*)registerEncoder
{

    if (registerEncoder.authenticated  && ![_authenticatedEncoders containsObject:registerEncoder]) {
        [_authenticatedEncoders addObject:registerEncoder];
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_ENCODER_COUNT_CHANGE object:self];
        
        
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////// THIS IS TEMP FOR IVANS MEETING ///////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        // this is a temp
        if ([dictOfEncoders count] > 0 && ![registerEncoder.name isEqualToString:@"trashed"]) {
            
            NSMutableArray * listed                     = [NSMutableArray arrayWithArray:[dictOfEncoders allKeys]];
            
            if (askPickMaster) {
                [askPickMaster dismissPopoverAnimated:NO];
                [askPickMaster clear];
                askPickMaster = nil;
            }
            
            askPickMaster                               = [[ListPopoverController alloc] initWithMessage:@"Please pick an encoder:" buttonListNames:[listed copy]];
            __block EncoderManager * weakEncoderManager = self;
            
            [askPickMaster addOnCompletionBlock:^(NSString *pick){
                
                for (Encoder* enc in [weakEncoderManager->dictOfEncoders allValues])
                {
                    enc.isMaster = NO;
                }
                ((Encoder*)[weakEncoderManager->dictOfEncoders objectForKey:pick]).isMaster =YES;
                weakEncoderManager.masterEncoder = ((Encoder*)[weakEncoderManager->dictOfEncoders objectForKey:pick]);
                PXPLog(@"%@ is set to master!",weakEncoderManager.masterEncoder.name);
                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_EM_FOUND_MASTER object:weakEncoderManager];
            }];
            [askPickMaster presentPopoverCenteredIn:[UIApplication sharedApplication].keyWindow.rootViewController.view
                                           animated:YES];
            
        }

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
    } else if (!registerEncoder.authenticated) {
        [registerEncoder destroy];
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

    [aEncoder destroy];
    [_authenticatedEncoders removeObject:aEncoder];
    [dictOfEncoders removeObjectForKey:aEncoder.name];
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_ENCODER_COUNT_CHANGE object:self];

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


-(void)onDeleteEvent:(NSNotification*)note
{
    Event *eventToDelete = note.object;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                @"name": eventToDelete.name,
                                                                                @"hid": eventToDelete.hid
                                                                                }];
    
    [eventToDelete.parentEncoder issueCommand:DELETE_EVENT priority:10 timeoutInSec:5 tagData:dict timeStamp:GET_NOW_TIME];
}

-(void)onLiveEventFound:(NSNotification*)note
{
    Encoder * encoderHasLive = (Encoder*) note.object;
    self.liveEvent = encoderHasLive.liveEvent;
    
    if (self.masterEncoder == encoderHasLive.liveEvent.parentEncoder) {
        // add code here to let the app know if its the only event and to push the app to live2Bench
        if (!self.primaryEncoder || (self.primaryEncoder && ![self.primaryEncoder event]) || self.masterEncoder.pressingStart) {
            if (!self.primaryEncoder) {
                self.primaryEncoder = self.masterEncoder;
            }
            self.masterEncoder.pressingStart = false;
            [self declareCurrentEvent:self.liveEvent];
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SELECT_TAB object:nil userInfo:@{@"tabName":@"Live2Bench"}];
        }
    }
}


-(void)onMasterFound:(NSNotification*)note
{
//    _masterEncoder = note.object;
//    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_EM_FOUND_MASTER object:self];
}

-(void)onMasterLost:(NSNotification*)note
{
//    [self.authenticatedEncoders removeObject:self.masterEncoder];
//    
//    if (self.masterEncoder !=nil) [self unRegisterEncoder:self.masterEncoder];
//    
//    if ( [self.liveEvent.name isEqualToString:self.currentEvent]){
//        self.currentEvent = nil;
//    }
//    
//    self.liveEvent = nil;
//    
//    [self.authenticatedEncoders enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        if ([obj isKindOfClass:[Encoder class]]){ // this is so it does not get the local encoder to search
//            Encoder * anEncoder = (Encoder *) obj;
//            [anEncoder searchForMaster];
//        }
//    }];

}


#pragma mark Master Command Methods
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


#pragma mark -
#pragma mark Utility Methods
-(Event*)getEventByHID:(NSString*)eventHID
{
    //    NSPredicate *pred = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
    //
    //        NSString * thisHID = [evaluatedObject objectForKey:@"hid"];
    //
    //        return [thisHID isEqualToString:eventHID];
    //    }];
    //
    //
    //    //   NSPredicate *pred2 =  [pred predicateWithSubstitutionVariables:@{@"asdlfkj":@"poop"}];
    //
    //
    //    NSArray * filtered = [NSArray arrayWithArray:[[self allEventData] filteredArrayUsingPredicate:pred ]];
    //
    //    if ([filtered count]==0)return nil;
    //
    //    // this is an issues
    //    Event * event = [[Event alloc]initWithDict:filtered[0] isLocal:NO andlocalPath:nil];
    //
    
    
    /////
    Event * event;
    
    // collects all events
    NSMutableArray * collection = [[NSMutableArray alloc]init];
    
    for (Encoder * enc in self.authenticatedEncoders) {
        for (NSMutableDictionary *eventDic in [enc.allEvents allValues]) {
            [collection addObject:eventDic[@"non-local"]];
        }
        //[collection addObjectsFromArray:[enc.allEvents allValues]];
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
        
        for (NSMutableDictionary * evtDic in collection) {
            Event *evt = evtDic[@"local"];
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
    return [[LocalMediaManager getInstance] getEventByName:eventName];
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




#pragma mark -
#pragma mark Debug Methods


/**
 *   This makes the external encoder after 40 seconds and if MAX is found and no encoders are found
 */
-(void)makeCoachExternal
{
    if ([_authenticatedEncoders count] == 1 && self.hasMAX && [[UserCenter getInstance].customerEmail isEqualToString:@"coach"]){
        [self registerEncoder:@"External Encoder" ip:@"avocatec.org:8888"];
    }
}

// does not work
-(void)makeFakeEncoder
{
    
    FakeEncoder * newEncoder    = [[FakeEncoder alloc]init];
    newEncoder.encoderManager = self;
    newEncoder.name         = [NSString stringWithFormat:@"Fake %d",[FakeEncoder fakeCount] ];
    //        [newEncoder requestVersion];
    //        [newEncoder authenticateWithCustomerID:_customerID];
    //        if (_masterEncoder == nil) [newEncoder searchForMaster];
    [dictOfEncoders setValue:newEncoder forKey:newEncoder.name];
    
    
    PXPLog(@"*** Registered FAKE Encoder ***");
    PXPLog(@"    %@ ",newEncoder.name);
    PXPLog(@"**************************");
    
}


// Depricated?
-(BOOL)searchForEncoders
{
    return _searchForEncoders;
}

// Depricated?
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


#pragma mark -
#pragma mark Action Delegate Methods


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
#pragma mark Action Methods
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

