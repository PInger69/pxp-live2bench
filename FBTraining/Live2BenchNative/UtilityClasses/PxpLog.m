//
//  PxpLog.m
//  Live2BenchNative
//
//  Created by dev on 2015-04-14.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "PxpLog.h"
#import "Utility.h"
#import "DeviceLog.h"
/**
 *  This class is meant to be a singleton that will record what is going on in the app
 l = [PxpLog getInstance];
 [l addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
 [PxpLog log:@"laksdflaskdfj"];
 */

static PxpLog * instance;
static DeviceLog * deviceLog;
static NSMutableDictionary * uniqueLogDic;

@implementation PxpLog

@synthesize text = _text;

+(void)initialize
{
    uniqueLogDic = [NSMutableDictionary new];

}

+(void)log:(NSString*)log,...
{
    va_list args;
    va_start(args, log);
    if (!instance) {
        instance = [[PxpLog alloc]init];
        [instance willChangeValueForKey:@"text"];
        instance.text = [[NSMutableString alloc]initWithFormat:log arguments:args];
        [instance didChangeValueForKey:@"text"];
    } else {
        
        [instance willChangeValueForKey:@"text"];
        NSString * tmp = [[NSString alloc]initWithFormat:log arguments:args];
        [instance.text appendFormat:@"\n%@",tmp ];
        [instance didChangeValueForKey:@"text"];
    }
     va_end(args);
}


+(void)deviceLog:(NSString*)log,...
{

    va_list args;
    va_start(args, log);

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm:ss";
    NSString * timeStamp = [formatter stringFromDate:[NSDate new]];
    NSString * slog = [[NSString alloc]initWithFormat:log arguments:args];
    NSString * tmp = [NSString stringWithFormat:@"%@  %@",timeStamp,slog];
    [deviceLog appendToLog:tmp];
    va_end(args);
}



+(void)deviceLogID:(NSString*)hash msg:(NSString*)log,...
{
    va_list args;
    va_start(args, log);
    
    if (!log) {
        return;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm:ss";
    NSString * timeStamp = [formatter stringFromDate:[NSDate new]];
    NSString * slog = [[NSString alloc]initWithFormat:log arguments:args];
    NSString * tmp = [NSString stringWithFormat:@"%@  %@",timeStamp,slog];
    if ([uniqueLogDic objectForKey:hash]) {
        NSString * check = [uniqueLogDic objectForKey:hash];
        
        if (![check isEqualToString:log]) {
            [deviceLog appendToLog:tmp];
            [uniqueLogDic setObject:log forKey:hash];
        }
    
    } else {
        [deviceLog appendToLog:tmp];
        [uniqueLogDic setObject:log forKey:hash];
    
    }
    
    
    va_end(args);
}



+(NSString*)deviceLogPath
{
    if (!deviceLog) {
        deviceLog = [DeviceLog new];
    }
    return deviceLog.path;
}


+(NSMutableString*)output
{
    return instance.text;
}

+(void)clear
{
    instance.text = [[NSMutableString alloc]init];
}

+(void)clearDeviceLog
{
    [deviceLog clearLog];
}

+(instancetype)getInstance
{
    if (!instance) {
        instance    = [[PxpLog alloc]init];
        deviceLog   = [DeviceLog new];
    }
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.text = [[NSMutableString alloc] initWithFormat:@"Application Start... %@",[NSDate date]];
    }
    return self;
}



@end
