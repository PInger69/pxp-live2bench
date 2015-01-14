//
//  Utility.m
//  Live2BenchNative
//
//  Created by dev on 10/3/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "Utility.h"

#import <CommonCrypto/CommonDigest.h>


@implementation Utility


//translate seconds to hh:mm:ss format
+(NSString*)translateTimeFormat:(float)time{
    NSUInteger dTotalSeconds = fabsf(time);
    NSUInteger dHours = floor(dTotalSeconds / 3600);
    NSUInteger dMinutes = floor(dTotalSeconds % 3600 / 60);
    NSUInteger dSeconds = floor(dTotalSeconds % 3600 % 60);
    NSString *displayTime;
    if (time < 0) {
        if (dHours > 0) {
            displayTime = [NSString stringWithFormat:@"-%i:%02i:%02i",dHours, dMinutes, dSeconds];
        }else{
            displayTime = [NSString stringWithFormat:@"-%02i:%02i", dMinutes, dSeconds];
        }
    }else{
        if (dHours > 0) {
            displayTime = [NSString stringWithFormat:@"%i:%02i:%02i",dHours, dMinutes, dSeconds];
        }else{
            displayTime = [NSString stringWithFormat:@"%02i:%02i", dMinutes, dSeconds];
        }
    }
    return displayTime;
}


+(NSString *)encodeSpecialCharacters:(NSString*)inputString
{
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                    NULL,
                                                                                                    (CFStringRef)inputString ,
                                                                                                    NULL,
                                                                                                    (CFStringRef)@"/#%^{}|`\"\\?",
                                                                                                    kCFStringEncodingUTF8 ));
    return encodedString;
}



+(NSString*)dictToJSON:(NSDictionary*)dict
{
    NSError *error;
    NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mutableDict options:0 error:&error];
    NSString *jsonString;
    if (jsonData) {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    } else {
        NSLog(@"JSON Error in Encoder");
    }
    
    return jsonString;
}

+(NSDictionary*)JSONDatatoDict:(NSData*)data
{
    NSDictionary *results;
    if(NSClassFromString(@"NSJSONSerialization"))
    {
        NSError *error = nil;
        id object = [NSJSONSerialization
                     JSONObjectWithData:data
                     options:0
                     error:&error];
        
        if(error) { /* JSON was malformed, act appropriately here */ }
        
        // the originating poster wants to deal with dictionaries;
        // assuming you do too then something like this is the first
        // validation step:
        if([object isKindOfClass:[NSDictionary class]])
        {
            results = object;
            /* proceed with results as you like; the assignment to
             an explicit NSDictionary * is artificial step to get
             compile-time checking from here on down (and better autocompletion
             when editing). You could have just made object an NSDictionary *
             in the first place but stylistically you might prefer to keep
             the question of type open until it's confirmed */
        }
        else
        {
            /* there's no guarantee that the outermost object in a JSON
             packet will be a dictionary; if we get here then it wasn't,
             so 'object' shouldn't be treated as an NSDictionary; probably
             you need to report a suitable error condition */
        }
    }
    else
    {
        // the user is using iOS 4; we'll need to use a third-party solution.
        // If you don't intend to support iOS 4 then get rid of this entire
        // conditional and just jump straight to
        // NSError *error = nil;
        // [NSJSONSerialization JSONObjectWithData:...
    }
    return results;
}


+(float)sumOfVersion:(NSString*)input
{
//    NSLog(@"Utility Class: sumOfVersion version check depricated");
    
    NSArray *numbers = [input componentsSeparatedByString:@"."];
    float sum = 0;
    for (NSString *number in numbers) {
        sum += [number floatValue];
    }
    return sum;
}


