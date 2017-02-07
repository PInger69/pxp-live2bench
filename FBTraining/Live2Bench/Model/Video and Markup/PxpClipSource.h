//
//  PxpClipSource.h
//  Live2Bench
//
//  This class models a clip's individual video source (e.g. a two-camera
//  set-up will have two sources: one for each camera).
//
//  Created by BC Holmes on 2017-02-07.
//  Copyright © 2017 Avoca. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PxpClipSource : NSObject

@property (nonatomic, readonly, nullable) NSURL* url;
@property (nonatomic, strong, nullable) NSString* path;
@property (nonatomic, strong, nullable) NSString* source;
@property (nonatomic, strong, nullable) NSString* proposedVideoName;

-(instancetype) initWithPath:(nonnull NSString*) path name:(nonnull NSString*) name sourceId:(nonnull NSString*) source;

@end
