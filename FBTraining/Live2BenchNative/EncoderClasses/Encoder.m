


//  Encoder.m
//  Live2BenchNative
//
//  Created by dev on 10/17/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "Encoder.h"
#import "CheckEncoderShutdown.h"
#import "Utility.h"
#import <objc/runtime.h>
#import "Feed.h"
#import "Tag.h"
#import "TagProxy.h"
#import "EncoderManager.h"
#import "CameraDetails.h"
#import "UserCenter.h"
#import "League.h"
#import "LeagueTeam.h"
#import "TeamPlayer.h"
#import "DownloadItem.h"
#import "ImageAssetManager.h"
#import "ParseModuleDefault.h"
#import "FeedMapController.h"
#import "DownloaderQueue.h"
#import "DownloadClipFromTag.h"

#define trimSrc(s)  [Utility removeSubString:@"s_" in:(s)]


#define GET_NOW_TIME_STRING [NSString stringWithFormat:@"%f",CACurrentMediaTime()]
#define trim(s)  [Utility removeSubString:@":timeStamp:" in:(s)]
#define SYNC_ME             @"SYNC_ME"
#define IS_AUTHENTICATING NO



// HELPER CLASS



// catagory  // catagory  // catagory  // catagory  // catagory  // catagory  // catagory  // catagory  // catagory

@interface NSURLConnection (Context)

@property (nonatomic,strong)    NSNumber        * timeStamp;
@property (nonatomic,strong)    NSMutableData   * cumulatedData;
@property (nonatomic,strong)    NSString        * connectionType;
@property (nonatomic,strong)    NSDictionary    * extra;
@property (nonatomic,weak)      CameraDetails   * cameraDetails;
@property (nonatomic,weak)      NSMutableArray  * camerasAvailableList;



-(NSNumber*)timeStamp;
-(void)setTimeStamp:(NSNumber*)time;

@end

@implementation NSURLConnection (Context)

@dynamic timeStamp;
@dynamic cumulatedData;
@dynamic connectionType;
@dynamic extra;
@dynamic cameraDetails;
@dynamic camerasAvailableList;


-(void)setTimeStamp:(NSNumber*)time
{
    objc_setAssociatedObject(self, @selector(timeStamp), time,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSNumber*)timeStamp
{
    return (NSNumber*)objc_getAssociatedObject(self,@selector(timeStamp));
}


-(void)setCumulatedData:(NSMutableData*)data
{
    objc_setAssociatedObject(self, @selector(cumulatedData), data,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSMutableData*)cumulatedData
{
    return (NSMutableData*)objc_getAssociatedObject(self,@selector(cumulatedData));
}


-(void)setConnectionType:(NSString*)type
{
    objc_setAssociatedObject(self, @selector(connectionType), type,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSString*)connectionType
{
    return (NSString*)objc_getAssociatedObject(self,@selector(connectionType));
}

-(void)setExtra:(NSDictionary *)extra
{
    objc_setAssociatedObject(self, @selector(extra), extra,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSDictionary*)extra
{
    return (NSDictionary*)objc_getAssociatedObject(self,@selector(extra));
}

@end





// END HELPER CLASSS


@implementation Encoder
{
    // Ready Flags
    BOOL isTeamsGet;
    BOOL isAuthenticate;

    void            (^_onCompleteDownloadClip)(NSArray*pooled);
}




@synthesize justStarted = _justStarted;
@synthesize pressingStart = _pressingStart;

@synthesize name = _name;
@synthesize ipAddress;
@synthesize version;
@synthesize URL;
@synthesize customerID;

@synthesize authenticated   = _authenticated;
@synthesize status          = _status;
@synthesize statusAsString  = _statusAsString;
@synthesize bitrate         = _bitrate;     // To be used with KVO
@synthesize event           = _event;

@synthesize isMaster        = _isMaster;
@synthesize liveEvent   = _liveEvent;
@synthesize cameraCount     = _cameraCount;
@synthesize encoderTeams    = _encoderTeams;
@synthesize encoderLeagues  = _encoderLeagues;
@synthesize isBuild         = _isBuild;
@synthesize isReady         = _isReady;

@synthesize isAlive;
@synthesize allEvents       = _allEvents;

@synthesize eventContext = _eventContext;
@synthesize urlProtocol = _urlProtocol;
// ActionListItems
@synthesize delegate,isFinished,isSuccess;


-(id)initWithIP:(NSString*)ip
{
    self = [super init];
    if (self){
        self.ipAddress  = ip;
        _authenticated  = NO;
        timeOut         = 15.0f;
        queue           = [[NSMutableDictionary alloc]init];
        _allEvents      = [[NSMutableDictionary alloc]init];
        isWaitiing      = NO;
        version         = @"?";
        _statusAsString = @"";
        _isMaster       = NO;
        isTeamsGet      = NO;
        isAuthenticate  = NO;
        _isBuild        = NO;
        _isReady         = NO;
        isAlive         = YES;
        _urlProtocol    = (YES)?@"http":@"device";
        _cameraCount    = 0;
        _status         = ENCODER_STATUS_INIT;
        _justStarted    = true;
        _parseModule    = [ParseModuleDefault new];
        _postedTagIDs   = [NSMutableSet new];
        self.cameraResource = [[CameraResource alloc]initEncoder:self];
        self.operationQueue = [NSOperationQueue new];
        self.operationQueue.maxConcurrentOperationCount = 1;
        
    }
    return self;
}

-(id <EncoderProtocol>)makePrimary
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onTagPost:)        name:NOTIF_TAG_POSTED           object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onModTag:)         name:NOTIF_MODIFY_TAG           object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onDeleteTag:)      name:NOTIF_DELETE_TAG           object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onDownloadClip:)   name:NOTIF_EM_DOWNLOAD_CLIP     object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onTelePost:)       name:NOTIF_CREATE_TELE_TAG      object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(ondeleteEvent:)      name:NOTIF_DELETE_EVENT_SERVER  object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(resetPlayerContext:) name:NOTIF_PXP_PLAYER_ERROR object:nil];
    return self;
}

-(id <EncoderProtocol>)removeFromPrimary
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_TAG_POSTED              object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_MODIFY_TAG              object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_DELETE_TAG              object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_EM_DOWNLOAD_CLIP        object:nil];
    self.event = nil;
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_DELETE_EVENT_SERVER     object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_CREATE_TELE_TAG         object:nil];
        [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_PXP_PLAYER_ERROR object:nil];
    return self;
}


// this is for quick fixes


-(void)resetPlayerContext:(NSNotification*)note
{

    PXPLog(@"Context has reset!!!!");
    self.event = self.event;

}


-(void)setJustStarted:(BOOL)justStarted{
    _justStarted = justStarted;
}

-(BOOL)justStarted{
    return _justStarted;
}

-(void)setEvent:(Event *)event
{
    /*if (event ==_event){
        return;
    }*/
    
    [self willChangeValueForKey:@"event"];
    _event      =  event;
    [self didChangeValueForKey:@"event"];
    NSString * eventType = (_event)?_event.eventType:@"";
    
    _eventContext.event = event;
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_EVENT_CHANGE object:self userInfo:@{@"eventType":eventType}];
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_TAG_RECEIVED object:_event];
}

-(void)resetEventAfterRemovingFeed:(Event *)event{
    _event = event;
    _eventContext.event = event;
}

-(Event*)event
{
    return _event;
}

#pragma - Make Commands

-(void)issueCommand:(NSString *)methodName priority:(int)priority timeoutInSec:(float)time tagData:(NSMutableDictionary*)tData timeStamp:(NSNumber *)aTimeStamp
{
    EncoderTask *cmd    = [[EncoderTask alloc]init];
    cmd.selector    = NSSelectorFromString(methodName);
    cmd.target      = self;
    cmd.priority    = priority;
    cmd.timeOut     = time;
    cmd.tagData     = tData;
    cmd.timeStamp   = aTimeStamp;
    [self addToQueue:cmd];
    int count =0;
    for (NSArray * arrayinQueue in [queue allValues]) {
        count += arrayinQueue.count;
    }
    
    if (count == 1) {
        isWaitiing  = NO;
        [self runNextCommand]; // run command as soon as issued if there is non in the queue
    }
    else if (currentCommand.priority < cmd.priority)
    {
        [encoderConnection cancel];
        isWaitiing = NO;
        [self runNextCommand];
    }
}


-(void)issueCommand:(NSString *)methodName priority:(int)priority timeoutInSec:(float)time tagData:(NSMutableDictionary*)tData timeStamp:(NSNumber *)aTimeStamp onComplete:(void(^)(NSDictionary*userInfo))onComplete
{
    EncoderTask *cmd    = [[EncoderTask alloc]init];
    cmd.selector    = NSSelectorFromString(methodName);
    cmd.target      = self;
    cmd.priority    = priority;
    cmd.timeOut     = time;
    cmd.tagData     = tData;
    cmd.timeStamp   = aTimeStamp;
    cmd.onComplete  = onComplete;
    [self addToQueue:cmd];
    int count =0;
    for (NSArray * arrayinQueue in [queue allValues]) {
        count += arrayinQueue.count;
    }
    
    if (count == 1) {
        isWaitiing  = NO;
        [self runNextCommand]; // run command as soon as issued if there is non in the queue
    }
    else if (currentCommand.priority < cmd.priority)
    {
        [encoderConnection cancel];
        isWaitiing = NO;
        [self runNextCommand];
    }



}



/**
 *  this will run the next command in the queue
 */
-(void)runNextCommand{
    //if the queue is not empty, send another request
    if(queue.count>0 && !isWaitiing)
    {
        EncoderTask * nextInQueue = [self getNextInQueue];
        currentCommand = nextInQueue;
        id controller   = nextInQueue.target;
        SEL sel         = nextInQueue.selector;
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [controller performSelector:sel withObject:nextInQueue.tagData withObject:nextInQueue.timeStamp];
        isWaitiing = YES;
        
        

    }
    
}


-(Event*)getEventByName:(NSString*)eventName
{
    NSPredicate *pred = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        
        Event* obj = evaluatedObject;
        return [obj.name isEqualToString:eventName];
    }];
    
    NSMutableArray *dataToBeFiltered = [[NSMutableArray alloc]init];
    for (NSMutableDictionary *eventDic in [_allEvents allValues]) {
        [dataToBeFiltered addObject:[eventDic objectForKey:@"non-local"]];
    }
    
    //NSArray * filtered = [NSArray arrayWithArray:[[[self allEvents] allValues] filteredArrayUsingPredicate:pred ]];
    NSArray * filtered = [NSArray arrayWithArray:[dataToBeFiltered filteredArrayUsingPredicate:pred]];
    
    if ([filtered count]==0)return nil;
    
    return (Event*)filtered[0];
}



// Commands
#pragma mark - Observer


