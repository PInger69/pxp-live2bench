//
//  LocalEncoder.h
//  Live2BenchNative
//
//  Created by dev on 2014-11-13.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "Encoder.h" // what ever is taken from this needs to be moved to the protocol
#import "EncoderProtocol.h"
#import "ActionListItem.h"

@class Event;
@class Clip;
@class Tag;

/**
 *  This class acts like a normal Encoder but all tags and event are local to the device
 *  as well as bookmarked clips for sharing.
 */


@interface LocalEncoder : NSObject <EncoderProtocol, NSURLConnectionDataDelegate,ActionListItem,EventDelegate>

@property (nonatomic, weak)     EncoderManager          *encoderManager;
//@property (nonatomic,strong)    NSString                * name;
@property (nonatomic,assign)    EncoderStatus           status;
@property (nonatomic,strong)    NSString                * statusAsString;
@property (nonatomic,strong)    Event                   * event;            // the current event the encoder is looking at
@property (nonatomic,strong)    Event                   * liveEvent;
//@property (nonatomic,strong)    NSDictionary            * allEvents;        // all events on the encoder
@property (nonatomic,strong)    NSMutableArray     * localTags;
@property (nonatomic,strong)    NSMutableArray     * modifiedTags;
@property (nonatomic, strong)   NSString                *localPath;





-(id)initWithDocsPath:(NSString*)aDocsPath;

#pragma mark - EncoderProtocol Methods
-(void)issueCommand:(NSString *)methodName priority:(int)priority timeoutInSec:(float)time tagData:(NSMutableDictionary*)tData  timeStamp:(NSNumber *)aTimeStamp;



#pragma mark - Bookmark Clip Methods
//@property (nonatomic,strong)    NSMutableDictionary * clips;    // This is all feeds kept on the device  key:<id> value:<Clip>

+(instancetype)getInstance;

-(NSInteger)getBookmarkSpace;
//-(NSString*)bookmarkPath;  // make readonly Props
//-(NSString*)bookmarkedVideosPath; // make readonly Props
//-(void)saveClip:(NSString*)aName withData:(NSDictionary*)tagData;//video file
//-(void)deleteClip:(NSString*)aName;


//-(NSString*)saveEvent:(Event*)aEvent;
//-(void)deleteEvent:(Event*)aEvent;
//-(Event*)getEventByName:(NSString*)eventName;


// ActionListItem Methods
@property (nonatomic,assign) BOOL isFinished;
@property (nonatomic,assign) BOOL isSuccess;
@property (nonatomic,weak)  id <ActionListItemDelegate>  delegate;

-(void)start;

@end
