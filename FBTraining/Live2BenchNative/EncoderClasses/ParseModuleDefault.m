//
//  ParseModuleDefault.m
//  Live2BenchNative
//
//  Created by dev on 2015-10-26.
//  Copyright © 2015 DEV. All rights reserved.
//


// The pourpose of the class is to act as a JSON Parsing Interface
// for each version of encoder
// This takes the JSON from the server a converts the data and applys it to the Encoder e.g. Event Classes and Tag Classes


/// This is for encoder version 0.94.5


#import "ParseModuleDefault.h"

@implementation ParseModuleDefault




// This is the very first  conversion and check of the jason
-(NSDictionary *)jsonToDict:(NSData *)data
{
//    NSError *error = nil;
    NSDictionary    * results =[Utility JSONDatatoDict:data];
    if (results[@"success"] && [results[@"success"]intValue] == 0) {
        PXPLog(@"Encoder Error! - JSON returned from server but success was 0");
        PXPLog(@"  reason: %@",results[@"msg"]);
    }
    return results;
}



// no parse for getCam
-(NSDictionary *)parse:(NSData*)data mode:(ParseMode)mode for:(Encoder*)encoder
{
    NSDictionary * parsedData   = [self jsonToDict:data];

    switch (mode) {
        case ParseModeVersionCheck:
            [self versionCheck:parsedData encoder:encoder];
            break;
            
        case ParseModeAuthentication:
            [self authenticate:parsedData encoder:encoder];
            break;
          
        case ParseModeGetPastEvents:
            [self getPastEvents:parsedData encoder:encoder];
            break;
            
        case ParseModeGetTeams:
            [self getPastEvents:parsedData encoder:encoder];
            break;
        case ParseModeGetEventTags:
            [self getPastEvents:parsedData encoder:encoder];
            break;
            
            
        case ParseModeStart:
            [self start:parsedData encoder:encoder];
            break;
        case ParseModeStop:
            [self stop:parsedData encoder:encoder];
            break;
        case ParseModePause:
            [self pause:parsedData encoder:encoder];
            break;
        case ParseModeResume:
            [self resume:parsedData encoder:encoder];
            break;
            
        case ParseModeDeleteEvent:
            [self deleteEvent:parsedData encoder:encoder];
            break;
        case ParseModeGetCameras:
            [self resume:parsedData encoder:encoder];
            break;
            
            
            
        // Tag
        case ParseModeTagSet:
            [self makeTag:parsedData encoder:encoder];
            break;
            
        case ParseModeTagMod:
            [self modTag:parsedData encoder:encoder];
            break;
        case ParseModeTagMakeMP4:
            [self modTagMakeMP4:parsedData encoder:encoder];
            break;
            
        default:
            break;
    }

    return parsedData;
}





#pragma mark - Master Responce

-(void)stop:(NSDictionary*)dict encoder:(Encoder*)encoder
{
    PXPLog(@"!!!Event Stopped on %@",encoder.name);
}

-(void)start:(NSDictionary*)dict encoder:(Encoder*)encoder
{
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_LIVE_EVENT_STARTED object:self];
    PXPLog(@"!!!Event Started on %@",encoder.name);
}

-(void)pause:(NSDictionary*)dict encoder:(Encoder*)encoder
{
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_LIVE_EVENT_PAUSED object:self];
    PXPLog(@"!!!Event Paused on %@",encoder.name);
}

-(void)resume:(NSDictionary*)dict encoder:(Encoder*)encoder
{
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_LIVE_EVENT_RESUMED object:self];
    PXPLog(@"!!!Event Resumed on %@",encoder.name);
}






// ParseModeVersionCheck
-(void)versionCheck:(NSDictionary*)dict encoder:(Encoder*)encoder
{
    encoder.version = (NSString *)[dict objectForKey:@"version"] ;
//    PXPLog(@"%@ is version %@",encoder.name ,encoder.version);
}


