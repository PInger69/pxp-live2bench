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

@synthesize name        = _name;
@synthesize type        = _type;
@synthesize fps         = _fps;

-(id)initWithDictionary:(NSDictionary *)dict encoderOwner:(Encoder *)encoder
{
    self = [super init];
    if (self){
        
        details         = dict;

        _name           = ([details objectForKey:@"name"])?[details objectForKey:@"name"]:@"";
        _type           = ([details objectForKey:@"type"])?[details objectForKey:@"type"]:@"";
        _fps            = ([details objectForKey:@"fps"])?[NSNumber numberWithFloat:[[details objectForKey:@"fps"]floatValue]]:@0;
 
    }
    return self;
}

@end
