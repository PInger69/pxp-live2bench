//
//  PxpLog.h
//  Live2BenchNative
//
//  Created by dev on 2015-04-14.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PXPLog(s,...) [PxpLog log:(s),##__VA_ARGS__]
#define PXPDeviceLog(s,...) [PxpLog deviceLog:(s),##__VA_ARGS__]
#define PXPDeviceLogHash(hash,s,...) [PxpLog deviceLogID:(hash) msg:(s),##__VA_ARGS__]

#define PXPLogAjax(s,...) //[PxpLog log:@""], [PxpLog log:(s),##__VA_ARGS__]

#define CODE_ERROR @"!000"

@interface PxpLog : NSObject

@property (atomic,strong) NSMutableString * text;

+(void)log:(NSString*)log,...;
+(void)deviceLog:(NSString*)log,...;
+(void)deviceLogID:(NSString*)hash msg:(NSString*)log,...;
+(instancetype)getInstance;
+(NSMutableString*)output;
+(void)clear;
+(void)clearDeviceLog;
+(NSString*)deviceLogPath;

@end