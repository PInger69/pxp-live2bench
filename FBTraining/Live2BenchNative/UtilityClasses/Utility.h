//
//  Utility.h
//  Live2BenchNative
//
//  Created by dev on 10/3/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

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
+(NSDictionary*)tagDict;
//+(NSString*)cmTimeToString:(CMTime)time;



@end
