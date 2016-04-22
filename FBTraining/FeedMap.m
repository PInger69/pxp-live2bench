//
//  FeedMap.m
//  Live2BenchNative
//
//  Created by dev on 2016-04-01.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "FeedMap.h"


@interface FeedMap ()

@property (nonatomic,strong) NSMutableDictionary * _feedDict;

@end

@implementation FeedMap


- (instancetype)init
{
    self = [super init];
    if (self) {
        self._feedDict = [NSMutableDictionary new];
    }
    return self;
}



- (instancetype)initWithDict:(NSDictionary*)plistDict
{
    self = [super init];
    if (self) {
        self._feedDict = [plistDict mutableCopy];
    }
    return self;
}

// SourceName, the user inputted name and the location where the video is recomended to play
-(void)addSourceKey:(NSString*)srcKey name:(NSString*)name position:(NSString*)position
{

}


-(NSDictionary*)rawData
{
    return [self._feedDict copy];
}

@end
