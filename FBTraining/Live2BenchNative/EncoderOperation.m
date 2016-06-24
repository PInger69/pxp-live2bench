//
//  EncoderOperation.m
//  Live2BenchNative
//
//  Created by dev on 2015-10-13.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "EncoderOperation.h"
#import "Tag.h"
#import "PxpURLProtocol.h"
#import "MockURLProtocol.h"
#import "Feed.h"
#import "Event.h"
#import "TagProtocol.h"
#import "TagProxy.h"

#define EO_DEFAULT_TIMEOUT 5
#define GET_NOW_TIME_STRING [NSString stringWithFormat:@"%f",CACurrentMediaTime()]

@implementation EncoderOperation
{
    
    BOOL _isFinished;
    BOOL _isExecuting;
}


#pragma NSOperation Abstract Methods


- (instancetype)init
{
    self = [super init];
    if (self) {
        _isExecuting               = NO;
        _isFinished                = NO;
        
    }
    return self;
}



-(BOOL)isConcurrent
{
    return YES;
}
- (void)setExecuting:(BOOL)isExecuting {
    if (isExecuting != _isExecuting) {
        [self willChangeValueForKey:@"isExecuting"];
        _isExecuting = isExecuting;
        [self didChangeValueForKey:@"isExecuting"];
    }
}

- (BOOL)isExecuting
{
    return _isExecuting;
}

- (void)setFinished:(BOOL)isFinished
{
    [self willChangeValueForKey:@"isFinished"];
    // Instance variable has the underscore prefix rather than the local
    _isFinished = isFinished;
    [self didChangeValueForKey:@"isFinished"];
}

- (BOOL)isFinished
{
    return _isFinished || [self isCancelled];
}

-(void)start
{
    if ([self isCancelled]) {
        [self setFinished:YES];

    }
    [self setExecuting:YES];
    
    NSURLSessionConfiguration *sessionConfig        = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.allowsCellularAccess              = NO;
    sessionConfig.timeoutIntervalForRequest         = 10;
    sessionConfig.timeoutIntervalForResource        = 10;
    sessionConfig.HTTPMaximumConnectionsPerHost     = 1;
    sessionConfig.protocolClasses                   = @[[PxpURLProtocol class],
                                                        [MockURLProtocol class]
                                                        ];
    
    self.session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
    [[self.session dataTaskWithRequest:self.request]resume];
}


- (void)cancel
{
    [super cancel];
//    if ([self isExecuting]) {
        [self setExecuting:NO];
        [self setFinished:YES];
//    }
}

#pragma EncoderOperation Abstract Methods

- (instancetype)initEncoder:(id <EncoderProtocol>)aEncoder data:(NSDictionary*)aData
{
    self = [super init];
    if (self) {
        self.argData    = aData;
        self.encoder    = (Encoder*)aEncoder;
        self.timeStamp  = [NSNumber numberWithDouble:CACurrentMediaTime()];
        self.request    = [self buildRequest:aData]; // this build request is overrided
    }
    return self;
}

// The is meant to overriden
-(NSURLRequest*)buildRequest:(NSDictionary*)aData
{
    NSURL * checkURL = [NSURL URLWithString:   [NSString stringWithFormat:@"%@://%@/min/ajax/encresume/",self.encoder.urlProtocol,self.encoder.ipAddress]  ];
    return   [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];

}

// this takes the json data and then converts the data so that it will be added the the encoder
-(void)parseDataToEncoder:(NSData*)data
{
    if (self.onRequestComplete) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.onRequestComplete(data,self);
        });
    }
    
    NSDictionary * checkIfFail = [Utility JSONDatatoDict:data];
    if ([checkIfFail[@"success"]intValue] == 0) {
        self.success = NO;
    } else {
        self.success = YES;
    }
    
}




#pragma mark - NSURLSession Methods
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
//    NSLog(@"Receiving...");
    if (self.cumulatedData == nil){
        self.cumulatedData = [NSMutableData dataWithData:data];
    } else {
        [self.cumulatedData appendData:data];
    }
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
//    NSLog(@"Connection finished");
    

    if (error) {
        self.error = error;
         NSLog(@"Error %@",error);
        self.success = NO;
    }
    
    [self parseDataToEncoder:self.cumulatedData];

    [self setExecuting:NO];
    [self setFinished:YES];
}



@end





//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////    Operations for encoder
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@implementation EncoderOperationGetVersion
-(NSURLRequest*)buildRequest:(NSDictionary*)aData
{
    NSURL * checkURL = [NSURL URLWithString: [NSString stringWithFormat:@"%@://%@/min/ajax/version",self.encoder.urlProtocol,self.encoder.ipAddress]  ];
    return [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:(self.timeout)?self.timeout:DEFAULT_TIMEOUT];
}