-(void)onTagPost:(NSNotification *)note
{
    NSMutableDictionary * data   = [NSMutableDictionary dictionaryWithDictionary:note.userInfo];
    //BOOL isDuration                 = ([note.userInfo objectForKey:@"duration"])?[[note.userInfo objectForKey:@"duration"] boolValue ]:FALSE;
    //[data removeObjectForKey:@"duration"];
    
    NSString *tagTime = [data objectForKey:@"time"];// just to make sure they are added
    NSString *tagName = [data objectForKey:@"name"];// just to make sure they are added
    NSString *eventNm = (self.event.live)?LIVE_EVENT:self.event.name;
    NSString *period = [data objectForKey:@"period"];
    
    // This is the starndard info that is collected from the encoder
    NSMutableDictionary * tagData = [NSMutableDictionary dictionaryWithDictionary:
                                     @{
                                       @"event"         : eventNm,
                                       @"colour"        : [Utility hexStringFromColor: [UserCenter getInstance].customerColor],
                                       @"user"          : [UserCenter getInstance].userHID,
                                       @"time"          : tagTime,
                                       @"name"          : tagName,
                                       @"deviceid"      : [[[UIDevice currentDevice] identifierForVendor]UUIDString]

                                       }];
    /*if (isDuration){ // Add extra data for duration Tags
        NSDictionary *durationData =        @{
                                              
                                              @"type"     : [NSNumber numberWithInteger:TagTypeOpenDuration]
                                            // ,@"dtagid": @"123456789" // this should be set before
                                              };
        [tagData addEntriesFromDictionary:durationData];
        
    }*/
    
    if (period) {
        [tagData setValue:period forKey:@"period"];
    }
    
    [tagData addEntriesFromDictionary:data];
    
    [self issueCommand:MAKE_TAG priority:1 timeoutInSec:20 tagData:tagData timeStamp:GET_NOW_TIME];
}

-(void)onTelePost:(NSNotification *)note
{
    NSMutableDictionary * data   = [NSMutableDictionary dictionaryWithDictionary:note.userInfo];
    
    NSString *tagTime = [data objectForKey:@"time"];// just to make sure they are added
    NSString *tagDuration = [data objectForKey:@"duration"];// just to make sure they are added
    NSData *teleData = [data objectForKey:@"telestration"];
    NSString *eventNm = (self.event.live)?LIVE_EVENT:self.event.name;
    NSString *period = [data objectForKey:@"period"];

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
    if (period) {
        [tagData setValue:period forKey:@"period"];
    }
    
    [self issueCommand:MAKE_TELE_TAG priority:1 timeoutInSec:20 tagData:tagData timeStamp:GET_NOW_TIME];
    
}

-(void)onModTag:(NSNotification *)note
{
    
    NSMutableDictionary * dict;
    
    if (!note.object && note.userInfo) {
        
        dict = [NSMutableDictionary dictionaryWithDictionary:note.userInfo];
        
         ///@"event"         : (tagToModify.isLive)?LIVE_EVENT:tagToModify.event.name, // LIVE_EVENT == @"live"
        
        
        /*if ([self.event.name isEqualToString:dict[@"event"]]) {
            dict[@"event"] = LIVE_EVENT;
        }*/
        
        if ([self.event.name isEqualToString:dict[@"event"]] && self.event.live) {
            dict[@"event"] = LIVE_EVENT;
        }
    
    } else {
        Tag *tagToModify = note.object;
        dict = [NSMutableDictionary dictionaryWithDictionary:
                @{
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
    tagToDelete.type = TagTypeDeleted;

    
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:
                                     @{
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
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
                                      @"name": eventToDelete.name,
                                      @"hid": eventToDelete.hid
                                       }];
    
    [self issueCommand:DELETE_EVENT priority:10 timeoutInSec:5 tagData:dict timeStamp:GET_NOW_TIME];
}


// recieved a notif that will have a tag a src and a block to get the download Item
-(void)onDownloadClip:(NSNotification *)note
{
    
    Tag *tag                                    = note.userInfo[@"tag"];
    NSString * srcID                            = note.userInfo[@"src"];
//    NSString * key                              = note.userInfo[@"key"];
    __block void(^dItemBlock)(DownloadItem*)    = note.userInfo[@"block"];


    
    NSMutableDictionary * sumRequestData = [NSMutableDictionary dictionaryWithDictionary:
                                            @{
                                              @"id": tag.ID,
                                              @"event": (tag.isLive)?LIVE_EVENT:tag.event,
                                              @"requesttime":GET_NOW_TIME_STRING,
                                              @"bookmark":@"1",
                                              @"user":[UserCenter getInstance].userHID,
                                              @"name":tag.name,
                                              @"srcValue":srcID // used by encoder to locate and cut clip
//                                              ,@"dlkey":key
                                              }];
    
    [sumRequestData addEntriesFromDictionary:@{@"sidx":trimSrc(note.userInfo[@"src"])}];
    
    PXPLog(@"Download Command Queued, waiting for encoder responce....");
    [self issueCommand:MODIFY_TAG priority:1 timeoutInSec:60 tagData:sumRequestData timeStamp:GET_NOW_TIME onComplete:^(NSDictionary *userInfo) {
        DownloadItem* dlitem = userInfo[@"downloadItem"];
        dItemBlock(dlitem);
    }];

    
    
    NSOperation * testOp = [NSBlockOperation blockOperationWithBlock:^{
//        NSLog(@"Done");

    }];
    
    [DownloaderQueue addDownloadItem:testOp key:@"asdfasdf"];
    
    
    NSOperation * testOp1 = [DownloaderQueue getQueueItemByKey:@"asdfasdf"];
    
    
    
//    NSLog(@"%s",__FUNCTION__);

}



/**
 *  This creates tags on the server or local
 *
 *
 *  @param data          this is the custom data that will be added to the tag
 *  @param isDuration    if YES then it will be stored in a open Duration tag dict
 */
//-(void)createTeleTag:(NSMutableDictionary *)data isDuration:(BOOL)isDuration
//{
//    
//    NSString *tagTime = [data objectForKey:@"time"];// just to make sure they are added
//    NSString *tagName = [data objectForKey:@"name"];// just to make sure they are added
//    NSString *eventNm = ([_currentEvent isEqualToString:_liveEventName])?@"live":_currentEvent;
//    
//    // This is the starndard info that is collected from the encoder
//    NSMutableDictionary * tagData = [NSMutableDictionary dictionaryWithDictionary:
//                                     @{
//                                       @"event"         : eventNm,
//                                       @"colour"        : [_dictOfAccountInfo objectForKey:@"tagColour"],
//                                       @"user"          : [_dictOfAccountInfo objectForKey:@"hid"],
//                                       @"time"          : tagTime,
//                                       @"name"          : tagName,
//                                       //                                               @"comment"       : @"",
//                                       //                                               @"rating"        : @"0",
//                                       //                                               @"coachpick"     : @"0",
//                                       //                                               @"bookmark"      : @"0",
//                                       //                                               @"deleted"       : @"0",
//                                       //                                               @"edited"        : @"0",
//                                       @"duration"      : @"1",
//                                       @"type"          : @"4",
//                                       //@"deviceid"      : [[[UIDevice currentDevice] identifierForVendor]UUIDString]
//                                       }];
//    if (isDuration){ // Add extra data for duration Tags
//        NSDictionary *durationData =        @{
//                                              @"starttime"     : tagTime
//                                              };
//        [tagData addEntriesFromDictionary:durationData];
//    }
//    
//    [tagData addEntriesFromDictionary:data];//
//    
//    
//    
//    //    // Check if tag is open for this already, if so close it
//    //    if ([_openDurationTags objectForKey:tagName] != nil)
//    //    {
//    //
//    //        [self closeDurationTag:tagName];
//    //
//    //
//    //    } else {
//    //
//    //        [_openDurationTags setObject:tagData forKey:tagName];
//    //        // issues new tag command
//    //    }
//    
//    
//    // issue command to all encoder with events
//    
//    
//    NSArray     * encoders;
//    
//    if (![_primaryEncoder isKindOfClass:[Encoder class]]&& _primaryEncoder) {
//        encoders    = @[_primaryEncoder];
//    } else {
//        encoders    = [_authenticatedEncoders copy];
//        
//    }
//    
//    
//    
//    NSNumber    * nowTime             = GET_NOW_TIME;
//    NSUInteger timeout = [encoders count] * 20;
//    [encoders enumerateObjectsUsingBlock:^(id <EncoderProtocol> obj, NSUInteger idx, BOOL *stop){
//        [obj issueCommand:MAKE_TELE_TAG priority:1 timeoutInSec:timeout tagData:tagData timeStamp:nowTime];
//    }];
//    
//    
//    
//}



// Commands
#pragma mark - Commands
-(void)authenticateWithCustomerID:(NSString*)custID
{
  //  void * context  =  &context;
    self.customerID = custID;
    [self issueCommand:AUTHENTICATE priority:99 timeoutInSec:15 tagData:nil timeStamp:GET_NOW_TIME];

}


-(void)requestVersion
{
    [self issueCommand:VERSION priority:100 timeoutInSec:15 tagData:nil timeStamp:GET_NOW_TIME];
}



-(void)searchForMaster
{
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(_foundMaster:) name:NOTIF_ENCODER_MASTER_FOUND object:nil];
    /// need to add to status checker
}

-(void)_foundMaster:(NSNotification*)note
{
 //   Encoder * isTheMaster = (Encoder*)note.object;
    
}

/**
 *  This is run when the encoder is authenticated TRUE
 *  it will populate the list of events and collect feeds
 * this places the command in the queue
 */
-(void)buildEncoderRequest
{
    [self issueCommand:CAMERAS_GET      priority:4 timeoutInSec:15 tagData:nil timeStamp:GET_NOW_TIME];
    [self issueCommand:TEAMS_GET        priority:3 timeoutInSec:15 tagData:nil timeStamp:GET_NOW_TIME];
    [self issueCommand:BUILD            priority:2 timeoutInSec:15 tagData:nil timeStamp:GET_NOW_TIME];
    

}


-(void)authenticate:(NSMutableDictionary *)data timeStamp:(NSNumber *)aTimeStamp
{

    
    
    if ([self.version isEqualToString:@"0.94.5"]){

//    if ([Utility sumOfVersion:self.version] <= [Utility sumOfVersion:OLD_VERSION]){
        [self willChangeValueForKey:@"authenticated"];
        if (!_authenticated) [self buildEncoderRequest];
        _authenticated  = YES;
        isAuthenticate = YES;
        [self didChangeValueForKey:@"authenticated"];
        isWaitiing      = NO;
//        self.isMaster = YES;

        [self removeFromQueue:currentCommand];
        [self runNextCommand]; // this line is for testing
        PXPLog(@"Encoder Warning: Version check in Authenticate Disabled");
        return;
    }
    
    
    NSString * json = [Utility dictToJSON:@{@"id":customerID}];
    
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"%@://%@/min/ajax/auth/%@",self.urlProtocol,self.ipAddress,json]  ];
    PXPLogAjax(@"%@://%@/min/ajax/auth/%@",self.urlProtocol,self.ipAddress,@{@"id":customerID});
    urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = AUTHENTICATE;
    encoderConnection.timeStamp             = aTimeStamp;

}


-(void)buildEncoder:(NSMutableDictionary *)data timeStamp:(NSNumber *)aTimeStamp
{
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"%@://%@/min/ajax/getpastevents",self.urlProtocol,self.ipAddress]  ];
    PXPLogAjax(checkURL.absoluteString);
    urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = BUILD;
    encoderConnection.timeStamp             = aTimeStamp;
}

