//
//  EncoderManager.h
//  Live2BenchNative
//
//  Created by dev on 10/17/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UtilitiesController.h"

@class Encoder;
#define NOTIF_ENCODER_COUNT_CHANGE          @"encoderCountChange"
#define NOTIF_THIS_ENCODER_IS_READY         @"encoderIsReady" // this is called on the encoder in question
#define NOTIF_ENCODER_AUTHENTICATED         @"encoderAuthenticated"
#define NOTIF_ENCODER_FEED_HAVE_CHANGED     @"encoderFeedHaveChanged"
#define NOTIF_TAG_POSTED                    @"postedTag"        // to post tages up to the server also sends the data in userInfo
#define NOTIF_TAG_RECIEVED                  @"recievedTag"      // when new tags are recieved from the encoder also passes the data in userInfo
#define NOTIF_TAG_NAMES_FROM_CLOUD          @"tagNamesFromCloud"

#define SUMMARY_TYPE_MONTH  @"month"
#define SUMMARY_TYPE_EVENT  @"game"


@interface EncoderManager : NSObject <NSNetServiceBrowserDelegate,NSNetServiceDelegate>


@property (nonatomic,readonly)          BOOL                    hasInternet;
@property (nonatomic,readonly)          BOOL                    hasWiFi;
@property (nonatomic,readonly)          BOOL                    hasMIN;
@property (nonatomic,readonly)          BOOL                    searchForEncoders;
@property (nonatomic,assign)            BOOL                    hasLive; // all the Encoders status checkers will effect this if non have live or if one has
@property (nonatomic,strong)            NSString                * liveEventName;
@property (nonatomic,strong)            NSMutableDictionary          * feeds; // this is an array of Dicts @{ @"feedPath": @"???", @"feedName":@"???" }
@property (nonatomic,strong)            NSMutableArray          * allEvents;
@property (nonatomic,strong)            NSMutableArray          * allEventData;
@property (nonatomic,strong)            NSMutableArray          * authenticatedEncoders;
@property (nonatomic,strong)            NSString                * currentEvent;
@property (nonatomic,strong)            NSMutableArray          * currentEventTags;
@property (nonatomic,strong,readonly)   NSString                * currentEventType; // like sport or medical
@property (nonatomic,strong,readonly)   NSDictionary            * currentEventData; // like sport or medical
@property (nonatomic,strong)            NSMutableDictionary     * openDurationTags;
@property (nonatomic,strong)            NSMutableDictionary     * eventTags; // keys are event names

@property (nonatomic,strong)            Encoder                 * masterEncoder;
@property (nonatomic,assign,readonly)   NSInteger               totalCameraCount;



#pragma mark - Encoder Manager Methods
-(id)initWithID:(NSString*)custID localDocPath:(NSString*)aLocalDocsPath;



-(void)reqestSummaryId:(NSString*)aId type:(NSString*)aType onComplete:(void(^)(NSArray*pooled))onCompleteGet;
-(void)updateSummaryId:(NSString*)aId type:(NSString*)aType summary:(NSString*)aSummary onComplete:(void(^)(NSArray*pooled))onCompleteGet;

-(void)reqestTeamData:(void(^)(NSArray*pooled))onCompleteGet;

-(void)createTag:(NSMutableDictionary *)data isDuration:(BOOL)isDuration;

-(void)modifyTag:(NSMutableDictionary *)data;

-(void)closeDurationTag:(NSString *)tagName;


-(void)requestTagDataForEvent:(NSString*)event onComplete:(void(^)(NSDictionary*all))onCompleteGet;



#pragma mark - Commands Methods

-(void)refresh;
#pragma mark - Debugging Methods
/**
 *  Removes all external Encoders and disables searching for others
 *  This is to be used for Debugging
 */
-(void)removeAllExternalEncoders;



@end
