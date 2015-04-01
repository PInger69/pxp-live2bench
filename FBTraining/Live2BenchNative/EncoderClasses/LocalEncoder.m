//
//  LocalEncoder.m
//  Live2BenchNative
//
//  Created by dev on 2014-11-13.
//  Copyright (c) 2014 DEV. All rights reserved.
//

/**
 *   This class will keep a reference to all the local stored videos and clips
 *   The data stored in the "bookmarks path" will be a collection of plist labeled by number e.g. 1.plist, 2.plist ...
 *   each plist will have reference to a clip that will be in the bookmakvideos.
 *
 *   The reason for this is that one book mark or clip can reference multiple videos (multicam) so its built to be extended
 */



#import "LocalEncoder.h"
#import "Feed.h"
#import "Downloader.h"

#define LOCAL_PLIST  @"EventsHid.plist"


@implementation LocalEncoder
{
    NSString        * _localDocsPListPath;
    NSString        * _localPath;
    NSMutableArray  * _bookmarkPlistNames;
    
    NSComparisonResult(^plistSort)(id obj1, id obj2);
    
}

@synthesize name            = _name;
@synthesize event           = _event;
@synthesize eventType       = _eventType;
@synthesize eventData       = _eventData;
@synthesize feeds           = _feeds;
@synthesize status          = _status;
@synthesize allEvents       = _allEvents;
@synthesize allEventData      = _allEventData;
@synthesize eventTagsDict   = _eventTagsDict;

@synthesize clipFeeds       = _clipFeeds;

-(id)initWithDocsPath:(NSString*)aDocsPath
{
    self = [super init];
    if (self){
        _name                            = @"Local Encoder";
        _localPath                      = aDocsPath;
        _localDocsPListPath             = [aDocsPath stringByAppendingPathComponent:LOCAL_PLIST];
        _status                         = ENCODER_STATUS_LOCAL;
        _event                          = @"none";
        _allEventData                   = [[NSArray alloc]initWithContentsOfFile:_localDocsPListPath];
        _eventData                      = @{};
        _eventTagsDict                  = [[NSMutableDictionary alloc]init];
        
        _bookmarkPlistNames             = [[NSMutableArray alloc]init];
        
        _clipFeeds                      = [self buildClipFeeds];
        NSMutableArray  * tempPool      = [[NSMutableArray alloc]init];
        NSEnumerator    * enumerator    = [_allEventData objectEnumerator];
        id value;
        
        while ((value = [enumerator nextObject])) {
            NSDictionary * dict = value;
            if ([dict objectForKey:@"name"]) {
                [tempPool addObject:[dict objectForKey:@"name"]];
            }
        }
        
        
        _allEvents                      = [tempPool copy];
        Feed * test                     = [[Feed alloc]initWithURLString:@"http://192.168.3.100/events/2014-11-13_16-21-16_dff4c99c75cf73a4b374a693f919244648f5aa31_local/video/list.m3u8" quality:0];
        _feeds                          = @{
                                            @"t1":test
                                            };
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myClipDataRequest:) name:NOTIF_REQUEST_MYCLIP_DATA object:nil];
        
        // build sorter block
        
        plistSort = ^(id obj1, id obj2) {
        
            NSString * fn1 = [((NSString*)obj1) componentsSeparatedByString: @"."][0];
            NSString * fn2 = [((NSString*)obj2) componentsSeparatedByString: @"."][0];
            
            int n1 = [fn1 integerValue];
            int n2 = [fn2 integerValue];
            if (n1 > n2) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            
            if (n1 < n2) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            
            return (NSComparisonResult)NSOrderedSame;
        };
        // End sorterblock
        
        
        
        
        [self buildEncoderRequest];
        
    }
    return self;
}









#pragma mark - Event Download








-(void)myClipDataRequest: (NSNotification *)note{
    
}

-(void)issueCommand:(NSString *)methodName priority:(int)priority timeoutInSec:(float)time tagData:(NSMutableDictionary *)tData timeStamp:(NSNumber *)aTimeStamp
{
}

/**
 *  This method will build all the plists during start up converting them in to NSDicts
 *  For Bookmarked Clips, Event, Event Tags, tags to be pushed to cloud
 */
