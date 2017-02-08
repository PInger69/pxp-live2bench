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
#import "EncoderProtocol.h"
#import "BooleanOperation.h"
#import "TagProtocol.h"

@interface EncoderOperation : BooleanOperation <NSURLSessionDelegate,NSURLSessionDataDelegate,NSURLSessionTaskDelegate>


#pragma mark - NSOperation Methods
@property(readonly, getter=isFinished)      BOOL finished;
//@property(readonly, getter=isAsynchronous)  BOOL asynchronous;
@property(readonly, getter=isExecuting)     BOOL executing;

#pragma mark - EncoderOperation Methods

@property (nonatomic,strong)    id <EncoderProtocol> encoder;
@property (nonatomic,assign)    ParseMode       parseMode;

@property (nonatomic,strong)    NSURLSession    * session;
@property (nonatomic,strong)    NSNumber        * timeStamp;
@property (nonatomic,assign)    NSTimeInterval  timeout;
@property (nonatomic,strong)    NSMutableData   * cumulatedData;
@property (nonatomic,strong)    NSURLRequest   * request;
@property (copy, nonatomic)     void(^onRequestComplete)(NSData*,EncoderOperation*);
@property (nonatomic,strong)    NSDictionary    * userInfo; // this is for data or classes that need to be sent back to the operaion
@property (nonatomic,strong)    NSError         * error;
@property (nonatomic,strong)    NSDictionary    * argData;

-(instancetype)initEncoder:(id <EncoderProtocol>)aEncoder data:(NSDictionary*)aData;

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

@interface EncoderOperationAuthenticate : EncoderOperation
- (instancetype)initEncoder:(id <EncoderProtocol>)aEncoder customerID:(NSString*)customerID;
@end

@interface EncoderOperationGetPastEvents : EncoderOperation
@end

@interface EncoderOperationGetEventTags : EncoderOperation
@end


@interface EncoderOperationDeleteEvent : EncoderOperation
@end



@interface EncoderOperationModTag : EncoderOperation
@property (nonatomic,weak) id <TagProtocol>  tag;
- (instancetype)initEncoder:(id <EncoderProtocol>)aEncoder tag:(id <TagProtocol>)tag;
- (instancetype)initEncoder:(id <EncoderProtocol>)aEncoder data:(NSDictionary*)aData tag:(id <TagProtocol>)tag;
@end

@interface EncoderOperationCloseTag : EncoderOperation
@property (nonatomic,weak) Tag * tag;
@property (nonatomic,strong) NSDictionary* tagData;
- (instancetype)initEncoder:(id <EncoderProtocol>)aEncoder tag:(Tag*)tag;
//- (instancetype)initEncoder:(id <EncoderProtocol>)aEncoder data:(NSDictionary*)aData tag:(Tag*)tag;
@end


@interface EncoderOperationMakeMP4fromTag : EncoderOperation

@end

@interface EncoderOperationMakeTag : EncoderOperation
@property (nonatomic,strong) NSDictionary* tagData;
@property (nonatomic,assign)    BOOL generateProxyTag;
@end

@interface EncoderOperationStartGameTag : EncoderOperation
@end


@interface EncoderOperationMakeTelestration : EncoderOperation

@end


@interface EncoderOperationCameraData : EncoderOperation
@end

@interface EncoderOperationCameraStartTimes : EncoderOperation
@end


@interface EncoderOperationCheckSpace : EncoderOperation
@end

@interface EncoderOperationStatAndSync : EncoderOperation
@end


@interface EncoderOperationLocalTagPost : EncoderOperation
@property (nonatomic,strong) NSDictionary* tagData;
@property (nonatomic,strong) NSString* tagHash;
@property (nonatomic,strong) NSString* type;

-(instancetype)initTagData:(NSDictionary*)tagData;
-(instancetype)initTagModData:(NSDictionary*)tagData;
-(void)updateWithEncoder:(id<EncoderProtocol>)aEncoder;
@end





