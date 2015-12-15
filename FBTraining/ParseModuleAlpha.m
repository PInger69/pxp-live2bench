//
//  ParseModuleAlpha.m
//  Live2BenchNative
//
//  Created by dev on 2015-11-04.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "ParseModuleAlpha.h"

@implementation ParseModuleAlpha










// ParseModeGetPastEvents and Find Live Event
-(void)getPastEvents:(NSDictionary*)dict encoder:(Encoder*)encoder
{
    
    NSArray                 * events   = [dict objectForKey:@"events"];
    NSMutableDictionary     * pool     = [[NSMutableDictionary alloc]init];
    
    @try {
        NSEnumerator *enumerator = [events objectEnumerator];
        id value;
        
        while ((value = [enumerator nextObject])) {
            
            
            // This will remove an event it its marked as deleted and also not build deleted events as well
            if ([[value objectForKey:@"deleted"] intValue] == 1) {
                [encoder.allEvents removeObjectForKey:value[@"name"]];
                continue;
            }
            
            // make event with the data
            // The event class parses based of the data from the encoder and encoder version
            Event * anEvent             = [[Event alloc]initWithDict:(NSDictionary *)value isLocal:NO andlocalPath:nil];
            anEvent.parentEncoder       = encoder;
            
            // populating teams based off data
            League      * league        = [encoder.encoderLeagues objectForKey:value[@"league"]];
            LeagueTeam  * homeTeam      = [league.teams objectForKey:value[@"homeTeam"]]  ? [league.teams objectForKey:value[@"homeTeam"]]  :[LeagueTeam new];
            LeagueTeam  * visitTeam     = [league.teams objectForKey:value[@"visitTeam"]] ? [league.teams objectForKey:value[@"visitTeam"]] :[LeagueTeam new];
            
            anEvent.teams               = @{@"homeTeam":homeTeam,@"visitTeam":visitTeam};
            
            
            if (anEvent.live){ // live event FOUND!
                
                encoder.liveEvent       = anEvent; // add Event to the encoder
                
                if ([encoder.allEvents objectForKey:anEvent.name]){
                    NSLog(@" *** Live event is already on encoder %@",anEvent.name);
                } else {
                    [pool setObject:anEvent forKey:anEvent.name];
                    [pool setObject:anEvent forKey:LIVE_EVENT];
                    
                    NSMutableDictionary *eventFinal = [[NSMutableDictionary alloc]initWithDictionary:@{@"non-local":anEvent}];
                    [encoder.allEvents setObject:eventFinal forKey:anEvent.name];
                    [encoder.allEvents setObject:eventFinal forKey:LIVE_EVENT];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_LIVE_EVENT_FOUND object:self];
                    });
                }
            }else if (![encoder.allEvents objectForKey:anEvent.name]) {
                [pool setObject:anEvent forKey:anEvent.name];
            }
            
            
        }
    }
    @catch (NSException *exception) {
        PXPLog(@"error parsing json data: %@",exception);
    }
    @finally {
        
    }
    
    
    // linking local to externel events
    for(Event *encoderEvent in [pool allValues]) {
        Event *localEvent = [[LocalMediaManager getInstance] getEventByName:encoderEvent.name];
        if (localEvent) {
            NSMutableDictionary *eventFinal = [[NSMutableDictionary alloc]initWithDictionary:@{@"local":localEvent,@"non-local":encoderEvent}];
            [encoder.allEvents setObject:eventFinal forKey:encoderEvent.name];
        }else{
            NSMutableDictionary *eventFinal = [[NSMutableDictionary alloc]initWithDictionary:@{@"non-local":encoderEvent}];
            [encoder.allEvents setObject:eventFinal forKey:encoderEvent.name];
        }
    }
    
    
    
}







-(void)encoderStatus:(NSDictionary*)dict encoder:(Encoder*)encoder
{
    EncoderStatus  statusCode  = [[dict objectForKey:@"code"]integerValue];
    [encoder encoderStatusStringChange:dict];
    [encoder encoderStatusChange:statusCode];
    [encoder onMotionAlarm:dict];
}












@end