-(void)parseDataToEncoder:(NSData*)data
{
    [super parseDataToEncoder:data];
    [self.encoder.parseModule parse:data mode:ParseModeVersionCheck for:self.encoder];
}

@end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation EncoderOperationAuthenticate

-(instancetype)initEncoder:(id<EncoderProtocol>)aEncoder customerID:(NSString *)customerID
{
    self = [super initEncoder:aEncoder data:@{@"id":customerID}];
    if (self) {

    }
    return self;
}


-(NSURLRequest*)buildRequest:(NSDictionary*)aData
{
    
    NSString * json = [Utility dictToJSON:aData];
    NSURL * checkURL = [NSURL URLWithString: [NSString stringWithFormat:@"%@://%@/min/ajax/auth/%@",self.encoder.urlProtocol,self.encoder.ipAddress,json]  ];
    return [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:(self.timeout)?self.timeout:DEFAULT_TIMEOUT];
}

-(void)parseDataToEncoder:(NSData*)data
{
    [super parseDataToEncoder:data];
    [self.encoder.parseModule parse:data mode:ParseModeVersionCheck for:self.encoder];
}

@end


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation EncoderOperationGetPastEvents
-(NSURLRequest*)buildRequest:(NSDictionary*)aData
{
    NSURL * checkURL = [NSURL URLWithString: [NSString stringWithFormat:@"%@://%@/min/ajax/getpastevents",self.encoder.urlProtocol,self.encoder.ipAddress]  ];
    return [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:(self.timeout)?self.timeout:EO_DEFAULT_TIMEOUT];
}

-(void)parseDataToEncoder:(NSData*)data
{

    [self.encoder.parseModule parse:data mode:ParseModeGetPastEvents for:self.encoder];
        [super parseDataToEncoder:data];
}

@end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation EncoderOperationGetEventTags
-(NSURLRequest*)buildRequest:(NSDictionary*)aData
{
    
//    {
//        device = "6FF220F1-E4CE-4FE8-9F2F-179FCD9750D4";
//        event = live;
//        requesttime = "158103.0717805834";
//        user = ae1e7198bc3074ff1b2e9ff520c30bc1898d038e;
//    }
   NSString *jsonString                    = [Utility dictToJSON:aData];
    NSURL * checkURL = [NSURL URLWithString: [NSString stringWithFormat:@"%@://%@/min/ajax/gametags/%@",self.encoder.urlProtocol,self.encoder.ipAddress,jsonString]  ];
    return [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:(self.timeout)?self.timeout:EO_DEFAULT_TIMEOUT];
}

-(void)parseDataToEncoder:(NSData*)data
{
    
    [self.encoder.parseModule parse:data mode:ParseModeGetEventTags for:self.encoder];
    [super parseDataToEncoder:data];
}

@end


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Delete Event from server
@implementation EncoderOperationDeleteEvent

-(NSURLRequest*)buildRequest:(NSDictionary*)aData
{
    NSURL * checkURL =[NSURL URLWithString:   [NSString stringWithFormat:@"%@://%@/min/ajax/evtdelete/?name=%@&event=%@",
                                               self.encoder.urlProtocol,
                                               self.encoder.ipAddress,
                                               [aData objectForKey:@"name"],
                                               [aData objectForKey:@"hid"]]  ];
    
    // if the event is not downloaded then it needs to be deleted
    // if the event is playing it needs to stop
    
   
    return [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:(self.timeout)?self.timeout:EO_DEFAULT_TIMEOUT];
}

-(void)parseDataToEncoder:(NSData*)data
{
    [super parseDataToEncoder:data];
    [self.encoder.parseModule parse:data mode:ParseModeDeleteEvent for:self.encoder];
}

@end


