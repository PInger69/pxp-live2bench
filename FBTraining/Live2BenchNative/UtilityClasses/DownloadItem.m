//
//  DownloadItem.m
//  Live2BenchNative
//
//  Created by dev on 2015-02-26.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "DownloadItem.h"
#import "Utility.h"





@implementation DownloadItem
{

}


@synthesize name;
@synthesize status = _status;
@synthesize progress = _progress;
@synthesize timeoutInterval = _timeoutInterval;
@synthesize freeSpaceBuffer = _freeSpaceBuffer;
@synthesize kbps;
@synthesize isAlive;

- (instancetype)initWithURL:(NSString*)aURL destination:(NSString*)aPath
{
    self = [super init];
    if (self) {
        self.isAlive        = YES;
        url                 = aURL;
        path                = aPath;
        self.status         = DownloadItemStatusWaiting;
        _progress           = 0;
        kbps                = 0;
        _timeoutInterval    = DEFAULT_TIMEOUT;
        _freeSpaceBuffer    = DEFAULT_FRAME_BUFFER_SIZE;
        downloadType        = DownloadItem_TypeVideo;
    }
    return self;
}


- (instancetype)initWithURL:(NSString*)aURL destination:(NSString*)aPath type:(DownloadType)aType
{
    self = [super init];
    if (self) {
        self.isAlive        = YES;
        url                 = aURL;
        path                = aPath;
        self.status         = DownloadItemStatusWaiting;
        _progress           = 0;
        kbps                = 0;
        _timeoutInterval    = DEFAULT_TIMEOUT;
        _freeSpaceBuffer    = DEFAULT_FRAME_BUFFER_SIZE;
        downloadType        = aType;
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
    
    
    
    if (downloadType == DownloadItem_TypeVideo){
    
         stream          = [[NSOutputStream alloc] initToFileAtPath:path append:YES];
        [stream open];
    
    } else if (downloadType == DownloadItem_TypePlist) {
        _data           = [[NSMutableData alloc]init];
    
    }
    
    
    

    


    startTime       = CACurrentMediaTime();
}

// this is the progress
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    _receivedBytes += data.length;
    
    NSUInteger left = [data length];
    

    if (downloadType == DownloadItem_TypeVideo){
        NSUInteger nwr = 0;
        do {
            nwr = [stream write:[data bytes] maxLength:left];
            if (-1 == nwr) break;
            left -= nwr;
        } while (left > 0);
        if (left) {
            NSLog(@"stream error: %@", [stream streamError]);
        }
    } else if (downloadType == DownloadItem_TypePlist) {
        [_data appendData:data];
        
    }
    
    

    
    
    self.status     = DownloadItemStatusProgress;
    self.progress   = (double)_receivedBytes / (double)_expectedBytes;
    if (progressBlock) progressBlock(self.progress, kbps);
    elapsedTime = CACurrentMediaTime() - startTime;
    kbps = ((double)_receivedBytes /  (double)elapsedTime) * 0.001;
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (stream)[stream close];
    
    if (downloadType == DownloadItem_TypePlist) {
        [self parseAndSavePlistTo:path data:_data];
    }
    
    self.status     = DownloadItemStatusComplete;
    self.progress   = 1;
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.status = DownloadItemStatusError;
    if (stream) [stream close];
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
    if (stream) [stream close];
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

/**
 *  This method adds a block to monitor the progress of a download if needed
 *
 *  @param pBlock progress gives a number from 0-1 based of the progress and kbps is kbps :)
 */
-(void)addOnProgressBlock:(void(^)(float progress,NSInteger kbps)) pBlock
{
    progressBlock = pBlock;
}

/**
 *  This takes in Data and converts to plist and saves to a location on the device
 *
 *  @param aPath where the final plist will be saved
 *  @param aData the JSON data that will be parsed
 */
-(void)parseAndSavePlistTo:(NSString*)aPath data:(NSMutableData*)aData
{
    NSDictionary * toPlist = [Utility JSONDatatoDict:(NSData *)aData];
    [toPlist writeToFile: aPath atomically:YES];
}

-(NSString*)stringStatus
{
    NSString * txt = @"";

    return txt;
}


-(void)dealloc
{
    self.isAlive = NO;
}

@end
