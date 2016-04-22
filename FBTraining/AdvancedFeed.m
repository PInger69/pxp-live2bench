//
//  AdvancedFeed.m
//  Live2BenchNative
//
//  Created by dev on 2016-04-15.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "AdvancedFeed.h"
#import "CameraDetails.h"

@interface AdvancedFeed ()

@property (nonatomic,strong) NSURL * _URLPath;


@end


@implementation AdvancedFeed


-(instancetype)initWithUrl:(NSString*)urlString
{

    self = [super init];
    if (self) {
        if ([urlString rangeOfString:@"http:"].location == NSNotFound) {
            self._URLPath = [NSURL fileURLWithPath: urlString];
        } else {
            self._URLPath = [NSURL URLWithString:   urlString];
        }
    }
    return self;

}

#define mark - FeedProtocol

-(NSString*)path
{
    return [self._URLPath absoluteString];
}

-(NSString*)source
{
    return nil;
}

-(NSString*)cameraID
{
    return self.cameraDetails.cameraID;
}

-(NSString*)cameraName
{
    return self.cameraDetails.name;
}

-(float)offset
{
    return 0.0;
}



@end
