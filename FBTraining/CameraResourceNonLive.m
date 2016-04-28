//
//  CameraResourceNonLive.m
//  Live2BenchNative
//
//  Created by dev on 2016-04-28.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "CameraResourceNonLive.h"
#import "CameraDetails.h"
#import "FeedMapController.h"
#import "Feed.h"
@implementation CameraResourceNonLive


- (instancetype)initWithFeeds:(NSArray*)feeds
{
    self = [super init];
    if (self) {
        
        
        
        self.cameraDataPool = [NSMutableArray new];
        
        
        
        NSArray* locationList = @[kQuad1of4,        kQuad2of4,        kQuad3of4,        kQuad4of4];
        
        
        for (NSInteger i=0; i <[feeds count]; i++) {
            
            Feed * aFeed = feeds[i];
            if (!aFeed.sourceName) aFeed.sourceName = @"onlySource";
            NSDictionary * dict = @{
                                    @"type" 	: @"???",
                                    @"fps" 	:     @0 ,
                                    @"sidx" 	: aFeed.sourceName,
                                    @"mac" 	:     [NSString stringWithFormat:@"%@-%@",locationList[i],aFeed.sourceName],
                                    @"ip" 	:     locationList[i],
                                    @"name" 	: locationList[i],
                                    @"url" 	:     @""
                                    
                                    
                                    
                                    };
            
            CameraDetails * camDetails = [[CameraDetails alloc]initWithDictionary:dict encoderOwner:nil];
            [self addCameraDetails:camDetails];
        }
        
        
        
        
        
    }
    return self;
}




-(void)addCameraDetails:(CameraDetails*)cameraDetails
{
    [self.cameraDataPool addObject:cameraDetails];
}


-(Feed*)getFeedByLocation:(NSString*)cameraLocation event:(Event*)event;
{
    NSDictionary * feeds = [event.feeds copy];
    for (CameraDetails* cd in self.cameraDataPool) {
        if ([cd.name isEqualToString:cameraLocation]) {
            return feeds[cd.source];
        }
    }
    return nil;
}

-(NSString*)getCameraNameBy:(NSString*)cameraLocation
{
    
    CameraDetails* pickCam;
    for (CameraDetails* cd in self.cameraDataPool) {
        if ([cd.cameraID isEqualToString:cameraLocation]) {
            return pickCam.name;
            
        }
    }
    return nil;
}

@end
