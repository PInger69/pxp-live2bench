//
//  ProfessionMap.m
//  Live2BenchNative
//
//  Created by dev on 2015-09-15.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "ProfessionMap.h"
#import "Tag.h"


@implementation ProfessionMap

static NSDictionary * _professionMapData;
+(void)initialize
{
    NSMutableDictionary  * dict = [NSMutableDictionary new];
    
     // Build Hockey
    Profession * hockey = [Profession new];
    hockey.filterPredicate  =  [NSCompoundPredicate orPredicateWithSubpredicates:@[[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeHockeyStartOLine]
                                                                                   ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeHockeyStopOLine]
                                                                                   ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeHockeyStartDLine]
                                                                                   ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeHockeyStopDLine]
                                                                                   ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeHockeyPeriodStart]
                                                                                   ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeHockeyPeriodStop]
                                                                                   ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeHockeyOppOLineStart]
                                                                                   ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeHockeyOppOLineStop]
                                                                                   ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeHockeyOppDLineStart]
                                                                                   ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeHockeyOppDLineStop]
                                                                                   ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeHockeyStrengthStart]
                                                                                   ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeHockeyStrengthStop]]];
    
    dict[SPORT_HOCKEY] =  hockey;
  

    _professionMapData = [dict copy];
    

}

+(NSDictionary*)data
{
    return _professionMapData;
}



@end


@implementation Profession

@end