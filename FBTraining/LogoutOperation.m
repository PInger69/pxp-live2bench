//
//  LogoutOperation.m
//  Live2BenchNative
//
//  Created by dev on 2016-04-15.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "LogoutOperation.h"

// when logout is complete, you need to clear all user data

@implementation LogoutOperation



- (instancetype)initWithEmail:(NSString*)email password:(NSString*)password authorization:(NSString*)authorization color:(NSString*)colorString customerHid:(NSString*)customerHid
{
    
    
    NSString            *emailAddress          = [Utility stringToSha1:email ];
    NSString            *accountInfoString     = [NSString stringWithFormat:@"v0=%@&v1=%@&v2=%@&v3=%@&v4=%@",
                                                  authorization,
                                                  emailAddress,
                                                  password,
                                                  colorString,
                                                  customerHid];
    
    NSData              *accountInfoData       = [accountInfoString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString            *postDataLength        = [NSString stringWithFormat:@"%lu",(unsigned long)[accountInfoData length]];
    NSMutableURLRequest *request               = [[NSMutableURLRequest alloc]init];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://myplayxplay.net/max/deactivate/ajax"]]];
//        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://192.168.5.115/max/deactivate/ajax"]]];
    //create post request
    [request setHTTPMethod:@"POST"];
    [request setValue:postDataLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current=Type"];
    [request setHTTPBody:accountInfoData];
    
    self = [super initWithNSURLRequest:request];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary*)tData
{

    NSDictionary        *accountInfo           = tData;
    NSString            *emailAddress          = [Utility stringToSha1:[accountInfo objectForKey:@"emailAddress"] ];
    NSString            *accountInfoString     = [NSString stringWithFormat:@"v0=%@&v1=%@&v2=%@&v3=%@&v4=%@",
                                                  [accountInfo objectForKey:@"authorization"],
                                                  emailAddress,
                                                  [accountInfo objectForKey:@"password"],
                                                  [accountInfo objectForKey:@"tagColour"],
                                                  [accountInfo objectForKey:@"customer"]];
    
    NSData              *accountInfoData       = [accountInfoString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString            *postDataLength        = [NSString stringWithFormat:@"%lu",(unsigned long)[accountInfoData length]];
    NSMutableURLRequest *request               = [[NSMutableURLRequest alloc]init];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://myplayxplay.net/max/deactivate/ajax"]]];
    
    //create post request
    [request setHTTPMethod:@"POST"];
    [request setValue:postDataLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current=Type"];
    [request setHTTPBody:accountInfoData];
    
    self = [super initWithNSURLRequest:request];
    if (self) {
        
    }
    return self;
}



@end