-(void)requestVersion:(NSMutableDictionary *)data timeStamp:(NSNumber *)aTimeStamp
{
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"%@://%@/min/ajax/version",self.urlProtocol,self.ipAddress]  ];
    PXPLogAjax(checkURL.absoluteString);
    urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = VERSION;
    encoderConnection.timeStamp             = aTimeStamp;
}

-(void)shutdown:(NSMutableDictionary *)data timeStamp:(NSNumber *)aTimeStamp
{
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"%@://%@/min/ajax/encshutdown",self.urlProtocol,self.ipAddress]  ];
    PXPLogAjax(checkURL.absoluteString);
    urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = SHUTDOWN;
    encoderConnection.timeStamp             = aTimeStamp;

}

-(void)makeTag:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp
{
    NSString *encodedName = [Utility encodeSpecialCharacters:[tData objectForKey:@"name"]];

    //over write name and add request time
    [tData addEntriesFromDictionary:@{
                                      @"name"           : encodedName,
                                      @"requesttime"    : GET_NOW_TIME_STRING
                                      //,@"colour"         : [Utility hexStringFromColor: [tData objectForKey:@"colour"]]
                                    }];
  
    NSString *jsonString                    = [Utility dictToJSON:tData];
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"%@://%@/min/ajax/tagset/%@",self.urlProtocol,self.ipAddress,jsonString]  ];
    PXPLogAjax(@"%@://%@/min/ajax/tagset/%@",self.urlProtocol,self.ipAddress,tData);
    urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = MAKE_TAG;
    encoderConnection.timeStamp             = aTimeStamp;
}

-(void)makeTeleTag:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp
{
    //UIImage *img = [UIImage imageNamed:@"painting.png"];
    
    // Create a transparent Image to send to server (duct tape to work with legacy code)
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1.0, 1.0), NO, 1.0);
    UIImage *ductTape = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // NSData *imageData = UIImagePNGRepresentation([tData objectForKey:@"image"]) ;
    [tData removeObjectForKey:@"image"];
    
    NSData *imageData = UIImagePNGRepresentation(ductTape);
    
    NSString *encodedName = [Utility encodeSpecialCharacters:[tData objectForKey:@"name"]];
    
    //over write name and add request time
    [tData addEntriesFromDictionary:@{
                                      @"name"           : encodedName,
                                      @"requesttime"    : GET_NOW_TIME_STRING
                                      }];
    

    NSString *jsonString                    = [Utility dictToJSON:tData];
//    jsonString = [jsonString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    jsonString = [jsonString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
     NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"%@://%@/min/ajax/teleset",self.urlProtocol,self.ipAddress]  ];
    PXPLogAjax(checkURL.absoluteString);
    NSMutableURLRequest *someUrlRequest     = [NSMutableURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    [someUrlRequest setHTTPMethod:@"POST"];
    
    NSString *boundary = @"----WebKitFormBoundarycC4YiaUFwM44F6rT";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [someUrlRequest setValue:contentType forHTTPHeaderField:@"Content-Type"];
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=tag\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    //[body appendData:[@"Content-Type: text/plain\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    // Now we need to append the different data 'segments'. We first start by adding the boundary.
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=file; filename=picture.png\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    // We now need to tell the receiver what content type we have
    // In my case it's a png image. If you have a jpg, set it to 'image/jpg'
    [body appendData:[@"Content-Type: image/png\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    // Now we append the actual image data
    //NSData *myData = [NSKeyedArchiver archivedDataWithRootObject:tData];
    //[body appendData:myData];
    [body appendData:[NSData dataWithData:imageData]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // and again the delimiting boundary
    //NSString *tempstr =[[NSString alloc]initWithData:body encoding:NSStringEncodingConversionAllowLossy];
    [someUrlRequest setHTTPBody:body];
    
    urlRequest                              = someUrlRequest;
    encoderConnection                       = [NSURLConnection connectionWithRequest:someUrlRequest delegate:self];
    encoderConnection.connectionType        = MAKE_TELE_TAG;
    encoderConnection.timeStamp             = aTimeStamp;

}


-(void)modifyTag:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp
{
    NSString *encodedName = [Utility encodeSpecialCharacters:[tData objectForKey:@"name"]];
    if (!encodedName) encodedName = @"";
    //over write name and add request time
    [tData addEntriesFromDictionary:@{
                                      @"name"           : encodedName,
                                      @"requestime"    : [NSString stringWithFormat:@"%f",CACurrentMediaTime()]
                                      }];
    
    if ( tData[@"srcValue"] ){ // This is used when downloading a clip
        
        // test
        NSString * src =    [tData[@"srcValue"] stringByReplacingOccurrencesOfString:@"s_" withString:@""];
        
        [tData addEntriesFromDictionary:@{@"srcValue"       : tData[@"srcValue"]}];
        [tData addEntriesFromDictionary:@{@"sidx"           : src}];
    }
    [tData removeObjectForKey:@"url"];
    [tData removeObjectForKey:@"url_2"];
    
    NSString *jsonString                    = [Utility dictToJSON:tData];
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"%@://%@/min/ajax/tagmod/%@",self.urlProtocol,self.ipAddress,jsonString]  ];
    if ( tData[@"srcValue"] ) {
        PXPLog(@"Download clip Request");
        PXPLog(@"%@://%@/min/ajax/tagmod/%@",self.urlProtocol,self.ipAddress,tData);

    }
    urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = MODIFY_TAG;
    encoderConnection.timeStamp             = aTimeStamp;
}

-(void)deleteEvent:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp{
    
   // NSString *jsonString                    = [Utility dictToJSON:tData];
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"%@://%@/min/ajax/evtdelete/?name=%@&event=%@",self.urlProtocol,self.ipAddress,[tData objectForKey:@"name"],[tData objectForKey:@"hid"]]  ];
    PXPLogAjax(@"%@://%@/min/ajax/evtdelete/?name=%@&event=%@",self.urlProtocol,self.ipAddress,[tData objectForKey:@"name"],[tData objectForKey:@"hid"]);
    urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = DELETE_EVENT;
    encoderConnection.timeStamp             = aTimeStamp;

}

-(void)summaryGet:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp
{
    NSMutableDictionary *summarydict = tData;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:summarydict options:0 error:&error];
    NSString *jsonString;
    if (! jsonData) {
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//        jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        jsonString = [jsonString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    }
    
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"%@://%@/min/ajax/sumget/%@",self.urlProtocol,self.ipAddress,jsonString]  ];
    PXPLogAjax(@"%@://%@/min/ajax/sumget/%@",self.urlProtocol,self.ipAddress,tData);
    urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = SUMMARY_GET;
    encoderConnection.timeStamp             = aTimeStamp;
}

-(void)summaryPut:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp
{
    NSMutableDictionary *summarydict = tData;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:summarydict options:0 error:&error];
    NSString *jsonString;
    if (! jsonData) {
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"%@://%@/min/ajax/sumset/%@",self.urlProtocol,self.ipAddress,jsonString]  ];
    PXPLogAjax(@"%@://%@/min/ajax/sumset/%@",self.urlProtocol,self.ipAddress,tData);
    urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = SUMMARY_PUT;
    encoderConnection.timeStamp             = aTimeStamp;
}

-(void)teamsGet:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp
{
 
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"%@://%@/min/ajax/teamsget",self.urlProtocol,self.ipAddress]  ];
    PXPLogAjax(checkURL.absoluteString);
    urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = TEAMS_GET;
    encoderConnection.timeStamp             = aTimeStamp;
}

-(void)camerasGet:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp
{
    
    //    Encoder * enc = (Encoder *)self.currentEvent.parentEncoder;
    EncoderOperation * testOp =  [[EncoderOperationCameraStartTimes alloc]initEncoder:self data:nil];
    [self runOperation:testOp];
    
    
    
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"%@://%@/min/ajax/getcameras",self.urlProtocol,self.ipAddress]  ];
    PXPLogAjax(checkURL.absoluteString);
    urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = CAMERAS_GET;
    encoderConnection.timeStamp             = aTimeStamp;
}


-(void)eventTagsGet:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp
{

    NSString *jsonString                    = [Utility dictToJSON:tData];
    
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"%@://%@/min/ajax/gametags/%@",self.urlProtocol,self.ipAddress,jsonString]  ];
    PXPLogAjax(@"%@://%@/min/ajax/gametags/%@",self.urlProtocol,self.ipAddress,tData);
    urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = EVENT_GET_TAGS;
    encoderConnection.timeStamp             = aTimeStamp;
    encoderConnection.extra                 = @{@"event":[tData objectForKey:@"event"]};// This is the key th   at will be used when making the dict
}


-(void)allEventsGet:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp
{
    
    NSString *jsonString                    = [Utility dictToJSON:tData];
    
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"%@://%@/min/ajax/gametags/%@",self.urlProtocol,self.ipAddress,jsonString]  ];
    PXPLogAjax(@"%@://%@/min/ajax/gametags/%@",self.urlProtocol,self.ipAddress,tData);
    urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = EVENT_GET_TAGS;
    encoderConnection.timeStamp             = aTimeStamp;
    encoderConnection.extra                 = @{@"event":[tData objectForKey:@"event"]};// This is the key that will be used when making the dict
}


-(void)liveEventGet:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp
{
    
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"%@://%@/min/ajax/getpastevents",self.urlProtocol,self.ipAddress]  ];
    PXPLogAjax(checkURL.absoluteString);
    urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = LIVE_EVENT_GET;
    encoderConnection.timeStamp             = aTimeStamp;
}

#pragma mark -  Master Commands
-(void)stopEvent:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp
{
    
    NSMutableDictionary *summarydict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%@",aTimeStamp],@"requesttime", nil];
    
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:summarydict options:0 error:&error];
    NSString *jsonString;
    if (! jsonData) {
        
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//        jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        jsonString = [jsonString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    }
    
    
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"%@://%@/min/ajax/encstop/%@",self.urlProtocol,self.ipAddress,jsonString]  ];
    PXPLogAjax(@"%@://%@/min/ajax/encstop/%@",self.urlProtocol,self.ipAddress,jsonString);
    urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = STOP_EVENT;
    encoderConnection.timeStamp             = aTimeStamp;
    
    
}

-(void)pauseEvent:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp
{
    
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"%@://%@/min/ajax/encpause/",self.urlProtocol,self.ipAddress]  ];
    urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    PXPLogAjax(checkURL.absoluteString);
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = PAUSE_EVENT;
    encoderConnection.timeStamp             = aTimeStamp;
}

-(void)resumeEvent:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp
{
    
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"%@://%@/min/ajax/encresume/",self.urlProtocol,self.ipAddress]  ];
    urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    PXPLogAjax(checkURL.absoluteString);
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = RESUME_EVENT;
    encoderConnection.timeStamp             = aTimeStamp;
}


