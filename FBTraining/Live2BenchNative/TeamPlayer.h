//
//  TeamPlayer.h
//  Live2BenchNative
//
//  Created by dev on 2015-07-22.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LeagueTeam;

@interface TeamPlayer : NSObject
@property (nonatomic,strong) NSString   * jersey;
@property (nonatomic,strong) NSString   * line;
@property (nonatomic,strong) NSString   * player;
@property (nonatomic,strong) NSString   * position;
@property (nonatomic,strong) NSString   * role;
@property (nonatomic,strong) LeagueTeam * team;


// This returns a primmative dict ready for json
-(NSDictionary*)asDictionary;

@end
