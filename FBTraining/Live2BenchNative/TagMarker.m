//
//  TagMarker.m
//  Live2BenchNative
//
//  Created by dev on 13-01-25.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "TagMarker.h"

@implementation TagMarker

-(id)initWithXValue:(double)xVal tagColour:(UIColor*)color tagTime:(CGFloat)time tagId:(NSString*)tagID
{
    self = [super init];
    if (self)
    {
        self.color = color;
        self.tagTime = time;
        self.tagID = tagID;
        self.xValue = xVal;
        self.markerView = [[UIView alloc]init];
        
    }
    return self;
}

@end