-(void)startEvent:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp
{
    
    [EncoderManager getInstance].primaryEncoder = [EncoderManager getInstance].masterEncoder;
    
    _pressingStart = true;
    
    NSString * homeTeam = [tData objectForKey:@"homeTeam"];
    NSString * awayTeam = [tData objectForKey:@"awayTeam"];
    NSString * league   = [tData objectForKey:@"league"];
    
    NSString *unencoded = [NSString stringWithFormat:@"%@://%@/min/ajax/encstart/?hmteam=%@&vsteam=%@&league=%@&time=%@&quality=%@",
                           self.urlProtocol,
                           self.ipAddress,
                           homeTeam,
                           awayTeam,
                           league,
                           [NSString stringWithFormat:@"%@",aTimeStamp],
                           @"high"];
    
//    unencoded = [unencoded stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    unencoded = [unencoded stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    
    NSURL * checkURL                        = [NSURL URLWithString:unencoded  ];
    PXPLogAjax(checkURL.absoluteString);
    urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = START_EVENT;
    encoderConnection.timeStamp             = aTimeStamp;
    
    

}




// Connections // Connections// Connections// Connections// Connections// Connections// Connections// Connections// Connections// Connections// Connections// Connections// Connections
// Connections // Connections// Connections// Connections// Connections// Connections// Connections// Connections// Connections// Connections// Connections// Connections// Connections
// Connections // Connections// Connections// Connections// Connections// Connections// Connections// Connections// Connections// Connections// Connections// Connections// Connections
#pragma mark - Connections


-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (connection.cumulatedData == nil){
        connection.cumulatedData = [NSMutableData dataWithData:data];
    } else {
        [connection.cumulatedData appendData:data];
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_ENCODER_CONNECTION_PROGRESS object:self userInfo:nil];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{

    NSString * connectionType   = connection.connectionType;
    NSData * finishedData       = connection.cumulatedData;
    NSDictionary * extra        = connection.extra;

    NSLog(@"JSON response for %@: %@", connectionType, [[NSString alloc] initWithData:finishedData encoding:NSUTF8StringEncoding]);
    
    if ([connectionType isEqualToString: AUTHENTICATE]){
        [self authenticateResponse: finishedData];
    } else if ([connectionType isEqualToString: VERSION]){
        [self versionResponse:  finishedData];
    } else if ([connectionType isEqualToString: BUILD]){
        [self getAllEventsResponse: finishedData];
    } else if ([connectionType isEqualToString: TEAMS_GET]) {
        [self teamsResponse:    finishedData];
    } else if ([connectionType isEqualToString: STOP_EVENT]) {
        [self stopResponce:     finishedData];
    } else if ([connectionType isEqualToString: START_EVENT]) {
        NSError         * error;
        NSDictionary    * results;
        
        results         = [Utility JSONDatatoDict:finishedData];
        results         = [Utility JSONDatatoDict:finishedData error:&error];
        
        if ([results[@"success"]intValue] == 0) {
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_STATUS_LABEL_CHANGED object:self];
            
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Can't Start Event"
                                                                            message:results[@"msg"]
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
            
            [[CustomAlertControllerQueue getInstance] presentViewController:alert inController:ROOT_VIEW_CONTROLLER animated:YES style:AlertImportant completion:nil];
            
        }
        [self startResponce:    finishedData];
    } else if ([connectionType isEqualToString: PAUSE_EVENT]) {
        [self pauseResponce:     finishedData];
    }  else if ([connectionType isEqualToString: RESUME_EVENT]) {
        [self resumeResponce:    finishedData];
    } else if ([connectionType isEqualToString: MAKE_TAG]) {
        //[self makeTagResponce:    finishedData];
        [self getEventTags:finishedData extraData:@{@"type":MAKE_TAG}];
        //[self tagsJustChanged:finishedData extraData:MAKE_TAG];
    } else if ([connectionType isEqualToString: MAKE_TELE_TAG]) {
        //[self makeTagResponce:    finishedData];
        [self getEventTags:finishedData extraData:@{@"type":MAKE_TELE_TAG}];
        //[self tagsJustChanged:finishedData extraData:MAKE_TELE_TAG];
    } else if ([connectionType isEqualToString: MODIFY_TAG]) {
        //[self modTagResponce:    finishedData];
         [self getEventTags:finishedData extraData:@{@"type":MODIFY_TAG}];

    } else if ([connectionType isEqualToString: CAMERAS_GET]) {
        [self camerasGetResponce:    finishedData];
    } else if ([connectionType isEqualToString: EVENT_GET_TAGS]) {
        //NSLog(@"%@",[[NSString alloc] initWithData:finishedData encoding:NSUTF8StringEncoding]);
        
        [self getEventTags:finishedData extraData:@{@"type":EVENT_GET_TAGS,@"event": extra[@"event"]} ];
        //[self eventTagsGetResponce:finishedData extraData:extra];
    } else if ([connectionType isEqualToString: DELETE_EVENT]){
        [self deleteEventResponse: finishedData];
    } else if ([connectionType isEqualToString: LIVE_EVENT_GET]){
        [self searchForLiveEventResponse: finishedData];
    }

    
    
    
    if (isAuthenticate && 1 && _isBuild && isTeamsGet && !_isReady){
        _isReady         = YES;
        if (!statusMonitor) {
            statusMonitor   = [[EncoderStatusMonitor alloc]initWithDelegate:self];
            statusMonitor.urlProtocol = self.urlProtocol;
            __weak id <EncoderProtocol> weakSelf = self;
            [statusMonitor setOnMotion:^(EncoderStatusMonitor *m, NSDictionary *data) {
                NSArray * alarmedFeeds = [data objectForKey:@"alarms"];
                NSArray * feedsChecked = (weakSelf.event.feeds)?[weakSelf.event.feeds allKeys]:@[];
                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MOTION_ALARM object:weakSelf userInfo:@{
                                                                                                                    @"feeds"    : feedsChecked,
                                                                                                                    @"alarms"   : alarmedFeeds
                                                                                                                    }];
    
            }];
            
            
        }

        

        
        
        
        [[EncoderManager getInstance] onRegisterEncoderCompleted:self];
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_ENCODER_CONNECTION_FINISH object:self userInfo:@{@"responce":finishedData}];
    
    
    PXPLog(@"%@ Connection finished: %@",self.name,trim(connectionType));
    if ([connectionType isEqualToString:SHUTDOWN]){
        __weak Encoder * weakSelf = self;
        [statusMonitor startShutdownChecker:^(void){
            PXPLog(@"%@ has shutdown!",weakSelf.name);
            if (weakSelf.isMaster) [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_ENCODER_MASTER_HAS_FALLEN object:weakSelf userInfo:nil];
         }];
    }
    isWaitiing  = NO;
    isSuccess   = YES;
    isFinished  = YES;
    if (self.delegate) {
        [self.delegate onSuccess:self];
    }
    if (currentCommand.onComplete && [connectionType isEqualToString: MODIFY_TAG]){
        [self tagPrepared:currentCommand responceData:finishedData];
    }
        

    [self removeFromQueue:currentCommand];
    [self runNextCommand];
}


-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
    NSString * failType = [error.userInfo objectForKey:@"NSLocalizedDescription"];
    isWaitiing = NO;

    PXPLog(@"%@ Error!",self.name);
    PXPLog(@"  connection type: %@ ",trim(connection.connectionType));
    PXPLog(@"  url: %@ ",[[connection originalRequest]URL]);
    PXPLog(@"  reason: %@ ",failType);
    if ([connection.connectionType isEqualToString: AUTHENTICATE] || [connection.connectionType isEqualToString: VERSION]){
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_EM_CONNECTION_ERROR object:self userInfo:@{@"error":@"fail"}];//
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_ENCODER_CONNECTION_FINISH object:self userInfo:nil];//
    isSuccess   = NO;
    isFinished  = YES;
    if (self.delegate) {
        [self.delegate onFail:self];
    }
    [self removeFromQueue:currentCommand];
    [self runNextCommand];
}


#pragma mark - Responce Methods

/**
 *  This method checks to see if the user has access to this encoder
 *  once complete it will set to authenticated
 *  @param data reponce from server
 */
-(void)authenticateResponse:(NSData *)data
{
    
     NSDictionary    * results =    [Utility JSONDatatoDict:data];
    
    if (results[@"config"]){
        NSDictionary * config = results[@"config"];
        [UserCenter getInstance].preRoll    = [config[@"preroll"] doubleValue];
        [UserCenter getInstance].postRoll   = [config[@"postroll"] doubleValue];
    }
    
    
    if (!IS_AUTHENTICATING){
        [self willChangeValueForKey:@"authenticated"];
        _authenticated = YES;
        PXPLog(@"Warning: define no authenticating");
        [self didChangeValueForKey:@"authenticated"];
        if (!isAuthenticate) [self buildEncoderRequest];
        isAuthenticate = YES;
        return;
    }
    
    

    if(NSClassFromString(@"NSJSONSerialization"))
    {
        NSError *error = nil;
        id object = [NSJSONSerialization
                     JSONObjectWithData:data
                     options:0
                     error:&error];
        
        if(error) {
            /* JSON was malformed, act appropriately here */
            [self willChangeValueForKey:@"authenticated"];
            _authenticated = YES;
            PXPLog(@"Warning: JSON was malformed");
            PXPLog(@"Default: User Authenticated");
            [self didChangeValueForKey:@"authenticated"];
        }
        
        // the originating poster wants to deal with dictionaries;
        // assuming you do too then something like this is the first
        // validation step:
        if([object isKindOfClass:[NSDictionary class]])
        {
            results = object;
            [self willChangeValueForKey:@"authenticated"];
            _authenticated = [[results objectForKey:@"success"] boolValue];
            [self didChangeValueForKey:@"authenticated"];
            /* proceed with results as you like; the assignment to
             an explicit NSDictionary * is artificial step to get
             compile-time checking from here on down (and better autocompletion
             when editing). You could have just made object an NSDictionary *
             in the first place but stylistically you might prefer to keep
             the question of type open until it's confirmed */
            
            if (!_authenticated){
                PXPLog(@"");
                PXPLog(LOG_HASH);
                PXPLog(@"Warning: User Failed to authenticate to Encoder %@",self.name);
                PXPLog(@"  ID:     @%",[UserCenter getInstance].customerID);
                PXPLog(@"  E-mail: @%",[UserCenter getInstance].customerEmail);
                PXPLog(LOG_HASH);
                PXPLog(@"");                
            }
        }
        else
        {
            [self willChangeValueForKey:@"authenticated"];
            _authenticated = YES;
            [self didChangeValueForKey:@"authenticated"];
            /* there's no guarantee that the outermost object in a JSON
             packet will be a dictionary; if we get here then it wasn't,
             so 'object' shouldn't be treated as an NSDictionary; probably
             you need to report a suitable error condition */
        }
    }
    else
    {
        // the user is using iOS 4; we'll need to use a third-party solution.
        // If you don't intend to support iOS 4 then get rid of this entire
        // conditional and just jump straight to
        // NSError *error = nil;
        // [NSJSONSerialization JSONObjectWithData:...
    }

    // Check the data or website and see if it is successful if so
    //    authenticated = YES else NO
    // Should there be a notif for when its complete
    if (!isAuthenticate) [self buildEncoderRequest];
    isAuthenticate = YES;
}

