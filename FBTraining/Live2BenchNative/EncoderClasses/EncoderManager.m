//
//  EncoderManager.m
//  Live2BenchNative
//
//  Created by dev on 10/17/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "EncoderManager.h"
#import "Encoder.h"
#import "LocalEncoder.h"

#import "EncoderCommands.h"
#import "EncoderStatusMonitor.h"
#import "Utility.h"
#import "EncoderManagerActionPack.h" // All actions are in here!
#import <SDWebImage/SDImageCache.h>
#define GET_NOW_TIME        [NSNumber numberWithDouble:CACurrentMediaTime()]
#define GET_NOW_TIME_STRING [NSString stringWithFormat:@"%f",CACurrentMediaTime()]

// HELPER CLASSES  // // // // // // // // // // // // // // // // // // // // // // // //
@interface EncoderDataSync : NSObject
@property (nonatomic,assign)  BOOL            complete;
-(id)initWith:(NSArray*)aToObserve name:(NSString*)aName timeStamp:(NSNumber *)aTime onFinish: (void (^)(NSArray * pooledResponces))aOnComplete;

@end

@implementation EncoderDataSync
{
    NSMutableArray  * _colletedResponce;
    NSMutableDictionary  * _colletedResponceDict;
    NSString        * _name;
    NSArray         * _encodersBeingWatched;
    NSInteger       _countOfLeftToComplete;
    void            (^_onComplete)(NSArray*pooled);
    void            (^_onCompleteDict)(NSDictionary*pooled);
    void            * _context;
    NSNumber        * _timeStamp;
    BOOL            _earlyBirdMode;

}

@synthesize complete = _complete;


-(id)init
{
    self = [super init];
    if (self){
        _earlyBirdMode          = NO;
        _complete               = YES;
        _colletedResponce       = [[NSMutableArray alloc]init];
        _name                   = @"None";
        _countOfLeftToComplete  = 0;
        _encodersBeingWatched   = @[];
    }
    return self;
}


/**
 *  This class is basically watches x number of encoders during a request and runs a block after all encoders have finished 
 *  passing the data thru the block as an Array of each of the responeses
 *
 *  @param aToObserve  list of encoders
 *  @param aName       Name of notification to be observed
 *  @param aOnComplete block to run on completion
 *
 *  @return instance
 */
-(id)initWith:(NSArray*)aToObserve name:(NSString*)aName timeStamp:(NSNumber *)aTime onFinish: (void (^)(NSArray * pooledResponces))aOnComplete
{
    self = [super init];
    if (self){
        _complete               = NO;
        _colletedResponce       = [[NSMutableArray alloc]init];
        _colletedResponceDict   = [[NSMutableDictionary alloc]init];
        _name                   = aName;
        _encodersBeingWatched   = aToObserve;
        _countOfLeftToComplete  = _encodersBeingWatched.count;
        _onComplete             = aOnComplete;
        _timeStamp              = aTime;
        
        for (EncoderDataSync *edS in _encodersBeingWatched) {
             [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recievedNotifcation:) name:_name object:edS];
        }
        

    }
    return self;
}


/**
 *  This class is basically watches x number of encoders during a request and runs a block after all encoders have finished
 *  passing the data thru the block as an Array of each of the responeses
 *
 *  @param aToObserve  list of encoders
 *  @param aName       Name of notification to be observed
 *  @param aOnComplete block to run on completion
 *
 *
 */
-(void)syncAll:(NSArray*)aToObserve name:(NSString*)aName timeStamp:(NSNumber *)aTime onFinish: (void (^)(NSArray * pooledResponces))aOnComplete
{
    
    if (!_complete){
        [self cancel];
    }
    _earlyBirdMode          = NO;
    _complete               = NO;
    _name                   = aName;
    _encodersBeingWatched   = aToObserve;
    _countOfLeftToComplete  = _encodersBeingWatched.count;
    _onComplete             = aOnComplete;
    _timeStamp              = aTime;
    
    _colletedResponce       = [[NSMutableArray alloc]init];
    _colletedResponceDict   = [[NSMutableDictionary alloc]init];
    
    
    for (EncoderDataSync *edS in _encodersBeingWatched) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recievedNotifcation:) name:_name object:edS];
    }
}


-(void)syncAll:(NSArray*)aToObserve name:(NSString*)aName timeStamp:(NSNumber *)aTime onFinishDict: (void (^)(NSDictionary * pooledResponces))aOnComplete
{
    
    if (!_complete){
        [self cancel];
    }
    _earlyBirdMode          = NO;
    _complete               = NO;
    _name                   = aName;
    _encodersBeingWatched   = aToObserve;
    _countOfLeftToComplete  = _encodersBeingWatched.count;
    _onCompleteDict             = aOnComplete;
    _timeStamp              = aTime;
    
    _colletedResponce       = [[NSMutableArray alloc]init];
    _colletedResponceDict   = [[NSMutableDictionary alloc]init];
    
    
    for (EncoderDataSync *edS in _encodersBeingWatched) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recievedNotifcation:) name:_name object:edS];
    }
}


