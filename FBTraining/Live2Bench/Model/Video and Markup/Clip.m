//
//  Clip.m
//  Live2BenchNative
//
//  Created by dev on 2015-04-09.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "Clip.h"
#import "Feed.h"
#import "LocalMediaManager.h"

@implementation Clip

/**
 *  This is used when making a new plist from scatch
 *
 *  @param aPath <#aPath description#>
 *  @param data  <#data description#>
 *
 *  @return <#return value description#>
 */

//@synthesize rating = _rating;
@synthesize comment = _comment;
@synthesize path    = _path;
-(instancetype)initWithPlistPath:(NSString*)aPath data:(NSDictionary*)data
{
    self = [super initWithData:data event:nil];
    if (self) {
        
        _localRawData         = [[NSMutableDictionary alloc]initWithDictionary:self.rawData];
        //_rawData            = [NSMutableDictionary dictionaryWithDictionary:data];
        //_name               = [_rawData objectForKey:@"name"];
        _clipId               = self.ID;
        //_clipId             = [NSString stringWithFormat:@"%d",[[_rawData objectForKey:@"id"] intValue]];
        //_rating             = [[_rawData objectForKey:@"rating"] intValue];
        //_comment            = [_rawData objectForKey:@"comment"];
        _rating             = [data[@"rating"] intValue];
        _comment            = data[@"comment"];
        _path               = aPath;
        self.videosBySrcKey     = ([data objectForKey:@"fileNamesByKey"])?[data objectForKey:@"fileNamesByKey"]:[NSMutableDictionary new];
        _localRawData[@"plistPath"] = aPath;
        _localRawData[@"fileNamesByKey"] = self.videosBySrcKey;
        //_localRawData[@"fileNames"] = data[@"fileNames"];
        _eventName = data[@"event"];
        _localRawData[@"event"] = _eventName;
        //_videosBySrcKey     = ([_rawData objectForKey:@"fileNamesByKey"])?[_rawData objectForKey:@"fileNamesByKey"]:[NSMutableDictionary new];
        //_event = _rawData[@"event"];
        //_displayTime = _rawData[@"displaytime"];
        
       // _rawData[@"plistPath"] = aPath;
        NSArray * fileNames = data[@"fileNames"];
        if ([self.videosBySrcKey count]<[fileNames count]) {
            NSDictionary * temp = _localRawData[@"url"];
            NSArray * temp2 = [temp allKeys];
            for (NSString*key in temp2) {
                for (NSString*key2 in fileNames) {
                    if ([key2 containsString:key]) {
                        [self.videosBySrcKey setObject:key2 forKey:key];
                    }
                    
                }
            }
        }

        if (![self.videosBySrcKey count] && [fileNames count]==1) {
            [self.videosBySrcKey setObject:[fileNames firstObject] forKey:@"s_00"];
        }
        
        
        [_localRawData writeToFile:self.path atomically:YES];
        
        // just save
    }
    return self;
}

-(PxpClipSource*) sourceForKey:(NSString*) source {
    NSString* filePath = self.videosBySrcKey[source];
    NSString* unqualifiedName = [filePath lastPathComponent];
    
    NSString* correctedPath = nil;
    for (NSString* path in self.videoFiles) {
        if ([unqualifiedName isEqualToString:[path lastPathComponent]]) {
            correctedPath = path;
            break;
        }
    }
    
    if (correctedPath == nil) {
        return nil;
    } else {
        NSString* name = [NSString stringWithFormat:@"%@_%@_%@_%@.mp4",self.name,[Utility dateFromEvent:self.eventName],self.displayTime,source];
        return [[PxpClipSource alloc] initWithPath:correctedPath name:name];
    }
}

