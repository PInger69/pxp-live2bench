//
//  AppQueue.m
//  Live2BenchNative
//
//  Created by DEV on 2013-01-31.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "AppQueue.h"

@implementation AppQueue{
    
    int NoServerConnectionErrorCount;
}


@synthesize queue;
@synthesize globals;
@synthesize timer;
@synthesize urlRequest;
@synthesize waitingTime;
@synthesize tagNumbersFromSyncme;
@synthesize connection;
@synthesize errorAlert;
@synthesize errorCounter;

NSDate *startRequestTime;

#define k_BITRATE_SAMPLE_SIZE 10

- (id)init
{
    //initialise queue
    self = [super init];
    if ((self = [super init])) {
        queue =[[NSMutableArray alloc]init];
        timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(waitingResponse) userInfo:nil repeats:YES];
        timerCount = 0;
        errorCounter = 0;
    }
    return self;
}

- (void) waitingResponse{
    if ([self peekHead]){
        timerCount++;
    }
    //NSLog(@"peekHead: %@,waiting time :%d timerCount: %d",[NSString stringWithFormat:@"%@",[[[self peekHead] allKeys]objectAtIndex:0 ]],waitingTime,timerCount);
    if (timerCount > waitingTime ){
        [self dequeue];
        globals.WAITING_RESPONSE_FROM_SERVER = FALSE;
        [self sendTheNextRequest];
    }
    //removes object from queue if it takes more than the waiting time to respond
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //if there is response from server, set the two error counter to zero
    errorCounter = 0;
    NoServerConnectionErrorCount = 0;
   
    
    ////////NSLog(@"didReceiveResponse [self peekHead]: %@",[self peekHead]);
    //do something if response recieved
    //reset the error alert
    errorAlert = nil;
    
}

//gets called when there is data response from the server (may be incomplete)
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
     ////////NSLog(@"didReceiveData [self peekHead]: %@",[self peekHead]);
    //make sure the data is not nill, then initialize responseData with it
    if (data != nil) {
        if (responseData == nil){
            //            initialize responseData with first packet
            responseData = [NSMutableData dataWithData:data];
        }
        else{
            //            for multiple packets, the data should be appended
            [responseData appendData:data];
        }
    }
    
    
}

- (NSString *) URLEncodedString_ch:(NSString*)input
{
    NSMutableString * output = [NSMutableString string];
    const unsigned char * source = (const unsigned char*)[input UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

// Add to the tail of the queue
-(void) enqueue:(id)anObject dict:(NSDictionary*)instanceObj  {
    
    if (!globals) {
        globals = [Globals instance];
    }
    
    // Push the item in
    selector = [[instanceObj objectForKey:@"callback"] pointerValue];
    //create dictionary of object vs selectorname
    NSMutableDictionary *dictionaryOfObj = [[NSMutableDictionary alloc]init];
    [dictionaryOfObj setObject:instanceObj forKey:anObject];
//    if ([[NSString stringWithFormat:@"%@",anObject] rangeOfString:@"teamsget"].location != NSNotFound) {
//        //////NSLog(@"gametags queue count %d",self.queue.count);
//    }
    //empty the queue when sending "getallgametags" request because of switching to different event
    if (([[NSString stringWithFormat:@"%@",anObject] rangeOfString:@"encstart"].location != NSNotFound || [[NSString stringWithFormat:@"%@",anObject] rangeOfString:@"gametags"].location != NSNotFound|| ([[NSString stringWithFormat:@"%@",anObject] rangeOfString:@"encstop"].location != NSNotFound && [globals.EVENT_NAME isEqualToString:@"live"]) ) && self.queue.count > 5 ) {
        //leave the peek request which may be waiting for responsse
        NSMutableArray *tempArr = [[NSMutableArray alloc]initWithObjects:[self.queue objectAtIndex:0],[self.queue objectAtIndex:1], nil];
        [self.queue removeAllObjects];
        [self.queue addObjectsFromArray:tempArr];
    }
    
    [self.queue addObject:dictionaryOfObj];
    // //////
    if(self.queue.count<=1 && !globals.WAITING_RESPONSE_FROM_SERVER)
    {
        
        if([anObject isKindOfClass:[NSString class]])
        {
            //urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:anObject]];
            urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:anObject] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0];
        }else{
            urlRequest = anObject;
        }
        
        //[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
        
        ////NSLog(@"urlreq %@",urlRequest);
        startRequestTime = [NSDate date];
        connection = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
        //[connection start];
        if (connection) {
            //////NSLog(@"connection successs");
        }else{
            //////NSLog(@"connection failed");
        }
        globals.WAITING_RESPONSE_FROM_SERVER = TRUE;
        if ([instanceObj objectForKey:@"timeout"]!=nil) {
            waitingTime = [[instanceObj objectForKey:@"timeout"]integerValue];
        }else{
            waitingTime = 5;
        }
        timerCount = 0;
    }
    
     //NSLog(@"enqueue: %d",self.queue.count);
}



- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    //NSLog(@"error: %@",error);
    /*
     Error Examples: error: Error Domain=NSURLErrorDomain Code=-1001 "The request timed out." UserInfo=0x2088bfc0 {NSErrorFailingURLStringKey=http://avocatec.org:8888/min/ajax/teamsget/%7B%22requesttime%22:%22199830.681579%22%7D, NSErrorFailingURLKey=http://avocatec.org:8888/min/ajax/teamsget/%7B%22requesttime%22:%22199830.681579%22%7D, NSLocalizedDescription=The request timed out., NSUnderlyingError=0x1fdcf840 "The request timed out."}
     error: Error Domain=NSURLErrorDomain Code=-1009 "The Internet connection appears to be offline." UserInfo=0x1f86a220 {NSErrorFailingURLStringKey=http://avocatec.org:8888/min/ajax/encoderstatjson/%7B%22requesttime%22:%22200101.656198%22%7D, NSErrorFailingURLKey=http://avocatec.org:8888/min/ajax/encoderstatjson/%7B%22requesttime%22:%22200101.656198%22%7D, NSLocalizedDescription=The Internet connection appears to be offline., NSUnderlyingError=0x1f837d10 "The Internet connection appears to be offline."}
     
     error: Error Domain=NSURLErrorDomain Code=-1004 "Could not connect to the server." UserInfo=0x17d74020 {NSErrorFailingURLStringKey=http://192.168.0.114:80/min/ajax/encshutdown/%7B%22requesttime%22:%221458439.295588%22%7D, NSErrorFailingURLKey=http://192.168.0.114:80/min/ajax/encshutdown/%7B%22requesttime%22:%221458439.295588%22%7D, NSLocalizedDescription=Could not connect to the server., NSUnderlyingError=0x17d8aa30 "Could not connect to the server."}
     error: Error Domain=NSURLErrorDomain Code=-1002 "unsupported URL" UserInfo=0x17dbb9f0 {NSErrorFailingURLStringKey=/min/ajax/encoderstatjson/%7B%22requesttime%22:%221458464.945253%22%7D, NSErrorFailingURLKey=/min/ajax/encoderstatjson/%7B%22requesttime%22:%221458464.945253%22%7D, NSLocalizedDescription=unsupported URL, NSUnderlyingError=0x17dc13e0 "unsupported URL"}
     */
    if (globals.HAS_MIN) {
        if ([[NSString stringWithFormat:@"%@",[error.userInfo objectForKey:@"NSErrorFailingURLKey"]] rangeOfString:@"myplayxplay.net"].location == NSNotFound) {
            errorCounter++;
            if (!errorAlert && errorCounter > 2) {
                NSString *msg = @"Connection to the server is interrupted. Please check the server connection and wifi connection.";
                //            if (error.code == -1002) {
                //                msg = @"Wifi is not connected. Please check the server connection and network condition.";
                //            }else{
                //                msg = [NSString stringWithFormat:@"%@ Please check the server connection and network condition.",error.localizedDescription];
                //            }
                errorAlert = [[CustomAlertView alloc]initWithTitle:@"myplayXplay" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [errorAlert show];
                //[globals.ARRAY_OF_POPUP_ALERT_VIEWS addObject:errorAlert]; Added from class
                globals.CURRENT_ENC_STATUS = @""; //encStateStopped;
                
                //check whether the server is still available or not
                //apstNotInited: 0, apstReactiveCheck:1
                if (globals.CURRENT_APP_STATE != 0)
                {
                    globals.CURRENT_APP_STATE = 1;
                }
            }
            //******
            //  error: Error Domain=NSURLErrorDomain Code=-1004 "Could not connect to the server." UserInfo=0x17d74020 {NSErrorFailingURLStringKey=http://192.168.0.114:80/min/ajax/encshutdown/%7B%22requesttime%22:%221458439.295588%22%7D, NSErrorFailingURLKey=http://192.168.0.114:80/min/ajax/encshutdown/%7B%22requesttime%22:%221458439.295588%22%7D, NSLocalizedDescription=Could not connect to the server., NSUnderlyingError=0x17d8aa30 "Could not connect to the server."}
            //error: Error Domain=NSURLErrorDomain Code=-1002 "unsupported URL" UserInfo=0x17dbb9f0 {NSErrorFailingURLStringKey=/min/ajax/encoderstatjson/%7B%22requesttime%22:%221458464.945253%22%7D, NSErrorFailingURLKey=/min/ajax/encoderstatjson/%7B%22requesttime%22:%221458464.945253%22%7D, NSLocalizedDescription=unsupported URL, NSUnderlyingError=0x17dc13e0 "unsupported URL"}
            //******
            if (error.code == -1004 || error.code == -1002) {
                NoServerConnectionErrorCount++;
                if (NoServerConnectionErrorCount > 2) {
                    globals.HAS_MIN = NO;

                }
            }
        }

    }
        //error code: kCFURLErrorUnsupportedURL = -1002,kCFURLErrorCannotConnectToHost    = -1004, Code=-1001 "The request timed out; Code=-1009 "The Internet connection appears to be offline.
    
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    errorCounter = 0;
    [CustomAlertView removeAlert:alertView];
}