// This method requests from all passed encoders and the first one to respond is not canceled
-(void)earlyBird:(NSArray*)aToObserve name:(NSString*)aName timeStamp:(NSNumber *)aTime onFinish: (void (^)(NSArray * pooledResponces))aOnComplete
{
    if (!_complete){
        [self cancel];
    }
    _earlyBirdMode          = YES;
    _complete               = NO;
    _name                   = aName;
    _encodersBeingWatched   = aToObserve;
    _countOfLeftToComplete  = _encodersBeingWatched.count;
    _onComplete             = aOnComplete;
    _timeStamp              = aTime;
    
    _colletedResponce       = [[NSMutableArray alloc]init];
    _colletedResponceDict   = [[NSMutableDictionary alloc]init];
    
    
    for (EncoderDataSync *edS in _encodersBeingWatched) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recievedNotifcation:) name:_name object:edS];
    }

    
}



/**
 *  This collects the data responce that is sent with the notif
 *
 *  @param note Notification with responce data
 */
-(void)recievedNotifcation:(NSNotification *)note
{
    if (_timeStamp != [NSNumber numberWithDouble:[[note.userInfo objectForKey:@"timeStamp"]doubleValue]])
    
    _countOfLeftToComplete--;
   if (_onComplete)   [_colletedResponce addObject: [note.userInfo objectForKey:@"responce"] ];
    if (_onCompleteDict){
        NSDictionary * collect = [note.userInfo objectForKey:@"responce"];
        [_colletedResponceDict addEntriesFromDictionary:collect];
    }
    if (!_countOfLeftToComplete || _earlyBirdMode) [self onCompletion];
}

/**
 *  This method is run when all the encders have responced
 *  This object will be flaged as complete
 *  it will remove the observers
 * it will also run the block. The argeument passed into the block is an Array of all the responces from the encoders
 *
 */
-(void)onCompletion
{
    self.complete = YES;
    [_encodersBeingWatched enumerateObjectsUsingBlock:^(Encoder *obj, NSUInteger idx, BOOL *stop){
        [[NSNotificationCenter defaultCenter] removeObserver:self name:_name object:obj];
    }];
    if (_onComplete)        _onComplete([_colletedResponce copy]);
    if (_onCompleteDict)    _onCompleteDict([_colletedResponceDict copy]);
    [self cancel];
}


// cancel current command
-(void)cancel
{
 //   NSLog(@"Cancel Sync: %@",_name);
    _onComplete = nil;
    [_colletedResponce removeAllObjects];
    _name                   = @"";

    [_encodersBeingWatched enumerateObjectsUsingBlock:^(Encoder *obj, NSUInteger idx, BOOL *stop){
        [[NSNotificationCenter defaultCenter] removeObserver:self name:_name object:obj];
        
        // this needs to reamove the command from the queue or cancel all
    }];
    _countOfLeftToComplete  = 0;
    

}


@end


#pragma mark - End of Helper Classes
// END OF HELPER CLASSES// // // // // // // // // // // // // // // // // // // // // // // // //
// END OF HELPER CLASSES// // // // // // // // // // // // // // // // // // // // // // // // //
// END OF HELPER CLASSES// // // // // // // // // // // // // // // // // // // // // // // // //
// END OF HELPER CLASSES// // // // // // // // // // // // // // // // // // // // // // // // //
// END OF HELPER CLASSES// // // // // // // // // // // // // // // // // // // // // // // // //


@implementation EncoderManager
{

    NSMutableArray              * foundEncoders;
    NSNetServiceBrowser         * serviceBrowser;   //serviceBrowser searches for services
    NSMutableArray              * services;         //array of netservices which are detected
    NSMutableDictionary         * dictOfIPs;        //dictionary of all IPs detected
    NSMutableDictionary         * dictOfEncoders;
    NSMutableArray              * arrayOfTagSets;
    NSMutableDictionary         * _dictOfAccountInfo; // this will take in the from the global ACCOUNT_INFO, to cut down access to the global
    EncoderDataSync             * encoderSync;
   
    LocalEncoder                * _localEncoder;

    id                          _userDataObserver;
    id                          _masterLostObserver;
    id                          _masterFoundObserver;
    id                          _encoderReadyObserver;
    
    
    CheckWiFiAction             * checkWiFiAction;
    CheckForACloudAction        * checkForACloudAction;
    CheckMasterEncoderAction    * checkMasterEncoderAction;
    LogoutAction                * logoutAction;
}

@synthesize mode                    = _mode;

@synthesize hasWiFi                 = _hasWiFi;
@synthesize hasMAX                  = _hasMAX;


@synthesize customerID              = _customerID;
@synthesize hasLive                 = _hasLive;
@synthesize searchForEncoders       = _searchForEncoders;
@synthesize feeds                   = _feeds;
@synthesize currentEvent            = _currentEvent;
@synthesize currentEventType        = _currentEventType;
@synthesize currentEventData        = _currentEventData;
@synthesize currentEventTags        = _currentEventTags;
@synthesize allEvents               = _allEvents;
@synthesize authenticatedEncoders   = _authenticatedEncoders;
@synthesize openDurationTags        = _openDurationTags;
@synthesize liveEventName           = _liveEventName;
@synthesize eventTags               = _eventTags;
@synthesize masterEncoder           = _masterEncoder;
@synthesize cloudEncoder            = _cloudEncoder;
@synthesize totalCameraCount        = _totalCameraCount;


