//
//  CameraDetails.m
//  Live2BenchNative
//
//  Created by andrei on 2015-06-09.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "CameraDetails.h"

@implementation CameraDetails
{
    NSDictionary        *details;
}

@synthesize cameraID    = _cameraID;
@synthesize name        = _name;
@synthesize source      = _source;
@synthesize type        = _type;
@synthesize fps         = _fps;
@synthesize ipAddress   = _ipAddress;
@synthesize rtsp        =_rtsp;

-(id)initWithDictionary:(NSDictionary *)dict encoderOwner:(Encoder *)encoder
{
    self = [super init];
    if (self){
        
        details         = dict;

        
        _type           = ([details objectForKey:@"type"])? [details objectForKey:@"type"]:@"";
        _fps            = ([details objectForKey:@"fps"])?  [NSNumber numberWithFloat:[[details objectForKey:@"fps"]floatValue]]:@0;
        
        NSString * src = [details objectForKey:@"sidx"];
        
        if ([src rangeOfString:@"s_"].location == NSNotFound) {
            src =  [NSString stringWithFormat:@"s_%@",src ];
        }
        
        _resolution     =  ([details objectForKey:@"resolution"])?  [details objectForKey:@"resolution"]:@"";
        
        _source         = (src)? src:@"";
        _cameraID       = ([details objectForKey:@"mac"])?  [details objectForKey:@"mac"]:@"";
        _ipAddress      = ([details objectForKey:@"ip"])?   [details objectForKey:@"ip"]:@"(unsupported)";
        _name           = ([details objectForKey:@"name"])? [details objectForKey:@"name"]:_cameraID;
        _rtsp            = ([details objectForKey:@"url"])? [details objectForKey:@"url"]:@"";
    }
    return self;
}

@end