/**
 *  This gets the version of the linked Encoder
 *
 *  @param data responce json from encoder
 */
-(void)versionResponse:(NSData *)data
{
    NSError * error;
    NSDictionary    * results;
//    results = [Utility JSONDatatoDict:data];
    results = [Utility JSONDatatoDict:data error:&error];
    
    if([results isKindOfClass:[NSDictionary class]]){
        version = (NSString *)[results objectForKey:@"version"] ;
        PXPLog(@"    version - %@",version);
        PXPLog(@"**************************");
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_VERSION_SET
                                                        object:self
                                                      userInfo:nil];

}


// this build the Leagus, teams and players on this encoder
-(void)teamsResponse:(NSData *)data
{
    NSDictionary    * results =[Utility JSONDatatoDict:data];
    if(![results isKindOfClass:[NSDictionary class]])
    {
            isTeamsGet = YES;
        return;
    }
    if ([results objectForKey:@"success"] && ![[results objectForKey:@"success"]boolValue]) {
        PXPLog(@"Encoder Error!");
        PXPLog(@"  reason: %@",results[@"msg"]);
    }
    
//    NSLog(@" ");
//    NSLog(@"Building Leagues ===============================");
    // building leagues
    NSMutableDictionary * leaguePool        = [[NSMutableDictionary alloc]init]; // this is the final
    NSMutableDictionary * leagueTempHIDPool = [[NSMutableDictionary alloc]init];
    NSArray * rawleagues = [[results objectForKey:@"leagues"]allValues];

    for (NSDictionary * lData in rawleagues) {
        League * aLeague    = [[League alloc]init];
        aLeague.hid         = lData[@"hid"];
        aLeague.name        = lData[@"name"];
        aLeague.shortName   = lData[@"short"];
        aLeague.sport       = lData[@"sport"];
        
        
        if ([leaguePool objectForKey:aLeague.name]){
            
            aLeague.name = [NSString stringWithFormat:@"%@ (Duplicate)",aLeague.name];
        }
        [leaguePool setObject:aLeague forKey:aLeague.name];

        [leagueTempHIDPool setObject:aLeague forKey:aLeague.hid];
    }
    
//    NSLog(@"Leagues =============================== %lu = %lu ",(unsigned long)[leaguePool count] , (unsigned long)[leagueTempHIDPool count]);
//    NSLog(@" ");
//    NSLog(@"Building Teams ===============================");
//    // Build Teams
    NSMutableDictionary * teamTempHIDPool = [[NSMutableDictionary alloc]init];
    NSArray             * rawTeams          = [[results objectForKey:@"teams"]allValues];

    for (NSDictionary * tData in rawTeams) {
        LeagueTeam  * lTeam = [[LeagueTeam alloc]init];
        NSString    * lHID  = tData[@"league"];
        lTeam.extra         = tData[@"extra"]?:@"";
        lTeam.hid           = tData[@"hid"];
        lTeam.name          = tData[@"name"];
        lTeam.sport         = tData[@"sport"];
        lTeam.txt_name      = tData[@"txt_name"];
    
        if ([lTeam.name isEqualToString: @"Bayonne"]){
        
        }
        League * owningLeague = (League *)[leagueTempHIDPool objectForKey:lHID];
        if (!owningLeague) {
            owningLeague = [[League alloc]init];
            owningLeague.name  = @"Teams Has No League...";
            owningLeague.hid   = lHID;
            owningLeague.sport = lTeam.sport;
            
//            [leagueTempHIDPool setObject:owningLeague forKey:lHID];
//            [leaguePool setObject:owningLeague forKey:owningLeague.name];
//            NSLog(@"Team has no League, making a League: %@",lTeam.name);
//              NSLog(@"Team has no League: %@",lTeam.name);
        }
        
        
        [owningLeague addTeam:lTeam];
        [teamTempHIDPool setObject:lTeam forKey:lTeam.hid];
    }
    
//    NSLog(@"Teams =============================== %lu = %lu ",(unsigned long)[rawTeams count] , (unsigned long)[teamTempHIDPool count]);
//    NSLog(@" ");
//    NSLog(@"Building Players ===============================");
    // build players
    
    NSArray             * rawTeamSetup          = [[results objectForKey:@"teamsetup"]allValues];
    NSInteger playerCount = 0;
    for (NSArray * pList in rawTeamSetup) {
        
        // each item in the Array should all be the same team
        NSString    * tHID      = pList[0][@"team"];
        LeagueTeam * owningTeam = (LeagueTeam *)[teamTempHIDPool objectForKey:tHID];
        
        
        
        for (NSDictionary * pData in pList) {
            playerCount++;
            TeamPlayer * aPlayer    = [[TeamPlayer alloc]init];
            aPlayer.jersey          = [pData[@"jersey"]stringValue];
            aPlayer.line = [pData objectForKey:@"line"];
            aPlayer.line            = pData[@"line"];
            aPlayer.player          = pData[@"player"];
            aPlayer.position        = pData[@"position"];
            aPlayer.role            = pData[@"role"];
            
            tHID      = pData[@"team"];
            if ([tHID isEqualToString: @"2a5ac580e608daa6d2cd4b6c20326e1518baadd5"]){
                
            }
            owningTeam = (LeagueTeam *)[teamTempHIDPool objectForKey:tHID];
            if (!owningTeam)  {

                owningTeam =  [[LeagueTeam alloc]init];
                owningTeam.name = @"NO NAME BRAND";
                owningTeam.hid  = tHID;
                owningTeam.extra         = @"";
                owningTeam.sport         = @"Reading";
                owningTeam.txt_name      = @"NO_NAME_BRAND";
                
//                [teamTempHIDPool setObject:owningTeam forKey:tHID];
//                NSLog(@"Player does not have a team, Making a new one");
//                 NSLog(@"Player does not have a team %@",tHID);
            }
            [owningTeam addPlayer:aPlayer];
            
           
        }
//           NSLog(@"%@ \tTeams have %lu players",owningTeam.name,(unsigned long)[owningTeam.players count]);
    }
//    NSLog(@"players =============================== %lu",(long)playerCount);
    
    self.encoderLeagues = [leaguePool copy];
    

    isTeamsGet = YES;
}

//-(void)checkTag:(NSData *)data
//{
//    
//}

//when tags are created or modified on the same ipad that is displaying the change
-(void)getEventTags:(NSData *)data extraData:(NSDictionary *)extra
{
    NSString * type = extra[@"type"];
    
    NSMutableDictionary *checkEventDic = ([type isEqualToString:EVENT_GET_TAGS])?[_allEvents objectForKey:extra[@"event"]]:nil ;
    Event * checkEvent = checkEventDic[@"non-local"];
    
    NSDictionary    * results =[Utility JSONDatatoDict:data];
    if([results isKindOfClass:[NSDictionary class]])    {
        if ([type isEqualToString:MODIFY_TAG]) {
            if (results){
                
                PXPLog(@"Download MODIFY_TAG Responce");
                PXPLog(@"%@",results);

                
                [self onModifyTags:results];
            }
        }
        else if ([type isEqualToString:MAKE_TAG])
        {
            if (results && [results objectForKey:@"telestration"]){
                [self onTeleTags:results];
            }else if (results){
                [self onNewTags:results];
            }
        } else if ([type isEqualToString:EVENT_GET_TAGS]){
            NSDictionary    * rawTags = [results objectForKey:@"tags"];
            if (rawTags) {
                //NSArray *rawTagsArray = [rawTags allValues];
                //NSDictionary *firstTag = [rawTagsArray firstObject];
                //checkEvent = [self.allEvents objectForKey:firstTag[@"event"]];
                [checkEvent addAllTags:rawTags];
                
                NSLog(@"oncomp: %@", (checkEvent.onComplete)?@"yes":@"no");
            }
            checkEvent.isBuilt = YES;


        }else if([type isEqualToString:MAKE_TELE_TAG]){
            if (results) {
                [self onTeleTags:results];
            }
            
        }
        
        
    }
    

}
                        

-(void)onModifyTags:(NSDictionary *)data
{
    if ([data objectForKey:@"id"]) {
        
        if ([_allEvents objectForKey:[data objectForKey:@"event"]]){
            NSMutableDictionary *checkEventDic = [_allEvents objectForKey:[data objectForKey:@"event"]];
            Event * checkEvent = [checkEventDic objectForKey:@"non-local"];
            Event * localEvent = [checkEventDic objectForKey:@"local"];
            
            [checkEvent modifyTag:data];
            
            if (localEvent) {
                if ([data[@"type"] integerValue] == TagTypeCloseDuration) {
                    
                    bool alreadyExist = false;
                    for (Tag *tag in localEvent.tags) {
                        if ([tag.ID isEqualToString:[data[@"id"] stringValue]]) {
                            [tag replaceDataWithDictionary:data];
                            alreadyExist = true;
                        }
                    }
                    if (!alreadyExist) {
                        Tag *localTag = [[Tag alloc] initWithData:data event:localEvent];
                        [localEvent addTag:localTag extraData:false];
                    }else{
                        [localEvent modifyTag:data];
                    }
                }else{
                    [localEvent modifyTag:data];
                }
                [localEvent.parentEncoder writeToPlist];
            }
        }
            

    }
    
    
    NSString * tagID = [[data objectForKey:@"id"]stringValue];
    NSPredicate * autoDownloadPredicate =  [NSPredicate predicateWithFormat:@"type = %ld",TagTypeCloseDuration];
    Tag * newTag = [[self.event getTagsByID:tagID] firstObject];
    
    
    BOOL checkClips = YES;
    for (NSString*k  in [newTag.thumbnails allKeys]) {
        if ([[LocalMediaManager getInstance]getClipByTag:newTag scrKey:k]){
            checkClips = NO;
        }
    }
    
    
    
    if (newTag != nil && checkClips &&[[UserCenter getInstance].tagsFlaggedForAutoDownload containsObject:newTag.name] && [autoDownloadPredicate evaluateWithObject:newTag]) {

        DownloadClipFromTag * downloadClip = [[DownloadClipFromTag alloc]initWithTag:newTag encoder:self sources:[newTag.thumbnails allKeys]];
        
        
        [downloadClip setOnCutComplete:^(NSData *data, NSError *error) {
        
            
        }];
        
        
        [downloadClip setCompletionBlock:^{
//            NSLog(@"%s",__FUNCTION__);
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_AUTO_DOWNLOAD_COMPLETE object:nil];
                
            });
            
        }];
        
        [downloadClip setOnFail:^(NSError *e) {
            NSString * errorTitle = [NSString stringWithFormat:@"Error downloading tag %@",newTag.name];
            NSString * errorMessage = [NSString stringWithFormat:@"%@\n%@",e.localizedFailureReason,e.localizedRecoverySuggestion];
            
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:errorTitle
                                                                            message:errorMessage
                                                                     preferredStyle:UIAlertControllerStyleAlert];
            // build NO button
            UIAlertAction* cancelButtons = [UIAlertAction
                                            actionWithTitle:@"OK"
                                            style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action)
                                            {
                                                [[CustomAlertControllerQueue getInstance] dismissViewController:alert animated:YES completion:nil];
                                            }];
            [alert addAction:cancelButtons];
            
            [[CustomAlertControllerQueue getInstance] presentViewController:alert inController:ROOT_VIEW_CONTROLLER animated:YES style:AlertImportant completion:nil];
            
        }];
        
        [self.operationQueue addOperation:downloadClip];
        
        
        
    } else {
//        NSLog(@"%s",__FUNCTION__);
    }

}


