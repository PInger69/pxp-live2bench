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
        _clipId             = [_rawData objectForKey:@"id"];
        _rating             = [[_rawData objectForKey:@"rating"] intValue];
        _comment            = [_rawData objectForKey:@"comment"];
        _path               = aPath;
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
    }
    return self;
}

#pragma mark - custom getter and setter methods

-(void)setRating:(int)rating{
    _rating = rating;
    [self modClipData: @{@"rating": [NSNumber numberWithInt: rating]}];
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
    
    NSMutableArray * list       = [NSMutableArray arrayWithArray: mutableDict[@"fileNames"]];
    NSString *aName = [[aDict objectForKey:@"fileNames"] firstObject];
    [list addObject: aName];
    mutableDict[@"fileNames"]   = list;

    _rawData = mutableDict;
    [_rawData writeToFile:self.path atomically:YES];
    
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
    return [NSString stringWithFormat:@"%@_%@", _rawData[@"event"], _rawData[@"id"]];
}


@end
