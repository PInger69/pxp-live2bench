//
//  TagProtocol.h
//  Live2BenchNative
//
//  Created by dev on 2016-06-13.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PxpTelestration;
typedef NS_ENUM (NSInteger,TagType){
    TagTypeNormal                  = 0,
    //TagTypeLine                    = 2,
    TagTypeDeleted                 = 3,
    TagTypeTele                    = 4,
    //TagTypeStrength                = 10,
    //    TagTypeOpenDuration            = 99,
    TagTypeCloseDurationOLD           = 100,
    
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
    
    /*TagTypeSoccerHalfStart         = 15,
     TagTypeSoccerHalfStop          = 16,
     TagTypeSoccerZoneStart         = 17,
     TagTypeSoccerZoneStop          = 18,*/
    
    TagTypeSoccerHalfStart         = 17,
    TagTypeSoccerHalfStop          = 18,
    TagTypeSoccerZoneStart         = 15,
    TagTypeSoccerZoneStop          = 16,
    
    TagTypeFootballDownStart       = 19,
    TagTypeFootballDownStop        = 20,
    TagTypeFootballQuarterStart    = 21,
    TagTypeFootballQuarterStop     = 22,
    
    TagTypeFootballDownTags        = 1002,
    TagTypeOpenDuration            = 1004,
    TagTypeCloseDuration           = 1006,
    
};

@class Event;

@protocol TagProtocol <NSObject>
@property (nonatomic) NSDictionary          * rawData; // same but Copy Dict Depericated
@property (strong, nonatomic) Event        	* eventInstance;
@property (assign, nonatomic) TagType       type;
@property (strong, nonatomic) NSDictionary  * thumbnails;
@property (strong, nonatomic) NSDictionary  * feeds;

@property (assign, nonatomic) double 			time;
@property (assign, nonatomic) double        startTime;
@property (assign, nonatomic) double        closeTime;
@property (assign, nonatomic) int 			duration;
@property (assign, nonatomic) int           uniqueID;
@property (assign,nonatomic,readonly) BOOL 	own;
@property (assign, nonatomic) BOOL          isLive;
@property (assign, nonatomic) BOOL          deleted;
@property (assign, nonatomic) BOOL          modified;
@property (assign, nonatomic) BOOL          coachPick;
@property (assign, nonatomic) NSInteger 	rating;

@property (strong, nonatomic) NSString 		* name;
@property (strong, nonatomic) NSString 		* user;
@property (strong, nonatomic) NSString 		* colour;
@property (strong, nonatomic) NSString      * event;
@property (strong, nonatomic) NSString      * comment;
@property (strong, nonatomic) NSString      * deviceID;
@property (strong, nonatomic) NSString      * displayTime;
@property (strong, nonatomic) NSString      * homeTeam;
@property (strong, nonatomic) NSString      * visitTeam;
@property (strong, nonatomic) NSString      * ID;
@property (strong, nonatomic) NSString      * requestURL;
@property (strong, nonatomic) NSString      * durationID;
@property (assign, nonatomic) NSString      * period;

@property (strong, nonatomic, nullable) PxpTelestration *telestration;

- (nullable UIImage *)thumbnailForSource:(nullable NSString *)source;

// used by the local Encoder

@optional
@property (nonatomic,strong) NSMutableDictionary * tagData; // Model for tag
@property (assign, nonatomic) BOOL         	 synced; // depricated
@property (strong, nonatomic) NSDictionary   *extraDic;
@property (strong, nonatomic) NSArray        *players;

@end
