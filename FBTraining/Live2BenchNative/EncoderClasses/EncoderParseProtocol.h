//
//  EncoderParseProtocol.h
//  Live2BenchNative
//
//  Created by dev on 2015-10-26.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Encoder;

@protocol EncoderParseProtocol <NSObject>


typedef NS_ENUM (NSInteger, ParseMode){

    ParseModeNone,
    
    // Master
    ParseModeStart,
    ParseModeStop,
    ParseModePause,
    ParseModeResume,

    ParseModeVersionCheck,
    ParseModeAuthentication,
    
    ParseModeGetTeams,
    ParseModeGetEventTags,
    ParseModeGetPastEvents,
    ParseModeDeleteEvent,
    ParseModeGetCameras,
    
    ParseModeTagSet,
    ParseModeTagMod,
    ParseModeTagMakeMP4,
    
    
    // Status monitor
    ParseModeSyncMe,
    ParseModeEncoderStatus
};



-(NSDictionary *)parse:(NSData*)data mode:(ParseMode)mode for:(Encoder*)encoder;

@end
