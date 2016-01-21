//
//  Feed.m
//  Live2BenchNative
//
//  Created by dev on 2014-11-18.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "Feed.h"
#define LOW_QUALITY     @"lq"
#define HIGH_QUALITY    @"hq"

@implementation Feed
{

    NSDictionary    * _qualities;
    NSURL           * _urlPath;
    NSMutableDictionary *_assets;
}


@synthesize quality     = _quality;
@synthesize sourceName  =_sourceName;
@synthesize type;
@synthesize isAlive;
@synthesize info;
@synthesize mode        = _mode;

@synthesize assets = _assets;

/**
 *  this is to be used right from the JSON data
 *
 *  @param aDict @"lq":<URL> ,@"hq":<URL>
 *
 *  @return instance
 */
-(id)initWithURLDict:(NSDictionary *)aDict
{
    self = [super init];
    if (self) {
        self.isAlive                        = YES;
        NSArray             * keys          = [aDict allKeys];
        NSMutableDictionary * tempDict      = [[NSMutableDictionary alloc]init];
        NSURL               * defaultURL;
        
        _assetsReady = NO;
        _assets = [NSMutableDictionary dictionary];
        for (NSString * k in keys)
        {
            if ([k isEqualToString:@"hq"] || [k isEqualToString:@"lq"]) {
                NSURL *url = [NSURL URLWithString:aDict[k]];
                
                if (url) {
                    tempDict[k] = url;
                    
                    _assets[k] = [AVURLAsset URLAssetWithURL:url options:nil];
                    
                    // Richard
//                    NSArray *requestedKeys = @[@"playable"];
//                    [_assets[k] loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:^{
//                        
//                    }];
                    // End Richard
                    
                    if (defaultURL == nil) {
                        defaultURL = [tempDict objectForKey:[k lowercaseString]];
                    } else if ([[k lowercaseString] isEqualToString:LOW_QUALITY]) {   // The default is LOW_QUALITY
                        defaultURL = [tempDict objectForKey:[k lowercaseString]];
                    }
                }
            }
        }
        _qualities = [tempDict copy];
        _urlPath = [defaultURL copy];
        self.type =FEED_TYPE_ENCODER;           
    }
    return self;
}


// Is this an issue
-(id)initWithURLString:(NSString *)aPath quality:(int)qlty
{
    self = [super init];
    if (self) {
        
        self.isAlive = YES;
        NSString * correctedQuality;
        if (qlty>=1) correctedQuality = HIGH_QUALITY;
        if (qlty<=0) correctedQuality = LOW_QUALITY;
        
        NSURL *url = [NSURL URLWithString:aPath];

        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
        // Richard
//        NSArray *requestedKeys = @[@"playable"];
//        [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:^{
//            
//        }];
        // End Richard
        
        
        _qualities = @{correctedQuality:url};
        _assetsReady = NO;
        _assets = [NSMutableDictionary dictionaryWithDictionary:@{correctedQuality:asset}];
        
        _urlPath = [_qualities objectForKey:correctedQuality];
        self.type =FEED_TYPE_ENCODER;
    }
    return self;
}

