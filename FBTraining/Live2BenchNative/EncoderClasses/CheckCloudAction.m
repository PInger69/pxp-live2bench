//
//  CheckCloudAction.m
//  Live2BenchNative
//
//  Created by dev on 2015-01-19.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "CheckCloudAction.h"

@implementation CheckCloudAction
{
    
    
}
@synthesize isFinished  = _isFinished;
@synthesize isSuccess   = _isSuccess;



-(void)start {
    NSURL * checkURL                        = [NSURL URLWithString:   @"http://myplayxplay.net/max/ping/ajax"  ];
    NSURLRequest * urlRequest               = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
    NSURLConnection * connnect              = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.isSuccess  = YES;
    self.isFinished = YES;
    
}


-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.isSuccess  = NO;
    self.isFinished = YES;
}



@end
