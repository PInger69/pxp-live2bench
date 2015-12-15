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
@synthesize keyedDownloadItems  = _keyedDownloadItems;

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
    PXPLog(@"The totalFreeSpace is %llu", totalFreeSpace / (1024 * 1024));
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

+(DownloadItem *)downloadURL:(NSString*)url to:(NSString*)path type:(DownloadType)aType
{
    DownloadItem * item = [[DownloadItem alloc]initWithURL:url destination:path type:aType];
    [[Downloader defaultDownloader] addToQueue:item];
    return item;
}

+(DownloadItem *)downloadURL:(NSString*)url to:(NSString*)path type:(DownloadType)aType key:(NSString*)aKey
{
    DownloadItem * item = [[DownloadItem alloc]initWithURL:url destination:path type:aType];
    [[Downloader defaultDownloader] addToQueue:item key:aKey];
    return item;
}

+(VideoTrimItem *)trimVideoURL: (NSString*)url to:(NSString*)path withTimeRange: (CMTimeRange) range{
    VideoTrimItem *item = [[VideoTrimItem alloc] initWithVideoURLString:url destination:path andTimeRange:range];
    [[Downloader defaultDownloader] addToQueue:item];
    return item;
}

+(VideoTrimItem *)trimVideoURL: (NSString*)url to:(NSString*)path withTimeRange: (CMTimeRange) range key:(NSString*)aKey{
    VideoTrimItem *item = [[VideoTrimItem alloc] initWithVideoURLString:url destination:path andTimeRange:range];
    [[Downloader defaultDownloader] addToQueue:item key:aKey];
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
        _keyedDownloadItems     = [[NSMutableDictionary alloc]init];
        _queue                  = [[NSMutableArray alloc]init];
        _pause                  = NO;
        isDownloading           = NO;
        
        _IOAlertView            = [[CustomAlertView alloc]init];
        _IOAlertView.type = AlertNotification;
        
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

-(void)addToQueue:(DownloadItem *)item key:(NSString *)key
{
    [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:&downLoaderContext];
    [_queue addObject:item];
    if (!isDownloading){
        isDownloading = YES;
        [self process];
    }
    item.key = key;
    [_keyedDownloadItems setObject:item forKey:key];
}


-(void)removeFromQueue:(DownloadItem *)item
{
    [item removeObserver:self forKeyPath:@"status" context:&downLoaderContext];
    [_queue removeObject:item];
    if (item.key)[_keyedDownloadItems removeObjectForKey:item.key];
    isDownloading = NO;
    
    if (_queue.count > 0) {
        [self process];
    }else{
        isDownloading = NO;
    }
}

-(void)process
{
    if(_pause)return; // don't process if paused
    
    
    // check again for space, if none... pause and show an alert if it has one
    if (![Downloader deviceHasFreeSpace]) {
        self.pause = NO;
        if (_IOAlertView) {
            if (![_IOAlertView display]) {
                [_IOAlertView display];
                [CustomAlertView removeAlert:_IOAlertView];
            }
        }
        isDownloading = NO;
        [self removeFromQueue: [_queue lastObject]];
        PXPLog(@"Device needs more space");
        dispatch_async(dispatch_get_main_queue(), ^{
        CustomAlertView *alert = [[[CustomAlertView alloc]initWithTitle:@"Insufficient space"
                                                               message:@"Please clear up some space and try again."
                                                              delegate:nil
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil, nil] showView];

        });
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
            if (_IOAlertView) {
                if (![_IOAlertView display]) {
                    [CustomAlertView removeAlert:_IOAlertView];
                }
            };
            self.pause = YES;
            break;
        case DownloadItemStatusComplete:
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_DOWNLOAD_COMPLETE object:cItem];
            [self removeFromQueue:cItem];
            break;
        case DownloadItemStatusCancel:
            break;
        case DownloadItemStatusError:
            {
                [_IOAlertView setTitle:@"myplayXplay"];
                NSString * msg;
                if (cItem.name) {
                    msg = [NSString stringWithFormat:@"Can't download the event/clip %@", cItem.name];
                } else {
                    msg = [NSString stringWithFormat:@"Can't download the event/clip"];
                }
                
                [_IOAlertView setMessage:msg];
                //[_IOAlertView addButtonWithTitle:@"Ok"];
                [_IOAlertView setDelegate:self];
                if (![_IOAlertView display]) {
                    [CustomAlertView removeAlert:_IOAlertView];
                }
                [self removeFromQueue:cItem];
                [self process];
            }
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


- (void)alertView:(CustomAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [alertView viewFinished];
    [CustomAlertView removeAlert:_IOAlertView];
}

@end
