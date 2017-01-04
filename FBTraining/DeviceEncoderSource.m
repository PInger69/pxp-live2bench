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
        
        NSString * theRaw = [requestString lastPathComponent];
        NSDictionary * dict  =  [Utility URLJSONStringDict:theRaw];
        self.customerID = dict[@"id"];
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
    } else if ([requestString rangeOfString:@"/ajax/tagset"].location != NSNotFound) {
        num = [requestString rangeOfString:@"/ajax/tagset"].location;
        responce = [PxpURLResponse responseWithDictionary: @{@"leagues":@{},@"requrl":@"/ajax/tagset",@"sender":@".device",
                                                             @"success":@"1",
                                                             
                                                             
                                                             @"msg":@"message"} errorCode:0];
        responce = [self buildTagSetResponse];
    } else if ([requestString rangeOfString:@"/ajax/teamsget"].location != NSNotFound) {
        num = [requestString rangeOfString:@"/ajax/teamsget"].location;
        responce = [PxpURLResponse responseWithDictionary: @{@"leagues":@{},@"requrl":@"/ajax/teamsget",@"sender":@".device",@"teams":@{},@"teamsetup":@{}} errorCode:0];
    
    } else if ([requestString rangeOfString:@"/ajax/gametags"].location         != NSNotFound) {
        
        responce = [PxpURLResponse responseWithDictionary: @{@"requrl":@"/ajax/teamsget",@"sender":@".device"} errorCode:0];
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
    
    
    NSString * sampleFile = @"file:///var/mobile/Media/DCIM/100APPLE/TEST_VIDEO.mp4";
    
    if (!self.eventData) {
        
        NSDictionary *sourcesData;
        NSMutableDictionary * temp = [NSMutableDictionary new];
        
        for (NSInteger i=0; i<self.cameraCount; i++) {
            
            [temp setObject:@{
                             @"hq":sampleFile,
                             @"lq":sampleFile,
                             @"vidsize_hq" : @"0.00MB",
                             @"vidsize_lq" : @"0.00MB",
                             @"vq" : @"lq"
                             } forKey:[NSString stringWithFormat:@"s_0%ld",(long)i]];
        }

        sourcesData = [temp copy];
        
        eventList = @[
                      @{
                          @"datapath"  : @"test",
                          @"date"      : @"2016-08-11 17:23:19",
                          @"dateFmt"   : @"2016-08-11_17-23-19",
                          @"deleted"   : @"0",
                          @"hid"       : @"12345",
                          @"homeTeam"  : @"A_",
                          @"league"    : @"B_",
                          @"md5"       : @"hash",
                          @"mp4"       : sampleFile,
                          @"mp4_2"     : sourcesData,
                          @"name"      : @"EventName",
                          @"num_mp4"   : @"1",
                          @"num_vid"   : @"1",
                          @"size"      : @"0",
                          @"sport"     : @"Book Reading",
                          @"vid"       : sampleFile,
                          @"vid_2"     : sourcesData,
                          @"visitTeam" : @"C_"
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

-(PxpURLResponse*)buildTagSetResponse
{
    
    
    
    NSDictionary * theData = @{
                               @"colour"      : @"3AF20F",
                               @"comment"     : @"",
                               @"deleted"     : @"0",
                               @"deviceid"    : @"282AF2B2-1B22-4A76-8EC6-032F5CB57648",
                               @"displaytime" : @"0:35:00",
                               @"duration"    : @"15",
                               @"event"       : @"2016-08-16_11-12-15_308c84c9bebb1c176bf766dbcbbe740ea80126bd_local",
                               @"homeTeam"    : @"St Mary's University",
                               @"id"          : @"10",
                               @"islive"      : @"1",
                               @"name"        : @"Concussion",
                               @"newTagID"    : @"10",
                               @"own"         : @"1",
                               @"period"      : @"0",
                               @"rating"      : @"",
                               @"requrl"       : @"/ajax/tagset/{\"colour\":\"3AF20F\",\"requesttime\":\"139859.478378\",\"deviceid\":\"282AF2B2-1B22-4A76-8EC6-032F5CB57648\",\"time\":\"2100.050871\",\"event\":\"live\",\"period\":\"0\",\"name\":\"Concussion\",\"user\":\"ae1e7198bc3074ff1b2e9ff520c30bc1898d038e\"}",
                               @"sender"       : @".min",
                               @"starttime"    : @"2095.050871",
                               @"success"      : @"1",
                               @"telefull_2"   : @{},
                               @"teleurl_2"    : @{},
                               @"time"         : @"2100.050871",
                               @"type"         : @"0",
                               @"url"          : @"http://172.18.2.157/events/live/thumbs/00hq_tn10.jpg",
                               @"url_2"        : @{
                                                   @"s_00" : @"http://172.18.2.157/events/live/thumbs/00hq_tn10.jpg"
                                                   },
                               @"user"         : @"ae1e7198bc3074ff1b2e9ff520c30bc1898d038e",
                               @"vidurl_2"     : @[],
                               @"visitTeam"    : @"St Mary's University"
    };
    
    
    
    PxpURLResponse* responce = [PxpURLResponse responseWithDictionary: theData errorCode:0];
    
    return responce;
}

-(PxpURLResponse*)responseTest
{
    PxpURLResponse* responce = [PxpURLResponse responseWithDictionary: @{@"stuff":@"STUFF"} errorCode:0];
    
    return responce;
}


@end
