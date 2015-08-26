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
#import "EncoderManager.h"
#import "CameraDetails.h"
#import "UserCenter.h"
#import "League.h"
#import "LeagueTeam.h"
#import "TeamPlayer.h"
#define trimSrc(s)  [Utility removeSubString:@"s_" in:(s)]


#define GET_NOW_TIME_STRING [NSString stringWithFormat:@"%f",CACurrentMediaTime()]
#define trim(s)  [Utility removeSubString:@":timeStamp:" in:(s)]
#define SYNC_ME             @"SYNC_ME"
#define IS_AUTHENTICATING NO


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
        
        for (id <EncoderProtocol> edS in _encodersBeingWatched) {
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
    
    
    for (id <EncoderProtocol> edS in _encodersBeingWatched) {
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
    
    
    for (id <EncoderProtocol> edS in _encodersBeingWatched) {
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
    
    
    for ( id <EncoderProtocol> edS in _encodersBeingWatched) {
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
    if (_onComplete && [note.userInfo objectForKey:@"responce"])   [_colletedResponce addObject: [note.userInfo objectForKey:@"responce"] ];
    if (_onCompleteDict && [note.userInfo objectForKey:@"responce"]){
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
    [_encodersBeingWatched enumerateObjectsUsingBlock:^( id <EncoderProtocol> obj, NSUInteger idx, BOOL *stop){
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
    
    [_encodersBeingWatched enumerateObjectsUsingBlock:^(id <EncoderProtocol> obj, NSUInteger idx, BOOL *stop){
        [[NSNotificationCenter defaultCenter] removeObserver:self name:_name object:obj];
        
        // this needs to reamove the command from the queue or cancel all
    }];
    _countOfLeftToComplete  = 0;
    
    
}


@end

// END OF HELPER CLASS






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
    BOOL isVersion;
    EncoderDataSync             * encoderSync;
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
//@synthesize allEventData    = _allEventData;
@synthesize liveEvent   = _liveEvent;
//@synthesize eventType       = _eventType;
//@synthesize eventTags       = _eventTags;
//@synthesize eventData       = _eventData;
//@synthesize feeds           = _feeds;

//@synthesize playerData      = _playerData;

@synthesize cameraCount     = _cameraCount;
//@synthesize eventTagsDict   = _eventTagsDict;
@synthesize encoderTeams    = _encoderTeams;
@synthesize encoderLeagues  = _encoderLeagues;
@synthesize isBuild         = _isBuild;
@synthesize isReady         = _isReady;

@synthesize isAlive;
@synthesize allEvents       = _allEvents;

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
//        _eventTagsDict  = [[NSMutableDictionary alloc]init];
        isWaitiing      = NO;
        version         = @"?";
        _statusAsString = @"";
        _isMaster       = NO;
        isTeamsGet      = NO;
        isAuthenticate  = NO;
        isVersion       = NO;
        _isBuild        = NO;
        _isReady         = NO;
        isAlive         = YES;
        _cameraCount    = 0;
        _status         = ENCODER_STATUS_INIT;
        _justStarted    = true;
        encoderSync             = [[EncoderDataSync alloc]init];
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
    return self;
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
    
    BOOL eventStopped = false;
    if (!event && _event && _event.live) {
        eventStopped = true;
    }
    
    [self willChangeValueForKey:@"event"];
    _event      =  event;
    [self didChangeValueForKey:@"event"];
    NSString * eventType = (_event)?_event.eventType:@"";
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_EVENT_CHANGE object:self userInfo:@{@"eventType":eventType}];
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_TAG_RECEIVED object:_event];
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


-(void)issueCommand:(NSString *)methodName priority:(int)priority timeoutInSec:(float)time tagData:(NSMutableDictionary*)tData timeStamp:(NSNumber *)aTimeStamp onComplete:(void (^)())onComplete
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
    tagToDelete.type = TagTypeDeleted;

    
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:
                                     @{
                                       @"delete"        : @"1",
                                       @"event"         : (tagToDelete.isLive)?LIVE_EVENT:tagToDelete.event.name, // LIVE_EVENT == @"live"
                                       @"id"            : tagToDelete.ID,
                                       @"requesttime"   : GET_NOW_TIME_STRING,
                                       @"user"          : tagToDelete.user
                                       }];
    
    
    //[dict addEntriesFromDictionary:[tagToDelete makeTagData]];
    
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

-(void)onDownloadClip:(NSNotification *)note
{
    //__block void(^dItemBlock)(DownloadItem*) = note.userInfo[@"block"];
    Tag *tag = note.userInfo[@"tag"];
    //NSString *feedName = note.userInfo[@"feedName"];
    
//    unsigned long srcID;
//    sscanf([note.userInfo[@"src"] UTF8String], "s_%lu", &srcID);
    
    NSString * srcID = note.userInfo[@"src"];
    //NSString * videoName = [NSString stringWithFormat:@"%@_vid_%@.mp4", tag.event, tag.ID];
    //dItemBlock([[LocalEncoder getInstance] saveClip:videoName withData:tag]);
    //dItemBlock([[LocalEncoder getInstance] saveClip:videoName withData: [tag makeTagData]]);
    //dItemBlock([_localEncoder saveClip:videoName withData: tag ]);
    __block void(^dItemBlock)(DownloadItem*) = note.userInfo[@"block"];

    // This gets run when the server responds
    void(^onCompleteGet)(NSArray *) = ^void (NSArray*pooledResponces) {
    
    NSData          * data                  = pooledResponces[0];
    NSDictionary    * results               = [Utility JSONDatatoDict: data];
    NSString        * urlForImageOnServer   = (NSString *)[results objectForKey:@"vidurl"];;
    if (!urlForImageOnServer) PXPLog(@"Warning: vidurl not found on Encoder");
    // if in the data success is 0 then there is an error!

    // we add "+srcID" so we can grab the srcID from the file name by scanning up to the '+'
//    NSString * videoName = [NSString stringWithFormat:@"%@_vid_%@+%02lu.mp4",results[@"event"],results[@"id"], srcID];
    NSString * videoName = [NSString stringWithFormat:@"%@_vid_%@+%@.mp4",results[@"event"],results[@"id"], srcID];
    

    // http://10.93.63.226/events/live/video/01hq_vid_10.mp4
    
    // BEGIN SERVER IS DUMB (Fake the URL of the saved video, because encoder pretty much always give back s_01)
    
    NSString *tagID = tag.ID;
    NSString *ip = self.ipAddress;
    NSString *src = note.userInfo[@"src"];
    
    unsigned long n;
    sscanf(src.UTF8String, "s_%lu", &n);
    NSString *remoteSrc = [NSString stringWithFormat:@"%02luhq", n];
        
        NSString *remotePath;
    if ([self checkEncoderVersion]) {
        remotePath = [NSString stringWithFormat:@"http://%@/events/live/video/vid_%@.mp4", ip, tagID];
    }else{
        remotePath = [NSString stringWithFormat:@"http://%@/events/live/video/%@_vid_%@.mp4", ip, remoteSrc, tagID];
    }
        
    //NSString *remotePath = [NSString stringWithFormat:@"http://%@/events/live/video/%@_vid_%@.mp4", ip, remoteSrc, tagID];
    


    // END SERVER IS DUMB
    
    //NSString * pth = [NSString stringWithFormat:@"%@/%@",[[LocalEncoder getInstance] bookmarkedVideosPath],videoName];
    NSString * pth = [NSString stringWithFormat:@"%@/%@",[[LocalMediaManager getInstance] bookmarkedVideosPath] ,videoName];
    DownloadItem * dli = [Downloader downloadURL:remotePath to:pth type:DownloadItem_TypeVideo key:[NSString stringWithFormat:@"%@-%@",tagID,src ]];
    dItemBlock(dli);
    
    
    
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NOTIF_DOWNLOAD_COMPLETE object:nil queue:nil usingBlock:^(NSNotification *note) {
    // is the object what we ware downloading
        if (note.object == dli) {
         NSLog(@"Download Complete");
    
         // we must now forge the results
            
            //[[LocalEncoder getInstance] saveClip:videoName withData:results];
          [[LocalMediaManager getInstance] saveClip:videoName withData:results];
          //[_localEncoder saveClip:videoName withData:results]; // this is the data used to make the plist
          }
     }];
    };
    
    
    
    NSMutableDictionary * sumRequestData = [NSMutableDictionary dictionaryWithDictionary:
                                                @{
                                                 @"id": tag.ID,
                                                 @"event": (tag.isLive)?LIVE_EVENT:tag.event,
                                                 @"requesttime":GET_NOW_TIME_STRING,
                                                 @"bookmark":@"1",
                                                 @"user":[UserCenter getInstance].userHID
                                                }];
    
    [sumRequestData addEntriesFromDictionary:@{@"sidx":trimSrc(note.userInfo[@"src"])}];
    
    [self issueCommand:MODIFY_TAG priority:1 timeoutInSec:30 tagData:sumRequestData timeStamp:GET_NOW_TIME];
    
    [encoderSync syncAll:@[self] name:NOTIF_ENCODER_CONNECTION_FINISH timeStamp:GET_NOW_TIME onFinish:onCompleteGet];
    //[encoderSync syncAll:@[_primaryEncoder] name:NOTIF_ENCODER_CONNECTION_FINISH timeStamp:GET_NOW_TIME onFinish:onCompleteGet];
    
    PXPLog(@"Downloading Clip!");
    

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
    [self issueCommand:TEAMS_GET        priority:3 timeoutInSec:15 tagData:nil timeStamp:GET_NOW_TIME];
    [self issueCommand:BUILD            priority:2 timeoutInSec:15 tagData:nil timeStamp:GET_NOW_TIME];
    [self issueCommand:CAMERAS_GET      priority:1 timeoutInSec:15 tagData:nil timeStamp:GET_NOW_TIME];

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
    
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"http://%@/min/ajax/auth/%@",self.ipAddress,json]  ];
    PXPLogAjax(@"http://%@/min/ajax/auth/%@",self.ipAddress,@{@"id":customerID});
    urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = AUTHENTICATE;
    encoderConnection.timeStamp             = aTimeStamp;

}


