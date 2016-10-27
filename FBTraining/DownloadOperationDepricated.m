//
//  DownloadOperationDepricated.m
//  Live2BenchNative
//
//  Created by dev on 2016-10-14.
//  Copyright © 2016 DEV. All rights reserved.
//



#import "DownloadOperationDepricated.h"


@interface DownloadOperationDepricated () <NSURLConnectionDelegate,NSURLConnectionDataDelegate>
@property (nonatomic,assign)    NSInteger       currentAttempt;
@property (nonatomic,strong)    NSURLConnection    *   theConnection;
@property (nonatomic,strong)    NSOutputStream  *stream;
@end

@implementation DownloadOperationDepricated


- (instancetype)init
{
    self = [super init];
    if (self) {
        executing               = NO;
        finished                = NO;
        self.timeout            = 30;
        self.request            = nil;
        self.attempts           = 3;
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
        self.attempts           = 3;
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
    
    
    
//    [self willChangeValueForKey:@"isFinished"];
//    [self willChangeValueForKey:@"isExecuting"];
//    
//    
//    executing = NO;
//    
//    finished = YES;
//    
//    [self didChangeValueForKey:@"isExecuting"];
//    [self didChangeValueForKey:@"isFinished"];
//    return;
    
    self.expectedBytes  = 0;
    self.receivedBytes  = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
    
        self.request = [NSURLRequest requestWithURL:self.source  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:self.timeout];
        self.theConnection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self];
        [self.theConnection start];
    });
}


// On Attempt fail try again
-(void)restart
{
    self.expectedBytes  = 0;
    self.receivedBytes  = 0;
    
    [self.theConnection cancel];
    self.theConnection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self];
    [self.theConnection start];
}

-(void)main
{
    NSLog(@"%s",__FUNCTION__);
    [super main];
    
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



#pragma mark -
#pragma mark NSURL Connection  Methods


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{

    if (!self.stream){
        self.expectedBytes  = (NSUInteger)response.expectedContentLength;
        
        if (self.expectedBytes < 300) {
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

}


-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    
    self.receivedBytes += data.length;
    NSLog(@"Receiving...");
    if (self.expectedBytes < 300) {
        // something is worng
        NSString* newStr = [NSString stringWithUTF8String:[data bytes]];
        NSLog(@" download error");
        
    }
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
        [self.theConnection cancel];
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

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    

    
    if (self.stream)[self.stream close];
    
    [self.theConnection cancel];
    
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    finished = YES;
    executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
    

}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
    if (self.stream)[self.stream close];
    
    if (error) {
        NSLog(@"%s",__FUNCTION__);
        
    }
    
    
    if (error && self.currentAttempt < self.attempts) {
        NSLog(@"DOWNLOAD Error %@",error);
        PXPLog(@"DOWNLOAD Error %@",error);
        self.error = error;
        self.currentAttempt += 1;
        [self restart];
        return;
    }
    [self.theConnection cancel];
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    finished = YES;
    executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
    

}



@end