-(void)buildEncoderRequest
{

    // Parse all events plists and add them to the Dictionary
    
    
    
    //Parse all the bookmarked plists
    
    
    
    [self scanPath];
    
    NSMutableDictionary * tempFeedDict = [[NSMutableDictionary alloc]init];
    
    
    // loop thru the plists
    
    
    Feed * feed = [[Feed alloc]initWithURLString:@"" quality:1];
    NSString * feedKey = @"";
    feed.info   = @{};// Plist data
    [tempFeedDict setObject:feed forKey:feedKey];
    
    
    
    
    
    
    _feeds = [tempFeedDict copy];
}


/**
 *   This gets all the videos and clips in the bookmarks folder of the device and adds them to dict based off video name key
 */
-(void)buildAllFeeds
{

//    
//    for (int i = ; i< list count ; i++) {
//        Feed * localFeed = [[Feed alloc]initWithURLString:@"http://192.168.3.100/events/2014-11-13_16-21-16_dff4c99c75cf73a4b374a693f919244648f5aa31_local/video/list.m3u8" quality:0];
//        [_clipFeeds setValue:localFeed forKey:@""];
//    }
//    
//    
    
}


-(void)setEvent:(NSString *)event
{
    // Is it the same event or the event is not on the encoder
    if ([event isEqualToString:_event]){
        return;
    }
    
    
    
    
    [self willChangeValueForKey:@"event"];
    
    
    
    NSArray         * events = _allEventData;
    for(NSDictionary* dict in events)
    {
        if([dict isKindOfClass:[NSDictionary class]]  && [dict[@"name"] isEqualToString: event])
        {
            self.eventData = dict;
            
            if ([dict[@"vid"] isKindOfClass:[NSString class]]) { // This is for backwards compatibility
                
                // _feeds = @{ @"s1":@{@"lq":dict[@"vid"]} };
                // this creates a feed object from just a string with it  source named s1
                Feed * theFeed =  [[Feed alloc]initWithURLString:dict[@"vid"] quality:0];
                _feeds = @{ @"s1":theFeed};
                
            }  else if ([dict[@"vid"] isKindOfClass:[NSDictionary class]]){
                NSMutableDictionary * collect = [[NSMutableDictionary alloc]init];
                
                for (id key in dict[@"vid"])
                {
                    if ([key isEqualToString:@"url"]) continue;
                    NSDictionary * vidDict      = dict[@"vid"];
                    NSDictionary * qualities    = [vidDict objectForKey:key];
                    // This builds a Feed and adds it to the feed pool
                    Feed * createdFeed = [[Feed alloc]initWithURLDict:qualities];
                    createdFeed.sourceName = key;
                    
                  
                    [collect setObject:createdFeed forKey:key];
                }
                
                _feeds = [collect copy];
                
                
            } else {
                NSLog(@"JSON ERROR");
            }
            [self willChangeValueForKey:@"eventType"];
            _eventType = [dict objectForKey:@"sport"];
            [self didChangeValueForKey:@"eventType"];
            break;
        }
    }
    _event =  event;
    [self didChangeValueForKey:@"event"];
    
}



-(NSString*)event
{
    return _event;
}


/**
 *  This class is what buils the rest of the data from the encoder
 *
 *
 *  @param data
 */
-(void)getAllEventsResponse:(NSData *)data
{

}




-(void)downloadToClip:(NSString*)clip
{


}


-(NSString*)bookmarkPath
{
    return [NSString stringWithFormat:@"%@/bookmark",_localPath];
}

-(NSString*)bookmarkedVideosPath
{
    return [NSString stringWithFormat:@"%@/bookmark/bookmarkvideo",_localPath];
}


/**
 *  This get all the plists in the bookmark folder on the device
 *  the plists are labeled as such 1.plist, 2.plist, 3.plist...
 */
-(void)scanPath
{

    NSString * bookmarkPath = [NSString stringWithFormat:@"%@/bookmark",_localPath];
    NSArray* dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:bookmarkPath
                                                                        error:NULL];
    NSMutableArray *mp3Files = [[NSMutableArray alloc] init];
    [dirs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *filename = (NSString *)obj;

        
        if ([self myClipPlistNameCheck:filename]) {
           
            [_bookmarkPlistNames addObject:filename];
            [mp3Files addObject:[bookmarkPath stringByAppendingPathComponent:filename]];
            
        }
        
        
    }];


    
    
    _bookmarkPlistNames = [NSMutableArray arrayWithArray:[_bookmarkPlistNames sortedArrayUsingComparator: plistSort]];
    
    _bookmarkPlistNames = @[@"0.plist",@"1.plist",@"2.plist",@"3.plist",@"4.plist",@"5.plist"];
    
    int n = [self gap:_bookmarkPlistNames first:0 last:[_bookmarkPlistNames count]-1];
    
}

