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

#define GET_NOW_TIME [ NSNumber numberWithDouble:CACurrentMediaTime()]




// HELPER CLASS



// catagory  // catagory  // catagory  // catagory  // catagory  // catagory  // catagory  // catagory  // catagory

@interface NSURLConnection (Context)

@property (nonatomic,strong)    NSNumber        * timeStamp;
@property (nonatomic,strong)    NSMutableData   * cumulatedData;
@property (nonatomic,strong)    NSString        * connectionType;

-(NSNumber*)timeStamp;
-(void)setTimeStamp:(NSNumber*)time;

@end

@implementation NSURLConnection (Context)

@dynamic timeStamp;
@dynamic cumulatedData;
@dynamic connectionType;

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


@end





// END HELPER CLASSS


@implementation Encoder
{

}



@synthesize name;
@synthesize ipAddress;
@synthesize version;
@synthesize URL;
@synthesize customerID;

@synthesize log;

@synthesize authenticated   = _authenticated;
@synthesize status          = _status;
@synthesize bitrate         = _bitrate;     // To be used with KVO
@synthesize event           = _event;
@synthesize eventType       = _eventType;
@synthesize eventData       = _eventData;
@synthesize feeds           = _feeds;
@synthesize isMaster        = _isMaster;
@synthesize allEventData    = _allEventData;


@synthesize teams           = _teams;
@synthesize playerData      = _playerData;
@synthesize league          = _league;




-(id)initWithIP:(NSString*)ip
{
    self = [super init];
    if (self){
        self.ipAddress  = ip;
        _authenticated  = NO;
        timeOut         = 15.0f;
        queue           = [[NSMutableDictionary alloc]init];
        isWaitiing      = NO;
        log             = [NSMutableString stringWithString:@"Encoder Log: \r"];
        version         = @"?";
        statusMonitor   = [[EncoderStatusMonitor alloc]initWithEncoder:self];
        _isMaster       = NO;
    }
    return self;
}


-(void)setEvent:(NSString *)event
{
    // Is it the same event or the event is not on the encoder
    if ([event isEqualToString:_event]){
        return;
    }

    [self willChangeValueForKey:@"event"];
    
    NSArray         * events = [rawEncoderData objectForKey:@"events"];
    for(NSDictionary* dict in events)
    {
        if([dict isKindOfClass:[NSDictionary class]]  && [dict[@"name"] isEqualToString: event])
        {
            self.eventData = dict;
            
            if ([dict[@"vid"] isKindOfClass:[NSString class]]) { // This is for backwards compatibility
            
               // _feeds = @{ @"s1":@{@"lq":dict[@"vid"]} };
                // this creates a feed object from just a string with it  source named s1
               Feed * theFeed =  [[Feed alloc]initWithURLString:dict[@"vid"] quality:0];
                _feeds = @{ @"s1":theFeed};
                
            }  else if ([dict[@"vid"] isKindOfClass:[NSDictionary class]]){
                NSMutableDictionary * collect = [[NSMutableDictionary alloc]init];
                
                for (id key in dict[@"vid"])
                {
                    if ([key isEqualToString:@"url"]) continue;
                    NSDictionary * vidDict      = dict[@"vid"];
                    NSDictionary * qualities    = [vidDict objectForKey:key];
                    
                    Feed * createdFeed = [[Feed alloc]initWithURLDict:qualities];
                    createdFeed.sourceName = key;
                    
                    [collect setObject:[[Feed alloc]initWithURLDict:qualities] forKey:key];
                }
                
                _feeds = [collect copy];
                
                
            } else {
                NSLog(@"JSON ERROR");
            }
            [self willChangeValueForKey:@"eventType"];
            _eventType = [dict objectForKey:@"sport"];
            [self didChangeValueForKey:@"eventType"];
            break;
        }
    }
    _event =  event;
   [self didChangeValueForKey:@"event"];
    
}



-(NSString*)event
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
    if (queue.count == 1) {
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
        [controller performSelector:sel withObject:nextInQueue.tagData withObject:nextInQueue.timeStamp];
        isWaitiing = YES;
        
        
//        [log appendFormat:@"%@  %@ - "
//                        ,[NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle]
//                        ,NSStringFromSelector(currentCommand.selector)
//                        ];
    }
    
}