//transfer hexstring to string
+(NSString *)stringFromHexString:(NSString *)hexString {
    
    NSString * str = hexString;
    NSMutableString * newString = [[NSMutableString alloc] init];
    int i = 0;
    while (i < [str length])
    {
        NSString * hexChar = [str substringWithRange: NSMakeRange(i, 2)];
        int value = 0;
        sscanf([hexChar cStringUsingEncoding:NSASCIIStringEncoding], "%x", &value);
        [newString appendFormat:@"%c", (char)value];
        i+=2;
    }
    return newString;
}


+(NSString *)stringToSha1:(NSString *)hashkey{
    
    // Using UTF8Encoding
    const char *s = [hashkey cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *keyData = [NSData dataWithBytes:s length:strlen(s)];
    
    // This is the destination
    uint8_t digest[CC_SHA1_DIGEST_LENGTH] = {0};
    // This one function does an unkeyed SHA1 hash of your hash data
    CC_SHA1(keyData.bytes, keyData.length, digest);
    
    // Now convert to NSData structure to make it usable again
    NSData *out = [NSData dataWithBytes:digest
                                 length:CC_SHA1_DIGEST_LENGTH];
    // description converts to hex but puts <> around it and spaces every 4bytes
    NSString *hash = [out description];
    hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
    // hash is now a string with just the 40char hash value in it
    
    return hash;
}


+(NSString*)sha256HashFor:(NSString*)input
{
    const char* str = [input UTF8String];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(str, strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_SHA256_DIGEST_LENGTH; i++)
    {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}


+(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

+(NSString*)encoderStatusToString:(int)status
{
    if (status ==0) return @"ENCODER_STATUS_UNKNOWN";
    NSString * result = @"";

    if (1<<0 & status)       result = [NSString stringWithFormat:@"%@ %@",result ,@"ENCODER_STATUS_INIT"];            //encoder is initializing (pxpservice just started)
    if (1<<1 & status)       result = [NSString stringWithFormat:@"%@ %@",result ,@"ENCODER_STATUS_CAM_LOADING"];     //the camera is initializing (searching for teradek cube's or matrox monarch's)
    if (1<<2 & status)       result = [NSString stringWithFormat:@"%@ %@",result ,@"ENCODER_STATUS_READY"];           //encoder is ready to start an event
    if (1<<3 & status)       result = [NSString stringWithFormat:@"%@ %@",result ,@"ENCODER_STATUS_LIVE"];            //there is a live event
    if (1<<4 & status)       result = [NSString stringWithFormat:@"%@ %@",result ,@"ENCODER_STATUS_SHUTDOWN"];        //encoder is shutting down
    if (1<<5 & status)       result = [NSString stringWithFormat:@"%@ %@",result ,@"ENCODER_STATUS_PAUSED"];          //the live event is paused
    if (1<<6 & status)       result = [NSString stringWithFormat:@"%@ %@",result ,@"ENCODER_STATUS_STOP"];            //live event is stopping
    if (1<<7 & status)       result = [NSString stringWithFormat:@"%@ %@",result ,@"ENCODER_STATUS_START"];           //live event starting
    if (1<<8 & status)       result = [NSString stringWithFormat:@"%@ %@",result ,@"ENCODER_STATUS_NOCAM"];            //no camera found
    if (1<<10 & status)      result = [NSString stringWithFormat:@"%@ %@",result ,@"ENCODER_STATUS_LOCAL"];            //no camera found

    return result;
}

//+(NSString*)cmTimeToString:(CMTime)time
//{
//    NSString * txt;
//    
//    return txt;
//}

+(NSComparisonResult)compareVersion:(NSString *)versionNum1 with:(NSString*)versionNum2
{
//    NSInteger (^cmpGroup)(NSString *grp1,NSString *grp2) = ^NSInteger(NSString *grp1,NSString *grp2) {
//    
//        NSInteger n1 = [string componentsSeparatedByString: @";"]
//        
//        return
//    };
//
//    
//    return (NSComparisonResult)1;
}



/**
 *  This makes a NSDictionary of basic data for taging
 */
+(NSDictionary*)tagDict
{}

@end
