//
//  DeviceEncoderSource.m
//  Live2BenchNative
//
//  Created by dev on 2016-01-11.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "DeviceEncoderSource.h"


// This class takes in the Request and then builds a responce based on the request

@interface DeviceEncoderSource ()



@end



@implementation DeviceEncoderSource
static DeviceEncoderSource* server;

+(void)initialize
{
    server = [[DeviceEncoderSource alloc] init];
}

+(DeviceEncoderSource*) instance {
    return server;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cameraCount = 4;
    }
    return self;
}

-(PxpURLResponse*) handleRequest:(NSURLRequest*) request {
    NSString* requestString = request.URL.path;
    
    PxpURLResponse * responce;
    NSString * locat;
    NSInteger num = [requestString rangeOfString:@"/auth"].location;
    
    //    NSRange match;
    //
    //    match = [requestString rangeOfString: @"brown dog"];
    //
    //    if (match.location != NSNotFound)
    //        NSLog (@"Match not found");
    //    else
    //        NSLog (@"match found at index %lu", match.location);
    
    
    if ([requestString rangeOfString:@"/auth"].location != NSNotFound) {
        num = [requestString rangeOfString:@"/auth"].location;
        responce = [self buildAuthenticateResponse];
    } else if ([requestString rangeOfString:@"/ajax/version"].location != NSNotFound) {
        num = [requestString rangeOfString:@"/ajax/version"].location;
        responce = [self buildVersionResponse];
    }else if ([requestString rangeOfString:@"/ajax/getpastevents"].location != NSNotFound) {
        num = [requestString rangeOfString:@"/ajax/getpastevents"].location;
        responce = [self buildGetAllEventsResponse];
    } else if ([requestString rangeOfString:@"/ajax/encoderstatjson"].location != NSNotFound) {
        num = [requestString rangeOfString:@"/ajax/encoderstatjson"].location;
        responce = [self buildStatusResponse];
    } else if ([requestString rangeOfString:@"/ajax/syncme"].location != NSNotFound) {
        num = [requestString rangeOfString:@"/ajax/syncme"].location;
        responce = [self buildSyncResponse];
    } else if ([requestString rangeOfString:@"/ajax/getcameras"].location != NSNotFound) {
        num = [requestString rangeOfString:@"/ajax/getcameras"].location;
        responce = [self responseCameraGet];
    } else if ([requestString rangeOfString:@"/ajax/teamsget"].location != NSNotFound) {
        num = [requestString rangeOfString:@"/ajax/teamsget"].location;
        responce = [PxpURLResponse responseWithDictionary: @{@"leagues":@{},@"requrl":@"/ajax/teamsget",@"sender":@".device",@"teams":@{},@"teamsetup":@{}} errorCode:0];
    } else {
        responce = [PxpURLResponse responseWithDictionary: @{@"success":@"0",@"sender":@".device"} errorCode:1];
    }
    
    
    
    
    return responce;
}


-(PxpURLResponse*)buildAuthenticateResponse
{
    PxpURLResponse* responce = [PxpURLResponse responseWithDictionary: @{@"success":@"1",@"sender":@".device"} errorCode:0];
    
    return responce;
}

-(PxpURLResponse*)buildVersionResponse
{
    PxpURLResponse* responce = [PxpURLResponse responseWithDictionary: @{@"version":@"9.9.9",@"sender":@".device",@"requrl":@"/ajax/version",@"success":@"1"} errorCode:0];
    
    return responce;
}

-(PxpURLResponse*)buildSyncResponse
{
    PxpURLResponse* responce = [PxpURLResponse responseWithDictionary: @{@"sender":@".device",@"requrl":@"/ajax/syncme",@"success":@"1"} errorCode:0];
    
    return responce;
}

