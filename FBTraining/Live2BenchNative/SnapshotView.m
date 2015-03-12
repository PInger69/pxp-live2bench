//
//  SnapshotView.m
//  Live2BenchNative
//
//  Created by dev on 2014-05-15.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "SnapshotView.h"

@implementation SnapshotView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self = [aDecoder decodeObjectForKey:@"view"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:self forKey:@"view"];
}

@end
