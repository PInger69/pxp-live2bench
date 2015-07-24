//
//  TeamPlayer.m
//  Live2BenchNative
//
//  Created by dev on 2015-07-22.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "TeamPlayer.h"
#import "LeagueTeam.h"
@implementation TeamPlayer

- (nonnull NSDictionary *)asDictionary
{
    NSDictionary * dict = @{
                            @"jersey"   : _jersey,
                            @"line"     : _line,
                            @"player"   : _player,
                            @"position" : _position,
                            @"role"     : _role,
                            @"team"     : (_team)?_team.hid:@""
                            };

    return dict;
}

@end