@implementation EncoderOperationStart
-(NSURLRequest*)buildRequest:(NSDictionary*)aData
{
    NSString * homeTeam = [aData objectForKey:@"homeTeam"];
    NSString * awayTeam = [aData objectForKey:@"awayTeam"];
    NSString * league   = [aData objectForKey:@"league"];
    
    NSString *unencoded = [NSString stringWithFormat:@"%@://%@/min/ajax/encstart/?hmteam=%@&vsteam=%@&league=%@&time=%@&quality=%@",
                           self.encoder.urlProtocol,
                           self.encoder.ipAddress,
                           homeTeam,
                           awayTeam,
                           league,
                           [NSString stringWithFormat:@"%@",self.timeStamp],
                           @"high"];
    
    unencoded = [unencoded stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL * checkURL                        = [NSURL URLWithString:unencoded  ];
    
    
    
    return [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:(self.timeout)?self.timeout:EO_DEFAULT_TIMEOUT];
}
-(void)parseDataToEncoder:(NSData*)data
{
    [super parseDataToEncoder:data];
    [self.encoder.parseModule parse:data mode:ParseModeStart for:self.encoder];
}
@end




@implementation EncoderOperationStop
-(NSURLRequest*)buildRequest:(NSDictionary*)aData
{
    
    NSError     * error;
    NSString    * jsonData = [Utility dictToJSON:@{@"requesttime":self.timeStamp}];
    NSURL       * checkURL = [NSURL URLWithString:   [NSString stringWithFormat:@"%@://%@/min/ajax/encstop/%@",self.encoder.urlProtocol,self.encoder.ipAddress,jsonData]  ];
    
    if (error) {
        PXPLog(@"Error converting data to stop event");
        return nil;
    }
    return [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:(self.timeout)?self.timeout:EO_DEFAULT_TIMEOUT];
}

-(void)parseDataToEncoder:(NSData*)data
{
    [super parseDataToEncoder:data];
    [self.encoder.parseModule parse:data mode:ParseModeStop for:self.encoder];
}
@end



/**
 This operation pauses the current live event. No data needs to be sent
 */
@implementation EncoderOperationPause
-(NSURLRequest*)buildRequest:(NSDictionary*)aData
{
    NSURL * checkURL = [NSURL URLWithString:   [NSString stringWithFormat:@"%@://%@/min/ajax/encpause/",self.encoder.urlProtocol,self.encoder.ipAddress]  ];
    return [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:(self.timeout)?self.timeout:EO_DEFAULT_TIMEOUT];

}
-(void)parseDataToEncoder:(NSData*)data
{
    [super parseDataToEncoder:data];
    [self.encoder.parseModule parse:data mode:ParseModePause for:self.encoder];
}
@end



/**
    This operation resumes the current live event. No data needs to be sent
 */
@implementation EncoderOperationResume
-(NSURLRequest*)buildRequest:(NSDictionary*)aData
{
    
    NSURL * checkURL = [NSURL URLWithString:   [NSString stringWithFormat:@"%@://%@/min/ajax/encresume/",self.encoder.urlProtocol,self.encoder.ipAddress]  ];
    return [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:(self.timeout)?self.timeout:EO_DEFAULT_TIMEOUT];

}

-(void)parseDataToEncoder:(NSData*)data
{
    [super parseDataToEncoder:data];
    [self.encoder.parseModule parse:data mode:ParseModeResume for:self.encoder];
}
@end


/**
 This operation resumes the current live event. No data needs to be sent
 */
@implementation EncoderOperationShutdown
-(NSURLRequest*)buildRequest:(NSDictionary*)aData
{
    NSURL * checkURL = [NSURL URLWithString:   [NSString stringWithFormat:@"%@://%@/min/ajax/encshutdown",self.encoder.urlProtocol,self.encoder.ipAddress]  ];
    return [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:(self.timeout)?self.timeout:EO_DEFAULT_TIMEOUT];
}

-(void)parseDataToEncoder:(NSData*)data
{
    [super parseDataToEncoder:data];
// There is nothing for the shutdown pars right now
}
@end


@implementation EncoderOperationModTag


- (instancetype)initEncoder:(id <EncoderProtocol>)aEncoder tag:(id <TagProtocol>)tag
{
    self = [super init];
    if (self) {
        
        
        
        self.argData    = @{};
        self.encoder    = (Encoder*)aEncoder;
        
        if ([self.tag isKindOfClass:[TagProxy class]]) {
            for (NSOperation * ops in [aEncoder operationQueue].operations) {
                if ([ops isKindOfClass:[EncoderOperationModTag class]] && ((EncoderOperationModTag*)ops).tag == tag) {
                    return nil;
                }
            }
            
        }
        self.timeStamp  = [NSNumber numberWithDouble:CACurrentMediaTime()];
        self.tag = tag;
        self.request    = [self buildRequest:self.argData ]; // this build request is overrided
    }
    return self;
}

- (instancetype)initEncoder:(id <EncoderProtocol>)aEncoder data:(NSDictionary*)aData tag:(id <TagProtocol>)tag
{
    self = [super init];
    if (self) {
        self.argData    = aData;
        self.encoder    = (Encoder*)aEncoder;
        self.timeStamp  = [NSNumber numberWithDouble:CACurrentMediaTime()];
        self.tag = tag;
        
    }
    return self;
}


-(void)start
{
    
    
    if ([self isCancelled]) {
        [self setFinished:YES];
        
    }
    [self setExecuting:YES];
    
    
    self.request    = [self buildRequest:self.argData]; // this build request is overrided
    
    NSURLSessionConfiguration *sessionConfig        = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.allowsCellularAccess              = NO;
    sessionConfig.timeoutIntervalForRequest         = 10;
    sessionConfig.timeoutIntervalForResource        = 10;
    sessionConfig.HTTPMaximumConnectionsPerHost     = 1;
    sessionConfig.protocolClasses                   = @[[PxpURLProtocol class],
                                                        [MockURLProtocol class]
                                                        ];
    
    self.session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
    [[self.session dataTaskWithRequest:self.request]resume];
}


-(NSURLRequest*)buildRequest:(NSDictionary*)aData
{
    NSError     * error;
    
    
//    NSMutableDictionary *mData = [[self.tag makeTagData]mutableCopy];
    NSMutableDictionary *mData = [[self.tag rawData]mutableCopy];
    
    if (self.tag.isLive){
        mData[@"event"] = LIVE_EVENT;
    }
    if (self.tag.durationID){
        mData[@"dtagid"] = self.tag.durationID;
    }
    
    
    [mData removeObjectForKey:@"url"];
//    [mData removeObjectForKey:@"duration"];
    NSString    * jsonData = [Utility dictToJSON:mData];
    
    if (error) {
        PXPLog(@"Error converting data to dowload Clip event");
        return nil;
    }
    
    
    NSURL * checkURL = [NSURL URLWithString:   [NSString stringWithFormat:@"%@://%@/min/ajax/tagmod/%@",self.encoder.urlProtocol,self.encoder.ipAddress, jsonData ]];
    return [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:(self.timeout)?self.timeout:EO_DEFAULT_TIMEOUT];
    
}

-(void)parseDataToEncoder:(NSData*)data
{
    [super parseDataToEncoder:data];
    
    
    
   NSDictionary * dict =  [self.encoder.parseModule parse:data mode:ParseModeTagMod for:self.encoder];
    
    
    NSLog(@"%s",__FUNCTION__);

}

// its ready if its a real tag  or if its a proxy with a real tag inside;
-(BOOL)isReady
{
    // if its not a proxy tag then its fine
    if ( ![self.tag isKindOfClass:[TagProxy class]]  ) {
        return YES;
    } else if ([self.tag isKindOfClass:[TagProxy class]]) {
        return [((TagProxy *) self.tag) hasTag];
    } else {
        return NO;
    }
}


@end


@implementation EncoderOperationCloseTag


- (instancetype)initEncoder:(id <EncoderProtocol>)aEncoder tag:(Tag*)tag
{
    self = [super init];
    if (self) {
        self.argData    = @{};
        self.encoder    = (Encoder*)aEncoder;
        self.timeStamp  = [NSNumber numberWithDouble:CACurrentMediaTime()];
        self.tag = tag;
        self.request    = [self buildRequest:self.argData ]; // this build request is overrided
    }
    return self;
}

-(NSURLRequest*)buildRequest:(NSDictionary*)aData
{
    NSError     * error;
    
    NSMutableDictionary *mData = [[self.tag makeTagData]mutableCopy];
    
    if (self.tag.isLive){
        mData[@"event"] = LIVE_EVENT;
    }
    if (self.tag.durationID){
        mData[@"dtagid"] = self.tag.durationID;
    }
    
    mData[@"time"] =  mData[@"closetime"];
    [mData removeObjectForKey:@"url"];
    [mData removeObjectForKey:@"url_2"];
    [mData removeObjectForKey:@"duration"];
    NSString    * jsonData = [Utility dictToJSON:mData];
    
    if (error) {
        PXPLog(@"Error converting data to dowload Clip event");
        return nil;
    }
    
    
    NSURL * checkURL = [NSURL URLWithString:   [NSString stringWithFormat:@"%@://%@/min/ajax/tagmod/%@",self.encoder.urlProtocol,self.encoder.ipAddress, jsonData ]];
    return [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:(self.timeout)?self.timeout:EO_DEFAULT_TIMEOUT];
    
}

-(void)parseDataToEncoder:(NSData*)data
{
    [super parseDataToEncoder:data];
    
    
    
    NSDictionary * dict =  [self.encoder.parseModule parse:data mode:ParseModeTagMod for:self.encoder];
    
    if ([dict[@"success"]intValue]){
    
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_TOAST object:nil userInfo:@{@"colour":dict[@"colour"],
                                                                                                    @"msg":dict[@"name"],
                                                                                                    @"type":[NSNumber numberWithUnsignedInteger:ARTagCreated]}];
    }
    
    NSLog(@"%s",__FUNCTION__);
    
}
@end


