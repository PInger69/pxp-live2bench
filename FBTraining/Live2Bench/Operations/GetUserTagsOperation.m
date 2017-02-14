//
//  GetUserTagsOperation.m
//  Live2BenchNative
//
//  Created by dev on 2016-04-15.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "GetUserTagsOperation.h"

@implementation GetUserTagsOperation


- (instancetype)initEmail:(NSString*)email password:(NSString*)aPassword authorization:(NSString*)authorization customerHid:(NSString*)customerHid
{
    NSString * user             = email;
    NSString * password         = aPassword;
    NSString * authoriz         = authorization;
    NSString * customer         = customerHid;
    NSString * emailAddress     = [Utility stringToSha1: user];
    
    NSString *pData             = [NSString stringWithFormat:@"&v0=%@&v1=%@&v2=%@&v3=%@&v4=%@",authoriz,emailAddress,password,@"( . Y . )",customer];
    // v0 autherzation  v1 hashedEmail  v2 password v3 ( . Y . )  v4 customerID
    NSData   *postData          = [pData dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postDataLength    = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc]init];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postDataLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current=Type"];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://myplayxplay.net/max/requesttagnames/ajax"]]];
    [request setHTTPBody:postData];
    
    self = [super initWithNSURLRequest:request];
    if (self) {
        
    }
    return self;
}



@end
