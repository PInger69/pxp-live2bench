//
//  DownloadItem.h
//  Live2BenchNative
//
//  Created by dev on 2015-02-26.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#define DEFAULT_FRAME_BUFFER_SIZE   500
#define DEFAULT_TIMEOUT             120

typedef NS_OPTIONS(NSInteger, DownloadItemStatus) {
    DownloadItemStatusWaiting   = 1<<1,
    DownloadItemStatusStart     = 1<<2,
    DownloadItemStatusProgress  = 1<<3,
    DownloadItemStatusComplete  = 1<<4,
    DownloadItemStatusCancel    = 1<<5,
    DownloadItemStatusError     = 1<<6,
    DownloadItemStatusIOError   = 1<<7
};

typedef NS_OPTIONS(NSInteger, DownloadType) {
    DownloadItem_TypePlist   = 1<<1,
    DownloadItem_TypeVideo     = 1<<2
};


@interface DownloadItem : NSObject <NSURLConnectionDataDelegate,NSURLConnectionDelegate>
{

    NSUInteger      _expectedBytes;
    NSUInteger      _receivedBytes;
    NSString        * url;
    NSURLConnection * theConnection;
    NSString        * path;
    NSOutputStream  *stream;
    NSMutableData   * _data;
    
    void(^progressBlock)(float,NSInteger);
    
    // For kbsp
    CFTimeInterval startTime;
    CFTimeInterval elapsedTime;
    
    DownloadType    downloadType;


}
@property (nonatomic,strong) NSString           * name; // this is here for convenience
@property (nonatomic,assign) DownloadItemStatus status;
@property (nonatomic,assign) float              progress;
@property (nonatomic,assign) NSTimeInterval     timeoutInterval;
@property (nonatomic,assign) NSInteger          freeSpaceBuffer;
@property (nonatomic,assign) NSInteger          kbps;
@property (nonatomic,assign) BOOL               isAlive;

-(instancetype)initWithURL:(NSString*)aURL destination:(NSString*)aPath;

-(instancetype)initWithURL:(NSString*)aURL destination:(NSString*)aPath type:(DownloadType)aType;

-(void)start;
-(void)cancel;
-(void)addOnProgressBlock:(void(^)(float progress,NSInteger kbps)) pBlock;
-(NSString*)stringStatus;
@end