// Commands

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
    [self issueCommand:BUILD        priority:2 timeoutInSec:15 tagData:nil timeStamp:GET_NOW_TIME];
    [self issueCommand:TEAMS_GET    priority:1 timeoutInSec:15 tagData:nil timeStamp:GET_NOW_TIME];
}


-(void)authenticate:(NSMutableDictionary *)data timeStamp:(NSNumber *)aTimeStamp
{

    if ([Utility sumOfVersion:self.version] <= [Utility sumOfVersion:OLD_VERSION]){
        [self willChangeValueForKey:@"authenticated"];
        _authenticated  = YES;
        [self didChangeValueForKey:@"authenticated"];
        isWaitiing      = NO;
        [self removeFromQueue:currentCommand];
        [self runNextCommand]; // this line is for testing
        return;
    }
    
    
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"http://%@/min/ajax/auth/?id=%@",self.ipAddress,customerID]  ];
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
//    encoderConnection.accessibilityValue    = SHUTDOWN;
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
//    encoderConnection.accessibilityValue    = MAKE_TAG;
    encoderConnection.connectionType        = MAKE_TAG;
    encoderConnection.timeStamp             = aTimeStamp;
}

-(void)modifyTag:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp
{
    NSString *encodedName = [Utility encodeSpecialCharacters:[tData objectForKey:@"name"]];
    
    //over write name and add request time
    [tData addEntriesFromDictionary:@{
                                      @"name"           : encodedName,
                                      @"requesttime"    : [NSString stringWithFormat:@"%f",CACurrentMediaTime()]
                                      }];
    
    NSString *jsonString                    = [Utility dictToJSON:tData];
    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"http://%@/min/ajax/tagmod/%@",self.ipAddress,jsonString]  ];
    urlRequest                              = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:currentCommand.timeOut];
    encoderConnection                       = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
//    encoderConnection.accessibilityValue    = MODIFY_TAG;
    encoderConnection.connectionType        = MODIFY_TAG;
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


// Connections // Connections// Connections// Connections// Connections// Connections// Connections// Connections// Connections// Connections// Connections// Connections// Connections
// Connections // Connections// Connections// Connections// Connections// Connections// Connections// Connections// Connections// Connections// Connections// Connections// Connections
// Connections // Connections// Connections// Connections// Connections// Connections// Connections// Connections// Connections// Connections// Connections// Connections// Connections


-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
}


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
    
    
    
    if ([connectionType isEqualToString: AUTHENTICATE]){
        [self authenticateResponse: finishedData];
    }  else if ([connectionType isEqualToString: VERSION]){
        [self versionResponse:      finishedData];
    }  else if ([connectionType isEqualToString: BUILD]){
        [self getAllEventsResponse: finishedData];
    }  else if ([connectionType isEqualToString: TEAMS_GET]) {
        [self teamsResponse:finishedData];
    }
   
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_ENCODER_CONNECTION_FINISH object:self userInfo:@{@"responce":finishedData}];
    
    
    NSLog(@"Connection finished: %@",connectionType);
    if ([connectionType isEqualToString:SHUTDOWN]){
//        [self shuttingDown];
        __weak Encoder * weakSelf = self;
        [statusMonitor startShutdownChecker:^(void){
            NSLog(@"Server has shutdown");
            if (weakSelf.isMaster) [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_ENCODER_MASTER_HAS_FALLEN object:weakSelf userInfo:nil];
         }];
    }
    isWaitiing = NO;
    [self removeFromQueue:currentCommand];
    [self runNextCommand]; // this line is for testing

}


-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%@ FAIL %@ \n%@",self.name,[connection originalRequest],connection.connectionType);
    isWaitiing = NO;
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_ENCODER_CONNECTION_FINISH object:self userInfo:nil];//
    [self removeFromQueue:currentCommand];
    [self runNextCommand];

    [log appendString:@"FAIL! \\n"];
}




/**
 *  This method checks to see if the user has access to this encoder
 *  once complete it will set to authenticated
 *  @param data reponce from server
 */
-(void)authenticateResponse:(NSData *)data
{
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

    
}



/**
 *  This gets the version of the linked Encoder
 *
 *  @param data responce json from encoder
 */
-(void)versionResponse:(NSData *)data
{
    NSDictionary    * results;
    if(NSClassFromString(@"NSJSONSerialization"))
    {
        NSError *error = nil;
        id object = [NSJSONSerialization
                     JSONObjectWithData:data
                     options:0
                     error:&error];
        
        if([object isKindOfClass:[NSDictionary class]])
        {
            results = object;
            version = (NSString *)[results objectForKey:@"version"] ;

        }
    }
}

