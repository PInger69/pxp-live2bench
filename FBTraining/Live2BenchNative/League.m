//
//  League.m
//  Live2BenchNative
//
//  Created by dev on 2015-07-22.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "League.h"
#import "LeagueTeam.h"
@implementation League
{
    __nonnull NSMutableDictionary *_teams;
}

@synthesize  teams = _teams;

- (nonnull instancetype)init
{
    self = [super init];
    if (self) {
        _hid = @"";
        _name = @"";
        _shortName = @"";
        _sport = @"";
        _teams = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void)addTeam:(LeagueTeam *)team
{
    if (team.league) {
        [team.league->_teams removeObjectForKey:team.name];
    }
    _teams[team.name] = team;
    team.league = self;
}
-(NSDictionary*)asDictionary
{
    NSDictionary * dict = @{
                            @"hid"      : _hid,
                            @"name"     : _name,
                            @"sport"    : _sport,
                            @"short"    : _shortName
                            };
    return dict;
}

@end
