//
//  MockEncoderSource.m
//  Live2BenchNative
//
//  Created by dev on 2016-02-17.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "MockEncoderSource.h"

@implementation MockEncoderSource
{
    NSDictionary * _selectorDict;

}
static MockEncoderSource* server;

+(void)initialize
{
    server = [[MockEncoderSource alloc] init];
}

+(MockEncoderSource*) instance {
    return server;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        
 
    }
    return self;
}

-(PxpURLResponse*) handleRequest:(NSURLRequest*) request {
    NSString        * requestString = request.URL.path;
    PxpURLResponse  * responce;
    
    if ([requestString rangeOfString:@"/auth"].location                         != NSNotFound) {
        responce = [self buildAuthenticateResponse];
    } else if ([requestString rangeOfString:@"/ajax/version"].location          != NSNotFound) {
//        responce = [self buildVersionResponse];
    }else if ([requestString rangeOfString:@"/ajax/getpastevents"].location     != NSNotFound) {
//        responce = [self buildGetAllEventsResponse];
    } else if ([requestString rangeOfString:@"/ajax/encoderstatjson"].location  != NSNotFound) {
//        responce = [self buildStatusResponse];
    } else if ([requestString rangeOfString:@"/ajax/syncme"].location           != NSNotFound) {
//        responce = [self buildSyncResponse];
    } else if ([requestString rangeOfString:@"/ajax/getcameras"].location       != NSNotFound) {
//        responce = [PxpURLResponse responseWithDictionary: @{@"camlist":@{},@"requrl":@"/ajax/getcameras",@"sender":@".device"} errorCode:0];
    } else if ([requestString rangeOfString:@"/ajax/teamsget"].location         != NSNotFound) {

        responce = [PxpURLResponse responseWithDictionary: @{@"leagues":@{},@"requrl":@"/ajax/teamsget",@"sender":@".device",@"teams":@{},@"teamsetup":@{}} errorCode:0];
    }
    
    
    return (responce)?responce:nil;
}

-(PxpURLResponse*)buildAuthenticateResponse
{
    PxpURLResponse* responce = [PxpURLResponse responseWithDictionary: @{@"success":@"1",@"sender":@".device"} errorCode:0];
    
    return responce;
}

@end
