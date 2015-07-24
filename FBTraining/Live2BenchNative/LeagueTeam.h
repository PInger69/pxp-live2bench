//
//  LeagueTeam.h
//  Live2BenchNative
//
//  Created by dev on 2015-07-22.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "League.h"
@class TeamPlayer;

NS_ASSUME_NONNULL_BEGIN

@interface LeagueTeam : NSObject
@property (nonatomic, strong) NSString       * extra;
@property (nonatomic, strong) NSString       * hid;
@property (nonatomic, strong) NSString       * name;
@property (nonatomic, strong) NSString       * sport;
@property (nonatomic, strong) NSString       * txt_name;
@property (nonatomic, weak)   League         * league;
@property (readonly, nonatomic,strong) NSDictionary   *players;

NS_ASSUME_NONNULL_END

- (void)addPlayer:(nonnull TeamPlayer *)player;
- (nonnull NSDictionary *)asDictionary;

@end
