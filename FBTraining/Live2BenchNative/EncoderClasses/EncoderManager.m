
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
//#import "EncoderControlsViewController.h"
#import "ImageAssetManager.h"
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
    
    NSArray * (^grabAllThumbNamesFromEvent)(Event * input);
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

static EncoderManager * instance;
#pragma mark - Encoder Manager Methods

-(id)initWithLocalDocPath:(NSString*)aLocalDocsPath
{
    
    self = [super init];
    if (self){
        self.feedMapController          = [FeedMapController instance];
        _authenticatedEncoders          = [[NSMutableArray alloc]init];
        dictOfEncoders                  = [[NSMutableDictionary alloc]init];
        bonjourModule                   = [[BonjourModule alloc]initWithDelegate:self];
        _cloudEncoder                   = [[CloudEncoder alloc]initWithIP:[Utility getIPAddress]];  // started in searchForEncoders
        _localEncoder                   = [[LocalEncoder alloc]initWithDocsPath:aLocalDocsPath];
        _localEncoder.encoderManager    = self;// depricated
        _localMediaManager              = [[LocalMediaManager alloc]initWithDocsPath:aLocalDocsPath];
        _searchForEncoders              = NO;
        _hasLive                        = NO; // default before checking
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onLiveEventFound:)             name:NOTIF_LIVE_EVENT_FOUND             object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onMasterFound:)                name:NOTIF_ENCODER_MASTER_FOUND         object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onMasterLost:)                 name:NOTIF_ENCODER_MASTER_HAS_FALLEN    object:nil];
        //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onDeleteEvent:)                name:NOTIF_DELETE_EVENT_SERVER          object:nil];

        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(masterCommands:)               name:NOTIF_MASTER_COMMAND               object:nil]; // watch whole app for start or stop events
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(oberverForEncoderStatus:)      name:NOTIF_ENCODER_STAT                 object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationDownloadEvent:)    name:NOTIF_EM_DOWNLOAD_EVENT            object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onLoginToCloud)                name:NOTIF_USER_LOGGED_IN               object:nil];

        checkWiFiAction             = [[CheckWiFiAction alloc]initWithEncoderManager:self];
        checkForACloudAction        = [[CheckForACloudAction alloc]initWithEncoderManager:self];
        checkMasterEncoderAction    = [[CheckMasterEncoderAction alloc]initWithEncoderManager:self];
        
        
        grabAllThumbNamesFromEvent = ^NSArray *(Event *input) {
            NSMutableArray  * collection    = [[NSMutableArray alloc]init];
            for (Tag * item in input.tags) {
                [collection addObjectsFromArray:[item.thumbnails allValues]];
            }
            return [collection copy];
        };

        
        
        // This will look for the external encoder if no other normal encoders are found
        [self performSelector:@selector(makeCoachExternal) withObject:nil afterDelay:40];
    }
    
    if (!instance){
        instance = self;
    }
    
    return self;
}


// Quick singleton of first created EncoderManager
+(EncoderManager*)getInstance
{
    return instance;
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
        [obj issueCommand:EVENT_GET_TAGS priority:1 timeoutInSec:15 tagData:requestData timeStamp:GET_NOW_TIME];
    }];
    
}






#pragma mark -
#pragma mark Encoder Administartion