@implementation EncoderOperationMakeMP4fromTag
-(NSURLRequest*)buildRequest:(NSDictionary*)aData
{
    NSError     * error;
    NSString    * jsonData = [Utility dictToJSON:aData];
    
    if (error) {
        PXPLog(@"Error converting data to dowload Clip event");
        return nil;
    }
    
    
    NSURL * checkURL = [NSURL URLWithString:   [NSString stringWithFormat:@"%@://%@/min/ajax/tagmod/%@",self.encoder.urlProtocol,self.encoder.ipAddress, jsonData ]];
    return [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:(self.timeout)?self.timeout:EO_DEFAULT_TIMEOUT];
    
}

-(void)parseDataToEncoder:(NSData*)data
{
    [super parseDataToEncoder:data];
    [self.encoder.parseModule parse:data mode:ParseModeTagMakeMP4 for:self.encoder];
}
@end




#pragma mark - Make Tag

@implementation EncoderOperationMakeTag
-(NSURLRequest*)buildRequest:(NSDictionary*)aData
{

    self.timeout = 60;
//    NSString *period = [aData objectForKey:@"period"];

//    NSString *tagTime = [data objectForKey:@"time"];// just to make sure they are added

    
    
    //over write name and add request time

    
//    aslfkj
    
    // Make Proxy Tag for the event the attach when complete or sync
    
    
    
    
    // This is the starndard info that is collected from the encoder
    NSMutableDictionary * tagData = [NSMutableDictionary new];
    [tagData addEntriesFromDictionary:aData];
    [tagData addEntriesFromDictionary:@{
                                        //                                       @"time"          : [aData objectForKey:@"time"],
                                        @"event"         : (self.encoder.event.live)?LIVE_EVENT:self.encoder.event.name,
                                        @"name"          : [Utility encodeSpecialCharacters:[aData objectForKey:@"name"]],
                                        @"colour"        : [Utility hexStringFromColor: [UserCenter getInstance].customerColor],
                                        @"user"          : [UserCenter getInstance].userHID,
                                        @"deviceid"      : [[[UIDevice currentDevice] identifierForVendor]UUIDString],
                                        @"requesttime"   : GET_NOW_TIME_STRING
                                        }];
 
    
//    if (period) {
//        [tagData setValue:period forKey:@"period"];
//    }
//

    
    if ([tagData[@"type"]integerValue] != TagTypeOpenDuration &&[tagData[@"type"]integerValue] != TagTypeOpenDuration && self.generateProxyTag) {
        Event * event = [self.encoder event];
        NSMutableDictionary * proxyData = [tagData mutableCopy];
        proxyData[@"name"] = [aData objectForKey:@"name"];
        id <TagProtocol> proxyTag = [[TagProxy alloc]initWithTagData:proxyData ownEvent:event];
        BOOL postToast = YES;
        [event addTag:proxyTag extraData:postToast];
    }
    
    
    NSString    * jsonString                    = [Utility dictToJSON:tagData];
    
    NSURL * checkURL = [NSURL URLWithString:   [NSString stringWithFormat:@"%@://%@/min/ajax/tagset/%@",self.encoder.urlProtocol,self.encoder.ipAddress, jsonString ]];
    NSURLRequest * req = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:(self.timeout)?self.timeout:EO_DEFAULT_TIMEOUT];
    
    

    NSDictionary * dict = [Utility URLJSONStringDict:[[[req URL]absoluteString]lastPathComponent]];
    
    return req;
}