#pragma mark - Encoder Manager Methods

-(id)initWithLocalDocPath:(NSString*)aLocalDocsPath
{
    

    self = [super init];
    if (self){

        foundEncoders           = [[NSMutableArray alloc]init];
        _authenticatedEncoders  = [[NSMutableArray alloc]init];
        dictOfEncoders          = [[NSMutableDictionary alloc]init];
        _openDurationTags       = [[NSMutableDictionary alloc]init];
        _eventTags              = [[NSMutableDictionary alloc]init];
        _liveEventName          = @"None";

        // Browse for services
        // Starts Bonjour search for pxp servers
        services                = [[NSMutableArray alloc]init];
        serviceBrowser          = [NSNetServiceBrowser new] ;
        serviceBrowser.delegate = self;
//       [serviceBrowser searchForServicesOfType:@"_pxp._udp" inDomain:@""];
        
        

        arrayOfTagSets          = [[NSMutableArray alloc]init];
        _feeds                  = [[NSMutableDictionary alloc]init];
        
        _cloudEncoder           = [[CloudEncoder alloc]initWithIP:[self getIPAddress]];  // started in searchForEncoders
        [_cloudEncoder startObserving];
        
        
        
        
        
        _localEncoder           = [[LocalEncoder alloc]initWithDocsPath:aLocalDocsPath];
        [_authenticatedEncoders addObject:_localEncoder];
        
        _currentEventType       = SPORT_HOCKEY;
        _searchForEncoders      = NO;
        encoderSync             = [[EncoderDataSync alloc]init];
        _hasLive                = NO; // default before checking
        
        // setup observers
  
        _userDataObserver       = [[NSNotificationCenter defaultCenter]addObserverForName:NOTIF_USER_INFO_RETRIEVED     object:nil queue:nil usingBlock:^(NSNotification *note) {
            _dictOfAccountInfo       = (NSMutableDictionary*)note.object;
            [[NSNotificationCenter defaultCenter]removeObserver:_userDataObserver];
        }];
        
        _masterFoundObserver = [[NSNotificationCenter defaultCenter]addObserverForName:NOTIF_ENCODER_MASTER_FOUND    object:nil queue:nil usingBlock:^(NSNotification *note) {
            _masterEncoder = (Encoder *)note.object;
            [self refresh];
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_EM_FOUND_MASTER object:self];

        }];
        
          _masterLostObserver  = [[NSNotificationCenter defaultCenter]addObserverForName:NOTIF_ENCODER_MASTER_HAS_FALLEN     object:nil queue:nil usingBlock:^(NSNotification *note) {
            _masterEncoder = nil;
            _liveEventName = nil;
            [self.authenticatedEncoders enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[Encoder class]]){ // this is so it does not get the local encoder to search
                    Encoder * anEncoder = (Encoder *) obj;
                    [anEncoder searchForMaster];
                }
            }];
        }];
        
        _encoderReadyObserver     = [[NSNotificationCenter defaultCenter]addObserverForName:NOTIF_THIS_ENCODER_IS_READY    object:nil queue:nil usingBlock:^(NSNotification *note) {
            
            
            Encoder * anEncoder = (Encoder *) note.object; // was _masterEncoder. before
            
            if (anEncoder.liveEventName) {
                _liveEventName = anEncoder.liveEventName;
                [self refresh];
                 [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MASTER_HAS_LIVE object:nil];
            }

            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_ENCODER_COUNT_CHANGE object:self];
        }];

        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(_observerForTagPosting:) name:NOTIF_TAG_POSTED object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(masterCommands:) name:NOTIF_MASTER_COMMAND object:nil]; // watch whole app for start or stop events
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(oberverForEncoderStatus:) name:NOTIF_ENCODER_STAT object:nil];

        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(masterHasLive:) name:NOTIF_MASTER_HAS_LIVE object:nil];
        
        // making actions
        
        
        checkWiFiAction             = [[CheckWiFiAction alloc]initWithEncoderManager:self];
        checkForACloudAction        = [[CheckForACloudAction alloc]initWithEncoderManager:self];
        checkMasterEncoderAction    = [[CheckMasterEncoderAction alloc]initWithEncoderManager:self];
        logoutAction                = [[LogoutAction alloc]initWithEncoderManager:self];
        
    }
    return self;
}