// This method switches encoders if need then changes the event. It will also build event if it has not been built
-(void)declareCurrentEvent:(Event*)event
{
    
    
 [[ImageAssetManager getInstance]thumbnailsUnloadAll];
    
    // if the event is current event then it needs to be closed to save space
    // This will convert all tags to dicts on the event and remove tag observers
    if (([self.primaryEncoder event] != event && event != nil)|| event == nil) {
        [[self.primaryEncoder event] closeEvent];
        
        // This needs to be fixed
//        [[ImageAssetManager getInstance]thumbnailsUnload:grabAllThumbNamesFromEvent([self.primaryEncoder event])];
        
        // just remove all thumbs instead
//        [[ImageAssetManager getInstance]thumbnailsUnloadAll];
    }
    
        [self.primaryEncoder event].primary = false;
        if (event == nil) {
            
            
            if ([[self.primaryEncoder event].name isEqualToString:self.liveEvent.name]) {

                [[self.primaryEncoder event] closeEvent];
                
                self.liveEvent = nil;
            }
            if (self.primaryEncoder) [self.primaryEncoder removeFromPrimary];
            self.primaryEncoder = nil;
        } else {
            
            if (event.isBuilt){
    
                if(!event.open)[event openEvent];
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
            
            // Pool all thumb nails
            [[ImageAssetManager getInstance]thumbnailsPreload:grabAllThumbNamesFromEvent(event)];
            
            
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
    Encoder * newEncoder;
    if ([ip isEqualToString:@"device"]) {
       
        newEncoder        = [[Encoder alloc]initWithIP:ip];
        newEncoder.encoderManager   = self;
        newEncoder.name             = name;
        newEncoder.urlProtocol      = @"device";
        [newEncoder requestVersion];
        [newEncoder authenticateWithCustomerID:[UserCenter getInstance].customerID];
        [dictOfEncoders setValue:newEncoder forKey:name];
        
        PXPLog(@"*** Registered Encoder ***");
        PXPLog(@"    %@ - %@",newEncoder.name,ip);
        PXPLog(@"**************************");
    
    } else if ([dictOfEncoders objectForKey:name] == nil || [((Encoder*)[dictOfEncoders objectForKey:name]).name isEqualToString:@"trashed"]) {
        newEncoder        = [[Encoder alloc]initWithIP:ip];
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
    if (!registerEncoder.authenticated){
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"myplayXplay",nil)
                                                                        message:[NSString stringWithFormat:@"You don’t have the credentials to use encoder %@",registerEncoder.name]
                                                                 preferredStyle:UIAlertControllerStyleAlert];
        // build NO button
        UIAlertAction* cancelButtons = [UIAlertAction
                                        actionWithTitle:@"Ok"
                                        style:UIAlertActionStyleCancel
                                        handler:^(UIAlertAction * action)
                                        {
                                            [[CustomAlertControllerQueue getInstance] dismissViewController:alert animated:YES completion:nil];
                                        }];
        [alert addAction:cancelButtons];
        
        [[CustomAlertControllerQueue getInstance] presentViewController:alert inController:ROOT_VIEW_CONTROLLER animated:YES style:AlertImportant completion:nil];
    }
    
    if (registerEncoder.authenticated  && ![_authenticatedEncoders containsObject:registerEncoder]) {
        [_authenticatedEncoders addObject:registerEncoder];
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_ENCODER_COUNT_CHANGE object:self];
        
        if (!self.primaryEncoder ) {
            self.primaryEncoder = registerEncoder;
        }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////// THIS IS TEMP FOR IVANS MEETING ///////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        // this is a temp
        if ([dictOfEncoders count] > 1 && ![registerEncoder.name isEqualToString:@"trashed"]) {
            
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
                Encoder* electedMaster = ((Encoder*)[weakEncoderManager->dictOfEncoders objectForKey:pick]);
               weakEncoderManager.masterEncoder = electedMaster;
                electedMaster.isMaster =YES;
                
                PXPLog(@"%@ is set to master!",weakEncoderManager.masterEncoder.name);
                
                if (electedMaster.liveEvent){
                    [weakEncoderManager declareCurrentEvent:electedMaster.liveEvent];
                    weakEncoderManager.liveEvent = electedMaster.liveEvent;
                     //[[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_LIVE_EVENT_FOUND object:electedMaster];
                }
                
                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_EM_FOUND_MASTER object:weakEncoderManager];
            }];
            [askPickMaster presentPopoverCenteredIn:[UIApplication sharedApplication].keyWindow.rootViewController.view
                                           animated:YES];
            
        } else if ([dictOfEncoders count] == 1 && ![registerEncoder.name isEqualToString:@"trashed"] && self.masterEncoder == nil) {
            
            self.masterEncoder = (Encoder*)[[dictOfEncoders allValues] firstObject];;
            self.masterEncoder.isMaster =YES;
            
            PXPLog(@"%@ is set to master!",self.masterEncoder.name);
            
            if (self.masterEncoder.liveEvent){
                [self declareCurrentEvent:self.masterEncoder.liveEvent];
                self.masterEncoder.liveEvent = self.masterEncoder.liveEvent;
                //[[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_LIVE_EVENT_FOUND object:self.masterEncoder];
            }
            
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_EM_FOUND_MASTER object:self];

            
        }

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
    } else if (!registerEncoder.authenticated) {
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_EM_CONNECTION_ERROR object:registerEncoder];
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
    if (aEncoder == self.primaryEncoder){
        [aEncoder removeFromPrimary];
        [self declareCurrentEvent:nil];
    }
    [aEncoder destroy];
    [_authenticatedEncoders removeObject:aEncoder];
    [dictOfEncoders removeObjectForKey:aEncoder.name];
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_ENCODER_COUNT_CHANGE object:self];
    if (_authenticatedEncoders.count == 0 ) {
        
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"No Encoder"
                                                                        message:@"No Encoder is connected"
                                                                 preferredStyle:UIAlertControllerStyleAlert];
        // build NO button
        UIAlertAction* cancelButtons = [UIAlertAction
                                        actionWithTitle:OK_BUTTON_TXT
                                        style:UIAlertActionStyleCancel
                                        handler:^(UIAlertAction * action)
                                        {
                                            [[CustomAlertControllerQueue getInstance] dismissViewController:alert animated:YES completion:nil];
                                        }];
        [alert addAction:cancelButtons];
        
        if ([UserCenter getInstance].customerEmail){
            [[CustomAlertControllerQueue getInstance] presentViewController:alert inController:ROOT_VIEW_CONTROLLER animated:YES style:AlertImportant completion:nil];
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_STATUS_LABEL_CHANGED object:nil userInfo:@{@"text":@"No Encoder"}];
    }

}