-(void)buildEncoder:(NSMutableDictionary *)data timeStamp:(NSNumber *)aTimeStamp
{
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"http://%@/min/ajax/getpastevents",self.ipAddress]  ];
    PXPLogAjax(checkURL.absoluteString);
    urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = BUILD;
    encoderConnection.timeStamp             = aTimeStamp;
}

-(void)requestVersion:(NSMutableDictionary *)data timeStamp:(NSNumber *)aTimeStamp
{
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"http://%@/min/ajax/version",self.ipAddress]  ];
    PXPLogAjax(checkURL.absoluteString);
    urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = VERSION;
    encoderConnection.timeStamp             = aTimeStamp;
}

-(void)shutdown:(NSMutableDictionary *)data timeStamp:(NSNumber *)aTimeStamp
{
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"http://%@/min/ajax/encshutdown",self.ipAddress]  ];
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
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"http://%@/min/ajax/tagset/%@",self.ipAddress,jsonString]  ];
    PXPLogAjax(@"http://%@/min/ajax/tagset/%@",self.ipAddress,tData);
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
    
    /*NSString *jsonString                    = [Utility dictToJSON:tData];
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"http://%@/min/ajax/teleset/%@",self.ipAddress,jsonString] ];
    urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = MAKE_TELE_TAG;
    encoderConnection.timeStamp             = aTimeStamp;*/
    //NSDictionary *teleData = [tData objectForKey:@"telestration"];
    //NSData *final = [NSKeyedArchiver archivedDataWithRootObject:teleData];
    //[tData removeObjectForKey:@"telestration"];
    NSString *jsonString                    = [Utility dictToJSON:tData];
    jsonString = [jsonString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
     NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"http://%@/min/ajax/teleset",self.ipAddress]  ];
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
    
    //f ([tData objectForKey:@"url"]) {
        [tData removeObjectForKey:@"url"];
    //}
    
    //if ([tData objectForKey:@"ulr_2"]) {
        [tData removeObjectForKey:@"url_2"];
    //}
    
    // this is temp
    /*if (((TagType)[tData[@"type"]integerValue]) == TagTypeCloseDuration && [tData objectForKey:@"closetime"]){
        double openTime                 = [tData[@"starttime"]doubleValue];
        double closeTime                = [tData[@"closetime"]doubleValue];
        tData[@"duration"]       = [NSNumber numberWithDouble:(closeTime-openTime)];
        
        [tData removeObjectForKey:@"closetime"];
    }*/
    
    
    NSString *jsonString                    = [Utility dictToJSON:tData];
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"http://%@/min/ajax/tagmod/%@",self.ipAddress,jsonString]  ];
    PXPLogAjax(@"http://%@/min/ajax/tagmod/%@",self.ipAddress,tData);
    urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = MODIFY_TAG;
    encoderConnection.timeStamp             = aTimeStamp;
}

