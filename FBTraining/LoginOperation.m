//
//  LoginOperation.m
//  Live2BenchNative
//
//  Created by dev on 2016-04-15.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "LoginOperation.h"

@implementation LoginOperation


-(instancetype)initWithEmail:(NSString*)email password:(NSString*)password
{
    
    NSString *deviceName        = [[UIDevice currentDevice] name];
    NSString *UUID              = [[[UIDevice currentDevice] identifierForVendor]UUIDString];
    NSString *deviceType        = [Utility stringToSha1: @"tablet"];
    NSString *emailAddress      = [Utility stringToSha1: email];
    NSString *hashedPassword    = [Utility sha256HashFor: [password stringByAppendingString: @"azucar"]];
    NSString *pData             = [NSString stringWithFormat:@"&v0=%@&v1=%@&v2=%@&v3=%@&v4=%@",deviceType,emailAddress,hashedPassword,deviceName,UUID];
    
    NSData *postData            = [pData dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postDataLength    = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc]init];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postDataLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current=Type"];
    [request setHTTPBody:postData];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://myplayxplay.net/max/activate/ajax"]]];
//    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://192.168.5.115/max/activate/ajax"]]];

    
    self = [super initWithNSURLRequest:request];
    if (self) {
        
    }
    return self;
}

@end
