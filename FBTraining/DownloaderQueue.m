//
//  DownloaderQueue.m
//  Live2BenchNative
//
//  Created by dev on 2016-10-05.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "DownloaderQueue.h"
#import "DownloadOperation.h"

static  NSOperationQueue * _queue;
static  NSMapTable       * _mapTable;
@implementation DownloaderQueue

+(void)initialize
{
    _queue = [NSOperationQueue new];
    _queue.maxConcurrentOperationCount = 1;
//    [_queue setSuspended:YES];
    _mapTable = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableWeakMemory];
}

+(void)addOperation:(NSOperation*)operation
{
    [_queue addOperation:operation];
}

+(NSOperationQueue*)queue
{
    return _queue;
}

+(NSOperation *)getQueueItemByKey:(NSString*)key
{
    
    // should check if operation is cleared when queue is empty
//    if (_queue.operationCount == 0) {
//        [_mapTable removeAllObjects];
//    }

    
    NSEnumerator *enumerator = [_mapTable keyEnumerator];
    NSMutableArray * keysToRemove = [NSMutableArray new];
    id value;
    
    while ((value = [enumerator nextObject])) {
        /* code that acts on the map table's keys */
        NSOperation * operation = [_mapTable objectForKey:value];
        if (operation.finished) {
           
            [keysToRemove addObject:value];
        }
    }
    
    for (NSString * key in keysToRemove) {
         [_mapTable removeObjectForKey:key];
    }
    
    return [_mapTable objectForKey:key];
}


// maybe this should follow a protocol
+(void)addDownloadItem:(NSOperation *)item key:(NSString*)key
{
    NSOperation * operation = (NSOperation *) item;
    
    [_mapTable setObject:operation forKey:key];
    
    [_queue addOperation:operation];
}

+(void)trackOperation:(NSOperation *)item key:(NSString*)key
{
    [_mapTable setObject:item forKey:key];
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}
@end