-(void)deleteEvent:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp{
    
   // NSString *jsonString                    = [Utility dictToJSON:tData];
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"http://%@/min/ajax/evtdelete/?name=%@&event=%@",self.ipAddress,[tData objectForKey:@"name"],[tData objectForKey:@"hid"]]  ];
    PXPLogAjax(@"http://%@/min/ajax/evtdelete/?name=%@&event=%@",self.ipAddress,[tData objectForKey:@"name"],[tData objectForKey:@"hid"]);
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
        jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"http://%@/min/ajax/sumget/%@",self.ipAddress,jsonString]  ];
    PXPLogAjax(@"http://%@/min/ajax/sumget/%@",self.ipAddress,tData);
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
    
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"http://%@/min/ajax/sumset/%@",self.ipAddress,jsonString]  ];
    PXPLogAjax(@"http://%@/min/ajax/sumset/%@",self.ipAddress,tData);
    urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = SUMMARY_PUT;
    encoderConnection.timeStamp             = aTimeStamp;
}

-(void)teamsGet:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp
{
 
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"http://%@/min/ajax/teamsget",self.ipAddress]  ];
    PXPLogAjax(checkURL.absoluteString);
    urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = TEAMS_GET;
    encoderConnection.timeStamp             = aTimeStamp;
}

