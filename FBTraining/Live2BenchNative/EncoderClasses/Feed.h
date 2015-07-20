//
//  Feed.h
//  Live2BenchNative
//
//  Created by dev on 2014-11-18.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#define FEED_TYPE_LOCAL     @"local"
#define FEED_TYPE_LIVE      @"live"
#define FEED_TYPE_ENCODER   @"encoder"


typedef NS_OPTIONS (NSInteger,FeedModes){
    
    FeedModesReady,
    FeedModesNotFound,
    FeedModesCorrupt,
    FeedModesInProcess
};

@interface Feed : NSObject

NS_ASSUME_NONNULL_BEGIN

@property (nonatomic, assign)            int            quality;
@property (nonatomic, assign,readonly)   BOOL           hasHighQuality;
@property (nonatomic, assign,readonly)   BOOL           hasLowQuality;
@property (nonatomic, strong)            NSString       * sourceName;   // raw source name
@property (nonatomic,assign)             BOOL           isAlive;        // for observering
@property (nonatomic, strong)            NSDictionary   * info;         // any extra data that needs to be associated with the feed e.g. tag plist
@property (nonatomic, strong)            NSArray        *allPaths;
@property (nonatomic, strong)           NSString       * type;
@property (nonatomic,assign)             FeedModes      mode;

@property (readonly, strong, nonatomic, nonnull) NSDictionary *assets;
@property (readonly, strong, nonatomic, nullable) AVAsset *lqAsset;
@property (readonly, strong, nonatomic, nullable) AVAsset *hqAsset;
@property (readonly, strong, nonatomic, nullable) AVAsset *anyAsset;

NS_ASSUME_NONNULL_END


-(nonnull instancetype)initWithURLDict:(nonnull NSDictionary *)aDict;
-(nonnull instancetype)initWithURLString:(nonnull NSString *)aPath quality:(int)qlty;
-(nonnull instancetype) initWithFileURL: (nonnull NSString *) fileURL;
-(nullable NSURL *)path;



@end
