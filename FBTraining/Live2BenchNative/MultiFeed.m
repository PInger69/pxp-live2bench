//
//  MultiFeed.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-07-20.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "MultiFeed.h"
#import "Feed.h"

@implementation MultiFeed

- (nonnull instancetype)init {
    self = [super init];
    if (self) {
        _feeds = [NSDictionary dictionary];
    }
    return self;
}

- (nonnull instancetype)initWithFeeds:(nonnull NSDictionary *)feeds {
    self = [super init];
    if (self) {
        NSMutableDictionary *temp = [NSMutableDictionary dictionary];
        for (NSString *k in feeds.keyEnumerator) {
            Feed *feed = feeds[k];
            
            // only add the items if they are feeds
            if ([k isKindOfClass:[NSString class]] && [feed isKindOfClass:[Feed class]]) {
                temp[k] = feed;
            }
        }
        _feeds = temp;
    }
    return self;
}

- (nonnull instancetype)initWithEvent:(nonnull Event *)event {
    return [self initWithFeeds:event.feeds];
}

- (nonnull instancetype)initWithClip:(nonnull Clip *)clip {
    self = [super init];
    if (self) {
        NSDictionary *paths = clip.videosBySrcKey;
        NSMutableDictionary *feeds = [NSMutableDictionary dictionary];
        for (NSString *k in paths.keyEnumerator) {
            NSString *path = paths[k];
            
            if ([k isKindOfClass:[NSString class]] && [path isKindOfClass:[NSString class]]) {
                feeds[k] = [[Feed alloc] initWithURLString:paths[k] quality:0];
            }
        }
        
        _feeds = feeds;
    }
    
    return self;
}

@end