static void * authenticatContext    = &authenticatContext;
static void * statusContext         = &statusContext;
static void * builtContext          = &builtContext; // depricated?

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
        [newEncoder addObserver:self forKeyPath:@"authenticated"    options:0 context:authenticatContext];
        [newEncoder addObserver:self forKeyPath:@"status"           options:0 context:statusContext];
        newEncoder.name         = name;
        [newEncoder requestVersion];
        [newEncoder authenticateWithCustomerID:_customerID];
        if (_masterEncoder == nil) [newEncoder searchForMaster];        
        [dictOfEncoders setValue:newEncoder forKey:name];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(oberverForFeedChange:) name:NOTIF_ENCODER_FEEDS_UPDATED object:newEncoder];
        // test
        
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
    
    NSLog(@"   ENCODER REMOVED: %@",aEncoder.name);
    [aEncoder removeObserver:self forKeyPath:@"authenticated"];
    [aEncoder removeObserver:self forKeyPath:@"status"];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_ENCODER_FEEDS_UPDATED object:aEncoder];
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_ENCODER_COUNT_CHANGE object:self];
    [aEncoder destroy];
    if (_masterEncoder == aEncoder){
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_ENCODER_MASTER_HAS_FALLEN object:self];
        _masterEncoder = nil;
        NSLog(@"Master Linched!");
    }
    [_authenticatedEncoders removeObject:aEncoder];
    [dictOfEncoders removeObjectForKey:aEncoder.name];
}

// depricated
-(void)updateUserInfo:(NSNotification*)note
{
     _dictOfAccountInfo       = (NSMutableDictionary*)note.object;
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_USER_INFO_RETRIEVED object:nil];

}

// depricated
-(void)masterFound:(NSNotification*)note
{
     _masterEncoder = (Encoder *)note.object;
    
}
// depricated
-(void)masterLost:(NSNotification*)note
{
    _masterEncoder = nil;
    [self.authenticatedEncoders enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[Encoder class]]){ // this is so it does not get the local encoder to search
            Encoder * anEncoder = (Encoder *) obj;
            [anEncoder searchForMaster];
        }
    }];
    
}

-(void)masterHasLive:(NSNotification *)note
{
//    self.liveEventName  = _masterEncoder.liveEventName;
    
    self.currentEvent   = self.liveEventName;
    [self deleteAllThumbs];
    [self requestTagDataForEvent:_liveEventName onComplete:^(NSDictionary *all) {
        
        [_eventTags setObject:all forKey:_liveEventName];
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_CLIPVIEW_TAG_RECEIVED object:nil];
    }];



}


-(void)setMode:(EncoderManagerMode)mode
{
    if (mode == _mode)return;
    
    [self willChangeValueForKey:@"mode"];
    switch (mode) {
        case EncoderManagerModeOnline:
            
            break;
        case EncoderManagerModeOffline:
//            _masterEncoder = _localEncoder;
            break;
        default:
            break;
    }
    
    
    _mode = mode;
    [self didChangeValueForKey:@"mode"];
    
}

-(EncoderManagerMode)mode
{
    return _mode;
}


#pragma mark -

// this method was added to possibly sync the feed changes since only the EncoderManager sees NOTIF_ENCODER_FEEDS_UPDATED
// the switchers see
-(void)oberverForFeedChange:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_ENCODER_FEED_HAVE_CHANGED object:self];
}


-(void)oberverForEncoderStatus:(NSNotification *)note
{
    Encoder * encoder = (Encoder * )note.object;
    
    NSLog(@"status !!!!!");
    switch (encoder.status) {
        case ENCODER_STATUS_UNKNOWN: // Disconnected
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
         //   [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_ENCODER_COUNT_CHANGE object:self];
        }
    }

}


-(void)_observerForTagPosting:(NSNotification*)note
{
    NSLog(@"Recieved a tage from the bottom view controller or some where");
    NSMutableDictionary * tagData   = [NSMutableDictionary dictionaryWithDictionary:note.userInfo];
    BOOL isDuration                 = ([note.userInfo objectForKey:@"duration"])?[[note.userInfo objectForKey:@"duration"] boolValue ]:FALSE;
    [self createTag:tagData isDuration:isDuration];
}

#pragma mark - Bonjour Methods
// Services Methods     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

//---services found---
-(void)netServiceBrowser:(NSNetServiceBrowser *)aBrowser didFindService:(NSNetService *)aService moreComing:(BOOL)more {
    [services addObject:aService];
    [self resolveIPAddress:aService];
}

//---services removed from the network---
-(void)netServiceBrowser:(NSNetServiceBrowser *)aBrowser didRemoveService:(NSNetService *)aService moreComing:(BOOL)more {
    [services removeObject:aService];
}

//---resolve the IP address of a service---
-(void) resolveIPAddress:(NSNetService *)service {
    NSNetService *remoteService = service;
    remoteService.delegate = self;
    [remoteService resolveWithTimeout:0];
}

