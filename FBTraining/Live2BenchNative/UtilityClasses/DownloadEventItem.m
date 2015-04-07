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
}

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

        for (NSDictionary* dict in aListOfURLAndDestination) {
            [listOfDownloadItems addObject:[[DownloadItem alloc]initWithURL:dict[@"path"] destination:dict[@"dest"]]];
        }
        
        
    }
    return self;



}



#pragma mark -
#pragma mark Class Methods

-(void)start
{
    [listOfDownloadItems makeObjectsPerformSelector:@selector(start)];
    
}


-(void)cancel
{
    [listOfDownloadItems makeObjectsPerformSelector:@selector(cancel)];
}


@end
