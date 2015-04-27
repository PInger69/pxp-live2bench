//
//  DownloadEventItem.m
//  Live2BenchNative
//
//  Created by dev on 2015-04-07.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "DownloadEventItem.h"

// PRIVATE CLASS


@implementation DownloadEventItem
{
    NSMutableArray  * listOfDownloadItems;
    NSArray         * urlList;
    
    DownloadItem    * focusItem;
    
}


static void * isObservedContext     = &isObservedContext;
static void * statusContext         = &statusContext;

-(instancetype)initWithURL:(NSArray*)aListOfURLAndDestination
{
    self = [super init];
    if (self) {
  //      url                 = @"";
//        path                = aPath;
        self.status         = DownloadItemStatusWaiting;
        super.progress           = 0;
        super.kbps                = 0;
        super.timeoutInterval    = DEFAULT_TIMEOUT;
        super.freeSpaceBuffer    = DEFAULT_FRAME_BUFFER_SIZE;
        downloadType        = DownloadItem_TypeVideo;

        listOfDownloadItems = [[NSMutableArray alloc]init];

        __block DownloadEventItem * weakSelf = self;
        
        for (NSDictionary* dict in aListOfURLAndDestination) {
            DownloadItem * dItem = [[DownloadItem alloc]initWithURL:dict[@"path"] destination:dict[@"dest"]];
            [dItem addOnProgressBlock:^(float progress, NSInteger kbps) {
                // this just gets the progress of all the downloads as one
                [weakSelf getAllProgress];
                
            }];
            [listOfDownloadItems addObject:dItem];
        }
        
        
        focusItem = [listOfDownloadItems objectAtIndex:0];
        
        [focusItem addObserver:self forKeyPath:NSStringFromSelector(@selector(status)) options:NSKeyValueObservingOptionNew context:&statusContext];
        [focusItem addObserver:self forKeyPath:NSStringFromSelector(@selector(isAlive)) options:NSKeyValueObservingOptionNew context:&isObservedContext];
        
        
    }
    return self;



}



-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    DownloadItem    * obj =object;
  
    if (context == &statusContext) {
        
        if (obj.status == DownloadItemStatusComplete) {
            int myindex = [listOfDownloadItems indexOfObject:obj];
            
            if (myindex == [listOfDownloadItems indexOfObject:[listOfDownloadItems lastObject]]){
                [obj removeObserver:self forKeyPath:NSStringFromSelector(@selector(status))    context:&statusContext];
                [obj removeObserver:self forKeyPath:NSStringFromSelector(@selector(isAlive))    context:&isObservedContext];
                self.status = DownloadItemStatusComplete;
                PXPLog(@"Download Complete!!!");
            } else {
                [obj removeObserver:self forKeyPath:NSStringFromSelector(@selector(status))    context:&statusContext];
                [obj removeObserver:self forKeyPath:NSStringFromSelector(@selector(isAlive))    context:&isObservedContext];

                focusItem = [listOfDownloadItems objectAtIndex:myindex+1];
                
                [focusItem addObserver:self forKeyPath:NSStringFromSelector(@selector(status)) options:NSKeyValueObservingOptionNew context:&statusContext];
                [focusItem addObserver:self forKeyPath:NSStringFromSelector(@selector(isAlive)) options:NSKeyValueObservingOptionNew context:&isObservedContext];
                [focusItem start];
            }
            
        } else {
            self.status = obj.status;
        
        }
        
        
        
        
        
    }
    if (context == &isObservedContext) {
        [obj removeObserver:self forKeyPath:NSStringFromSelector(@selector(status))    context:&statusContext];
        [obj removeObserver:self forKeyPath:NSStringFromSelector(@selector(isAlive))    context:&isObservedContext];
    }
    
}




-(void)setStatus:(DownloadItemStatus)status
{
//    if (_status==status)return;
    [self willChangeValueForKey:NSStringFromSelector(@selector(status))];
//    _status = status;
    [self didChangeValueForKey:NSStringFromSelector(@selector(status))];
    
}


-(DownloadItemStatus)status
{
    return nil;
}


#pragma mark -
#pragma mark Class Methods


-(void)getAllProgress
{
    float       poolProgress    = 0;
    NSInteger   poolkbps        = 0;
    
    for (DownloadItem* dli in listOfDownloadItems) {
        
        poolProgress    += dli.progress;
    }
    
    self.progress       = poolProgress / [listOfDownloadItems count];
    self.kbps           = focusItem.kbps;
    if (progressBlock) progressBlock(self.progress, self.kbps);
}


-(void)start
{
    [focusItem start];
//    [listOfDownloadItems makeObjectsPerformSelector:@selector(start)];
    
}


-(void)cancel
{
    [listOfDownloadItems makeObjectsPerformSelector:@selector(cancel)];
}


-(NSString*)stringStatus
{
    NSString * txt = @"";
    
    return txt;
}



@end
