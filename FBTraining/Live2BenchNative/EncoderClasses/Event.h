//
//  Event.h
//  Live2BenchNative
//
//  Created by dev on 2015-04-01.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EncoderProtocol.h"
#import "CameraResource.h"
#import "CameraResourceNonLive.h"
#import "TagProtocol.h"

@class Tag;


@protocol EventDelegate <NSObject>

@optional
-(void)onEventBuildFinished:(Event*)event;


@end




@interface Event : NSObject


@property (nonatomic,strong) NSString               * name;
@property (nonatomic,strong) NSString               * eventType;
@property (nonatomic,strong) NSString               * datapath;
@property (nonatomic,strong) NSString               * date;
@property (nonatomic,strong) NSString               * hid;
@property (nonatomic,strong) NSMutableArray         * advancedfeeds;
@property (nonatomic,strong) NSMutableDictionary    * feeds;
@property (nonatomic,strong) NSDictionary           * originalFeeds;
@property (nonatomic,strong) NSDictionary           * mp4s;
@property (nonatomic,strong) NSMutableDictionary    * rawData;
@property (nonatomic,strong) NSMutableArray         * tags;
@property (nonatomic,assign) BOOL                   deleted;
@property (nonatomic,assign) BOOL                   local;
@property (nonatomic,assign) BOOL                   live;
@property (nonatomic,assign) BOOL                   primary;

@property (nonatomic,strong) CameraResource         * cameraResource;

@property (nonatomic, strong) NSMutableDictionary  * downloadingItemsDictionary;

//This property contains tags that have not yet been uploaded to the server
@property (nonatomic,strong) NSMutableDictionary    * localTags;

@property (nonatomic,strong) NSMutableArray        * downloadedSources; // this is a list of strings of videos that are on the device

@property (nonatomic,weak)  id <EventDelegate>      delegate;

@property (nonatomic,strong) NSDictionary           * teams;
@property (nonatomic,strong) id <EncoderProtocol>   parentEncoder;
@property (nonatomic,assign) BOOL                   isBuilt;
@property (nonatomic, copy)  void(^onComplete)();

@property (nonatomic,assign,readonly) BOOL                   open;

@property (nonatomic,strong) id <TagProtocol>   gameStartTag;


-(instancetype)initWithDict:(NSDictionary*)data isLocal:(BOOL)isLocal andlocalPath:(NSString *)path;
-(instancetype)initWithDict:(NSDictionary*)data localPath:(NSString *)path;
-(void)openEvent;
-(void)closeEvent;

-(void)addTag:(id<TagProtocol>)newtag extraData:(BOOL)notifPost;
-(void)addAllTags:(NSDictionary *)allTagData;
-(void)modifyTag:(NSDictionary *)modifiedData;
-(NSArray*)getTagsByID:(NSString*)tagId;

-(float)gameStartTime;
-(float)gameEndTime;


-(void)build;
-(void)buildFeeds;
-(void)destroy;
@end
