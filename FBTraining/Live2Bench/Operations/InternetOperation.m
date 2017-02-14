//
//  InternetOperation.m
//  Live2BenchNative
//
//  Created by dev on 2016-04-15.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "InternetOperation.h"
#import "PxpURLProtocol.h"
#import "MockURLProtocol.h"
@implementation InternetOperation
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
    NSURL * checkURL = [NSURL URLWithString:   @"http://myplayxplay.net/max/ping/ajax"  ];
    self.request   = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
    self.session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
    [[self.session dataTaskWithRequest:self.request]resume];
}


- (void)cancel
{
    [super cancel];
    
    [self setExecuting:NO];
    [self setFinished:YES];
    
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
        
    } else {
        self.success = YES;
    }
    if (self.checkIfInternet)self.checkIfInternet(self.success,error);
  
    
    [self setExecuting:NO];
    [self setFinished:YES];
}



@end