//---managed to resolve---
-(void)netServiceDidResolveAddress:(NSNetService *)service {

    if (!_searchForEncoders)return; // disable the ability to search
    
    NSString *name          = nil;
    NSData *address         = nil;
    struct sockaddr_in *socketAddress = nil;
    NSString *ipString      = nil;
    int port;
    BOOL isSameNetwork      = TRUE;
    NSString *deviceIP      = [self getIPAddress];
    
    NSArray *parseLocalIP   = [[NSArray alloc]initWithArray:[deviceIP componentsSeparatedByString:@"."]]; //split the local ip of the device into an array of each number -- used to compare to remote ip(test if on the same network
    
    for(int i=0;i < [[service addresses] count]; i++ )
    {
        name                    = [service name];//retrieve unique name of bonjservice
        address                 = [[service addresses] objectAtIndex: i];
        socketAddress           = (struct sockaddr_in *) [address bytes];
        ipString                = [NSString stringWithFormat: @"%s", inet_ntoa(socketAddress->sin_addr)];
        NSArray *parseRemoteIP  = [[NSArray alloc]initWithArray:[ipString componentsSeparatedByString:@"."]]; //parse remote ip into an array to compare with local ip
        
        for(NSString *subIP in parseRemoteIP)
        {
            int i = [parseRemoteIP indexOfObject:subIP];
            if(![subIP isEqualToString:[parseLocalIP objectAtIndex:i]]&&i<3)//compare only the first 3 numbers in the ip address
            {
                isSameNetwork=FALSE; // if the numbers don't equal each other then we don't want it, set the bool to false
            }
        }
        
        port = socketAddress->sin_port; // grab port
        
        if(isSameNetwork)
        {
            NSArray *arrayOfStrings = [name componentsSeparatedByString:@" - "];
            [dictOfIPs setValue:[NSString stringWithFormat:@"http://%@:%d",ipString,htons(port)] forKey:[arrayOfStrings objectAtIndex:0]];
            //globals.URL=[NSString stringWithFormat:@"http://%@:%d",ipString,htons(port)];//set the global url parameter to our ipstring:port -- we need to use htons to flip the bytes returned by the port
            //globals.CURRENT_PLAYBACK_EVENT=[NSString stringWithFormat:@"%@/events/live/video/list.m3u8",globals.URL];

            NSString *hostName = [service hostName];
            if ([[service hostName] hasSuffix:@".local."]){
                hostName = [[service hostName] stringByReplacingOccurrencesOfString:@".local." withString:@""];
            }
            [dictOfIPs setValue:[NSString stringWithFormat:@"http://%@:%d",ipString,htons(port)] forKey:hostName];
            
            [self registerEncoder:hostName ip:ipString];
        }
    }

}

//---did not managed to resolve---
-(void)netService:(NSNetService *)service didNotResolve:(NSDictionary *)errorDict {
    
}




// END of Services Methods ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
        } else if ([data objectForKey:@"pause"]) {
            [_masterEncoder issueCommand:PAUSE_EVENT    priority:3 timeoutInSec:6 tagData:requestData timeStamp:GET_NOW_TIME];
        }  else if ([data objectForKey:@"resume"]) {
            [_masterEncoder issueCommand:RESUME_EVENT    priority:3 timeoutInSec:6 tagData:requestData timeStamp:GET_NOW_TIME];
        }
    }

}

#pragma mark - Command Methods

-(void)logoutOfCloud
{
    [_cloudEncoder logoutOfCloud];
}


-(void)pushTag:(NSMutableDictionary *)tagSet
{
    [arrayOfTagSets addObject:tagSet];
}

// Getters
-(BOOL)hasInternet
{
    SCNetworkReachabilityFlags flags;
    BOOL receivedFlags;
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(CFAllocatorGetDefault(), [@"www.google.com" UTF8String]);
    
    receivedFlags = SCNetworkReachabilityGetFlags(reachability, &flags);
    
    CFRelease(reachability);
    
    return  (!receivedFlags || flags == 0) ? FALSE : TRUE;

}


-(BOOL)hasWiFi
{
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&zeroAddress);
    if(reachability != NULL) {
        //NetworkStatus retVal = NotReachable;
        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(reachability, &flags)) {
            if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
            {
                // if target host is not reachable
                CFRelease(reachability);
                return NO;
            }
            
            if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
            {
                // if target host is reachable and no connection is required
                //  then we'll assume (for now) that your on Wi-Fi
                CFRelease(reachability);
                return YES;
            }
            
            
            if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
                 (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
            {
                // ... and the connection is on-demand (or on-traffic) if the
                //     calling application is using the CFSocketStream or higher APIs
                
                if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
                {
                    // ... and no [user] intervention is needed
                    CFRelease(reachability);
                    return YES;
                }
            }
            
            if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0)
            {
                // ... but WWAN connections are OK if the calling application
                //     is using the CFNetwork (CFSocketStream?) APIs.
                CFRelease(reachability);
                return YES;
            }
        }
    }
    
    CFRelease(reachability);
    return NO;
    
//    return [uController hasConnectivity];
}



/**
 *  This method should get all the encoders to respond and finish then compile all the data and run the Block wne complete when
 *  the data is recieved. the final data will be pased thru the block
 *
 *  @param data          <#data description#>
 *  @param onCompleteGet <#onCompleteGet description#>
 */