-(instancetype) initWithFileURL: (NSString *) fileURL{
    self = [super init];
    if (self) {
        [self assignModes:fileURL];
        self.isAlive = YES;
        
        NSURL *url = [NSURL fileURLWithPath: fileURL];
        
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
 
        __block NSError *error = nil;
        // Richard
//        NSArray *requestedKeys = @[@"playable",@"duration"];
//        [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:^{
//            
//            
//            AVKeyValueStatus playableStatus = [asset statusOfValueForKey:@"playable" error:&error];
//            switch (playableStatus) {
//                case AVKeyValueStatusLoaded:
//                    //go on
//                    break;
//                default:
//                    return;
//            }
//            
//            AVKeyValueStatus durationStatus = [asset statusOfValueForKey:@"duration" error:&error];
//            switch (durationStatus) {
//                case AVKeyValueStatusLoaded:
//
//                   
//                    break;
//                default:
//                    return;
//            }
//             Float64 ttt=  CMTimeGetSeconds(asset.duration);
//            
//            NSLog(@"");
//        }];
        
        /* Tells the asset to load the values of any of the specified keys that are not already loaded. */
//        [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:
//         ^{
//             dispatch_async( dispatch_get_main_queue(),
//                            ^{
//                                /* IMPORTANT: Must dispatch to main queue in order to operate on the AVPlayer and AVPlayerItem. */
//                                [self prepareToPlayAsset:asset withKeys:requestedKeys];
//                                
//                            });
//         }];
        
        // End Richard
        _qualities = @{HIGH_QUALITY: url};
        _assets = [NSMutableDictionary dictionaryWithDictionary:@{HIGH_QUALITY: asset}];
        _urlPath = [_qualities objectForKey: HIGH_QUALITY];
        self.type =FEED_TYPE_LOCAL;
        
    }
    if (_mode == FeedModesReady) {
        return  self;
    }else{
        return nil;
    }

}

-(void)assignModes:(NSString *)aPath{
    if ([[NSFileManager defaultManager] fileExistsAtPath:aPath]) {
        _mode = FeedModesReady;
    }else{
        _mode = FeedModesNotFound;
    }
}

-(NSArray *)allPaths{
    return [_qualities allValues];
}


-(NSURL *)path
{
    return _urlPath;
}


-(void)setQuality:(int)aQuality
{
    if (aQuality == _quality) return;
    aQuality = aQuality;
    [self willChangeValueForKey:@"quality"];
//    CMTime time = avPlayer.currentTime;
    if (aQuality == 1 && self.hasHighQuality){
        _urlPath =[_qualities objectForKey:HIGH_QUALITY];
    } else if (aQuality == 0 && self.hasLowQuality){
        _urlPath =[_qualities objectForKey:LOW_QUALITY];
    } else {
        // If
        NSString * key = [[_qualities allKeys]objectAtIndex:0];
        _urlPath = [_qualities objectForKey:key];
    }

    _quality = aQuality;
    [self didChangeValueForKey:@"quality"];
    
}

-(BOOL)hasHighQuality
{
    return ([_qualities objectForKey:HIGH_QUALITY] !=nil)? YES:NO;
}

-(BOOL)hasLowQuality
{
    return ([_qualities objectForKey:LOW_QUALITY] !=nil)? YES:NO;
}


-(NSString*)description
{
    NSString * txt              = [NSString stringWithFormat:@"Feed Quality: %d\n",_quality];
    if (self.hasHighQuality)txt = [NSString stringWithFormat:@"%@High Quaility:\t %@\n",txt,[_qualities objectForKey:HIGH_QUALITY]];
    if (self.hasLowQuality)txt  = [NSString stringWithFormat:@"%@Low Quaility:\t %@",txt,[_qualities objectForKey:LOW_QUALITY]];

    return txt;
}

-(id) copy{

    Feed *feedToReturn = [[Feed alloc] initWithURLDict: [_qualities copy]];
    return feedToReturn;
}
-(void)dealloc
{
    self.isAlive = NO;
}

- (nullable AVAsset *)lqAsset {
    return self.assets[LOW_QUALITY] ? self.assets[LOW_QUALITY] : self.anyAsset;
}

- (nullable AVAsset *)hqAsset {
    return self.assets[HIGH_QUALITY] ? self.assets[HIGH_QUALITY] : self.anyAsset;
}

- (nullable AVAsset *)anyAsset {
    return self.assets.allValues.firstObject;
}

- (nullable NSURL *)lqPath {
    return _qualities[LOW_QUALITY];
}

- (nullable NSURL *)hqPath {
    
    
    return (_qualities[HIGH_QUALITY])?_qualities[HIGH_QUALITY]:_qualities[LOW_QUALITY];
}

@end
