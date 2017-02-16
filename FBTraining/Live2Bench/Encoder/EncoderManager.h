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
#import "ActionListItemDelegate.h"
#import "LocalMediaManager.h"
#import "BonjourModule.h"
#import "CustomAlertControllerQueue.h"
#import "FeedMapController.h"

#import "LocalTagSyncManager.h"

@class Encoder;




#define NOTIF_ENCODER_COUNT_CHANGE          @"encoderCountChange"
//#define NOTIF_THIS_ENCODER_IS_READY         @"encoderIsReady" // this is called on the encoder in question
#define NOTIF_ENCODER_AUTHENTICATED         @"encoderAuthenticated"
#define NOTIF_ENCODER_FEED_HAVE_CHANGED     @"encoderFeedHaveChanged"
#define NOTIF_TAG_POSTED                    @"postedTag"        // to post tages up to the server also sends the data in userInfo
//#define NOTIF_TAG_RECIEVED                  @"recievedTag"      // when new tags are recieved from the encoder also passes the data in userInfo
#define NOTIF_TAG_NAMES_FROM_CLOUD          @"tagNamesFromCloud"

#define SUMMARY_TYPE_MONTH  @"month"
#define SUMMARY_TYPE_EVENT  @"game"


@interface EncoderManager : NSObject <NSNetServiceBrowserDelegate,NSNetServiceDelegate,ActionListItemDelegate,BonjourModuleDelegate>

@property (nonatomic,strong)            BonjourModule           * bonjourModule;


//@property (nonatomic,assign)            BOOL                    hasInternet;
//@property (nonatomic,assign)            BOOL                    hasWiFi; // Toggled by checkForWiFiAction
@property (atomic,assign)            BOOL                    hasMAX;
@property (atomic,assign)            BOOL                    searchForEncoders;
@property (atomic,assign)            BOOL                    hasLive; // all the Encoders status checkers will effect this if non have live or if one has
@property (atomic,strong)            NSString                * liveEventName;
@property (atomic,strong)            NSMutableDictionary     * feeds; // this is an array of Dicts @{ @"feedPath": @"???", @"feedName":@"???" }
@property (atomic,strong)            NSMutableArray          * allEvents;
@property (atomic,strong)            NSMutableArray          * allEventData;
@property (atomic,strong)            NSMutableArray          * authenticatedEncoders;
@property (atomic,strong)            NSString                * currentEvent;
@property (atomic,strong)            NSMutableArray          * currentEventTags;
@property (atomic,strong,readonly)   NSString                * currentEventType; // like sport or medical
@property (atomic,strong,readonly)   NSDictionary            * currentEventData; // like sport or medical
@property (atomic,strong)            NSMutableDictionary     * openDurationTags;
@property (atomic,strong)            NSMutableDictionary     * eventTags; // keys are event names



@property (atomic,weak)              Event                   * liveEvent;


// important encoders
@property (nonatomic,strong)            Encoder                 * masterEncoder; // Main box encoder
@property (nonatomic,strong)            LocalEncoder            * localEncoder;  // the device acts like an in app encoder / with clips
@property (nonatomic,strong)            LocalMediaManager       * localMediaManager;
@property (nonatomic,strong)            CloudEncoder            * cloudEncoder;  // 
@property (nonatomic,strong)            id <EncoderProtocol>    primaryEncoder;

@property (nonatomic,strong)            Encoder                 * deviceEncoder;
@property (nonatomic,weak)              FeedMapController       * feedMapController;
@property (nonatomic,strong)            LocalTagSyncManager     * localTagSyncManager;

#pragma mark - Encoder Manager Methods

+(EncoderManager*)getInstance;

-(id)initWithLocalDocPath:(NSString*)aLocalDocsPath;

-(void)requestTagDataForEvent:(NSString*)event onComplete:(void(^)(NSDictionary*all))onCompleteGet;

-(Event*)getEventByHID:(NSString*)eventHID;
-(Event*)getEventByName:(NSString*)eventName;

-(void)registerEncoder:(NSString*)name ip:(NSString*)ip;
-(void)onRegisterEncoderCompleted:(Encoder*)registerEncoder; 

-(void)unRegisterEncoder:(Encoder *) aEncoder;

-(void)declareCurrentEvent:(Event*)event;

-(void)makeFakeEncoder; // debug

#pragma mark - Commands Methods

//-(void)refresh;
-(void)logoutOfCloud; // Depricated
-(void)onLoginToCloud; // Depricated

-(id<ActionListItem>)checkForWiFiAction;
-(id<ActionListItem>)checkForACloudAction;
-(id<ActionListItem>)checkForMasterAction;

@end
