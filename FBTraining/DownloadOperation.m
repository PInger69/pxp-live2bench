//
//  DownloadOperation.m
//  Live2BenchNative
//
//  Created by dev on 2015-12-08.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "DownloadOperation.h"

@implementation DownloadOperation


- (instancetype)initWith:(NSURL*)url destination:(NSString*)destination
{
    self = [super init];
    if (self) {
        executing               = NO;
        finished                = NO;
        self.timeout            = 5;
        self.request            = nil;
        self.destination        = destination;
        self.source             = url;
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
    _receivedBytes  = 0;
    NSURLSessionConfiguration *sessionConfig        = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.allowsCellularAccess              = NO;
    sessionConfig.timeoutIntervalForRequest         = self.timeout;
    sessionConfig.timeoutIntervalForResource        = self.timeout;
    sessionConfig.HTTPMaximumConnectionsPerHost     = 1;
    
    self.session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
    self.request = [NSURLRequest requestWithURL:self.source  cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:self.timeout];
    [[self.session dataTaskWithRequest:self.request]resume];
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




-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    
    if (!stream){
        _expectedBytes  = (double)dataTask.countOfBytesExpectedToReceive;
        
        
        // this is to overwirte the file
        if([[NSFileManager defaultManager] fileExistsAtPath:self.destination])
        {
            [[NSFileManager defaultManager] removeItemAtPath:self.destination error:nil];
        }
        
        stream          = [[NSOutputStream alloc] initToFileAtPath:self.destination append:YES];
        [stream open];
        if (self.onRequestRecieved) {
            self.onRequestRecieved(self);
        }
    }
    
    
    
    _receivedBytes += data.length;
    NSLog(@"Receiving...");
    
    NSUInteger left = [data length];
    NSUInteger nwr = 0;
    do {
        nwr = [stream write:[data bytes] maxLength:left];
        if (-1 == nwr) break;
        left -= nwr;
    } while (left > 0);
    if (left) {
        PXPLog(@"stream error: %@", [stream streamError]);
    }

    if ([self isCancelled]) {
        [dataTask cancel];
        
        if (stream)[stream close];
        if([[NSFileManager defaultManager] fileExistsAtPath:self.destination])
        {
            [[NSFileManager defaultManager] removeItemAtPath:self.destination error:nil];
        }

    }
    
    if (self.onRequestProgress) {
        self.onRequestProgress(self);
    }
    
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    NSLog(@"Connection finished");
    if (stream)[stream close];
    
    if (error) {
        NSLog(@"Error %@",error);
    }
    
    
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    finished = YES;
    executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
    

}




@end
