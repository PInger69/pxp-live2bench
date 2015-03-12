//
//  LocalEncoder.h
//  Live2BenchNative
//
//  Created by dev on 2014-11-13.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "Encoder.h"

@interface LocalEncoder : NSObject <EncoderCommands>


@property (nonatomic,strong)    NSString            * name;
@property (nonatomic,strong)    NSString            * event;        // the current event the encoder is looking at
@property (nonatomic,strong)    NSString            * eventType;        // the current event the encoder is looking at
@property (nonatomic,strong)    NSDictionary        * eventData;   //raw dict
@property (nonatomic,strong)    NSArray             * allEvents;    // all events on the encoder just the event names
@property (nonatomic,strong)    NSArray             * allEventData; // all the event dicts
@property (nonatomic,strong)    NSDictionary        * feeds;
@property (nonatomic,strong)    NSDictionary        * clipFeeds;    // This is all feeds kept on the device  key:<ClipName> value:<Feed>
@property (nonatomic,assign)    EncoderStatus       status;
@property (nonatomic,strong)    NSMutableDictionary * eventTagsDict;


-(id)initWithDocsPath:(NSString*)aDocsPath;

-(NSInteger)getBookmarkSpace;
-(NSString*)bookmarkPath;


-(void)deleteClip:(NSString*)name;

@end
