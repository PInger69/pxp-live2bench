//
//  CameraResource.m
//  Live2BenchNative
//
//  Created by dev on 2016-04-20.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "CameraResource.h"
#import "Encoder.h"
#import "CameraDetails.h"
#import "Feed.h"

#import "Event.h"
@interface CameraResource ()


@property (nonatomic,strong) Encoder * encoder;

@end
@implementation CameraResource



- (instancetype)initEncoder:(Encoder*)encoder
{
    self = [super init];
    if (self) {
        self.cameraDataPool = [NSMutableArray new];
        
        self.encoder = encoder;
    }
    return self;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
                self.cameraDataPool = [NSMutableArray new];
    }
    return self;
}

-(void)addCameraDetails:(CameraDetails*)cameraDetails
{
    [self.cameraDataPool addObject:cameraDetails];
}


-(Feed*)getFeedByLocation:(NSString*)cameraLocation event:(Event*)event
{
    
    
    // this get the camera based of a location
    NSString * camID = [[UserCenter getInstance]getPickByCameraLocation:cameraLocation];
    
    CameraDetails* pickCam;
    for (CameraDetails* cd in self.cameraDataPool) {
        if ([cd.cameraID isEqualToString:camID]) {
            pickCam = cd;
            NSLog(@"CamName: %@  %@ camID %@",cd.name,cd.cameraID,camID);
            NSLog(@" ");
            break;
        }
    }
 
    NSString * sourceKey = pickCam.source;
    
    Feed* selectedFeed = [event.feeds objectForKey:sourceKey];
    
    //    self.encoder.cameraData
    NSLog(@"%@",selectedFeed.sourceName);
    return selectedFeed;
}







-(NSString*)getCameraNameBy:(NSString*)cameraLocation
{
    NSString * camID = [[UserCenter getInstance]getPickByCameraLocation:cameraLocation];
    
    CameraDetails* pickCam;
    for (CameraDetails* cd in self.cameraDataPool) {
        if ([cd.cameraID isEqualToString:camID]) {
            pickCam = cd;
            break;
        }
    }
    
    
    NSString * camname = [[[UserCenter getInstance]namedCamerasByUser] objectForKey:pickCam.name];


    return (camname)?camname:pickCam.cameraID;
}


@end