-(void)camerasGet:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp
{
    
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"http://%@/min/ajax/getcameras",self.ipAddress]  ];
    PXPLogAjax(checkURL.absoluteString);
    urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = CAMERAS_GET;
    encoderConnection.timeStamp             = aTimeStamp;
}


-(void)eventTagsGet:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp
{

    NSString *jsonString                    = [Utility dictToJSON:tData];
    
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"http://%@/min/ajax/gametags/%@",self.ipAddress,jsonString]  ];
    PXPLogAjax(@"http://%@/min/ajax/gametags/%@",self.ipAddress,tData);
    urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = EVENT_GET_TAGS;
    encoderConnection.timeStamp             = aTimeStamp;
    encoderConnection.extra                 = @{@"event":[tData objectForKey:@"event"]};// This is the key th   at will be used when making the dict
}


-(void)allEventsGet:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp
{
    
    NSString *jsonString                    = [Utility dictToJSON:tData];
    
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"http://%@/min/ajax/gametags/%@",self.ipAddress,jsonString]  ];
    PXPLogAjax(@"http://%@/min/ajax/gametags/%@",self.ipAddress,tData);
    urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = EVENT_GET_TAGS;
    encoderConnection.timeStamp             = aTimeStamp;
    encoderConnection.extra                 = @{@"event":[tData objectForKey:@"event"]};// This is the key that will be used when making the dict
}


