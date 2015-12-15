//
//  DownloadOperation.h
//  Live2BenchNative
//
//  Created by dev on 2015-12-08.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadOperation : NSOperation <NSURLSessionDelegate,NSURLSessionDataDelegate,NSURLSessionTaskDelegate>
{
    BOOL        executing;
    BOOL        finished;
    NSOutputStream  *stream;
}

@property (nonatomic,strong)    NSURLSession    * session;
@property (nonatomic,strong)    NSURLRequest    * request;

@property (nonatomic,strong)    NSURL        * source;
@property (nonatomic,strong)    NSString        * destination;
@property (nonatomic,assign)    NSInteger       timeout;
@property (nonatomic,assign)    double          expectedBytes;
@property (nonatomic,assign)    double          receivedBytes;

@property (copy, nonatomic)     void(^onRequestProgress)(DownloadOperation* operation);
@property (copy, nonatomic)     void(^onRequestRecieved)(DownloadOperation* operation);

- (instancetype)initWith:(NSURL*)url destination:(NSString*)destination;

@end
