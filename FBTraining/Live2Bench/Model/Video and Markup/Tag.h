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
#import "TagProtocol.h"

@interface Tag : NSObject<FilterItemProtocol,TagProtocol>
{

    NSInteger _rating;
}
NS_ASSUME_NONNULL_BEGIN

@property (strong, nonatomic) NSDictionary  *rawData;
@property (strong, nonatomic) NSString      *colour;
@property (strong, nonatomic) NSString      *comment;
@property (strong, nonatomic) NSString      *deviceID;
@property (strong, nonatomic) NSString      *displayTime;
@property (assign, nonatomic) int           duration;
@property (strong, nonatomic) NSString      * event;
@property (strong, nonatomic) Event         * eventInstance;
@property (strong, nonatomic) NSString      *homeTeam;
@property (strong, nonatomic) NSString      *visitTeam;
@property (assign, nonatomic) int           uniqueID;
@property (strong, nonatomic) NSString      *ID;
@property (assign, nonatomic) BOOL          isLive;
@property (strong, nonatomic) NSString      *name;
@property (assign, nonatomic) BOOL          own;
@property (assign, nonatomic) NSInteger     rating;
@property (strong, nonatomic) NSString      *requestURL;
@property (assign, nonatomic) double        startTime;
@property (assign, nonatomic) double        closeTime;
@property (assign, nonatomic) double        time;
@property (assign, nonatomic) TagType       type;
@property (strong, nonatomic) NSDictionary  *thumbnails;
@property (strong, nonatomic) NSString      *user;
@property (assign, nonatomic) BOOL          synced;
@property (assign, nonatomic) BOOL          modified;
@property (assign, nonatomic) BOOL          coachPick;
@property (strong, nonatomic) NSDictionary  *feeds;
@property (strong, nonatomic) NSString      *durationID;
@property (strong, nonatomic) NSString      *period;
@property (strong,nonatomic) NSArray        *players;
@property (strong,nonatomic) NSDictionary   *extraDic;
@property (assign,nonatomic) NSInteger      role;
@property (strong,nonatomic) NSString       * userTeam;
@property (assign, nonatomic) BOOL          deleted;

/// The telestration accociated with the tag.
@property (strong, nonatomic, nullable) PxpTelestration *telestration;

NS_ASSUME_NONNULL_END

+(void)clearDurationTags;
+(nonnull NSString *)makeDurationID;
+(void)addOpenDurationTag:(nonnull Tag*)tag dtid:(nonnull NSString*)uid;
+(nullable Tag*)getOpenTagByDurationId:(nonnull NSString*)uid;



-(nonnull instancetype) initWithData: (nonnull NSDictionary *)tagData event:(nullable Event*)aEvent;
-(nonnull NSDictionary *) tagDictionary;
-(nonnull NSDictionary *) modifiedData;
-(nonnull NSDictionary *) makeTagData;
-(void) replaceDataWithDictionary: (nonnull NSDictionary *) tagData;

- (nullable UIImage *)thumbnailForSource:(nullable NSString *)source;

@end
