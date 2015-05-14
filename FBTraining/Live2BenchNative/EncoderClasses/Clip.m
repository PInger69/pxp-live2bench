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

//@synthesize name        = _name;
//@synthesize clipId      = _clipId;
//@synthesize rating      = _rating;
//@synthesize comment     = _comment;
//@synthesize feeds       = _feeds;
//@synthesize rawData     = _rawData;
//@synthesize path        = _path;


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
        
        //NSDictionary * data = [[NSDictionary alloc]initWithContentsOfFile:aPath];
    
        _rawData            = data;
        _name               = [_rawData objectForKey:@"name"];
        _clipId             = [_rawData objectForKey:@"id"];
        _rating             = [[_rawData objectForKey:@"rating"] intValue];
        _comment            = [_rawData objectForKey:@"comment"];
        _feeds              = [self buildFeeds:_rawData];
        _path               = aPath;
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
        
        _rawData            = data;
        _name               = [_rawData objectForKey:@"name"];
        _clipId             = [NSString stringWithFormat:@"%d",[[_rawData objectForKey:@"id"] intValue]];
        _rating             = [[_rawData objectForKey:@"rating"] intValue];
        _comment            = [_rawData objectForKey:@"comment"];
        _feeds              = [self buildFeeds:_rawData];
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

-(NSArray *)videoFiles{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent: @"/bookmark"];
    NSString *path = [dataPath stringByAppendingPathComponent: @"/bookmarkvideo"];
    NSString *filePath = [path stringByAppendingPathComponent: [[_rawData objectForKey:@"fileNames"] firstObject]];
    
    NSArray *returningArray = @[filePath];
    return returningArray;
}

-(NSDictionary*)buildFeeds:(NSDictionary*)aDict
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent: @"/bookmark"];
    NSString *path = [dataPath stringByAppendingPathComponent: @"/bookmarkvideo"];
    
    NSMutableDictionary *returningDict = [[NSMutableDictionary alloc] init];
    int i = 0;
    for (NSString *fileName in [aDict objectForKey:@"fileNames"]) {
        NSString *filePath = [path stringByAppendingPathComponent: fileName];
        Feed *newFeed = [[Feed alloc] initWithFileURL: filePath];
        
        [returningDict setObject:newFeed forKey:[NSString stringWithFormat:@"source%i", i]];
        
    }
    
    return returningDict;
//
//
//    if ([aDict objectForKey:@"fileNames"]){
//    
//    
//    }
//    
//    if ([aDict[@"vid_2"] isKindOfClass:[NSDictionary class]]){ // For new encoder and non live
//        
//        for (id key in aDict[@"vid_2"])
//        {
//            NSDictionary * vidDict      = aDict[@"vid_2"];
//            NSDictionary * qualities    = [vidDict objectForKey:key];
//            
//            Feed * createdFeed = [[Feed alloc]initWithURLDict:qualities];
//            createdFeed.sourceName = key;
//            
//            [tempDict setObject:createdFeed forKey:key];
//        }
//        
//    } else if ([aDict[@"live_2"] isKindOfClass:[NSDictionary class]]){ // for new encoder and Live
//        
//        for (id key in aDict[@"live_2"])
//        {
//            NSDictionary * vidDict      = aDict[@"live_2"];
//            NSDictionary * qualities    = [vidDict objectForKey:key];
//            
//            Feed * createdFeed = [[Feed alloc]initWithURLDict:qualities];
//            createdFeed.sourceName = key;
//            
//            [tempDict setObject:createdFeed forKey:key];
//        }
//        
//    }
//    
//    
//    return [tempDict copy];
    return nil;
}

