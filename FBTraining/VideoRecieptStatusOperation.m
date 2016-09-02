//
//  VideoRecieptStatusOperation.m
//  Live2BenchNative
//
//  Created by dev on 2016-08-26.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "VideoRecieptStatusOperation.h"

@implementation VideoRecieptStatusOperation



- (instancetype)initWithKey:(NSString*)videoKey device:(NSString*)deviceID customer:(NSString*)customerID
{
    self = [super init];
    if (self) {
        executing               = NO;
        finished                = NO;
        self.videoKey           = videoKey;
        self.deviceID           = deviceID;
        self.customerID         = customerID;
        
    }
    return self;
}



-(void)start
{
    
    if ([self isCancelled]) {
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    
    NSLog(@"POSTING");
    
    
    
//    NSString * boundary         = @"----WebKitFormBoundaryE19zNvXGzXaLvS5C";
//    NSString * contentType      = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"http://myplayxplay.net/max/xsStats/ajax"]];
    [request setHTTPMethod:@"POST"];
//    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];    
    
    
    NSMutableData *body         = [NSMutableData data];
    
    
    NSString * boundary         = @"---------------------------14737809831466499882746641449";
    NSString * contentType      = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    NSString * deviceID         = self.deviceID;    //@"a25a73cb2c1a7acf08249089c2ea9dc5be514dcb";//
    NSString * customerID       = self.customerID;  //@"356a192b7913b04c54574d18c28d46e6395428ab";//
    NSString * theKey           = self.videoKey;    //@"cd546eaf44dd1222eb938b2471e022c36a4a9fda";//@"356a192b7913b04c54574d18c28d46e6395428ab";//
//    NSMutableData *body         = [NSMutableData data];
    
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"v0\"; \r\n\r\n"]] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[deviceID dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"v4\"; \r\n\r\n"]] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[customerID dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"key\"; \r\n\r\n"]] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[theKey dataUsingEncoding:NSUTF8StringEncoding]];
    //    [body appendData:[[NSString stringWithString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"qqfile\"; \r\nContent-Type: video/mp4\r\n\r\n"]] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    
    
    
//    [body appendData:[[NSString stringWithString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"qqfile\"; filename=\"test.mp4\"\r\n"]] dataUsingEncoding:NSUTF8StringEncoding]];
//    [body appendData:[@"\r\nContent-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    [body appendData:[NSData dataWithData:self.data]];
    
    
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    

    [request setHTTPBody:body];
    
    NSString *returnString = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
    NSLog(@"%@",returnString);
    
    NSURLSessionConfiguration *sessionConfig        = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.allowsCellularAccess              = NO;
    sessionConfig.timeoutIntervalForRequest         = 10;
    sessionConfig.timeoutIntervalForResource        = 10;
    sessionConfig.HTTPMaximumConnectionsPerHost     = 1;
    //    sessionConfig.protocolClasses                   = @[[PxpURLProtocol class],
    //                                                        [MockURLProtocol class]
    //                                                        ];
    //
    self.session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
    //    [[self.session uploadTaskWithRequest:self.request fromData:self.data]resume];
    //
    //    return;
    
    
    
    self.task = [self.session dataTaskWithRequest:request completionHandler:
                 ^(NSData *data, NSURLResponse *response, NSError *error) {
                     
                     if (error) {
                         NSLog(@"error :%@",error);
                         self.error = error;
                     }
                     NSString * text = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                     
                     NSDictionary * checkIfFail = [Utility JSONDatatoDict:data];
                     if ([checkIfFail[@"success"]intValue] == 0) {
                         NSLog(@"self.success = NO");
                     } else {
                         NSLog(@"self.success = YES");
                     }
                     
                     self.data = data;
                     
                     if (self.onRequestRecieved)  {
                         self.onRequestRecieved(self);
                     }
                     [self willChangeValueForKey:@"isFinished"];
                     [self willChangeValueForKey:@"isExecuting"];
                     finished = YES;
                     executing = NO;
                     [self didChangeValueForKey:@"isExecuting"];
                     [self didChangeValueForKey:@"isFinished"];
                 }];
    
    [self.task resume];
    
//    self.request = [self buildRequest];
    
}


-(BOOL)isConcurrent
{
    return YES;
}

-(BOOL)isExecuting
{
    return executing;
}

-(BOOL)isFinished
{
    return finished;
}

#pragma mark - Delegate methods

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{

}


-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{

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
        NSLog(@"Error %@",error);
    }
    NSDictionary * checkIfFail = [Utility JSONDatatoDict:self.cumulatedData];
    
    self.rawData = checkIfFail;
    if ([checkIfFail[@"success"]intValue] == 0) {
        NSLog(@"self.success = NO");
    } else {
        NSLog(@"self.success = YES");
    }
    
    if (self.onRequestRecieved)  {
        self.onRequestRecieved(self);
    }
    
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    finished = YES;
    executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}


@end