-(void)authenticate:(NSDictionary*)dict encoder:(Encoder*)encoder
{
   
    encoder.authenticated =  YES;
    PXPLog(@"Warning: define no authenticating");
    return;
 
    // It was noted that authentications the error out and also authenticated

    if (!dict) { // error in parsing?
        encoder.authenticated =  YES;
        return;
    }
    
    
    encoder.authenticated = [[dict objectForKey:@"success"] boolValue];
    
    if (!encoder.authenticated){
        PXPLog(@"");
        PXPLog(LOG_HASH);
        PXPLog(@"Warning: User Failed to authenticate to Encoder %@",encoder.name);
        PXPLog(@"  ID:     @%",[UserCenter getInstance].customerID);
        PXPLog(@"  E-mail: @%",[UserCenter getInstance].customerEmail);
        PXPLog(LOG_HASH);
        PXPLog(@"");
    }
    
 
}








// this build the Leagus, teams and players on this encoder
-(void)getTeams:(NSDictionary*)dict encoder:(Encoder*)encoder
{
    if (encoder.encoderLeagues) {
        return;
    }

    NSMutableDictionary * leaguePool        = [[NSMutableDictionary alloc]init]; // this is the final
    NSMutableDictionary * leagueTempHIDPool = [[NSMutableDictionary alloc]init];
    NSArray * rawleagues = [[dict objectForKey:@"leagues"]allValues];
    
    for (NSDictionary * lData in rawleagues) {
        League * aLeague    = [[League alloc]init];
        aLeague.hid         = lData[@"hid"];
        aLeague.name        = lData[@"name"];
        aLeague.shortName   = lData[@"short"];
        aLeague.sport       = lData[@"sport"];
        
        if ([leaguePool objectForKey:aLeague.name]){
            aLeague.name = [NSString stringWithFormat:@"%@ (Duplicate)",aLeague.name];
        }
        [leaguePool setObject:aLeague forKey:aLeague.name];
        
        [leagueTempHIDPool setObject:aLeague forKey:aLeague.hid];
    }
    

    NSMutableDictionary * teamTempHIDPool   = [[NSMutableDictionary alloc]init];
    NSArray             * rawTeams          = [[dict objectForKey:@"teams"]allValues];
    
    for (NSDictionary * tData in rawTeams) {
        LeagueTeam  * lTeam = [[LeagueTeam alloc]init];
        NSString    * lHID  = tData[@"league"];
        lTeam.extra         = tData[@"extra"];
        lTeam.hid           = tData[@"hid"];
        lTeam.name          = tData[@"name"];
        lTeam.sport         = tData[@"sport"];
        lTeam.txt_name      = tData[@"txt_name"];
        
        if ([lTeam.name isEqualToString: @"Bayonne"]){
            
        }
        League * owningLeague = (League *)[leagueTempHIDPool objectForKey:lHID];
        if (!owningLeague) {
            owningLeague = [[League alloc]init];
            owningLeague.name  = @"Teams Has No League...";
            owningLeague.hid   = lHID;
            owningLeague.sport = lTeam.sport;
        }
        
        [owningLeague addTeam:lTeam];
        [teamTempHIDPool setObject:lTeam forKey:lTeam.hid];
    }
    
    NSArray  * rawTeamSetup = [[dict objectForKey:@"teamsetup"]allValues];
    NSInteger playerCount   = 0;
    for (NSArray * pList in rawTeamSetup) {
        // each item in the Array should all be the same team
        NSString    * tHID      = pList[0][@"team"];
        LeagueTeam * owningTeam = (LeagueTeam *)[teamTempHIDPool objectForKey:tHID];
        
        for (NSDictionary * pData in pList) {
            playerCount++;
            TeamPlayer * aPlayer    = [[TeamPlayer alloc]init];
            aPlayer.jersey          = [pData[@"jersey"]stringValue];
            aPlayer.line = [pData objectForKey:@"line"];
            aPlayer.line            = pData[@"line"];
            aPlayer.player          = pData[@"player"];
            aPlayer.position        = pData[@"position"];
            aPlayer.role            = pData[@"role"];
            
            tHID      = pData[@"team"];

            owningTeam = (LeagueTeam *)[teamTempHIDPool objectForKey:tHID];
            if (!owningTeam)  {
                
                owningTeam =  [[LeagueTeam alloc]init];
                owningTeam.name = @"NO NAME BRAND";
                owningTeam.hid  = tHID;
                owningTeam.extra         = @"";
                owningTeam.sport         = @"Reading";
                owningTeam.txt_name      = @"NO_NAME_BRAND";
                
                //                [teamTempHIDPool setObject:owningTeam forKey:tHID];
                //                NSLog(@"Player does not have a team, Making a new one");
                NSLog(@"Player does not have a team %@",tHID);
            }
            [owningTeam addPlayer:aPlayer];
            
            
        }
        //           NSLog(@"%@ \tTeams have %lu players",owningTeam.name,(unsigned long)[owningTeam.players count]);
    }

    encoder.encoderLeagues = [leaguePool copy];
}











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