-(void)parseDataToEncoder:(NSData*)data
{
    NSDictionary * dict = [self.encoder.parseModule parse:data mode:ParseModeTagSet for:self.encoder];
    
    
    
    // first check to add the real tag to the proxy
    
    
    NSArray * tags = [self.encoder.event.tags copy];
    
    for ( id <TagProtocol> aTag in tags) {
        if ( [aTag conformsToProtocol:@protocol(TagProtocol)] && [aTag isKindOfClass:[TagProxy class]] ) {
            // check if aTag matches the data from the dict
            
            
            
            if ([[aTag name] isEqualToString:dict[@"name"]] && [aTag time] == [dict[@"time"]doubleValue] && [dict[@"own"]boolValue]) { //match
                TagProxy * proxyTag         = (TagProxy *)aTag;
                
                if (proxyTag.modified) {
                    PXPLog(@"Tag was Modded before server responded");
                }
                
                id <TagProtocol> realTag    = [[Tag alloc] initWithData: dict event:self.encoder.event];//  make from data
                
                [proxyTag addTagToProxy:realTag];
                
            
            }
            
        
        }
    }
    
    
    
    
//    if ( ![self.encoder.postedTagIDs containsObject:newTag.ID] ){
//        [self.encoder.postedTagIDs addObject:newTag.ID];
//        Tag * tag = [self.encoder.encoder onNewTagsEO:dict];
//        if (tag)self.userInfo = @{@"tag":tag};
//        
//    } else {
//        [self.encoder.postedTagIDs removeObject:newTag.ID];
//    }

    
    
    [super parseDataToEncoder:data];

    
    
}
@end



#pragma mark - Telestation

@implementation EncoderOperationMakeTelestration

