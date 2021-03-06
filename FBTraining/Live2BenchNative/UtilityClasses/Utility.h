//
//  Utility.h
//  Live2BenchNative
//
//  Created by dev on 10/3/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <AVFoundation/AVFoundation.h>
#import "DownloadItem.h"
@interface Utility : NSObject
//+(NSString*)timeToString:(CMTime)time;
+(NSString*)translateTimeFormat:(float)time;
+(NSString*)encodeSpecialCharacters:(NSString*)inputString;

+(NSString*)dictToJSON:(NSDictionary*)dict;
+(NSString*) dictToJsonWithoutEncoding:(NSDictionary*) dict;
+(NSString*)dictToJSON:(NSDictionary*)dict error:(NSError **)aError;
+(NSDictionary*)JSONDatatoDict:(NSData*)data;
+(NSDictionary*)JSONDatatoDict:(NSData*)data error:(NSError **)aError;
+(NSDictionary*)URLJSONStringDict:(NSString*)data;
+(float)sumOfVersion:(NSString*)version;
+(NSString *)stringFromHexString:(NSString *)hexString;
+(NSString *)stringToSha1:(NSString *)hashkey;
+(NSString*)sha256HashFor:(NSString*)input;
+(UIColor*)colorWithHexString:(NSString*)hex;
+(NSString *)hexStringFromColor:(UIColor *)color;
+(NSString*)encoderStatusToString:(int)status;
+(NSComparisonResult)compareVersion: (NSString *)version1 withVersion: (NSString *)version2;
+(NSString *)dateFromEvent: (NSString *) eventName;
+(NSString *)platformString;
+(BOOL)isDeviceBlurSupported:(NSString *)platform;
+(BOOL)isDeviceSupportedMultiCam:(NSString *)platform;
+(BOOL)hasInternet;
+(void)hasInternetOnComplete:(void (^)(BOOL succsess))onFinish;
+(NSString*)myWifiName;

//+(void)downloadEvent:(NSDictionary*)data sourceName:(NSString*)sourceName returnBlock:(void (^)(DownloadItem*item))block;
+(NSString*)removeSubString:(NSString*)substring in:(NSString*)main;

+(UIColor*)ligherColorOf:(UIColor*)color;
+(UIColor*)darkerColorOf:(UIColor*)color;

+(NSString *)getIPAddress;
+(BOOL)hasWiFi;

+(UIImage *)starImageSelected: (BOOL) selected size:(CGSize)size;
+(UIImage*)makeOnePixelUIImageWithColor:(UIColor*)color;


+(NSString*)downloadByteToStringHuman:(long long)byte;

@end