-(void)liveEventGet:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp
{
    
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"http://%@/min/ajax/getpastevents",self.ipAddress]  ];
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
        jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"http://%@/min/ajax/encstop/%@",self.ipAddress,jsonString]  ];
    PXPLogAjax(@"http://%@/min/ajax/encstop/%@",self.ipAddress,jsonString);
    urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = STOP_EVENT;
    encoderConnection.timeStamp             = aTimeStamp;
    
    
}

-(void)pauseEvent:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp
{
    
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"http://%@/min/ajax/encpause/",self.ipAddress]  ];
    urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    PXPLogAjax(checkURL.absoluteString);
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = PAUSE_EVENT;
    encoderConnection.timeStamp             = aTimeStamp;
}

-(void)resumeEvent:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp
{
    
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"http://%@/min/ajax/encresume/",self.ipAddress]  ];
    urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    PXPLogAjax(checkURL.absoluteString);
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = RESUME_EVENT;
    encoderConnection.timeStamp             = aTimeStamp;
}


-(void)startEvent:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp
{
    
    _encoderManager.primaryEncoder = _encoderManager.masterEncoder;
    
    _pressingStart = true;
    
    NSString * homeTeam = [tData objectForKey:@"homeTeam"];
    NSString * awayTeam = [tData objectForKey:@"awayTeam"];
    NSString * league   = [tData objectForKey:@"league"];
    
    NSString *unencoded = [NSString stringWithFormat:@"http://%@/min/ajax/encstart/?hmteam=%@&vsteam=%@&league=%@&time=%@&quality=%@",
                           self.ipAddress,
                           homeTeam,
                           awayTeam,
                           league,
                           [NSString stringWithFormat:@"%@",aTimeStamp],
                           @"high"];
    
    unencoded = [unencoded stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
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

//-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
//{
//    
//}


-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (connection.cumulatedData == nil){
        connection.cumulatedData = [NSMutableData dataWithData:data];
    } else {
        [connection.cumulatedData appendData:data];
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_ENCODER_CONNECTION_PROGRESS object:self userInfo:nil];
}

-(void)alertView:(CustomAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [alertView viewFinished];
}


-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{

    NSString * connectionType   = connection.connectionType;
    NSData * finishedData       = connection.cumulatedData;
    NSDictionary * extra            = connection.extra;

    if ([connectionType isEqualToString: AUTHENTICATE]){
        [self authenticateResponse: finishedData];
    }  else if ([connectionType isEqualToString: VERSION]){
        [self versionResponse:  finishedData];
    }  else if ([connectionType isEqualToString: BUILD]){
        [self getAllEventsResponse: finishedData];
    }  else if ([connectionType isEqualToString: TEAMS_GET]) {
        [self teamsResponse:    finishedData];
    }  else if ([connectionType isEqualToString: STOP_EVENT]) {
        [self stopResponce:     finishedData];
    }  else if ([connectionType isEqualToString: START_EVENT]) {
        NSDictionary    * results =[Utility JSONDatatoDict:finishedData];
        if ([results[@"success"]intValue] == 0) {
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_STATUS_LABEL_CHANGED object:self];
            CustomAlertView *alert = [[CustomAlertView alloc]initWithTitle:@"Can't Start Event" message:results[@"msg"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert showView];
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
        //[self tagsJustChanged:finishedData extraData:MODIFY_TAG];
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
        if (!statusMonitor) statusMonitor   = [[EncoderStatusMonitor alloc]initWithDelegate:self];
//        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_THIS_ENCODER_IS_READY object:self];
        [self.encoderManager onRegisterEncoderCompleted:self];
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
    if (!IS_AUTHENTICATING){
        [self willChangeValueForKey:@"authenticated"];
        _authenticated = YES;
        PXPLog(@"Warning: define no authenticating");
        [self didChangeValueForKey:@"authenticated"];
        if (!isAuthenticate) [self buildEncoderRequest];
        isAuthenticate = YES;
        return;
    }
    
    
    NSDictionary    * results;

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
                PXPLog(@"##############################################################");
                PXPLog(@"Warning: User Failed to authenticate to Encoder %@",self.name);
                PXPLog(@"  ID:     @%",[UserCenter getInstance].customerID);
                PXPLog(@"  E-mail: @%",[UserCenter getInstance].customerEmail);
                PXPLog(@"##############################################################");
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
    NSDictionary    * results =[Utility JSONDatatoDict:data];
    if([results isKindOfClass:[NSDictionary class]]){
        version = (NSString *)[results objectForKey:@"version"] ;
        PXPLog(@"%@ is version %@",self.name ,version);
    }
    
    isVersion = YES;
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
    
    NSLog(@" ");
    NSLog(@"Building Leagues ===============================");
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
    
    NSLog(@"Leagues =============================== %lu = %lu ",(unsigned long)[leaguePool count] , (unsigned long)[leagueTempHIDPool count]);
    NSLog(@" ");
    NSLog(@"Building Teams ===============================");
    // Build Teams
    NSMutableDictionary * teamTempHIDPool = [[NSMutableDictionary alloc]init];
    NSArray             * rawTeams          = [[results objectForKey:@"teams"]allValues];

    for (NSDictionary * tData in rawTeams) {
        LeagueTeam  * lTeam = [[LeagueTeam alloc]init];
        NSString    * lHID  = tData[@"league"];
        lTeam.extra         = tData[@"extra"];
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
              NSLog(@"Team has no League: %@",lTeam.name);
        }
        
        
        [owningLeague addTeam:lTeam];
        [teamTempHIDPool setObject:lTeam forKey:lTeam.hid];
    }
    
    NSLog(@"Teams =============================== %lu = %lu ",(unsigned long)[rawTeams count] , (unsigned long)[teamTempHIDPool count]);
    NSLog(@" ");
    NSLog(@"Building Players ===============================");
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
                 NSLog(@"Player does not have a team %@",tHID);
            }
            [owningTeam addPlayer:aPlayer];
            
           
        }
//           NSLog(@"%@ \tTeams have %lu players",owningTeam.name,(unsigned long)[owningTeam.players count]);
    }
    NSLog(@"players =============================== %lu",(long)playerCount);
    
    self.encoderLeagues = [leaguePool copy];
    

    isTeamsGet = YES;
}

