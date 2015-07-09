//
//  Clip.m
//  Live2BenchNative
//
//  Created by dev on 2015-04-09.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "Clip.h"
#import "Feed.h"


@implementation Clip

/**
 *  This is used when making a new plist from scatch
 *
 *  @param aPath <#aPath description#>
 *  @param data  <#data description#>
 *
 *  @return <#return value description#>
 */
-(instancetype)initWithPlistPath:(NSString*)aPath data:(NSDictionary*)data
{
    self = [super init];
    if (self) {
        
        _rawData            = [NSMutableDictionary dictionaryWithDictionary:data];
        _name               = [_rawData objectForKey:@"name"];
        _clipId             = [NSString stringWithFormat:@"%d",[[_rawData objectForKey:@"id"] intValue]];
        _rating             = [[_rawData objectForKey:@"rating"] intValue];
        _comment            = [_rawData objectForKey:@"comment"];
        _path               = aPath;
        _videosBySrcKey     = ([_rawData objectForKey:@"fileNamesByKey"])?[_rawData objectForKey:@"fileNamesByKey"]:[NSMutableDictionary new];
        _event = _rawData[@"event"];
        _displayTime = _rawData[@"displaytime"];
        
        _rawData[@"plistPath"] = aPath;
        
        
        
        [_rawData writeToFile:self.path atomically:YES];
        
        // just save
    }
    return self;
}


/**
 *  This is used to make a clip from a existing plist
 *
 *  @param data <#data description#>
 *
 *  @return <#return value description#>
 */
-(instancetype)initWithDict:(NSDictionary*)data
{
    self = [super init];
    if (self) {
        _rawData            = [NSMutableDictionary dictionaryWithDictionary:data];
        _name               = [_rawData objectForKey:@"name"];
        _clipId             = [NSString stringWithFormat:@"%d",[[_rawData objectForKey:@"id"] intValue]];
        _rating             = [[_rawData objectForKey:@"rating"] intValue];
        _comment            = [_rawData objectForKey:@"comment"];
        _path               = [_rawData objectForKey:@"plistName"];
        _videosBySrcKey     = ([_rawData objectForKey:@"fileNamesByKey"])?[_rawData objectForKey:@"fileNamesByKey"]:[NSMutableDictionary new];
        _event = _rawData[@"event"];
        _displayTime = _rawData[@"displaytime"];
        
        
        NSMutableArray * listOfVideos = [NSMutableArray arrayWithArray:[self videoFiles]];
        BOOL modFlag;
         // this checks to see if the clip is are on the device if not then remove from Dict
        for (NSString * videoPathsToCheck  in listOfVideos) {
            if ( ![[NSFileManager defaultManager] fileExistsAtPath:videoPathsToCheck] ){
                [listOfVideos removeObject:videoPathsToCheck];
                modFlag = YES;
            }
        }
        
        NSArray * vidkeys = [_videosBySrcKey allKeys];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent: @"/bookmark"];
        NSString *path = [dataPath stringByAppendingPathComponent: @"/bookmarkvideo"];
        
        for (NSString * k  in vidkeys) {

            NSString * check = [path stringByAppendingPathComponent:_videosBySrcKey[k]];
            if ( ![[NSFileManager defaultManager] fileExistsAtPath:check] ){
                [_videosBySrcKey removeObjectForKey:k];
                modFlag = YES;
            }
        }
        
        
        if (modFlag) [_rawData writeToFile:self.path atomically:YES];
    }
    return self;
}

#pragma mark - custom getter and setter methods

-(void)setRating:(NSInteger)rating{
    _rating = rating;
    [self modClipData: @{@"rating": [NSNumber numberWithInteger: rating]}];
    [self write];
}

-(void)setComment:(NSString *)comment{
    _comment = comment;
    if (comment) {
        [self modClipData: @{@"comment": comment}];
    }else{
        [self modClipData: @{@"comment": @""}];
    }
    [self write];
}

