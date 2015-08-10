//
//  PxpPlayerContext+Tag.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-10.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpPlayerContext+Tag.h"

@implementation PxpPlayerContext (Tag)

- (void)setTag:(nullable Tag *)tag {
    self.mainPlayer.tag = tag;
}

@end
