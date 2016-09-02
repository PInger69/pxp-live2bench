//
//  SetSummaryOperation.m
//  Live2BenchNative
//
//  Created by dev on 2016-08-05.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "SetSummaryOperation.h"

@implementation SetSummaryOperation


- (instancetype)initWithUser:(NSString*)user summary:(NSString*)summary eventID:(NSString*)eventID type:(SummaryType)type encoder:(id<EncoderProtocol>)encoder
{
    NSError     * error;
    NSString    * jsonData = [Utility dictToJSON: @{
                                                    @"user":user,
                                                    @"id":eventID,
                                                    @"summary":summary,
                                                    @"type":(type==SummaryTypeGame)?@"game":@"month"
                                                    
                                                    } error:&error];
    
    
    
    
    if (error) {
        PXPLog(@"Error setting summary");
        return nil;
    }
    
    
    NSURL * checkURL = [NSURL URLWithString:   [NSString stringWithFormat:@"%@://%@/min/ajax/sumset/%@",encoder.urlProtocol,encoder.ipAddress, jsonData ]];
    
    
    NSURLRequest * request = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    
    self = [super initWithNSURLRequest:request];
    if (self) {
        self.encoder = encoder;
    }
    return self;


}

@end
