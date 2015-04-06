//
//  Event.m
//  Live2BenchNative
//
//  Created by dev on 2015-04-01.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "Event.h"
#import "Feed.h"


@implementation Event

@synthesize name        = _name;
@synthesize eventType   = _eventType;
@synthesize datapath    = _datapath;
@synthesize date        = _date;
@synthesize hid         = _hid;
@synthesize feeds       = _feeds;
@synthesize rawData     = _rawData;
@synthesize deleted     = _deleted;
@synthesize local       = _local;


- (instancetype)initWithDict:(NSDictionary*)data
{
    self = [super init];
    if (self) {

        _rawData    = data;
        
        _name       = [_rawData objectForKey:@"name"];
        _hid        = [_rawData objectForKey:@"hid"];
        _eventType  = [_rawData objectForKey:@"sport"];
        _datapath   = [_rawData objectForKey:@"datapath"];
        _date       = [_rawData objectForKey:@"date"];
        _feeds      = [self buildFeeds:_rawData];
        _deleted    = [[_rawData objectForKey:@"deleted"]boolValue];
    }
    return self;
}













/**
 *  This makes the feeds from the data and returns the a dict based of the feeds labeled by scource name as key
 *
 *  @param dict raw data
 *
 *  @return key
 */
-(NSDictionary*)buildFeeds:(NSDictionary*)aDict
{
   
    NSMutableDictionary * tempDict = [[NSMutableDictionary alloc]init];
    

        if ([aDict[@"vid_2"] isKindOfClass:[NSDictionary class]]){ // For new encoder and non live
           
            for (id key in aDict[@"vid_2"])
            {
                NSDictionary * vidDict      = aDict[@"vid_2"];
                NSDictionary * qualities    = [vidDict objectForKey:key];
                
                Feed * createdFeed = [[Feed alloc]initWithURLDict:qualities];
                createdFeed.sourceName = key;
                
                [tempDict setObject:createdFeed forKey:key];
            }
            
        } else if ([aDict[@"live_2"] isKindOfClass:[NSDictionary class]]){ // for new encoder and Live
            
            for (id key in aDict[@"live_2"])
            {
                NSDictionary * vidDict      = aDict[@"live_2"];
                NSDictionary * qualities    = [vidDict objectForKey:key];
                
                Feed * createdFeed = [[Feed alloc]initWithURLDict:qualities];
                createdFeed.sourceName = key;
                
                [tempDict setObject:createdFeed forKey:key];
            }

        } else { // for old encoder
            
            Feed * theFeed;
            if (aDict[@"live"]) { // This is for backwards compatibility
                theFeed =  [[Feed alloc]initWithURLString:aDict[@"live"] quality:0];
            } else if (aDict[@"vid"]) {
                theFeed =  [[Feed alloc]initWithURLString:aDict[@"vid"]  quality:0];
            } else {
                NSLog(@"Event Class issue");
                return @{};
            }
            [tempDict setObject:theFeed forKey:@"s1"];
        }


    return [tempDict copy];
}


@end
