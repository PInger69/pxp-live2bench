//
//  PxpLog.m
//  Live2BenchNative
//
//  Created by dev on 2015-04-14.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "PxpLog.h"
/**
 *  This class is meant to be a singleton that will record what is going on in the app
 l = [PxpLog getInstance];
 [l addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
 [PxpLog log:@"laksdflaskdfj"];
 */

static PxpLog * instance;
@implementation PxpLog

@synthesize text = _text;


+(void)log:(NSString*)log
{
    if (!instance) {
        instance = [[PxpLog alloc]init];
        [instance willChangeValueForKey:@"text"];
        instance.text = [[NSMutableString alloc]initWithFormat:@"\n%@",log];
        [instance didChangeValueForKey:@"text"];
    } else {
        
        [instance willChangeValueForKey:@"text"];
        [instance.text appendFormat:@"\n%@",log ];
        [instance didChangeValueForKey:@"text"];
    }
}

+(NSMutableString*)output
{
    
    return instance.text;
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
        
    }
    return self;
}





@end
