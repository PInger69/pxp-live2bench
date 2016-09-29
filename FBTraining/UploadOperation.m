//
//  UploadOperation.m
//  Live2BenchNative
//
//  Created by dev on 2016-08-17.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "UploadOperation.h"
#import "UserCenter.h"
#import "CustomAlertControllerQueue.h"

#define DEVICE_ID    @"v0"
#define CUSTOMER_ID  @"v4"
#define VIDEO_FILE  @"qqfile"


@implementation UploadOperation

- (instancetype)initWith:(NSURL*)urlDestination fileToBeUploaded:(NSURL*)videoURL;
{
    
    NSData * theData = [NSData dataWithContentsOfFile:[videoURL path]];
    
    self = [[UploadOperation alloc] initWith:urlDestination dataToBeUploaded:theData];
    return self;
}


- (instancetype)initWith:(NSURL*)urlDestination dataToBeUploaded:(NSData*)data;
{
    self = [super init];
    if (self) {
        executing               = NO;
        finished                = NO;
        self.request            = nil;
        self.data               = data;
        self.source             = urlDestination;

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
    
    _expectedBytes  = 0;
    _sentBytes  = 0;
    
    NSLog(@"POSTING");
    
    self.request = [self buildRequest];
    

    
    
    NSURLSessionConfiguration *sessionConfig        = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.allowsCellularAccess              = NO;
    sessionConfig.timeoutIntervalForRequest         = 30;
    sessionConfig.timeoutIntervalForResource        = 30;
    sessionConfig.HTTPMaximumConnectionsPerHost     = 1;
//    sessionConfig.protocolClasses                   = @[[PxpURLProtocol class],
//                                                        [MockURLProtocol class]
//                                                        ];
//    
    self.session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
//    [[self.session uploadTaskWithRequest:self.request fromData:self.data]resume];    
//    
//    return;

    
    
    self.task = [self.session dataTaskWithRequest:self.request completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                               
                                      if (error) {
                                          self.error = error;
                                          NSLog(@"error :%@",error);
                                          UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Pxp Alert"
                                                                                                          message:[error localizedDescription]
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

                                      }
                                      NSString * text = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                                      
                                      NSDictionary * checkIfFail = [Utility JSONDatatoDict:data];
                                      
                                      self.data = data;
                                      if ([checkIfFail[@"success"]intValue] == 0) {
                                          NSLog(@"self.success = NO");
                                      } else {
                                          NSLog(@"self.success = YES");
                                      }
                                      
                                      if (self.onRequestRecieved) {
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
    if (self.onRequestProgress) {
        self.expectedBytes = totalBytesExpectedToSend;
        self.sentBytes = totalBytesSent;
        self.onRequestProgress(self);
    }

}


-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    
    //    NSLog(@"Receiving...");
    if (self.cumulatedData == nil){
        self.cumulatedData = [NSMutableData dataWithData:data];
    } else {
        [self.cumulatedData appendData:data];
    }
    
    if (self.onRequestProgress) {
        self.onRequestProgress(self);
    }
    
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    NSLog(@"Connection finished");
//    if (stream)[stream close];
    
    if (error) {
        NSLog(@"Error %@",error);
    }
        NSDictionary * checkIfFail = [Utility JSONDatatoDict:self.cumulatedData];
    if ([checkIfFail[@"success"]intValue] == 0) {
        NSLog(@"self.success = NO");
    } else {
        NSLog(@"self.success = YES");
    }

    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    finished = YES;
    executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}


-(NSMutableURLRequest*)buildRequest
{
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:self.source];
    [request setHTTPMethod:@"POST"];
    
    BOOL val = 1;
    

    
    
    
//TODO:    Add "hteam", "vteam", "league"
    NSString * boundary         = @"---------------------------14737809831466499882746641449";
    NSString * contentType      = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    NSString * deviceID         = (val)?[UserCenter getInstance].customerAuthorization:@"a25a73cb2c1a7acf08249089c2ea9dc5be514dcb";//@"a25a73cb2c1a7acf08249089c2ea9dc5be514dcb";//
    NSString * customerID       = [UserCenter getInstance].customerID;
    NSMutableData *body         = [NSMutableData data];
    
    
    NSData * (^addField)(NSString*,NSString*) = ^NSData*(NSString*name, NSString*value) {
        NSMutableData *tempData         = [NSMutableData data];
        [tempData appendData:[[NSString stringWithString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; \r\n\r\n",name]] dataUsingEncoding:NSUTF8StringEncoding]];
        [tempData appendData:[value dataUsingEncoding:NSUTF8StringEncoding]];
        [tempData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        return tempData;
    };

    
    
    
    
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//    [body appendData: addField(@"v0",deviceID)];
//    [body appendData: addField(@"v4",customerID)];
    
    [body appendData: addField(@"v0",deviceID)]; // device
    [body appendData: addField(@"v4",customerID)]; // customer
    if (self.league)        [body appendData: addField(@"league",self.league)];
    if (self.hTeam)         [body appendData: addField(@"hteam",self.hTeam)];
    if (self.vTeam)         [body appendData: addField(@"vteam",self.vTeam)];
    if (self.clipName)      [body appendData: addField(@"clip",self.clipName)];
    if (self.clipEventName) [body appendData: addField(@"event",self.clipEventName)];
    
    
//    [body appendData:[[NSString stringWithString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"v0\"; \r\n\r\n"]] dataUsingEncoding:NSUTF8StringEncoding]];
//    [body appendData:[deviceID dataUsingEncoding:NSUTF8StringEncoding]];
//    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//    [body appendData:[[NSString stringWithString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"v4\"; \r\n\r\n"]] dataUsingEncoding:NSUTF8StringEncoding]];
//    [body appendData:[customerID dataUsingEncoding:NSUTF8StringEncoding]];
//    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    NSString *returnString = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
    NSLog(@"%@",returnString);
    
 
    [body appendData:[[NSString stringWithString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"qqfile\"; filename=\"test.mp4\"\r\n"]] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:self.data]];

   
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];


    
    [request setHTTPBody:body];

    return request;
}



@end