// Depricated
-(void)onNewTags:(NSDictionary*)data
{
    if ([data objectForKey:@"success"] != nil && [[data objectForKey:@"success"]integerValue] != 1){
        PXPLog(@"Encoder Error! on New Tag - msg: %@",[data objectForKey:@"msg"]);
        return;
    }
    
    // check if tag data has ID and check if the event exists
    if ([data objectForKey:@"id"] && [_allEvents objectForKey:[data objectForKey:@"event"]]) {
        
    
            NSMutableDictionary *checkEventDic = [_allEvents objectForKey:[data objectForKey:@"event"]];
            Event * encoderEvent = [checkEventDic objectForKey:@"non-local"];
            Event * localEvent = [checkEventDic objectForKey:@"local"];
            Tag *newTag = [[Tag alloc] initWithData: data event:encoderEvent];

            if (newTag.type == TagTypeGameStart ) {
                encoderEvent.gameStartTag = newTag;
            }
        // role and perission check
          if (newTag.role){
                if (newTag.type == TagTypeNormal || newTag.type == TagTypeCloseDuration || newTag.type == TagTypeTele || newTag.type == TagTypeOpenDuration) {
                  
                        if (![[UserCenter getInstance].rolePermissions containsObject:[NSNumber numberWithInteger:newTag.role]]) {
                            return;
                        }
                   
                }
                
                
                if (newTag.userTeam && newTag.role){
                    if (![newTag.userTeam isEqualToString:[UserCenter getInstance].taggingTeam.name]) return;
                    
                }
         }
        
        
            // AutoDownload check
        
        NSPredicate * autoDownloadPredicate =  [NSPredicate predicateWithFormat:@"type != %ld",TagTypeOpenDuration];
        
        
            if ([[UserCenter getInstance].tagsFlaggedForAutoDownload containsObject:newTag.name] && [autoDownloadPredicate evaluateWithObject:newTag]) {
//                    for (NSString *key in [newTag.thumbnails allKeys]) {
//                        NSString * placeHolderKey = [NSString stringWithFormat:@"%@-%@hq",newTag.ID,key ];
//                        [[Downloader defaultDownloader].keyedDownloadItems setObject:@"placeHolder" forKey:placeHolderKey];
//                        
//                        NSString *src = [NSString stringWithFormat:@"%@hq", key];
//                        
//                        // this takes the download item and attaches it to the cell
//                        void(^blockName)(DownloadItem * downloadItem ) = ^(DownloadItem *downloadItem){
//                            NSLog(@"%s",__FUNCTION__);
//
//                        };
//
//                        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_EM_DOWNLOAD_CLIP object:nil userInfo:@{
//                                                                                                                            @"block": blockName,
//                                                                                                                               @"tag": newTag,
//                                                                                                                               @"src":src,
//                                                                                                                               @"key":key}];
//                        
//                    }
                
                DownloadClipFromTag * downloadClip = [[DownloadClipFromTag alloc]initWithTag:newTag encoder:self sources:[newTag.thumbnails allKeys]];
                
                
                [downloadClip setOnCutComplete:^(NSData *data, NSError *error) {
                  
                   
                }];
                
                
                [downloadClip setCompletionBlock:^{
//                    NSLog(@"%s",__FUNCTION__);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_AUTO_DOWNLOAD_COMPLETE object:nil];    
                        
                    });
                    
                }];
                
                [downloadClip setOnFail:^(NSError *e) {
                    NSString * errorTitle = [NSString stringWithFormat:@"Error downloading tag %@",newTag.name];
                    NSString * errorMessage = [NSString stringWithFormat:@"%@\n%@",e.localizedFailureReason,e.localizedRecoverySuggestion];
                    
                    UIAlertController * alert = [UIAlertController alertControllerWithTitle:errorTitle
                                                                                    message:errorMessage
                                                                             preferredStyle:UIAlertControllerStyleAlert];
                    // build NO button
                    UIAlertAction* cancelButtons = [UIAlertAction
                                                    actionWithTitle:@"OK"
                                                    style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction * action)
                                                    {
                                                        [[CustomAlertControllerQueue getInstance] dismissViewController:alert animated:YES completion:nil];
                                                    }];
                    [alert addAction:cancelButtons];
                    
                    [[CustomAlertControllerQueue getInstance] presentViewController:alert inController:ROOT_VIEW_CONTROLLER animated:YES style:AlertImportant completion:nil];
    
                }];
                
                 [self.operationQueue addOperation:downloadClip];
                
                
                
            } else {
//                    NSLog(@"%s",__FUNCTION__);
            }

        
        
        
            // if new is not in
            if ( ![self.postedTagIDs containsObject:newTag.ID] ){
                [self.postedTagIDs addObject:newTag.ID];
                if (self.event == encoderEvent) {
                    
                    // check if tag is in the event
                    
                    
                    NSArray * tags = [encoderEvent.tags copy];
                    TagProxy * proxyTag;
                    
                    
                    for ( id <TagProtocol> aTag in tags) {
                        if ( [aTag conformsToProtocol:@protocol(TagProtocol)] && [aTag isKindOfClass:[TagProxy class]] ) {
                            // check if aTag matches the data from the dict
//                            proxyTag = (TagProxy *) aTag;
                            if ([[aTag name] isEqualToString:newTag.name] && [aTag time] == newTag.time) {
                                proxyTag         = (TagProxy *)aTag;
                                if (proxyTag.modified) {
                                    PXPLog(@"Tag was Modded before server responded");
                                }
                                break;
                            }
                        }
                    }
                    
                    
                    
                    if (proxyTag != nil && ![proxyTag hasTag]) {
                    
                        // get proxy and add tag to it
                        [proxyTag addTagToProxy:newTag];
                    
                    } else if (proxyTag == nil && [newTag own])  { //this is not your tag add it
                        [encoderEvent addTag:newTag extraData:true];
                    } else if (![newTag own]){
                        [encoderEvent addTag:newTag extraData:true]; // WAS FALSE
                    }
                    
                    
                    
                    
                    
                    
                }else{
                    [encoderEvent addTag:newTag extraData:false];
                }
            } else {
                [self.postedTagIDs removeObject:newTag.ID];
            }
            
            if (localEvent && newTag.type != TagTypeOpenDuration) {
                Tag *localTag = [[Tag alloc] initWithData:data event:localEvent];
                [localEvent addTag:localTag extraData:false];
                [localEvent.parentEncoder writeToPlist];
            }
            
        
            // Download Thumbnail for new tags

            [[ImageAssetManager getInstance]thumbnailsPreload:[newTag.thumbnails allValues]];
    }
}

// new for Encoder Operation
-(Tag*)onNewTagsEO:(NSDictionary*)data
{
    if ([data objectForKey:@"success"] != nil && [[data objectForKey:@"success"]integerValue] != 1){
        PXPLog(@"Encoder Error! on New Tag - msg: %@",[data objectForKey:@"msg"]);
        return nil;
    }
    
    
    
    if ([data objectForKey:@"id"]) {
        
        if ([_allEvents objectForKey:[data objectForKey:@"event"]]){
            NSMutableDictionary *checkEventDic = [_allEvents objectForKey:[data objectForKey:@"event"]];
            Event * encoderEvent = [checkEventDic objectForKey:@"non-local"];
            Event * localEvent = [checkEventDic objectForKey:@"local"];
            Tag *newTag = [[Tag alloc] initWithData: data event:encoderEvent];
            
            
            if (newTag.type == TagTypeGameStart ) {
                encoderEvent.gameStartTag = newTag;
            }
            
            if (self.event == encoderEvent) {
                [encoderEvent addTag:newTag extraData:true];
            }else{
                [encoderEvent addTag:newTag extraData:false];
            }
            
            if (localEvent && newTag.type != TagTypeOpenDuration) {
                Tag *localTag = [[Tag alloc] initWithData:data event:localEvent];
                [localEvent addTag:localTag extraData:false];
                [localEvent.parentEncoder writeToPlist];
            }
            
            
            // Download Thumbnail for new tags
            
            [[ImageAssetManager getInstance]thumbnailsPreload:[newTag.thumbnails allValues]];
            
            
            
            return newTag;
        }
    }
    
    
    return nil;
}


-(void)onTeleTags:(NSDictionary*)data
{
    NSMutableDictionary *tData = [[NSMutableDictionary alloc]initWithDictionary:data];
    [tData removeObjectForKey:@"telefull"];
    [tData removeObjectForKey:@"teleurl"];
    //[tData setObject:[tData objectForKey:@"time"] forKey:@"starttime"];
    //[tData removeObjectForKey:@"url"];
    
    if ([tData objectForKey:@"id"]) {
        if ([_allEvents objectForKey:[tData objectForKey:@"event"]]){
            NSMutableDictionary *checkEventDic = [_allEvents objectForKey:[tData objectForKey:@"event"]];
            Event * encoderEvent = [checkEventDic objectForKey:@"non-local"];
            Event * localEvent = [checkEventDic objectForKey:@"local"];
            
            Tag *newTag = [[Tag alloc] initWithData: tData event:encoderEvent];
            
            
         
            
            
            if (newTag.userTeam && newTag.role){
                if (![newTag.userTeam isEqualToString:[UserCenter getInstance].taggingTeam.name]) return;
                
            }
            
            
            if ([tData objectForKey:@"telestration"]) {
                newTag.telestration = [PxpTelestration telestrationFromData:[tData objectForKey:@"telestration"]];
            }
        
            
            if ( ![self.postedTagIDs containsObject:newTag.ID] ){
                [self.postedTagIDs addObject:newTag.ID];
                if (self.event == encoderEvent) {
                    [encoderEvent addTag:newTag extraData:true];
                }else{
                    [encoderEvent addTag:newTag extraData:false];
                }
            } else {
                [self.postedTagIDs removeObject:newTag.ID];
            }

            

            
            if (localEvent && newTag.type != TagTypeOpenDuration) {
                Tag *localTag = [[Tag alloc] initWithData:tData event:localEvent];
                [localEvent addTag:localTag extraData:false];
                [localEvent.parentEncoder writeToPlist];
            }
        }
    }
    
    if ([tData objectForKey:@"success"] != nil && [[tData objectForKey:@"success"]integerValue] == 0) {

        PXPLog(@"!Encoder Issue:");
        PXPLog(@"   msg:    %@",tData[@"msg"]);
        PXPLog(@"   requrl: %@",tData[@"requrl"]);
    }
    
    
}


