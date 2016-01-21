//
//  DeviceEncoderURLProtocol.m
//  Live2BenchNative
//
//  Created by dev on 2016-01-11.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "PxpURLProtocol.h"
#import "PxpURLResponse.h"
#import "DeviceEncoderSource.h"

@implementation PxpURLProtocol
+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    NSString* scheme = [[request URL] scheme];

    NSArray * urlProtocols = @[@"device"];
    
    for (NSString * urlp in urlProtocols) {
        if ([scheme isEqualToString:urlp]) {
            return YES;
        }
    }
    return NO;
}


// this is where you connections if there was
- (void) stopLoading
{
    
}


- (void)startLoading
{
    

    NSURLRequest *request = [self request];
    
    id client = [self client];

    
 
    PxpURLResponse* pxpURLResponse = [[DeviceEncoderSource instance] handleRequest:request];

    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:pxpURLResponse.response
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString* responseString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
////
    if (pxpURLResponse.errorCode != 0) {
        NSError* err = [NSError errorWithDomain:@"MockURLResponse"
                                           code:pxpURLResponse.errorCode
                                       userInfo:pxpURLResponse.response];
        
        [client URLProtocol:self didFailWithError:err];
    } else if ([[request HTTPMethod] isEqualToString:@"GET"] && [responseString length] == 0){
        // We expect a body in the response from a GET request.
        NSError* err = [NSError errorWithDomain:@"MockURLResponse"
                                           code:1
                                       userInfo:@{@"info":@"Found no response"}];
        
        [client URLProtocol:self didFailWithError:err];
    } else {
        NSHTTPURLResponse* response = [[NSHTTPURLResponse alloc] initWithURL:[request URL]
                                                                  statusCode:200 HTTPVersion:@""
                                                                headerFields:@{@"content-type":@"application/json"}];
        [client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [client URLProtocol:self didLoadData:[responseString dataUsingEncoding:NSUTF8StringEncoding]];

        [client URLProtocolDidFinishLoading:self];
//
    }
}







+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}
@end