-(void)write
{
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//
//    //NSString *plistName = [_rawData objectForKey:@"plistName"];
//    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent: @"/bookmark"];
//    NSString *plistPath = [dataPath stringByAppendingPathComponent: self.path];
    
    
    [_rawData writeToFile: self.path atomically:YES];
    
    return ;
//    NSError  * error        = nil;
//    [[NSFileManager defaultManager] removeItemAtPath:plistPath error:&error];
//    
//    for (NSString *videoFileName in [_rawData objectForKey:@"fileNames"]) {
//        dataPath = [documentsDirectory stringByAppendingPathComponent: @"/bookmarkVideos"];
//        NSString * videoPath    = [dataPath stringByAppendingPathComponent: videoFileName];
//        [[NSFileManager defaultManager] removeItemAtPath:videoPath error:&error];
//    }
    // check the device if the clip is there.. if not then make a new clip from and make get an Id
//    
//    
//    NSString            * clipID        = tagData[@"id"];
//    NSMutableDictionary * mutableDict   = [NSMutableDictionary dictionaryWithDictionary:tagData];
//    NSString            * bookmarkPlistPath;
//    
//    if ([_bookmarkPlistById objectForKey:clipID]) { // if there is a plist there already then just mod the data
//        mutableDict                 = [_bookmarkPlistById objectForKey:clipID];
//        NSMutableArray * list       = [NSMutableArray arrayWithArray:mutableDict[@"fileNames"]];
//        [list addObject:aName];
//        mutableDict[@"fileNames"]   = list;
//        NSString * plistFileName    = mutableDict[@"plistName"];
//        bookmarkPlistPath = [NSString stringWithFormat:@"%@/bookmark/%@",_localPath,plistFileName];
//        
//    } else { // there is no plist for this clip... make a new plist
//        [mutableDict addEntriesFromDictionary:@{@"fileNames": @[aName]}];
//        [self scanForBookmarks];
//        int nextGap = [self gap:_bookmarkPlistNames first:0 last:[_bookmarkPlistNames count]-1];
//        bookmarkPlistPath = [NSString stringWithFormat:@"%@/bookmark/%d.plist",_localPath,nextGap];
//    }
//    
//    // make bookmarkvideo path if not there
//    BOOL isDir = NO;
//    [[NSFileManager defaultManager] fileExistsAtPath:[self bookmarkedVideosPath] isDirectory:&isDir];
//    
//    if ( !isDir){
//        [[NSFileManager defaultManager] createDirectoryAtPath:[self bookmarkedVideosPath] withIntermediateDirectories:YES attributes:nil error:NULL];
//    }
//    
//    NSString * clipPath = [NSString stringWithFormat:@"%@/%@",[self bookmarkedVideosPath],aName]; // is this right
//    
//    
//    // adds the clip to the rest of the clip feeds
//    
//    Feed     * myFeed   = [[Feed alloc]initWithURLString:clipPath quality:0];
//    [_clipFeeds setValue:myFeed forKey:aName];
//    
//    
//    [mutableDict addEntriesFromDictionary:@{@"plistName": [bookmarkPlistPath lastPathComponent] }];
//    [mutableDict writeToFile:bookmarkPlistPath atomically:YES];
//    
//    [_eventTagsDict setObject:mutableDict forKey:aName];
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
//    NSString * plistFileName    = mutableDict[@"plistName"];
//    bookmarkPlistPath = [NSString stringWithFormat:@"%@/bookmark/%@",_localPath,plistFileName];
    _rawData = mutableDict;
    [_rawData writeToFile:self.path atomically:YES];
//
//    
//    
//    
//    // make bookmarkvideo path if not there
//    BOOL isDir = NO;
//    [[NSFileManager defaultManager] fileExistsAtPath:[self bookmarkedVideosPath] isDirectory:&isDir];
//    
//    if ( !isDir){
//        [[NSFileManager defaultManager] createDirectoryAtPath:[self bookmarkedVideosPath] withIntermediateDirectories:YES attributes:nil error:NULL];
//    }
//    
//    NSString * clipPath = [NSString stringWithFormat:@"%@/%@",[self bookmarkedVideosPath],aName]; // is this right
//    
//    
//    // adds the clip to the rest of the clip feeds
//    
//    Feed     * myFeed   = [[Feed alloc]initWithURLString:clipPath quality:0];
//    [_clipFeeds setValue:myFeed forKey:aName];
//    
//    
//    [mutableDict addEntriesFromDictionary:@{@"plistName": [bookmarkPlistPath lastPathComponent] }];
//    [mutableDict writeToFile:bookmarkPlistPath atomically:YES];
//    
//    [_eventTagsDict setObject:mutableDict forKey:aName];

    
    
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
            NSLog(@"The plist has been destroyed");
        }

    }

    //NSDictionary * clipDict = [_clips objectForKey:aId];
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString *plistName = [_rawData objectForKey:@"plistName"];
//    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent: @"/bookmark"];
//    
//    NSString *plistPath = [dataPath stringByAppendingPathComponent: plistName];
//    NSError  * error        = nil;
//    [[NSFileManager defaultManager] removeItemAtPath:plistPath error:&error];
//    
//    for (NSString *videoFileName in [_rawData objectForKey:@"fileNames"]) {
//        dataPath = [documentsDirectory stringByAppendingPathComponent: @"/bookmarkVideos"];
//        NSString * videoPath    = [dataPath stringByAppendingPathComponent: videoFileName];
//        [[NSFileManager defaultManager] removeItemAtPath:videoPath error:&error];
//    }
//       NSString * clipID       = [NSString stringWithFormat:@"%@",[clipDict objectForKey:@"id"]];
//    
//    
////[_clips removeObjectForKey:clipID];
//    
//    // sort list on delete
//    _bookmarkPlistNames = [NSMutableArray arrayWithArray:[_bookmarkPlistNames sortedArrayUsingComparator: plistSort]];
    // BOOM!
}

-(void)dealloc{

}

- (NSString *)globalID {
    return [NSString stringWithFormat:@"%@_%@", _rawData[@"event"], _rawData[@"id"]];
}


@end
