//
//  PostOperation.m
//  Live2BenchNative
//
//  Created by dev on 2016-04-15.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "PostOperation.h"

@interface PostOperation ()
@property (nonatomic,strong)    NSMutableData   * cumulatedData;
@end


@implementation PostOperation
{   
    BOOL _isFinished;
    BOOL _isExecuting;
}






- (instancetype)initWithNSURLRequest:(NSURLRequest*)request
{
    self = [super init];
    if (self) {
        
        _isExecuting               = NO;
        _isFinished                = NO;
        self.request               = request;        
        self.sessionConfig         = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.sessionConfig.allowsCellularAccess              = NO;
        self.sessionConfig.timeoutIntervalForRequest         = 10;
        self.sessionConfig.timeoutIntervalForResource        = 10;
        self.sessionConfig.HTTPMaximumConnectionsPerHost     = 1;
    }
    return self;
}




-(void)start
{
    if ([self isCancelled]) {
        [self setFinished:YES];
        
    }
    [self setExecuting:YES];
    

    
    self.session = [NSURLSession sessionWithConfiguration:self.sessionConfig delegate:self delegateQueue:nil];
    [[self.session dataTaskWithRequest:self.request]resume];
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
    _isFinished = isFinished;
    [self didChangeValueForKey:@"isFinished"];
}

- (BOOL)isFinished
{
    return _isFinished || [self isCancelled];
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
    if (error) {
        self.error = error;
        self.success = NO;
    } else {
        self.success = YES;
    }
    
    if (self.onRequestComplete) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.onRequestComplete(self.cumulatedData,self);
        });
    }
    
    [self setExecuting:NO];
    [self setFinished:YES];
}

-(NSData*)resultData
{
    return (self.isFinished)?self.cumulatedData:nil;
}

@end


