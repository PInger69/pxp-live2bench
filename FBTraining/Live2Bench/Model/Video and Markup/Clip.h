//
//  Clip.h
//  Live2BenchNative
//
//  Created by dev on 2015-04-09.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FilterItemProtocol.h"
#import "Tag.h"
#import "PxpClipSource.h"

/**
 Its kinda like the Event Class but is used to only manage the sources for local content
 */

@interface Clip : Tag<FilterItemProtocol>

@property (nonatomic,strong)            NSString       * clipId;
@property (nonatomic,strong)            NSMutableDictionary   * localRawData;
@property (nonatomic,strong)            NSString       * path;
@property (nonatomic, readonly)         NSArray        * videoFiles;
@property (nonatomic, readonly)         NSArray* clipSources;
@property (nonatomic, strong)           NSMutableDictionary        * videosBySrcKey;

@property (strong, nonatomic) NSString *eventName;
@property (readonly, nonatomic) NSString *globalID;


/**
 *  This is used to make a new Clip from a non existing Plist
 *
 *  @param aPath path of the new plist
 *  @param data build the Clip
 *  @return data build the Clip
 */
-(instancetype)initWithPlistPath:(NSString*)aPath data:(NSDictionary*)data;

/**
 *  There was already a plist on the device and ist just needs to be init
 *
 *  @param data build the Clip
 *
 *  @return an instance of a Clip
 */
-(instancetype)initWithDict:(NSDictionary*)data;


/**
 *  Will modify the clip and save the plist
 *
 *  @param aDict eg @{KeyIsPropToChange:value}
 */
-(void)modClipData:(NSDictionary*)aDict;

/**
 *  Add another source to the Clip
 *
 *  @param aDict - the dictionary values of a source
 */
-(void)addSourceToClip:(NSDictionary*)aDict DEPRECATED_MSG_ATTRIBUTE("Use addSource:videoName: instead.");

-(void) addSource:(NSString*) source videoName:(NSString*) videoName;

/**
 *  This method mods the clip GlobalID so that its no longer connected to live event
 */
-(void)breakClipId;

/**
 *  Deletes all mp4s and selfPlist
 */
-(void)destroy;

/**
 *  Access an object that encapsulates various attributes of an
 *  individual video source.
 *
 *  @return the clip source
 */
-(PxpClipSource*) sourceForKey:(NSString*) source;


@end


// example clip data
//{
//    colour = ff0101;
//    comment = "";
//    deleted = 0;
//    deviceid = "D207EE3F-BDD1-4A40-82D3-07E0A86999EE";
//    displaytime = "0:00:00";
//    duration = 10;
//    event = "2015-04-10_17-26-45_bee18c98b33cca33d26cba46e24cf15b23b4b072_local";
//    homeTeam = "AFC Wimbledon";
//    id = 11;
//    islive = 1;
//    name = "COACH%20CALL";
//    own = 1;
//    rating = "";
//    starttime = 0;
//    success = 1;
//    "telefull_2" =     {
//    };
//    "teleurl_2" =     {
//    };
//    time = "0.01";
//    type = 0;
//    url = "http://192.168.1.111/events/live/thumbs/00hq_tn11.jpg";
//    "url_2" =     {
//        "s_00" = "http://192.168.1.111/events/live/thumbs/00hq_tn11.jpg";
//        "s_02" = "http://192.168.1.111/events/live/thumbs/02hq_tn11.jpg";
//        "s_03" = "http://192.168.1.111/events/live/thumbs/03hq_tn11.jpg";
//    };
//    user = b7103ca278a75cad8f7d065acda0c2e80da0b7dc;
//    "vidurl_2" =     {
//    };
//    visitTeam = "Accrington Stanley";
//}


