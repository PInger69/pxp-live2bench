//
//  CameraResource.h
//  Live2BenchNative
//
//  Created by dev on 2016-04-20.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Encoder;
@class CameraDetails;
@class Event;
@class Feed;

@interface CameraResource : NSObject

@property (nonatomic,strong) NSMutableArray * cameraDataPool;

- (instancetype)initEncoder:(Encoder*)encoder;
-(void)addCameraDetails:(CameraDetails*)cameraDetails;
-(Feed*)getFeedByLocation:(NSString*)cameraLocation event:(Event*)event;

-(NSString*)getCameraNameBy:(NSString*)cameraLocation;
-(BOOL)allCamerasHaveMatchingFormats;
@end
