//
//  LocalEncoder.h
//  Live2BenchNative
//
//  Created by dev on 2014-11-13.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "Encoder.h" // what ever is taken from this needs to be moved to the protocol
#import "EncoderProtocol.h"
#import "Event.h"
/**
 *  This class acts like a normal Encoder but all tags and event are local to the device
 *  as well as bookmarked clips for sharing.
 */


@interface LocalEncoder : NSObject <EncoderProtocol>

@property (nonatomic,strong)    NSString                * name;
@property (nonatomic,assign)    EncoderStatus           status;
@property (nonatomic,strong)    NSString                * statusAsString;
@property (nonatomic,strong)    NSString                * event;            // the current event the encoder is looking at
@property (nonatomic,strong)    NSString                * eventType;        // the current event the encoder is looking at
@property (nonatomic,strong)    NSArray                 * eventTags;        // the current event the encoder is looking at
@property (nonatomic,strong)    NSString                * liveEventName;
@property (nonatomic,strong)    NSDictionary            * eventData;        //raw dict
@property (nonatomic,strong)    NSArray                 * allEvents;        // all events on the encoder
@property (nonatomic,strong)    NSArray                 * allEventData;
@property (nonatomic,strong)    NSMutableDictionary     * eventTagsDict;    // keys are event names
@property (nonatomic,strong)    NSDictionary            * feeds;            // feeds for current event

@property (nonatomic,strong)    NSDictionary    * teams;
@property (nonatomic,strong)    NSDictionary    * playerData;
@property (nonatomic,strong)    NSDictionary    * league;

-(id)initWithDocsPath:(NSString*)aDocsPath;

#pragma mark - EncoderProtocol Methods
-(void)issueCommand:(NSString *)methodName priority:(int)priority timeoutInSec:(float)time tagData:(NSMutableDictionary*)tData  timeStamp:(NSNumber *)aTimeStamp;
-(void)clearQueueAndCurrent;



#pragma mark - Bookmark Clip Methods

@property (nonatomic,strong)    NSMutableDictionary * clipFeeds;    // This is all feeds kept on the device  key:<ClipName> value:<Feed>
//@property (nonatomic,strong)    NSMutableDictionary * clipFeedsDict;

-(NSInteger)getBookmarkSpace;
-(NSString*)bookmarkPath;
-(NSString*)bookmarkedVideosPath;
-(void)saveClip:(NSString*)aName withData:(NSDictionary*)tagData;//video file
-(void)deleteClip:(NSString*)aName;

-(void)saveEvent:(Event*)aEvent;
-(void)deleteEvent:(NSString*)aHid;

@end