// This method is getting run from the Encoder Status monitor
-(void)onTagsChange:(NSData *)data
{
    NSDictionary    * results =[Utility JSONDatatoDict:data];

    
    if ([results isKindOfClass:[NSArray class]])return; // this gets hit when event is shutdown and a sync was in progress
    if([results isKindOfClass:[NSDictionary class]]){
        if ( [results objectForKey: @"tags"]) {
            NSArray * allTags = [[results objectForKey: @"tags"] allValues];
            for (NSDictionary *tag in allTags) {
//                if (![tag[@"deviceid"] isEqualToString:[[[UIDevice currentDevice] identifierForVendor]UUIDString]] || [tag[@"type"]intValue] == TagTypeHockeyStrengthStop || [tag[@"type"]intValue] == TagTypeHockeyStopOLine || [tag[@"type"]intValue] == TagTypeHockeyStopDLine ||  [tag[@"type"]intValue] == TagTypeSoccerZoneStop) {
//                if (   [tag[@"type"]intValue]  == TagTypeHockeyStrengthStop
//                    || [tag[@"type"]intValue]  == TagTypeHockeyStopOLine
//                    || [tag[@"type"]intValue]  == TagTypeHockeyStopDLine
//                    || [tag[@"type"]intValue]  == TagTypeSoccerZoneStop
//                    || [tag[@"type"]intValue]  == TagTypeTele
//                    || [tag[@"type"]intValue]  == TagTypeNormal
//                    || [tag[@"type"]intValue]  == TagTypeCloseDuration
//                    || [tag[@"type"]intValue]  == TagTypeOpenDuration
//                    || [tag[@"type"]intValue]  == TagTypeGameStart
//                    ) {
                
                    
                    NSString * vv = [[tag objectForKey:@"id"] stringValue];
                    NSPredicate * modCheck =  [NSPredicate predicateWithFormat:@"type = %ld OR type = %ld OR type = %ld OR type = %ld OR type = %ld OR type = %ld OR type = %ld OR type = %ld OR type = %ld",(long)TagTypeFootballQuarterStop ,(long)TagTypeFootballDownStop ,(long)TagTypeSoccerZoneStop ,(long)TagTypeSoccerHalfStop ,(long)TagTypeHockeyStopOLine ,(long)TagTypeHockeyStopDLine ,(long)TagTypeHockeyOppOLineStop ,(long)TagTypeHockeyStrengthStop ,(long)TagTypeCloseDuration];
               
                
                    NSArray* tagsByID = [self.event getTagsByID:vv];
                    
                    if ([tag[@"type"]intValue] == TagTypeDeleted) {
                        [self onModifyTags:tag];
                        
                    }else if([tag[@"type"]intValue] == TagTypeCloseDuration){
                        [self onModifyTags:tag];
                    }else if([tagsByID count]==0 && [tag[@"modified"]boolValue]){
                        [self onNewTags:tag];
                    }else if([tag[@"modified"]boolValue]){
                        [self onModifyTags:tag];
                    }else if([modCheck evaluateWithObject:tag]){
                        [self onModifyTags:tag];
                        

                    }else if([tag[@"type"]intValue] == TagTypeHockeyStrengthStop){
                        [self onModifyTags:tag];
                    }else if ([tag[@"type"]intValue] == TagTypeTele){
                        [self onTeleTags:tag]; // its showing double
                    }else {
                        [self onNewTags:tag];
                    }

//                }
                
                
            }
        }
    }
}


-(void)onBitrate:(NSDate *)startTime
{
    self.bitrate = (double)[[NSDate date] timeIntervalSinceDate:startTime];
}



-(BOOL)checkEncoderVersion
{
    BOOL olderVersion = ([self.version isEqualToString:@"0.94.5"])?YES:NO;
    return olderVersion;
}

// this is for the older encoder versions
-(void)assignMaster:(NSDictionary *)data extraData:(BOOL)olderVersion
{
    if ([self.version compare:OLD_VERSION options:NSNumericSearch]){
        BOOL checkIfNobel = [[data objectForKey:@"master"]boolValue];
        
        if (olderVersion){
            checkIfNobel = YES;
        }
        
        self.isMaster = checkIfNobel;
    }

}


-(void)encoderStatusChange:(EncoderStatus)status
{
    if (self.status != status) {
        // encoder status changed
        // old encoder status is not live or live event name was set or new encoder status is ready
        
        if (self.status == ENCODER_STATUS_LIVE && status == ENCODER_STATUS_READY) {
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_LIVE_EVENT_STOPPED object:self];
        }
        
        self.status           = status; /// maybe make this mod directly
        if (self.status == ENCODER_STATUS_LIVE && self.liveEvent == nil) {
//            self.isBuild = false; // This is so the encoder manager rebuilds it once
            [self issueCommand:LIVE_EVENT_GET priority:1 timeoutInSec:15 tagData:nil timeStamp:GET_NOW_TIME];
        } else if (self.status == ENCODER_STATUS_STOP ||self.status == ENCODER_STATUS_READY) {
            if (self.liveEvent == self.event) {
                //[self stopResponce:nil];
                //self.liveEvent = nil;
                
                if (self.status == ENCODER_STATUS_STOP) [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_LIVE_EVENT_STOPPED object:self];
                [[EncoderManager getInstance] declareCurrentEvent:nil];


            };
            [self.allEvents removeObjectForKey:LIVE_EVENT];
            if (self.liveEvent) [self.allEvents removeObjectForKey:self.liveEvent.name];
            self.liveEvent = nil;
            [EncoderManager getInstance].liveEvent = nil;
            [EncoderManager getInstance].liveEventName = nil;


            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_EVENT_CHANGE object:self userInfo:@{@"eventType":@""}];

        } else if (self.status == ENCODER_STATUS_PAUSED) {
            
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Encoder"
                                                                            message:@"Event has been paused"
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
            
            [[CustomAlertControllerQueue getInstance] presentViewController:alert inController:ROOT_VIEW_CONTROLLER animated:YES style:AlertImportant completion:nil];
        }
        
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_ENCODER_STAT object:self];
    }

}

-(void)encoderStatusStringChange:(NSDictionary *)data
{
     self.statusAsString   = ([data objectForKey:@"status"])?[data objectForKey:@"status"]:@"";
}

-(void)onEncoderMasterFallen:(NSError *)error
{
    if (self.status == ENCODER_STATUS_UNKNOWN) return;
    self.status = ENCODER_STATUS_UNKNOWN;
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_ENCODER_MASTER_HAS_FALLEN object:self userInfo:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_ENCODER_STAT object:self];    
    NSString * failType = [error.userInfo objectForKey:@"NSLocalizedDescription"];
    PXPLog(@"EncoderStatus Error!!! ENCODER_STATUS_UNKNOWN : %@",failType);

}




#pragma mark  - EncoderStatusMonitorMotionDelegate Method
-(void)onMotionAlarm:(NSDictionary *)data
{
    
        NSArray * alarmedFeeds = [data objectForKey:@"alarms"];
        NSArray * feedsChecked = (self.event.feeds)?[self.event.feeds allKeys]:@[];
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MOTION_ALARM object:self userInfo:@{
                                                                                                                @"feeds"    : feedsChecked,
                                                                                                                @"alarms"   : alarmedFeeds
                                                                                                            }];
    
}


-(void)deleteEventResponse: (NSData *) data{
    NSDictionary    * results =[Utility JSONDatatoDict:data];
    
    if (results){

        PXPLog(@"The event has been deleted %@" , results);
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_DELETE_EVENT_COMPLETE object:self];
}
-(void)camerasGetResponce:(NSData *)data
{
    NSDictionary    * results =[Utility JSONDatatoDict:data];
    NSArray * list = [results[@"camlist"]allValues];
    _cameraCount = list.count;
    self.cameraData = results;
    NSMutableDictionary *camerasAvailableList = [NSMutableDictionary new];
    
    
    for (NSDictionary *dic in list) {
       // if ([dic[@"cameraPresent"]boolValue])_cameraCount++;
        if ([dic[@"mac"] isKindOfClass:[NSString class]] ){
            CameraDetails * camD = [[CameraDetails alloc]initWithDictionary:dic encoderOwner:self];
            [camerasAvailableList setObject:camD forKey:dic[@"deviceURL"]];
//            [camerasAvailableList setObject:camD forKey:dic[@"ip"]];
//            [camerasAvailableList setObject:camD forKey:dic[@"mac"]];
            [self.cameraResource addCameraDetails:camD];
        }
        
    }
  
    
    self.cameraData = [camerasAvailableList copy];
    
    PXPLog(@"%@ has %@ cameras",self.name ,[NSString stringWithFormat:@"%ld",(long)_cameraCount ]);
    [[FeedMapController instance]getCameraDetailsFromServer];
}




#pragma mark - Master Responce

-(void)stopResponce:(NSData *)data
{
    
    PXPLog(@"!!!Event Stopped on %@",self.name);
}

-(void)startResponce:(NSData *)data
{

    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_LIVE_EVENT_STARTED object:self];
    PXPLog(@"!!!Event Started on %@",self.name);
}

-(void)pauseResponce:(NSData *)data
{
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_LIVE_EVENT_PAUSED object:self];
    PXPLog(@"!!!Event Paused on %@",self.name);
}

-(void)resumeResponce:(NSData *)data
{
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_LIVE_EVENT_RESUMED object:self];
    PXPLog(@"!!!Event Resumed on %@",self.name);
}




/**
 *  This class is what buils the rest of the data from the encoder
 *
 *
 *  @param data
 */
