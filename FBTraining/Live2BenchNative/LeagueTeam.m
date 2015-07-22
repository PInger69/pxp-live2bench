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

@synthesize extra = _extra;
@synthesize hid = _hid;
@synthesize name = _name;
@synthesize sport = _sport;
@synthesize txt_name = _txt_name;
@synthesize league = _league;
@synthesize players = _players;

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(void)addPlayer:(TeamPlayer*)player
{

    NSMutableDictionary * temp = [NSMutableDictionary dictionaryWithDictionary:_players];
    player.team = self;
    [temp setObject:player forKey:player.jersey];
    _players = [temp copy];



}

-(NSDictionary*)asDictionary
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

@end
