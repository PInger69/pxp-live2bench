//
//  TagProxy.h
//  Live2BenchNative
//
//  Created by dev on 2016-06-13.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TagProtocol.h"
#import "FilterItemProtocol.h"
#import "PxpTelestration.h"

@interface TagProxy : NSObject <TagProtocol, FilterItemProtocol>
@property (nonatomic,strong) NSMutableDictionary * tagData;

@property (strong, nonatomic) NSDictionary  * rawData; // same but Copy Dict Depericated
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

// optionals? check
@property (assign, nonatomic) BOOL         	 synced; // depricated
@property (strong, nonatomic) NSDictionary   *extraDic;
@property (strong, nonatomic) NSArray        *players;



@property (strong, nonatomic, nullable) PxpTelestration *telestration;

- (instancetype)initWithTagData:(NSDictionary*)dict ownEvent:(Event*)event;

-(void)addTagToProxy:(id <TagProtocol>)tag;
-(BOOL)hasTag;

@end
