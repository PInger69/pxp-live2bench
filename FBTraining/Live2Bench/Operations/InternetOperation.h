//
//  InternetOperation.h
//  Live2BenchNative
//
//  Created by dev on 2016-04-15.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "BooleanOperation.h"

@interface InternetOperation : BooleanOperation <NSURLSessionDelegate,NSURLSessionDataDelegate,NSURLSessionTaskDelegate>

@property (nonatomic,strong) NSError * error;
@property (nonatomic,strong)    NSMutableData   * cumulatedData;
@property (nonatomic,strong)    NSURLSession    * session;
@property (nonatomic,strong)    NSURLRequest   * request;
@property (nonatomic,copy) void(^checkIfInternet)(BOOL hasInternet,NSError * error);


@end
