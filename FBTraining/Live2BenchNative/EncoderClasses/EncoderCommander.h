//
//  EncoderCommander.h
//  Live2BenchNative
//
//  Created by dev on 2015-06-08.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EncoderProtocol.h"
#import "Encoder.h"
#import "Event.h"
#import "Tag.h"
#import "Downloader.h"
#import "DownloadItem.h"


// this class is is a combo of Master and Slave Encoders

@interface EncoderCommander : NSObject <EncoderProtocol>


@property (nonatomic,strong)    NSString                * name;
@property (nonatomic, weak)     EncoderManager          * encoderManager;
@property (nonatomic,assign)    EncoderStatus           status;
@property (nonatomic,strong)    NSString                * statusAsString;
@property (nonatomic,strong)    Event                   * event;        // the current event the encoder is looking at
@property (nonatomic,strong)    NSDictionary            * allEvents;    // all events on the encoder keyed by HID
@property (nonatomic,strong)    NSMutableDictionary     * openDurationTags; // should be in events???

@property (nonatomic,strong)    NSString        * ipAddress;

@property (nonatomic,strong) Encoder        * masterEncoder;
@property (nonatomic,strong) NSMutableArray * allEncoders;

-(id <EncoderProtocol>)makePrimary;
-(id <EncoderProtocol>)removeFromPrimary;

-(void)addEncoder:(Encoder*)aEncoder;

-(void)issueCommand:(NSString *)methodName priority:(int)priority timeoutInSec:(float)time tagData:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp;

@end
