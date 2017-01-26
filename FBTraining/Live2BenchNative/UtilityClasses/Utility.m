//
//  Utility.m
//  Live2BenchNative
//
//  Created by dev on 10/3/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "Utility.h"

#import <CommonCrypto/CommonDigest.h>
#import "SystemConfiguration/SystemConfiguration.h"
#import <sys/types.h>
#import <sys/sysctl.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import "sys/socket.h"
#import "netinet/in.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "InternetMonitor.h"

#import <AssetsLibrary/AssetsLibrary.h>

@implementation Utility

static InternetMonitor* internetMonitor;

+(void)initialize
{
    // Internet Checking
//    NSTimer * timem = [NSTime alloc]initWithFireDate:<#(nonnull NSDate *)#> interval:<#(NSTimeInterval)#> target:<#(nonnull id)#> selector:<#(nonnull SEL)#> userInfo:<#(nullable id)#> repeats:<#(BOOL)#>
    internetMonitor = [[InternetMonitor alloc]init];
}

//translate seconds to hh:mm:ss format
+(NSString*)translateTimeFormat:(float)time{
    
    NSUInteger dTotalSeconds = fabsf(time);
    NSUInteger dHours = floor(dTotalSeconds / 3600);
    NSUInteger dMinutes = floor(dTotalSeconds % 3600 / 60);
    NSUInteger dSeconds = floor(dTotalSeconds % 3600 % 60);
    NSString *displayTime;
    if (dHours == 0 && dMinutes == 0 && dSeconds == 0) {
        displayTime = @"0:00:00";
    } else if (time < 0) {
//        if (dHours > 0) {
            displayTime = [NSString stringWithFormat:@"-%lu:%02lu:%02lu",(unsigned long)dHours, (unsigned long)dMinutes, (unsigned long)dSeconds];
//        }
//        else{
//            displayTime = [NSString stringWithFormat:@"-%02lu:%02lu", (unsigned long)dMinutes, (unsigned long)dSeconds];
//        }
    }else{
//        if (dHours > 0) {
            displayTime = [NSString stringWithFormat:@"%lu:%02lu:%02lu",(unsigned long)dHours, (unsigned long)dMinutes, (unsigned long)dSeconds];
//        }
//        else{
//            displayTime = [NSString stringWithFormat:@"%02lu:%02lu", (unsigned long)dMinutes, (unsigned long)dSeconds];
//        }
    }
    return displayTime;
}

//+(NSString*)timeToString:(CMTime)time
//{
//    NSUInteger dTotalSeconds = CMTimeGetSeconds(time);
//    NSUInteger dHours = floor(dTotalSeconds / 3600);
//    NSUInteger dMinutes = floor(dTotalSeconds % 3600 / 60);
//    NSUInteger dSeconds = floor(dTotalSeconds % 3600 % 60);
//    NSString *videoDurationText = [NSString stringWithFormat:@"%lu:%02lu:%02lu",(unsigned long)dHours, (unsigned long)dMinutes, (unsigned long)dSeconds];
//    
//    return videoDurationText;
//}
//


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


// Depricated
+(NSString*)dictToJSON:(NSDictionary*)dict
{
    NSError *error;
    NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mutableDict options:0 error:&error];
    NSString *jsonString;
    if (jsonData) {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//        jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        jsonString = [jsonString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    } else {
        NSLog(@"JSON Error in Encoder");
    }
    
    return jsonString;
}

+(NSString*)dictToJSON:(NSDictionary*)dict error:(NSError **)aError;
{
    

    NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mutableDict options:0 error:aError];
    NSString *jsonString;
    if (jsonData) {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//        jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        jsonString = [jsonString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    } else {
        NSLog(@"JSON Error: converting Dict to JSON");
        *aError = [NSError errorWithDomain:@"Json Error" code:-0 userInfo:@{}];
    }
    
    return jsonString;
}


