//
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

#define GET_NOW_TIME [ NSNumber numberWithDouble:CACurrentMediaTime()]
#define trim(s)  [Utility removeSubString:@":timeStamp:" in:(s)]



// HELPER CLASS



// catagory  // catagory  // catagory  // catagory  // catagory  // catagory  // catagory  // catagory  // catagory

@interface NSURLConnection (Context)

@property (nonatomic,strong)    NSNumber        * timeStamp;
@property (nonatomic,strong)    NSMutableData   * cumulatedData;
@property (nonatomic,strong)    NSString        * connectionType;
@property (nonatomic,strong)    NSString        * extra;


-(NSNumber*)timeStamp;
-(void)setTimeStamp:(NSNumber*)time;

@end

@implementation NSURLConnection (Context)

@dynamic timeStamp;
@dynamic cumulatedData;
@dynamic connectionType;
@dynamic extra;


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

-(void)setExtra:(NSString *)extra
{
    objc_setAssociatedObject(self, @selector(extra), extra,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSString*)extra
{
    return (NSString*)objc_getAssociatedObject(self,@selector(extra));
}

@end





// END HELPER CLASSS


@implementation Encoder
{
    // Ready Flags
    BOOL isTeamsGet;
    BOOL isAuthenticate;
    BOOL isVersion;
}



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

-(id)initWithIP:(NSString*)ip
{
    self = [super init];
    if (self){
        self.ipAddress  = ip;
        _authenticated  = NO;
        timeOut         = 15.0f;
        queue           = [[NSMutableDictionary alloc]init];
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
    }
    return self;
}


-(void)setEvent:(Event *)event
{
    if (event ==_event){
        return;
    }
    
    [self willChangeValueForKey:@"event"];
    _event      =  event;
    [self didChangeValueForKey:@"event"];
    
    /*
    [self willChangeValueForKey:@"event"];
    
    NSArray         * events = [rawEncoderData objectForKey:@"events"];
    for(NSDictionary* dict in events)
    {
       _event =  nil;
        if([dict isKindOfClass:[NSDictionary class]]  && [dict[@"name"] isEqualToString: event])
        {
            self.eventData = dict;
            
            // The new version have _authenticated the old versions do not
            if (_authenticated) {
            
                if ([dict[@"vid_2"] isKindOfClass:[NSDictionary class]]){
                    NSMutableDictionary * collect = [[NSMutableDictionary alloc]init];
                    
                    for (id key in dict[@"vid_2"])
                    {
                        NSDictionary * vidDict      = dict[@"vid_2"];
                        NSDictionary * qualities    = [vidDict objectForKey:key];
                        
                        Feed * createdFeed = [[Feed alloc]initWithURLDict:qualities];
                        createdFeed.sourceName = key;
                        
                        [collect setObject:[[Feed alloc]initWithURLDict:qualities] forKey:key];
                    }
                    
                    _feeds = [collect copy];
                    
                    
                } else if ([dict[@"live_2"] isKindOfClass:[NSDictionary class]]){
                    NSMutableDictionary * collect = [[NSMutableDictionary alloc]init];
                    
                    for (id key in dict[@"live_2"])
                    {
                        NSDictionary * vidDict      = dict[@"live_2"];
                        NSDictionary * qualities    = [vidDict objectForKey:key];
                        
                        Feed * createdFeed = [[Feed alloc]initWithURLDict:qualities];
                        createdFeed.sourceName = key;
                        
                        [collect setObject:[[Feed alloc]initWithURLDict:qualities] forKey:key];
                    }
                    
                    _feeds = [collect copy];
                    
                    
                }
                
                
                
                
            } else {
                if (dict[@"live"]) { // This is for backwards compatibility
                    // _feeds = @{ @"s1":@{@"lq":dict[@"vid"]} };
                    // this creates a feed object from just a string with it  source named s1
                    Feed * theFeed =  [[Feed alloc]initWithURLString:dict[@"live"] quality:0];
                    _feeds = @{ @"s1":theFeed};
                } else if (dict[@"vid"]) {
                    Feed * theFeed =  [[Feed alloc]initWithURLString:dict[@"vid"] quality:0];
                    _feeds = @{ @"s1":theFeed};
                }
            }
            
            [self willChangeValueForKey:@"eventType"];
            _eventType = [dict objectForKey:@"sport"];
            [self didChangeValueForKey:@"eventType"];
           _event =  event;
            break;
        }
    }
 
   [self didChangeValueForKey:@"event"];
    */
}

-(Event*)event
{
    return _event;
}

#pragma - Make COmmands

-(void)issueCommand:(NSString *)methodName priority:(int)priority timeoutInSec:(float)time tagData:(NSMutableDictionary*)tData timeStamp:(NSNumber *)aTimeStamp
{
    EncoderCommand *cmd    = [[EncoderCommand alloc]init];
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

/**
 *  this will run the next command in the queue
 */
-(void)runNextCommand{
    //if the queue is not empty, send another request
    if(queue.count>0 && !isWaitiing)
    {
        EncoderCommand * nextInQueue = [self getNextInQueue];
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
    
    NSArray * filtered = [NSArray arrayWithArray:[[[self allEvents]allValues] filteredArrayUsingPredicate:pred ]];
    
    if ([filtered count]==0)return nil;
    
    return (Event*)filtered[0];
}

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
    [self issueCommand:BUILD            priority:3 timeoutInSec:15 tagData:nil timeStamp:GET_NOW_TIME];
    [self issueCommand:CAMERAS_GET      priority:2 timeoutInSec:15 tagData:nil timeStamp:GET_NOW_TIME];
    [self issueCommand:TEAMS_GET        priority:1 timeoutInSec:15 tagData:nil timeStamp:GET_NOW_TIME];
}


-(void)authenticate:(NSMutableDictionary *)data timeStamp:(NSNumber *)aTimeStamp
{

    
    PXPLog(@"Encoder Warning: Version check in Authenticate Disabled");
    if ([self.version isEqualToString:@"0.94.5"]){

//    if ([Utility sumOfVersion:self.version] <= [Utility sumOfVersion:OLD_VERSION]){
        [self willChangeValueForKey:@"authenticated"];
        _authenticated  = YES;
        isAuthenticate = YES;
        [self didChangeValueForKey:@"authenticated"];
        isWaitiing      = NO;
//        self.isMaster = YES;

        [self removeFromQueue:currentCommand];
        [self runNextCommand]; // this line is for testing
        return;
    }
    
    
    NSString * json = [Utility dictToJSON:@{@"id":customerID}];
    
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"http://%@/min/ajax/auth/%@",self.ipAddress,json]  ];
    urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = AUTHENTICATE;
    encoderConnection.timeStamp             = aTimeStamp;

}