-(void)setPrimaryEncoder:(id<EncoderProtocol>)primaryEncoder
{
//    if (_primaryEncoder == primaryEncoder) return;

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
    Event               * theEvent         = (Event *)note.object;
    NSString            * source           = note.userInfo[@"source"];
    NSString            * encoderSource    = (source)?[theEvent.mp4s objectForKey:source][@"hq"]:[[theEvent.mp4s allValues]firstObject][@"hq"];
    NSMutableDictionary * eventDic         = [self.masterEncoder.allEvents objectForKey:theEvent.name];
    
    if (theEvent.isBuilt){
        PXPLog(@"Event Download started!");
        NSLog(@"Event Download started!");
        __block Event * weakEvent = theEvent;

        
        NSString * videoFolderPath      = [_localMediaManager saveEvent:eventDic]; // This makes a plist for the event and a location to save the video
        __block Event * weakLocalEvent  = [_localMediaManager getEventByName:weakEvent.name];
        NSString * savedFileName        = [encoderSource lastPathComponent];
        NSString * downloaderKey        = [NSString stringWithFormat:@"%@_%@",theEvent.name,source ];
        
        
        NSArray * thmbs = grabAllThumbNamesFromEvent(weakEvent);
        for (NSString * item in thmbs) {
            NSString * fileName = [item lastPathComponent];

            NSString * thbPath = [videoFolderPath stringByAppendingPathComponent:@"thumbnails"];
            thbPath = [thbPath stringByAppendingPathComponent:fileName];

            (void)[Downloader downloadURL:item to:thbPath type:DownloadItem_TypeImage];

        }
        
        DownloadItem * item =         [Downloader downloadURL:encoderSource to:[videoFolderPath stringByAppendingPathComponent:savedFileName] type:DownloadItem_TypeVideo key:downloaderKey];
        [item setOnComplete:^{
//            weakLocalEvent.originalFeeds;
            
            [weakLocalEvent buildFeeds];
        }];
        

        
        
    } else {
        PXPLog(@"Event Download Failed... Event was not built... please try again later");
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
    /*_masterEncoder = note.object;
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_EM_FOUND_MASTER object:self];*/
}

-(void)onMasterLost:(NSNotification*)note
{
    /*[self.authenticatedEncoders removeObject:self.masterEncoder];
    
    if (self.masterEncoder !=nil) [self unRegisterEncoder:self.masterEncoder];
    
    if ( [self.liveEvent.name isEqualToString:self.currentEvent]){
        self.currentEvent = nil;
    }
    
    self.liveEvent = nil;
    
    [self.authenticatedEncoders enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[Encoder class]]){ // this is so it does not get the local encoder to search
            Encoder * anEncoder = (Encoder *) obj;
            [anEncoder searchForMaster];
        }
    }];*/

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
    if ([_authenticatedEncoders count] == 0 && self.hasMAX && [[UserCenter getInstance].customerEmail isEqualToString:@"coach"] && self.masterEncoder == nil){
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
        
        if (![[UserCenter getInstance].customerID isEqualToString:@"Guest"])[[UserCenter getInstance] updateTagInfoFromCloud];
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

