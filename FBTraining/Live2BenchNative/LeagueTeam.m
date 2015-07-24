//
//  LeagueTeam.m
//  Live2BenchNative
//
//  Created by dev on 2015-07-22.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "LeagueTeam.h"
#import "TeamPlayer.h"

@implementation LeagueTeam
{
    __nonnull NSMutableDictionary *_players;
}

@synthesize players = _players;

- (nonnull instancetype)init
{
    self = [super init];
    if (self) {
        _extra = @"";
        _name = @"";
        _sport = @"";
        _txt_name = @"";
        _league = nil;
        _players = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addPlayer:(nonnull TeamPlayer *)player
{
    if (player.team) {
        [player.team->_players removeObjectForKey:player.jersey];
    }
    
    _players[player.jersey] = player;
    player.team = self;
}

- (nonnull NSDictionary *)asDictionary
{
    NSDictionary * dict = @{
                            @"extra"    : _extra,
                            @"hid"      : _hid,
                            @"league"   : (_league)?_league.hid:@"",
                            @"name"     : _name,
                            @"sport"    : _sport,
                            @"txt_name" : _txt_name
                            };
    return dict;
}

-(NSInteger)playerCount
{
    return [[_players allValues] count];
}


@end
