//
//  AdvancedFeed.h
//  Live2BenchNative
//
//  Created by dev on 2016-04-15.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeedProtocol.h"

@interface AdvancedFeed : NSObject <FeedProtocol>

@property (nonatomic,weak) CameraDetails * cameraDetails;

-(instancetype)initWithUrl:(NSString*)urlString;


#define mark - FeedProtocol
@property (nonatomic,assign) FeedStatus status;

-(NSString*)path;
-(NSString*)source;
-(NSString*)cameraID;
-(NSString*)cameraName;
-(float)offset;


@end