//called when the connection with the server is finished
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //reset errorcounter
    errorCounter = 0;
    //////NSLog(@"reset errorCounter");
    //    at this point all the data (from multiple packets) is in responseData - parse the json from it
    id json;
    if(responseData)
    {
        if ([responseData length] <= 1000){
            double diff = [[NSDate date] timeIntervalSinceDate:startRequestTime];
            globals.BIT_RATE = 0;
            if ([globals.BIT_RATE_SAMPLES count] >= k_BITRATE_SAMPLE_SIZE/5){
                if ([globals.BIT_RATE_SAMPLES count] >= k_BITRATE_SAMPLE_SIZE) {
                    [globals.BIT_RATE_SAMPLES removeObjectAtIndex:0];
                }
                [globals.BIT_RATE_SAMPLES addObject:[NSNumber numberWithDouble:([responseData length]/diff)]];
                for (NSNumber *num in globals.BIT_RATE_SAMPLES){
                    globals.BIT_RATE += [num doubleValue];
                }
                globals.BIT_RATE /= [globals.BIT_RATE_SAMPLES count];
            } else {
                globals.BIT_RATE = -1; //Flag to indicate it is still searching for a signal
                [globals.BIT_RATE_SAMPLES addObject:[NSNumber numberWithDouble:([responseData length]/diff)]];
            }
        }
        json = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
    }
    NSString * foo = [[NSString alloc]initWithData:responseData encoding:NSASCIIStringEncoding]; // used to //////NSLog appqueue response
    NSString * test = [NSString stringWithFormat:@"'%@'",foo];
