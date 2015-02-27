//
//  DownloadItem.m
//  Live2BenchNative
//
//  Created by dev on 2015-02-26.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "DownloadItem.h"

#define DEFAULT_FRAME_BUFFER_SIZE   500
#define DEFAULT_TIMEOUT             120



@implementation DownloadItem
{
    NSUInteger      _expectedBytes;
    NSUInteger      _receivedBytes;
    NSString        * url;
    NSURLConnection * theConnection;
    NSString        * path;
    NSOutputStream  *stream;
    void(^progressBlock)(float,NSInteger);
    
    // For kbsp
    CFTimeInterval startTime;
    CFTimeInterval elapsedTime;
}


@synthesize name;
@synthesize status = _status;
@synthesize progress = _progress;
@synthesize timeoutInterval = _timeoutInterval;
@synthesize freeSpaceBuffer = _freeSpaceBuffer;
@synthesize kbps;


- (instancetype)initWithURL:(NSString*)aURL destination:(NSString*)aPath
{
    self = [super init];
    if (self) {
        url                 = aURL;
        path                = aPath;
        self.status         = DownloadItemStatusWaiting;
        _progress           = 0;
        kbps                = 0;
        _timeoutInterval    = DEFAULT_TIMEOUT;
        _freeSpaceBuffer    = DEFAULT_FRAME_BUFFER_SIZE;
    }
    return self;
}



#pragma mark -
#pragma mark NSURL Connection  Methods


// first connection
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
    _expectedBytes  = (NSUInteger)response.expectedContentLength;
    
    // this is to overwirte the file
    if([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }

    
    // this pauses the download if there is inifficient space on the device // you can resume the download by [Downloader defaultDownloder].pause = NO;
    if (![self deviceHasFreeSpace:_freeSpaceBuffer andItemSize:_expectedBytes]){
        self.status     = DownloadItemStatusIOError;
        [connection cancel];
        return;
    }
    
    self.status     = DownloadItemStatusStart;
    _receivedBytes  = 0;
    stream          = [[NSOutputStream alloc] initToFileAtPath:path append:YES];
    [stream open];
    startTime       = CACurrentMediaTime();
}

// this is the progress
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    _receivedBytes += data.length;
    
    NSUInteger left = [data length];
    NSUInteger nwr = 0;
    do {
        nwr = [stream write:[data bytes] maxLength:left];
        if (-1 == nwr) break;
        left -= nwr;
    } while (left > 0);
    if (left) {
        NSLog(@"stream error: %@", [stream streamError]);
    }
    self.status     = DownloadItemStatusProgress;
    self.progress   = (float)_receivedBytes / (float)_expectedBytes;
    if (progressBlock) progressBlock(self.progress, kbps);
    


    elapsedTime = CACurrentMediaTime() - startTime;
    
    
    kbps = ((float)_receivedBytes /  (float)elapsedTime) * 0.001;
    
//    startTime = CACurrentMediaTime();
    
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [stream close];
    self.status     = DownloadItemStatusComplete;
    self.progress   = 1;
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.status = DownloadItemStatusError;
    [stream close];
    // delete file if partly downloaded
    if([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
}

#pragma mark -
#pragma mark Class Methods


-(void)start
{
    NSURLRequest *urlRequest;
    urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:_timeoutInterval];
    theConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    [theConnection start];
}

-(void)cancel
{
    self.status     = DownloadItemStatusCancel;
    [stream close];
    [theConnection cancel];
   
    // delete file if partly downloaded
    if([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
}


-(void)setStatus:(DownloadItemStatus)status
{
    if (_status==status)return;
    [self willChangeValueForKey:NSStringFromSelector(@selector(status))];
    _status = status;
    [self didChangeValueForKey:NSStringFromSelector(@selector(status))];

}


-(DownloadItemStatus)status
{
    return _status;
}



-(BOOL)deviceHasFreeSpace:(NSInteger)buffer andItemSize:(NSInteger)itemSize
{
    uint64_t                totalFreeSpace              = 0;
    __autoreleasing NSError * error                     = nil;
    NSArray                 * fileSystemPaths           = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary            * fileSystemDictionary      = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[fileSystemPaths lastObject] error: &error];
    NSNumber                * freeFileSystemSizeInBytes = [fileSystemDictionary objectForKey:NSFileSystemFreeSize];
    totalFreeSpace                                      = [freeFileSystemSizeInBytes unsignedLongLongValue];
    return (totalFreeSpace-itemSize > buffer * 1048576);
}


-(void)addOnProgressBlock:(void(^)(float progress,NSInteger kbps)) pBlock
{
    progressBlock = pBlock;
}


@end