-(NSArray *)videoFiles {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent: @"/bookmark"];
    NSString *path = [dataPath stringByAppendingPathComponent: @"/bookmarkvideo"];
    
    NSMutableArray *filePaths = [NSMutableArray arrayWithArray:_rawData[@"fileNames"]];
    for (NSUInteger i = 0; i < filePaths.count; i++) {
        filePaths[i] = [path stringByAppendingPathComponent:filePaths[i]];
    }
    
    return filePaths;
}

-(void)write {
    [_rawData writeToFile: self.path atomically:YES];
}


-(void)modClipData:(NSDictionary*)aDict
{
    NSMutableDictionary *mutableDict = [_rawData mutableCopy];
    for (NSString *key in [aDict allKeys]) {
        mutableDict[key] = aDict[key];
    }
    _rawData = mutableDict;
}

-(void)addSourceToClip:(NSDictionary*)aDict
{
    NSMutableDictionary *mutableDict = [_rawData mutableCopy];
    
    if (![mutableDict objectForKey:@"fileNames"]){
        [mutableDict setObject:[[NSMutableArray alloc]init] forKey:@"fileNames"];
    }
    
    
    if (![mutableDict objectForKey:@"fileNamesByKey"]){
        _videosBySrcKey = [[NSMutableDictionary alloc]init];
        [mutableDict setObject:_videosBySrcKey forKey:@"fileNamesByKey"];
    } else {
        _videosBySrcKey = [NSMutableDictionary dictionaryWithDictionary:[mutableDict objectForKey:@"fileNamesByKey"]];
    
    }
    
    
        NSString * theFileName          = [[aDict objectForKey:@"fileNames"] firstObject];
        
        NSRange startRange = [theFileName rangeOfString:@"+"];
        NSRange endRange = [theFileName rangeOfString:@".mp4"];
        
        NSRange searchRange = NSMakeRange(startRange.location+1, (endRange.location-1) - startRange.location);
        
//        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(?<=\+).+?(?=\.mp4)" options:0 error:nil];
//        NSRange needleRange = [regex rangeOfFirstMatchInString:theFileName options:NSMatchingAnchored range:NSMakeRange(0, theFileName.length)];
        NSString *scrKeyFromFileName = [theFileName substringWithRange:searchRange];

     //   NSString * scrKeyFromFileName   = [theFileName substringWithRange:needleRange];
        
        [_videosBySrcKey setObject:theFileName forKey:scrKeyFromFileName];

    
    
    NSMutableArray * list       = [NSMutableArray arrayWithArray: mutableDict[@"fileNames"]];
    NSString *aName = [[aDict objectForKey:@"fileNames"] firstObject];
    [list addObject: aName];
    NSSet * uniqueFileNames = [[NSSet alloc]initWithArray:list];
    mutableDict[@"fileNames"]   = [uniqueFileNames allObjects];
    
    _rawData = mutableDict;
    
    @try {
        [_rawData writeToFile:self.path atomically:YES];
    }
    @catch (NSException *exception) {
        NSLog(@"EXCEPTION: %@", exception);
    }
    
}

// This method mods the clip GlobalID so that its no longer connected to live event
-(void)breakClipId
{
    
    [_rawData setObject:  [NSNumber numberWithInteger:CFAbsoluteTimeGetCurrent()]   forKey:@"id"]  ;
    _clipId = [NSString stringWithFormat:@"%d",[[_rawData objectForKey:@"id"] intValue]];
    [self write];
}


-(void)destroy
{
    BOOL plistDestroyed = [[NSFileManager defaultManager] removeItemAtPath:self.path error:nil];
    
    if (plistDestroyed) {
        NSLog(@"The plist has been destroyed");
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent: @"/bookmark"];
    NSString *path = [dataPath stringByAppendingPathComponent: @"/bookmarkvideo"];
    

    for (NSString *fileName in [_rawData objectForKey:@"fileNames"]) {
        NSString *filePath = [path stringByAppendingPathComponent: fileName];
        
        BOOL vidDestroyed = [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        
        if (vidDestroyed) {
            NSLog(@"The video has been destroyed");
        }

    }
}

- (NSString *)globalID {
//    return [NSString stringWithFormat:@"%@_%@", _rawData[@"event"], _rawData[@"id"]];
    return [NSString stringWithFormat:@"%@_%@", _event, _clipId];
}


@end