-(void)reqestSummaryId:(NSString*)aId type:(NSString*)aType onComplete:(void(^)(NSArray*pooled))onCompleteGet
{
    NSMutableDictionary * sumRequestData = [NSMutableDictionary dictionaryWithDictionary:
                                            @{
                                             @"id":aId,
                                             @"type":aType,
                                             @"requesttime":GET_NOW_TIME_STRING,
                                             @"user":[_dictOfAccountInfo objectForKey:@"hid"]
                                              }];
    
    NSArray     * encoders          = [dictOfEncoders allValues];
    NSNumber    * nowTime             = GET_NOW_TIME;
    [encoders enumerateObjectsUsingBlock:^(Encoder *obj, NSUInteger idx, BOOL *stop){
        [obj issueCommand:SUMMARY_GET priority:1 timeoutInSec:15 tagData:sumRequestData timeStamp:nowTime];
    }];
   
    [encoderSync syncAll:encoders name:NOTIF_ENCODER_CONNECTION_FINISH timeStamp:nowTime onFinish:onCompleteGet];

}

-(void)updateSummaryId:(NSString*)aId type:(NSString*)aType summary:(NSString*)aSummary onComplete:(void(^)(NSArray*pooled))onCompleteGet
{
    NSMutableDictionary * sumRequestData = [NSMutableDictionary dictionaryWithDictionary:
                                            @{
                                              @"id":aId,
                                              @"type":aType,
                                              @"summary":aSummary,
                                              @"requesttime":GET_NOW_TIME_STRING,
                                              @"user":[_dictOfAccountInfo objectForKey:@"hid"]
                                              }];
    NSNumber    * nowTime               = GET_NOW_TIME;
    
    // updating game summary only on the encoder that has the game
    if ([aType isEqualToString:@"game"]){
        //[sumRequestData setObject:GET_NOW_TIME_STRING forKey:@"requesttime"];
        NSArray         * encoders          = [dictOfEncoders allValues];
        NSMutableArray  * encodersWithGame  =  [[NSMutableArray alloc]init];
       [encoders enumerateObjectsUsingBlock:^(Encoder *obj, NSUInteger idx, BOOL *stop){
           if ([obj.allEvents containsObject:aId]) {
               [obj issueCommand:SUMMARY_PUT priority:1 timeoutInSec:15 tagData:sumRequestData timeStamp:nowTime];
               [encodersWithGame addObject:obj];
           }
        }];
        
        [_masterEncoder issueCommand:SUMMARY_PUT priority:1 timeoutInSec:10 tagData:sumRequestData timeStamp:nowTime];
        [encoderSync syncAll:[encodersWithGame copy] name:NOTIF_ENCODER_CONNECTION_FINISH timeStamp:nowTime onFinish:onCompleteGet];
        
    } else if ([aType isEqualToString:@"month"] && _masterEncoder) {
        [_masterEncoder issueCommand:SUMMARY_PUT priority:1 timeoutInSec:10 tagData:sumRequestData timeStamp:nowTime];
        [encoderSync syncAll:@[_masterEncoder] name:NOTIF_ENCODER_CONNECTION_FINISH timeStamp:nowTime onFinish:onCompleteGet];
    } else if ([aType isEqualToString:@"month"] && !_masterEncoder){
        // Alert the user that there is not master encoder
    }

}


-(void)reqestTeamData:(void(^)(NSArray*pooled))onCompleteGet
{

     if (_masterEncoder) {
         NSNumber    * nowTime             = GET_NOW_TIME;
        [_masterEncoder issueCommand:TEAMS_GET priority:1 timeoutInSec:10 tagData:nil timeStamp:nowTime];
//        encoderSync =  [[EncoderDataSync alloc]initWith:@[_masterEncoder] name:NOTIF_ENCODER_CONNECTION_FINISH timeStamp:GET_NOW_TIME onFinish:onCompleteGet];
         [encoderSync syncAll:@[_masterEncoder] name:NOTIF_ENCODER_CONNECTION_FINISH timeStamp:nowTime onFinish:onCompleteGet];
    } else {
        // Alert the user that there is not master encoder
    }
}



/**
 *  This creates tags on the server or local
 *
 *
 *  @param data          this is the custom data that will be added to the tag
 *  @param isDuration    if YES then it will be stored in a open Duration tag dict
 */
