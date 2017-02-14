//
//  PostOperation.h
//  Live2BenchNative
//
//  Created by dev on 2016-04-15.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "BooleanOperation.h"

@interface PostOperation : BooleanOperation <NSURLSessionDelegate,NSURLSessionDataDelegate,NSURLSessionTaskDelegate>

@property(readonly, getter=isFinished)      BOOL finished;
@property(readonly, getter=isExecuting)     BOOL executing;

@property (nonatomic,strong) NSURLSessionConfiguration  * sessionConfig;
@property (nonatomic,strong) NSError                    * error;
@property (nonatomic,strong) NSURLSession               * session;
@property (nonatomic,strong) NSURLRequest               * request;
@property (copy, nonatomic)     void(^onRequestComplete)(NSData*,NSOperation*);

-(instancetype)initWithNSURLRequest:(NSURLRequest*)request;

-(NSData*)resultData;

@end