/**
 *  This gets the version of the linked Encoder
 *
 *  @param data responce json from encoder
 */
-(void)teamsResponse:(NSData *)data
{
    
    
    
    NSDictionary    * results =[Utility JSONDatatoDict:data];
    if(NSClassFromString(@"NSJSONSerialization"))
    {
        NSError *error = nil;
        id object = [NSJSONSerialization
                     JSONObjectWithData:data
                     options:0
                     error:&error];
        
        if([object isKindOfClass:[NSDictionary class]])
        {
            results     = object;
            self.teams      = [results objectForKey:@"teams"];
            self.playerData = [results objectForKey:@"teamsetup"];
            self.league     = [results objectForKey:@"leagues"];
        }
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_THIS_ENCODER_IS_READY object:self];
}

/**
 *  This class is what buils the rest of the data from the encoder
 *
 *
 *  @param data <#data description#>
 */
-(void)getAllEventsResponse:(NSData *)data
{
    
    if(NSClassFromString(@"NSJSONSerialization"))
    {
        NSError *error = nil;
        id object = [NSJSONSerialization
                     JSONObjectWithData:data
                     options:0
                     error:&error];
        
        if([object isKindOfClass:[NSDictionary class]])
        {
            
            rawEncoderData                  = object;
            
            NSArray         * events        = [rawEncoderData objectForKey:@"events"];
            NSMutableArray  * pool          = [[NSMutableArray alloc]init];
            NSMutableArray  * dataPool          = [[NSMutableArray alloc]init];
            
            @try {
                NSEnumerator *enumerator = [events objectEnumerator];
                id value;
                
                while ((value = [enumerator nextObject])) {
                    NSDictionary * dict = value;
                    if ([dict objectForKey:@"hid"]) {
                        [pool addObject:[dict objectForKey:@"hid"]];
                        [dataPool addObject:dict];
                    }
                    
                    if ([dict objectForKey:@"live"]){
                        /////
                        self.event = @"live";
                        if ([dict[@"live"] isKindOfClass:[NSString class]]) { // This is for backwards compatibility
                            
                            // _feeds = @{ @"s1":@{@"lq":dict[@"vid"]} };
                            // this creates a feed object from just a string with it  source named s1
                            Feed * theFeed =  [[Feed alloc]initWithURLString:dict[@"live"] quality:0];
                            _feeds = @{ @"s1":theFeed};
                            
                        }  else if ([dict[@"live"] isKindOfClass:[NSDictionary class]]){
                            NSMutableDictionary * collect = [[NSMutableDictionary alloc]init];
                            
                            for (id key in dict[@"live"])
                            {
                                if ([key isEqualToString:@"url"])continue;
                                NSDictionary * qualities = [((NSDictionary *)dict[@"live"]) objectForKey:key];
                                [collect setObject:[[Feed alloc]initWithURLDict:qualities] forKey:key];
                            }
                            
                            _feeds = [collect copy];
                            
                            
                        } else {
                            NSLog(@"JSON ERROR");
                        }
                        

                        
                    }
                    
                    
                }
            }
            @catch (NSException *exception) {
                NSLog(@"error parsing json data: %@",exception);
            }
            @finally {
           
            }
            
            self.allEvents      = [pool copy];
            self.allEventData   = [dataPool copy];
            
            if (_feeds == nil) _feeds     = @{};
        }
    }

}



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
    
    EncoderCommand * nextObj = [((NSMutableArray *)[queue objectForKey:thePriorityKey]) lastObject];

    return nextObj;
}




-(void)cancelCommand
{
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
}

-(NSDictionary*)feeds
{
    return _feeds;
}

-(void)setFeeds:(NSDictionary *)feeds
{
    if ([_feeds count]==0 && !feeds) return;
    
    _feeds = feeds;
    if(_feeds == nil) _feeds = @{};
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_ENCODER_FEEDS_UPDATED object:self];
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


// This will show name and status
-(NSString*)description
{
    NSString * txt = [NSString stringWithFormat:@" %@: %d - %@   - %@",self.name,self.status,self.event,self.eventType  ];

    
    
    
    return txt;
}

@end
