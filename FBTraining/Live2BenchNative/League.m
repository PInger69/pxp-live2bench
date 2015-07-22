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


@synthesize  hid   = _hid;
@synthesize  name  = _name;
@synthesize  shortName = _shortName;
@synthesize  sport = _sport;
@synthesize  teams = _teams;

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}






-(void)addTeam:(LeagueTeam *)team
{
    NSMutableDictionary * temp = [NSMutableDictionary dictionaryWithDictionary:_teams];
    team.league = self;
    [temp setObject:team forKey:team.name];
    _teams = [temp copy];
}


@end
