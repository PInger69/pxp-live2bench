//
//  Downloader.h
//  Live2BenchNative
//
//  Created by dev on 2015-02-25.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomAlertView.h"
#import "DownloadItem.h"

@interface Downloader : NSObject


@property (strong,nonatomic) CustomAlertView * IOAlertView;             // No space on device
@property (strong,nonatomic) NSMutableArray  * queue;
@property (assign,nonatomic) BOOL            pause;

+(Downloader*)defaultDownloader;
+(DownloadItem *)downloadURL:(NSString*)url to:(NSString*)path;
+(DownloadItem *)downloadURL:(NSString*)url to:(NSString*)path type:(DownloadType)aType;

-(void)addToQueue:(DownloadItem *)item;
-(void)removeFromQueue:(DownloadItem *)item;
@end