-(PxpURLResponse*)buildGetAllEventsResponse
{
    NSArray * eventList = @[];
    
    
    if (!self.eventData) {
        eventList = @[
                      @{
                          @"datapath"  : @"test",
                          @"date"      : @"test",
                          @"dateFmt"   : @"test",
                          @"deleted"   : @"0",
                          @"hid"       : @"12345",
                          @"homeTeam"  : @"A",
                          @"league"    : @"B",
                          @"md5"       : @"hash",
                          @"mp4"       : @"file:///var/mobile/Media/DCIM/100APPLE/IMG_0001.mp4",
                          @"mp4_2"     : @{@"s_00":@{
                                                   @"hq":@"file:///var/mobile/Media/DCIM/100APPLE/IMG_0001.mp4",
                                                   @"lq":@"file:///var/mobile/Media/DCIM/100APPLE/IMG_0001.mp4",
                                                   @"vidsize_hq" : @"0.00MB",
                                                   @"vidsize_lq" : @"0.00MB",
                                                   @"vq" : @"lq"
                                                   }},
                          @"name"      : @"EventName",
                          @"num_mp4"   : @"1",
                          @"num_vid"   : @"1",
                          @"size"      : @"0",
                          @"sport"     : @"Book Reading",
                          @"vid"       : @"file:///var/mobile/Media/DCIM/100APPLE/IMG_0001.mp4",
                          @"vid_2"     : @{@"s_00":@{
                                                   @"hq":@"file:///var/mobile/Media/DCIM/100APPLE/IMG_0001.mp4",
                                                   @"lq":@"file:///var/mobile/Media/DCIM/100APPLE/IMG_0001.mp4",
                                                   @"vidsize_hq" : @"0.00MB",
                                                   @"vidsize_lq" : @"0.00MB",
                                                   @"vq" : @"lq"
                                                   }},
                          @"visitTeam" : @"C"
                          }
                      ];
    } else {
        eventList = @[];
    }
    
    
    PxpURLResponse* responce = [PxpURLResponse responseWithDictionary: @{@"events":eventList,@"sender":@".device",@"requrl":@"/ajax/getpastevents",@"success":@YES} errorCode:0];
    
    return responce;
}

-(PxpURLResponse*)buildStatusResponse
{
    
    NSDictionary * dict = @{
                            @"alarms"   : @[],
                            @"code"     : @8,
                            @"master"   : @1,
                            @"requrl"   : @"/ajax/encoderstatjson/",
                            @"sender"   : @".device" ,
                            @"status"   : @"live"
                            };
    
    PxpURLResponse* responce = [PxpURLResponse responseWithDictionary: dict errorCode:0];
    
    return responce;
}


-(PxpURLResponse*)responseCameraGet
{
    NSMutableDictionary * camList = [NSMutableDictionary new];
    
    for (NSInteger i=0; i<self.cameraCount; i++) {
        
        [camList setObject:@{
                             @"type"    : @"SuperEffective",
                             @"fps" 	   : @30,
                             @"sidx"    : [NSString stringWithFormat:@"s_0%ld",(long)i],
                             @"mac" 	:[NSString stringWithFormat:@"MAC:00:%ld",(long)i],
                             @"ip" 	    : @"000",
                             @"name"    : [NSString stringWithFormat:@"FakeCam_%ld",(long)i],
                             @"url"       : @"rtsp://nothing",
                             @"deviceURL" : [NSString stringWithFormat:@"rtsp://nothing/%ld",(long)i]
                             
                             } forKey:[NSString stringWithFormat:@"MAC:00:%ld",(long)i]];
        
        
        //        [camList addObject:@{
        //                             @"type"    : @"SuperEffective",
        //                             @"fps" 	   : @30,
        //                             @"sidx"    : [NSString stringWithFormat:@"s_0%ld",(long)self.cameraCount],
        //                             @"mac" 	:[NSString stringWithFormat:@"MAC:00:%ld",(long)i],
        //                             @"ip" 	    : @"000",
        //                             @"name"    : [NSString stringWithFormat:@"FakeCam_%ld",(long)i],
        //                             @"url" 	: @"rtsp://nothing"
        //
        //                             }];
    }
    
    
    PxpURLResponse* responce = [PxpURLResponse responseWithDictionary: @{@"camlist":[camList copy],
                                                                         @"requrl":@"/ajax/getcameras",
                                                                         @"sender":@".device"
                                                                         } errorCode:0];
    
    return responce;
}


-(PxpURLResponse*)responseTest
{
    PxpURLResponse* responce = [PxpURLResponse responseWithDictionary: @{@"stuff":@"STUFF"} errorCode:0];
    
    return responce;
}


@end
