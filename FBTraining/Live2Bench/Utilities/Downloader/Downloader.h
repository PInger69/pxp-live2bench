//
//  Downloader.h
//  Live2BenchNative
//
//  Created by dev on 2015-02-25.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadItem.h"
#import "VideoTrimItem.h"
#import "CustomAlertControllerQueue.h"

@interface Downloader : NSObject

@property (strong,nonatomic) UIAlertController      * alert;
@property (strong,nonatomic) NSMutableArray         * queue;
@property (assign,nonatomic) BOOL                   pause;
@property (strong,nonatomic) NSMutableDictionary    * keyedDownloadItems;


+(Downloader*)defaultDownloader;
+(DownloadItem *)downloadURL:(NSString*)url to:(NSString*)path;
+(DownloadItem *)downloadURL:(NSString*)url to:(NSString*)path type:(DownloadType)aType;
+(DownloadItem *)downloadURL:(NSString*)url to:(NSString*)path type:(DownloadType)aType key:(NSString*)aKey;
+(VideoTrimItem *)trimVideoURL: (NSString*)url to:(NSString*)path withTimeRange: (CMTimeRange) range;
+(VideoTrimItem *)trimVideoURL: (NSString*)url to:(NSString*)path withTimeRange: (CMTimeRange) range key:(NSString*)aKey;
-(void)addToQueue:(DownloadItem *)item;
-(void)addToQueue:(DownloadItem *)item key:(NSString*)key;
-(void)removeFromQueue:(DownloadItem *)item;
@end
