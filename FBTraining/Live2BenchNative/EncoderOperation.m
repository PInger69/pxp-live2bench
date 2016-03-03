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
    NSLog(@"Receiving...");
    if (self.cumulatedData == nil){
        self.cumulatedData = [NSMutableData dataWithData:data];
    } else {
        [self.cumulatedData appendData:data];
    }
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    NSLog(@"Connection finished");
    

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


- (instancetype)initEncoder:(id <EncoderProtocol>)aEncoder data:(NSDictionary*)aData tag:(Tag*)tag
{
    self = [super initEncoder:aEncoder data:aData];
    if (self) {
        self.tag = tag;
    }
    return self;
}


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
    [self.encoder.parseModule parse:data mode:ParseModeTagMod for:self.encoder];
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
       NSString    * jsonString                    = [Utility dictToJSON:tagData];
    
    NSURL * checkURL = [NSURL URLWithString:   [NSString stringWithFormat:@"%@://%@/min/ajax/tagset/%@",self.encoder.urlProtocol,self.encoder.ipAddress, jsonString ]];
    NSURLRequest * req = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:(self.timeout)?self.timeout:EO_DEFAULT_TIMEOUT];
    
    

    NSDictionary * dict = [Utility URLJSONStringDict:[[[req URL]absoluteString]lastPathComponent]];
    
    return req;
}

-(void)parseDataToEncoder:(NSData*)data
{
    NSDictionary * dict = [self.encoder.parseModule parse:data mode:ParseModeTagSet for:self.encoder];
  
    
    Tag * tag = [self.encoder onNewTagsEO:dict];
    if (tag)self.userInfo = @{@"tag":tag};
    
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
    self.encoder.cameraData = results;
    [super parseDataToEncoder:data];
}
@end

