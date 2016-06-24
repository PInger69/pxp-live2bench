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
#import "FeedMapController.h"
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
         NSLog(@"CamName: %@  %@ camID %@",cd.name,cd.cameraID,camID);
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
    
    if (selectedFeed == nil) {
        NSDictionary * sourceAlt = @{kQuad1of4:@"s_00",
                                     kQuad2of4:@"s_01",
                                     kQuad3of4:@"s_02",
                                     kQuad4of4:@"s_03"};
    
        
        NSString * sKey =[sourceAlt objectForKey:cameraLocation];
        selectedFeed = [event.feeds objectForKey:sKey];
    }
    
    
    
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

-(BOOL)allCamerasHaveMatchingFormats
{
    if ([self.cameraDataPool count]== 0) return YES;
    
    CameraDetails* camData =[self.cameraDataPool firstObject];
    NSString * format = camData.resolution;
    
    for (CameraDetails* c in self.cameraDataPool) {
        if (![c.resolution isEqualToString:format]) return NO;
    }
    

    return YES;
}


@end