-(NSURLRequest*)buildRequest:(NSDictionary*)aData
{
    self.timeout = 60;
    
    NSMutableDictionary * tData = [NSMutableDictionary new];

    NSLog(@"Time Getting sent to server: %@",[aData objectForKey:@"time"]);
    [tData addEntriesFromDictionary:@{

//
                                        @"colour"           : [Utility hexStringFromColor: [UserCenter getInstance].customerColor],
                                        @"deviceid"         : [[[UIDevice currentDevice] identifierForVendor]UUIDString],
                                        @"duration"         : [aData objectForKey:@"duration"],
                                        @"event"            : (self.encoder.event.live)?LIVE_EVENT:self.encoder.event.name,
                                        @"name"             : @"Telestration",//[Utility encodeSpecialCharacters:[aData objectForKey:@"name"]],
                                        @"telestration"     : [aData objectForKey:@"telestration"],
                                        @"telesrc"          : [aData objectForKey:@"telesrc"],
                                        @"time"             : [aData objectForKey:@"time"],
                                        @"type"             : [NSNumber numberWithInteger:TagTypeTele],
                                        @"user"             : [UserCenter getInstance].userHID
                                        }];
    
    // build default data
//    NSData *teleData = [data objectForKey:@"telestration"];
//    NSString *period = [data objectForKey:@"period"];
    
    // build JSON data

    NSString *jsonString    = [Utility dictToJSON:tData];
    jsonString              = [jsonString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    PXPLog(@"^^^^^^^^^^^^^^^^^^^^^^^^^^^");
    PXPLog(@"TIME OF TAG SENT TO SERVER: %@",[aData objectForKey:@"time"]);
    PXPLog(@"^^^^^^^^^^^^^^^^^^^^^^^^^^^");
    
    // Create a transparent Image to send to server (duct tape to work with legacy code)
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1.0, 1.0), NO, 1.0);
    UIImage *ductTape   = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *imageData   = UIImagePNGRepresentation(ductTape);
    


    NSURL * checkURL                        = [NSURL URLWithString:   [NSString stringWithFormat:@"%@://%@/min/ajax/teleset",self.encoder.urlProtocol,self.encoder.ipAddress]  ];

    NSMutableURLRequest *someUrlRequest     = [NSMutableURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:(self.timeout)?self.timeout:EO_DEFAULT_TIMEOUT];
    [someUrlRequest setHTTPMethod:@"POST"];
    
    NSString *boundary = @"----WebKitFormBoundarycC4YiaUFwM44F6rT";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [someUrlRequest setValue:contentType forHTTPHeaderField:@"Content-Type"];
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary]  dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=tag\r\n\r\n"   dataUsingEncoding:NSUTF8StringEncoding]];
    //[body appendData:[@"Content-Type: text/plain\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    // Now we need to append the different data 'segments'. We first start by adding the boundary.
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary]  dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=file; filename=picture.png\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    // We now need to tell the receiver what content type we have
    // In my case it's a png image. If you have a jpg, set it to 'image/jpg'
    [body appendData:[@"Content-Type: image/png\r\n\r\n"                    dataUsingEncoding:NSUTF8StringEncoding]];
    // Now we append the actual image data
    //NSData *myData = [NSKeyedArchiver archivedDataWithRootObject:tData];
    //[body appendData:myData];
    [body appendData:[NSData dataWithData:imageData]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // and again the delimiting boundary
    //NSString *tempstr =[[NSString alloc]initWithData:body encoding:NSStringEncodingConversionAllowLossy];
    [someUrlRequest setHTTPBody:body];
    
    return someUrlRequest;
}

-(void)parseDataToEncoder:(NSData*)data
{
   
    NSDictionary    * results =[Utility JSONDatatoDict:data];
    
    
    NSMutableDictionary *tData = [[NSMutableDictionary alloc]initWithDictionary:results];
    [tData removeObjectForKey:@"telefull"];//
    [tData removeObjectForKey:@"teleurl"];
    
    PXPLog(@"^^^^^^^^^^^^^^^^^^^^^^^^^^^");
    PXPLog(@"TIME OF TAG FROM SERVER: %@",[results objectForKey:@"time"]);
    PXPLog(@"^^^^^^^^^^^^^^^^^^^^^^^^^^^");

    
    if ([tData objectForKey:@"id"]) {
        
        NSMutableDictionary *checkEventDic = [self.encoder.allEvents objectForKey:[tData objectForKey:@"event"]];
        Event * encoderEvent    = [checkEventDic objectForKey:@"non-local"];
        Event * localEvent      = [checkEventDic objectForKey:@"local"];


        
        Tag *newTag = [[Tag alloc] initWithData: tData event:encoderEvent];
        if ([tData objectForKey:@"telestration"]) {
            newTag.telestration = [PxpTelestration telestrationFromData:[tData objectForKey:@"telestration"]];
        }
        
        
        if ( ![self.encoder.postedTagIDs containsObject:newTag.ID] ){
            [self.encoder.postedTagIDs addObject:newTag.ID];
            if (self.encoder.event == encoderEvent) {
                [encoderEvent addTag:newTag extraData:true];
            }else{
                [encoderEvent addTag:newTag extraData:false];
            }
        } else {
            [self.encoder.postedTagIDs removeObject:newTag.ID];
        }

        

        
        if (localEvent && newTag.type != TagTypeOpenDuration) {
            Tag *localTag = [[Tag alloc] initWithData:tData event:localEvent];
            [localEvent addTag:localTag extraData:false];
            [localEvent.parentEncoder writeToPlist];
        }

    }
    [super parseDataToEncoder:data];
}
@end



