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
#import "EncoderOperation.h"
#import "LocalTagSyncManager.h"


@class Event;
@class Clip;
@class Tag;

/**
 *  This class acts like a normal Encoder but all tags and event are local to the device
 *  as well as bookmarked clips for sharing.
 */


@interface LocalEncoder : NSObject <EncoderProtocol, NSURLConnectionDataDelegate,ActionListItem,EventDelegate>

@property (nonatomic, weak)     EncoderManager          *encoderManager;
@property (nonatomic,strong) CameraResource * cameraResource;
//@property (nonatomic,strong)    NSString                * name;
@property (nonatomic,assign)    EncoderStatus           status;
@property (nonatomic,strong)    NSString                * statusAsString;
@property (nonatomic,strong)    Event                   * event;            // the current event the encoder is looking at
@property (nonatomic,strong)    Event                   * liveEvent;
//@property (nonatomic,strong)    NSDictionary            * allEvents;        // all events on the encoder
@property (nonatomic,strong)    NSMutableArray     * localTags;
@property (nonatomic,strong)    NSMutableArray     * modifiedTags;
@property (nonatomic, strong)   NSString                *localPath;


@property (nonatomic,strong)    NSString        *urlProtocol;//http
@property (nonatomic,strong)    NSString        * ipAddress;
@property (nonatomic,strong) LocalTagSyncManager    * localTagSyncManager;
@property (nonatomic,strong)  NSString        * version;
-(id)initWithDocsPath:(NSString*)aDocsPath;

#pragma mark - EncoderProtocol Methods
-(void)issueCommand:(NSString *)methodName priority:(int)priority timeoutInSec:(float)time tagData:(NSMutableDictionary*)tData  timeStamp:(NSNumber *)aTimeStamp;



#pragma mark - Bookmark Clip Methods
//@property (nonatomic,strong)    NSMutableDictionary * clips;    // This is all feeds kept on the device  key:<id> value:<Clip>

+(instancetype)getInstance;

-(NSInteger)getBookmarkSpace;


// ActionListItem Methods
@property (nonatomic,assign) BOOL isFinished;
@property (nonatomic,assign) BOOL isSuccess;
@property (nonatomic,weak)  id <ActionListItemDelegate>  delegate;
-(Event*)searchEventByName:(NSString*)eventName;

-(void)start;
-(void)checkEncoder;
-(void)resetEventAfterRemovingFeed:(Event *)event;

@end