-(void)checkTag:(NSData *)data
{
    
}

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
            
        
        /*if ([self.allEvents objectForKey:[data objectForKey:@"event"]]){
            Event * checkEvent = [self.allEvents objectForKey:[data objectForKey:@"event"]]; // get event by name
            NSArray * eventTags = [checkEvent.tags copy];
            
            NSString * tagId = [[data objectForKey:@"id"]stringValue];// [NSString stringWithFormat:@"%ld",[[data objectForKey:@"id"]integerValue] ];
            NSPredicate *pred = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                Tag * obj = evaluatedObject;
                return [obj.ID isEqualToString:tagId];
            }];
            
            NSArray *filteredArray = [eventTags filteredArrayUsingPredicate:pred];
            Tag *tagToBeModded = [filteredArray firstObject];
            
            if ( ((TagType)[data[@"type"]integerValue]) == TagTypeOpenDuration) {
                NSMutableDictionary * dictToChange = [[NSMutableDictionary alloc]initWithDictionary:data];
                double openTime                 = tagToBeModded.time;
                double closeTime                = [dictToChange[@"time"]doubleValue];
                dictToChange[@"duration"]       = [NSNumber numberWithDouble:(closeTime - openTime )];
                dictToChange[@"time"]           = [NSNumber numberWithDouble:openTime];
                
                [tagToBeModded replaceDataWithDictionary:[dictToChange copy]];
            } else {
                [tagToBeModded replaceDataWithDictionary:data];
            
            }
         

            [checkEvent modifyTag:tagToBeModded];
        }*/
    }
}

