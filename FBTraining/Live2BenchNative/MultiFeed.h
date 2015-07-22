//
//  MultiFeed.h
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-07-20.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"
#import "Clip.h"

@interface MultiFeed : NSObject

@property (strong, nonatomic, nonnull) NSDictionary *feeds;

- (nonnull instancetype)initWithFeeds:(nonnull NSDictionary *)feeds;
- (nonnull instancetype)initWithEvent:(nonnull Event *)event;
- (nonnull instancetype)initWithClip:(nonnull Clip *)clip;

@end