-(NSArray*) clipSources {
    NSMutableArray* result = [NSMutableArray new];
    for (NSString* source in self.videosBySrcKey) {
        PxpClipSource* clipSource = [self sourceForKey:source];
        if (clipSource != nil) {
            [result addObject:clipSource];
        }
    }
    return [NSArray arrayWithArray:result];
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
    self = [super initWithData:data event:nil];
    //self = [super initWithData:data event:]
    if (self) {
         _localRawData         = [[NSMutableDictionary alloc]initWithDictionary:self.rawData];
        _clipId              = self.ID;
        _rating             = [data[@"rating"] intValue];
        _comment            = data[@"comment"];
        _path               = [data objectForKey:@"plistPath"];

        self.videosBySrcKey     = ([data objectForKey:@"fileNamesByKey"])?[[data objectForKey:@"fileNamesByKey"] mutableCopy ]:[NSMutableDictionary new];
        _localRawData[@"plistPath"] = _path;
        _localRawData[@"fileNamesByKey"] = [self.videosBySrcKey copy];
        if (data[@"fileNames"]) _localRawData[@"fileNames"] = data[@"fileNames"];
        _eventName = data[@"event"];
        _localRawData[@"event"] = _eventName;
        
        NSArray * fileNames = [self videoFiles];
        if ([self.videosBySrcKey count]<[fileNames count]) {
            NSDictionary * temp = _localRawData[@"url"];
            NSArray * temp2 = [temp allKeys];
            for (NSString*key in temp2) {
                for (NSString*key2 in fileNames) {
                    if ([key2 containsString:key]) {
                        [self.videosBySrcKey setObject:key2 forKey:key];
                    }
                    
                }
            }
        }

        
        if (![self.videosBySrcKey count] && [fileNames count]==1) {
            [self.videosBySrcKey setObject:[fileNames firstObject] forKey:@"s_00"];
        }
        
        NSMutableArray * listOfVideos = [NSMutableArray arrayWithArray:[self videoFiles]];
        BOOL modFlag = NO;
         // this checks to see if the clip is are on the device if not then remove from Dict
        for (NSInteger i = [listOfVideos count]-1;i>=0;i--) {
            NSString * videoPathsToCheck = listOfVideos[i];
            if ( ![[NSFileManager defaultManager] fileExistsAtPath:videoPathsToCheck] ){
                [listOfVideos removeObject:videoPathsToCheck];
                modFlag = YES;
            }
        
        }

        if (modFlag) [_localRawData writeToFile:_path atomically:YES];
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
    
    NSMutableArray *filePaths = [NSMutableArray arrayWithArray:_localRawData[@"fileNames"]];
    for (NSUInteger i = 0; i < filePaths.count; i++) {
        filePaths[i] = [path stringByAppendingPathComponent:filePaths[i]];
    }
    
    return filePaths;
}

-(void)write {
    NSMutableDictionary *rawData = [[NSMutableDictionary alloc]initWithDictionary:self.rawData];
    [rawData addEntriesFromDictionary:self.localRawData];
    [rawData writeToFile: self.path atomically:YES];
    NSLog(@"Write file to: %@",self.path);
}


-(void)modClipData:(NSDictionary*)aDict
{
    NSMutableDictionary *mutableDict = [_localRawData mutableCopy];
    for (NSString *key in [aDict allKeys]) {
        mutableDict[key] = aDict[key];
    }
    _localRawData = mutableDict;
}

-(void)addSourceToClip:(NSDictionary*)aDict
{
    NSMutableDictionary *mutableDict = [_localRawData mutableCopy];
    
    if (![mutableDict objectForKey:@"fileNames"]){
        [mutableDict setObject:[[NSMutableArray alloc]init] forKey:@"fileNames"];
    }
    
    
    if (![mutableDict objectForKey:@"fileNamesByKey"]){
        _videosBySrcKey = [[NSMutableDictionary alloc]init];
        [mutableDict setObject:_videosBySrcKey forKey:@"fileNamesByKey"];
    } else {
        _videosBySrcKey = [NSMutableDictionary dictionaryWithDictionary:[mutableDict objectForKey:@"fileNamesByKey"]];
    
    }
    
    NSMutableArray * list       = [NSMutableArray arrayWithArray: mutableDict[@"fileNames"]];
    NSString *aName = [[aDict objectForKey:@"fileNames"] firstObject];
    [list addObject: aName];
    NSSet * uniqueFileNames = [[NSSet alloc]initWithArray:list];
    mutableDict[@"fileNames"]   = [uniqueFileNames allObjects];
    
    if ([self.videosBySrcKey count]<[uniqueFileNames count]) {
        NSDictionary * temp = _localRawData[@"url"];
        NSArray * temp2 = [temp allKeys];
        for (NSString*key in temp2) {
            for (NSString*key2 in uniqueFileNames) {
                if ([key2 containsString:key]) {
                    if(![key2 containsString:@"bookmark"]) {
                        [self.videosBySrcKey setObject:[NSString stringWithFormat:@"%@/%@",[[LocalMediaManager getInstance]bookmarkedVideosPath],key2] forKey:key];
                    } else {
                        [self.videosBySrcKey setObject:key2 forKey:key];
                    }
                   
                }
            
            }
        }
    }
    mutableDict[@"fileNamesByKey"] = self.videosBySrcKey;
    _localRawData = mutableDict;
    
    @try {
        [_localRawData writeToFile:self.path atomically:YES];
    }
    @catch (NSException *exception) {
        NSLog(@"EXCEPTION: %@", exception);
    }
    
}

// This method mods the clip GlobalID so that its no longer connected to live event
-(void)breakClipId
{
    
    [_localRawData setObject:  [NSNumber numberWithInteger:CFAbsoluteTimeGetCurrent()]   forKey:@"id"]  ;
//    _clipId = self.ID;
    _clipId = _localRawData[@"id"];
    
    //[NSString stringWithFormat:@"%d",[[_rawData objectForKey:@"id"] intValue]];
    [self write];
}


-(void)destroy
{
    
    NSError * plistError;
    
    BOOL isAFile = [[NSFileManager defaultManager] fileExistsAtPath:self.path];
    
    if(isAFile) {
    
        NSLog(@"Found File");
    
    } else {
        NSLog(@"NO FIle");
    }
    
    
    
    BOOL plistDestroyed = [[NSFileManager defaultManager] removeItemAtPath:self.path error:&plistError];
    NSLog(@"Path : %@",self.path);
    if (plistDestroyed) {
        NSLog(@"The plist has been destroyed");
    } else {
        if (plistError){
            NSLog(@"Error in destroying plist %@",plistError);
        }
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent: @"/bookmark"];
    NSString *path = [dataPath stringByAppendingPathComponent: @"/bookmarkvideo"];
    
    
    for (NSString *fileName in [_localRawData objectForKey:@"fileNames"]) {
        NSString *filePath = [path stringByAppendingPathComponent: fileName];
        
        BOOL vidDestroyed = [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        
        if (vidDestroyed) {
            NSLog(@"The video has been destroyed");
        }
        
    }
}

- (NSString *)globalID {
    return [NSString stringWithFormat:@"%@_%@", _eventName, _clipId];
}


-(NSString*)path
{
    return _path;
}

-(void)setPath:(NSString *)path
{
    _path = path;
}


- (BOOL)isEqual:(id)object {
    BOOL check = [object isKindOfClass:[Clip class]] &&
    [self.clipId isEqualToString:[(Clip *)object clipId]] &&
    [self.name isEqualToString:[(Clip *)object name]]    ;
    
    return check;
}


@end

