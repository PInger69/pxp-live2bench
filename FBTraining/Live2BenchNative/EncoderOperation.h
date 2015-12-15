//
//  EncoderOperation.h
//  Live2BenchNative
//
//  Created by dev on 2015-10-13.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EncoderParseProtocol.h"
#import "Encoder.h" // this should be a Protocol

@interface EncoderOperation : NSOperation <NSURLSessionDelegate,NSURLSessionDataDelegate,NSURLSessionTaskDelegate>


#pragma mark - NSOperation Methods
@property(readonly, getter=isFinished)      BOOL finished;
@property(readonly, getter=isAsynchronous)  BOOL asynchronous;
@property(readonly, getter=isExecuting)     BOOL executing;

#pragma mark - EncoderOperation Methods

@property (nonatomic,weak)      Encoder         * encoder;
@property (nonatomic,assign)    ParseMode       parseMode;

@property (nonatomic,strong)    NSURLSession    * session;
@property (nonatomic,strong)    NSNumber        * timeStamp;
@property (nonatomic,assign)    NSTimeInterval  timeout;
@property (nonatomic,strong)    NSMutableData   * cumulatedData;
@property (nonatomic,strong)    NSURLRequest   * request;
@property (copy, nonatomic)     void(^onRequestComplete)(NSData*,EncoderOperation*);
@property (nonatomic,strong)    NSDictionary    * userInfo; // this is for data or classes that need to be sent back to the operaion


-(instancetype)initEncoder:(Encoder*)aEncoder data:(NSDictionary*)aData;

@end


#pragma mark - EncoderOperation Master Types

@interface EncoderOperationStart : EncoderOperation
@end

@interface EncoderOperationStop : EncoderOperation
@end

@interface EncoderOperationPause : EncoderOperation
@end

@interface EncoderOperationResume : EncoderOperation
@end

@interface EncoderOperationShutdown : EncoderOperation
@end

#pragma mark - EncoderOperation Types

@interface EncoderOperationGetVersion : EncoderOperation
@end

@interface EncoderOperationGetPastEvents : EncoderOperation
@end


@interface EncoderOperationDeleteEvent : EncoderOperation
@end

@interface EncoderOperationModTag : EncoderOperation
@end

@interface EncoderOperationMakeMP4fromTag : EncoderOperation
@end

@interface EncoderOperationMakeTag : EncoderOperation
@end
