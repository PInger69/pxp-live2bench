//
//  DownloadThumbnailOperation.m
//  Live2BenchNative
//
//  Created by dev on 2016-02-25.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "DownloadThumbnailOperation.h"
#import "PxpURLProtocol.h"
#import "MockURLProtocol.h"

@interface DownloadThumbnailOperation () <NSURLSessionDelegate,NSURLSessionDataDelegate,NSURLSessionTaskDelegate>
@property (nonatomic,strong) NSMutableData  * cumulatedData;
@property (nonatomic,strong) NSURLSession   * session;
@property (nonatomic,strong) NSURLRequest   * request;
@end

@implementation DownloadThumbnailOperation
{
    BOOL _isFinished;
    BOOL _isExecuting;
}



- (instancetype)initImageAssetManager:(ImageAssetManager*)aIAM url:(NSString*)aUrl
{
    self = [super init];
    if (self) {
        self.imageAssetManager      = aIAM;
        self.url                    = aUrl;
        _isExecuting                = NO;
        _isFinished                 = NO;
    }
    return self;
}

-(instancetype)initImageAssetManager:(ImageAssetManager*)aIAM url:(NSString*)aUrl imageView:(UIImageView*)aImageView
{
    self = [super init];
    if (self) {
        self.imageAssetManager      = aIAM;
        self.url                    = aUrl;
        
        self.imageView              = aImageView;
        _isExecuting                = NO;
        _isFinished                 = NO;
        
    }
    return self;
}

#pragma mark - Operation Methods
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
    
    NSURL * checkURL = [NSURL URLWithString:   self.url ];
    self.request    =  [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
    
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
    [self completeOperation];
}

- (void)completeOperation {
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    _isExecuting = NO;
    _isFinished  = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
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

    UIImage *receivedImage = [UIImage imageWithData:self.cumulatedData];
    
    if (error || !receivedImage) {
        self.error = error;
        if (error) {
            NSLog(@"Error %@",error);
        }
        self.success = NO;
    } else {
        NSLog(@"received image size %@: %.1fx%.1f", self.request.URL.path,
              receivedImage.size.width, receivedImage.size.height);
        [self.imageAssetManager.arrayOfClipImages setObject:receivedImage forKey:self.url];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = receivedImage;
        });
        self.success = YES;
    }
    [self completeOperation];
}



@end
