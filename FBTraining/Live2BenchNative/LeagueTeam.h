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

@interface LeagueTeam : NSObject
@property (nonatomic,strong) NSString       * extra;
@property (nonatomic,strong) NSString       * hid;
@property (nonatomic,strong) NSString       * name;
@property (nonatomic,strong) NSString       * sport;
@property (nonatomic,strong) NSString       * txt_name;
@property (nonatomic,weak)   League         * league;
@property (nonatomic,strong) NSDictionary   * players;



-(void)addPlayer:(TeamPlayer*)player;
-(NSDictionary*)asDictionary;
@end
