//
//  Tag.h
//  Live2BenchNative
//
//  Created by dev on 2015-04-17.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FilterItemProtocol.h"
#import "Event.h"

typedef NS_ENUM (NSInteger,TagType){
    TagTypeNormal   = 0,
    TagTypeLine     = 2,
    TagTypeDeleted  = 3,
    TagTypeTele     = 4,
    TagTypeStrength = 10
};

@interface Tag : NSObject<FilterItemProtocol>

@property (strong, nonatomic) NSDictionary *rawData;
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

-(instancetype) initWithData: (NSDictionary *)tagData event:(Event*)aEvent;
-(NSDictionary *) tagDictionary;
-(NSDictionary *) modifiedData;
-(NSDictionary *) makeTagData;
-(void) replaceDataWithDictionary: (NSDictionary *) tagData;

@end