-(void)getAllEventsResponse:(NSData *)data
{
    if(NSClassFromString(@"NSJSONSerialization"))
    {
        _liveEvent = nil;
        NSError *error = nil;
        id object = [NSJSONSerialization
                     JSONObjectWithData:data
                     options:0
                     error:&error];
        



        if([object isKindOfClass:[NSDictionary class]])
        {
            rawEncoderData                  = object;
            
            NSArray              * events   = [rawEncoderData objectForKey:@"events"];
            NSMutableDictionary  * pool     = [[NSMutableDictionary alloc]init];
            
            @try {
                NSEnumerator *enumerator = [events objectEnumerator];
                id value;
                
                while ((value = [enumerator nextObject])) {
                    
                    if ( ![self validateEventData:value]) {
                        NSLog(@" !!! Corruppted Event Found on server %@",value);
                        continue;
                    }
                    
                    // make event with the data
                  
                    Event * anEvent = [[Event alloc]initWithDict:(NSDictionary *)value isLocal:NO andlocalPath:nil];
                    anEvent.parentEncoder = self;
                    
                    // populating teams based off data
                    League      * league        = [self.encoderLeagues objectForKey:value[kLeague]];
                    LeagueTeam  * homeTeam      = [league.teams objectForKey:value[kHomeTeam]];
                    LeagueTeam  * visitTeam     = [league.teams objectForKey:value[kAwayTeam]];
                    if (!homeTeam) {
                        homeTeam     = [LeagueTeam new];
                    }
                    if (!visitTeam) {
                        visitTeam   = [LeagueTeam new];
                    }
                    
                    
                    anEvent.teams = @{kHomeTeam:homeTeam,kAwayTeam:visitTeam};

                    
                    
                    if (anEvent.live){ // live event FOUND!
                        _liveEvent = anEvent;
                        anEvent.cameraResource = self.cameraResource; // this is to replace the camera resource that was made with feed data
                        if ([_allEvents objectForKey:anEvent.name]){
                            NSLog(@" *** Is already on encoder %@",anEvent.name);
                        } else {
                            [pool setObject:anEvent forKey:anEvent.name];
                            [pool setObject:anEvent forKey:LIVE_EVENT];
                            
                            NSMutableDictionary *eventFinal = [[NSMutableDictionary alloc]initWithDictionary:@{@"non-local":anEvent}];
                            [_allEvents setObject:eventFinal forKey:anEvent.name];
                            [_allEvents setObject:eventFinal forKey:LIVE_EVENT];
                            
                            //self.allEvents      = [pool copy];
                            //if (_status == ENCODER_STATUS_LIVE) {
                            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_LIVE_EVENT_FOUND object:self];
                            //}
                        }
                    }else{
                        if ([_allEvents objectForKey:anEvent.name]){
                            NSLog(@" *** Is already on encoder %@",anEvent.name);
                        } else {

                            [pool setObject:anEvent forKey:anEvent.name];
                        
                        }
                        
                    }
                    
                    if ([[anEvent.rawData objectForKey:@"deleted"] intValue] == 1) {
                        [pool removeObjectForKey:anEvent.name];
                    }
                }
            }
            @catch (NSException *exception) {
                PXPLog(@"error parsing json data: %@",exception);
            }
            @finally {
                
            }
            
            for(Event *encoderEvent in [pool allValues]) {
                Event *localEvent = [[LocalMediaManager getInstance] getEventByName:encoderEvent.name];
                if (localEvent) {
                    NSMutableDictionary *eventFinal = [[NSMutableDictionary alloc]initWithDictionary:@{@"local":localEvent,@"non-local":encoderEvent}];
                    [_allEvents setObject:eventFinal forKey:encoderEvent.name];
                }else{
                    NSMutableDictionary *eventFinal = [[NSMutableDictionary alloc]initWithDictionary:@{@"non-local":encoderEvent}];
                    [_allEvents setObject:eventFinal forKey:encoderEvent.name];
                }
            }
            
            
            //self.allEvents      = [pool copy];
            
        }
    }
    
    _isBuild = YES;
}



-(void)searchForLiveEventResponse:(NSData *)data
{
    NSDictionary * rData = [Utility JSONDatatoDict:data];
    
    if (![rData isKindOfClass:[NSDictionary class]]){
        PXPLog(@"error parsing json data when looking for Live");
    }
   
    NSArray     * eventsToSearch        = [rData objectForKey:@"events"];
    
    NSEnumerator *enumerator = [eventsToSearch objectEnumerator];
    id value;
    while ((value = [enumerator nextObject])) {
        
        if ([(NSDictionary *)value objectForKey:@"live"] || [(NSDictionary *)value objectForKey:@"live_2"] ) {
            Event * anEvent = [[Event alloc]initWithDict:(NSDictionary *)value isLocal:NO andlocalPath:nil];
            anEvent.parentEncoder = self;
            
            League      * league        = [self.encoderLeagues objectForKey:value[@"league"]];
            LeagueTeam  * homeTeam      = [league.teams objectForKey:value[@"homeTeam"]];
            LeagueTeam  * visitTeam     = [league.teams objectForKey:value[@"visitTeam"]];
            if (!homeTeam) {
                homeTeam     = [LeagueTeam new];
            }
            if (!visitTeam) {
                visitTeam   = [LeagueTeam new];
            }
            
            anEvent.teams = @{@"homeTeam":homeTeam,@"visitTeam":visitTeam};

            _liveEvent = anEvent;
            NSMutableDictionary *eventFinal = [[NSMutableDictionary alloc]initWithDictionary:@{@"non-local":anEvent}];
            [_allEvents setObject:eventFinal forKey:anEvent.name];
            [_allEvents setObject:eventFinal forKey:LIVE_EVENT];
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_LIVE_EVENT_FOUND object:self];
            break;
        }
    }
    

    
}

#pragma mark - 

-(BOOL)validateEventData:(NSDictionary *)eventData
{
    BOOL allOkay = YES;
    if (![eventData isKindOfClass:[NSDictionary class]]) allOkay = NO;
    if (![eventData objectForKey:@"name"]) allOkay = NO;
    if (![eventData objectForKey:@"hid"]) allOkay = NO;
    if (![eventData objectForKey:@"sport"]) allOkay = NO;
    if (![eventData objectForKey:@"league"]) allOkay = NO;
    if (![eventData objectForKey:@"homeTeam"]) allOkay = NO;
    if (![eventData objectForKey:@"visitTeam"]) allOkay = NO;

    return  allOkay;
}


#pragma mark - Queue methods
// Queue methods
-(void)addToQueue:(EncoderTask *)obj
{
    NSNumber * priKey =[[NSNumber alloc] initWithInt:obj.priority];
    if ([queue objectForKey: priKey] == nil ) {
        [queue setObject:[[NSMutableArray alloc]init] forKey:priKey];
    }
    [((NSMutableArray*)[queue objectForKey:priKey])addObject:obj];

}

/**
 *  This removes a Command forom the Queue
 *
 *  @param obj the command to be removed
 */
-(void)removeFromQueue:(EncoderTask *)obj
{
    NSNumber * priKey =[[NSNumber alloc] initWithInt:obj.priority];
    [[queue objectForKey:priKey]removeObject:obj];
    
}

-(EncoderTask *)getNextInQueue
{
    // Sorted keys
    NSMutableArray * allKeys =  [NSMutableArray arrayWithArray:[[queue allKeys] sortedArrayUsingComparator:^(id obj1, id obj2) {
        return (NSComparisonResult) ([obj1 longValue] - [obj2 longValue]);
    }]];
    
    NSNumber * thePriorityKey = [allKeys lastObject];
    while ([queue count]!=0 && ((NSMutableArray *)[queue objectForKey:thePriorityKey]).count == 0 ) {
        [queue removeObjectForKey:thePriorityKey];
        [allKeys removeLastObject];
        thePriorityKey = [allKeys lastObject];
    }
    
    EncoderTask * nextObj = [((NSMutableArray *)[queue objectForKey:thePriorityKey]) objectAtIndex:0];
    
    return nextObj;
}
/**
 *  this will clear all commands in the queue and cancel current command
 */
-(void)clearQueueAndCurrent
{
    [queue removeAllObjects];
    [encoderConnection cancel];
    isWaitiing = NO;
}


-(void)destroy
{
    [statusMonitor destroy];
    [self clearQueueAndCurrent];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_ENCODER_MASTER_FOUND object:nil];
    self.name = @"trashed"; // temp fix
}


-(void)setIsMaster:(BOOL)isMaster
{
    if (_isMaster == isMaster) return;
    BOOL wasMaster = _isMaster;
    
    [self willChangeValueForKey:@"isMaster"];
    _isMaster = isMaster;
    [self didChangeValueForKey:@"isMaster"];
    
    if (wasMaster && !isMaster){
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_ENCODER_MASTER_ENSLAVED object:self];
    }
    
    if (_isMaster) {
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_ENCODER_MASTER_FOUND object:self];
    }
    
}

#pragma mark - Clip Download Methods


-(void)tagPrepared:(EncoderTask*)task responceData:(NSData*) data
{
       NSDictionary    * results               = [Utility JSONDatatoDict:data];
    // break up the the data to make a good url
    NSString        * urlForImageOnServer   = (NSString *)[results objectForKey:@"vidurl"];
    PXPLog(LOG_HASH);
    PXPLog(@"%@",results);
    
    PXPLog(LOG_HASH);
    

    
    // this part can be replaced with a regex
    NSString * sidx     = results[@"requrl"];
    NSRange  d          =  [sidx rangeOfString:@"sidx\":\""];
    d                       = NSMakeRange(0, d.length+d.location);
    sidx =  [sidx stringByReplacingCharactersInRange:d withString:@""];
    d =  [sidx rangeOfString:@"\""];
    d = NSMakeRange( d.location,[sidx length]-d.location);
    sidx =  [sidx stringByReplacingCharactersInRange:d withString:@""];
    NSString *src = sidx;
    
    if (!urlForImageOnServer) PXPLog(@"Warning: vidurl not found on Encoder");
    // if in the data success is 0 then there is an error!
    
    // we add "+srcID" so we can grab the srcID from the file name by scanning up to the '+'
    NSString * videoName        = [NSString stringWithFormat:@"%@_vid_%@+%@.mp4",results[@"event"],results[@"id"], src];
    NSString *tagID             = results[@"id"];
    NSString *ip                = self.ipAddress;
    NSString *remoteSrc         = [src stringByReplacingOccurrencesOfString:@"s_" withString:@""];
    NSString *downloaderRefKey  =  results[@"srcValue"]; // this is used for the downloader and the localmedia manager
    NSString * eventName        = (self.event.live)?LIVE_EVENT:results[@"event"] ;
    
    
    NSString *remotePath;
    if ([self checkEncoderVersion]) {
        remotePath = [NSString stringWithFormat:@"http://%@/events/%@/video/vid_%@.mp4", ip,eventName, tagID];
    }else{
        remotePath = [NSString stringWithFormat:@"http://%@/events/%@/video/%@_vid_%@.mp4", ip,eventName, remoteSrc, tagID];
    }
    
    NSString        * pth   = [NSString stringWithFormat:@"%@/%@",[[LocalMediaManager getInstance] bookmarkedVideosPath] ,videoName];
    NSString        * dlKey = [NSString stringWithFormat:@"%@-%@",tagID,downloaderRefKey ];
    DownloadItem    * dli   = [Downloader downloadURL:remotePath to:pth type:DownloadItem_TypeVideo key:dlKey];

    
    
    
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NOTIF_DOWNLOAD_COMPLETE object:nil queue:nil usingBlock:^(NSNotification *note) {
        if (note.object == dli) {
            NSLog(@"Download Complete block saving to local");
            [[LocalMediaManager getInstance] saveClip:videoName withData:results];
        }
    }];

    // on start downloading send the item to original block
    task.onComplete(@{@"downloadItem":dli});

}


//debugging
#pragma mark - debugging

// This will show name and status
-(NSString*)description
{
    NSString * txt = [NSString stringWithFormat:@" %@(%@)<%@>: %ld - %@   - %@",self.name,_urlProtocol,version,(long)self.status,self.event.name,self.event.eventType  ];
    return txt;
}

// Depricated? do we need getters and setters
-(NSString*)name
{
    return _name;
}

// Depricated? do we need getters and setters
-(void)setName:(NSString *)name
{
    [self willChangeValueForKey:@"name"];
    _name = name;
    [self didChangeValueForKey:@"name"];
}


// ActionListItem Methods

-(void)start
{
    isFinished = NO;
}




-(void)dealloc
{
    isAlive = NO;
}

- (void)eventTagsGetResponce:(NSData *)data extraData:(NSDictionary *)dict {
    // IMPLEMENT ME!
}


#pragma mark - New Encoder Structure

// this adds the operation to the operation Queue
// The reason for not sending it directly is there is other encoders that will not react to operaions the same way
-(void)runOperation:(EncoderOperation*)operation
{
    
    [self.operationQueue addOperation:(NSOperation *)operation];
}



@end
