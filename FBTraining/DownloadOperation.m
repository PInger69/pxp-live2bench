//
//  DownloadOperation.m
//  Live2BenchNative
//
//  Created by dev on 2015-12-08.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "DownloadOperation.h"

@interface DownloadOperation ()
@property (nonatomic,assign)    NSInteger       currentAttempt;
@property (nonatomic,strong)    NSOutputStream  *stream;
@end




@implementation DownloadOperation
@synthesize source      = _source;
@synthesize destination = _destination;

- (instancetype)init
{
    self = [super init];
    if (self) {
        executing               = NO;
        finished                = NO;
        self.timeout            = 30;
        self.request            = nil;
        self.attempts           = 5;
        self.currentAttempt     = 0;
    }
    return self;
}

- (instancetype)initWith:(NSURL*)url destination:(NSString*)destination
{
    self = [super init];
    if (self) {
        executing               = NO;
        finished                = NO;
        self.timeout            = 30;
        self.request            = nil;
        self.destination        = destination;
        self.source             = url;
        self.attempts           = 5;
        self.currentAttempt     = 0;
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
    
    self.session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];

    NSURLSessionDownloadTask * downloadTask = [self.session downloadTaskWithURL:self.source];
    PXPLog(@"%@",self.source);
    [downloadTask resume];
}


// On Attempt fail try again
-(void)restart
{
    _expectedBytes  = 0;
    _receivedBytes  = 0;
    NSURLSessionConfiguration *sessionConfig        = [[NSURLSessionConfiguration defaultSessionConfiguration]copy];;

//    [self.session invalidateAndCancel];
    self.session = nil;
    self.request = nil;
    
    self.session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
    NSURLSessionDownloadTask * downloadTask = [self.session downloadTaskWithURL:self.source];
    PXPLog(@"%@",self.source);
    [downloadTask resume];

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

-(BOOL)isReady
{
    return (self.source && self.destination);
}

-(void)setSource:(NSURL *)source
{

    [self willChangeValueForKey:@"isReady"];
    _source = source;
    [self didChangeValueForKey:@"isReady"];
}

-(void)setDestination:(NSString *)destination
{
    [self willChangeValueForKey:@"isReady"];
    _destination = destination;
    [self didChangeValueForKey:@"isReady"];

}


#pragma mark - Delegate methods Data Task



/*
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    
    if (!self.stream){
        _expectedBytes  = (double)dataTask.countOfBytesExpectedToReceive;
        
        if (_expectedBytes < 300) {
            // something is worng
            NSLog(@" download error");

        }
        
        // this is to overwirte the file
        if([[NSFileManager defaultManager] fileExistsAtPath:self.destination])
        {
            [[NSFileManager defaultManager] removeItemAtPath:self.destination error:nil];
        }
        
        self.stream          = [[NSOutputStream alloc] initToFileAtPath:self.destination append:YES];
        [self.stream open];
        if (self.onRequestRecieved) {
            self.onRequestRecieved(self);
        }
    }
    
    
    
    _receivedBytes += data.length;
    NSLog(@"Receiving...");
    
    NSUInteger left = [data length];
    NSUInteger nwr = 0;
    do {
        nwr = [self.stream write:[data bytes] maxLength:left];
        if (-1 == nwr) break;
        left -= nwr;
    } while (left > 0);
    if (left) {
        self.error = [self.stream streamError];
        PXPLog(@"stream error: %@", self.error);
        
    }

    if ([self isCancelled]) {
        [dataTask cancel];
        self.error = [[NSError alloc]initWithDomain:@"Download Cancelled" code:0 userInfo:nil];
        if (self.stream)[self.stream close];
        if([[NSFileManager defaultManager] fileExistsAtPath:self.destination])
        {
            [[NSFileManager defaultManager] removeItemAtPath:self.destination error:nil];
        }

    }
    
    if (self.onRequestProgress) {
        self.onRequestProgress(self);
    }
    
}
*/

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error) {
        NSLog(@"%s",__FUNCTION__);
    }
    
    
    
    if (error && self.currentAttempt <= self.attempts) {
        NSLog(@"DOWNLOAD Error %@",error);
        NSLog(@" URL %@",self.request);
        PXPLog(@"DOWNLOAD Error %@",error);
        self.error = error;
        self.currentAttempt += 1;
        [self restart];

        return;
    } else if (error) {
//        NSDictionary * userInfo = @{
//                                    NSLocalizedDescriptionKey:               @"Failed to cut clip on server.",
//                                    NSLocalizedFailureReasonErrorKey:        @"To many cut request simultaneously or cut request timed out.",
//                                    NSLocalizedRecoverySuggestionErrorKey:   @"Please try again later when server traffic is not over loaded."
//                                    };
//        NSError * aError = [[NSError alloc]initWithDomain:PxpErrorDomain code:DOWNLOAD_CLIP_ERROR userInfo:userInfo];
//        //
        if (self.onFail){
            self.onFail(error);
        }

        
    }
    [self.session finishTasksAndInvalidate];

    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    finished = YES;
    executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
    
}


-(void)cancel
{
 
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    finished = YES;
    executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

#pragma mark - Delegate methods Data Task

-(void)URLSession:(NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(nonnull NSURL *)location
{

    NSLog(@"%s didFinishDownloadingToURL",__FUNCTION__);
    // Finished downloading file move to folder
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSError * error;
    
    NSData *data = [NSData dataWithContentsOfURL:location];
    

    if ([data length] < 300){
        NSString* newStr = [NSString stringWithUTF8String:[data bytes]];
        NSLog(@"%@",newStr);
        if ([newStr containsString:@"404 Not Found"]) {
            NSLog(@"              FILE NOT FOUND!!!");
            return;
        }
    }


    [fileManager moveItemAtURL:location toURL:[NSURL fileURLWithPath:self.destination] error:&error];
}

-(void)URLSession:(NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    _expectedBytes  = (double)totalBytesExpectedToWrite;
    _receivedBytes  = (double)totalBytesWritten;
    
    if (self.onRequestProgress) {
        self.onRequestProgress(self);
    }
}


@end