+(NSDictionary*)URLJSONStringDict:(NSString*)data
{

    NSString * temp =     [data stringByRemovingPercentEncoding];
    NSData * webData = [temp dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary * dict = [Utility JSONDatatoDict:webData];
    return dict;

}



// Depricated
+(NSDictionary*)JSONDatatoDict:(NSData*)data
{
    NSDictionary *results;
//    if (!data) return @{};
    if(NSClassFromString(@"NSJSONSerialization"))
    {
        NSError *error = nil;
        if (!data) {
             PXPLog(@"%@ Error! U002  %@",@"nil Data sent to NSJSONSerialization return empty Dict",@"bad connection");
            return @{};
        }
        id object = [NSJSONSerialization
                     JSONObjectWithData:data
                     options:NSJSONReadingAllowFragments
                     error:&error];
        
        if(error) {

            NSString * description      = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
            NSString * reason           = [error.userInfo objectForKey:NSLocalizedFailureReasonErrorKey];
            NSString * debugDescription = [error.userInfo objectForKey:@"NSDebugDescription"];
            
            if (!description && debugDescription) {
                PXPLog(@"JSON was malformed Error! %@",debugDescription);
            } else if (!description && !reason) {
            
                PXPLog(@"JSON was malformed Error!");
            } else {
                PXPLog(@"%@ Error! U001  %@",description,reason);
            }
            
           
            
            
            /* JSON was malformed, act appropriately here */ }
        
        // the originating poster wants to deal with dictionaries;
        // assuming you do too then something like this is the first
        // validation step:
        if([object isKindOfClass:[NSDictionary class]])
        {
//            NSDictionary *  test = [[NSDictionary alloc]init];
//            NSString * teste = NSString st
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


+(NSDictionary*)JSONDatatoDict:(NSData*)data error:(NSError **)aError
{
    NSDictionary *results;
    if(NSClassFromString(@"NSJSONSerialization"))
    {
        if (!data) {
//            &aError = [[NSError alloc]initWithDomain:0 code:0 userInfo:@{}];
            return@{};
        }
        id object = [NSJSONSerialization
                     JSONObjectWithData:data
                     options:NSJSONReadingAllowFragments
                     error:aError];
        
        if(aError) {
//            NSError * e = &aError;
//            NSString * description  = [e.userInfo objectForKey:NSLocalizedDescriptionKey];
//            NSString * reason       = [e.userInfo objectForKey:NSLocalizedFailureReasonErrorKey];
            
            PXPLog(@" Error! U001  JSONDatatoDict:data:error:");
            /* JSON was malformed, act appropriately here */ }
        
        // the originating poster wants to deal with dictionaries;
        // assuming you do too then something like this is the first
        // validation step:
        if([object isKindOfClass:[NSDictionary class]])
        {
            //            NSDictionary *  test = [[NSDictionary alloc]init];
            //            NSString * teste = NSString st
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

+(NSString *)hexStringFromColor:(UIColor *)color
{
    CGFloat r = 0.0, g = 0.0, b = 0.0;
    [color getRed:&r green:&g blue:&b alpha:nil];
    return [NSString stringWithFormat:@"%02hhX%02hhX%02hhX", (unsigned char) (r * 255), (unsigned char) (g * 255), (unsigned char) (b * 255)];
}

+(NSString *)stringToSha1:(NSString *)hashkey{
    
    // Using UTF8Encoding
    const char *s = [hashkey cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *keyData = [NSData dataWithBytes:s length:strlen(s)];
    
    // This is the destination
    uint8_t digest[CC_SHA1_DIGEST_LENGTH] = {0};
    // This one function does an unkeyed SHA1 hash of your hash data
    CC_SHA1(keyData.bytes, (unsigned int) keyData.length, digest);
    
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
    CC_SHA256(str, (unsigned int) strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_SHA256_DIGEST_LENGTH; i++)
    {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}


+(UIColor*)colorWithHexString:(NSString*)hex
{
    unsigned char r = 0, g = 0, b = 0;
    sscanf(hex.UTF8String, "%02hhx%02hhx%02hhx", &r, &g, &b);
    return [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:1.0];
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

+(NSComparisonResult)compareVersion: (NSString *)version1 withVersion: (NSString *)version2{
  
    if ([version1 isEqualToString:@"local"] && [version2 isEqualToString:@"local"]) {
        return NSOrderedSame;
    } else if ([version1 isEqualToString:@"local"] && ![version2 isEqualToString:@"local"]) {
        return NSOrderedAscending;
    } else if (![version1 isEqualToString:@"local"] && [version2 isEqualToString:@"local"]) {
         return NSOrderedDescending;
    }
    
    NSArray *version1Array = [version1 componentsSeparatedByString:@"."];
    NSArray *version2Array = [version2 componentsSeparatedByString:@"."];
    
    NSUInteger maxCount = MAX(version1Array.count, version2Array.count);
    
    for (NSUInteger i = 0; i < maxCount; ++i) {
        int version1Number = [version1Array[i] intValue];
        int version2Number = [version2Array[i] intValue];
        
        if (version1Number > version2Number) {
            return NSOrderedDescending;
        }else if (version1Number < version2Number){
            return NSOrderedAscending;
        }
        
        if (i == (maxCount - 1)) {
            return NSOrderedSame;
        }
        
        if (i == (version1Array.count - 1) && !(i == (version2Array.count - 1))) {
            return NSOrderedAscending;
        }else if (i == (version2Array.count - 1) && !(i == (version1Array.count - 1))){
            return NSOrderedDescending;
        }
    }
    
    return NSOrderedSame;
}




+ (NSString *) platformString{
    
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    
//    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
//    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
//    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
//    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
//    if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
//    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
//    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
//    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
//    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
//    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
//    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
//    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
//    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
//    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
//    if ([platform isEqualToString:@"iPad3,1"])      return @"foobar";
//    if ([platform isEqualToString:@"i386"])         return @"Simulator";
//    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    
    
    return platform;
}






+(BOOL)isDeviceBlurSupported:(NSString *)platform{
  // [Utility isDeviceBlurSupported:[Utility platformString]];
    
    BOOL result = FALSE;
    NSArray *deviceBlurNotSupportedArray = [[NSArray alloc] initWithObjects:
                                            @"iPad1,1",
                                            @"iPhone1,1",
                                            @"iPhone1,2",
                                            @"iPhone2,1",
                                            @"iPhone3,1",
                                            @"iPhone3,2",
                                            @"iPhone3,3",
                                            @"iPod1,1",
                                            @"iPod2,1",
                                            @"iPod2,2",
                                            @"iPod3,1",
                                            @"iPod4,1",
                                            @"iPad2,1",
                                            @"iPad2,2",
                                            @"iPad2,3",
                                            @"iPad2,4",
                                            @"iPad3,1",
                                            @"iPad3,2",
                                            @"iPad3,3", nil];
    
    for(NSString *devicePlatformFromArray in deviceBlurNotSupportedArray){
        if([platform isEqualToString:devicePlatformFromArray]){
            result = FALSE;
            NSLog(@"Blur not supported for Device ID \"%@\"", platform);
            break;
            
        }else{
            result = TRUE;
    
        }
        
    }
    
    return result;
    
}

+(BOOL)isDeviceSupportedMultiCam:(NSString *)platform{
    NSLog(@"multi cam limiter disabled <Utility Class>");
    return YES;
/*
    const char *s = platform.UTF8String;
    BOOL result = FALSE;
    
    if (s && strstr(s, "iPad")) {
        NSArray *words = [platform componentsSeparatedByString:@","];
        platform = words[0];
        words = [platform componentsSeparatedByString:@"iPad"];
        if ([words[1] intValue] >= 4) {
            result = TRUE;
        }
    }
    return result;
*/
}

+ (NSString *)myWifiName
{
    CFArrayRef myArray = CNCopySupportedInterfaces();
    // Get the dictionary containing the captive network infomation
    if (myArray) {
        CFStringRef inferfaceName = CFArrayGetValueAtIndex(myArray, 0);
        CFDictionaryRef captiveNtwrkDict = CNCopyCurrentNetworkInfo(inferfaceName);
        
        NSString *ssid = nil;
        
        if (captiveNtwrkDict) {
            CFStringRef key = CFSTR("SSID");
            ssid = (__bridge NSString *) CFDictionaryGetValue(captiveNtwrkDict, key);
            CFRelease(key);
            CFRelease(captiveNtwrkDict);
        }
        
        if(!ssid){
            ssid = @"Unavailable";
        }
        
        CFRelease(myArray);
        return ssid;
    }
    
    
    
     return @"No Wifi";
}

+(NSString *) dateFromEvent: (NSString *) eventName{
    return [eventName substringToIndex:10];
}


// Depricated
+(BOOL)hasInternet{

    //Reachability *internetReachableFoo = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    SCNetworkReachabilityFlags flags;
    BOOL receivedFlags;
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(CFAllocatorGetDefault(), [@"www.google.com" UTF8String]);
    
    receivedFlags = SCNetworkReachabilityGetFlags(reachability, &flags);
    
    CFRelease(reachability);
    
    return  (!receivedFlags || flags == 0) ? FALSE : TRUE;

}


+(void)hasInternetOnComplete:(void (^)(BOOL succsess))onFinish
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        SCNetworkReachabilityFlags flags;
        BOOL receivedFlags;
        
        SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(CFAllocatorGetDefault(), [@"www.google.com" UTF8String]);
        receivedFlags = SCNetworkReachabilityGetFlags(reachability, &flags);
        
        CFRelease(reachability);
        BOOL found = (!receivedFlags || flags == 0) ? FALSE : TRUE;
        dispatch_async(dispatch_get_main_queue(), ^{
            onFinish(found);
        });
    });
    
    
    
    
    
}



+(NSString*)removeSubString:(NSString*)substring in:(NSString*)main
{
    NSMutableString * temp =     [[NSMutableString alloc]initWithString:main];
    //[temp deleteCharactersInRange:[main rangeOfString:substring]];
    return temp;
}

+(UIColor*)darkerColorOf:(UIColor*)color
{
    CGFloat r, g, b, a;
    if ([color getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MAX(r - 0.2, 0.0)
                               green:MAX(g - 0.2, 0.0)
                                blue:MAX(b - 0.2, 0.0)
                               alpha:a];
    return nil;
}

+(UIColor*)ligherColorOf:(UIColor*)color
{
    CGFloat r, g, b, a;
    if ([color getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MAX(r + 0.5, 0.0)
                               green:MAX(g + 0.5, 0.0)
                                blue:MAX(b + 0.5, 0.0)
                               alpha:a];
    return nil;
}



+(NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wired connection on a simulator, en1 - wifi on the simulator, or lo0 - wifi on an iPad
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"] ||
                   [[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en1"] ||
                   [[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"lo0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
}


+(BOOL)hasWiFi
{
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&zeroAddress);
    if(reachability != NULL) {
        //NetworkStatus retVal = NotReachable;
        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(reachability, &flags)) {
            if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
            {
                // if target host is not reachable
                CFRelease(reachability);
                return NO;
            }
            
            if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
            {
                // if target host is reachable and no connection is required
                //  then we'll assume (for now) that your on Wi-Fi
                CFRelease(reachability);
                return YES;
            }
            
            
            if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
                 (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
            {
                // ... and the connection is on-demand (or on-traffic) if the
                //     calling application is using the CFSocketStream or higher APIs
                
                if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
                {
                    // ... and no [user] intervention is needed
                    CFRelease(reachability);
                    return YES;
                }
            }
            
            if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0)
            {
                // ... but WWAN connections are OK if the calling application
                //     is using the CFNetwork (CFSocketStream?) APIs.
                CFRelease(reachability);
                return YES;
            }
        }
    }
    
    if (reachability) {
        CFRelease(reachability);
    }
    
    return NO;
    
    //    return [uController hasConnectivity];
}

+(UIImage *)starImageSelected: (BOOL) selected size:(CGSize)size
{
    CGSize imageSize = size;
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, [UIScreen mainScreen].scale);
    
    UIBezierPath *starPath = [UIBezierPath bezierPath];
//    UIBezierPath *outLinePath = [UIBezierPath bezierPath];
    
    [starPath moveToPoint:      CGPointMake(imageSize.width*0.175,  imageSize.height)];         // bottom left
    [starPath addLineToPoint:   CGPointMake(imageSize.width*0.5,    0)];                        // top
    [starPath addLineToPoint:   CGPointMake(imageSize.width*0.825,  imageSize.height)];         // bottom right
    [starPath addLineToPoint:   CGPointMake(0,                      imageSize.height*0.382)];   //left
    [starPath addLineToPoint:   CGPointMake(imageSize.width,        imageSize.height*0.382)];   //right
    [starPath addLineToPoint:   CGPointMake(imageSize.width*0.175,  imageSize.height)];         // bottom left
    
//    
//    [outLinePath moveToPoint: CGPointMake(17.5/2, 100/2)];
//    [outLinePath addLineToPoint: CGPointMake(50/2, (100 -23.61)/2 )];
//    [outLinePath addLineToPoint: CGPointMake((50 + 32.5)/2, 100/2)];
//    [outLinePath addLineToPoint: CGPointMake(70/2, 61.8/2)];
//    [outLinePath addLineToPoint: CGPointMake(100/2, 38.2/2)];
//    [outLinePath addLineToPoint: CGPointMake(0, 38.2/2)];
//    [outLinePath addLineToPoint: CGPointMake((50 + 32.5)/2, 100/2)];
//    [outLinePath addLineToPoint: CGPointMake(50/2, 0)];
//    [outLinePath addLineToPoint: CGPointMake(17.5/2, 100/2)]; // bottom left
//    
    
    if (selected) {
        [PRIMARY_APP_COLOR setFill];
        //[PRIMARY_APP_COLOR setStroke];
    }else{
        [[UIColor lightGrayColor] setFill];
        //[[UIColor lightGrayColor] setStroke];
    }
    
    
//    
//    outLinePath.lineWidth = 5.0;
//    [outLinePath stroke];
    [starPath fill];
    
    UIImage *starImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return starImage;
}

+(UIImage*)makeOnePixelUIImageWithColor:(UIColor*)color
{
    CGSize pixelSize = CGSizeMake(1, 1);

    UIGraphicsBeginImageContextWithOptions(pixelSize, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context,(CGRect){CGPointZero, pixelSize});
    CGContextSaveGState(context);
    UIImage *pixel = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
  
    return  pixel;
}

+(NSString*)downloadByteToStringHuman:(long long)byte
{

    NSString * readable;
    double mb = (double) byte;
    

    

    
    for (NSString *x in @[@"b",@"KB",@"MB",@"GB",@"TB",@"PB",@"EB",@"ZB",@"YB"]){
        if (byte < 1024)
        {
            mb = (double) byte;    
//            return readable =  [NSString stringWithFormat:@"%llu %@" , byte, x ];
             return readable =  [NSString stringWithFormat:@"%.2f %@" , mb, x ];

        }
        byte = byte >> 10;
       
    }
    return @"";
}

@end

