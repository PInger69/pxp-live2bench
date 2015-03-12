//
//  CheckEncoderShutdown.m
//  Live2BenchNative
//
//  Created by dev on 10/23/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "CheckEncoderShutdown.h"
/**
 *  This class just checks if the server is shutdown and runs a block when it is
 */
@implementation CheckEncoderShutdown
{
    void (^onServerShutdown)(void);
    int                     maxCount;
    int                     currentCount;
    NSString                * ipAddress;
    NSTimer                 * timer;
    NSURLRequest            * urlRequest;
    NSURLConnection         * encoderConnection;
}

-(id)initWithIP:(NSString*)ip block:(void(^)(void))onShutdown
{
    self = [super init];
    if (self){
        ipAddress           = ip;
        maxCount            = 20;
        currentCount        = maxCount;
        onServerShutdown    = onShutdown;
    }
    return self;
}

-(void)start
{
    timer               = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checking) userInfo:nil repeats:YES];
}

-(void)checking
{
    NSURL * checkURL    = [NSURL URLWithString:   [NSString stringWithFormat:@"http://%@/min/ajax/encoderstatjson/",ipAddress]  ];
    urlRequest          = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:1];
    encoderConnection   = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (currentCount-- == 0) [self serverHasShutdown];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    currentCount = maxCount;
}

/**
 *  Invalidates timer and runs block
 */
-(void)serverHasShutdown
{
    [timer invalidate];
   if (onServerShutdown) onServerShutdown();
}


@end