-(void)onNewTags:(NSDictionary*)data
{
    if ([data objectForKey:@"id"]) {
        
        if ([_allEvents objectForKey:[data objectForKey:@"event"]]){
            NSMutableDictionary *checkEventDic = [_allEvents objectForKey:[data objectForKey:@"event"]];
            Event * encoderEvent = [checkEventDic objectForKey:@"non-local"];
            Event * localEvent = [checkEventDic objectForKey:@"local"];
            Tag *newTag = [[Tag alloc] initWithData: data event:encoderEvent];
            
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
        }
    }
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
            if ([tData objectForKey:@"telestration"]) {
                newTag.telestration = [PxpTelestration telestrationFromData:[tData objectForKey:@"telestration"]];
            }
        
            if (self.event == encoderEvent) {
                [encoderEvent addTag:newTag extraData:true];
            }else{
                [encoderEvent addTag:newTag extraData:false];
            }
            
            if (localEvent && newTag.type != TagTypeOpenDuration) {
                Tag *localTag = [[Tag alloc] initWithData:tData event:localEvent];
                [localEvent addTag:localTag extraData:false];
                [localEvent.parentEncoder writeToPlist];
            }
        }
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
                
                if (![tag[@"deviceid"] isEqualToString:[[[UIDevice currentDevice] identifierForVendor]UUIDString]] || [tag[@"type"]intValue] == TagTypeHockeyStrengthStop || [tag[@"type"]intValue] == TagTypeHockeyStopOLine || [tag[@"type"]intValue] == TagTypeHockeyStopDLine ||  [tag[@"type"]intValue] == TagTypeSoccerZoneStop) {
                    if ([tag[@"type"]intValue] == TagTypeDeleted) {
                        [self onModifyTags:tag];
                    }else if([tag[@"modified"]boolValue]){
                        [self onModifyTags:tag];
                    }else if([tag[@"type"]intValue] == TagTypeCloseDuration){
                        [self onModifyTags:tag];
                    }else if ([tag[@"type"]intValue] == TagTypeTele){
                        [self onTeleTags:tag];
                    }
                    else{
                        [self onNewTags:tag];
                    }

                }
                
                
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
        
        self.status           = status; /// maybe make this mod directly
        if (self.status == ENCODER_STATUS_LIVE && self.liveEvent == nil) {
//            self.isBuild = false; // This is so the encoder manager rebuilds it once
            [self issueCommand:LIVE_EVENT_GET priority:1 timeoutInSec:15 tagData:nil timeStamp:GET_NOW_TIME];
        } else if (self.status == ENCODER_STATUS_STOP ||self.status == ENCODER_STATUS_READY) {
            if (self.liveEvent == self.event) {
                //[self stopResponce:nil];
                //self.liveEvent = nil;
                [self.encoderManager declareCurrentEvent:nil];
            };
            self.liveEvent = nil;
            self.encoderManager.liveEvent = nil;
            self.encoderManager.liveEventName = nil;
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_EVENT_CHANGE object:self userInfo:@{@"eventType":@""}];
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_LIVE_EVENT_STOPPED object:self];
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

-(void)onMotionAlarm:(NSDictionary *)data
{
    if ([data objectForKey:@"alarms"]) {
        NSArray * alarmedFeeds = [data objectForKey:@"alarms"];
        NSArray * feedsChecked = (self.event.feeds)?[self.event.feeds allKeys]:@[];
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MOTION_ALARM object:self userInfo:@{
                                                                                                                @"feeds"    : feedsChecked,
                                                                                                                @"alarms"   : alarmedFeeds
                                                                                                            }];
    }
}


/*-(void)makeTagResponce:(NSData *)data
{
    NSDictionary    * results =[Utility JSONDatatoDict:data];
    PXPLog(@"Tag Response has been received");
    PXPLog(@"The tag response is %@", results);
    if([results isKindOfClass:[NSDictionary class]])
    {
        if ([results objectForKey:@"id"]) {
            NSString * tagId = [[results objectForKey:@"id"]stringValue];
            Tag *newTag = [[Tag alloc] initWithData: results];
            newTag.feeds = self.encoderManager.feeds;
            [_event.tags setObject:newTag forKey:tagId];
                if ([[[self.encoderManager.primaryEncoder event]name] isEqualToString:newTag.event] ) {
                    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_TAG_RECEIVED object:newTag userInfo:results];
                }
        }
    }
}*/

