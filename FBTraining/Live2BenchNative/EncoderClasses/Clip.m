//
//  Clip.m
//  Live2BenchNative
//
//  Created by dev on 2015-04-09.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "Clip.h"
#import "Feed.h"


@implementation Clip

@synthesize name        = _name;
@synthesize clipId      = _clipId;
@synthesize rating      = _rating;
@synthesize comment     = _comment;
@synthesize feeds       = _feeds;
@synthesize rawData     = _rawData;
@synthesize path        = _path;




-(instancetype)initWithDict:(NSDictionary*)data
{
    self = [super init];
    if (self) {
        
        _rawData            = data;
        _name               = [_rawData objectForKey:@"name"];
        _clipId             = [_rawData objectForKey:@"id"];
        _rating             =[_rawData objectForKey:@"name"];
        _comment            =[_rawData objectForKey:@"name"];
        _feeds              =[_rawData objectForKey:@"name"];
        _path               =[_rawData objectForKey:@"name"];

        
//        _datapath           = [_rawData objectForKey:@"datapath"];
//        _date               = [_rawData objectForKey:@"date"];
//        _mp4s               = [self buildMP4s:_rawData];
//        _feeds              = [self buildFeeds:_rawData];

        
        
        
    }
    return self;
}







@end