-(void)createTag:(NSMutableDictionary *)data isDuration:(BOOL)isDuration
{
    
    NSString *tagTime = [data objectForKey:@"time"];
    NSString *tagName = [data objectForKey:@"name"];
    NSString *eventNm = ([_currentEvent isEqualToString:_liveEventName])?@"live":_currentEvent;
    
    // This is the starndard info that is collected from the encoder
    NSMutableDictionary * tagData = [NSMutableDictionary dictionaryWithDictionary:
                                             @{
                                               @"event"         : eventNm,
                                               @"colour"        : [_dictOfAccountInfo objectForKey:@"tagColour"],
                                               @"user"          : [_dictOfAccountInfo objectForKey:@"hid"],
                                               @"time"          : tagTime,
                                               @"name"          : tagName,
//                                               @"comment"       : @"",
//                                               @"rating"        : @"0",
//                                               @"coachpick"     : @"0",
//                                               @"bookmark"      : @"0",
//                                               @"deleted"       : @"0",
//                                               @"edited"        : @"0",
                                               @"deviceid"      : [[[UIDevice currentDevice] identifierForVendor]UUIDString]
                                               }];
    if (isDuration){ // Add extra data for duration Tags
        NSDictionary *durationData =        @{
                                               @"starttime"     : tagTime
                                              };
        [tagData addEntriesFromDictionary:durationData];
    }


    
    
    
//    // Check if tag is open for this already, if so close it
//    if ([_openDurationTags objectForKey:tagName] != nil)
//    {
//        
//        [self closeDurationTag:tagName];
//        
//        
//    } else {
//        
//        [_openDurationTags setObject:tagData forKey:tagName];
//        // issues new tag command
//    }
    
    
    // issue command to all encoder with events
    NSArray     * encoders          = [_authenticatedEncoders copy];
    NSNumber    * nowTime             = GET_NOW_TIME;
    int timeout = [encoders count] * 10;
    [encoders enumerateObjectsUsingBlock:^(Encoder *obj, NSUInteger idx, BOOL *stop){
    // ignore local
        if (obj.event != nil){
            [obj issueCommand:MAKE_TAG priority:1 timeoutInSec:timeout tagData:tagData timeStamp:nowTime];
        }
    }];
    
    
    
}

-(void)modifyTag:(NSMutableDictionary *)data
{

}

-(void)closeDurationTag:(NSString *)tagName
{
    
    NSMutableDictionary * tag = [_openDurationTags objectForKey:tagName];
    [_openDurationTags removeObjectForKey:tagName];

    
    // issues mod tag command
    
    for (id <EncoderCommands> aEncoder  in _authenticatedEncoders) {
    
        [aEncoder issueCommand:MODIFY_TAG
                      priority:10
                  timeoutInSec:5
                       tagData:tag
                     timeStamp:GET_NOW_TIME];
    }
    
}
// Getters and setters
-(NSString*)currentEvent
{
    return _currentEvent;
    
}


// whe you set an event it will update the feeds to the correct feeds
-(void)setCurrentEvent:(NSString *)aCurrentEvent
{
    
    NSMutableSet * typeCollector =  [[NSMutableSet alloc]init];
    
    NSDictionary * eventData;
    
    NSMutableDictionary * temp  = [[NSMutableDictionary alloc]init];
    for (Encoder * encoder in _authenticatedEncoders) {
        encoder.event       = aCurrentEvent;
        if (encoder.eventType != nil){
            [typeCollector addObject:encoder.eventType];
            [temp addEntriesFromDictionary:encoder.feeds];
            eventData = encoder.eventData;
        }
    }
    _feeds = [temp copy];
    
    
    if (_masterEncoder && [_masterEncoder.event isEqualToString:aCurrentEvent]) eventData = _masterEncoder.eventData;
    
    
    _currentEventData = eventData;
    
    [self willChangeValueForKey:@"currentEvent"];
    _currentEvent = aCurrentEvent;
    [self didChangeValueForKey:@"currentEvent"];
    
    [typeCollector removeObject:@"none"]; // just incase
    [typeCollector removeObject:@""]; // just incase
    
    if ([_feeds count] >0 && [typeCollector count]>0){
        [self willChangeValueForKey:@"currentEventType"];
        // filter out none
        _currentEventType = (NSString *)[typeCollector anyObject];
        [self didChangeValueForKey:@"currentEventType"];
    }
    
    

        
    [self refresh];
    
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_ENCODER_FEED_HAVE_CHANGED object:self];
}

-(NSString*)currentEventType
{

  return [_currentEventType lowercaseString];
}



-(NSMutableArray*)allEvents
{
    NSMutableArray * temp  = [[NSMutableArray alloc]init];
    for (Encoder * encoder in _authenticatedEncoders) {
        [temp addObjectsFromArray:encoder.allEvents];
    }
    
    return temp;
}



// this gets all Events, Masters Event take priority and all events are unique.
-(NSMutableArray*)allEventData
{

    // Collects all data from encoders into a temp array
    NSMutableArray * temp1  = [[NSMutableArray alloc]init];
    for (Encoder * encoder in _authenticatedEncoders) {
        [temp1 addObjectsFromArray:encoder.allEventData];
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
            NSEnumerator * masterEnum = [_masterEncoder.allEventData objectEnumerator];
            id value2;
            while ((value2 = [masterEnum nextObject])) {
                NSDictionary * dict = value2;
                [uniqueDict setObject:dict forKey:[dict objectForKey:@"name"]];
            }
    }
    
    
    
    return [[uniqueDict allValues]copy];
}


