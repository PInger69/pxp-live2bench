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
}


@synthesize quality     = _quality;
@synthesize sourceName  =_sourceName;
@synthesize type;
@synthesize isAlive;
@synthesize info;
@synthesize mode        = _mode;

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
        for (NSString * k in keys)
        {
            [tempDict setObject:[NSURL URLWithString:[aDict objectForKey:k]] forKey:k];
            
            if (defaultURL == nil) {
                defaultURL = [tempDict objectForKey:[k lowercaseString]];
            } else if ([[k lowercaseString] isEqualToString:LOW_QUALITY]) {   // The default is LOW_QUALITY
                defaultURL = [tempDict objectForKey:[k lowercaseString]];
            }
        }
        _qualities = [tempDict copy];
        _urlPath = [defaultURL copy];
        self.type =FEED_TYPE_ENCODER;           
    }
    return self;
}

-(id)initWithURLString:(NSString *)aPath quality:(int)qlty
{
    self = [super init];
    if (self) {
        
        self.isAlive = YES;
        NSString * correctedQuality;
        if (qlty>=1) correctedQuality = HIGH_QUALITY;
        if (qlty<=0) correctedQuality = LOW_QUALITY;
        
        _qualities = @{correctedQuality:[NSURL URLWithString:aPath]};
        
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
        _qualities = @{HIGH_QUALITY: [NSURL fileURLWithPath: fileURL]};
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
    int correctedQuality;
    if (aQuality>1) correctedQuality =1;
    if (aQuality<0) correctedQuality =0;
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


@end
