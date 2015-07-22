//
//  PxpLog.m
//  Live2BenchNative
//
//  Created by dev on 2015-04-14.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "PxpLog.h"
#import "Utility.h"
/**
 *  This class is meant to be a singleton that will record what is going on in the app
 l = [PxpLog getInstance];
 [l addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
 [PxpLog log:@"laksdflaskdfj"];
 */

static PxpLog * instance;

@implementation PxpLog

@synthesize text = _text;


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

+(NSMutableString*)output
{
    return instance.text;
}

+(void)clear
{
    instance.text = [[NSMutableString alloc]init];
}

+(instancetype)getInstance
{
    if (!instance) {
        instance = [[PxpLog alloc]init];
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
