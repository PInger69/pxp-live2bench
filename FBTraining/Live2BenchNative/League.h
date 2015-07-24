//
//  League.h
//  Live2BenchNative
//
//  Created by dev on 2015-07-22.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LeagueTeam;
@interface League : NSObject

NS_ASSUME_NONNULL_BEGIN

@property (nonatomic, strong) NSString * hid;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * shortName;
@property (nonatomic, strong) NSString * sport;
@property (readonly, nonatomic, strong) NSDictionary * teams;

NS_ASSUME_NONNULL_END

// this adds a team and makes the team know the league it belongs too
-(void)addTeam:(nonnull LeagueTeam *)team;

@end
