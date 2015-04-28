//
//  Utility.h
//  Live2BenchNative
//
//  Created by dev on 10/3/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadItem.h"
@interface Utility : NSObject
+(NSString*)translateTimeFormat:(float)time;
+(NSString*)encodeSpecialCharacters:(NSString*)inputString;
+(NSString*)dictToJSON:(NSDictionary*)dict;
+(NSDictionary*)JSONDatatoDict:(NSData*)data;
+(float)sumOfVersion:(NSString*)version;
+(NSString *)stringFromHexString:(NSString *)hexString;
+(NSString *)stringToSha1:(NSString *)hashkey;
+(NSString*)sha256HashFor:(NSString*)input;
+(UIColor*)colorWithHexString:(NSString*)hex;
+(NSString*)encoderStatusToString:(int)status;
+(NSComparisonResult)compareVersion: (NSString *)version1 withVersion: (NSString *)version2;
+(NSString *)dateFromEvent: (NSString *) eventName;

+(BOOL)hasInternet;
+(NSString*)myWifiName;

+(void)downloadEvent:(NSDictionary*)data sourceName:(NSString*)sourceName returnBlock:(void (^)(DownloadItem*item))block;

@end


