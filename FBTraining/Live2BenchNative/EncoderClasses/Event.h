//
//  Event.h
//  Live2BenchNative
//
//  Created by dev on 2015-04-01.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface Event : NSObject


@property (nonatomic,strong) NSString               * name;
@property (nonatomic,strong) NSString               * eventType;
@property (nonatomic,strong) NSString               * datapath;
@property (nonatomic,strong) NSString               * date;
@property (nonatomic,strong) NSString               * hid;
@property (nonatomic,strong) NSDictionary           * feeds;
@property (nonatomic,strong) NSDictionary           * mp4s;
@property (nonatomic,strong) NSDictionary           * rawData;
@property (nonatomic,strong) NSMutableDictionary    * tags;
@property (nonatomic,assign) BOOL                   deleted;
@property (nonatomic,assign) BOOL                   local;
@property (nonatomic,assign) BOOL                   live;

@property (nonatomic,strong) NSArray        * downloadedSources; // this is a list of strings of videos that are on the device


// These need to be cleaned
@property (nonatomic,strong) NSDictionary        * teams;
@property (nonatomic,strong) NSDictionary        * playerData;
@property (nonatomic,strong) NSDictionary        * league;



-(instancetype)initWithDict:(NSDictionary*)data;
@end
