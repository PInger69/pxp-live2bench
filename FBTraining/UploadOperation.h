//
//  UploadOperation.h
//  Live2BenchNative
//
//  Created by dev on 2016-08-17.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UploadOperation : NSOperation <NSURLSessionDelegate,NSURLSessionDataDelegate,NSURLSessionTaskDelegate>
{
    BOOL        executing;
    BOOL        finished;
    NSOutputStream  *stream;
}

@property (nonatomic,strong)    NSURLSession    * session;
@property (nonatomic,strong)   NSURLSessionDataTask *task;
@property (nonatomic,strong)    NSMutableURLRequest    * request;

@property (nonatomic,strong)    NSURL        * source;
@property (nonatomic,strong)    NSData        * data;
@property (nonatomic,strong)    NSMutableData   * cumulatedData;
@property (nonatomic,assign)    int64_t          expectedBytes;
@property (nonatomic,assign)    int64_t          sentBytes;

@property (nonatomic,strong) NSString * hTeam;
@property (nonatomic,strong) NSString * vTeam;
@property (nonatomic,strong) NSString * league;
@property (nonatomic,strong) NSString * clipName;
@property (nonatomic,strong) NSString * clipTime;
@property (nonatomic,strong) NSString * clipDate;



@property (copy, nonatomic)     void(^onRequestProgress)(UploadOperation* operation);
@property (copy, nonatomic)     void(^onRequestRecieved)(UploadOperation* operation);

- (instancetype)initWith:(NSURL*)urlDestination fileToBeUploaded:(NSURL*)videoURL;

- (instancetype)initWith:(NSURL*)urlDestination dataToBeUploaded:(NSData*)data;

@end

