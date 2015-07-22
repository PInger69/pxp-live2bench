//
//  Tag.h
//  Live2BenchNative
//
//  Created by dev on 2015-04-17.
//  Copyright (c) 2015 DEV. All rights reserved.
//
// NOTES
//#default			= 0
//
//#deleted			= 3 - this one shouldn't happen on tagSet
//#telestration 		= 4
//
//#start o-line     	= 1 - hockey
//#stop o-line     	= 2 - hockey
//#start d-line		= 5 - hockey
//#stop  d-line		= 6 - hockey
//#period start		= 7 - hockey
//#period	stop		= 8 - hockey
//#opp. o-line start 	= 9 - hockey
//#opp. o-line stop 	= 10- hockey
//#opp. d-line start 	= 11- hockey
//#opp. d-line stop 	= 12- hockey
//#strength start 	= 13- hockey
//#strength stop 		= 14- hockey
//
//#half start 		= 15- soccer
//#half stop 			= 16- soccer
//#zone start 		= 17- soccer
//#zone stop 			= 18- soccer
//
//#down start 		= 19- football
//#down stop 			= 20- football
//#quarter start 		= 21- football
//#quarter stop 		= 22- football

//type 0: normal tag, type 4: tele tag, type 100: duration tag,type 2: offense line shift, type 6: defense line shift, type 16: soccer zone shift


#import <Foundation/Foundation.h>
#import "FilterItemProtocol.h"
#import "Event.h"
#import "PxpTelestration.h"

typedef NS_ENUM (NSInteger,TagType){
    TagTypeNormal                  = 0,
    TagTypeLine                    = 2,
    TagTypeDeleted                 = 3,
    TagTypeTele                    = 4,
    TagTypeStrength                = 10,
    TagTypeOpenDuration            = 99,
    TagTypeCloseDuration           = 100,
    
    TagTypeHockeyStartOLine        = 1,
    TagTypeHockeyStopOLine         = 2,
    TagTypeHockeyStartDLine        = 5,
    TagTypeHockeyStopDLine         = 6,
    TagTypeHockeyPeriodStart       = 7,
    TagTypeHockeyPeriodStop        = 8,
    TagTypeHockeyOppOLineStart     = 9,
    TagTypeHockeyOppOLineStop      = 10,
    TagTypeHockeyOppDLineStart     = 11,
    TagTypeHockeyOppDLineStop      = 12,
    TagTypeHockeyStrengthStart     = 13,
    TagTypeHockeyStrengthStop      = 14,
    TagTypeSoccerHalfStart         = 15,
    TagTypeSoccerHalfStop          = 16,
    TagTypeSoccerZoneStart         = 17,
    TagTypeSoccerZoneStop          = 18,
    TagTypeFootballDownStart       = 19,
    TagTypeFootballDownStop        = 20,
    TagTypeFootballQuarterStart    = 21,
    TagTypeFootballQuarterStop     = 22
    
};

@interface Tag : NSObject<FilterItemProtocol>


@property (strong, nonatomic) NSDictionary  *rawData;
@property (strong, nonatomic) NSString      *colour;
@property (strong, nonatomic) NSString      *comment;
@property (strong, nonatomic) NSString      *deviceID;
@property (strong, nonatomic) NSString      *displayTime;
@property (assign, nonatomic) int           duration;
@property (strong, nonatomic) Event         * event;
@property (strong, nonatomic) NSString      *homeTeam;
@property (strong, nonatomic) NSString      *visitTeam;
@property (assign, nonatomic) int           uniqueID;
@property (strong, nonatomic) NSString      *ID;
@property (assign, nonatomic) BOOL          isLive;
@property (strong, nonatomic) NSString      *name;
@property (assign, nonatomic) BOOL          own;
@property (assign, nonatomic) NSInteger           rating;
@property (strong, nonatomic) NSString      *requestURL;
@property (assign, nonatomic) double        startTime;
@property (assign, nonatomic) double        time;
@property (assign, nonatomic) TagType       type;
@property (strong, nonatomic) NSDictionary  *thumbnails;
@property (strong, nonatomic) NSString      *user;
@property (assign, nonatomic) BOOL          synced;
@property (assign, nonatomic) BOOL          modified;
@property (assign, nonatomic) BOOL          coachPick;
@property (strong, nonatomic) NSDictionary  *feeds;
//@property (strong, nonatomic) NSString *requestTime;
@property (strong, nonatomic) NSString      *durationID;

/// The telestration accociated with the tag.
@property (strong, nonatomic, nullable) PxpTelestration *telestration;

+(void)clearDurationTags;
+( NSString *)makeDurationID;
+(void)addOpenDurationTag:(Tag*)tag dtid:(NSString*)uid;
+(Tag*)getOpenTagByDurationId:(NSString*)uid;



-(instancetype) initWithData: (NSDictionary *)tagData event:(Event*)aEvent;
-(NSDictionary *) tagDictionary;
-(NSDictionary *) modifiedData;
-(NSDictionary *) makeTagData;
-(void) replaceDataWithDictionary: (NSDictionary *) tagData;

- (nullable UIImage *)thumbnailForSource:(nullable NSString *)source;

@end
