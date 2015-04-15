//
//  PxpLog.h
//  Live2BenchNative
//
//  Created by dev on 2015-04-14.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>


// Please make PxpLog(@"words") work

//#ifdef DEBUG
//#   define PxpLog(...) NSLog(__VA_ARGS__)
//#else
//#   define PxpLog(...)
//#endif


@interface PxpLog : NSObject

@property (nonatomic,strong) NSMutableString * text;

+(void)log:(NSString*)log;
+(instancetype)getInstance;
+(NSMutableString*)output;
@end