#pragma mark - Camera Data

@implementation EncoderOperationCameraData
-(NSURLRequest*)buildRequest:(NSDictionary*)aData
{
    self.timeout = 60;

    NSURL * checkURL    = [NSURL URLWithString:   [NSString stringWithFormat:@"%@://%@/min/ajax/getcameras",self.encoder.urlProtocol,self.encoder.ipAddress] ];
    NSURLRequest * req  = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:(self.timeout)?self.timeout:EO_DEFAULT_TIMEOUT];
    

    return req;
}

-(void)parseDataToEncoder:(NSData*)data
{
    NSDictionary    * results =[Utility JSONDatatoDict:data];
    NSArray * list = [results[@"camlist"]allValues];
    self.encoder.cameraCount = list.count;
//    self.encoder.cameraData = results;
    [super parseDataToEncoder:data];
}
@end

#pragma mark - Camera Data

@implementation EncoderOperationCameraStartTimes
-(NSURLRequest*)buildRequest:(NSDictionary*)aData
{
    self.timeout = 60;
    
    NSString *jsonString    = [Utility dictToJSON:@{@"sidx":@"*",@"event":@"live"}];
//    http://localhost/min/ajax/rec_stat/{"sidx":"00hq","event":"live"}
    
    NSURL * checkURL    = [NSURL URLWithString:   [NSString stringWithFormat:@"%@://%@/min/ajax/rec_stat/%@",self.encoder.urlProtocol,self.encoder.ipAddress,jsonString] ];
    NSURLRequest * req  = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:(self.timeout)?self.timeout:EO_DEFAULT_TIMEOUT];
    
    
    return req;
}

-(void)parseDataToEncoder:(NSData*)data
{
    NSDictionary    * results =[Utility JSONDatatoDict:data];
    
    NSArray * list = [results allKeys];
    
    NSMutableDictionary * dict =  [NSMutableDictionary new];
    
    for (NSString * key in list) {
        if([key rangeOfString:@"ctime-"].location != NSNotFound) {
            NSString * k = [key substringFromIndex:6];
            NSLog(@"%@",[key substringFromIndex:6]);
            [dict setObject:results[key] forKey:k];
        }
    }
    
    NSInteger lowestNumber   = NSIntegerMax;
     NSArray * list2 = [dict allKeys];
    
    for (NSString * key in list2) {
        if ( lowestNumber > [dict[key]intValue])
        {
            lowestNumber = [dict[key]intValue];
        }
    }
    
    
    for (NSString * key2 in list2) {
        dict[key2] = [NSNumber numberWithInteger:-([dict[key2]intValue] - lowestNumber) ];
    }
    
    
    PXPLog(@"Player Feed offsets:");
    
    NSArray * allKey = [dict allKeys];
    allKey = [allKey sortedArrayUsingSelector:@selector(compare:)];
    
    [allKey enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PXPLog(@"  %@ %@",obj,dict[obj]);
    }];
    
    
    
    
    Encoder * enc = self.encoder;
    Event * liveEvent = enc.liveEvent;
    
    if (liveEvent) {
        NSArray         * kList     = [enc.liveEvent.feeds allKeys];
        NSDictionary    * dictFeeds = enc.liveEvent.feeds;
        
        for (NSString * key3 in list2) {
            
            NSString * source   = [key3 substringToIndex:2];
            NSString * quality  = [key3 substringFromIndex:2];
            
            NSString * makeKey = [NSString stringWithFormat:@"s_%@",source];
            Feed * feed = dictFeeds[makeKey];
            
            [feed.offsetDict setObject:dict[key3] forKey:quality];
            
            
            NSLog(@"");
         }
        
        
    }
    
    
    
   
    
    [super parseDataToEncoder:data];
}


@end
#pragma mark - CheckSpace

