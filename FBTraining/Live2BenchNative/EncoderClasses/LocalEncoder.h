//
//  LocalEncoder.h
//  Live2BenchNative
//
//  Created by dev on 2014-11-13.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "Encoder.h" // what ever is taken from this needs to be moved to the protocol
#import "EncoderProtocol.h"
/**
 *  This class acts like a normal Encoder but all tags and event are local to the device
 *  as well as bookmarked clips for sharing.
 */


@interface LocalEncoder : NSObject <EncoderCommands,EncoderProtocol>


@property (nonatomic,strong)    NSString            * name;
@property (nonatomic,strong)    NSString            * event;        // the current event the encoder is looking at
@property (nonatomic,strong)    NSString            * eventType;        // the current event the encoder is looking at
@property (nonatomic,strong)    NSDictionary        * eventData;   //raw dict
@property (nonatomic,strong)    NSArray             * allEvents;    // all events on the encoder just the event names
@property (nonatomic,strong)    NSArray             * allEventData; // all the event dicts
@property (nonatomic,strong)    NSDictionary        * feeds;        // all feeds for current Event

@property (nonatomic,assign)    EncoderStatus       status;
@property (nonatomic,strong)    NSMutableDictionary * eventTagsDict;


@property (nonatomic,strong)    NSMutableDictionary * clipFeeds;    // This is all feeds kept on the device  key:<ClipName> value:<Feed>


-(id)initWithDocsPath:(NSString*)aDocsPath;

-(NSInteger)getBookmarkSpace;
-(NSString*)bookmarkPath;
-(NSString*)bookmarkedVideosPath;

#pragma mark - Bookmark Clip Methods
-(void)saveClip:(NSString*)aName withData:(NSDictionary*)tagData;//video file
-(void)deleteClip:(NSString*)aName;
@end
