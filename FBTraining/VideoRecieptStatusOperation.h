//
//  VideoRecieptStatusOperation.h
//  Live2BenchNative
//
//  Created by dev on 2016-08-26.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoRecieptStatusOperation : NSOperation <NSURLSessionDelegate,NSURLSessionDataDelegate,NSURLSessionTaskDelegate>
{
    BOOL        executing;
    BOOL        finished;
    NSOutputStream  *stream;
}

@property (nonatomic,strong) NSString * videoKey;
@property (nonatomic,strong) NSString * deviceID;
@property (nonatomic,strong) NSString * customerID;



@property (nonatomic,strong)    NSURLSession    * session;
@property (nonatomic,strong)   NSURLSessionDataTask *task;
@property (nonatomic,strong)    NSMutableURLRequest    * request;

@property (nonatomic,strong)    NSURL        * source;
@property (nonatomic,strong)    NSData        * data;
@property (nonatomic,strong)    NSError        * error;
@property (nonatomic,strong)    NSMutableData   * cumulatedData;
@property (nonatomic,strong)    NSDictionary   * rawData;




@property (copy, nonatomic)     void(^onRequestRecieved)(VideoRecieptStatusOperation* operation);

- (instancetype)initWithKey:(NSString*)videoKey device:(NSString*)deviceID customer:(NSString*)customerID;

@end
