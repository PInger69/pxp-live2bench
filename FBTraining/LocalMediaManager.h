//
//  LocalMediaManager.h
//  Live2BenchNative
//
//  Created by dev on 2015-06-30.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"
#import "Clip.h"
#import "Tag.h"

@interface LocalMediaManager : NSObject

@property (nonatomic,strong)    NSString                * name;
@property (nonatomic, strong)   NSString                *localPath;
@property (nonatomic,strong)    NSMutableDictionary            * allEvents;
@property (nonatomic,strong)    NSMutableDictionary * clips;    // This is all feeds kept on the device  key:<id> value:<Clip>

+(instancetype)getInstance;
-(id)initWithDocsPath:(NSString*)aDocsPath;
-(void)deleteEvent:(Event*)aEvent;
-(NSString*)saveEvent:(NSMutableDictionary*)eventDic;
-(NSString*)bookmarkedVideosPath;
-(void)saveClip:(NSString*)aName withData:(NSDictionary *)tagData;
-(Event*)getEventByName:(NSString*)eventName;
-(void)assignEncoderVersionEvent:(NSDictionary *)allEvent;
-(Clip*)getClipByTag:(Tag*)tag scrKey:(NSString*)scrKey;
-(void)breakTagLink:(Clip*)aClip;
@end