-(void)deleteEvent:(NSDictionary*)dict encoder:(Encoder*)encoder
{
    if (dict){
        PXPLog(@"The event has been deleted %@" , dict);
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_DELETE_EVENT_COMPLETE object:self];
}


// This method is incomplete so the it only list cam count and raw data
-(void)getCameras:(NSDictionary*)dict encoder:(Encoder*)encoder
{
    NSArray * list      = [dict[@"camlist"]allValues];
    encoder.cameraCount = list.count;
    encoder.cameraData  = dict;
    PXPLog(@"%@ has %@ cameras",encoder.name ,[NSString stringWithFormat:@"%ld",(long)encoder.cameraCount ]);

//    NSMutableArray *camerasAvailableList = [[NSMutableArray alloc]init];
//    
//    
//    for (NSDictionary *dic in list) {
//        // if ([dic[@"cameraPresent"]boolValue])_cameraCount++;
//        
////        [camerasAvailableList addObject:[[CameraDetails alloc]initWithDictionary:dic encoderOwner:self]];
//        
//    }
    //   _cameraCount = [((NSDictionary*)[results objectForKey:@"camlist"]) count];

}


-(void)makeTag:(NSDictionary*)dict encoder:(Encoder*)encoder
{

}

-(void)modTag:(NSDictionary*)dict encoder:(Encoder*)encoder
{

}

-(void)modTagMakeMP4:(NSDictionary*)dict encoder:(Encoder*)encoder
{

}




-(void)encoderStatus:(NSDictionary*)dict encoder:(Encoder*)encoder
{

    NSString        * legacyStatus = [dict objectForKey:@"status"];
    EncoderStatus   statusCode;
    
    if ([legacyStatus isEqualToString:@"Event is being stopped"]) {
        statusCode = ENCODER_STATUS_STOP;
    } else if ([legacyStatus isEqualToString:@"paused"]) {
        statusCode = ENCODER_STATUS_PAUSED;
    } else if ([legacyStatus isEqualToString:@"stopped"]) {
        statusCode = ENCODER_STATUS_READY;
    } else if ([legacyStatus isEqualToString:@"live"]) {
        statusCode = ENCODER_STATUS_LIVE;
    } else if ([legacyStatus isEqualToString:@"pro recoder disconnected"]) {
        statusCode = ENCODER_STATUS_NOCAM;
    } else if ([legacyStatus isEqualToString:@"camera disconnected"]) {
        statusCode = ENCODER_STATUS_NOCAM;
    } else if ([legacyStatus isEqualToString:@"streaming app is starting"]) {
        statusCode = ENCODER_STATUS_CAM_LOADING;
    } else if ([legacyStatus isEqualToString:@"preparing to stream"]) {
        statusCode = ENCODER_STATUS_START;
    } else {
        statusCode = ENCODER_STATUS_UNKNOWN;
    }
    
    [encoder assignMaster:dict extraData:YES];
    [encoder encoderStatusStringChange:dict];
    [encoder encoderStatusChange:statusCode];
    [encoder onMotionAlarm:dict];
}



@end
