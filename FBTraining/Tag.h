//
//  Tag.h
//  Live2BenchNative
//
//  Created by dev on 2015-04-17.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tag : NSObject

//@property (strong, nonatomic) NSDictionary *rawData;
@property (strong, nonatomic) NSString      *colour;
@property (strong, nonatomic) NSString      *comment;
//@property (strong, assign)
@property (strong, nonatomic) NSString      *deviceID;
@property (strong, nonatomic) NSString      *displayTime;
@property (assign, nonatomic) int           duration;
@property (strong, nonatomic) NSString      *event;
@property (strong, nonatomic) NSString      *homeTeam;
@property (strong, nonatomic) NSString      *visitTeam;
@property (assign, nonatomic) int           uniqueID;
@property (strong, nonatomic) NSString      *ID;
@property (assign, nonatomic) BOOL          isLive;
@property (strong, nonatomic) NSString      *name;
@property (assign, nonatomic) BOOL          own;
@property (assign, nonatomic) int           rating;
@property (strong, nonatomic) NSString      *requestURL;
@property (assign, nonatomic) double        startTime;
@property (assign, nonatomic) double        time;
@property (assign, nonatomic) int           type;
@property (strong, nonatomic) NSDictionary  *thumbnails;
@property (strong, nonatomic) NSString      *user;
@property (assign, nonatomic) BOOL          synced;
@property (assign, nonatomic) BOOL          modified;
@property (assign, nonatomic) BOOL          coachPick;
@property (strong, nonatomic) NSDictionary  *feeds;
//@property (strong, nonatomic) NSString *requestTime;

-(instancetype) initWithData: (NSDictionary *)tagData;
-(NSDictionary *) tagDictionary;
-(NSDictionary *) makeTagData;
-(void) replaceDataWithDictionary: (NSDictionary *) tagData;

@end
