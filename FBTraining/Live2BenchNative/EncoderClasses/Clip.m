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
        _rating             = [_rawData objectForKey:@"rating"];
        _comment            = [_rawData objectForKey:@"comment"];
        _feeds              = [self buildFeeds:_rawData];
        _path               = [_rawData objectForKey:@"plistName"];

    
    }
    return self;
}


-(NSDictionary*)buildFeeds:(NSDictionary*)aDict
{
    
    NSMutableDictionary * tempDict = [[NSMutableDictionary alloc]init];
    
//    
//    if ([aDict[@"vid_2"] isKindOfClass:[NSDictionary class]]){ // For new encoder and non live
//        
//        for (id key in aDict[@"vid_2"])
//        {
//            NSDictionary * vidDict      = aDict[@"vid_2"];
//            NSDictionary * qualities    = [vidDict objectForKey:key];
//            
//            Feed * createdFeed = [[Feed alloc]initWithURLDict:qualities];
//            createdFeed.sourceName = key;
//            
//            [tempDict setObject:createdFeed forKey:key];
//        }
//        
//    } else if ([aDict[@"live_2"] isKindOfClass:[NSDictionary class]]){ // for new encoder and Live
//        
//        for (id key in aDict[@"live_2"])
//        {
//            NSDictionary * vidDict      = aDict[@"live_2"];
//            NSDictionary * qualities    = [vidDict objectForKey:key];
//            
//            Feed * createdFeed = [[Feed alloc]initWithURLDict:qualities];
//            createdFeed.sourceName = key;
//            
//            [tempDict setObject:createdFeed forKey:key];
//        }
//        
//    }
    
    
    return [tempDict copy];
}




@end