-(void)buildEncoder:(NSMutableDictionary *)data timeStamp:(NSNumber *)aTimeStamp
{
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"http://%@/min/ajax/getpastevents",self.ipAddress]  ];
    urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = BUILD;
    encoderConnection.timeStamp             = aTimeStamp;
}

-(void)requestVersion:(NSMutableDictionary *)data timeStamp:(NSNumber *)aTimeStamp
{
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"http://%@/min/ajax/version",self.ipAddress]  ];
    urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = VERSION;
    encoderConnection.timeStamp             = aTimeStamp;
}

-(void)shutdown:(NSMutableDictionary *)data timeStamp:(NSNumber *)aTimeStamp
{
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"http://%@/min/ajax/encshutdown",self.ipAddress]  ];
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
                                      @"requesttime"    : [NSString stringWithFormat:@"%f",CACurrentMediaTime()]
                                    }];
    
    NSString *jsonString                    = [Utility dictToJSON:tData];
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"http://%@/min/ajax/tagset/%@",self.ipAddress,jsonString]  ];
    urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = MAKE_TAG;
    encoderConnection.timeStamp             = aTimeStamp;
}

-(void)makeTeleTag:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp
{
    NSData *imageData = UIImagePNGRepresentation([tData objectForKey:@"image"]) ;
    [tData removeObjectForKey:@"image"];
    
    NSString *encodedName = [Utility encodeSpecialCharacters:[tData objectForKey:@"name"]];
    
    //over write name and add request time
    [tData addEntriesFromDictionary:@{
                                      @"name"           : encodedName,
                                      @"requesttime"    : [NSString stringWithFormat:@"%f",CACurrentMediaTime()]
                                      }];
    
    NSString *jsonString                    = [Utility dictToJSON:tData];
    jsonString = [jsonString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"http://%@/min/ajax/teleset",self.ipAddress]  ];
    NSMutableURLRequest *someUrlRequest     = [NSMutableURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    [someUrlRequest setHTTPMethod:@"POST"];

    NSString *boundary = @"----WebKitFormBoundarycC4YiaUFwM44F6rT";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [someUrlRequest setValue:contentType forHTTPHeaderField:@"Content-Type"];
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=tag\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    // [body appendData:[@"Content-Type: text/plain\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    // Now we need to append the different data 'segments'. We first start by adding the boundary.
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=file; filename=picture.png\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    // We now need to tell the receiver what content type we have
    // In my case it's a png image. If you have a jpg, set it to 'image/jpg'
    [body appendData:[@"Content-Type: image/png\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    // Now we append the actual image data
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
                                      //@"name"           : encodedName,
                                      //@"requesttime"    : [NSString stringWithFormat:@"%f",CACurrentMediaTime()]
                                      }];
    
    NSString *jsonString                    = [Utility dictToJSON:tData];
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"http://%@/min/ajax/tagmod/%@",self.ipAddress,jsonString]  ];
    urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = MODIFY_TAG;
    encoderConnection.timeStamp             = aTimeStamp;
}