-(void)requestTagDataForEvent:(NSString*)event onComplete:(void(^)(NSDictionary*all))onCompleteGet
{
    NSString * myEvent = ([event isEqualToString:_liveEventName])?@"live":event; // Converts event name to live if needed
    NSString * hid     = [_dictOfAccountInfo objectForKey:@"hid"];
    
    NSMutableDictionary * requestData = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                        @"user"        : hid,
                                                                                        @"requesttime" : GET_NOW_TIME,
                                                                                        @"device"      : [[[UIDevice currentDevice] identifierForVendor]UUIDString],
                                                                                        @"event"       : myEvent
                                                                                        }];

    NSArray     * encoders          = [dictOfEncoders allValues];
    NSNumber    * nowTime             = GET_NOW_TIME;
    [encoders enumerateObjectsUsingBlock:^(Encoder *obj, NSUInteger idx, BOOL *stop){
        [obj issueCommand:EVENT_GET_TAGS priority:1 timeoutInSec:15 tagData:requestData timeStamp:GET_NOW_TIME];
    }];
    
    
    [encoderSync syncAll:encoders name:NOTIF_ENCODER_CONNECTION_FINISH timeStamp:nowTime onFinish:^(NSArray *pooledResponces) {
//        this is where you collect all the raw data and convert it all in to one dict
        NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
        for (NSData * rData in pooledResponces) {
            NSDictionary * tags =[[Utility JSONDatatoDict:rData] objectForKey:@"tags"];
            if (tags)[dic addEntriesFromDictionary:tags];
        }
        
        onCompleteGet([dic copy]);
        
    }];
    
    
    
//    [encoderSync syncAll:encoders name:NOTIF_ENCODER_CONNECTION_FINISH timeStamp:nowTime onFinishDict:onCompleteGet];

}



-(NSMutableDictionary*)eventTags
{

    NSMutableDictionary* tags = [[NSMutableDictionary alloc]init];
    for (Encoder * encoder in _authenticatedEncoders) {
        if (encoder.eventTagsDict != nil ){
            [tags  addEntriesFromDictionary:encoder.eventTagsDict];
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

/**
 *  This menthod Will recollect all the data from the encoders for the current Event
 */
-(void)refresh
{

    
    
    // this collects all the tags from the encoders
    [self willChangeValueForKey:@"currentEventTags"];
    
    NSMutableArray * tempList  = [[NSMutableArray alloc]init];
    for (Encoder * encoder in _authenticatedEncoders) {
        if (encoder.eventType != nil && [encoder isKindOfClass:[LocalEncoder class]]){
            [tempList addObjectsFromArray:encoder.eventTags];
        }
        
    }
    _currentEventTags = [tempList copy];
    
    [self didChangeValueForKey:@"currentEventTags"];
    

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



/**
 *  This checks all the cameras for each encoder not counting Local encoder
 *
 *  @return count of cameras
 */
-(NSInteger)totalCameraCount
{
    NSInteger c = 0;
    for (Encoder * encoder in _authenticatedEncoders) {
        if (encoder.eventType != nil && [encoder isKindOfClass:[LocalEncoder class]]){
            c += encoder.cameraCount;
        }
        
    }
    return c;
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
        [serviceBrowser searchForServicesOfType:@"_pxp._udp" inDomain:@""];
        [_cloudEncoder updateTagInfoFromCloud];// search for cloud
    } else{
        [serviceBrowser stop];
    }
    [self willChangeValueForKey:@"searchForEncoders"];
    _searchForEncoders = searchForEncoders;
    [self didChangeValueForKey:@"searchForEncoders"];
    
}



// For debugging


#pragma mark - Debugging Methods


/**
 *  Removes all external Encoders and disables searching for others
 */
-(void)removeAllExternalEncoders
{
    _searchForEncoders  = NO;
    _masterEncoder      = nil;
    
    NSLog(@"Encoders to Removed: %i", [self.authenticatedEncoders count]);
    NSLog(@"master?: %@", _masterEncoder);
    [self.authenticatedEncoders enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[Encoder class]]){ // this is so it does not get the local encoder to search
            Encoder * anEncoder = (Encoder *) obj;
            [self unRegisterEncoder:anEncoder];
        }
    }];


}

-(void)deleteAllThumbs
{
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    [imageCache cleanDisk];
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString * path = [documentsDirectory stringByAppendingPathComponent:@"events/thumbnails"];
   
    
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:path])
    {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    NSError *cError;
    [fileManager createDirectoryAtPath:path withIntermediateDirectories:TRUE attributes:nil error:&cError];

}



-(NSString*)description
{
    NSString * txt = [NSString stringWithFormat:@"Encoder Manager - Type: %@\n Event:%@\n Encoders:\n",_currentEventType,_currentEvent];
    
    for (Encoder * enc in _authenticatedEncoders)
    {
        NSString * encoderStats = [NSString stringWithFormat:@"\t%@",enc.name];
        NSString * socialStatus;
        NSString * encoderStatus = [Utility encoderStatusToString:enc.status];
        encoderStats = [NSString stringWithFormat:@"%@%*c - ",encoderStats, 16 - encoderStats.length, ' '];
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
#pragma Utility Methods
- (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wired connection on a simulator, en1 - wifi on the simulator, or lo0 - wifi on an iPad
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"] ||
                   [[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en1"] ||
                   [[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"lo0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
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

/**
 *  logout of the cloud encoder
 *
 *  @return the action
 */
-(id<ActionListItem>)logoutAction
{
    logoutAction.isFinished = NO;
    logoutAction.isSuccess  = NO;
    return logoutAction;
}

@end

