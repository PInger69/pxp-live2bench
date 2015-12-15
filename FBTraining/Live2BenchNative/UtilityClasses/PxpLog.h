//
//  PxpLog.h
//  Live2BenchNative
//
//  Created by dev on 2015-04-14.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PXPLog(s,...) [PxpLog log:(s),##__VA_ARGS__]

#define PXPLogAjax(s,...) //[PxpLog log:@""], [PxpLog log:(s),##__VA_ARGS__]

@interface PxpLog : NSObject

@property (atomic,strong) NSMutableString * text;

+(void)log:(NSString*)log,...;
+(instancetype)getInstance;
+(NSMutableString*)output;
+(void)clear;
@end