-(void)deleteEvent:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp{
    
   // NSString *jsonString                    = [Utility dictToJSON:tData];
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"http://%@/min/ajax/evtdelete/?name=%@&event=%@",self.ipAddress,[tData objectForKey:@"name"],[tData objectForKey:@"hid"]]  ];
    
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
    urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = SUMMARY_PUT;
    encoderConnection.timeStamp             = aTimeStamp;
}

-(void)teamsGet:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp
{
 
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"http://%@/min/ajax/teamsget",self.ipAddress]  ];
    urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = TEAMS_GET;
    encoderConnection.timeStamp             = aTimeStamp;
}

-(void)camerasGet:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp
{
    
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"http://%@/min/ajax/getcameras",self.ipAddress]  ];
    urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = CAMERAS_GET;
    encoderConnection.timeStamp             = aTimeStamp;
}


-(void)eventTagsGet:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp
{

    NSString *jsonString                    = [Utility dictToJSON:tData];
    
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"http://%@/min/ajax/gametags/%@",self.ipAddress,jsonString]  ];
    urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = EVENT_GET_TAGS;
    encoderConnection.timeStamp             = aTimeStamp;
    encoderConnection.extra                 = [tData objectForKey:@"event"];// This is the key th   at will be used when making the dict
}


-(void)allEventsGet:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp
{
    
    NSString *jsonString                    = [Utility dictToJSON:tData];
    
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"http://%@/min/ajax/gametags/%@",self.ipAddress,jsonString]  ];
    urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = EVENT_GET_TAGS;
    encoderConnection.timeStamp             = aTimeStamp;
    encoderConnection.extra                 = [tData objectForKey:@"event"];// This is the key that will be used when making the dict
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
    urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = STOP_EVENT;
    encoderConnection.timeStamp             = aTimeStamp;
}

-(void)pauseEvent:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp
{
    
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"http://%@/min/ajax/encpause/",self.ipAddress]  ];
    urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = PAUSE_EVENT;
    encoderConnection.timeStamp             = aTimeStamp;
}

-(void)resumeEvent:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp
{
    
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"http://%@/min/ajax/encresume/",self.ipAddress]  ];
    urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    encoderConnection.connectionType        = RESUME_EVENT;
    encoderConnection.timeStamp             = aTimeStamp;
}


-(void)startEvent:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp
{
    
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



-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{

    NSString * connectionType   = connection.connectionType;
    NSData * finishedData       = connection.cumulatedData;
    NSString * extra            = connection.extra;
    
    
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
        [self startResponce:    finishedData];
    } else if ([connectionType isEqualToString: PAUSE_EVENT]) {
        [self pauseResponce:     finishedData];
    }  else if ([connectionType isEqualToString: RESUME_EVENT]) {
        [self resumeResponce:    finishedData];
    } else if ([connectionType isEqualToString: MAKE_TAG]) {
        [self makeTagResponce:    finishedData];
    } else if ([connectionType isEqualToString: MAKE_TELE_TAG]) {
        [self makeTagResponce:    finishedData];
    } else if ([connectionType isEqualToString: MODIFY_TAG]) {
        [self modTagResponce:    finishedData];
    } else if ([connectionType isEqualToString: CAMERAS_GET]) {
        [self camerasGetResponce:    finishedData];
    } else if ([connectionType isEqualToString: EVENT_GET_TAGS]) {
        //NSLog(@"%@",[[NSString alloc] initWithData:finishedData encoding:NSUTF8StringEncoding]);
        
        [self eventTagsGetResponce:finishedData eventNameKey:extra];
    }else if ([connectionType isEqualToString: DELETE_EVENT]){
        [self deleteEventResponse: finishedData];
    }
    
    if (isAuthenticate && 1 && _isBuild && isTeamsGet && !_isReady){
        _isReady         = YES;
        if (!statusMonitor) statusMonitor   = [[EncoderStatusMonitor alloc]initWithEncoder:self]; // Start watching the status when its ready
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_THIS_ENCODER_IS_READY object:self];
        
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
    isWaitiing = NO;
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
    
    NSDictionary    * results;
    
    //NSDictionary    * results =[Utility JSONDatatoDict:data];
    
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

-(void)teamsResponse:(NSData *)data
{
    NSDictionary    * results =[Utility JSONDatatoDict:data];
    
    if([results isKindOfClass:[NSDictionary class]])
    {
        if (![[results objectForKey:@"success"]boolValue]) {
            PXPLog(@"Encoder Error!");
            PXPLog(@"  reason: %@",results[@"msg"]);
        }
        self.encoderTeams      = [results objectForKey:@"teams"];
//            self.playerData = [results objectForKey:@"teamsetup"];
        self.encoderLeagues     = [results objectForKey:@"leagues"];
    }
    isTeamsGet = YES;
}

-(void)modTagResponce:(NSData *)data
{
    
    NSDictionary    * results =[Utility JSONDatatoDict:data];
    if([results isKindOfClass:[NSDictionary class]])    {
        if ([results objectForKey:@"id"]) {
            //NSString * tagId = [[results objectForKey:@"id"]stringValue];
            PXPLog(@"Tag Modification succeded: %@", @"");

            //[_event.tags setObject:results forKey:tagId];
            //[[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_TAG_MODIFIED object:nil userInfo:results];
        }
    
    }
    
}

-(void)makeTagResponce:(NSData *)data
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
            // [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_TAG_RECEIVED object:newTag userInfo:results];
        }
    }
}

