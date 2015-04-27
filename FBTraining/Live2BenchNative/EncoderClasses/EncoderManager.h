//
//  EncoderManager.h
//  Live2BenchNative
//
//  Created by dev on 10/17/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActionList.h"
#import "EncoderProtocol.h"
#import "CloudEncoder.h"
#import "LocalEncoder.h"
#import "Event.h"


@class Encoder;



typedef NS_OPTIONS(NSInteger, EncoderManagerMode) {
    EncoderManagerModeOnline   = 1<<1,
    EncoderManagerModeOffline  = 1<<2
};


#define NOTIF_ENCODER_COUNT_CHANGE          @"encoderCountChange"
#define NOTIF_THIS_ENCODER_IS_READY         @"encoderIsReady" // this is called on the encoder in question
#define NOTIF_ENCODER_AUTHENTICATED         @"encoderAuthenticated"
#define NOTIF_ENCODER_FEED_HAVE_CHANGED     @"encoderFeedHaveChanged"
#define NOTIF_TAG_POSTED                    @"postedTag"        // to post tages up to the server also sends the data in userInfo
//#define NOTIF_TAG_RECIEVED                  @"recievedTag"      // when new tags are recieved from the encoder also passes the data in userInfo
#define NOTIF_TAG_NAMES_FROM_CLOUD          @"tagNamesFromCloud"

#define SUMMARY_TYPE_MONTH  @"month"
#define SUMMARY_TYPE_EVENT  @"game"


@interface EncoderManager : NSObject <NSNetServiceBrowserDelegate,NSNetServiceDelegate>

@property (nonatomic,assign)            EncoderManagerMode      mode;

@property (nonatomic,assign)            BOOL                    hasInternet;
@property (nonatomic,assign)            BOOL                    hasWiFi; // Toggled by checkForWiFiAction
@property (nonatomic,assign)            BOOL                    hasMAX;
@property (nonatomic,assign)            BOOL                    searchForEncoders;
@property (nonatomic,assign)            BOOL                    hasLive; // all the Encoders status checkers will effect this if non have live or if one has
@property (nonatomic,strong)            NSString                * liveEventName;
@property (nonatomic,strong)            NSMutableDictionary     * feeds; // this is an array of Dicts @{ @"feedPath": @"???", @"feedName":@"???" }
@property (nonatomic,strong)            NSMutableArray          * allEvents;
@property (nonatomic,strong)            NSMutableArray          * allEventData;
@property (nonatomic,strong)            NSMutableArray          * authenticatedEncoders;
@property (nonatomic,strong)            NSString                * currentEvent;
@property (nonatomic,strong)            NSMutableArray          * currentEventTags;
@property (nonatomic,strong,readonly)   NSString                * currentEventType; // like sport or medical
@property (nonatomic,strong,readonly)   NSDictionary            * currentEventData; // like sport or medical
@property (nonatomic,strong)            NSMutableDictionary     * openDurationTags;
@property (nonatomic,strong)            NSMutableDictionary     * eventTags; // keys are event names


// important encoders
@property (nonatomic,strong)            Encoder                 * masterEncoder; // Main box encoder
@property (nonatomic,strong)            LocalEncoder            * localEncoder;  // the device acts like an in app encoder / with clips
@property (nonatomic,strong)            CloudEncoder            * cloudEncoder;  // 
@property (nonatomic,strong)            id <EncoderProtocol>    primaryEncoder;


@property (nonatomic,assign,readonly)   NSInteger               totalCameraCount;

@property (nonatomic,strong)            NSString                * customerID;


#pragma mark - Encoder Manager Methods
-(id)initWithLocalDocPath:(NSString*)aLocalDocsPath;



-(void)reqestSummaryId:(NSString*)aId type:(NSString*)aType onComplete:(void(^)(NSArray*pooled))onCompleteGet;

-(void)reqestTeamData:(void(^)(NSArray*pooled))onCompleteGet;

-(void)createTag:(NSMutableDictionary *)data isDuration:(BOOL)isDuration;

-(void)modifyTag:(NSMutableDictionary *)data;

-(void)closeDurationTag:(NSString *)tagName;


-(void)requestTagDataForEvent:(NSString*)event onComplete:(void(^)(NSDictionary*all))onCompleteGet;

-(Event*)getEventByHID:(NSString*)eventHID;

#pragma mark - Commands Methods

-(void)refresh;
-(void)logoutOfCloud;


#pragma mark - Debugging Methods
/**
 *  Removes all external Encoders and disables searching for others
 *  This is to be used for Debugging
 */
-(void)removeAllExternalEncoders;


-(id<ActionListItem>)checkForWiFiAction;
-(id<ActionListItem>)checkForACloudAction;
-(id<ActionListItem>)checkForMasterAction;
-(id<ActionListItem>)logoutAction;

@end
