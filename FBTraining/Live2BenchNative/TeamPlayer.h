//
//  TeamPlayer.h
//  Live2BenchNative
//
//  Created by dev on 2015-07-22.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LeagueTeam;

NS_ASSUME_NONNULL_BEGIN

@interface TeamPlayer : NSObject
@property (nonatomic,strong) NSString   * jersey;
@property (nonatomic,strong) NSString   * line;
@property (nonatomic,strong) NSString   * player;
@property (nonatomic,strong) NSString   * position;
@property (nonatomic,strong) NSString   * role;
@property (nonatomic,weak)   LeagueTeam * team;

NS_ASSUME_NONNULL_END

// This returns a primmative dict ready for json
- (nonnull NSDictionary *)asDictionary;

@end