-(NSArray*)grabAllFiles:(NSString*)aPath ext:(NSString*)ext
{



    return @[];
}


/**
 *  This will check the bookmark folder on the device and give a number that will be used for the name of the video that will be used
 *
 *  @return n
 */
-(NSInteger)getBookmarkSpace
{
    return 0;
}



-(BOOL)myClipPlistNameCheck:(NSString*)check
{
    // Regx
//    NSRange   searchedRange     = NSMakeRange(0, [check length]);
//    NSString *pattern           = @".*\\.plist";//@"(?:www\\.)?((?!-)[a-zA-Z0-9-]{2,63}(?<!-))\\.?((?:[a-zA-Z0-9]{2,})?(?:\\.[a-zA-Z0-9]{2,})?)";
//    NSError  *error             = nil;
//    NSRegularExpression* regex  = [NSRegularExpression regularExpressionWithPattern: pattern options:0 error:&error];
//    NSArray* matches            = [regex matchesInString:check options:0 range: searchedRange];
//    
//    // name split
//    
////    NSArray *lines = [filename componentsSeparatedByString: @"."];
////    NSString *lineOne = lines[0];
//
//    NSString *extension = [[check pathExtension] lowercaseString];
//
    NSRange range = [check rangeOfString:@"[0-9]+\\.plist" options:NSRegularExpressionSearch];
    return range.location != NSNotFound;
}



#pragma mark - Bookmark Clip Methods

-(NSMutableDictionary *)buildClipFeeds
{
    


}


-(void)saveClip:(NSString*)aName withData:(NSDictionary*)tagData
{
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:tagData];
    
    // add local file name to the plist
    [dict addEntriesFromDictionary:@{@"fileNames": @[aName]}];
    
    
    // adds the clip to the rest of the feeds
    NSString * clipPath = [NSString stringWithFormat:@"%@/%@",[self bookmarkedVideosPath],aName];
    Feed     * myFeed   = [[Feed alloc]initWithURLString:clipPath quality:0];
    [_clipFeeds setValue:myFeed forKey:aName];
    
    
    // writes the plist to the harddrive
    int nextGap = [self gap:_bookmarkPlistNames first:0 last:[_bookmarkPlistNames count]-1];
    // write the plist
    NSString * bookmarkPath = [NSString stringWithFormat:@"%@/bookmark/%d.plist",_localPath,nextGap];
    [dict writeToFile:bookmarkPath atomically:YES];
    
    // adds the plist to the list of clips
    
    [_eventTagsDict setObject:dict forKey:aName];
}


-(void)deleteClip:(NSString*)aName
{
    
    
    [_clipFeeds removeObjectForKey:aName];
    
    // sort list on delete
    _bookmarkPlistNames = [NSMutableArray arrayWithArray:[_bookmarkPlistNames sortedArrayUsingComparator: plistSort]];
}


-(int)gap:(NSArray*)list first:(int)first last:(int)last
{
    // if there is nothing in the list
    if ([list count] <1){
        return 0;
    }
    
    if (first >= last){
        if(first >= [list[first] intValue]){
            return last+1;
        }
        return last;
    }
    int med =  (last+first)>>1;//(int)((last+first)*.5);//
    if(med < [list[med]intValue]){
        return [self gap:list first:first last:med];
    }
    return [self gap:list first:med+1 last:last];
    
}





//debugging
#pragma mark - debugging

// This will show name and status
// This will show name and status
-(NSString*)description
{
    NSString * bookmarkPath = [NSString stringWithFormat:@"%@/bookmark",_localPath];
    NSString * txt = [NSString stringWithFormat:@" %@: %d - %@   - %@\nBookmark Path:%@",self.name,self.status,self.event,self.eventType,  bookmarkPath ];
    return txt;
}


-(NSString*)name
{
    return _name;
}

-(void)setName:(NSString *)name
{
    [self willChangeValueForKey:@"name"];
    _name = name;
    [self didChangeValueForKey:@"name"];
}


@end