-(void)eventTagsGetResponce:(NSData *)data eventNameKey:(NSString*)eventName
{
    NSDictionary    * results =[Utility JSONDatatoDict:data];
    
    if (results){
        NSDictionary    * tags = [results objectForKey:@"tags"];
        NSMutableDictionary *tagsDictionary = [NSMutableDictionary dictionary];
        if (tags) {
            for (NSString *idKey in [tags allKeys]) {
                if ([tags[idKey] objectForKey:@"id"]) {
                    Tag *newTag = [[Tag alloc] initWithData: tags[idKey]];
                    newTag.feeds = self.encoderManager.feeds;
                    [tagsDictionary addEntriesFromDictionary:@{idKey:newTag}];
                }
                
            }
            
            _event.tags =tagsDictionary;
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_TAGS_ARE_READY object:nil];
        }
    }
    
}

-(void)deleteEventResponse: (NSData *) data{
    NSDictionary    * results =[Utility JSONDatatoDict:data];
    
    if (results){
        NSLog( @"The results");
        PXPLog(@"The event has been deleted %@" , results);
    }
    
}
-(void)camerasGetResponce:(NSData *)data
{
    NSDictionary    * results =[Utility JSONDatatoDict:data];
    NSArray * list = [results[@"camlist"]allValues];
    _cameraCount = 0;
    for (NSDictionary *dic in list) {
        if ([dic[@"cameraPresent"]boolValue])_cameraCount++;
    }
 //   _cameraCount = [((NSDictionary*)[results objectForKey:@"camlist"]) count];
    
    PXPLog(@"%@ has %@ cameras",self.name ,[NSString stringWithFormat:@"%ld",(long)_cameraCount ]);
}

#pragma mark - Master Responce

-(void)stopResponce:(NSData *)data
{
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_LIVE_EVENT_STOPPED object:self];
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
                  
                    Event * anEvent = [[Event alloc]initWithDict:(NSDictionary *)value isLocal:NO];

                    
                    
                    if (anEvent.live){ // live event FOUND!
                        _liveEvent = anEvent;
                        [pool setObject:anEvent forKey:anEvent.name];
                        self.allEvents      = [pool copy];
                        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_LIVE_EVENT_FOUND object:self];
                        
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
            
            self.allEvents      = [pool copy];
            
        }
    }
    _isBuild = YES;
}



#pragma mark - Queue methods
// Queue methods
-(void)addToQueue:(EncoderCommand *)obj
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
-(void)removeFromQueue:(EncoderCommand *)obj
{
    NSNumber * priKey =[[NSNumber alloc] initWithInt:obj.priority];
    [[queue objectForKey:priKey]removeObject:obj];
    
}

-(EncoderCommand *)getNextInQueue
{
    // Sorted keys
    NSMutableArray * allKeys =  [NSMutableArray arrayWithArray:[[queue allKeys] sortedArrayUsingComparator:^(id obj1, id obj2) {
        return [obj1 intValue] - [obj2 intValue];
    }]];
    
    NSNumber * thePriorityKey = [allKeys lastObject];
    while ([queue count]!=0 && ((NSMutableArray *)[queue objectForKey:thePriorityKey]).count == 0 ) {
        [queue removeObjectForKey:thePriorityKey];
        [allKeys removeLastObject];
        thePriorityKey = [allKeys lastObject];
    }
    
    EncoderCommand * nextObj = [((NSMutableArray *)[queue objectForKey:thePriorityKey]) objectAtIndex:0];
    
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
    NSString * txt = [NSString stringWithFormat:@" %@(%@): %d - %@   - %@",self.name,version,self.status,self.event.name,self.event.eventType  ];
    return txt;
}


-(NSString*)name
{
    return _name;
}

-(void)setName:(NSString *)name
{
    [self willChangeValueForKey:@"name"];
    _name = name;
    [self didChangeValueForKey:@"name"];
}


-(void)dealloc
{
    isAlive = NO;
}

@end
