//
//  FeedProtocol.h
//  Live2BenchNative
//
//  Created by dev on 2016-04-15.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CameraDetails;

typedef NS_OPTIONS (NSInteger,FeedStatus){
    
    FeedStatusReady,
    FFeedStatusNotFound,
    FeedStatusCorrupt,
    FeedStatusInProcess
};


@protocol FeedProtocol <NSObject>

@property (nonatomic,assign) FeedStatus status;



-(NSString*)path;
-(NSString*)source;
-(NSString*)cameraID;
-(NSString*)cameraName;
-(float)offset;




@end
