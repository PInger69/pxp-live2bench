//
//  DownloadItem.h
//  Live2BenchNative
//
//  Created by dev on 2015-02-26.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSInteger, DownloadItemStatus) {
    DownloadItemStatusWaiting   = 1<<1,
    DownloadItemStatusStart     = 1<<2,
    DownloadItemStatusProgress  = 1<<3,
    DownloadItemStatusComplete  = 1<<4,
    DownloadItemStatusCancel    = 1<<5,
    DownloadItemStatusError     = 1<<6,
    DownloadItemStatusIOError   = 1<<7
};


@interface DownloadItem : NSObject <NSURLConnectionDataDelegate,NSURLConnectionDelegate>

@property (nonatomic,assign) NSString           * name; // this is here for convenience
@property (nonatomic,assign) DownloadItemStatus status;
@property (nonatomic,assign) float              progress;
@property (nonatomic,assign) NSTimeInterval     timeoutInterval;
@property (nonatomic,assign) NSInteger          freeSpaceBuffer;
@property (nonatomic,assign) NSInteger          kbps;

-(instancetype)initWithURL:(NSString*)aURL destination:(NSString*)aPath;
-(void)start;
-(void)cancel;
-(void)addOnProgressBlock:(void(^)(float progress,NSInteger kbps)) pBlock;

@end