@implementation EncoderOperationCheckSpace
-(NSURLRequest*)buildRequest:(NSDictionary*)aData
{
    self.timeout = 60;
    
    NSURL * checkURL    = [NSURL URLWithString:   [NSString stringWithFormat:@"%@://%@/min/ajax/getcameras",self.encoder.urlProtocol,self.encoder.ipAddress] ];
    NSURLRequest * req  = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:(self.timeout)?self.timeout:EO_DEFAULT_TIMEOUT];
    
    
    return req;
}

-(void)EncoderOperationCheckSpace:(NSData*)data
{
    NSDictionary    * results =[Utility JSONDatatoDict:data];

    [super parseDataToEncoder:data];
}
@end


#pragma mark - CheckSpace

@implementation EncoderOperationStatAndSync
-(NSURLRequest*)buildRequest:(NSDictionary*)aData
{
    self.timeout = 60;
    
    NSURL * checkURL    = [NSURL URLWithString:   [NSString stringWithFormat:@"%@://%@/min/ajax/encstatsyncme",self.encoder.urlProtocol,self.encoder.ipAddress] ];
    NSURLRequest * req  = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:(self.timeout)?self.timeout:EO_DEFAULT_TIMEOUT];
    
    
    return req;
}

-(void)EncoderOperationCheckSpace:(NSData*)data
{
    NSDictionary    * results =[Utility JSONDatatoDict:data];
    
    [super parseDataToEncoder:data];
}
@end



#pragma mark - Local Tag Post
@implementation EncoderOperationLocalTagPost

-(instancetype)initTagData:(NSDictionary*)tagData
{
    self = [super init];
    if (self) {
        self.tagData = tagData;
        self.type    = @"tagset";
        
        NSMutableDictionary * filteredData  = [NSMutableDictionary new];
        
        [filteredData setObject:self.tagData[@"time"]     forKey:@"time"];
        [filteredData setObject:self.tagData[@"event"]    forKey:@"event"];
        [filteredData setObject:self.tagData[@"name"]     forKey:@"name"];
        [filteredData setObject:self.tagData[@"type"]     forKey:@"type"];
        [filteredData setObject:self.tagData[@"colour"]   forKey:@"colour"];
        [filteredData setObject:self.tagData[@"user"]     forKey:@"user"];
        [filteredData setObject:self.tagData[@"deviceid"] forKey:@"deviceid"];
        [filteredData setObject:self.tagData[@"duration"] forKey:@"duration"];
        
        
        self.tagData = [filteredData copy];
        
    }
    return self;
}

-(instancetype)initTagModData:(NSDictionary*)tagData
{
    self = [super init];
    if (self) {
        self.tagData = tagData;
        self.type    = @"tagmod";
    }
    return self;
}

-(void)start
{
    
    
    if ([self isCancelled]) {
        [self setFinished:YES];
        
    }
    
    
    self.timeStamp  = [NSNumber numberWithDouble:CACurrentMediaTime()];
    self.request    = [self buildRequest:self.tagData]; // this build request is overrided
    
    
    [self setExecuting:YES];
    
    NSURLSessionConfiguration *sessionConfig        = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.allowsCellularAccess              = NO;
    sessionConfig.timeoutIntervalForRequest         = 10;
    sessionConfig.timeoutIntervalForResource        = 10;
    sessionConfig.HTTPMaximumConnectionsPerHost     = 1;
    sessionConfig.protocolClasses                   = @[[PxpURLProtocol class],
                                                        [MockURLProtocol class]
                                                        ];
    
    self.session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
    [[self.session dataTaskWithRequest:self.request]resume];
}


-(void)updateWithEncoder:(id<EncoderProtocol>)aEncode
{
    [self willChangeValueForKey:@"isReady"];
    self.encoder = aEncode;
    [self didChangeValueForKey:@"isReady"];
}


-(NSURLRequest*)buildRequest:(NSDictionary*)aData
{
    NSString    * jsonString                    = [Utility dictToJSON:aData];
    NSURL * checkURL    = [NSURL URLWithString:   [NSString stringWithFormat:@"%@://%@/min/ajax/%@/%@",self.encoder.urlProtocol,self.encoder.ipAddress,self.type,jsonString] ];
    NSURLRequest * req  = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:(self.timeout)?self.timeout:EO_DEFAULT_TIMEOUT];
    
    return req;
}

-(void)parseDataToEncoder:(NSData*)data
{
    if (self.onRequestComplete) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.onRequestComplete(data,self);
        });
    }
    
    NSDictionary * checkIfFail = [Utility JSONDatatoDict:data];
    if ([checkIfFail[@"success"]intValue] == 0) {
        self.success = NO;
    } else {
        self.success = YES;
    }
}

-(BOOL)isReady
{
    NSString * eventName = self.tagData[@"event"];
// if has encoder and encoder has EVent
    return (self.encoder && [[self.encoder allEvents] objectForKey:eventName]);
}

@end