/*-(void)eventTagsGetResponce:(NSData *)data extraData:(NSDictionary*)dict
{
    NSDictionary    * results =[Utility JSONDatatoDict:data];
    Event * tempEvent;
    
//    if ([dict objectForKey:@"event"]){
//        tempEvent = (Event *)[dict objectForKey:@"event"];
//    } else {
        tempEvent = _event;
//    }

    
    if (results){
        NSDictionary    * tags = [results objectForKey:@"tags"];
        NSMutableDictionary *tagsDictionary = [NSMutableDictionary dictionary];
        if (tags) {
            for (NSString *idKey in [tags allKeys]) {
                if ([tags[idKey] objectForKey:@"id"]) {
                    Tag *newTag = [[Tag alloc] initWithData: tags[idKey]];
                    newTag.feeds = self.encoderManager.feeds;
                    [tagsDictionary addEntriesFromDictionary:@{idKey:newTag}];
                    if ([[[self.encoderManager.primaryEncoder event]name] isEqualToString:newTag.event] ) {
                        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_TAG_RECEIVED object:newTag userInfo:tags[idKey]];
                    }
                }
                
            }
            
            tempEvent.tags = [[NSMutableArray alloc]initWithArray:[tagsDictionary allValues]];
            //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_TAGS_ARE_READY object:nil];
        } else  if (![[results objectForKey:@"success"]boolValue]) {
            PXPLog(@"Encoder Error!");
            PXPLog(@"  ajax: %@",@"gametags");
            PXPLog(@"  reason: %@",results[@"msg"]);
        }
    }
    
}*/

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
    NSMutableArray *camerasAvailableList = [[NSMutableArray alloc]init];
    
    
    for (NSDictionary *dic in list) {
       // if ([dic[@"cameraPresent"]boolValue])_cameraCount++;
        
       [camerasAvailableList addObject:[[CameraDetails alloc]initWithDictionary:dic encoderOwner:self]];
        
    }
 //   _cameraCount = [((NSDictionary*)[results objectForKey:@"camlist"]) count];
    
    PXPLog(@"%@ has %@ cameras",self.name ,[NSString stringWithFormat:@"%ld",(long)_cameraCount ]);
//    PXPLog(@"JSON OUTPUT:");
//    PXPLog(@"%@",results);
//    PXPLog(@" ");
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
            
            NSArray         * events        = [rawEncoderData objectForKey:@"events"];
            NSMutableDictionary  * pool     = [[NSMutableDictionary alloc]init];
            
            @try {
                NSEnumerator *enumerator = [events objectEnumerator];
                id value;
                
                while ((value = [enumerator nextObject])) {
                
                    // make event with the data
                  
                    Event * anEvent = [[Event alloc]initWithDict:(NSDictionary *)value isLocal:NO andlocalPath:nil];
                    anEvent.parentEncoder = self;
                    
                    // populating teams based off data
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

                    
                    
                    if (anEvent.live){ // live event FOUND!
                        _liveEvent = anEvent;
                        
                        [pool setObject:anEvent forKey:anEvent.name];
                        [pool setObject:anEvent forKey:LIVE_EVENT];
                        
                        NSMutableDictionary *eventFinal = [[NSMutableDictionary alloc]initWithDictionary:@{@"non-local":anEvent}];
                        [_allEvents setObject:eventFinal forKey:anEvent.name];
                        [_allEvents setObject:eventFinal forKey:LIVE_EVENT];
                        
                        //self.allEvents      = [pool copy];
                        //if (_status == ENCODER_STATUS_LIVE) {
                            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_LIVE_EVENT_FOUND object:self];
                        //}
                        
                    }else{
                        [pool setObject:anEvent forKey:anEvent.name];
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


//debugging
#pragma mark - debugging

// This will show name and status
-(NSString*)description
{
    NSString * txt = [NSString stringWithFormat:@" %@(%@): %ld - %@   - %@",self.name,version,(long)self.status,self.event.name,self.event.eventType  ];
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

@end
