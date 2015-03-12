//
//  Downloader.m
//  Live2BenchNative
//
//  Created by dev on 2015-02-25.
//  Copyright (c) 2015 DEV. All rights reserved.
//

// This is a centeral class that is used to download
// this will listen for Notif and download files


#import "Downloader.h"



@implementation Downloader
{
    BOOL isDownloading;
}


@synthesize queue               = _queue;
@synthesize pause               = _pause;

static Downloader * _instance;
static void *  downLoaderContext = &downLoaderContext;


+(Downloader*)defaultDownloader
{
    if (!_instance) {
        _instance = [[Downloader alloc]init];
    }
    return _instance;
}


+(BOOL)deviceHasFreeSpace
{
    uint64_t                totalFreeSpace              = 0;
    __autoreleasing NSError * error                     = nil;
    NSArray                 * fileSystemPaths           = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary            * fileSystemDictionary      = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[fileSystemPaths lastObject] error: &error];
    NSNumber                * freeFileSystemSizeInBytes = [fileSystemDictionary objectForKey:NSFileSystemFreeSize];
    totalFreeSpace                                      = [freeFileSystemSizeInBytes unsignedLongLongValue];
    NSLog(@"The totalFreeSpace is %llu", totalFreeSpace / (1024 * 1024));
    return (totalFreeSpace > 500 * 1048576);
}


+(DownloadItem *)downloadTag:(NSString*)tagName
{
//s  DownloadItem * item = [DownloadItem alloc]initWithURL:<#(NSString *)#>
    
    return nil;
}


+(DownloadItem *)downloadURL:(NSString*)url to:(NSString*)path
{
    DownloadItem * item = [[DownloadItem alloc]initWithURL:url destination:path];
    [[Downloader defaultDownloader] addToQueue:item];
    return item;
}

+(DownloadItem *)downloadEvent:(NSString*)eventName
{
    return nil;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        _queue                  = [[NSMutableArray alloc]init];
        _pause                  = NO;
        isDownloading           = NO;
        
        _IOAlertView            = [[CustomAlertView alloc]init];
        
        [_IOAlertView setTitle:@"myplayXplay"];
        [_IOAlertView setMessage:@"There isn't enough space on the device."];
        [_IOAlertView addButtonWithTitle:@"Ok"];
        [_IOAlertView setDelegate:self];
    }
    return self;
}


-(void)addToQueue:(DownloadItem *)item
{
    [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:&downLoaderContext];
    [_queue addObject:item];
    if (!isDownloading){
        isDownloading = YES;
        [self process];
    }
    
}


-(void)removeFromQueue:(DownloadItem *)item
{
    [item removeObserver:self forKeyPath:@"status" context:&downLoaderContext];
    [_queue removeObject:item];
    isDownloading = NO;
}

-(void)process
{
    if(_pause)return; // don't process if paused
    
    
    // check again for space, if none... pause and show an alert if it has one
    if (![Downloader deviceHasFreeSpace]) {
        self.pause = NO;
        if (_IOAlertView) [_IOAlertView show];
        isDownloading = NO;
        [self removeFromQueue: [_queue lastObject]];
        NSLog(@"Device needs more space");
        return;
    }
    
    if ([_queue count]>0) {
        DownloadItem        * cItem = (DownloadItem *)[_queue objectAtIndex:0];
        [cItem start];
    }
}

#pragma mark -
#pragma mark Observer Methods


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    DownloadItem        * cItem = (DownloadItem *)object;
    
    switch (cItem.status) {
        case DownloadItemStatusIOError:
            if (_IOAlertView) [_IOAlertView show];
            self.pause = YES;
            break;
        case DownloadItemStatusComplete:
            //[[NSNotificationCenter defaultCenter] postNotificationName:@"finishDownloading" object:nil userInfo:@{@"dateString" : cItem.dateString}];
            [self removeFromQueue:cItem];
            break;
        case DownloadItemStatusCancel:
            break;
        case DownloadItemStatusError:
            [_IOAlertView setTitle:@"myplayXplay"];
            [_IOAlertView setMessage:[NSString stringWithFormat:@"Can't download the event %@", cItem.name]];
            //[_IOAlertView addButtonWithTitle:@"Ok"];
            [_IOAlertView setDelegate:self];
            [_IOAlertView show];
            [self removeFromQueue:cItem];
            [self process];
            break;
        case DownloadItemStatusWaiting:
            break;
        case DownloadItemStatusStart:
            break;
        case DownloadItemStatusProgress:
            break;
        default:
            break;
    }
    
    
    
}

#pragma mark -
#pragma mark Getter and setters Methods

-(void)setPause:(BOOL)pause
{
    if (pause == _pause)return;
    
    _pause = pause;
    
    if (!_pause) [self process];
}


-(BOOL)pause
{
    return _pause;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [CustomAlertView removeAlert:_IOAlertView];
}

@end