//  NSLog(@"jjson -- %@",foo);
    //////NSLog(@"responsedata : %@,responseData: %@, [self peekHead]: %@",json,foo,[self peekHead]);

    NSURL *responseURL;
    if ([json isKindOfClass:[NSDictionary class]] && [json objectForKey:@"requrl"]) {
        NSString * properlyEncodedString = [[json objectForKey:@"requrl"] stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
        responseURL = [NSURL URLWithString: properlyEncodedString];
    }
    //    if (!tagNumbersFromSyncme) {
    //        tagNumbersFromSyncme = 0;
    //    }
    
    NSString *peekURLStr;
    if ([self peekHead]) {
        peekURLStr = [NSString stringWithFormat:@"%@",[[[self peekHead] allKeys]objectAtIndex:0 ]];
        //////NSLog(@"[self peekHead] %@ peekURLStr %@",[self peekHead],peekURLStr);
    }
    globals.WAITING_RESPONSE_FROM_SERVER = FALSE;
    //reset responseData for the next server request
    responseData = nil;
    
    //    if ([responseURL.absoluteString rangeOfString:@"syncme"].location != NSNotFound) {
    //        // ////NSLog(@"json from syncme call back: %@",json);
    //        if ([json objectForKey:@"tags"]) {
    //            NSDictionary *tempDict= [[NSDictionary alloc]initWithDictionary:[json objectForKey:@"tags"]];
    //            tagNumbersFromSyncme += tempDict.count;
    //            ////NSLog(@"new tags count %d, total tag numbers %d, responseURL: %@, peekURL: %@",tempDict.count,tagNumbersFromSyncme,responseURL,peekURLStr);
    //        }
    //
    //    }
    if ([peekURLStr rangeOfString:@"myplayxplay.net"].location == NSNotFound){
        
        //if the response is not from the cloud, resset has_min to TRUE
        globals.HAS_MIN = TRUE;
    }
    
    if (peekURLStr && responseURL) {
        //if the response data matches the current request, send the response data to the request call back function
        if ([peekURLStr rangeOfString:[responseURL absoluteString]].location != NSNotFound) {
            //////NSLog(@"go inside peekURLStr && responseURL");
            //dequeue object
            id tempObj = [self.queue objectAtIndex:0];
            //extract callback pointer
            selector = [[[[tempObj allObjects] objectAtIndex:0] objectForKey:@"callback"] pointerValue];
            //call selector using passed in controller object
            if (selector){
                [[[[tempObj allObjects] objectAtIndex:0] objectForKey:@"controller"] performSelector:selector withObject:json];
            }
            
            [self dequeue];
            [self sendTheNextRequest];
        }else{
            //////NSLog(@"go inside peekURLStr != responseURL");
            // ////NSLog(@"peekURLstr %@, responseURL %@",peekURLStr,responseURL);
        }
    }else{
        //////NSLog(@"go inside peekURLStr== nil OR responseURL == nil");
        //////NSLog(@"peekURLstr %@, responseURL %@",peekURLStr,responseURL);
    }
    
}


-(void)sendTheNextRequest{
    //if the queue is not empty, send another request
    if(self.queue.count>0 && !globals.WAITING_RESPONSE_FROM_SERVER)
    {
        id currentObject = [[[self.queue objectAtIndex:0] allKeys] objectAtIndex:0];
        //NSURLRequest *urlRequest;
        if([currentObject isKindOfClass:[NSString class]])
        {
            //urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:currentObject]];
            urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:currentObject] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0];
        }else{
            urlRequest = (NSURLRequest*)currentObject;
        }
        ////////NSLog(@"Response url: %@",urlRequest);
        //[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
        startRequestTime = [NSDate date];
        connection = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
        //[connection start];
        if (connection) {
            ////////NSLog(@"connection successs");
        }else{
            ////////NSLog(@"connection failed");
        }
        globals.WAITING_RESPONSE_FROM_SERVER = TRUE;
        id instanceObj = [[self.queue objectAtIndex:0] objectForKey:currentObject];
        
        if ([instanceObj objectForKey:@"timeout"]!=nil) {
            waitingTime = [[instanceObj objectForKey:@"timeout"]integerValue];
        }else{
            waitingTime = 5;
        }
        
        timerCount = 0;
    }
    
}
// Grab the next item in the queue, if there is one
-(id) dequeue {
   
    timerCount = 0;
    // Set aside a reference to the object to pass back
    id queueObject = nil;
    // Do we have any items?
    if ([self.queue lastObject]) {
        // Pick out the first one
        queueObject = [self.queue  objectAtIndex: 0];
        // Remove it from the queue
        [self.queue  removeObjectAtIndex: 0];
        globals.WAITING_RESPONSE_FROM_SERVER = FALSE;
    }
    // NSLog(@"dequeue: %d",self.queue.count);
    // Pass back the dequeued object, if any
    return queueObject;
}

// Takes a look at an object at a given location
-(id) peek: (int) index {
    // Set aside a reference to the peeked at objectr
    id peekObject = nil;
    // Do we have any items at all?
    if ([self.queue lastObject]) {
        // Is this within range?
        if (index < [self.queue count]) {
            // Get the object at this index
            peekObject = [self.queue objectAtIndex: index];
        }
    }
	
    // Pass back the peeked at object, if any
    return peekObject;
}

// Let's take a look at the next item to be dequeued
-(id) peekHead {
    // Peek at the next item
	return [self peek: 0];
}

// Let's take a look at the last item to have been added to the queue
-(id) peekTail {
    // Pick out the last item
	return [self.queue lastObject];
}

// Checks if the queue is empty
-(BOOL) empty {
    return ([self.queue lastObject] == nil);
}


-(NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
    return request;
}

@end
